From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] io-controller: Fix task hanging when there are more
	than one groups
Date: Mon, 14 Sep 2009 23:37:39 -0400
Message-ID: <20090915033739.GA4054__23958.7193857462$1252986006$gmane$org@redhat.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<4AA4B905.8010801@cn.fujitsu.com>
	<20090908191941.GF15974@redhat.com>
	<4AA75B71.5060109@cn.fujitsu.com>
	<20090909150537.GD8256@redhat.com> <4AA9A4BE.30005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AA9A4BE.30005-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Sep 11, 2009 at 09:15:42AM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> > On Wed, Sep 09, 2009 at 03:38:25PM +0800, Gui Jianfeng wrote:
> >> Vivek Goyal wrote:
> >>> On Mon, Sep 07, 2009 at 03:40:53PM +0800, Gui Jianfeng wrote:
> >>>> Hi Vivek,
> >>>>
> >>>> I happened to encount a bug when i test IO Controller V9.
> >>>> When there are three tasks to run concurrently in three group,
> >>>> that is, one is parent group, and other two tasks are running 
> >>>> in two different child groups respectively to read or write 
> >>>> files in some disk, say disk "hdb", The task may hang up, and 
> >>>> other tasks which access into "hdb" will also hang up.
> >>>>
> >>>> The bug only happens when using AS io scheduler.
> >>>> The following scirpt can reproduce this bug in my box.
> >>>>
> >>> Hi Gui,
> >>>
> >>> I tried reproducing this on my system and can't reproduce it. All the
> >>> three processes get killed and system does not hang.
> >>>
> >>> Can you please dig deeper a bit into it. 
> >>>
> >>> - If whole system hangs or it is just IO to disk seems to be hung.
> >>     Only when the task is trying do IO to disk it will hang up.
> >>
> >>> - Does io scheduler switch on the device work
> >>     yes, io scheduler can be switched, and the hung task will be resumed.
> >>
> >>> - If the system is not hung, can you capture the blktrace on the device.
> >>>   Trace might give some idea, what's happening.
> >> I run a "find" task to do some io on that disk, it seems that task hangs 
> >> when it is issuing getdents() syscall.
> >> kernel generates the following message:
> >>
> >> INFO: task find:3260 blocked for more than 120 seconds.
> >> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> >> find          D a1e95787  1912  3260   2897 0x00000004
> >>  f6af2db8 00000096 f660075c a1e95787 00000032 f6600270 f6600508 c2037820
> >>  00000000 c09e0820 f655f0c0 f6af2d8c fffebbf1 00000000 c0447323 f7152a1c
> >>  0006a144 f7152a1c 0006a144 f6af2e04 f6af2db0 c04438df c2037820 c2037820
> >> Call Trace:
> >>  [<c0447323>] ? getnstimeofday+0x57/0xe0
> >>  [<c04438df>] ? ktime_get_ts+0x4a/0x4e
> >>  [<c068ab68>] io_schedule+0x47/0x79
> >>  [<c04c12ee>] sync_buffer+0x36/0x3a
> >>  [<c068ae14>] __wait_on_bit+0x36/0x5d
> >>  [<c04c12b8>] ? sync_buffer+0x0/0x3a
> >>  [<c068ae93>] out_of_line_wait_on_bit+0x58/0x60
> >>  [<c04c12b8>] ? sync_buffer+0x0/0x3a
> >>  [<c0440fa4>] ? wake_bit_function+0x0/0x43
> >>  [<c04c1249>] __wait_on_buffer+0x19/0x1c
> >>  [<f81e4186>] ext3_bread+0x5e/0x79 [ext3]
> >>  [<f81e77a8>] htree_dirblock_to_tree+0x1f/0x120 [ext3]
> >>  [<f81e7923>] ext3_htree_fill_tree+0x7a/0x1bb [ext3]
> >>  [<c04a01f9>] ? kmem_cache_alloc+0x86/0xf3
> >>  [<c044c428>] ? trace_hardirqs_on_caller+0x107/0x12f
> >>  [<c044c45b>] ? trace_hardirqs_on+0xb/0xd
> >>  [<f81e09e4>] ? ext3_readdir+0x9e/0x692 [ext3]
> >>  [<f81e0b34>] ext3_readdir+0x1ee/0x692 [ext3]
> >>  [<c04b1100>] ? filldir64+0x0/0xcd
> >>  [<c068b86a>] ? mutex_lock_killable_nested+0x2b1/0x2c5
> >>  [<c068b874>] ? mutex_lock_killable_nested+0x2bb/0x2c5
> >>  [<c04b12db>] ? vfs_readdir+0x46/0x94
> >>  [<c04b12fd>] vfs_readdir+0x68/0x94
> >>  [<c04b1100>] ? filldir64+0x0/0xcd
> >>  [<c04b1387>] sys_getdents64+0x5e/0x9f
> >>  [<c04028b4>] sysenter_do_call+0x12/0x32
> >> 1 lock held by find/3260:
> >>  #0:  (&sb->s_type->i_mutex_key#7){+.+.+.}, at: [<c04b12db>] vfs_readdir+0x46/0x94
> >>
> >> ext3 calls wait_on_buffer() to wait buffer, and schedule the task out in TASK_UNINTERRUPTIBLE
> >> state, and I found this task will be resumed after a quite long period(more than 10 mins).
> > 
> > Thanks Gui. As Jens said, it does look like a case of missing queue
> > restart somewhere and now we are stuck, no requests are being dispatched
> > to the disk and queue is already unplugged.
> > 
> > Can you please also try capturing the trace of events at io scheduler
> > (blktrace) to see how did we get into that situation.
> > 
> > Are you using ide drivers and not libata? As jens said, I will try to make
> > use of ide drivers and see if I can reproduce it.
> > 
> 
> Hi Vivek, Jens,
> 
> Currently, If there's only the root cgroup and no other child cgroup available, io-controller will
> optimize to stop expiring the current ioq, and we thought the current ioq belongs to root group. But
> in some cases, this assumption is not true. Consider the following scenario, if there is a child cgroup
> located in root cgroup, and task A is running in the child cgroup, and task A issues some IOs. Then we
> kill task A and remove the child cgroup, at this time, there is only root cgroup available. But the ioq
> is still under service, and from now on, this ioq won't expire because "only root" optimization.
> The following patch ensures the ioq do belongs to the root group if there's only root group existing.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Hi Gui,

I have modified your patch a bit to improve readability. Looking at the
issue closely I realized that this optimization of not expiring the 
queue can lead to other issues like high vdisktime in certain scenarios.
While fixing that also noticed the issue of high rate of as queue
expiration in certain cases which could have been avoided. 

Here is a patch which should fix all that. I am still testing this patch
to make sure that something is not obiviously broken. Will merge it if
there are no issues.

Thanks
Vivek

o Fixed the issue of not expiring the queue for single ioq schedulers. Reported
  and fixed by Gui.

o If an AS queue is not expired for a long time and suddenly somebody
  decides to create a group and launch a job there, in that case old AS
  queue will be expired with a very high value of slice used and will get
  a very high disk time. Fix it by marking the queue as "charge_one_slice"
  and charge the queue only for a single time slice and not for whole
  of the duration when queue was running.

o There are cases where in case of AS, excessive queue expiration will take
  place by elevator fair queuing layer because of few reasons.
	- AS does not anticipate on a queue if there are no competing requests.
	  So if only a single reader is present in a group, anticipation does
	  not get turn on.

	- elevator layer does not know that As is anticipating hence initiates
	  expiry requests in select_ioq() thinking queue is empty.

	- elevaotr layer tries to aggressively expire last empty queue. This
	  can lead to lof of queue expiry

o This patch now starts ANITC_WAIT_NEXT anticipation if last request in the
  queue completed and associated io context is eligible to anticipate. Also
  AS lets elevatory layer know that it is anticipating (elv_ioq_wait_request())
  . This solves above mentioned issues.
 
o Moved some of the code in separate functions to improve readability.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/as-iosched.c  |   93 +++++++++++++++++++++++++++++---
 block/elevator-fq.c |  150 +++++++++++++++++++++++++++++++++++++++++-----------
 block/elevator-fq.h |    3 +
 3 files changed, 210 insertions(+), 36 deletions(-)

Index: linux18/block/elevator-fq.c
===================================================================
--- linux18.orig/block/elevator-fq.c	2009-09-14 15:45:58.000000000 -0400
+++ linux18/block/elevator-fq.c	2009-09-14 23:09:08.000000000 -0400
@@ -472,19 +472,18 @@ static inline void debug_entity_vdisktim
 					unsigned long served, u64 delta) {}
 #endif /* DEBUG_ELV_FAIR_QUEUING */
 
-static void
-entity_served(struct io_entity *entity, unsigned long served,
-				unsigned long nr_sectors)
+static void entity_served(struct io_entity *entity, unsigned long real_served,
+		unsigned long virtual_served, unsigned long nr_sectors)
 {
 	for_each_entity(entity) {
 		u64 delta;
 
-		delta = elv_delta_fair(served, entity);
+		delta = elv_delta_fair(virtual_served, entity);
 		entity->vdisktime += delta;
 		update_min_vdisktime(entity->st);
-		entity->total_time += served;
+		entity->total_time += real_served;
 		entity->total_sectors += nr_sectors;
-		debug_entity_vdisktime(entity, served, delta);
+		debug_entity_vdisktime(entity, virtual_served, delta);
 	}
 }
 
@@ -928,7 +927,24 @@ EXPORT_SYMBOL(elv_put_ioq);
 
 static void elv_ioq_served(struct io_queue *ioq, unsigned long served)
 {
-	entity_served(&ioq->entity, served, ioq->nr_sectors);
+
+	unsigned long virtual_served = served, allocated_slice;
+
+	/*
+	 * For single ioq schedulers we don't expire the queue if there are
+	 * no other competing groups. It might happen that once a queue has
+	 * not been expired for a long time, suddenly a new group is created
+	 * and IO comes in that new group. In that case, we don't want to
+	 * charge the old queue for whole of the period it was not expired.
+	 */
+	if (elv_ioq_charge_one_slice(ioq)) {
+		allocated_slice = elv_prio_to_slice(ioq->efqd, ioq);
+		if (served > allocated_slice)
+			virtual_served = allocated_slice;
+		elv_clear_ioq_charge_one_slice(ioq);
+	}
+
+	entity_served(&ioq->entity, served, virtual_served, ioq->nr_sectors);
 	elv_log_ioq(ioq->efqd, ioq, "ioq served: QSt=%lu QSs=%lu qued=%lu",
 			served, ioq->nr_sectors, ioq->nr_queued);
 	print_ioq_service_stats(ioq);
@@ -2543,6 +2559,22 @@ alloc_sched_q:
 		elv_init_ioq_io_group(ioq, iog);
 		elv_init_ioq_sched_queue(e, ioq, sched_q);
 
+		/*
+		 * For AS, also mark the group queue idle_window. This will
+		 * make sure that select_ioq() will not try to expire an
+		 * AS queue if there are dispatched request from the queue but
+		 * queue is empty. This gives a chance to asq to anticipate
+		 * after request completion, otherwise select_ioq() will
+		 * mark it must_expire and soon asq will be expired.
+		 *
+		 *  Not doing it for noop and deadline yet as they don't have
+		 *  any anticpation logic and this will slow down queue
+		 *  switching in a NCQ supporting hardware.
+		 */
+		if (!strcmp(e->elevator_type->elevator_name, "anticipatory")) {
+			elv_mark_ioq_idle_window(ioq);
+		}
+
 		elv_io_group_set_ioq(iog, ioq);
 		elv_mark_ioq_sync(ioq);
 		elv_get_iog(iog);
@@ -2664,6 +2696,12 @@ static inline int is_only_root_group(voi
 
 #endif /* CONFIG_GROUP_IOSCHED */
 
+static inline int ioq_is_idling(struct io_queue *ioq)
+{
+	return (elv_ioq_wait_request(ioq) ||
+			timer_pending(&ioq->efqd->idle_slice_timer));
+}
+
 /*
  * Should be called after ioq prio and class has been initialized as prio
  * class data will be used to determine which service tree in the group
@@ -2835,7 +2873,6 @@ elv_iosched_expire_ioq(struct request_qu
 		if (!ret)
 			elv_mark_ioq_must_expire(ioq);
 	}
-
 	return ret;
 }
 
@@ -3078,6 +3115,7 @@ void elv_ioq_request_add(struct request_
 		 */
 		if (group_wait_req || elv_ioq_wait_request(ioq)) {
 			del_timer(&efqd->idle_slice_timer);
+			elv_clear_ioq_wait_request(ioq);
 			if (blk_rq_bytes(rq) > PAGE_CACHE_SIZE ||
 			    efqd->busy_queues > 1 || !blk_queue_plugged(q))
 				__blk_run_queue(q);
@@ -3121,6 +3159,7 @@ static void elv_idle_slice_timer(unsigne
 	if (ioq) {
 		struct io_group *iog = ioq_to_io_group(ioq);
 
+		elv_clear_ioq_wait_request(ioq);
 		elv_clear_iog_wait_request(iog);
 
 		if (elv_iog_wait_busy(iog)) {
@@ -3222,6 +3261,28 @@ static inline struct io_queue *elv_close
 	return new_ioq;
 }
 
+/*
+ * One can do some optimizations for single ioq scheduler, when one does
+ * not have to expire the queue after every time slice is used. This avoids
+ * some unnecessary overhead, especially in AS where we wait for requests to
+ * finish from last queue before new queue is scheduled in.
+ */
+static inline int single_ioq_no_timed_expiry(struct request_queue *q)
+{
+	struct elv_fq_data *efqd = q->elevator->efqd;
+
+	if (!elv_iosched_single_ioq(q->elevator))
+		return 0;
+
+	if (!is_only_root_group())
+		return 0;
+
+	if (efqd->busy_queues == 1)
+		return 1;
+
+	return 0;
+}
+
 /* Common layer function to select the next queue to dispatch from */
 void *elv_select_ioq(struct request_queue *q, int force)
 {
@@ -3229,7 +3290,7 @@ void *elv_select_ioq(struct request_queu
 	struct io_queue *new_ioq = NULL, *ioq = elv_active_ioq(q->elevator);
 	struct io_group *iog;
  	struct elevator_type *e = q->elevator->elevator_type;
- 	int slice_expired = 1;
+ 	int slice_expired = 0;
 
 	if (!elv_nr_busy_ioq(q->elevator))
 		return NULL;
@@ -3255,16 +3316,20 @@ void *elv_select_ioq(struct request_queu
 	}
 
 	/* This queue has been marked for expiry. Try to expire it */
-	if (elv_ioq_must_expire(ioq))
+	if (elv_ioq_must_expire(ioq)) {
+		elv_log_ioq(efqd, ioq, "select: ioq must_expire. expire");
 		goto expire;
+	}
 
 	/*
 	 * If there is only root group present, don't expire the queue for
 	 * single queue ioschedulers (noop, deadline, AS).
 	 */
 
-	if (is_only_root_group() && elv_iosched_single_ioq(q->elevator))
+	if (single_ioq_no_timed_expiry(q)) {
+		elv_mark_ioq_charge_one_slice(ioq);
 		goto keep_queue;
+	}
 
 	/* We are waiting for this group to become busy before it expires.*/
 	if (elv_iog_wait_busy(iog)) {
@@ -3301,6 +3366,7 @@ void *elv_select_ioq(struct request_queu
 		 * from queue and is not proportional to group's weight, it
 		 * harms the fairness of the group.
 		 */
+		slice_expired = 1;
 		if (elv_iog_should_idle(ioq) && !elv_iog_wait_busy_done(iog)) {
 			ioq = NULL;
 			goto keep_queue;
@@ -3332,7 +3398,7 @@ void *elv_select_ioq(struct request_queu
 	 * conditions to happen (or time out) before selecting a new queue.
 	 */
 
-	if (timer_pending(&efqd->idle_slice_timer) ||
+	if (ioq_is_idling(ioq) ||
 	    (elv_ioq_nr_dispatched(ioq) && elv_ioq_idle_window(ioq))) {
 		ioq = NULL;
 		goto keep_queue;
@@ -3344,7 +3410,6 @@ void *elv_select_ioq(struct request_queu
 		goto keep_queue;
 	}
 
-	slice_expired = 0;
 expire:
  	if (efqd->fairness && !force && ioq && ioq->dispatched
  	    && strcmp(e->elevator_name, "anticipatory")) {
@@ -3439,6 +3504,43 @@ void elv_deactivate_rq_fair(struct reque
 						efqd->rq_in_driver);
 }
 
+/*
+ * if this is only queue and it has completed all its requests and has nothing
+ * to dispatch, expire it. We don't want to keep it around idle otherwise later
+ * when it is expired, all this idle time will be added to queue's disk time
+ * used and queue might not get a chance to run for a long time.
+ */
+static inline void
+check_expire_last_empty_queue(struct request_queue *q, struct io_queue *ioq)
+{
+	struct elv_fq_data *efqd = q->elevator->efqd;
+
+	if (efqd->busy_queues != 1)
+		return;
+
+	if (ioq->dispatched || ioq->nr_queued)
+		return;
+
+	/*
+	 * Anticipation is on. Don't expire queue. Either a new request will
+	 * come or it is up to io scheduler to expire the queue once idle
+	 * timer fires
+	 */
+
+	if(ioq_is_idling(ioq))
+		return;
+
+	/*
+	 * If IO scheduler denies expiration here, it is up to io scheduler
+	 * to expire the queue when possible. Otherwise all the idle time
+	 * will be charged to the queue when queue finally expires.
+	 */
+	if (elv_iosched_expire_ioq(q, 0, 0)) {
+		elv_log_ioq(efqd, ioq, "expire last empty queue");
+		elv_slice_expired(q);
+	}
+}
+
 /* A request got completed from io_queue. Do the accounting. */
 void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 {
@@ -3470,16 +3572,16 @@ void elv_ioq_completed_request(struct re
 			elv_set_prio_slice(q->elevator->efqd, ioq);
 			elv_clear_ioq_slice_new(ioq);
 		}
+
 		/*
 		 * If there is only root group present, don't expire the queue
 		 * for single queue ioschedulers (noop, deadline, AS). It is
 		 * unnecessary overhead.
 		 */
 
-		if (is_only_root_group() &&
-			elv_iosched_single_ioq(q->elevator)) {
-			elv_log_ioq(efqd, ioq, "select: only root group,"
-					" no expiry");
+		if (single_ioq_no_timed_expiry(q)) {
+			elv_mark_ioq_charge_one_slice(ioq);
+			elv_log_ioq(efqd, ioq, "single ioq no timed expiry");
 			goto done;
 		}
 
@@ -3519,7 +3621,7 @@ void elv_ioq_completed_request(struct re
 		 * decide to idle on queue, idle on group.
 		 */
 		if (elv_iog_should_idle(ioq) && !elv_ioq_nr_dispatched(ioq)
-		    && !timer_pending(&efqd->idle_slice_timer)) {
+		    && !ioq_is_idling(ioq)) {
 			/*
 			 * If queue has used up its slice, wait for the
 			 * one extra group_idle period to let the group
@@ -3532,17 +3634,7 @@ void elv_ioq_completed_request(struct re
 				elv_iog_arm_slice_timer(q, iog, 0);
 		}
 
-		/*
-		 * if this is only queue and it has completed all its requests
-		 * and has nothing to dispatch, expire it. We don't want to
-		 * keep it around idle otherwise later when it is expired, all
-		 * this idle time will be added to queue's disk time used.
-		 */
-		if (efqd->busy_queues == 1 && !ioq->dispatched &&
-		   !ioq->nr_queued && !timer_pending(&efqd->idle_slice_timer)) {
-			if (elv_iosched_expire_ioq(q, 0, 0))
-				elv_slice_expired(q);
-		}
+		check_expire_last_empty_queue(q, ioq);
 	}
 done:
 	if (!efqd->rq_in_driver)
Index: linux18/block/as-iosched.c
===================================================================
--- linux18.orig/block/as-iosched.c	2009-09-14 15:45:58.000000000 -0400
+++ linux18/block/as-iosched.c	2009-09-14 23:13:08.000000000 -0400
@@ -187,6 +187,24 @@ static void as_antic_stop(struct as_data
 static inline int as_batch_expired(struct as_data *ad, struct as_queue *asq);
 
 #ifdef CONFIG_IOSCHED_AS_HIER
+static int as_can_anticipate(struct as_data *ad, struct request *rq);
+static void as_antic_waitnext(struct as_data *ad);
+
+static inline void as_mark_active_asq_wait_request(struct as_data *ad)
+{
+	struct as_queue *asq = elv_active_sched_queue(ad->q->elevator);
+
+	elv_mark_ioq_wait_request(asq->ioq);
+}
+
+static inline void as_clear_active_asq_wait_request(struct as_data *ad)
+{
+	struct as_queue *asq = elv_active_sched_queue(ad->q->elevator);
+
+	if (asq)
+		elv_clear_ioq_wait_request(asq->ioq);
+}
+
 static void as_save_batch_context(struct as_data *ad, struct as_queue *asq)
 {
 	/* Save batch data dir */
@@ -279,6 +297,29 @@ static void as_active_ioq_set(struct req
 }
 
 /*
+ * AS does not anticipate on a context if there is no other request pending.
+ * So if only a single sequential reader was running, AS will not turn on
+ * anticipation. This function turns on anticipation if an io context has
+ * think time with-in limits and there are no other requests to dispatch.
+ *
+ * With group scheduling, a queue is expired if is empty, does not have a
+ * request dispatched and we are not idling. In case of this single reader
+ * we will see a queue expiration after every request completion. Hence turn
+ * on the anticipation if an io context should ancipate and there are no
+ * other requests queued in the queue.
+ */
+static inline void
+as_hier_check_start_waitnext(struct request_queue *q, struct as_queue *asq)
+{
+	struct as_data *ad = q->elevator->elevator_data;
+
+	if (!ad->nr_dispatched && !asq->nr_queued[1] && !asq->nr_queued[0] &&
+	    as_can_anticipate(ad, NULL)) {
+		as_antic_waitnext(ad);
+	}
+}
+
+/*
  * This is a notification from common layer that it wishes to expire this
  * io queue. AS decides whether queue can be expired, if yes, it also
  * saves the batch context.
@@ -325,13 +366,18 @@ static int as_expire_ioq(struct request_
 		goto keep_queue;
 
 	/*
-	 * If AS anticipation is ON, wait for it to finish.
+	 * If AS anticipation is ON, wait for it to finish if queue slice
+	 * has not expired.
 	 */
 	BUG_ON(status == ANTIC_WAIT_REQ);
 
-	if (status == ANTIC_WAIT_NEXT)
-		goto keep_queue;
-
+	if (status == ANTIC_WAIT_NEXT) {
+		if (!slice_expired)
+			goto keep_queue;
+		/* Slice expired. Stop anticipating. */
+		as_antic_stop(ad);
+		ad->antic_status = ANTIC_OFF;
+	}
 	/* We are good to expire the queue. Save batch context */
 	as_save_batch_context(ad, asq);
 	ad->switch_queue = 0;
@@ -342,6 +388,33 @@ keep_queue:
 	ad->switch_queue = 1;
 	return 0;
 }
+
+static inline void as_check_expire_active_as_queue(struct request_queue *q)
+{
+	struct as_data *ad = q->elevator->elevator_data;
+	struct as_queue *asq = elv_active_sched_queue(q->elevator);
+
+	/*
+	 * We anticpated on the queue and timer fired. If queue is empty,
+	 * expire the queue. This will make sure an idle queue does not
+	 * remain active for a very long time as later all the idle time
+	 * can be added to the queue disk usage.
+	 */
+	if (asq) {
+		if (!ad->nr_dispatched && !asq->nr_queued[1] &&
+		    !asq->nr_queued[0]) {
+			ad->switch_queue = 0;
+			elv_ioq_slice_expired(q, asq->ioq);
+		}
+	}
+}
+
+#else /* CONFIG_IOSCHED_AS_HIER */
+static inline void as_mark_active_asq_wait_request(struct as_data *ad) {}
+static inline void as_clear_active_asq_wait_request(struct as_data *ad) {}
+static inline void
+as_hier_check_start_waitnext(struct request_queue *q, struct as_queue *asq) {}
+static inline void as_check_expire_active_as_queue(struct request_queue *q) {}
 #endif
 
 /*
@@ -622,6 +695,7 @@ static void as_antic_waitnext(struct as_
 	mod_timer(&ad->antic_timer, timeout);
 
 	ad->antic_status = ANTIC_WAIT_NEXT;
+	as_mark_active_asq_wait_request(ad);
 	as_log(ad, "antic_waitnext set");
 }
 
@@ -656,6 +730,7 @@ static void as_antic_stop(struct as_data
 	if (status == ANTIC_WAIT_REQ || status == ANTIC_WAIT_NEXT) {
 		if (status == ANTIC_WAIT_NEXT)
 			del_timer(&ad->antic_timer);
+		as_clear_active_asq_wait_request(ad);
 		ad->antic_status = ANTIC_FINISHED;
 		/* see as_work_handler */
 		kblockd_schedule_work(ad->q, &ad->antic_work);
@@ -672,7 +747,7 @@ static void as_antic_timeout(unsigned lo
 	unsigned long flags;
 
 	spin_lock_irqsave(q->queue_lock, flags);
-	as_log(ad, "as_antic_timeout");
+	as_log(ad, "as_antic_timeout. antic_status=%d", ad->antic_status);
 	if (ad->antic_status == ANTIC_WAIT_REQ
 			|| ad->antic_status == ANTIC_WAIT_NEXT) {
 		struct as_io_context *aic;
@@ -680,6 +755,9 @@ static void as_antic_timeout(unsigned lo
 		aic = ad->io_context->aic;
 
 		ad->antic_status = ANTIC_FINISHED;
+
+		as_clear_active_asq_wait_request(ad);
+		as_check_expire_active_as_queue(q);
 		kblockd_schedule_work(q, &ad->antic_work);
 
 		if (aic->ttime_samples == 0) {
@@ -690,6 +768,7 @@ static void as_antic_timeout(unsigned lo
 			/* process not "saved" by a cooperating request */
 			ad->exit_no_coop = (7*ad->exit_no_coop + 256)/8;
 		}
+
 		spin_unlock(&ad->io_context->lock);
 	}
 	spin_unlock_irqrestore(q->queue_lock, flags);
@@ -1122,7 +1201,8 @@ static void as_completed_request(struct 
 			 * the next one
 			 */
 			as_antic_waitnext(ad);
-		}
+		} else
+			as_hier_check_start_waitnext(q, asq);
 	}
 
 	as_put_io_context(rq);
@@ -1471,7 +1551,6 @@ static void as_add_request(struct reques
 	data_dir = rq_is_sync(rq);
 
 	rq->elevator_private = as_get_io_context(q->node);
-
 	asq->nr_queued[data_dir]++;
 	as_log_asq(ad, asq, "add a %c request read_q=%d write_q=%d",
 			data_dir ? 'R' : 'W', asq->nr_queued[1],
Index: linux18/block/elevator-fq.h
===================================================================
--- linux18.orig/block/elevator-fq.h	2009-09-14 15:45:58.000000000 -0400
+++ linux18/block/elevator-fq.h	2009-09-14 15:50:04.000000000 -0400
@@ -264,6 +264,8 @@ enum elv_queue_state_flags {
 	ELV_QUEUE_FLAG_slice_new,	  /* no requests dispatched in slice */
 	ELV_QUEUE_FLAG_sync,              /* synchronous queue */
 	ELV_QUEUE_FLAG_must_expire,       /* expire queue even slice is left */
+	ELV_QUEUE_FLAG_charge_one_slice,  /* Charge the queue for only one
+					   * time slice length */
 };
 
 #define ELV_IO_QUEUE_FLAG_FNS(name)					\
@@ -287,6 +289,7 @@ ELV_IO_QUEUE_FLAG_FNS(idle_window)
 ELV_IO_QUEUE_FLAG_FNS(slice_new)
 ELV_IO_QUEUE_FLAG_FNS(sync)
 ELV_IO_QUEUE_FLAG_FNS(must_expire)
+ELV_IO_QUEUE_FLAG_FNS(charge_one_slice)
 
 #ifdef CONFIG_GROUP_IOSCHED
