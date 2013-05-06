From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET] blk-throttle: implement proper hierarchy support
Date: Mon, 6 May 2013 13:33:06 -0400
Message-ID: <20130506173306.GC11731@redhat.com>
References: <20130502190732.GK30020@redhat.com>
	<CAOS58YOk7G=dBG1v5Ed2z3biMMyKkkutp30vH5XC72z0_Z85cw@mail.gmail.com>
	<20130502193139.GL30020@redhat.com>
	<20130502231307.GT19814@mtj.dyndns.org>
	<20130503175652.GB6062@redhat.com>
	<20130503185751.GA22860@mtj.dyndns.org>
	<20130503190823.GC6062@redhat.com>
	<20130503191418.GC22860@mtj.dyndns.org>
	<20130503210513.GE6062@redhat.com>
	<20130503235455.GE22860@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130503235455.GE22860-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, May 03, 2013 at 04:54:55PM -0700, Tejun Heo wrote:
> Hey,
> 
> On Fri, May 03, 2013 at 05:05:13PM -0400, Vivek Goyal wrote:
> > Following inline patch implements transferring child's start time to 
> > parent, if parent slice had expired at the time of bio migration.
> > 
> > I does seem to help a lot on my machine. Can you please give it a try.
> 
> Cool, will give it a try.  Can you please make it a proper patch with
> SOB?  Please feel free to base it on top of the series.  It can
> probably go right below the final patch but the rebase there should be
> trivial.

Hi tejun,

Here is the patch to fix the issue. It is on top of your old series
(no throtl_node stuff). Do let me know if want me to refresh it
on top of throtl_node patch.

Thanks
Vivek


blk-throtl: Account for child group's start time in parent while bio climbs up

Now with hierarchy support, a bio climbs up the tree before actually
being dispatched. This makes sure bio is also subjected to parent's
throttling limits, if any.

It might happen that parent is idle and when bio is transferred to
parent, a new slice starts fresh. But that is not good as parents
wait time should have started when bio was queued in child group.

Given the fact that we have not written hierarchical algorithm 
in a way where child's and parents time slices are synchronized,
we transfer the child's start time to parent if parent was idling.
If parent was busy doing dispatch of other bios all this while, this
is not an issue.

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
---
 block/blk-throttle.c |   33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

Index: linux-2.6/block/blk-throttle.c
===================================================================
--- linux-2.6.orig/block/blk-throttle.c	2013-05-06 12:59:20.585535099 -0400
+++ linux-2.6/block/blk-throttle.c	2013-05-06 13:03:37.857552427 -0400
@@ -547,6 +547,28 @@ static bool throtl_schedule_next_dispatc
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
@@ -888,6 +910,16 @@ static void tg_update_disptime(struct th
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
@@ -909,6 +941,7 @@ static void tg_dispatch_one_bio(struct t
 	 */
 	if (parent_tg) {
 		throtl_add_bio_tg(bio, parent_tg);
+		start_parent_slice_with_credit(tg, parent_tg, rw);
 	} else {
 		bio_list_add(&parent_sq->bio_lists[rw], bio);
 		BUG_ON(tg->td->nr_queued[rw] <= 0);
