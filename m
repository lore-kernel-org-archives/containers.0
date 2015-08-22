From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] User namespace related changes for v4.3
Date: Sat, 22 Aug 2015 02:40:27 -0500
Message-ID: <87io876aac.fsf@x220.int.ebiederm.org>
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
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

I am out out on vacation for the next week or so, and I expect
the merge window will open before I return so I am sending my pull
request for the 4.3 merge window early.

When the merge window for v4.3 opens please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: 4b75de8615050c1b0dd8d7794838c42f74ed36ba fs: Set the size of empty dirs to 0.

This little branch finishes up the changes to ensure proc and
sysfs do not start implementing executable files, as the there are
application today that are only secure because such files do not exist.

This branch fixes a long standing misfeature of /proc/<pid>/mountinfo
that did not show the proper source for files bind mounted from
/proc/<pid>/ns/*.

This branch straightens out the handling of clone flags related to user
namespaces, fixing an unnecessary failure of unshare(CLONE_NEWUSER) when
files such as /proc/<pid>/environ are read while <pid> is calling
unshare.  This winds up fixing a minor bug in unshare flag handling that
dates back to the first version of unshare in the kernel.

This branch fixes a minor regression caused by the introduction of
sysfs_create_mount_point, which broke someone's in house application,
by restoring the size of /sys/fs/cgroup to 0 bytes.  Apparently that
application uses the directory size to determine if a tmpfs is mounted
on /sys/fs/cgroup.

The bind mount escape fixes are present in Al Viros for-next branch. and
I expect them to come from there.  The bind mount escape is the last of
the user namespace related security bugs that I am aware of.

Eric W. Biederman (6):
      vfs: Commit to never having exectuables on proc and sysfs.
      mnt: fs_fully_visible enforce noexec and nosuid  if !SB_I_NOEXEC
      nsfs: Add a show_path method to fix mountinfo
      unshare: Unsharing a thread does not require unsharing a vm
      userns,pidns: Force thread group sharing, not signal handler sharing.
      fs: Set the size of empty dirs to 0.

 fs/exec.c               | 10 ++++++++--
 fs/libfs.c              |  2 +-
 fs/namespace.c          | 33 +++++++++++++++++++++++++--------
 fs/nsfs.c               | 10 ++++++++++
 fs/open.c               |  2 +-
 fs/proc/root.c          |  2 ++
 fs/sysfs/mount.c        |  4 ++++
 include/linux/fs.h      |  3 +++
 kernel/fork.c           | 36 ++++++++++++++++++++++--------------
 kernel/sys.c            |  3 +--
 kernel/user_namespace.c |  4 ++--
 mm/mmap.c               |  4 ++--
 mm/nommu.c              |  2 +-
 security/security.c     |  2 +-
 14 files changed, 83 insertions(+), 34 deletions(-)

---

diff --git a/fs/exec.c b/fs/exec.c
index 1977c2a553ac..b06623a9347f 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -98,6 +98,12 @@ static inline void put_binfmt(struct linux_binfmt * fmt)
 	module_put(fmt->module);
 }
 
+bool path_noexec(const struct path *path)
+{
+	return (path->mnt->mnt_flags & MNT_NOEXEC) ||
+	       (path->mnt->mnt_sb->s_iflags & SB_I_NOEXEC);
+}
+
 #ifdef CONFIG_USELIB
 /*
  * Note that a shared library must be both readable and executable due to
@@ -132,7 +138,7 @@ SYSCALL_DEFINE1(uselib, const char __user *, library)
 		goto exit;
 
 	error = -EACCES;
-	if (file->f_path.mnt->mnt_flags & MNT_NOEXEC)
+	if (path_noexec(&file->f_path))
 		goto exit;
 
 	fsnotify_open(file);
@@ -777,7 +783,7 @@ static struct file *do_open_execat(int fd, struct filename *name, int flags)
 	if (!S_ISREG(file_inode(file)->i_mode))
 		goto exit;
 
-	if (file->f_path.mnt->mnt_flags & MNT_NOEXEC)
+	if (path_noexec(&file->f_path))
 		goto exit;
 
 	err = deny_write_access(file);
diff --git a/fs/libfs.c b/fs/libfs.c
index 102edfd39000..c7cbfb092e94 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -1185,7 +1185,7 @@ void make_empty_dir_inode(struct inode *inode)
 	inode->i_uid = GLOBAL_ROOT_UID;
 	inode->i_gid = GLOBAL_ROOT_GID;
 	inode->i_rdev = 0;
-	inode->i_size = 2;
+	inode->i_size = 0;
 	inode->i_blkbits = PAGE_SHIFT;
 	inode->i_blocks = 0;
 
diff --git a/fs/namespace.c b/fs/namespace.c
index c7cb8a526c05..ce428cadd41f 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3194,6 +3194,8 @@ static bool fs_fully_visible(struct file_system_type *type, int *new_mnt_flags)
 	down_read(&namespace_sem);
 	list_for_each_entry(mnt, &ns->list, mnt_list) {
 		struct mount *child;
+		int mnt_flags;
+
 		if (mnt->mnt.mnt_sb->s_type != type)
 			continue;
 
@@ -3203,17 +3205,30 @@ static bool fs_fully_visible(struct file_system_type *type, int *new_mnt_flags)
 		if (mnt->mnt.mnt_root != mnt->mnt.mnt_sb->s_root)
 			continue;
 
+		/* Read the mount flags and filter out flags that
+		 * may safely be ignored.
+		 */
+		mnt_flags = mnt->mnt.mnt_flags;
+		if (mnt->mnt.mnt_sb->s_iflags & SB_I_NOEXEC)
+			mnt_flags &= ~(MNT_LOCK_NOSUID | MNT_LOCK_NOEXEC);
+
 		/* Verify the mount flags are equal to or more permissive
 		 * than the proposed new mount.
 		 */
-		if ((mnt->mnt.mnt_flags & MNT_LOCK_READONLY) &&
+		if ((mnt_flags & MNT_LOCK_READONLY) &&
 		    !(new_flags & MNT_READONLY))
 			continue;
-		if ((mnt->mnt.mnt_flags & MNT_LOCK_NODEV) &&
+		if ((mnt_flags & MNT_LOCK_NODEV) &&
 		    !(new_flags & MNT_NODEV))
 			continue;
-		if ((mnt->mnt.mnt_flags & MNT_LOCK_ATIME) &&
-		    ((mnt->mnt.mnt_flags & MNT_ATIME_MASK) != (new_flags & MNT_ATIME_MASK)))
+		if ((mnt_flags & MNT_LOCK_NOSUID) &&
+		    !(new_flags & MNT_NOSUID))
+			continue;
+		if ((mnt_flags & MNT_LOCK_NOEXEC) &&
+		    !(new_flags & MNT_NOEXEC))
+			continue;
+		if ((mnt_flags & MNT_LOCK_ATIME) &&
+		    ((mnt_flags & MNT_ATIME_MASK) != (new_flags & MNT_ATIME_MASK)))
 			continue;
 
 		/* This mount is not fully visible if there are any
@@ -3223,16 +3238,18 @@ static bool fs_fully_visible(struct file_system_type *type, int *new_mnt_flags)
 		list_for_each_entry(child, &mnt->mnt_mounts, mnt_child) {
 			struct inode *inode = child->mnt_mountpoint->d_inode;
 			/* Only worry about locked mounts */
-			if (!(mnt->mnt.mnt_flags & MNT_LOCKED))
+			if (!(mnt_flags & MNT_LOCKED))
 				continue;
 			/* Is the directory permanetly empty? */
 			if (!is_empty_dir_inode(inode))
 				goto next;
 		}
 		/* Preserve the locked attributes */
-		*new_mnt_flags |= mnt->mnt.mnt_flags & (MNT_LOCK_READONLY | \
-							MNT_LOCK_NODEV    | \
-							MNT_LOCK_ATIME);
+		*new_mnt_flags |= mnt_flags & (MNT_LOCK_READONLY | \
+					       MNT_LOCK_NODEV    | \
+					       MNT_LOCK_NOSUID   | \
+					       MNT_LOCK_NOEXEC   | \
+					       MNT_LOCK_ATIME);
 		visible = true;
 		goto found;
 	next:	;
diff --git a/fs/nsfs.c b/fs/nsfs.c
index 99521e7c492b..e4905fbf3396 100644
--- a/fs/nsfs.c
+++ b/fs/nsfs.c
@@ -4,6 +4,7 @@
 #include <linux/proc_ns.h>
 #include <linux/magic.h>
 #include <linux/ktime.h>
+#include <linux/seq_file.h>
 
 static struct vfsmount *nsfs_mnt;
 
@@ -136,9 +137,18 @@ out_invalid:
 	return ERR_PTR(-EINVAL);
 }
 
+static int nsfs_show_path(struct seq_file *seq, struct dentry *dentry)
+{
+	struct inode *inode = d_inode(dentry);
+	const struct proc_ns_operations *ns_ops = dentry->d_fsdata;
+
+	return seq_printf(seq, "%s:[%lu]", ns_ops->name, inode->i_ino);
+}
+
 static const struct super_operations nsfs_ops = {
 	.statfs = simple_statfs,
 	.evict_inode = nsfs_evict,
+	.show_path = nsfs_show_path,
 };
 static struct dentry *nsfs_mount(struct file_system_type *fs_type,
 			int flags, const char *dev_name, void *data)
diff --git a/fs/open.c b/fs/open.c
index e33dab287fa0..b6f1e96a7c0b 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -377,7 +377,7 @@ retry:
 		 * with the "noexec" flag.
 		 */
 		res = -EACCES;
-		if (path.mnt->mnt_flags & MNT_NOEXEC)
+		if (path_noexec(&path))
 			goto out_path_release;
 	}
 
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 68feb0f70e63..361ab4ee42fc 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -134,6 +134,8 @@ static struct dentry *proc_mount(struct file_system_type *fs_type,
 		}
 
 		sb->s_flags |= MS_ACTIVE;
+		/* User space would break if executables appear on proc */
+		sb->s_iflags |= SB_I_NOEXEC;
 	}
 
 	return dget(sb->s_root);
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index 1c6ac6fcee9f..f3db82071cfb 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -40,6 +40,10 @@ static struct dentry *sysfs_mount(struct file_system_type *fs_type,
 				SYSFS_MAGIC, &new_sb, ns);
 	if (IS_ERR(root) || !new_sb)
 		kobj_ns_drop(KOBJ_NS_TYPE_NET, ns);
+	else if (new_sb)
+		/* Userspace would break if executables appear on sysfs */
+		root->d_sb->s_iflags |= SB_I_NOEXEC;
+
 	return root;
 }
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a0653e560c26..42912f8d286e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1244,6 +1244,7 @@ struct mm_struct;
 
 /* sb->s_iflags */
 #define SB_I_CGROUPWB	0x00000001	/* cgroup-aware writeback enabled */
+#define SB_I_NOEXEC	0x00000002	/* Ignore executables on this fs */
 
 /* Possible states of 'frozen' field */
 enum {
@@ -3030,4 +3031,6 @@ static inline bool dir_relax(struct inode *inode)
 	return !IS_DEADDIR(inode);
 }
 
+extern bool path_noexec(const struct path *path);
+
 #endif /* _LINUX_FS_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 1bfefc6f96a4..2c72b8a8ae24 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1273,10 +1273,9 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 
 	/*
 	 * If the new process will be in a different pid or user namespace
-	 * do not allow it to share a thread group or signal handlers or
-	 * parent with the forking task.
+	 * do not allow it to share a thread group with the forking task.
 	 */
-	if (clone_flags & CLONE_SIGHAND) {
+	if (clone_flags & CLONE_THREAD) {
 		if ((clone_flags & (CLONE_NEWUSER | CLONE_NEWPID)) ||
 		    (task_active_pid_ns(current) !=
 				current->nsproxy->pid_ns_for_children))
@@ -1866,13 +1865,21 @@ static int check_unshare_flags(unsigned long unshare_flags)
 				CLONE_NEWUSER|CLONE_NEWPID))
 		return -EINVAL;
 	/*
-	 * Not implemented, but pretend it works if there is nothing to
-	 * unshare. Note that unsharing CLONE_THREAD or CLONE_SIGHAND
-	 * needs to unshare vm.
+	 * Not implemented, but pretend it works if there is nothing
+	 * to unshare.  Note that unsharing the address space or the
+	 * signal handlers also need to unshare the signal queues (aka
+	 * CLONE_THREAD).
 	 */
 	if (unshare_flags & (CLONE_THREAD | CLONE_SIGHAND | CLONE_VM)) {
-		/* FIXME: get_task_mm() increments ->mm_users */
-		if (atomic_read(&current->mm->mm_users) > 1)
+		if (!thread_group_empty(current))
+			return -EINVAL;
+	}
+	if (unshare_flags & (CLONE_SIGHAND | CLONE_VM)) {
+		if (atomic_read(&current->sighand->count) > 1)
+			return -EINVAL;
+	}
+	if (unshare_flags & CLONE_VM) {
+		if (!current_is_single_threaded())
 			return -EINVAL;
 	}
 
@@ -1936,21 +1943,22 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
 	int err;
 
 	/*
-	 * If unsharing a user namespace must also unshare the thread.
+	 * If unsharing a user namespace must also unshare the thread group
+	 * and unshare the filesystem root and working directories.
 	 */
 	if (unshare_flags & CLONE_NEWUSER)
 		unshare_flags |= CLONE_THREAD | CLONE_FS;
 	/*
-	 * If unsharing a thread from a thread group, must also unshare vm.
-	 */
-	if (unshare_flags & CLONE_THREAD)
-		unshare_flags |= CLONE_VM;
-	/*
 	 * If unsharing vm, must also unshare signal handlers.
 	 */
 	if (unshare_flags & CLONE_VM)
 		unshare_flags |= CLONE_SIGHAND;
 	/*
+	 * If unsharing a signal handlers, must also unshare the signal queues.
+	 */
+	if (unshare_flags & CLONE_SIGHAND)
+		unshare_flags |= CLONE_THREAD;
+	/*
 	 * If unsharing namespace, must also unshare filesystem information.
 	 */
 	if (unshare_flags & CLONE_NEWNS)
diff --git a/kernel/sys.c b/kernel/sys.c
index 259fda25eb6b..fa2f2f671a5c 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1668,8 +1668,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	 * overall picture.
 	 */
 	err = -EACCES;
-	if (!S_ISREG(inode->i_mode)	||
-	    exe.file->f_path.mnt->mnt_flags & MNT_NOEXEC)
+	if (!S_ISREG(inode->i_mode) || path_noexec(&exe.file->f_path))
 		goto exit;
 
 	err = inode_permission(inode, MAY_EXEC);
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 4109f8320684..f65a0a06a8c0 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -976,8 +976,8 @@ static int userns_install(struct nsproxy *nsproxy, struct ns_common *ns)
 	if (user_ns == current_user_ns())
 		return -EINVAL;
 
-	/* Threaded processes may not enter a different user namespace */
-	if (atomic_read(&current->mm->mm_users) > 1)
+	/* Tasks that share a thread group must share a user namespace */
+	if (!thread_group_empty(current))
 		return -EINVAL;
 
 	if (current->fs->users != 1)
diff --git a/mm/mmap.c b/mm/mmap.c
index aa632ade2be7..f126923ce683 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1268,7 +1268,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	 *  mounted, in which case we dont add PROT_EXEC.)
 	 */
 	if ((prot & PROT_READ) && (current->personality & READ_IMPLIES_EXEC))
-		if (!(file && (file->f_path.mnt->mnt_flags & MNT_NOEXEC)))
+		if (!(file && path_noexec(&file->f_path)))
 			prot |= PROT_EXEC;
 
 	if (!(flags & MAP_FIXED))
@@ -1337,7 +1337,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		case MAP_PRIVATE:
 			if (!(file->f_mode & FMODE_READ))
 				return -EACCES;
-			if (file->f_path.mnt->mnt_flags & MNT_NOEXEC) {
+			if (path_noexec(&file->f_path)) {
 				if (vm_flags & VM_EXEC)
 					return -EPERM;
 				vm_flags &= ~VM_MAYEXEC;
diff --git a/mm/nommu.c b/mm/nommu.c
index 58ea3643b9e9..ce17abf087ff 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1035,7 +1035,7 @@ static int validate_mmap_request(struct file *file,
 
 		/* handle executable mappings and implied executable
 		 * mappings */
-		if (file->f_path.mnt->mnt_flags & MNT_NOEXEC) {
+		if (path_noexec(&file->f_path)) {
 			if (prot & PROT_EXEC)
 				return -EPERM;
 		} else if ((prot & PROT_READ) && !(prot & PROT_EXEC)) {
diff --git a/security/security.c b/security/security.c
index 595fffab48b0..062f3c997fdc 100644
--- a/security/security.c
+++ b/security/security.c
@@ -776,7 +776,7 @@ static inline unsigned long mmap_prot(struct file *file, unsigned long prot)
 	 * ditto if it's not on noexec mount, except that on !MMU we need
 	 * NOMMU_MAP_EXEC (== VM_MAYEXEC) in this case
 	 */
-	if (!(file->f_path.mnt->mnt_flags & MNT_NOEXEC)) {
+	if (!path_noexec(&file->f_path)) {
 #ifndef CONFIG_MMU
 		if (file->f_op->mmap_capabilities) {
 			unsigned caps = file->f_op->mmap_capabilities(file);
