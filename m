From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 02/13] mnt: Refactor fs_fully_visible into
	mount_too_revealing
Date: Mon, 20 Jun 2016 12:21:19 -0500
Message-ID: <20160620172130.15712-2-ebiederm@xmission.com>
References: <87fus77pns.fsf@x220.int.ebiederm.org>
	<20160620172130.15712-1-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160620172130.15712-1-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Replace the call of fs_fully_visible in do_new_mount from before the
new superblock is allocated with a call of mount_too_revealing after
the superblock is allocated.   This winds up being a much better location
for maintainability of the code.

The first change this enables is the replacement of FS_USERNS_VISIBLE
with SB_I_USERNS_VISIBLE.  Moving the flag from struct filesystem_type
to sb_iflags on the superblock.

Unfortunately mount_too_revealing fundamentally needs to touch
mnt_flags adding several MNT_LOCKED_XXX flags at the appropriate
times.  If the mnt_flags did not need to be touched the code
could be easily moved into the filesystem specific mount code.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c     | 38 +++++++++++++++++++++++++-------------
 fs/proc/inode.c    |  1 +
 fs/proc/root.c     |  2 +-
 fs/sysfs/mount.c   |  4 ++--
 include/linux/fs.h |  4 +++-
 5 files changed, 32 insertions(+), 17 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 783004af5707..1a69aa786975 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2375,7 +2375,7 @@ unlock:
 	return err;
 }
 
-static bool fs_fully_visible(struct file_system_type *fs_type, int *new_mnt_flags);
+static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags);
 
 /*
  * create a new mount for userspace and request it to be added into the
@@ -2408,12 +2408,6 @@ static int do_new_mount(struct path *path, const char *fstype, int flags,
 			flags |= MS_NODEV;
 			mnt_flags |= MNT_NODEV | MNT_LOCK_NODEV;
 		}
-		if (type->fs_flags & FS_USERNS_VISIBLE) {
-			if (!fs_fully_visible(type, &mnt_flags)) {
-				put_filesystem(type);
-				return -EPERM;
-			}
-		}
 	}
 
 	mnt = vfs_kern_mount(type, flags, name, data);
@@ -2425,6 +2419,11 @@ static int do_new_mount(struct path *path, const char *fstype, int flags,
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
 
+	if (mount_too_revealing(mnt, &mnt_flags)) {
+		mntput(mnt);
+		return -EPERM;
+	}
+
 	err = do_add_mount(real_mount(mnt), path, mnt_flags);
 	if (err)
 		mntput(mnt);
@@ -3216,22 +3215,19 @@ bool current_chrooted(void)
 	return chrooted;
 }
 
-static bool fs_fully_visible(struct file_system_type *type, int *new_mnt_flags)
+static bool mnt_already_visible(struct mnt_namespace *ns, struct vfsmount *new,
+				int *new_mnt_flags)
 {
-	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
 	int new_flags = *new_mnt_flags;
 	struct mount *mnt;
 	bool visible = false;
 
-	if (unlikely(!ns))
-		return false;
-
 	down_read(&namespace_sem);
 	list_for_each_entry(mnt, &ns->list, mnt_list) {
 		struct mount *child;
 		int mnt_flags;
 
-		if (mnt->mnt.mnt_sb->s_type != type)
+		if (mnt->mnt.mnt_sb->s_type != new->mnt_sb->s_type)
 			continue;
 
 		/* This mount is not fully visible if it's root directory
@@ -3298,6 +3294,22 @@ found:
 	return visible;
 }
 
+static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags)
+{
+	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
+	unsigned long s_iflags;
+
+	if (ns->user_ns == &init_user_ns)
+		return false;
+
+	/* Can this filesystem be too revealing? */
+	s_iflags = mnt->mnt_sb->s_iflags;
+	if (!(s_iflags & SB_I_USERNS_VISIBLE))
+		return false;
+
+	return !mnt_already_visible(ns, mnt, new_mnt_flags);
+}
+
 static struct ns_common *mntns_get(struct task_struct *task)
 {
 	struct ns_common *ns = NULL;
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 42305ddcbaa0..78fa452d65ed 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -462,6 +462,7 @@ int proc_fill_super(struct super_block *s)
 	struct inode *root_inode;
 	int ret;
 
+	s->s_iflags |= SB_I_USERNS_VISIBLE;
 	s->s_flags |= MS_NODIRATIME | MS_NOSUID | MS_NOEXEC;
 	s->s_blocksize = 1024;
 	s->s_blocksize_bits = 10;
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 55bc7d6c8aac..a1b2860fec62 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -158,7 +158,7 @@ static struct file_system_type proc_fs_type = {
 	.name		= "proc",
 	.mount		= proc_mount,
 	.kill_sb	= proc_kill_sb,
-	.fs_flags	= FS_USERNS_VISIBLE | FS_USERNS_MOUNT,
+	.fs_flags	= FS_USERNS_MOUNT,
 };
 
 void __init proc_root_init(void)
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index f3db82071cfb..f31e36994dfb 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -42,7 +42,7 @@ static struct dentry *sysfs_mount(struct file_system_type *fs_type,
 		kobj_ns_drop(KOBJ_NS_TYPE_NET, ns);
 	else if (new_sb)
 		/* Userspace would break if executables appear on sysfs */
-		root->d_sb->s_iflags |= SB_I_NOEXEC;
+		root->d_sb->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC;
 
 	return root;
 }
@@ -59,7 +59,7 @@ static struct file_system_type sysfs_fs_type = {
 	.name		= "sysfs",
 	.mount		= sysfs_mount,
 	.kill_sb	= sysfs_kill_sb,
-	.fs_flags	= FS_USERNS_VISIBLE | FS_USERNS_MOUNT,
+	.fs_flags	= FS_USERNS_MOUNT,
 };
 
 int __init sysfs_init(void)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index dd288148a6b1..71988dd3af95 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1328,6 +1328,9 @@ struct mm_struct;
 #define SB_I_CGROUPWB	0x00000001	/* cgroup-aware writeback enabled */
 #define SB_I_NOEXEC	0x00000002	/* Ignore executables on this fs */
 
+/* sb->s_iflags to limit user namespace mounts */
+#define SB_I_USERNS_VISIBLE		0x00000010 /* fstype already mounted */
+
 /* Possible states of 'frozen' field */
 enum {
 	SB_UNFROZEN = 0,		/* FS is unfrozen */
@@ -2011,7 +2014,6 @@ struct file_system_type {
 #define FS_HAS_SUBTYPE		4
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
 #define FS_USERNS_DEV_MOUNT	16 /* A userns mount does not imply MNT_NODEV */
-#define FS_USERNS_VISIBLE	32	/* FS must already be visible */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
 	struct dentry *(*mount) (struct file_system_type *, int,
 		       const char *, void *);
-- 
2.8.3
