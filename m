From: Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] [RFC][WIP] namespace.c: Allow some unprivileged proc mounts
	when not fully visible
Date: Wed,  4 Apr 2018 13:53:11 +0200
Message-ID: <20180404115311.725-1-alban@kinvolk.io>
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
To: Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Cc: Iago Lopez Galeiras <iago-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Crosby <crosbymichael-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Stephen J Day <stephen.day-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jess Frazelle <acidburn-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Since Linux v4.2 with commit 1b852bceb0d1 ("mnt: Refactor the logic for
mounting sysfs and proc in a user namespace"), new mounts of proc or
sysfs in non init userns are only allowed when there is at least one
fully-visible proc or sysfs mount.

This is to enforce that proc/sysfs files masked by a mount are still
masked in a new mount in a unprivileged userns. The locked mount logic
for bind mounts (has_locked_children()) was not enough in the case of
proc/sysfs new mounts because some files in proc (/proc/kcore) exist as
a singleton rather than being owned by a specific proc mount.

Unfortunately, this blocks me from using userns from within a Docker
container because Docker containers mask entries such as /proc/kcore. My
use case is to build container images with arbitrary commands (such as
using "RUN" commands in Dockerfiles) without privileges and from within
a Docker container. Those arbitrary commands could be shell scripts that
require /proc.

The following commands show my problem:

$ sudo docker run -ti --rm --cap-add=SYS_ADMIN busybox sh -c 'unshare -U -r -p -m -f mount -t proc proc /home && echo ok'
mount: permission denied (are you root?)

$ sudo docker run -ti --rm --cap-add=SYS_ADMIN busybox sh -c 'mkdir -p /unmasked-proc && mount -t proc proc /unmasked-proc && unshare -U -r -p -m -f mount -t proc proc /home && echo ok'
ok

This patch is a WIP attempt to ease new proc mounts in a user namespace
even when the proc mount in the parent container has masked entries.
However, to preserve the security guarantee of mount_too_revealing(),
the same masked entries in the old proc mount must be masked in the new
proc mount.

It cannot be masked with mounts covering the entries because it's not
possible to use MS_REC for new proc mount and add covering submounts at
the same time. Instead, it introduces new options in proc to disable
some proc entries (TBD). A proc entry will be disabled when all other
proc mounts have the same entry disabled, or when all other proc mounts
have the same entry masked by a submount.

The granularity does not need to be per proc entry. It is simpler to
define categories of entries that can be hidden. In practice, only a few
entries need to support disablement and what matters is that the new
proc mount is more masked than the other proc mounts. Granularity can be
improved later if use cases exist.

The flag IOP_USERNS_HIDEABLE is added on some proc inodes that are
singletons such as /proc/kcore. This flag is used in
mnt_already_visible() to signal that, as an exception to the general
rule, the file can be masked by a mount without blocking the new proc
mount. The hideable category is computed (WIP) and returned (WIP) in
order to configure the new proc mount before attaching it to the mount
tree.

For my use case, I will need to support at least the following entries:

$ sudo docker run -ti --rm busybox sh -c 'mount|grep /proc/'
proc on /proc/asound type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/bus type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/fs type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/irq type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/sys type proc (ro,nosuid,nodev,noexec,relatime)
proc on /proc/sysrq-trigger type proc (ro,nosuid,nodev,noexec,relatime)
tmpfs on /proc/kcore type tmpfs (rw,context="...",nosuid,mode=755)
tmpfs on /proc/latency_stats type tmpfs (rw,context="...",nosuid,mode=755)
tmpfs on /proc/timer_list type tmpfs (rw,context="...",nosuid,mode=755)
tmpfs on /proc/sched_debug type tmpfs (rw,context="...",nosuid,mode=755)
tmpfs on /proc/scsi type tmpfs (ro,seclabel,relatime)

This patch can be tested in the following way:

$ sudo unshare -p -f -m sh -c "mount --bind /dev/null /proc/cmdline && unshare -U -r -p -m -f mount -t proc proc /proc && echo ok"
mount: /proc: permission denied.
(this patch does not support /proc/cmdline as hideable)

$ sudo unshare -p -f -m sh -c "mount --bind /dev/null /proc/kcore && unshare -U -r -p -m -f mount -t proc proc /proc && echo ok"
ok
(this patch marks /proc/kcore as hideable: the new mounts works fine,
whereas it didn't work on vanilla kernels)

Signed-off-by: Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
---
 fs/namespace.c     | 26 +++++++++++++++++++++-----
 fs/proc/generic.c  |  5 +++++
 fs/proc/inode.c    |  2 ++
 fs/proc/internal.h |  1 +
 include/linux/fs.h |  1 +
 5 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 9d1374ab6e06..0d466885c181 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2489,7 +2489,7 @@ static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags)
 	return err;
 }
 
-static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags);
+static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags, int *hideable_categories);
 
 /*
  * create a new mount for userspace and request it to be added into the
@@ -2500,6 +2500,7 @@ static int do_new_mount(struct path *path, const char *fstype, int sb_flags,
 {
 	struct file_system_type *type;
 	struct vfsmount *mnt;
+	int hideable_categories = 0;
 	int err;
 
 	if (!fstype)
@@ -2518,11 +2519,15 @@ static int do_new_mount(struct path *path, const char *fstype, int sb_flags,
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
 
-	if (mount_too_revealing(mnt, &mnt_flags)) {
+	if (mount_too_revealing(mnt, &mnt_flags, &hideable_categories)) {
 		mntput(mnt);
 		return -EPERM;
 	}
 
+	if (hideable_categories != 0) {
+		/* TODO: configure the mount to hide the categories of files */
+	}
+
 	err = do_add_mount(real_mount(mnt), path, mnt_flags);
 	if (err)
 		mntput(mnt);
@@ -3342,7 +3347,7 @@ bool current_chrooted(void)
 }
 
 static bool mnt_already_visible(struct mnt_namespace *ns, struct vfsmount *new,
-				int *new_mnt_flags)
+				int *new_mnt_flags, int *hideable_categories)
 {
 	int new_flags = *new_mnt_flags;
 	struct mount *mnt;
@@ -3352,6 +3357,7 @@ static bool mnt_already_visible(struct mnt_namespace *ns, struct vfsmount *new,
 	list_for_each_entry(mnt, &ns->list, mnt_list) {
 		struct mount *child;
 		int mnt_flags;
+		int local_hideable_categories = 0;
 
 		if (mnt->mnt.mnt_sb->s_type != new->mnt_sb->s_type)
 			continue;
@@ -3388,6 +3394,12 @@ static bool mnt_already_visible(struct mnt_namespace *ns, struct vfsmount *new,
 			/* Only worry about locked mounts */
 			if (!(child->mnt.mnt_flags & MNT_LOCKED))
 				continue;
+			/* Hideable inodes might be ok but gather categories */
+			if (inode->i_opflags & IOP_USERNS_HIDEABLE) {
+				/* TODO: get proc_dir_entry->userns_hideable_categories */
+				local_hideable_categories |= 0x01;
+				continue;
+			}
 			/* Is the directory permanetly empty? */
 			if (!is_empty_dir_inode(inode))
 				goto next;
@@ -3395,6 +3407,10 @@ static bool mnt_already_visible(struct mnt_namespace *ns, struct vfsmount *new,
 		/* Preserve the locked attributes */
 		*new_mnt_flags |= mnt_flags & (MNT_LOCK_READONLY | \
 					       MNT_LOCK_ATIME);
+		/* Preserve hidden categories */
+		*hideable_categories |= local_hideable_categories;
+		/* TODO: for nested containers */
+		*hideable_categories |= 0; /* proc_sb(mnt->mnt.mnt_sb)->hideable_categories */
 		visible = true;
 		goto found;
 	next:	;
@@ -3404,7 +3420,7 @@ static bool mnt_already_visible(struct mnt_namespace *ns, struct vfsmount *new,
 	return visible;
 }
 
-static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags)
+static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags, int *hideable_categories)
 {
 	const unsigned long required_iflags = SB_I_NOEXEC | SB_I_NODEV;
 	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
@@ -3424,7 +3440,7 @@ static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags)
 		return true;
 	}
 
-	return !mnt_already_visible(ns, mnt, new_mnt_flags);
+	return !mnt_already_visible(ns, mnt, new_mnt_flags, hideable_categories);
 }
 
 bool mnt_may_suid(struct vfsmount *mnt)
diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 5d709fa8f3a2..96537a0f751e 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -491,6 +491,11 @@ struct proc_dir_entry *proc_create_data(const char *name, umode_t mode,
 	pde->proc_fops = proc_fops;
 	pde->data = data;
 	pde->proc_iops = &proc_file_inode_operations;
+
+	// TODO: add parameters to proc_create() instead of hardcoding
+	if (strcmp(name, "kcore") == 0)
+		pde->userns_hideable = true;
+
 	if (proc_register(parent, pde) < 0)
 		goto out_free;
 	return pde;
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 6e8724958116..dbf8f2dfe85e 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -455,6 +455,8 @@ struct inode *proc_get_inode(struct super_block *sb, struct proc_dir_entry *de)
 			set_nlink(inode, de->nlink);
 		WARN_ON(!de->proc_iops);
 		inode->i_op = de->proc_iops;
+		if (de->userns_hideable)
+			inode->i_opflags |= IOP_USERNS_HIDEABLE;
 		if (de->proc_fops) {
 			if (S_ISREG(inode->i_mode)) {
 #ifdef CONFIG_COMPAT
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index d697c8ab0a14..7176fbff3660 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -52,6 +52,7 @@ struct proc_dir_entry {
 	struct proc_dir_entry *parent;
 	struct rb_root_cached subdir;
 	struct rb_node subdir_node;
+	bool userns_hideable;
 	umode_t mode;
 	u8 namelen;
 	char name[];
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c6baf767619e..4203c4d3330f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -559,6 +559,7 @@ is_uncached_acl(struct posix_acl *acl)
 #define IOP_NOFOLLOW	0x0004
 #define IOP_XATTR	0x0008
 #define IOP_DEFAULT_READLINK	0x0010
+#define IOP_USERNS_HIDEABLE	0x0020
 
 struct fsnotify_mark_connector;
 
-- 
2.14.3
