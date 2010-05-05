From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][cr][PATCH  4/6] Restore file-locks
Date: Tue, 4 May 2010 22:31:46 -0700
Message-ID: <20100505053146.GD20993__18326.6597138301$1273037181$gmane$org@us.ibm.com>
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


From 58da2b18ee4389fdb1c0602d098ccde2dd3bf194 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Sun, 2 May 2010 23:10:18 -0700
Subject: [RFC][cr][PATCH  4/6] Restore file-locks

Restore POSIX file-locks of an application from its checkpoint image.

Read the saved file-locks from the checkpoint image and for each POSIX
lock, call flock_set() to set the lock on the file.

As pointed out by Matt Helsley, no special handling is necessary for a
process P2 in the checkpointed container that is blocked on a lock, L1
held by another process P1.  Since processes in the restarted container
begin execution only after all processes have restored. If the blocked
process P2 is restored first, first, it will prepare to return an
-ERESTARTSYS from the fcntl() system call, but wait for P1 to be
restored. When P1 is restored, it will re-acquire the lock L1 before P1
and P2 begin actual execution. This ensures that even if P2 is scheduled
to run before P1, P2 will go back to waiting for the lock L1.

TODO:
	Checkpoint/restart 64-bit file-locks (set by fctnl_getlk64() and
	fcntl_setlk64()).

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/checkpoint.c |   97 ++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 89 insertions(+), 8 deletions(-)

diff --git a/fs/checkpoint.c b/fs/checkpoint.c
index 180302e..625ccb9 100644
--- a/fs/checkpoint.c
+++ b/fs/checkpoint.c
@@ -269,9 +269,6 @@ static int checkpoint_one_file_lock(struct ckpt_ctx *ctx, struct file *file,
 
 	ckpt_hdr_put(ctx, h);
 
-	ckpt_debug("Lock [%lld, %lld, %d, 0x%x] fd %d, rc %d\n", lock->fl_start,
-			lock->fl_end, lock->fl_type, lock->fl_flags, fd, rc);
-
 	return rc;
 }
 
@@ -289,9 +286,9 @@ checkpoint_file_locks(struct ckpt_ctx *ctx, struct files_struct *files,
 	inode = file->f_path.dentry->d_inode;
 	for_each_lock(inode, lockpp) {
 		lockp = *lockpp;
-		ckpt_debug("Found lock [%lld, %lld, %d, 0x%x]\n",
-				lockp->fl_start, lockp->fl_end, 
-				lockp->fl_type, lockp->fl_flags);
+		ckpt_debug("Lock [%lld, %lld, %d, 0x%x], fd %d\n",
+				lockp->fl_start, lockp->fl_end,
+				lockp->fl_type, lockp->fl_flags, fd);
 
 		if (lockp->fl_owner != files)
 			continue;
@@ -831,6 +828,86 @@ static struct restore_file_ops restore_file_ops[] = {
 	},
 };
 
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
+	fl->l_type = h->fl_type;
+	fl->l_start = h->fl_start;
+	fl->l_len = h->fl_end - h->fl_start;
+	fl->l_whence = SEEK_SET;
+
+	/* TODO: Init ->l_sysid, l_pid fields */
+
+	return 0;
+}
+
+static int restore_file_locks(struct ckpt_ctx *ctx, struct file *file, int fd)
+{
+	int ret;
+	struct flock fl;
+	struct ckpt_hdr_file_lock *h;
+
+	ret = 0;
+	while (!ret) {
+
+		h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FILE_LOCK);
+		if (IS_ERR(h))
+			return PTR_ERR(h);
+
+		ckpt_debug("Lock [%lld, %lld, %d, 0x%x]\n", h->fl_start,
+				h->fl_end, (int)h->fl_type, h->fl_flags);
+
+		/*
+		 * If we found a dummy-lock, then the fd has no more
+		 * file-locks
+		 */
+		if ((h->fl_flags & FL_POSIX) && (h->fl_start == (loff_t)-1)) {
+			ckpt_debug("Found last lock for fd\n");
+			break;
+		}
+
+		if (h->fl_flags & FL_POSIX) {
+			ret = ckpt_hdr_file_lock_to_flock(h, &fl);
+			if (ret < 0) {
+				ckpt_err(ctx, ret, "%(T) Unexpected flock\n");
+				break;
+			}
+			/*
+			 * Use F_SETLK because we should not have to wait for
+			 * the lock. If another process holds the lock, it
+			 * indicates that filesystem-state is not consistent
+			 * with what it was at checkpoint. In which case we
+			 * better fail.
+			 */
+			ret = flock_set(fd, file, F_SETLK, &fl);
+			if (ret)
+				ckpt_err(ctx, ret, "flock_set(): %d\n",
+						(int)h->fl_type);
+		} else {
+			ret = EINVAL;
+			ckpt_err(ctx, ret, "%(T) Unexpected fl_flags 0x%x\n",
+					h->fl_flags);
+		}
+	}
+	return ret;
+}
+
 static void *restore_file(struct ckpt_ctx *ctx)
 {
 	struct restore_file_ops *ops;
@@ -862,7 +939,7 @@ static void *restore_file(struct ckpt_ctx *ctx)
 }
 
 /**
- * ckpt_read_file_desc - restore the state of a given file descriptor
+ * restore_file_desc - restore the state of a given file descriptor
  * @ctx: checkpoint context
  *
  * Restores the state of a file descriptor; looks up the objref (in the
@@ -908,7 +985,11 @@ static int restore_file_desc(struct ckpt_ctx *ctx)
 	}
 
 	set_close_on_exec(h->fd_descriptor, h->fd_close_on_exec);
-	ret = 0;
+	ret = restore_file_locks(ctx, file, h->fd_descriptor);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "Error restoring locks on fd %d\n",
+				h->fd_descriptor);
+	}
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
-- 
1.6.0.4
