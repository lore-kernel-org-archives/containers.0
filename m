From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 20/20] io-controller: experimental debug patch for async queue
	wait before expiry
Date: Tue, 26 May 2009 18:42:09 -0400
Message-ID: <1243377729-2176-21-git-send-email-vgoyal__20034.6582722434$1243380734$gmane$org@redhat.com>
References: <1243377729-2176-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1243377729-2176-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
 block/blk-sysfs.c   |    7 +++++
 block/elevator-fq.c |   67 +++++++++++++++++++++++++++++++++++++++++++++++---
 block/elevator-fq.h |    7 +++++
 3 files changed, 77 insertions(+), 4 deletions(-)

diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index b60b76e..f245f33 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -314,6 +314,12 @@ static struct queue_sysfs_entry queue_slice_idle_entry = {
 	.store = elv_slice_idle_store,
 };
 
+static struct queue_sysfs_entry queue_async_slice_idle_entry = {
+	.attr = {.name = "async_slice_idle", .mode = S_IRUGO | S_IWUSR },
+	.show = elv_async_slice_idle_show,
+	.store = elv_async_slice_idle_store,
+};
+
 static struct queue_sysfs_entry queue_slice_sync_entry = {
 	.attr = {.name = "slice_sync", .mode = S_IRUGO | S_IWUSR },
 	.show = elv_slice_sync_show,
@@ -349,6 +355,7 @@ static struct attribute *default_attrs[] = {
 	&queue_iostats_entry.attr,
 #ifdef CONFIG_ELV_FAIR_QUEUING
 	&queue_slice_idle_entry.attr,
+	&queue_async_slice_idle_entry.attr,
 	&queue_slice_sync_entry.attr,
 	&queue_slice_async_entry.attr,
 	&queue_fairness_entry.attr,
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 6dd8683..f1179aa 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -20,6 +20,7 @@ const int elv_slice_sync = HZ / 10;
 int elv_slice_async = HZ / 25;
 const int elv_slice_async_rq = 2;
 int elv_slice_idle = HZ / 125;
+int elv_async_slice_idle = 0;
 static struct kmem_cache *elv_ioq_pool;
 
 /* Maximum Window length for updating average disk rate */
@@ -2677,6 +2678,46 @@ ssize_t elv_slice_idle_store(struct request_queue *q, const char *name,
 	return count;
 }
 
+/* Functions to show and store elv_idle_slice value through sysfs */
+ssize_t elv_async_slice_idle_show(struct request_queue *q, char *name)
+{
+	struct elv_fq_data *efqd;
+	unsigned int data;
+	unsigned long flags;
+
+	spin_lock_irqsave(q->queue_lock, flags);
+	efqd = &q->elevator->efqd;
+	data = jiffies_to_msecs(efqd->elv_async_slice_idle);
+	spin_unlock_irqrestore(q->queue_lock, flags);
+	return sprintf(name, "%d\n", data);
+}
+
+ssize_t elv_async_slice_idle_store(struct request_queue *q, const char *name,
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
+	data = msecs_to_jiffies(data);
+
+	spin_lock_irqsave(q->queue_lock, flags);
+	efqd = &q->elevator->efqd;
+	efqd->elv_async_slice_idle = data;
+	spin_unlock_irqrestore(q->queue_lock, flags);
+
+	return count;
+}
+
 /* Functions to show and store elv_slice_sync value through sysfs */
 ssize_t elv_slice_sync_show(struct request_queue *q, char *name)
 {
@@ -2930,8 +2971,10 @@ int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
 		ioq->pid = current->pid;
 
 	ioq->sched_queue = sched_queue;
-	if (elv_gen_idling_enabled(eq) && is_sync && !elv_ioq_class_idle(ioq))
-		elv_mark_ioq_idle_window(ioq);
+	if (elv_gen_idling_enabled(eq) && !elv_ioq_class_idle(ioq)) {
+		if (is_sync || efqd->fairness)
+			elv_mark_ioq_idle_window(ioq);
+	}
 	bfq_init_entity(&ioq->entity, iog);
 	ioq->entity.budget = elv_prio_to_slice(efqd, ioq);
 	return 0;
@@ -3563,7 +3606,12 @@ void elv_ioq_arm_slice_timer(struct request_queue *q, int wait_for_busy)
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
@@ -3572,7 +3620,10 @@ void elv_ioq_arm_slice_timer(struct request_queue *q, int wait_for_busy)
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
@@ -3913,6 +3964,13 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
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
@@ -4042,6 +4100,7 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 	efqd->elv_slice[0] = elv_slice_async;
 	efqd->elv_slice[1] = elv_slice_sync;
 	efqd->elv_slice_idle = elv_slice_idle;
+	efqd->elv_async_slice_idle = elv_async_slice_idle;
 	efqd->hw_tag = 1;
 
 	/* For the time being keep fairness enabled by default */
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index de0f6b0..1c99e83 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -339,6 +339,8 @@ struct elv_fq_data {
 	 * users of this functionality.
 	 */
 	unsigned int elv_slice_idle;
+	/* idle slice for async queue */
+	unsigned int elv_async_slice_idle;
 	struct timer_list idle_slice_timer;
 	struct work_struct unplug_work;
 
@@ -665,6 +667,11 @@ extern ssize_t elv_slice_idle_store(struct request_queue *q, const char *name,
 extern ssize_t elv_slice_sync_show(struct request_queue *q, char *name);
 extern ssize_t elv_slice_sync_store(struct request_queue *q, const char *name,
 						size_t count);
+
+extern ssize_t elv_async_slice_idle_show(struct request_queue *q, char *name);
+extern ssize_t elv_async_slice_idle_store(struct request_queue *q,
+					const char *name, size_t count);
+
 extern ssize_t elv_slice_async_show(struct request_queue *q, char *name);
 extern ssize_t elv_slice_async_store(struct request_queue *q, const char *name,
 						size_t count);
-- 
1.6.0.1
