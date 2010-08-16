From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 09/17][cr][v4]: Restore file-locks
Date: Mon, 16 Aug 2010 12:43:13 -0700
Message-ID: <1281987801-1293-10-git-send-email-sukadev__42276.654757052$1281988546$gmane$org@linux.vnet.ibm.com>
References: <1281987801-1293-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1281987801-1293-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Restore POSIX file-locks of an application from its checkpoint image.

Read the saved file-locks from the checkpoint image and for each POSIX
lock, call flock_set() to set the lock on the file.

As pointed out by Matt Helsley, no special handling is necessary for a
process P2 in the checkpointed container that is blocked on a lock, L1
held by another process P1. Processes in the restarted container begin
execution only after all processes have restored. If the blocked process
P2 is restored first, it will prepare to return an -ERESTARTSYS from the
fcntl() system call, but wait for P1 to be restored. When P1 is restored,
it will re-acquire the lock L1 before P1 and P2 begin actual execution.
This ensures that even if P2 is scheduled to run before P1, P2 will go
back to waiting for the lock L1.

Changelog[v4]:
	- [Oren Laadan]: For consistency with other such objects, replace
	  checkpoint of the "marker lock" with a checkpoint of a count of
	  file-locks on the file, before the checkpoint of the first lock.
	- Added a missing ckpt_hdr_put()
	- Minor reorg of code.

Changelog[v3]:
	- [Oren Laadan]: Use a macro that can be shared with user-space
	  to set/test marker file-lock.

Changelog[v2]:
	- Add support for C/R of F_SETLK64/F_GETLK64

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/checkpoint.c |  176 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 174 insertions(+), 2 deletions(-)

diff --git a/fs/checkpoint.c b/fs/checkpoint.c
index 47aa802..540f831 100644
--- a/fs/checkpoint.c
+++ b/fs/checkpoint.c
@@ -981,8 +981,176 @@ static void *restore_file(struct ckpt_ctx *ctx)
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
@@ -1028,7 +1196,11 @@ static int restore_file_desc(struct ckpt_ctx *ctx)
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
-- 
1.6.0.4
