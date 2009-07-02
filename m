From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 25/25] io-controller: experimental debug patch for async queue
	wait before expiry
Date: Thu,  2 Jul 2009 16:01:57 -0400
Message-ID: <1246564917-19603-26-git-send-email-vgoyal__39403.0214091346$1246567308$gmane$org@redhat.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246564917-19603-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

o A debug patch which does wait for next IO from async queue once it
  becomes empty.

o For async writes, traffic seen by IO scheduler is not in proportion to
  the weight of the cgroup task/page belongs to. So if there are two processes
  doing heavy writeouts in two cgroups with weights 1000 and 500 respectively,
  then IO scheduler does not see more traffic/IO from higher weight cgroup
  even if IO scheduler tries to give it higher disk time. Effectively, the
  async queue belonging to higher weight cgroup becomes empty, and gets out
  of contention for disk and lower weight cgroup gets to use disk giving
  an impression in user space that higher weight cgroup did not get higher
  time to disk.

o This is more of a problem at page cache level where a higher weight
  process might be writing out the pages of lower weight process etc and
  should be fixed there.

o While we fix those issues, introducing this debug patch which allows one
  to idle on async queue (tunable via /sys/blolc/<disk>/queue/async_slice_idle)  so that once a higher weight queue becomes empty, instead of expiring it
  we try to wait for next request to come from that queue hence giving it
  higher disk time. A higher value of async_slice_idle, around 300ms, helps
  me get some right numbers for my setup. Note: higher disk time would not
  necessarily translate in more IO done as higher weight group is not pushing
  enough IO to io scheduler. It is just a debugging aid to prove correctness
  of IO controller by providing higher disk times to higher weight cgroup.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/cfq-iosched.c |    1 +
 block/elevator-fq.c |   39 ++++++++++++++++++++++++++++++++++++---
 block/elevator-fq.h |    5 +++++
 3 files changed, 42 insertions(+), 3 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index a40a2fa..fbe56a9 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -2093,6 +2093,7 @@ static struct elv_fs_entry cfq_attrs[] = {
 	ELV_ATTR(slice_sync),
 	ELV_ATTR(slice_async),
 	ELV_ATTR(fairness),
+	ELV_ATTR(async_slice_idle),
 	__ATTR_NULL
 };
 
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 5b3f068..7c83d1e 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -24,6 +24,7 @@ const int elv_slice_sync = HZ / 10;
 int elv_slice_async = HZ / 25;
 const int elv_slice_async_rq = 2;
 int elv_slice_idle = HZ / 125;
+int elv_async_slice_idle = 0;
 static struct kmem_cache *elv_ioq_pool;
 
 /* Maximum Window length for updating average disk rate */
@@ -2819,6 +2820,8 @@ SHOW_FUNCTION(elv_slice_async_show, efqd->elv_slice[0], 1);
 EXPORT_SYMBOL(elv_slice_async_show);
 SHOW_FUNCTION(elv_fairness_show, efqd->fairness, 0);
 EXPORT_SYMBOL(elv_fairness_show);
+SHOW_FUNCTION(elv_async_slice_idle_show, efqd->elv_async_slice_idle, 1);
+EXPORT_SYMBOL(elv_async_slice_idle_show);
 #undef SHOW_FUNCTION
 
 #define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
@@ -2845,6 +2848,8 @@ STORE_FUNCTION(elv_slice_async_store, &efqd->elv_slice[0], 1, UINT_MAX, 1);
 EXPORT_SYMBOL(elv_slice_async_store);
 STORE_FUNCTION(elv_fairness_store, &efqd->fairness, 0, 2, 0);
 EXPORT_SYMBOL(elv_fairness_store);
+STORE_FUNCTION(elv_async_slice_idle_store, &efqd->elv_async_slice_idle, 0, UINT_MAX, 1);
+EXPORT_SYMBOL(elv_async_slice_idle_store);
 #undef STORE_FUNCTION
 
 void elv_schedule_dispatch(struct request_queue *q)
@@ -3018,7 +3023,7 @@ int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
 		ioq->pid = current->pid;
 
 	ioq->sched_queue = sched_queue;
-	if (is_sync && !elv_ioq_class_idle(ioq))
+	if (!elv_ioq_class_idle(ioq) && (is_sync || efqd->fairness))
 		elv_mark_ioq_idle_window(ioq);
 	bfq_init_entity(&ioq->entity, iog);
 	ioq->entity.budget = elv_prio_to_slice(efqd, ioq);
@@ -3699,7 +3704,12 @@ static void elv_ioq_arm_slice_timer(struct request_queue *q, int wait_for_busy)
 	/*
 	 * idle is disabled, either manually or by past process history
 	 */
-	if (!efqd->elv_slice_idle || !elv_ioq_idle_window(ioq))
+	if ((elv_ioq_sync(ioq) && !efqd->elv_slice_idle) ||
+			!elv_ioq_idle_window(ioq))
+		return;
+
+	/* If this is async queue and async_slice_idle is disabled, return */
+	if (!elv_ioq_sync(ioq) && !efqd->elv_async_slice_idle)
 		return;
 
 	/*
@@ -3708,7 +3718,10 @@ static void elv_ioq_arm_slice_timer(struct request_queue *q, int wait_for_busy)
 	 */
 	if (wait_for_busy) {
 		elv_mark_ioq_wait_busy(ioq);
-		sl = efqd->elv_slice_idle;
+		if (elv_ioq_sync(ioq))
+			sl = efqd->elv_slice_idle;
+		else
+			sl = efqd->elv_async_slice_idle;
 		mod_timer(&efqd->idle_slice_timer, jiffies + sl);
 		elv_log_ioq(efqd, ioq, "arm idle: %lu wait busy=1", sl);
 		return;
@@ -3882,6 +3895,18 @@ void *elv_fq_select_ioq(struct request_queue *q, int force)
 		goto keep_queue;
 	}
 
+	/*
+	 * If this is an async queue which has time slice left but not
+	 * requests. Wait busy is also not on (may be because when last
+	 * request completed, ioq was not empty). Wait for the request
+	 * completion. May be completion will turn wait busy on.
+	 */
+	if (efqd->fairness && efqd->elv_async_slice_idle && !elv_ioq_sync(ioq)
+	    && elv_ioq_nr_dispatched(ioq)) {
+		ioq = NULL;
+		goto keep_queue;
+	}
+
 	slice_expired = 0;
 expire:
 	if (efqd->fairness >= 2 && !force && ioq && ioq->dispatched
@@ -4076,6 +4101,13 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 			goto done;
 		}
 
+		/* For async queue try to do wait busy */
+		if (efqd->fairness && !elv_ioq_sync(ioq) && !ioq->nr_queued
+		    && (elv_iog_nr_active(iog) <= 1)) {
+			elv_ioq_arm_slice_timer(q, 1);
+			goto done;
+		}
+
 		/*
 		 * If there are no requests waiting in this queue, and
 		 * there are other queues ready to issue requests, AND
@@ -4215,6 +4247,7 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 	efqd->elv_slice[0] = elv_slice_async;
 	efqd->elv_slice[1] = elv_slice_sync;
 	efqd->elv_slice_idle = elv_slice_idle;
+	efqd->elv_async_slice_idle = elv_async_slice_idle;
 	efqd->hw_tag = 1;
 
 	/* For the time being keep fairness enabled by default */
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 19ac8ca..f089a55 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -362,6 +362,8 @@ struct elv_fq_data {
 	 * users of this functionality.
 	 */
 	unsigned int elv_slice_idle;
+	/* idle slice for async queue */
+	unsigned int elv_async_slice_idle;
 	struct timer_list idle_slice_timer;
 	struct work_struct unplug_work;
 
@@ -647,6 +649,9 @@ extern ssize_t elv_slice_async_store(struct elevator_queue *q, const char *name,
 extern ssize_t elv_fairness_show(struct elevator_queue *q, char *name);
 extern ssize_t elv_fairness_store(struct elevator_queue *q, const char *name,
 						size_t count);
+extern ssize_t elv_async_slice_idle_show(struct elevator_queue *q, char *name);
+extern ssize_t elv_async_slice_idle_store(struct elevator_queue *q,
+					const char *name, size_t count);
 
 /* Functions used by elevator.c */
 extern int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e);
-- 
1.6.0.6
