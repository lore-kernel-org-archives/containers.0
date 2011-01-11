From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 2/2] c/r: add checkpoint support for file-locks
Date: Mon, 10 Jan 2011 20:37:05 -0500
Message-ID: <1294709825-23357-3-git-send-email-orenl@cs.columbia.edu>
References: <1288333001-28838-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1288333001-28838-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch adds suppprt for POSIX file locks only. Support for flock
file locks, file-owner, and fileleases will be addresses later.

While checkpointing each file-descriptor, find all the locks on the
file and save information about the lock in the checkpoint-image.
During restart of the application, read the saved file-locks from the
checkpoint image and for each POSIX lock, call flock_set() to set the
lock on the file.

As pointed out by Matt Helsley, no special handling is necessary for a
process P2 in the checkpointed container that is blocked on a lock, L1
held by another process P1. Processes in the restarted container begin
execution only after all processes have restored. If the blocked process
P2 is restored first, it will prepare to return an -ERESTARTSYS from the
fcntl() system call, but wait for P1 to be restored. When P1 is restored,
it will re-acquire the lock L1 before P1 and P2 begin actual execution.
This ensures that even if P2 is scheduled to run before P1, P2 will go
back to waiting for the lock L1.

Based on patches originally by Sukadev Bhattiprolu.

Changelog[v23-rc1]:
  - Major rework and clean up the code
  - Merge 23/64 bit code in a simpler way
  - Merge locks c/r documenation into this patch
  - Move code to fs/locks.c where it belongs
  - Do not hold lock_flocks() while writing data out
Changelog[v5]:
  - Combine checkpoint and restart patches for easier review
Changelog[v4]:
  - For consistency with other such objects, replace the "marker lock"
    an explicit count of file-locks for each file
Changelog[v3]:
  - Add a missing (loff_t) type cast and use a macro to set the
     marker/dummy file lock
Changelog[v2]:
  - [Matt Helsley]: Use fixed sizes (__s64) instead of 'loff_t' in
    'struct ckpt_hdr_file_lock'.
  - [Matt Helsley, Serge Hallyn]: Highlight new use of BKL (using
    lock_flocks() macros as suggested by Serge).
  - [Matt Helsley]: Reorg code a bit to simplify error handling.
  - [Matt Helsley]: Reorg code to initialize marker-lock (Pass a NULL
    lock to checkpoint_one_lock() to indicate marker).

Cc: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 Documentation/checkpoint/file-system.txt |   59 +++++++
 fs/checkpoint.c                          |   22 +--
 fs/locks.c                               |  268 ++++++++++++++++++++++++++++++
 include/linux/checkpoint_hdr.h           |   14 ++
 include/linux/fs.h                       |    5 +
 5 files changed, 355 insertions(+), 13 deletions(-)
 create mode 100644 Documentation/checkpoint/file-system.txt

diff --git a/Documentation/checkpoint/file-system.txt b/Documentation/checkpoint/file-system.txt
new file mode 100644
index 0000000..a2d4c18
--- /dev/null
+++ b/Documentation/checkpoint/file-system.txt
@@ -0,0 +1,59 @@
+
+Filesystem consistency across C/R
+=================================
+
+To checkpoint/restart a process that is using any filesystem resource, the
+kernel assumes that the file system state at the time of restart is consistent
+with its state at the time of checkpoint. In general, this consistency can be
+achieved by:
+
+	a. running the application inside a container (to ensure no process
+	   outside the container modifies the filesystem/IPC or other states)
+
+	b. freezing the application before checkpoint
+	c. taking a snapshot of the file system while application is frozen
+	d. checkpointing the application while it is frozen
+
+	e. restoring the file system state to its snapshot
+	f. restart the application inside a container
+
+i.e the kernel assumes that file system state is consistent but it does/can
+NOT verify that it is. The administrator must provide this consistency taking
+into account the file system type including whether it is local or remote,
+and the tools available in the file system (snapshot tools in btrfs or rsync
+etc).
+
+For distributed applications operating on distributed filesystems, it is
+expected that an external mechanism will coordinate the freeze/checkpoint/
+snapshot/restart across the nodes. IOW, the current semantics in the kernel
+provide for C/R on a single node.
+
+
+Checkpoint/restart of file-locks
+================================
+
+To checkpoint file-locks in an application, we start with each file-descriptor
+and count the number of file-locks on that file-descriptor. We save this count
+in the checkpoint image, and then information about each file-lock on the
+file-descriptor.
+
+When restarting the application from the checkpoint, we read the file-lock
+count for each file-descriptor and then read the information about each
+file-lock. For each file-lock, we call flock_set() to set a new file-lock.
+
+No special handling is necessary for a process P2 in the checkpointed container
+that is blocked on a file-lock, L1 held by another process P1. Processes in the
+restarted container begin execution only after all processes have restored.
+If the blocked process P2 is restored first, it will prepare to return an
+-ERESTARTSYS from the fcntl() system call, but wait for P1 to be restored.
+When P1 is restored, it will re-acquire the file-lock L1 before P1 and P2 begin
+actual execution.
+
+This ensures that even if P2 is scheduled to run before P1, P2 will go
+back to waiting for the file-lock L1.
+
+STATUS:
+[done] POSIX file locks
+[todo] FLOCK file locks
+[todo] file leases
+[todo] file ownership
diff --git a/fs/checkpoint.c b/fs/checkpoint.c
index fd539c5..02bbd61 100644
--- a/fs/checkpoint.c
+++ b/fs/checkpoint.c
@@ -281,18 +281,6 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
 	}
 	rcu_read_unlock();
 
-	ret = find_locks_with_owner(file, files);
-	/*
-	 * find_locks_with_owner() returns an error when there
-	 * are no locks found, so we *want* it to return an error
-	 * code.  Its success means we have to fail the checkpoint.
-	 */
-	if (!ret) {
-		ret = -EBADF;
-		ckpt_err(ctx, ret, "%(T)fd %d has file lock or lease\n", fd);
-		goto out;
-	}
-
 	/* sanity check (although this shouldn't happen) */
 	ret = -EBADF;
 	if (!file) {
@@ -327,6 +315,10 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
 	h->fd_close_on_exec = coe;
 
 	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	ret = checkpoint_file_locks(ctx, files, file);
 out:
 	ckpt_hdr_put(ctx, h);
 	if (file)
@@ -838,8 +830,12 @@ static int restore_file_desc(struct ckpt_ctx *ctx)
 	}
 
 	set_close_on_exec(h->fd_descriptor, h->fd_close_on_exec);
-	ret = 0;
+
+	ret = restore_file_locks(ctx, file, h->fd_descriptor);
  out:
+	if (ret < 0)
+		ckpt_err(ctx, ret, "Failed fd %d\n", h->fd_descriptor);
+
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
diff --git a/fs/locks.c b/fs/locks.c
index c3fc56d..f4373f8 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -126,6 +126,7 @@
 #include <linux/time.h>
 #include <linux/rcupdate.h>
 #include <linux/pid_namespace.h>
+#include <linux/checkpoint.h>
 
 #include <asm/uaccess.h>
 
@@ -2388,6 +2389,273 @@ int lock_may_write(struct inode *inode, loff_t start, unsigned long len)
 
 EXPORT_SYMBOL(lock_may_write);
 
+#ifdef CONFIG_CHECKPOINT
+static int checkpoint_count_locks(struct ckpt_ctx *ctx,
+				  struct files_struct *files,
+				  struct file *file)
+{
+	struct inode *inode;
+	struct file_lock **lockpp;
+	struct file_lock *lockp;
+	int count = 0;
+
+	inode = file->f_path.dentry->d_inode;
+
+	lock_flocks();
+	for_each_lock(inode, lockpp) {
+		lockp = *lockpp;
+		if (lockp->fl_owner != files)
+			continue;
+		ckpt_debug("Lock [%lld, %lld, %d, 0x%x]\n", lockp->fl_start,
+				lockp->fl_end, lockp->fl_type, lockp->fl_flags);
+		if (lockp->fl_owner != files)
+			continue;
+		if (!IS_POSIX(lockp)) {
+			ckpt_err(ctx, -EBADF, "%(T), checkpoint of lock "
+				 "[%lld, %lld, %d, 0x%x] failed\n",
+				 lockp->fl_start, lockp->fl_end,
+				 lockp->fl_type, lockp->fl_flags);
+			count = -EBADF;
+			break;
+		}
+		count++;
+	}
+	unlock_flocks();
+	return count;
+}
+
+#define CKPT_FLOCK_CHUNK  (8096 / (int) sizeof(struct ckpt_file_lock))
+
+static int checkpoint_file_locks_chunk(struct ckpt_ctx *ctx,
+				       struct files_struct *files,
+				       struct file *file,
+				       struct file_lock **last,
+				       struct ckpt_file_lock *hh)
+{
+	struct inode *inode;
+	struct file_lock **lockpp;
+	struct file_lock *lockp;
+	int count = 0;
+	int found = 0;
+
+	inode = file->f_path.dentry->d_inode;
+
+	if (*last == NULL)  /* start from the beginning */
+		found = 1;
+
+	lock_flocks();
+
+	for_each_lock(inode, lockpp) {
+		lockp = *lockpp;
+		if (!found) {  /* start where we previous pass left off */
+			if (lockp == *last)
+				found = 1;
+			continue;
+		}
+		if (lockp->fl_owner != files)
+			continue;
+		if (!IS_POSIX(lockp)) {  /* something must have changed */
+			count = -EBUSY;
+			break;
+		}
+
+		hh->fl_start = lockp->fl_start;
+		hh->fl_end = lockp->fl_end;
+		hh->fl_type = lockp->fl_type;
+		hh->fl_flags = lockp->fl_flags;
+		hh++;
+
+		*last = lockp;
+
+		if (++count == CKPT_FLOCK_CHUNK)
+			break;
+	}
+
+	unlock_flocks();
+
+	return count;
+}
+
+int checkpoint_file_locks(struct ckpt_ctx *ctx, struct files_struct *files,
+			  struct file *file)
+{
+	struct ckpt_hdr_file_locks *h;
+	struct ckpt_file_lock *hh;
+	struct file_lock *last = NULL;
+	int nr_locks, len;
+	int ret;
+
+	nr_locks = checkpoint_count_locks(ctx, files, file);
+	if (nr_locks < 0)
+		return nr_locks;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_LOCKS);
+	if (!h)
+		return -ENOMEM;
+	h->nr_locks = nr_locks;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	if (ret || !nr_locks)
+		return ret;
+
+	len = nr_locks * sizeof(*hh) + sizeof(*h);
+	ret = ckpt_write_obj_type(ctx, NULL, len, CKPT_HDR_BUFFER);
+	if (ret < 0)
+		return ret;
+
+	hh = kzalloc(sizeof(*hh) * CKPT_FLOCK_CHUNK, GFP_KERNEL);
+	if (!hh)
+		return -ENOMEM;
+
+	while (nr_locks > 0) {
+		ret = checkpoint_file_locks_chunk(ctx, files, file, &last, hh);
+		if (ret <= 0)   /* zero means no more locks */
+			break;
+		nr_locks -= ret;
+		ret = ckpt_kwrite(ctx, hh, ret * sizeof(*hh));
+		if (ret < 0)
+			break;
+	}
+
+	kfree(hh);
+
+	if (nr_locks != 0)
+		ret = -EBUSY;
+	if (ret)
+		ckpt_err(ctx, ret, "Checkpointing file locks\n");
+
+	return ret;
+}
+
+/*
+ * NOTE: For BITS_PER_LONG == 32, always use 'struct flock64' to
+ *   restore, even if the original lock was 'struct flock'. Anyway,
+ *   we first convert both to a posix_file_lock before processing.
+ *
+ * E.g., NFS for instance uses IS_SETLK() instead of cmd==F_SETLK.
+ *
+ * TODO: do other fs implement F_SETLK but not F_SETLK64 ? if so,
+ * then restore_one_lock() will fail :(
+ */
+static int restore_one_lock(struct ckpt_ctx *ctx, struct file *file,
+			    int fd, struct ckpt_file_lock *h)
+{
+#if BITS_PER_LONG == 32
+	struct flock64 fl;
+#else
+	struct flock fl;
+#endif
+	int ret;
+
+	/* TODO: sanitize the remaining possible flags */
+	if ((h->fl_type & (FL_POSIX | FL_FLOCK | FL_LEASE)) != FL_POSIX)
+		return -EINVAL;
+
+	/* TODO: we don't expect leases, nor F_INPROGRESS */
+	switch(h->fl_type) {
+	case F_RDLCK:
+	case F_WRLCK:
+	case F_UNLCK:
+		break;
+	default:
+		ckpt_err(ctx, -EINVAL, "Bad posix lock 0x%x\n", h->fl_type);
+		return -EINVAL;
+	}
+
+	memset(&fl, 0, sizeof(fl));
+	fl.l_type = h->fl_type;
+	fl.l_start = h->fl_start;
+	if (h->fl_end != OFFSET_MAX)
+		fl.l_len =  h->fl_end - h->fl_start + 1;
+	fl.l_whence = SEEK_SET;
+
+	/* TODO: init ->l_sysid, l_pid fields */
+
+	ckpt_debug("posix lock [%lld, %lld, %d]\n",
+		   fl.l_start, fl.l_len, fl.l_type);
+
+	/*
+	 * Use F_SETLK because we should not have to wait for the
+	 * lock. If another process holds the lock, it indicates that
+	 * filesystem-state is not consistent with what it was at
+	 * checkpoint. In which case we better fail.
+	 */
+#if BITS_PER_LONG == 32
+	ret = do_fcntl_setlk64(fd, file, F_SETLK64, &fl);
+#else
+	ret = do_fcntl_setlk(fd, file, F_SETLK64, &fl);
+#endif
+	if (ret < 0)
+		ckpt_err(ctx, ret, "Failed posix lock %d\n", (int)h->fl_type);
+
+	return ret;
+}
+
+static int restore_file_locks_chunk(struct ckpt_ctx *ctx, struct file *file,
+				    int fd, struct ckpt_file_lock *hh, int nr)
+{
+	int i, ret;
+
+	ret = ckpt_kread(ctx, hh, nr * sizeof(*hh));
+	if (ret < 0)
+		return ret;
+
+	for (i = 0; i < nr; i++) {
+		if (!(hh[i].fl_flags & FL_POSIX))
+			return -EINVAL;
+
+		ret = restore_one_lock(ctx, file, fd, &hh[i]);
+		if (ret < 0)
+			return ret;
+	}
+
+	return 0;
+}
+
+int restore_file_locks(struct ckpt_ctx *ctx, struct file *file, int fd)
+{
+	struct ckpt_hdr_file_locks *h;
+	struct ckpt_file_lock *hh;
+	int nr_locks, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FILE_LOCKS);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	nr_locks = h->nr_locks;
+	ckpt_hdr_put(ctx, h);
+
+	if (!nr_locks)
+		return 0;
+
+	ret = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_BUFFER);
+	if (ret < 0)
+		return ret;
+	/* make sure the size is what we expect */
+	if (nr_locks != (ret / sizeof(*hh)))
+		return -EINVAL;
+
+	hh = kzalloc(sizeof(*hh) * CKPT_FLOCK_CHUNK, GFP_KERNEL);
+	if (!hh)
+		return -ENOMEM;
+
+	while (nr_locks > 0) {
+		int n = min(nr_locks, CKPT_FLOCK_CHUNK);
+
+		ret = restore_file_locks_chunk(ctx, file, fd, hh, n);
+		if (ret < 0)
+			nr_locks = ret;
+
+		nr_locks -= n;
+	}
+
+	kfree(hh);
+
+	return nr_locks;
+}
+#endif /* CONFIG_CHECKPOINT */
+
 static int __init filelock_init(void)
 {
 	filelock_cache = kmem_cache_create("file_lock_cache",
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b12d586..f7e233d 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -160,6 +160,8 @@ enum {
 #define CKPT_HDR_TTY_LDISC CKPT_HDR_TTY_LDISC
 	CKPT_HDR_EPOLL_ITEMS,  /* must be after file-table */
 #define CKPT_HDR_EPOLL_ITEMS CKPT_HDR_EPOLL_ITEMS
+	CKPT_HDR_FILE_LOCKS,
+#define CKPT_HDR_FILE_LOCKS CKPT_HDR_FILE_LOCKS
 
 	CKPT_HDR_MM = 401,
 #define CKPT_HDR_MM CKPT_HDR_MM
@@ -620,6 +622,18 @@ struct ckpt_hdr_file_eventfd {
 	__u32 flags;
 } __attribute__((aligned(8)));
 
+struct ckpt_file_lock {
+	__s64 fl_start;
+	__s64 fl_end;
+	__u8 fl_type;
+	__u8 fl_flags;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_file_locks {
+	struct ckpt_hdr h;
+	__u32 nr_locks;
+} __attribute__((aligned(8)));
+
 /* socket */
 struct ckpt_hdr_socket {
 	struct ckpt_hdr h;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7f38be1..f368e30 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2394,6 +2394,11 @@ void inode_set_bytes(struct inode *inode, loff_t bytes);
 
 #ifdef CONFIG_CHECKPOINT
 extern int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+extern int checkpoint_file_locks(struct ckpt_ctx *ctx,
+				 struct files_struct *files,
+				 struct file *file);
+extern int restore_file_locks(struct ckpt_ctx *ctx, struct file *file, int fd);
+
 #endif
 
 extern int vfs_readdir(struct file *, filldir_t, void *);
-- 
1.7.1
