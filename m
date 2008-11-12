From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: [PATCH][cfq-cgroups][11/12] Expand idle slice timer function.
Date: Wed, 12 Nov 2008 17:31:05 +0900
Message-ID: <001801c944a1$011b0060$03510120$__42549.2214541466$1226480875$gmane$org@jp.nec.com>
References: <000c01c9449e$c5bcdc20$51369460$@jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <000c01c9449e$c5bcdc20$51369460$@jp.nec.com>
Content-Language: ja
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, 'Ryo Tsuruta' <ryov@valin>
Cc: 'Andrew Morton' <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, 'SUGAWARA Tomoyoshi' <tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


  This patch expandes function of idle slice timer.


    Signed-off-by: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>

---
 block/cfq-cgroup.c          |   45 +++++++++++++++++++++++++++++++++++++++++++
 block/cfq-iosched.c         |   29 ++++++++++++++++++++++-----
 include/linux/cfq-iosched.h |    3 ++
 3 files changed, 71 insertions(+), 6 deletions(-)

diff --git a/block/cfq-cgroup.c b/block/cfq-cgroup.c
index f3e9f40..4938fa0 100644
--- a/block/cfq-cgroup.c
+++ b/block/cfq-cgroup.c
@@ -69,9 +69,16 @@ static inline struct cfq_cgroup *task_to_cfq_cgroup(struct task_struct *tsk)
 /*
  * Add device or cgroup data functions.
  */
+static void cfq_cgroup_idle_slice_timer(unsigned long data);
+
 static void cfq_cgroup_init_driver_data_opt(struct cfq_driver_data *cfqdd,
 					      struct cfq_data *cfqd)
 {
+	cfqdd->elv_data = cfqd;
+
+	cfqdd->idle_slice_timer.function = cfq_cgroup_idle_slice_timer;
+	cfqdd->idle_slice_timer.data = (unsigned long) cfqdd;
+
 	cfqdd->sibling_tree = RB_ROOT;
 	cfqdd->siblings = 0;
 
@@ -623,6 +630,44 @@ static int cfq_cgroup_is_active_data(struct cfq_data *cfqd)
 
 
 /*
+ * Timer running if the active_queue is currently idling inside its time slice
+ */
+static void cfq_cgroup_idle_slice_timer(unsigned long data)
+{
+	struct cfq_driver_data *cfqdd = (struct cfq_driver_data *) data;
+	struct cfq_data *cfqd;
+	int timed_out = 1;
+	unsigned long flags;
+
+	spin_lock_irqsave(cfqdd->queue->queue_lock, flags);
+
+	cfqd = cfqdd->active_data;
+	if (cfqd) {
+		timed_out = 0;
+
+		if (cfq_cgroup_slice_used(cfqd))
+			goto expire_cgroup;
+
+		if (!cfqdd->busy_data)
+			goto out_cont;
+
+		if (__cfq_idle_slice_timer(cfqd))
+			goto out_cont;
+		else
+			goto out_kick;
+
+	}
+expire_cgroup:
+	cfq_cgroup_slice_expired(cfqdd, timed_out);
+out_kick:
+	cfq_schedule_dispatch(cfqdd->elv_data);
+out_cont:
+	spin_unlock_irqrestore(cfqdd->queue->queue_lock,
+			       flags);
+}
+
+
+/*
  * cgroupfs parts below -->
  */
 static void
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 5fe0551..edc23e5 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -2122,18 +2122,13 @@ static void cfq_kick_queue(struct work_struct *work)
 /*
  * Timer running if the active_queue is currently idling inside its time slice
  */
-static void cfq_idle_slice_timer(unsigned long data)
+inline int __cfq_idle_slice_timer(struct cfq_data *cfqd)
 {
-	struct cfq_data *cfqd = (struct cfq_data *) data;
 	struct cfq_queue *cfqq;
-	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
-	unsigned long flags;
 	int timed_out = 1;
 
 	cfq_log(cfqd, "idle timer fired");
 
-	spin_lock_irqsave(cfqdd->queue->queue_lock, flags);
-
 	cfqq = cfqd->active_queue;
 	if (cfqq) {
 		timed_out = 0;
@@ -2163,7 +2158,21 @@ expire:
 	cfq_slice_expired(cfqd, timed_out);
 out_kick:
 	cfq_schedule_dispatch(cfqd);
+	return 1;
 out_cont:
+	return 0;
+}
+
+static void cfq_idle_slice_timer(unsigned long data)
+{
+	struct cfq_data *cfqd = (struct cfq_data *) data;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
+	unsigned long flags;
+
+	spin_lock_irqsave(cfqdd->queue->queue_lock, flags);
+
+	__cfq_idle_slice_timer(cfqd);
+
 	spin_unlock_irqrestore(cfqdd->queue->queue_lock, flags);
 }
 
@@ -2226,6 +2235,13 @@ static void cfq_exit_queue(elevator_t *e)
 	kfree(cfqdd);
 }
 
+static void
+cfq_init_driver_data_opt(struct cfq_driver_data *cfqdd, struct cfq_data *cfqd)
+{
+	cfqdd->idle_slice_timer.function = cfq_idle_slice_timer;
+	cfqdd->idle_slice_timer.data = (unsigned long) cfqd;
+}
+
 static struct cfq_driver_data *
 cfq_init_driver_data(struct request_queue *q, struct cfq_data *cfqd,
 			struct cfq_ops *op)
@@ -2441,6 +2457,7 @@ struct elevator_type iosched_cfq = {
 };
 
 static struct cfq_ops cfq_op = {
+	.cfq_init_driver_data_opt_fn = cfq_init_driver_data_opt,
 };
 
 static int __init cfq_init(void)
diff --git a/include/linux/cfq-iosched.h b/include/linux/cfq-iosched.h
index 7287186..920bcb5 100644
--- a/include/linux/cfq-iosched.h
+++ b/include/linux/cfq-iosched.h
@@ -24,6 +24,7 @@ struct cfq_rb_root {
  * Driver unique data structure
  */
 struct cfq_driver_data {
+	struct cfq_data *elv_data;
 	struct request_queue *queue;
 
 	int rq_in_driver;
@@ -156,5 +157,7 @@ extern void cfq_slice_expired(struct cfq_data *, int);
 extern int wait_request_checker(struct cfq_data *cfqd);
 extern int cfq_forced_dispatch(struct cfq_data *);
 extern int cfq_queue_dispatch_requests(struct cfq_data *, int);
+extern int __cfq_idle_slice_timer(struct cfq_data *cfqd);
+extern void cfq_schedule_dispatch(struct cfq_data *cfqd);
 
 #endif  /* _LINUX_CFQ_IOSCHED_H */
-- 
1.5.6.5
