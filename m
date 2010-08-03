From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 06/16][cr][v3]: Checkpoint file-locks
Date: Tue,  3 Aug 2010 16:11:27 -0700
Message-ID: <1280877097-12377-7-git-send-email-sukadev__20641.8956550353$1280877395$gmane$org@linux.vnet.ibm.com>
References: <1280877097-12377-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1280877097-12377-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

While checkpointing each file-descriptor, find all the locks on the
file and save information about the lock in the checkpoint-image.
A follow-on patch will use this informaiton to restore the file-locks.

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
 fs/checkpoint.c                |  100 ++++++++++++++++++++++++++++++++++-----
 include/linux/checkpoint_hdr.h |   18 +++++++
 2 files changed, 105 insertions(+), 13 deletions(-)

diff --git a/fs/checkpoint.c b/fs/checkpoint.c
index b5486c1..57b6944 100644
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
@@ -256,8 +267,78 @@ static int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
 	return ret;
 }
 
+static int checkpoint_one_file_lock(struct ckpt_ctx *ctx, struct file *file,
+		struct file_lock *lock)
+{
+	int rc;
+	struct ckpt_hdr_file_lock *h;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_LOCK);
+	if (!h)
+		return -ENOMEM;
+
+	if (lock) {
+		h->fl_start = lock->fl_start;
+		h->fl_end = lock->fl_end;
+		h->fl_type = lock->fl_type;
+		h->fl_flags = lock->fl_flags;
+	} else {
+		/* Checkpoint a dummy lock as a marker */
+		CKPT_HDR_SET_MARKER_FILE_LOCK(h);
+	}
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
+	int rc;
+	struct inode *inode;
+	struct file_lock **lockpp;
+	struct file_lock *lockp;
+
+	lock_flocks();
+	inode = file->f_path.dentry->d_inode;
+	for_each_lock(inode, lockpp) {
+		lockp = *lockpp;
+		ckpt_debug("Lock [%lld, %lld, %d, 0x%x]\n", lockp->fl_start,
+				lockp->fl_end, lockp->fl_type, lockp->fl_flags);
+
+		if (lockp->fl_owner != files)
+			continue;
+
+		rc = -EBADF;
+		if (IS_POSIX(lockp))
+			rc = checkpoint_one_file_lock(ctx, file, lockp);
+
+		if (rc < 0) {
+			ckpt_err(ctx,  rc, "%(T), checkpoint of lock "
+					"[%lld, %lld, %d, 0x%x] failed\n",
+					lockp->fl_start, lockp->fl_end,
+					lockp->fl_type, lockp->fl_flags);
+			goto out;
+		}
+	}
+
+	/*
+	 * At the end of file-locks for this file, checkpoint a marker.
+	 */
+	rc = checkpoint_one_file_lock(ctx, file, NULL);
+	if (rc < 0)
+		ckpt_err(ctx,  rc, "%(T), checkpoint marker-lock failed\n");
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
@@ -288,18 +369,6 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
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
@@ -323,6 +392,11 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
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
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 0381019..ad08c8e 100644
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
@@ -586,6 +588,22 @@ struct ckpt_hdr_file_generic {
 	struct ckpt_hdr_file common;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_file_lock {
+       struct ckpt_hdr h;
+       __s64 fl_start;
+       __s64 fl_end;
+       __u8 fl_type;
+       __u8 fl_flags;
+};
+
+#define CKPT_HDR_SET_MARKER_FILE_LOCK(h) {		\
+		h->fl_flags = FL_POSIX;		\
+		h->fl_start = (loff_t) -1;	\
+}
+
+#define CKPT_HDR_IS_MARKER_FILE_LOCK(h)		\
+		((h->fl_flags == FL_POSIX) && (h->fl_start == (loff_t) -1))
+
 struct ckpt_hdr_file_pipe {
 	struct ckpt_hdr_file common;
 	__s32 pipe_objref;
-- 
1.6.0.4
