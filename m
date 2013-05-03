From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET] blk-throttle: implement proper hierarchy support
Date: Fri, 3 May 2013 17:05:13 -0400
Message-ID: <20130503210513.GE6062__20597.1524156213$1367615141$gmane$org@redhat.com>
References: <20130502184514.GI30020@redhat.com>
	<20130502184953.GP19814@mtj.dyndns.org>
	<20130502190732.GK30020@redhat.com>
	<CAOS58YOk7G=dBG1v5Ed2z3biMMyKkkutp30vH5XC72z0_Z85cw@mail.gmail.com>
	<20130502193139.GL30020@redhat.com>
	<20130502231307.GT19814@mtj.dyndns.org>
	<20130503175652.GB6062@redhat.com>
	<20130503185751.GA22860@mtj.dyndns.org>
	<20130503190823.GC6062@redhat.com>
	<20130503191418.GC22860@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130503191418.GC22860-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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

On Fri, May 03, 2013 at 12:14:18PM -0700, Tejun Heo wrote:
> On Fri, May 03, 2013 at 03:08:23PM -0400, Vivek Goyal wrote:
> > 		T1	T2	T3	T4	T5	T6	T7
> > parent:			b1	b2	b3		b4 	b5
> > child: 		b1	b2	b3		b4	b5	
> > 
> > 
> > So continuity breaks down because application is waiting for previous
> > IO to finish. This forces expiry of existing time slices and new time
> > slice start both in child and parent and penalty keep on increasing.
> 
> It's a problem even in flat mode as the "child" above can easily be
> just a process which is throttling itself and it won't be able to get
> the configured bandwidth due to the scheduling bubbles introduced
> whenever new slice is started.  Shouldn't be too difficult to get rid
> of, right?

Hi Tejun,

Following inline patch implements transferring child's start time to 
parent, if parent slice had expired at the time of bio migration.

I does seem to help a lot on my machine. Can you please give it a try.

I think even this approach is flawed. If there are multiple children,
it might happen that one child pushes up the bio early (as it is smaller
size bio or group rate is high). And later other child pushes up the bio
(bio was big or group limit was slow). We still lost time and effective
rate will still be lower than anticipated.

Thanks
Vivek


---
 block/blk-throttle.c |   40 ++++++++++++++++++++++++++++++++++++++--
 1 file changed, 38 insertions(+), 2 deletions(-)

Index: linux-2.6/block/blk-throttle.c
===================================================================
--- linux-2.6.orig/block/blk-throttle.c	2013-05-03 16:03:10.279016400 -0400
+++ linux-2.6/block/blk-throttle.c	2013-05-03 16:46:11.398936631 -0400
@@ -547,6 +547,30 @@ static bool throtl_schedule_next_dispatc
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
+	 * credit
+	 */
+	if (time_after_eq(start, tg->slice_start[rw])) {
+		tg->slice_start[rw] = start;
+	} else
+		tg->slice_start[rw] = tg->slice_start[rw];
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
@@ -888,6 +912,16 @@ static void tg_update_disptime(struct th
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
@@ -908,7 +942,9 @@ static void tg_dispatch_one_bio(struct t
 	 * responsible for issuing these bios.
 	 */
 	if (parent_tg) {
+		throtl_log(parent_sq, "add bio sz=%u", bio->bi_size);
 		throtl_add_bio_tg(bio, parent_tg);
+		start_parent_slice_with_credit(tg, parent_tg, rw);
 	} else {
 		bio_list_add(&parent_sq->bio_lists[rw], bio);
 		BUG_ON(tg->td->nr_queued[rw] <= 0);
@@ -1369,11 +1405,11 @@ bool blk_throtl_bio(struct request_queue
 	}
 
 	/* out-of-limit, queue to @tg */
-	throtl_log(sq, "[%c] bio. bdisp=%llu sz=%u bps=%llu iodisp=%u iops=%u queued=%d/%d",
+	throtl_log(sq, "[%c] bio. bdisp=%llu sz=%u bps=%llu iodisp=%u iops=%u queued=%d/%d sz=%u",
 		   rw == READ ? 'R' : 'W',
 		   tg->bytes_disp[rw], bio->bi_size, tg->bps[rw],
 		   tg->io_disp[rw], tg->iops[rw],
-		   sq->nr_queued[READ], sq->nr_queued[WRITE]);
+		   sq->nr_queued[READ], sq->nr_queued[WRITE], bio->bi_size);
 
 	bio_associate_current(bio);
 	tg->td->nr_queued[rw]++;
