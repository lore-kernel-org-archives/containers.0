From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][cr][PATCH  2/6] Checkpoint file-locks
Date: Tue, 4 May 2010 22:31:09 -0700
Message-ID: <20100505053109.GB20993__39953.8462902003$1273037137$gmane$org@us.ibm.com>
References: <20100505053016.GA20483@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100505053016.GA20483-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From 46f8a088d15eda817f537cbb17574253a3af4e8c Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Thu, 29 Apr 2010 23:43:46 -0700
Subject: [RFC][cr][PATCH  2/6] Checkpoint file-locks

While checkpointing each file-descriptor, find all the locks on the
file and save information about the lock in the checkpoint-image.
A follow-on patch will use this informaiton to restore the file-locks.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/checkpoint.c                |   98 ++++++++++++++++++++++++++++++++++-----
 include/linux/checkpoint_hdr.h |   10 ++++
 2 files changed, 95 insertions(+), 13 deletions(-)

diff --git a/fs/checkpoint.c b/fs/checkpoint.c
index e036a7a..180302e 100644
--- a/fs/checkpoint.c
+++ b/fs/checkpoint.c
@@ -26,6 +26,7 @@
 #include <linux/checkpoint.h>
 #include <linux/eventpoll.h>
 #include <linux/eventfd.h>
+#include <linux/smp_lock.h>
 #include <net/sock.h>
 
 /**************************************************************************
@@ -249,8 +250,86 @@ static int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
 	return ret;
 }
 
+static int checkpoint_one_file_lock(struct ckpt_ctx *ctx, struct file *file,
+		int fd, struct file_lock *lock)
+{
+	int rc;
+	struct ckpt_hdr_file_lock *h;
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
+	ckpt_debug("Lock [%lld, %lld, %d, 0x%x] fd %d, rc %d\n", lock->fl_start,
+			lock->fl_end, lock->fl_type, lock->fl_flags, fd, rc);
+
+	return rc;
+}
+
+int
+checkpoint_file_locks(struct ckpt_ctx *ctx, struct files_struct *files,
+		struct file *file, int fd)
+{
+	int rc;
+	struct inode *inode;
+	struct file_lock **lockpp;
+	struct file_lock *lockp;
+	struct file_lock last_lock;
+
+	lock_kernel();
+	inode = file->f_path.dentry->d_inode;
+	for_each_lock(inode, lockpp) {
+		lockp = *lockpp;
+		ckpt_debug("Found lock [%lld, %lld, %d, 0x%x]\n",
+				lockp->fl_start, lockp->fl_end, 
+				lockp->fl_type, lockp->fl_flags);
+
+		if (lockp->fl_owner != files)
+			continue;
+
+		if (IS_POSIX(lockp)) {
+			rc = checkpoint_one_file_lock(ctx, file, fd, lockp);
+			if (rc < 0) {
+				ckpt_err(ctx,  rc, "%(T)fd %d, checkpoint "
+						"lock failed\n", fd);
+				goto out;
+			}
+		} else {
+			rc = -EBADF;
+			ckpt_err(ctx, rc, "%(T)fd %d has unsupported file "
+					"lock type, flags 0x%x\n", fd,
+					lockp->fl_flags);
+			goto out;
+		}
+	}
+
+	/*
+	 * Checkpoint a dummy file-lock to mark the end of file-locks
+	 * for this fd.
+	 */
+	memset(&last_lock, 0, sizeof(struct file_lock));
+	last_lock.fl_start = -1;
+	last_lock.fl_flags = FL_POSIX;
+	rc = checkpoint_one_file_lock(ctx, file, fd, &last_lock);
+	if (rc < 0)
+		ckpt_err(ctx,  rc, "%(T)fd %d, checkpoint last-lock failed\n",
+				fd);
+out:
+	unlock_kernel();
+	return rc;
+}
+
 /**
- * ckpt_write_file_desc - dump the state of a given file descriptor
+ * checkpoint_file_desc - dump the state of a given file descriptor
  * @ctx: checkpoint context
  * @files: files_struct pointer
  * @fd: file descriptor
@@ -282,18 +361,6 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
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
@@ -328,6 +395,11 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
 	h->fd_close_on_exec = coe;
 
 	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	ret = checkpoint_file_locks(ctx, files, file, fd);
+
 out:
 	ckpt_hdr_put(ctx, h);
 	if (file)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 790214f..d2a0fcd 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -144,6 +144,8 @@ enum {
 #define CKPT_HDR_TTY_LDISC CKPT_HDR_TTY_LDISC
 	CKPT_HDR_EPOLL_ITEMS,  /* must be after file-table */
 #define CKPT_HDR_EPOLL_ITEMS CKPT_HDR_EPOLL_ITEMS
+	CKPT_HDR_FILE_LOCK,
+#define CKPT_HDR_FILE_LOCK CKPT_HDR_FILE_LOCK
 
 	CKPT_HDR_MM = 401,
 #define CKPT_HDR_MM CKPT_HDR_MM
@@ -576,6 +578,14 @@ struct ckpt_hdr_file_generic {
 	struct ckpt_hdr_file common;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_file_lock {
+       struct ckpt_hdr h;
+       loff_t fl_start;
+       loff_t fl_end;
+       __u8 fl_type;
+       __u8 fl_flags;
+};
+
 struct ckpt_hdr_file_pipe {
 	struct ckpt_hdr_file common;
 	__s32 pipe_objref;
-- 
1.6.0.4
