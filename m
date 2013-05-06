From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 31/33] blk-throttle: Account for child group's start time in
	parent while bio climbs up
Date: Mon,  6 May 2013 15:46:10 -0700
Message-ID: <1367880372-28312-32-git-send-email-tj__49551.7125622884$1367880751$gmane$org@kernel.org>
References: <1367880372-28312-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1367880372-28312-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

With the planned proper hierarchy support, a bio will climb up the
tree before actually being dispatched. This makes sure bio is also
subjected to parent's throttling limits, if any.

It might happen that parent is idle and when bio is transferred to
parent, a new slice starts fresh. But that is incorrect as parents
wait time should have started when bio was queued in child group and
causes IOs to be throttled more than configured as they climb the
hierarchy.

Given the fact that we have not written hierarchical algorithm in a
way where child's and parents time slices are synchronized, we
transfer the child's start time to parent if parent was idling.  If
parent was busy doing dispatch of other bios all this while, this is
not an issue.

Child's slice start time is passed to parent. Parent looks at its
last expired slice start time. If child's start time is after parents
old start time, that means parent had been idle and after parent
went idle, child had an IO queued. So use child's start time as
parent start time.

If parent's start time is after child's start time, that means,
when IO got queued in child group, parent was not idle. But later
it dispatched some IO, its slice got trimmed and then it went idle.
After a while child's request got shifted in parent group. In this
case use parent's old start time as new start time as that's the
duration of slice we did not use.

This logic is far from perfect as if there are multiple childs
then first child transferring the bio decides the start time while
a bio might have queued up even earlier in other child, which is
yet to be transferred up to parent. In that case we will lose
time and bandwidth in parent. This patch is just an approximation
to make situation somewhat better.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 541bd0d..7477f33 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -633,6 +633,28 @@ static bool throtl_schedule_next_dispatch(struct throtl_service_queue *sq,
 	return false;
 }
 
+static inline void throtl_start_new_slice_with_credit(struct throtl_grp *tg,
+		bool rw, unsigned long start)
+{
+	tg->bytes_disp[rw] = 0;
+	tg->io_disp[rw] = 0;
+
+	/*
+	 * Previous slice has expired. We must have trimmed it after last
+	 * bio dispatch. That means since start of last slice, we never used
+	 * that bandwidth. Do try to make use of that bandwidth while giving
+	 * credit.
+	 */
+	if (time_after_eq(start, tg->slice_start[rw]))
+		tg->slice_start[rw] = start;
+
+	tg->slice_end[rw] = jiffies + throtl_slice;
+	throtl_log(&tg->service_queue,
+		   "[%c] new slice with credit start=%lu end=%lu jiffies=%lu",
+		   rw == READ ? 'R' : 'W', tg->slice_start[rw],
+		   tg->slice_end[rw], jiffies);
+}
+
 static inline void throtl_start_new_slice(struct throtl_grp *tg, bool rw)
 {
 	tg->bytes_disp[rw] = 0;
@@ -992,6 +1014,16 @@ static void tg_update_disptime(struct throtl_grp *tg)
 	tg->flags &= ~THROTL_TG_WAS_EMPTY;
 }
 
+static void start_parent_slice_with_credit(struct throtl_grp *child_tg,
+					struct throtl_grp *parent_tg, bool rw)
+{
+	if (throtl_slice_used(parent_tg, rw)) {
+		throtl_start_new_slice_with_credit(parent_tg, rw,
+				child_tg->slice_start[rw]);
+	}
+
+}
+
 static void tg_dispatch_one_bio(struct throtl_grp *tg, bool rw)
 {
 	struct throtl_service_queue *sq = &tg->service_queue;
@@ -1020,6 +1052,7 @@ static void tg_dispatch_one_bio(struct throtl_grp *tg, bool rw)
 	 */
 	if (parent_tg) {
 		throtl_add_bio_tg(bio, &tg->qnode_on_parent[rw], parent_tg);
+		start_parent_slice_with_credit(tg, parent_tg, rw);
 	} else {
 		throtl_qnode_add_bio(bio, &tg->qnode_on_parent[rw],
 				     &parent_sq->queued[rw]);
-- 
1.8.1.4
