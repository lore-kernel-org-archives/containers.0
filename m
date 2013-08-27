From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 1/2] userns: Better restrictions on when proc and
	sysfs can be mounted
Date: Tue, 27 Aug 2013 14:44:39 -0700
Message-ID: <878uzmhkqg.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Rely on the fact that another flavor of the filesystem is already
mounted and do not rely on state in the user namespace.

Verify that the mounted filesystem is not covered in any significant
way.  I would love to verify that the previously mounted filesystem
has no mounts on top but there are at least the directories
/proc/sys/fs/binfmt_misc and /sys/fs/cgroup/ that exist explicitly
for other filesystems to mount on top of.

Refactor the test into a function named fs_fully_visible and call that
function from the mount routines of proc and sysfs.  This makes this
test local to the filesystems involved and the results current of when
the mounts take place, removing a weird threading of the user
namespace, the mount namespace and the filesystems themselves.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c                 |   37 +++++++++++++++++++++++++------------
 fs/proc/root.c                 |    7 +++++--
 fs/sysfs/mount.c               |    3 ++-
 include/linux/fs.h             |    1 +
 include/linux/user_namespace.h |    4 ----
 kernel/user.c                  |    2 --
 kernel/user_namespace.c        |    2 --
 7 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 64627f8..877e427 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2867,25 +2867,38 @@ bool current_chrooted(void)
 	return chrooted;
 }
 
-void update_mnt_policy(struct user_namespace *userns)
+bool fs_fully_visible(struct file_system_type *type)
 {
 	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
 	struct mount *mnt;
+	bool visible = false;
 
-	down_read(&namespace_sem);
+	if (unlikely(!ns))
+		return false;
+
+	namespace_lock();
 	list_for_each_entry(mnt, &ns->list, mnt_list) {
-		switch (mnt->mnt.mnt_sb->s_magic) {
-		case SYSFS_MAGIC:
-			userns->may_mount_sysfs = true;
-			break;
-		case PROC_SUPER_MAGIC:
-			userns->may_mount_proc = true;
-			break;
+		struct mount *child;
+		if (mnt->mnt.mnt_sb->s_type != type)
+			continue;
+
+		/* This mount is not fully visible if there are any child mounts
+		 * that cover anything except for empty directories.
+		 */
+		list_for_each_entry(child, &mnt->mnt_mounts, mnt_child) {
+			struct inode *inode = child->mnt_mountpoint->d_inode;
+			if (!S_ISDIR(inode->i_mode))
+				goto next;
+			if (inode->i_nlink != 2)
+				goto next;
 		}
-		if (userns->may_mount_sysfs && userns->may_mount_proc)
-			break;
+		visible = true;
+		goto found;
+	next:	;
 	}
-	up_read(&namespace_sem);
+found:
+	namespace_unlock();
+	return visible;
 }
 
 static void *mntns_get(struct task_struct *task)
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 38bd5d4..45e5fb7 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -110,8 +110,11 @@ static struct dentry *proc_mount(struct file_system_type *fs_type,
 		ns = task_active_pid_ns(current);
 		options = data;
 
-		if (!current_user_ns()->may_mount_proc ||
-		    !ns_capable(ns->user_ns, CAP_SYS_ADMIN))
+		if (!capable(CAP_SYS_ADMIN) && !fs_fully_visible(fs_type))
+			return ERR_PTR(-EPERM);
+
+		/* Does the mounter have privilege over the pid namespace? */
+		if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN))
 			return ERR_PTR(-EPERM);
 	}
 
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index afd8327..4a2da3a 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -112,7 +112,8 @@ static struct dentry *sysfs_mount(struct file_system_type *fs_type,
 	struct super_block *sb;
 	int error;
 
-	if (!(flags & MS_KERNMOUNT) && !current_user_ns()->may_mount_sysfs)
+	if (!(flags & MS_KERNMOUNT) && !capable(CAP_SYS_ADMIN) &&
+	    !fs_fully_visible(fs_type))
 		return ERR_PTR(-EPERM);
 
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9818747..3050c62 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1897,6 +1897,7 @@ extern int vfs_ustat(dev_t, struct kstatfs *);
 extern int freeze_super(struct super_block *super);
 extern int thaw_super(struct super_block *super);
 extern bool our_mnt(struct vfsmount *mnt);
+extern bool fs_fully_visible(struct file_system_type *);
 
 extern int current_umask(void);
 
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index b6b215f..4ce0093 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -26,8 +26,6 @@ struct user_namespace {
 	kuid_t			owner;
 	kgid_t			group;
 	unsigned int		proc_inum;
-	bool			may_mount_sysfs;
-	bool			may_mount_proc;
 };
 
 extern struct user_namespace init_user_ns;
@@ -84,6 +82,4 @@ static inline void put_user_ns(struct user_namespace *ns)
 
 #endif
 
-void update_mnt_policy(struct user_namespace *userns);
-
 #endif /* _LINUX_USER_H */
diff --git a/kernel/user.c b/kernel/user.c
index 69b4c3d..5bbb919 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -51,8 +51,6 @@ struct user_namespace init_user_ns = {
 	.owner = GLOBAL_ROOT_UID,
 	.group = GLOBAL_ROOT_GID,
 	.proc_inum = PROC_USER_INIT_INO,
-	.may_mount_sysfs = true,
-	.may_mount_proc = true,
 };
 EXPORT_SYMBOL_GPL(init_user_ns);
 
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index d8c30db..d58ad1e 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -97,8 +97,6 @@ int create_user_ns(struct cred *new)
 
 	set_cred_user_ns(new, ns);
 
-	update_mnt_policy(ns);
-
 	return 0;
 }
 
-- 
1.7.5.4
