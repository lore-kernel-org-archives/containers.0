From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 16/16][cr][v3]: Restore file-leases
Date: Tue,  3 Aug 2010 16:11:37 -0700
Message-ID: <1280877097-12377-17-git-send-email-sukadev__7928.26519250429$1280877401$gmane$org@linux.vnet.ibm.com>
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

Restart an application with file-leases, from its checkpoint.

Restart of file-lease that is not being broken (i.e F_INPROGRESS is not set)
is almost identical to C/R of file-locks. i.e save the type of lease for the
file in the checkpoint image and when restarting, restore the lease by calling
do_setlease().

C/R of file-lease gets complicated (I think), if a process is checkpointed
when its lease was being revoked. i.e if P1 has a F_WRLCK lease on file F1
and P2 opens F1 for write, P2's open is blocked for lease_break_time (45 secs).
P1's lease is revoked (i.e set to F_UNLCK) and P1 is notified via a SIGIO to
flush any dirty data.

Basic design:

To restore a lease that is being broken, we temporarily re-assign the original
lease type (that we saved in ->fl_type_prev) to the lease-holder. i.e. in the
above example, give P1 a F_WRLCK lease). When the lease-breaker (P2) is
restarted after checkpoint, its open() system fails with -ERESTARTSYS and it
will retry the open(). This open() will re-initiate the lease-break protocol
(i.e P2 will go back to waiting and P1 will be notified).

Some observations about this approach:

1. We must use ->fl_type_prev because, when the lease is being broken,
  ->fl_type is already set to F_UNLCK and would not result in a
  lease-break protocol when P2 is restarted.

2. When the lease-break is initiated and we signal the lease-holder, we set
   the ->fl_break_notified field. When restarting the lease and repeating
   the lease-break protocol, we check the ->fl_break_notified field and
   signal the lease-holder only if did not signal before the checkpoint.

3. If P1 was was checkpointed 40 seconds into the lease_break_time,(i.e.
   it had 5 seconds remaining in the lease), we would ideally want to ensure
   that after restart, P1 gets 5 or at least 5 seconds to finish cleaning up
   the lease.

   But the actual time that P1 gets after the application is restarted
   depends on many factors (number of processes in the application
   process tree, load on system at the time of restart etc).

   Jamie Lokier had suggested that we favor the lease-holder (P1) during
   restart, even if it meant giving the lease-holder the entire lease-break
   interval (45 seconds) again after the restart. Oren Laadan suggested
   that rather than make that a kernel policy, we let the user choose a
   policy based on the application's behavior.

   The current patchset computes and checkpoints the remaining-lease and
   uses this value to restore the lease. i.e the kernel simply uses the
   "remaining-lease" value stored in the checkpoint image. Userspace tools
   can be developed to alter the remaining-lease value in the checkpoint
   image to either favor the lease-holder or the lease-breaker or to add
   a fixed delta.

4. The above design of C/R of file-leases assumes that both lease-holder
   and lease-breaker are restarted. If only the lease-holder is
   restarted, the kernel will re-assign the original lease (F_WRLCK in
   the example) to lease-holder. If no lease-breaker comes along, the
   kernel will leave the lease assigned to lease-holder.

   This should not be a problem because, as far as the lease-holder is
   concerned the lease was revoked and it will/should reacquire the
   lease.

Changelog[v3]:

	- Broke-up patchset into smaller patches and addressed comments
	  from Oren Laadan, Jamie Lokier.

Changelog[v2]:
	- comments from Matt Helsley, Serge Hallyn...

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/checkpoint.c |   29 +++++++++++++++++++++-
 fs/locks.c      |   71 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 95 insertions(+), 5 deletions(-)

diff --git a/fs/checkpoint.c b/fs/checkpoint.c
index 5e5d0c5..3b53f99 100644
--- a/fs/checkpoint.c
+++ b/fs/checkpoint.c
@@ -1090,8 +1090,10 @@ static int restore_file_locks(struct ckpt_ctx *ctx, struct file *file, int fd)
 		if (IS_ERR(h))
 			return PTR_ERR(h);
 
-		ckpt_debug("Lock [%lld, %lld, %d, 0x%x]\n", h->fl_start,
-				h->fl_end, (int)h->fl_type, h->fl_flags);
+		ckpt_debug("Lock [%lld, %lld, %d, 0x%x], fl_type_prev %d, "
+				"fl_break_notified %d\n", h->fl_start,
+				h->fl_end, (int)h->fl_type, h->fl_flags,
+				h->fl_type_prev, h->fl_break_notified);
 
 		/*
 		 * If it is a dummy-lock, we are done with this fd.
@@ -1104,6 +1106,29 @@ static int restore_file_locks(struct ckpt_ctx *ctx, struct file *file, int fd)
 		ret = -EBADF;
 		if (h->fl_flags & FL_POSIX)
 			ret = restore_one_file_lock(ctx, file, fd, h); 
+		else if (h->fl_flags & FL_LEASE) {
+			int type;
+			unsigned long bt;
+
+			type = h->fl_type;
+			if (h->fl_type & F_INPROGRESS)
+				type = h->fl_type_prev;
+
+			/*
+			 * Use ->fl_rem_lease to compute new break time in
+			 * jiffies relative to ->jiffies_begin.
+			 */
+			bt = ctx->jiffies_begin + (h->fl_rem_lease * HZ);
+
+			ckpt_debug("current-jiffies %lu, jiffies_begin %lu, "
+					"break-time-jiffies %lu\n", jiffies,
+					ctx->jiffies_begin, bt);
+
+			ret = do_setlease(fd, file, type, bt,
+						h->fl_break_notified);
+			if (ret)
+				ckpt_err(ctx, ret, "do_setlease(): %d\n", type);
+		}
 
 		if (ret < 0)
 			ckpt_err(ctx, ret, "%(T) fl_flags 0x%x\n", h->fl_flags);
diff --git a/fs/locks.c b/fs/locks.c
index 6e84d90..b0640b9 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1183,6 +1183,16 @@ static void time_out_leases(struct inode *inode)
  *	some kind of lock (maybe a lease) on this file.  Leases are broken on
  *	a call to open() or truncate().  This function can sleep unless you
  *	specified %O_NONBLOCK to your open().
+ *
+ *	Checkpoint/restart: Suppose 10 seconds remain in a lease when the
+ *		lease-holder is checkpointed. When the lease-holder is
+ *		restarted, it should probably only get 10-seconds of the
+ *		lease, but we favor the lease-holder and allow it to to
+ *		have entire lease-break-time again. This can of course
+ *		cause the lease-breaker(s) to starve if the application is
+ *		repeatedly checkpointed during the lease-break protocol,
+ *		but that is hopefully not a common occurence.
+ *
  */
 int __break_lease(struct inode *inode, unsigned int mode)
 {
@@ -1236,12 +1246,38 @@ int __break_lease(struct inode *inode, unsigned int mode)
 
 	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
 		if (fl->fl_type != future) {
-			fl->fl_type_prev = fl->fl_type;
+
+			/*
+			 * If ->fl_type_prev is already set, we could be in a
+			 * recursive checkpoint/restart. i.e. we were
+			 * checkpointed once when our lease was being broken.
+			 * We were then restarted from the checkpoint and
+			 * immediately checkpointed again before the restored
+			 * lease expired. In this case, we want to restore
+			 * the lease to the original type. So don't overwrite
+			 * ->fl_type_prev if its already set.
+			 */
+			if (!fl->fl_type_prev)
+				fl->fl_type_prev = fl->fl_type;
+
 			fl->fl_type = future;
-			fl->fl_break_time = break_time;
+			/*
+			 * If this lease was restored from a checkpoint (i.e.
+			 * ->fl_break_time is set), don't change the remaining
+			 *  time on the lease.
+			 */
+			if (!fl->fl_break_time)
+				fl->fl_break_time = break_time;
+
+			/*
+			 * Similarly, if we already notified the lease-holder
+			 * before the checkpoint, i.e. ->fl_break_notified is
+			 * set, don't notify again.
+			 */
 
 			/* lease must have lmops break callback */
-			fl->fl_lmops->fl_break(fl);
+			if (!fl->fl_break_notified)
+				fl->fl_lmops->fl_break(fl);
 			fl->fl_break_notified = 1;
 		}
 	}
@@ -1490,6 +1526,35 @@ int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
 }
 EXPORT_SYMBOL_GPL(vfs_setlease);
 
+/*
+ * do_setlease():
+ *
+ *
+ * Checkpoint/restart notes:
+ *
+ * 	If this lease was from a checkpoint, we assume that the lease-breaker
+ * 	was also checkpointed, and we re-assign the lease to the lease holder.
+ *
+ * 	When the lease-breaker is restarted, it will retry the open() and thus
+ * 	initiate the lease-break protocol again. But to avoid confusing the
+ * 	application, we follow the entire lease-break protocol except that we
+ * 	signal the application only if it was not signalled before.
+ *
+ * 	Note that these semantics assume that the lease-breaker will come along
+ * 	and reclaim the lease. If that does not happen, (either because the
+ * 	lease-breaker was not checkpointed or is not being restarted at the
+ * 	same time as the lease-holder) the kernel will leave the lease assigned
+ * 	to the lease-holder, even though the application assumes it no longer
+ * 	has the lease.
+ *
+ * 	But this discrepancy will not cause a problem for the lease-holder,
+ * 	since the lease-holder "knows" it does not have the lease and will
+ * 	have to reacquire the lease.
+ *
+ * 	This semantics has a down-side to any new lease-breaker in that they
+ * 	will be blocked for the lease_break_time, even if the lease-holder no
+ * 	longer has the lease.
+ */
 int do_setlease(unsigned int fd, struct file *filp, long arg, 
 			unsigned long break_time, int notified)
 {
-- 
1.6.0.4
