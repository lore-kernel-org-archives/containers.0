From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 3/3][cr][v2]: fileleases: C/R of an in-progress lease.
Date: Tue, 25 May 2010 18:07:43 -0700
Message-ID: <1274836063-13271-4-git-send-email-sukadev__16395.7315417521$1274835830$gmane$org@linux.vnet.ibm.com>
References: <1274836063-13271-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1274836063-13271-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, matthew-Ztpu424NOJ8@public.gmane.org
List-Id: containers.vger.kernel.org

If process P1 has a F_WRLCK lease on file F1 and process P2 opens the
file, P2's open() blocks for lease_break_time (45 seconds) and P1 gets
a SIGIO to cleanup it lease in preparation for P2's open.  If the two
processes are checkpointed/restarted in this window, we should address
following two issues:

	- P1 should get a SIGIO only once for the lease (i.e if P1 got the
	  SIGIO before checkpoint, it should not get the SIGIO after restart).

	- If R seconds remain in the lease, P2's open should be blocked for
	  at least the R seconds, so P1 has the time to clean up its lease.
	  The previous patch gives P1 the entire lease_break_time but that
	  can leave P2 stalled for 2*lease_break_time.

To address first, we add a field ->fl_break_notified to "remember" if we
notified the lease-holder already. We save this field in the checkpoint
image and when restarting, we notify the lease-holder only if this field
is not set.

To address the second issue, we also checkpoint the ->fl_break_time for
an in-progress lease. When restarting the process, we ensure that the
lease-holder sleeps only for the remaining-lease rather than the entire
lease.

These two fixes sound like an approximation (see comments in do_setlease()
and __break_lease() below) and are also a bit kludgy (hence a separate patch
for now).

Appreciate comments on how we can do this better. Specifically:

	- do we even need to try and address the second issue above or
	  just let P1 have the entire lease_break_time again ?

	- theoretically, the R seconds should start counting after *all*
	  processes in the application-process tree have been restarted,
	  since P1 waits inside the kernel for a portion of the remaining
	  lease - should we then add a delta to R ?

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/checkpoint.c                |   13 ++++++---
 fs/locks.c                     |   56 ++++++++++++++++++++++++++++++++++-----
 include/linux/checkpoint_hdr.h |    1 +
 include/linux/fs.h             |    4 ++-
 4 files changed, 61 insertions(+), 13 deletions(-)

diff --git a/fs/checkpoint.c b/fs/checkpoint.c
index 2baeb32..f2adb38 100644
--- a/fs/checkpoint.c
+++ b/fs/checkpoint.c
@@ -284,9 +284,13 @@ static int checkpoint_one_file_lock(struct ckpt_ctx *ctx, struct file *file,
 		h->fl_type = lock->fl_type;
 		h->fl_type_prev = lock->fl_type_prev;
 		h->fl_flags = lock->fl_flags;
-		if (h->fl_type & F_INPROGRESS && 
-					(lock->fl_break_time > jiffies))
-			h->fl_rem_lease = (lock->fl_break_time - jiffies) / HZ;
+		if (IS_LEASE(lock)) {
+			unsigned long bt = lock->fl_break_time;
+
+			h->fl_break_notified = lock->fl_break_notified;
+			if ((h->fl_type & F_INPROGRESS) && (bt > jiffies))
+				h->fl_rem_lease = (bt - jiffies) / HZ;
+		}
 
 	} else {
 		/* Checkpoint a dummy lock as a marker */
@@ -1084,7 +1088,8 @@ static int restore_file_locks(struct ckpt_ctx *ctx, struct file *file, int fd)
 			type = h->fl_type;
 			if (h->fl_type & F_INPROGRESS)
 				type = h->fl_type_prev;
-			ret = do_setlease(fd, file, type, h->fl_rem_lease);
+			ret = do_setlease(fd, file, type, h->fl_rem_lease,
+					h->fl_break_notified);
 			if (ret)
 				ckpt_err(ctx, ret, "do_setlease(): %d\n", type);
 		}
diff --git a/fs/locks.c b/fs/locks.c
index 7a80278..c6ef829 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -185,6 +185,7 @@ void locks_init_lock(struct file_lock *fl)
 	fl->fl_flags = 0;
 	fl->fl_type = 0;
 	fl->fl_type_prev = 0;
+	fl->fl_break_notified = 0;
 	fl->fl_break_time = 0UL;
 	fl->fl_start = fl->fl_end = 0;
 	fl->fl_ops = NULL;
@@ -229,6 +230,8 @@ void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
 	new->fl_flags = fl->fl_flags;
 	new->fl_type = fl->fl_type;
 	new->fl_start = fl->fl_start;
+	new->fl_break_time = fl->fl_break_time;
+	new->fl_break_notified = fl->fl_break_notified;
 	new->fl_end = fl->fl_end;
 	new->fl_ops = NULL;
 	new->fl_lmops = NULL;
@@ -460,6 +463,8 @@ static int lease_init(struct file *filp, int type, struct file_lock *fl)
 	fl->fl_end = OFFSET_MAX;
 	fl->fl_ops = NULL;
 	fl->fl_lmops = &lease_manager_ops;
+	fl->fl_break_time = 0UL;
+	fl->fl_break_notified = 0;
 	return 0;
 }
 
@@ -1139,6 +1144,7 @@ int lease_modify(struct file_lock **before, int arg)
 	struct file_lock *fl = *before;
 	int error = assign_type(fl, arg);
 
+	fl->fl_break_notified = 0;
 	if (error)
 		return error;
 	locks_wake_up_blocks(fl);
@@ -1254,16 +1260,25 @@ int __break_lease(struct inode *inode, unsigned int mode)
 			if (!fl->fl_type_prev)
 				fl->fl_type_prev = fl->fl_type;
 			fl->fl_type = future;
-			fl->fl_break_time = break_time;
 
 			/*
-			 * TODO: ->fl_break() sends the SIGIO to lease-holder.
-			 *       If lease-holder was checkpointed/restarted and
-			 *       this is a restarted lease, we should not
-			 *       re-send the SIGIO ?
+			 * CHECK:
+			 *
+			 * Similarly, if ->fl_break_time or ->fl_break_notified
+			 * are set, we were in the middle of a lease-break
+			 * when we were checkpointed. So we don't need to
+			 * notify of the lease holder again or wait for the
+			 * entire lease_break_time. Note that this time
+			 * could be more than lease_break_time since we use
+			 * the value that was checkpointed.
 			 */
+			if (!fl->fl_break_time)
+				fl->fl_break_time = break_time;
+
 			/* lease must have lmops break callback */
-			fl->fl_lmops->fl_break(fl);
+			if (!fl->fl_break_notified)
+				fl->fl_lmops->fl_break(fl);
+			fl->fl_break_notified = 1;
 		}
 	}
 
@@ -1511,7 +1526,8 @@ int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
 }
 EXPORT_SYMBOL_GPL(vfs_setlease);
 
-int do_setlease(unsigned int fd, struct file *filp, long arg, int rem_lease)
+int do_setlease(unsigned int fd, struct file *filp, long arg, int rem_lease,
+		int notified)
 {
 	struct file_lock fl, *flp = &fl;
 	struct inode *inode = filp->f_path.dentry->d_inode;
@@ -1521,6 +1537,30 @@ int do_setlease(unsigned int fd, struct file *filp, long arg, int rem_lease)
 	error = lease_init(filp, arg, &fl);
 	if (error)
 		return error;
+	fl.fl_break_notified = notified;
+
+	/*
+	 * Checkpoint/restart:
+	 *
+	 * If this lease is from a checkpoint, use the 'remaining-lease' that
+	 * was checkpointed. 
+	 *
+	 * NOTE: There are couple of observations:
+	 *
+	 * 	- We look at jiffies now and decide the absolute end time for
+	 * 	  the lease, but the lease-holder is still frozen and will not
+	 * 	  actually have the entire time to clean up. When the lease-
+	 * 	  holder gets to run, depends on how many other processes are
+	 * 	  in the checkpointed application's process-tree.
+	 *
+	 * 	- We assume that the lease-breaker was also checkpointed and
+	 * 	  set up the lease/file_lock object in anticipation of the 
+	 * 	  lease-breaker retrying their open(). If the lease-breaker
+	 * 	  was not checkpointed, the lease-holder continues to have the
+	 * 	  lease until another lease-breaker comes along.
+	 */
+	if (rem_lease)
+		fl.fl_break_time = jiffies + rem_lease * HZ;
 
 	lock_kernel();
 
@@ -1556,7 +1596,7 @@ out_unlock:
  */
 int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 {
-	return do_setlease(fd, filp, arg, 0);
+	return do_setlease(fd, filp, arg, 0, 0);
 }
 
 /**
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index ddad73f..c741e6a 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -590,6 +590,7 @@ struct ckpt_hdr_file_lock {
        __u8 fl_type;
        __u8 fl_type_prev;
        __u8 fl_flags;
+       __u8 fl_break_notified;
        unsigned long fl_rem_lease;
 };
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 54b2a7b..74da7bb 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1067,6 +1067,7 @@ struct file_lock {
 	unsigned char fl_flags;
 	unsigned char fl_type;
 	unsigned char fl_type_prev;
+	unsigned char fl_break_notified;
 	unsigned int fl_pid;
 	struct pid *fl_nspid;
 	wait_queue_head_t fl_wait;
@@ -1123,7 +1124,8 @@ extern int flock64_set(unsigned int, struct file *, unsigned int,
 			struct flock64 *);
 #endif
 
-extern int do_setlease(unsigned int fd, struct file *filp, long arg, int rem_lease);
+extern int do_setlease(unsigned int fd, struct file *filp, long arg, 
+			int rem_lease, int notified);
 extern int fcntl_setlease(unsigned int fd, struct file *filp, long arg);
 extern int fcntl_getlease(struct file *filp);
 
-- 
1.6.0.4
