From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Wed, 18 Mar 2009 17:55:29 -0400
Message-ID: <20090318215529.GA3338@redhat.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090312100054.GA8024@linux.vnet.ibm.com>
	<20090312140450.GE10919@redhat.com>
	<49C0A171.8060009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49C0A171.8060009-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Mar 18, 2009 at 03:23:29PM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> >> Hi Vivek,
> >>
> >> I would be interested in knowing if these are the results expected?
> >>
> > 
> > Hi Dhaval, 
> > 
> > Good question. Keeping current expectation in mind, yes these are expected
> > results. To begin with, current expectations are that try to emulate
> > cfq behavior and the kind of service differentiation we get between
> > threads of different priority, same kind of service differentiation we
> > should get from different cgroups.
> >  
> > Having said that, in theory a more accurate estimate should be amount 
> > of actual disk time a queue/cgroup got. I have put a tracing message
> > to keep track of total service received by a queue. If you run "blktrace"
> > then you can see that. Ideally, total service received by two threads
> > over a period of time should be in same proportion as their cgroup
> > weights.
> > 
> > It will not be easy to achive it given the constraints we have got in
> > terms of how to accurately we can account for disk time actually used by a
> > queue in certain situations. So to begin with I am targetting that
> > try to meet same kind of service differentation between cgroups as
> > cfq provides between threads and then slowly refine it to see how
> > close one can come to get accurate numbers in terms of "total_serivce"
> > received by each queue.
> 
>   Hi Vivek,
> 
>   I simply tested with blktrace opened. I create two groups and set ioprio
>   4 and 7 respectively(the corresponding weight should 4:1, right?),

Hi Gui,

Thanks for testing. You are right about weight proportions.

> and 
>   start two dd concurrently. UUIC, Ideally, the proportion of service two 
>   dd got should be 4:1 in a period of time when they are running. I extract 
>   *served* value from blktrace output and sum them up. I found the proportion 
>   of the sum of *served* value is about 1.7:1
>   Am i missing something?

Actually getting the service proportion in same ratio as weight proportion
is quite hard for sync queues. The biggest issue is that many a times sync
queues are not continuously backlogged and they do some IO and then dispatch
a next round of requests.

Most of the time idling seems to be the solution for giving an impression
that sync queue is continuously backlogged but it also has potential to
reduce throughput on faster hardware.

Anyway, can you please send me your complete blkparse output. There are
many a places where code has been designed to favor throughput than
fairness. Looking at your blkparse output, will give me better idea what's
the issue in your setup.

Also please try the attached patch. I have experimented with waiting for
new request to come before sync queue is expired. It helps me in getting
the fairness numbers at least with noop on non-queueing rotational media.

I also have introduced a new tunable "fairness". Above code will kick in
only if this variable is set to 1. Many a places where we favor throughput
over fairness, I plan to use this variable as condition to let user
decide whether to choose fairness over throughput. I am not sure at how many
places it really makes sense, but it atleast gives us something to play and
compare the throughput in two cases.

This patch applies on my current tree after removing tomost patceh
"anticipatory scheduling changes". My code has changed a bit since the
posting, so you might have to message this patch a bit.

Thanks
Vivek


DESC
io-controller: idle for sometime on sync queue before expiring it
EDESC 

o When a sync queue expires, in many cases it might be empty and then
  it will be deleted from the active tree. This will lead to a scenario
  where out of two competing queues, only one is on the tree and when a
  new queue is selected, vtime jump takes place and we don't see services
  provided in proportion to weight.

o In general this is a fundamental problem with fairness of sync queues
  where queues are not continuously backlogged. Looks like idling is
  only solution to make sure such kind of queues can get some decent amount
  of disk bandwidth in the face of competion from continusouly backlogged
  queues. But excessive idling has potential to reduce performance on SSD
  and disks with commnad queuing.

o This patch experiments with waiting for next request to come before a
  queue is expired after it has consumed its time slice. This can ensure
  more accurate fairness numbers in some cases.

o Introduced a tunable "fairness". If set, io-controller will put more
  focus on getting fairness right than getting throughput right. 


---
 block/blk-sysfs.c   |    7 ++++
 block/elevator-fq.c |   85 +++++++++++++++++++++++++++++++++++++++++++++-------
 block/elevator-fq.h |   12 +++++++
 3 files changed, 94 insertions(+), 10 deletions(-)

Index: linux1/block/elevator-fq.h
===================================================================
--- linux1.orig/block/elevator-fq.h	2009-03-18 17:34:46.000000000 -0400
+++ linux1/block/elevator-fq.h	2009-03-18 17:34:53.000000000 -0400
@@ -318,6 +318,13 @@ struct elv_fq_data {
 	unsigned long long rate_sampling_start; /*sampling window start jifies*/
 	/* number of sectors finished io during current sampling window */
 	unsigned long rate_sectors_current;
+
+	/*
+	 * If set to 1, will disable many optimizations done for boost
+	 * throughput and focus more on providing fairness for sync
+	 * queues.
+	 */
+	int fairness;
 };
 
 extern int elv_slice_idle;
@@ -340,6 +347,7 @@ enum elv_queue_state_flags {
 	ELV_QUEUE_FLAG_idle_window,	  /* elevator slice idling enabled */
 	ELV_QUEUE_FLAG_wait_request,	  /* waiting for a request */
 	ELV_QUEUE_FLAG_slice_new,	  /* no requests dispatched in slice */
+	ELV_QUEUE_FLAG_wait_busy,	  /* wait for this queue to get busy */
 	ELV_QUEUE_FLAG_NR,
 };
 
@@ -362,6 +370,7 @@ ELV_IO_QUEUE_FLAG_FNS(sync)
 ELV_IO_QUEUE_FLAG_FNS(wait_request)
 ELV_IO_QUEUE_FLAG_FNS(idle_window)
 ELV_IO_QUEUE_FLAG_FNS(slice_new)
+ELV_IO_QUEUE_FLAG_FNS(wait_busy)
 
 static inline struct io_service_tree *
 io_entity_service_tree(struct io_entity *entity)
@@ -554,6 +563,9 @@ static inline struct io_queue *elv_looku
 extern ssize_t elv_slice_idle_show(struct request_queue *q, char *name);
 extern ssize_t elv_slice_idle_store(struct request_queue *q, const char *name,
 						size_t count);
+extern ssize_t elv_fairness_show(struct request_queue *q, char *name);
+extern ssize_t elv_fairness_store(struct request_queue *q, const char *name,
+						size_t count);
 
 /* Functions used by elevator.c */
 extern int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e);
Index: linux1/block/elevator-fq.c
===================================================================
--- linux1.orig/block/elevator-fq.c	2009-03-18 17:34:46.000000000 -0400
+++ linux1/block/elevator-fq.c	2009-03-18 17:34:53.000000000 -0400
@@ -1837,6 +1837,44 @@ void elv_ioq_served(struct io_queue *ioq
 			ioq->total_service);
 }
 
+/* Functions to show and store fairness value through sysfs */
+ssize_t elv_fairness_show(struct request_queue *q, char *name)
+{
+	struct elv_fq_data *efqd;
+	unsigned int data;
+	unsigned long flags;
+
+	spin_lock_irqsave(q->queue_lock, flags);
+	efqd = &q->elevator->efqd;
+	data = efqd->fairness;
+	spin_unlock_irqrestore(q->queue_lock, flags);
+	return sprintf(name, "%d\n", data);
+}
+
+ssize_t elv_fairness_store(struct request_queue *q, const char *name,
+			  size_t count)
+{
+	struct elv_fq_data *efqd;
+	unsigned int data;
+	unsigned long flags;
+
+	char *p = (char *)name;
+
+	data = simple_strtoul(p, &p, 10);
+
+	if (data < 0)
+		data = 0;
+	else if (data > INT_MAX)
+		data = INT_MAX;
+
+	spin_lock_irqsave(q->queue_lock, flags);
+	efqd = &q->elevator->efqd;
+	efqd->fairness = data;
+	spin_unlock_irqrestore(q->queue_lock, flags);
+
+	return count;
+}
+
 /* Functions to show and store elv_idle_slice value through sysfs */
 ssize_t elv_slice_idle_show(struct request_queue *q, char *name)
 {
@@ -2263,10 +2301,11 @@ void __elv_ioq_slice_expired(struct requ
 	assert_spin_locked(q->queue_lock);
 	elv_log_ioq(efqd, ioq, "slice expired upd=%d", budget_update);
 
-	if (elv_ioq_wait_request(ioq))
+	if (elv_ioq_wait_request(ioq) || elv_ioq_wait_busy(ioq))
 		del_timer(&efqd->idle_slice_timer);
 
 	elv_clear_ioq_wait_request(ioq);
+	elv_clear_ioq_wait_busy(ioq);
 
 	/*
 	 * if ioq->slice_end = 0, that means a queue was expired before first
@@ -2482,8 +2521,9 @@ void elv_ioq_request_add(struct request_
 		 * immediately and flag that we must not expire this queue
 		 * just now
 		 */
-		if (elv_ioq_wait_request(ioq)) {
+		if (elv_ioq_wait_request(ioq) || elv_ioq_wait_busy(ioq)) {
 			del_timer(&efqd->idle_slice_timer);
+			elv_clear_ioq_wait_busy(ioq);
 			blk_start_queueing(q);
 		}
 	} else if (elv_should_preempt(q, ioq, rq)) {
@@ -2519,6 +2559,9 @@ void elv_idle_slice_timer(unsigned long 
 
 	if (ioq) {
 
+		if (elv_ioq_wait_busy(ioq))
+			goto expire;
+
 		/*
 		 * expired
 		 */
@@ -2546,7 +2589,7 @@ out_cont:
 	spin_unlock_irqrestore(q->queue_lock, flags);
 }
 
-void elv_ioq_arm_slice_timer(struct request_queue *q)
+void elv_ioq_arm_slice_timer(struct request_queue *q, int wait_for_busy)
 {
 	struct elv_fq_data *efqd = &q->elevator->efqd;
 	struct io_queue *ioq = elv_active_ioq(q->elevator);
@@ -2563,15 +2606,27 @@ void elv_ioq_arm_slice_timer(struct requ
 		return;
 
 	/*
-	 * still requests with the driver, don't idle
+	 * idle is disabled, either manually or by past process history
 	 */
-	if (efqd->rq_in_driver)
+	if (!efqd->elv_slice_idle || !elv_ioq_idle_window(ioq))
 		return;
 
 	/*
-	 * idle is disabled, either manually or by past process history
+	 * This queue has consumed its time slice. We are waiting only for
+	 * it to become busy before we select next queue for dispatch.
 	 */
-	if (!efqd->elv_slice_idle || !elv_ioq_idle_window(ioq))
+	if (efqd->fairness && wait_for_busy) {
+		elv_mark_ioq_wait_busy(ioq);
+		sl = efqd->elv_slice_idle;
+		mod_timer(&efqd->idle_slice_timer, jiffies + sl);
+		elv_log(efqd, "arm idle: %lu wait busy=1", sl);
+		return;
+	}
+
+	/*
+	 * still requests with the driver, don't idle
+	 */
+	if (efqd->rq_in_driver)
 		return;
 
 	/*
@@ -2628,6 +2683,12 @@ void *elv_fq_select_ioq(struct request_q
 		}
 	}
 
+	/* We are waiting for this queue to become busy before it expires.*/
+	if (efqd->fairness && elv_ioq_wait_busy(ioq)) {
+		ioq = NULL;
+		goto keep_queue;
+	}
+
 	/*
 	 * The active queue has run out of time, expire it and select new.
 	 */
@@ -2802,10 +2863,14 @@ void elv_ioq_completed_request(struct re
 			elv_ioq_set_prio_slice(q, ioq);
 			elv_clear_ioq_slice_new(ioq);
 		}
-		if (elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq))
+		if (elv_ioq_class_idle(ioq))
 			elv_ioq_slice_expired(q, 1);
-		else if (sync && !ioq->nr_queued)
-			elv_ioq_arm_slice_timer(q);
+		else if (sync && !ioq->nr_queued) {
+			if (elv_ioq_slice_used(ioq))
+				elv_ioq_arm_slice_timer(q, 1);
+			else
+				elv_ioq_arm_slice_timer(q, 0);
+		}
 	}
 
 	if (!efqd->rq_in_driver)
Index: linux1/block/blk-sysfs.c
===================================================================
--- linux1.orig/block/blk-sysfs.c	2009-03-18 17:34:28.000000000 -0400
+++ linux1/block/blk-sysfs.c	2009-03-18 17:34:53.000000000 -0400
@@ -282,6 +282,12 @@ static struct queue_sysfs_entry queue_sl
 	.show = elv_slice_idle_show,
 	.store = elv_slice_idle_store,
 };
+
+static struct queue_sysfs_entry queue_fairness_entry = {
+	.attr = {.name = "fairness", .mode = S_IRUGO | S_IWUSR },
+	.show = elv_fairness_show,
+	.store = elv_fairness_store,
+};
 #endif
 static struct attribute *default_attrs[] = {
 	&queue_requests_entry.attr,
@@ -296,6 +302,7 @@ static struct attribute *default_attrs[]
 	&queue_iostats_entry.attr,
 #ifdef CONFIG_ELV_FAIR_QUEUING
 	&queue_slice_idle_entry.attr,
+	&queue_fairness_entry.attr,
 #endif
 	NULL,
 };
