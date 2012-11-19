From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 5/6] vfs: Allow unprivileged manipulation of the mount
	namespace.
Date: Mon, 19 Nov 2012 02:50:21 -0800
Message-ID: <1353322222-27060-5-git-send-email-ebiederm@xmission.com>
References: <87k3thc1h3.fsf@xmission.com>
	<1353322222-27060-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353322222-27060-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

- Add a filesystem flag to mark filesystems that are safe to mount as
  an unprivileged user.

- Add a filesystem flag to mark filesystems that don't need MNT_NODEV
  when mounted by an unprivileged user.

- Relax the permission checks to allow unprivileged users that have
  CAP_SYS_ADMIN permissions in the user namespace referred to by the
  current mount namespace to be allowed to mount, unmount, and move
  filesystems.

Acked-by: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c     |   69 ++++++++++++++++++++++++++++++++-------------------
 include/linux/fs.h |    2 +
 2 files changed, 45 insertions(+), 26 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 4dfcaf0..9ddc86f 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1269,7 +1269,7 @@ SYSCALL_DEFINE2(umount, char __user *, name, int, flags)
 		goto dput_and_out;
 
 	retval = -EPERM;
-	if (!capable(CAP_SYS_ADMIN))
+	if (!ns_capable(mnt->mnt_ns->user_ns, CAP_SYS_ADMIN))
 		goto dput_and_out;
 
 	retval = do_umount(mnt, flags);
@@ -1295,7 +1295,7 @@ SYSCALL_DEFINE1(oldumount, char __user *, name)
 
 static int mount_is_safe(struct path *path)
 {
-	if (capable(CAP_SYS_ADMIN))
+	if (ns_capable(real_mount(path->mnt)->mnt_ns->user_ns, CAP_SYS_ADMIN))
 		return 0;
 	return -EPERM;
 #ifdef notyet
@@ -1633,7 +1633,7 @@ static int do_change_type(struct path *path, int flag)
 	int type;
 	int err = 0;
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!ns_capable(mnt->mnt_ns->user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
 
 	if (path->dentry != path->mnt->mnt_root)
@@ -1797,7 +1797,7 @@ static int do_move_mount(struct path *path, const char *old_name)
 	struct mount *p;
 	struct mount *old;
 	int err = 0;
-	if (!capable(CAP_SYS_ADMIN))
+	if (!ns_capable(real_mount(path->mnt)->mnt_ns->user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
 	if (!old_name || !*old_name)
 		return -EINVAL;
@@ -1884,21 +1884,6 @@ static struct vfsmount *fs_set_subtype(struct vfsmount *mnt, const char *fstype)
 	return ERR_PTR(err);
 }
 
-static struct vfsmount *
-do_kern_mount(const char *fstype, int flags, const char *name, void *data)
-{
-	struct file_system_type *type = get_fs_type(fstype);
-	struct vfsmount *mnt;
-	if (!type)
-		return ERR_PTR(-ENODEV);
-	mnt = vfs_kern_mount(type, flags, name, data);
-	if (!IS_ERR(mnt) && (type->fs_flags & FS_HAS_SUBTYPE) &&
-	    !mnt->mnt_sb->s_subtype)
-		mnt = fs_set_subtype(mnt, fstype);
-	put_filesystem(type);
-	return mnt;
-}
-
 /*
  * add a mount into a namespace's mount tree
  */
@@ -1944,20 +1929,46 @@ unlock:
  * create a new mount for userspace and request it to be added into the
  * namespace's tree
  */
-static int do_new_mount(struct path *path, const char *type, int flags,
+static int do_new_mount(struct path *path, const char *fstype, int flags,
 			int mnt_flags, const char *name, void *data)
 {
+	struct file_system_type *type;
+	struct user_namespace *user_ns;
 	struct vfsmount *mnt;
 	int err;
 
-	if (!type)
+	if (!fstype)
 		return -EINVAL;
 
 	/* we need capabilities... */
-	if (!capable(CAP_SYS_ADMIN))
+	user_ns = real_mount(path->mnt)->mnt_ns->user_ns;
+	if (!ns_capable(user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
 
-	mnt = do_kern_mount(type, flags, name, data);
+	type = get_fs_type(fstype);
+	if (!type)
+		return -ENODEV;
+
+	if (user_ns != &init_user_ns) {
+		if (!(type->fs_flags & FS_USERNS_MOUNT)) {
+			put_filesystem(type);
+			return -EPERM;
+		}
+		/* Only in special cases allow devices from mounts
+		 * created outside the initial user namespace.
+		 */
+		if (!(type->fs_flags & FS_USERNS_DEV_MOUNT)) {
+			flags |= MS_NODEV;
+			mnt_flags |= MNT_NODEV;
+		}
+	}
+
+	mnt = vfs_kern_mount(type, flags, name, data);
+	if (!IS_ERR(mnt) && (type->fs_flags & FS_HAS_SUBTYPE) &&
+	    !mnt->mnt_sb->s_subtype)
+		mnt = fs_set_subtype(mnt, fstype);
+
+	put_filesystem(type);
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
 
@@ -2549,7 +2560,7 @@ SYSCALL_DEFINE2(pivot_root, const char __user *, new_root,
 	struct mount *new_mnt, *root_mnt;
 	int error;
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!ns_capable(current->nsproxy->mnt_ns->user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
 
 	error = user_path_dir(new_root, &new);
@@ -2631,8 +2642,13 @@ static void __init init_mount_tree(void)
 	struct vfsmount *mnt;
 	struct mnt_namespace *ns;
 	struct path root;
+	struct file_system_type *type;
 
-	mnt = do_kern_mount("rootfs", 0, "rootfs", NULL);
+	type = get_fs_type("rootfs");
+	if (!type)
+		panic("Can't find rootfs type");
+	mnt = vfs_kern_mount(type, 0, "rootfs", NULL);
+	put_filesystem(type);
 	if (IS_ERR(mnt))
 		panic("Can't create rootfs");
 
@@ -2757,7 +2773,8 @@ static int mntns_install(struct nsproxy *nsproxy, void *ns)
 	struct mnt_namespace *mnt_ns = ns;
 	struct path root;
 
-	if (!capable(CAP_SYS_ADMIN) || !capable(CAP_SYS_CHROOT))
+	if (!ns_capable(mnt_ns->user_ns, CAP_SYS_ADMIN) ||
+	    !nsown_capable(CAP_SYS_CHROOT))
 		return -EINVAL;
 
 	if (fs->users != 1)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b33cfc9..5037aa6 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1812,6 +1812,8 @@ struct file_system_type {
 #define FS_REQUIRES_DEV		1 
 #define FS_BINARY_MOUNTDATA	2
 #define FS_HAS_SUBTYPE		4
+#define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
+#define FS_USERNS_DEV_MOUNT	16 /* A userns mount does not imply MNT_NODEV */
 #define FS_REVAL_DOT		16384	/* Check the paths ".", ".." for staleness */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
 	struct dentry *(*mount) (struct file_system_type *, int,
-- 
1.7.5.4
