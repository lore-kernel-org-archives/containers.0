From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 03/24] io-controller: bfq support of in-class preemption
Date: Tue, 28 Jul 2009 14:45:19 -0400
Message-ID: <20090728184519.GC3870__28478.8717901849$1248806929$gmane$org@redhat.com>
References: <1248467274-32073-1-git-send-email-vgoyal@redhat.com>
	<1248467274-32073-4-git-send-email-vgoyal@redhat.com>
	<4A6DDBDE.8020608@redhat.com> <20090727224138.GA3702@redhat.com>
	<4A6EE4A0.6080700@redhat.com> <20090728135212.GC6133@redhat.com>
	<4A6F0B32.7060801@redhat.com> <20090728150310.GA3870@redhat.com>
	<4A6F1B4F.6080709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A6F1B4F.6080709-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jerome Marchand <jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 28, 2009 at 05:37:51PM +0200, Jerome Marchand wrote:
> Vivek Goyal wrote:
> > On Tue, Jul 28, 2009 at 04:29:06PM +0200, Jerome Marchand wrote:
> >> Vivek Goyal wrote:
> >>> On Tue, Jul 28, 2009 at 01:44:32PM +0200, Jerome Marchand wrote:
> >>>> Vivek Goyal wrote:
> >>>>> Hi Jerome,
> >>>>>
> >>>>> Thanks for testing it out. I could also reproduce the issue.
> >>>>>
> >>>>> I had assumed that RT queue will always preempt non-RT queue and hence if
> >>>>> there is an RT ioq/request pending, the sd->next_entity will point to
> >>>>> itself and any queue which is preempting it has to be on same service
> >>>>> tree.
> >>>>>
> >>>>> But in your test case it looks like that RT async queue is pending and 
> >>>>> there is some sync BE class IO going on. It looks like that CFQ allows
> >>>>> sync queue preempting async queue irrespective of class, so in this case
> >>>>> sync BE class reader will preempt async RT queue and that's where my
> >>>>> assumption is broken and we see BUG_ON() hitting.
> >>>>>
> >>>>> Can you please tryout following patch. It is a quick patch and requires
> >>>>> more testing. It solves the crash but still does not solve the issue of
> >>>>> sync queue always preempting async queues irrespective of class. In
> >>>>> current scheduler we always schedule the RT queue first (whether it be
> >>>>> sync or async). This problem requires little more thought.
> >>>> I've tried it: I can't reproduce the issue anymore and I haven't seen any
> >>>> other problem so far.
> >>>> By the way, what is the expected result regarding fairness among different
> >>>> groups when IO from different classes are run on each group? For instance,
> >>>> if we have RT IO going on on one group, BE IO on an other and Idle IO on a
> >>>> third group, what is the expected result: should the IO time been shared
> >>>> fairly between the groups or should RT IO have priority? As it is now, the
> >>>> time is shared fairly between BE and RT groups and the last group running
> >>>> Idle IO hardly get any time.
> >>>>
> >>> Hi Jerome,
> >>>
> >>> If there are two groups RT and BE, I would expect RT group to get all the
> >>> bandwidth as long as it is backlogged and starve the BE group.
> >> I wasn't clear enough. I meant the class of the process as set by ionice, not
> >> the class of the cgroup. That is, of course, only an issue when using CFQ.
> >>
> >>> I ran quick test of two dd readers. One reader is in RT group and other is
> >>> in BE group. I do see that RT group runs away with almost all the BW.
> >>>
> >>> group1 time=8:16 2479 group1 sectors=8:16 457848
> >>> group2 time=8:16 103  group2 sectors=8:16 18936
> >>>
> >>> Note that when group1 (RT) finished it had got 2479 ms of disk time while
> >>> group2 (BE) got only 103 ms.
> >>>
> >>> Can you send details of your test. It should not be fair sharing between
> >>> RT and BE group.
> >> Setup:
> >>
> >> $ mount -t cgroup -o io,blkio none /cgroup
> >> $ mkdir /cgroup/test1 /cgroup/test2 /cgroup/test3
> >> $ echo 1000 > /cgroup/test1/io.weight
> >> $ echo 1000 > /cgroup/test2/io.weight
> >> $ echo 1000 > /cgroup/test3/io.weight
> >>
> >> Test:
> >> $ echo 3 > /proc/sys/vm/drop_caches
> >>
> >> $ ionice -c 1 dd if=/tmp/io-controller-test3 of=/dev/null &
> >> $ echo $! > /cgroup/test1/tasks
> >>
> >> $ ionice -c 2 dd if=/tmp/io-controller-test1 of=/dev/null &
> >> $ echo $! > /cgroup/test2/tasks
> >>
> >> $ ionice -c 3 dd if=/tmp/io-controller-test2 of=/dev/null &
> >> $ echo $! > /cgroup/test3/tasks
> >>
> > 
> > Ok, got it. So you have created three BE class groups and with-in those
> > groups you are running job of RT, BE and IDLE type.
> > 
> > From group scheduling point of view, because the tree groups have got same
> > class and same weight, they should get equal access to disk and with-in
> > group how bandwidth is divided is left to CFQ.
> > 
> > Because in this case, only one task is present in each group, it should
> > get all the BW available to the group. Hence, in above test case, all the
> > three dd processes should get equal amount of disk time.
> 
> OK. That's how I understood it, but I wanted your confirmation.
> 
> > 
> > You mentioned that RT and BE task are getting fair share but not IDLE
> > task. This is a bug and probably I know where the bug is. I will debug it
> > and fix it soon.
> 
> I've tested it with the last version of your patchset (v6) and the problem
> was less acute (the IDLE task got about 5 times less time that RT and BE
> against 50 times less with v7 patchset). I hope that helps you.

Hi Jerome,

Can you please try attached patch. It should fix the issue of group in 
which idle task is running is not getting its fair share.

The primary issue here is that for such groups, we were not doing group
idle, which will lead to queue and group deletion immediately after 
dispatching one request and it will not get its fair share.

Attached patch should fix the problem.

Thanks
Vivek


---
 block/cfq-iosched.c |    5 ++-
 block/elevator-fq.c |   70 ++++++++++++++++++++++++++++++++++++----------------
 block/elevator-fq.h |    1 
 3 files changed, 54 insertions(+), 22 deletions(-)

Index: linux8/block/elevator-fq.c
===================================================================
--- linux8.orig/block/elevator-fq.c	2009-07-27 18:18:49.000000000 -0400
+++ linux8/block/elevator-fq.c	2009-07-28 14:30:08.000000000 -0400
@@ -1212,6 +1212,30 @@ io_group_init_entity(struct io_cgroup *i
 	entity->my_sched_data = &iog->sched_data;
 }
 
+/* Check if we plan to idle on the group associated with this queue or not */
+int elv_iog_should_idle(struct io_queue *ioq)
+{
+	struct io_group *iog = ioq_to_io_group(ioq);
+	struct elv_fq_data *efqd = ioq->efqd;
+
+	/*
+	 * No idling on group if group idle is disabled or idling is disabled
+	 * for this group. Currently for root group idling is disabled.
+	 */
+	if (!efqd->elv_group_idle || !elv_iog_idle_window(iog))
+		return 0;
+
+	/*
+	 * If this is last active queue in group with no request queued, we
+	 * need to idle on group before expiring the queue to make sure group
+	 * does not loose its share.
+	 */
+	if ((elv_iog_nr_active(iog) <= 1) && !ioq->nr_queued)
+		return 1;
+
+	return 0;
+}
+
 static void io_group_set_parent(struct io_group *iog, struct io_group *parent)
 {
 	struct io_entity *entity;
@@ -2708,6 +2732,10 @@ static inline int is_only_root_group(voi
 {
 	return 1;
 }
+
+/* No group idling in flat mode */
+int elv_iog_should_idle(struct io_queue *ioq) { return 0; }
+
 #endif /* GROUP_IOSCHED */
 
 /* Elevator fair queuing function */
@@ -3308,12 +3336,18 @@ void __elv_ioq_slice_expired(struct requ
 	if (time_after(ioq->slice_end, jiffies)) {
 		slice_unused = ioq->slice_end - jiffies;
 		if (slice_unused == entity->budget) {
-			/*
-			 * queue got expired immediately after
-			 * completing first request. Charge 1/2 of
-			 * time consumed in completing first request.
+			/* Queue got expired immediately after completing
+			 * first request. It happens with idle class queues
+			 * as well as can happen with closely cooperating
+			 * queues or with queues for which idling is not
+			 * enabled.
+			 *
+			 * Charge the full time since slice was started. This
+			 * will include the seek cost also on rotational media.
+			 * This is bit unfair but don't know what's the better
+			 * way to handle such cases.
 			 */
-			slice_used = (slice_used + 1)/2;
+			slice_used = jiffies - ioq->slice_start;
 		} else
 			slice_used = entity->budget - slice_unused;
 	} else {
@@ -3686,7 +3720,8 @@ void *elv_fq_select_ioq(struct request_q
 	/*
 	 * The active queue has run out of time, expire it and select new.
 	 */
-	if (elv_ioq_slice_used(ioq) && !elv_ioq_must_dispatch(ioq)) {
+	if ((elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq))
+             && !elv_ioq_must_dispatch(ioq)) {
 		/*
 		 * Queue has used up its slice. Wait busy is not on otherwise
 		 * we wouldn't have been here. If this group will be deleted
@@ -3711,9 +3746,7 @@ void *elv_fq_select_ioq(struct request_q
 		 * from queue and is not proportional to group's weight, it
 		 * harms the fairness of the group.
 		 */
-		if ((elv_iog_nr_active(iog) <= 1) && !ioq->nr_queued
-		   && !elv_iog_wait_busy_done(iog) && efqd->elv_group_idle
-		   && elv_iog_idle_window(iog)) {
+		if (elv_iog_should_idle(ioq) && !elv_iog_wait_busy_done(iog)) {
 			ioq = NULL;
 			goto keep_queue;
 		} else
@@ -3893,12 +3926,6 @@ void elv_ioq_completed_request(struct re
 			elv_clear_ioq_slice_new(ioq);
 		}
 
-		if (elv_ioq_class_idle(ioq)) {
-			if (elv_iosched_expire_ioq(q, 1, 0))
-				elv_ioq_slice_expired(q);
-			goto done;
-		}
-
 		/*
 		 * If there is only root group present, don't expire the queue
 		 * for single queue ioschedulers (noop, deadline, AS). It is
@@ -3919,14 +3946,14 @@ void elv_ioq_completed_request(struct re
 		 * mean seek distance, give them a chance to run instead
 		 * of idling.
 		 */
-		if (elv_ioq_slice_used(ioq)) {
+		if (elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq)) {
 			/* This is the last empty queue in the group and it
 			 * has consumed its slice. If we expire it right away
 			 * group might loose its share. Wait for an extra
 			 * group_idle period for a request before queue
 			 * expires.
 			 */
-			if ((elv_iog_nr_active(iog) <= 1) && !ioq->nr_queued) {
+			if (elv_iog_should_idle(ioq)) {
 				elv_iog_arm_slice_timer(q, iog, 1);
 				goto done;
 			}
@@ -3943,8 +3970,10 @@ void elv_ioq_completed_request(struct re
 				goto done;
 
 			/* Expire the queue */
-			if (elv_iosched_expire_ioq(q, 1, 0))
+			if (elv_iosched_expire_ioq(q, 1, 0)) {
 				elv_ioq_slice_expired(q);
+				goto done;
+			}
 		} else if (!ioq->nr_queued && !elv_close_cooperator(q, ioq)
 			   && sync && !rq_noidle(rq))
 			elv_ioq_arm_slice_timer(q);
@@ -3953,9 +3982,8 @@ void elv_ioq_completed_request(struct re
 		 * If this is the last queue in the group and we did not
 		 * decide to idle on queue, idle on group.
 		 */
-		if (elv_active_ioq(q->elevator) && !ioq->nr_queued &&
-		    !ioq->dispatched && !timer_pending(&efqd->idle_slice_timer)
-		    && (elv_iog_nr_active(iog) <= 1)) {
+		if (elv_iog_should_idle(ioq) && !ioq->dispatched
+		    && !timer_pending(&efqd->idle_slice_timer)) {
 			/*
 			 * If queue has used up its slice, wait for the
 			 * one extra group_idle period to let the group
Index: linux8/block/elevator-fq.h
===================================================================
--- linux8.orig/block/elevator-fq.h	2009-07-24 16:09:04.000000000 -0400
+++ linux8/block/elevator-fq.h	2009-07-28 13:18:00.000000000 -0400
@@ -695,6 +695,7 @@ extern int elv_nr_busy_ioq(struct elevat
 extern int elv_rq_in_driver(struct elevator_queue *e);
 extern struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp_mask);
 extern void elv_free_ioq(struct io_queue *ioq);
+extern int elv_iog_should_idle(struct io_queue *ioq);
 
 #else /* CONFIG_ELV_FAIR_QUEUING */
 
Index: linux8/block/cfq-iosched.c
===================================================================
--- linux8.orig/block/cfq-iosched.c	2009-07-24 16:08:58.000000000 -0400
+++ linux8/block/cfq-iosched.c	2009-07-28 13:54:51.000000000 -0400
@@ -1007,10 +1007,13 @@ static int cfq_dispatch_requests(struct 
 	/*
 	 * expire an async queue immediately if it has used up its slice. idle
 	 * queue always expire after 1 dispatch round.
+	 *
+	 * Also do not expire the queue if we plan to do group idling on it.
+	 * In that case it will be expired later.
 	 */
 	if (elv_nr_busy_ioq(q->elevator) > 1 && ((!cfq_cfqq_sync(cfqq) &&
 	    cfqq->slice_dispatch >= cfq_prio_to_maxrq(cfqd, cfqq)) ||
-	    cfq_class_idle(cfqq))) {
+	    (cfq_class_idle(cfqq) && !elv_iog_should_idle(cfqq->ioq)))) {
 		cfq_slice_expired(cfqd);
 	}
