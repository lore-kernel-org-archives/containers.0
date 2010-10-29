From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 4/5][v5][cr]: Checkpoint/restore file-locks
Date: Thu, 28 Oct 2010 23:16:40 -0700
Message-ID: <1288333001-28838-5-git-send-email-sukadev__37916.6966806681$1288332622$gmane$org@linux.vnet.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

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

Changelog[v5]:
	[Oren Laadan]: Combine checkpoint and restart patches into one
	for easier review

Changelog[v4]:
	[Oren Laadan]: For consistency with other such objects, replace
	the "marker lock" checkpoint with a checkpoint of a count of the
	file-locks before the first file-lock of each file.

Changelog[v3]:
	[Oren Laadan] Add a missing (loff_t) type cast and use a macro
		to set the marker/dummy file lock

Changelog[v2]:
	[Matt Helsley]: Use fixed sizes (__s64) instead of 'loff_t' in
		'struct ckpt_hdr_file_lock'.
	[Matt Helsley, Serge Hallyn]: Highlight new use of BKL (using
		lock_flocks() macros as suggested by Serge).
	[Matt Helsley]: Reorg code a bit to simplify error handling.
	[Matt Helsley]: Reorg code to initialize marker-lock (Pass a
		NULL lock to checkpoint_one_lock() to indicate marker).

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/checkpoint.c                |  318 ++++++++++++++++++++++++++++++++++++++--
 include/linux/checkpoint_hdr.h |   17 ++
 2 files changed, 320 insertions(+), 15 deletions(-)

diff --git a/fs/checkpoint.c b/fs/checkpoint.c
index 87d7c6e..898a016 100644
--- a/fs/checkpoint.c
+++ b/fs/checkpoint.c
@@ -26,8 +26,19 @@
 #include <linux/checkpoint.h>
 #include <linux/eventpoll.h>
 #include <linux/eventfd.h>
+#include <linux/smp_lock.h>
 #include <net/sock.h>
 
+/*
+ * TODO: This code uses the BKL for consistency with other uses of
+ * 	 'for_each_lock()'. But since the BKL may be replaced with another
+ * 	 lock in the future, use lock_flocks() macros instead. lock_flocks()
+ * 	 are currently used in BKL-fix sand boxes and when those changes
+ * 	 are merged, the following macros can be removed
+ */
+#define lock_flocks()		lock_kernel()
+#define unlock_flocks()	unlock_kernel()
+
 /**************************************************************************
  * Checkpoint
  */
@@ -249,8 +260,120 @@ static int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
 	return ret;
 }
 
+static int checkpoint_one_file_lock(struct ckpt_ctx *ctx, 
+		struct file_lock *lock)
+{
+	int rc;
+	struct ckpt_hdr_file_lock *h;
+
+	if (!IS_POSIX(lock)) {
+		/* Hmm, we should have caught this while counting locks */
+		return -EBADF;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_LOCK);
+	if (!h)
+		return -ENOMEM;
+
+	h->fl_start = lock->fl_start;
+	h->fl_end = lock->fl_end;
+	h->fl_type = lock->fl_type;
+	h->fl_flags = lock->fl_flags;
+
+	rc = ckpt_write_obj(ctx, &h->h);
+
+	ckpt_hdr_put(ctx, h);
+
+	return rc;
+}
+
+static int checkpoint_file_lock_count(struct ckpt_ctx *ctx, int num_locks)
+{
+	int rc;
+	struct ckpt_hdr_file_lock_count *h;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_LOCK_COUNT);
+	if (!h)
+		return -ENOMEM;
+
+	h->nr_locks = num_locks;
+
+	rc = ckpt_write_obj(ctx, &h->h);
+
+	ckpt_hdr_put(ctx, h);
+
+	return rc;
+}
+
+int
+checkpoint_file_locks(struct ckpt_ctx *ctx, struct files_struct *files,
+		struct file *file)
+{
+	int n;
+	int rc;
+	struct inode *inode;
+	struct file_lock **lockpp;
+	struct file_lock *lockp;
+
+	lock_flocks();
+
+	/*
+	 * First count the number of file-locks on this file
+	 */
+	n = 0;
+	rc = -EBADF;
+	inode = file->f_path.dentry->d_inode;
+	for_each_lock(inode, lockpp) {
+		lockp = *lockpp;
+		if (lockp->fl_owner != files)
+			continue;
+
+		ckpt_debug("Lock [%lld, %lld, %d, 0x%x]\n", lockp->fl_start,
+				lockp->fl_end, lockp->fl_type, lockp->fl_flags);
+
+		if (lockp->fl_owner != files)
+			continue;
+
+		if (IS_POSIX(lockp))
+			n++;
+		else {
+			ckpt_err(ctx,  rc, "%(T), checkpoint of lock "
+					"[%lld, %lld, %d, 0x%x] failed\n",
+					lockp->fl_start, lockp->fl_end,
+					lockp->fl_type, lockp->fl_flags);
+			goto out;
+		}
+	}
+
+	/*
+	 * Checkpoint the count of file-locks
+	 */
+	rc = checkpoint_file_lock_count(ctx, n);
+	if (rc < 0) {
+		ckpt_err(ctx,  rc, "%(T), checkpoint file-lock count failed\n");
+		goto out;
+	}
+
+	/*
+	 * Make a second pass and checkpoint file-locks themselves.
+	 */
+	for_each_lock(inode, lockpp) {
+		lockp = *lockpp;
+		if (lockp->fl_owner != files)
+			continue;
+
+		rc = checkpoint_one_file_lock(ctx, lockp);
+		if (rc < 0)
+			goto out;
+	}
+
+out:
+	unlock_flocks();
+	return rc;
+}
+
 /**
- * ckpt_write_file_desc - dump the state of a given file descriptor
+ * checkpoint_file_desc - dump the state of a given file descriptor
  * @ctx: checkpoint context
  * @files: files_struct pointer
  * @fd: file descriptor
@@ -282,18 +405,6 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
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
@@ -328,6 +439,11 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
 	h->fd_close_on_exec = coe;
 
 	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	ret = checkpoint_file_locks(ctx, files, file);
+
 out:
 	ckpt_hdr_put(ctx, h);
 	if (file)
@@ -792,8 +908,176 @@ static void *restore_file(struct ckpt_ctx *ctx)
 	return (void *)file;
 }
 
+#if BITS_PER_LONG == 32
+
+/*
+ * NOTE: Even if we checkpointed a lock that was set with 'struct flock'
+ * 	 restore the lock using 'struct flock64'. Note that both these lock
+ * 	 types are first converted to a posix_file_lock before processing so
+ * 	 converting to 'struct flock64' is (hopefully) not a problem. 
+ * 	 NFS for instance uses IS_SETLK() instead of cmd == F_SETLK.
+ *
+ * 	 TODO:  Are there filesystems that implement F_SETLK but not F_SETLK64 ?
+ * 	 	If there are, restore_one_posix_lock() will fail.
+ */
+static int
+ckpt_hdr_file_lock_to_flock64(struct ckpt_hdr_file_lock *h, struct flock64 *fl)
+{
+	/*
+	 * We checkpoint the 'raw' fl_type which in case of leases includes
+	 * the F_INPROGRESS flag. But for posix-locks, the fl_type should
+	 * be simple.
+	 */
+	switch(h->fl_type) {
+		case F_RDLCK:
+		case F_WRLCK:
+		case F_UNLCK:
+			break;
+		default:
+			ckpt_debug("Bad posix lock type 0x%x ?\n", h->fl_type);
+			return -EINVAL;
+	}
+
+	memset(fl, 0, sizeof(*fl));
+	fl->l_type = h->fl_type;
+	fl->l_start = h->fl_start;
+	fl->l_len = h->fl_end == OFFSET_MAX ? 0 : h->fl_end - h->fl_start + 1;
+	fl->l_whence = SEEK_SET;
+
+	/* TODO: Init ->l_sysid, l_pid fields */
+	ckpt_debug("Restoring filelock [%lld, %lld, %d]\n", fl->l_start,
+			fl->l_len, fl->l_type);
+
+	return 0;
+}
+
+static int restore_one_posix_lock(struct ckpt_ctx *ctx, struct file *file,
+		int fd, struct ckpt_hdr_file_lock *h)
+{
+	struct flock64 fl;
+	int ret;
+
+	ret = ckpt_hdr_file_lock_to_flock64(h, &fl);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "%(T) Unexpected flock\n");
+		return ret;
+	}
+
+	/*
+	 * Use F_SETLK because we should not have to wait for the lock. If
+	 * another process holds the lock, it indicates that filesystem-state
+	 * is not consistent with what it was at checkpoint. In which case we
+	 * better fail.
+	 */
+	ret = flock64_set(fd, file, F_SETLK64, &fl);
+	if (ret)
+		ckpt_err(ctx, ret, "flock64_set(): %d\n", (int)h->fl_type);
+
+	return ret;
+}
+
+#else
+
+static int
+ckpt_hdr_file_lock_to_flock(struct ckpt_hdr_file_lock *h, struct flock *fl)
+{
+	/*
+	 * We checkpoint the 'raw' fl_type which in case of leases includes
+	 * the F_INPROGRESS flag. But for posix-locks, the fl_type should
+	 * be simple.
+	 */
+	switch(h->fl_type) {
+		case F_RDLCK:
+		case F_WRLCK:
+		case F_UNLCK:
+			break;
+		default:
+			ckpt_debug("Bad posix lock type 0x%x ?\n", h->fl_type);
+			return -EINVAL;
+	}
+
+	memset(fl, 0, sizeof(*fl));
+
+	fl->l_type = h->fl_type;
+	fl->l_start = h->fl_start;
+	fl->l_len = fl->fl_end == OFFSET_MAX ? 0 : h->fl_end - h->fl_start + 1;
+	fl->l_whence = SEEK_SET;
+
+	ckpt_debug("Restoring filelock [%lld, %lld, %d]\n", fl->l_start,
+			fl->l_len, fl->l_type);
+
+	/* TODO: Init ->l_sysid, l_pid fields */
+
+	return 0;
+}
+
+static int restore_one_posix_lock(struct ckpt_ctx *ctx, struct file *file,
+		int fd, struct ckpt_hdr_file_lock *h)
+{
+	struct flock fl;
+	int ret;
+
+	ret = ckpt_hdr_file_lock_to_flock(h, &fl);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "%(T) Unexpected flock\n");
+		break;
+	}
+
+	/*
+	 * Use F_SETLK because we should not have to wait for the lock. If
+	 * another process holds the lock, it indicates that filesystem-state
+	 * is not consistent with what it was at checkpoint. In which case we
+	 * better fail.
+	 */
+	ret = flock_set(fd, file, F_SETLK, &fl);
+	if (ret)
+		ckpt_err(ctx, ret, "flock_set(): %d\n", (int)h->fl_type);
+
+	return ret;
+}
+#endif
+
+static int restore_file_locks(struct ckpt_ctx *ctx, struct file *file, int fd)
+{
+	int i, ret;
+	struct ckpt_hdr_file_lock *h;
+	struct ckpt_hdr_file_lock_count *hfc;
+
+	hfc = ckpt_read_obj_type(ctx, sizeof(*hfc), CKPT_HDR_FILE_LOCK_COUNT);
+	if (IS_ERR(hfc))
+		return PTR_ERR(hfc);
+
+	ret = 0;
+	for (i = 0; i < hfc->nr_locks; i++) {
+
+		h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FILE_LOCK);
+		if (IS_ERR(h)) {
+			ret = PTR_ERR(h);
+			goto out;
+		}
+
+		ckpt_debug("Lock [%lld, %lld, %d, 0x%x]\n", h->fl_start,
+				h->fl_end, (int)h->fl_type, h->fl_flags);
+
+		ret = -EBADF;
+		if (h->fl_flags & FL_POSIX)
+			ret = restore_one_posix_lock(ctx, file, fd, h); 
+
+		ckpt_hdr_put(ctx, h);
+
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "%(T)\n");
+			goto out;
+		}
+
+	}
+out:
+	ckpt_hdr_put(ctx, hfc);
+	return ret;
+}
+
 /**
- * ckpt_read_file_desc - restore the state of a given file descriptor
+ * restore_file_desc - restore the state of a given file descriptor
  * @ctx: checkpoint context
  *
  * Restores the state of a file descriptor; looks up the objref (in the
@@ -839,7 +1123,11 @@ static int restore_file_desc(struct ckpt_ctx *ctx)
 	}
 
 	set_close_on_exec(h->fd_descriptor, h->fd_close_on_exec);
-	ret = 0;
+
+	ret = restore_file_locks(ctx, file, h->fd_descriptor);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "Error on fd %d\n", h->fd_descriptor);
+
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 049bb82..7b3267c 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -159,6 +159,10 @@ enum {
 #define CKPT_HDR_TTY_LDISC CKPT_HDR_TTY_LDISC
 	CKPT_HDR_EPOLL_ITEMS,  /* must be after file-table */
 #define CKPT_HDR_EPOLL_ITEMS CKPT_HDR_EPOLL_ITEMS
+	CKPT_HDR_FILE_LOCK_COUNT,
+#define CKPT_HDR_FILE_LOCK_COUNT CKPT_HDR_FILE_LOCK_COUNT
+	CKPT_HDR_FILE_LOCK,
+#define CKPT_HDR_FILE_LOCK CKPT_HDR_FILE_LOCK
 
 	CKPT_HDR_MM = 401,
 #define CKPT_HDR_MM CKPT_HDR_MM
@@ -614,6 +618,19 @@ struct ckpt_hdr_file_generic {
 	struct ckpt_hdr_file common;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_file_lock_count {
+       struct ckpt_hdr h;
+       __u32 nr_locks;
+};
+
+struct ckpt_hdr_file_lock {
+       struct ckpt_hdr h;
+       __s64 fl_start;
+       __s64 fl_end;
+       __u8 fl_type;
+       __u8 fl_flags;
+};
+
 struct ckpt_hdr_file_pipe {
 	struct ckpt_hdr_file common;
 	__s32 pipe_objref;
-- 
1.6.0.4
