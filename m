From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 14/17][cr][v4]: Checkpoint file-leases
Date: Mon, 16 Aug 2010 12:43:18 -0700
Message-ID: <1281987801-1293-15-git-send-email-sukadev__12996.5734239251$1281988052$gmane$org@linux.vnet.ibm.com>
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

Build upon the C/R of file-locks to checkpoint file-leases. This patch
simply checkpoints the file-lease information. A follow-on patch
will use this checkpoint information to restorethe file leases.

C/R of file leases depends on whether the lease is currently being broken
(i.e F_INPROGRESS is set) or not.  If the file-lease is not being broken,
checkpoint of file-lease is identical to checkpoint of file-locks.

But if the lease is being broken, we checkpoint additional information,
such as:
        - the previous lease type,
        - the time remaining in the lease, and
        - whether we already notified the lease-holder about the lease-break

See follow-on patch ("Restore file-leases") for more details on how this
information is used while restoring file leases and for other semantics
relating to file-leases.

Changelog[v4]:
	- [Oren Laadan]: Minor changes due to the fact that we now checkpoint
	  the count of file-locks rather than a "marker-lock".
Changelog[v3]:
	- [Oren Laadan, John Stultz]: Use ->jiffies_begin to compute
	  remaining lease
        - Broke-up the draft-patch from previous version into smaller
          patches and addressed comments from Oren Laadan.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/checkpoint.c                |   29 +++++++++++++++++++++++++----
 include/linux/checkpoint_hdr.h |    3 +++
 2 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/fs/checkpoint.c b/fs/checkpoint.c
index 540f831..8a4cd23 100644
--- a/fs/checkpoint.c
+++ b/fs/checkpoint.c
@@ -267,13 +267,24 @@ static int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
 	return ret;
 }
 
+static int get_rem_lease(struct ckpt_ctx *ctx, struct file_lock *lock)
+{
+	int rem_lease;
+
+	rem_lease = 0;
+	if ((lock->fl_type & F_INPROGRESS))
+		rem_lease = (lock->fl_break_time - ctx->jiffies_begin) / HZ;
+
+	return rem_lease;
+}
+
 static int checkpoint_one_file_lock(struct ckpt_ctx *ctx, 
 		struct file_lock *lock)
 {
 	int rc;
 	struct ckpt_hdr_file_lock *h;
 
-	if (!IS_POSIX(lock)) {
+	if (!IS_POSIX(lock) && !IS_LEASE(lock)) {
 		/* Hmm, we should have caught this while counting locks */
 		return -EBADF;
 	}
@@ -284,8 +295,14 @@ static int checkpoint_one_file_lock(struct ckpt_ctx *ctx,
 
 	h->fl_start = lock->fl_start;
 	h->fl_end = lock->fl_end;
+	/* checkpoint F_INPROGRESS also, if set */
+	h->fl_type_prev = lock->fl_type_prev;
 	h->fl_type = lock->fl_type;
 	h->fl_flags = lock->fl_flags;
+	if (IS_LEASE(lock)) {
+		h->fl_break_notified = lock->fl_break_notified;
+		h->fl_rem_lease = get_rem_lease(ctx, lock);
+	}
 
 	rc = ckpt_write_obj(ctx, &h->h);
 
@@ -335,13 +352,17 @@ checkpoint_file_locks(struct ckpt_ctx *ctx, struct files_struct *files,
 		if (lockp->fl_owner != files)
 			continue;
 
-		ckpt_debug("Lock [%lld, %lld, %d, 0x%x]\n", lockp->fl_start,
-				lockp->fl_end, lockp->fl_type, lockp->fl_flags);
+		ckpt_debug("Lock [%lld, %lld, %d, 0x%x], type_prev %d, "
+				"break-notified %d, rem-lease %d\n",
+				lockp->fl_start, lockp->fl_end, lockp->fl_type,
+				lockp->fl_flags, lockp->fl_type_prev,
+				lockp->fl_break_notified,
+				get_rem_lease(ctx, lockp));
 
 		if (lockp->fl_owner != files)
 			continue;
 
-		if (IS_POSIX(lockp))
+		if (IS_POSIX(lockp) || IS_LEASE(lockp))
 			n++;
 		else {
 			ckpt_err(ctx,  rc, "%(T), checkpoint of lock "
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 14b287f..2a54a89 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -600,7 +600,10 @@ struct ckpt_hdr_file_lock {
        __s64 fl_start;
        __s64 fl_end;
        __u8 fl_type;
+       __u8 fl_type_prev;
        __u8 fl_flags;
+       __u8 fl_break_notified;
+       __s32 fl_rem_lease;
 };
 
 struct ckpt_hdr_file_pipe {
-- 
1.6.0.4
