From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: [PATCH][cfq-cgroups][06/12] Add siblings tree control for driver
	data(cfq_driver_data).
Date: Wed, 12 Nov 2008 17:27:40 +0900
Message-ID: <001301c944a0$869ef3f0$93dcdbd0$__18220.2008589686$1226480243$gmane$org@jp.nec.com>
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


  This patch adds a tree control for siblings of driver data(cfq_driver_data).
  This tree controls cfq data(cfq_data) for same device, and is used mainly 
  when a new device is registered or a existed device is unregistered.


    Signed-off-by: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>

---
 block/cfq-cgroup.c          |  114 +++++++++++++++++++++++++++++++++++++++++++
 block/cfq-iosched.c         |   50 +++++++++++++++---
 include/linux/cfq-iosched.h |   27 ++++++++++
 3 files changed, 182 insertions(+), 9 deletions(-)

diff --git a/block/cfq-cgroup.c b/block/cfq-cgroup.c
index 733980d..ce35af2 100644
--- a/block/cfq-cgroup.c
+++ b/block/cfq-cgroup.c
@@ -17,6 +17,7 @@
 
 #define CFQ_CGROUP_MAX_IOPRIO		(7)
 
+static struct cfq_ops cfq_cgroup_op;
 
 struct cfq_cgroup {
 	struct cgroup_subsys_state css;
@@ -36,6 +37,70 @@ static inline struct cfq_cgroup *task_to_cfq_cgroup(struct task_struct *tsk)
 }
 
 
+/*
+ * Add device or cgroup data functions.
+ */
+static void cfq_cgroup_init_driver_data_opt(struct cfq_driver_data *cfqdd,
+					      struct cfq_data *cfqd)
+{
+	cfqdd->sibling_tree = RB_ROOT;
+	cfqdd->siblings = 0;
+}
+
+static void cfq_driver_sibling_tree_add(struct cfq_driver_data *cfqdd,
+					     struct cfq_data *cfqd)
+{
+	struct rb_node **p;
+	struct rb_node *parent = NULL;
+
+	BUG_ON(!RB_EMPTY_NODE(&cfqd->sib_node));
+
+	p = &cfqdd->sibling_tree.rb_node;
+
+	while (*p) {
+		struct cfq_data *__cfqd;
+		struct rb_node **n;
+
+		parent = *p;
+		__cfqd = rb_entry(parent, struct cfq_data, sib_node);
+
+		if (cfqd < __cfqd)
+			n = &(*p)->rb_left;
+		else
+			n = &(*p)->rb_right;
+		p = n;
+	}
+
+	rb_link_node(&cfqd->sib_node, parent, p);
+	rb_insert_color(&cfqd->sib_node, &cfqdd->sibling_tree);
+	cfqdd->siblings++;
+	cfqd->cfqdd = cfqdd;
+}
+
+static struct cfq_data *
+__cfq_cgroup_init_queue(struct request_queue *q, struct cfq_driver_data *cfqdd)
+{
+	struct cfq_data *cfqd = cfq_init_cfq_data(q, cfqdd, &cfq_cgroup_op);
+
+	if (!cfqd)
+		return NULL;
+
+	RB_CLEAR_NODE(&cfqd->sib_node);
+
+	cfq_driver_sibling_tree_add(cfqd->cfqdd, cfqd);
+
+	return cfqd;
+}
+
+static void *cfq_cgroup_init_queue(struct request_queue *q)
+{
+	struct cfq_data *cfqd = NULL;
+
+	cfqd = __cfq_cgroup_init_queue(q, NULL);
+
+	return cfqd;
+}
+
 static struct cgroup_subsys_state *
 cfq_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
@@ -56,11 +121,53 @@ cfq_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	return &cfqc->css;
 }
 
+
+/*
+ * Remove device or cgroup data functions.
+ */
+static void cfq_cgroup_erase_driver_siblings(struct cfq_driver_data *cfqdd,
+						 struct cfq_data *cfqd)
+{
+	rb_erase(&cfqd->sib_node, &cfqdd->sibling_tree);
+	cfqdd->siblings--;
+}
+
+static void cfq_exit_device_group(struct cfq_driver_data *cfqdd)
+{
+	struct rb_node *p, *n;
+	struct cfq_data *cfqd;
+
+	p =  rb_first(&cfqdd->sibling_tree);
+
+	while (p) {
+		n = rb_next(p);
+		cfqd = rb_entry(p, struct cfq_data, sib_node);
+
+		cfq_cgroup_erase_driver_siblings(cfqdd, cfqd);
+		cfq_free_cfq_data(cfqd);
+
+		p = n;
+	}
+}
+
+static void cfq_cgroup_exit_queue(elevator_t *e)
+{
+	struct cfq_data *cfqd = e->elevator_data;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
+
+	cfq_exit_device_group(cfqdd);
+	kfree(cfqdd);
+}
+
 static void cfq_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
 {
 	kfree(cgroup_to_cfq_cgroup(cont));
 }
 
+
+/*
+ * cgroupfs parts below -->
+ */
 static ssize_t cfq_cgroup_read(struct cgroup *cont, struct cftype *cft,
 			       struct file *file, char __user *userbuf,
 			       size_t nbytes, loff_t *ppos)
@@ -154,6 +261,7 @@ static int cfq_cgroup_populate(struct cgroup_subsys *ss, struct cgroup *cont)
 	return cgroup_add_files(cont, ss, files, ARRAY_SIZE(files));
 }
 
+
 struct cgroup_subsys cfq_subsys = {
 	.name = "cfq",
 	.create = cfq_cgroup_create,
@@ -280,9 +388,15 @@ static struct elevator_type iosched_cfq_cgroup = {
 	.elevator_owner	= THIS_MODULE,
 };
 
+static struct cfq_ops cfq_cgroup_op = {
+	.cfq_init_driver_data_opt_fn	= cfq_cgroup_init_driver_data_opt,
+};
+
 static int __init cfq_cgroup_init(void)
 {
 	iosched_cfq_cgroup.ops = iosched_cfq.ops;
+	iosched_cfq_cgroup.ops.elevator_init_fn = cfq_cgroup_init_queue;
+	iosched_cfq_cgroup.ops.elevator_exit_fn = cfq_cgroup_exit_queue;
 
 	elv_register(&iosched_cfq_cgroup);
 
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index e105827..fd1ed0c 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -62,6 +62,8 @@ static DEFINE_SPINLOCK(ioc_gone_lock);
 
 #define sample_valid(samples)	((samples) > 80)
 
+static struct cfq_ops cfq_op;
+
 /*
  * Per process-grouping structure
  */
@@ -2133,9 +2135,8 @@ static void cfq_put_async_queues(struct cfq_data *cfqd)
 		cfq_put_queue(cfqd->async_idle_cfqq);
 }
 
-static void cfq_exit_queue(elevator_t *e)
+void cfq_free_cfq_data(struct cfq_data *cfqd)
 {
-	struct cfq_data *cfqd = e->elevator_data;
 	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 	struct request_queue *q = cfqdd->queue;
 
@@ -2160,12 +2161,21 @@ static void cfq_exit_queue(elevator_t *e)
 
 	cfq_shutdown_timer_wq(cfqdd);
 
-	kfree(cfqdd);
 	kfree(cfqd);
 }
 
+static void cfq_exit_queue(elevator_t *e)
+{
+	struct cfq_data *cfqd = e->elevator_data;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
+
+	cfq_free_cfq_data(cfqd);
+	kfree(cfqdd);
+}
+
 static struct cfq_driver_data *
-cfq_init_driver_data(struct request_queue *q, struct cfq_data *cfqd)
+cfq_init_driver_data(struct request_queue *q, struct cfq_data *cfqd,
+			struct cfq_ops *op)
 {
 	struct cfq_driver_data *cfqdd;
 
@@ -2186,10 +2196,16 @@ cfq_init_driver_data(struct request_queue *q, struct cfq_data *cfqd)
 
 	cfqdd->hw_tag = 1;
 
+	/* module dependend initialization */
+	cfqdd->op = op;
+	if (op->cfq_init_driver_data_opt_fn)
+		op->cfq_init_driver_data_opt_fn(cfqdd, cfqd);
+
 	return cfqdd;
 }
 
-static void *cfq_init_queue(struct request_queue *q)
+struct cfq_data *cfq_init_cfq_data(struct request_queue *q,
+			struct cfq_driver_data *cfqdd, struct cfq_ops *op)
 {
 	struct cfq_data *cfqd;
 
@@ -2197,10 +2213,14 @@ static void *cfq_init_queue(struct request_queue *q)
 	if (!cfqd)
 		return NULL;
 
-	cfqd->cfqdd = cfq_init_driver_data(q, cfqd);
-	if (!cfqd->cfqdd) {
-		kfree(cfqd);
-		return NULL;
+	if (cfqdd)
+		cfqd->cfqdd = cfqdd;
+	else {
+		cfqd->cfqdd = cfq_init_driver_data(q, cfqd, op);
+		if (!cfqd->cfqdd) {
+			kfree(cfqd);
+			return NULL;
+		}
 	}
 
 	cfqd->service_tree = CFQ_RB_ROOT;
@@ -2219,6 +2239,15 @@ static void *cfq_init_queue(struct request_queue *q)
 	return cfqd;
 }
 
+static void *cfq_init_queue(struct request_queue *q)
+{
+	struct cfq_data *cfqd = NULL;
+
+	cfqd = cfq_init_cfq_data(q, NULL, &cfq_op);
+
+	return cfqd;
+}
+
 static void cfq_slab_kill(void)
 {
 	/*
@@ -2358,6 +2387,9 @@ struct elevator_type iosched_cfq = {
 	.elevator_owner =	THIS_MODULE,
 };
 
+static struct cfq_ops cfq_op = {
+};
+
 static int __init cfq_init(void)
 {
 	/*
diff --git a/include/linux/cfq-iosched.h b/include/linux/cfq-iosched.h
index a28ef00..22d1aed 100644
--- a/include/linux/cfq-iosched.h
+++ b/include/linux/cfq-iosched.h
@@ -6,6 +6,7 @@
 
 struct request_queue;
 struct cfq_io_context;
+struct cfq_ops;
 
 /*
  * Most of our rbtree usage is for sorting with min extraction, so
@@ -46,6 +47,14 @@ struct cfq_driver_data {
 
 	sector_t last_position;
 	unsigned long last_end_request;
+
+	struct cfq_ops *op;
+
+#ifdef CONFIG_IOSCHED_CFQ_CGROUP
+	/* device siblings */
+	struct rb_root sibling_tree;
+	unsigned int siblings;
+#endif
 };
 
 /*
@@ -80,8 +89,26 @@ struct cfq_data {
 	struct list_head cic_list;
 
 	struct cfq_driver_data *cfqdd;
+
+#ifdef CONFIG_IOSCHED_CFQ_CGROUP
+	/* sibling_tree member for cfq_meta_data */
+	struct rb_node sib_node;
+#endif
+};
+
+/*
+ * Module depended optional operations.
+ */
+typedef void (cfq_init_driver_data_opt_fn)(struct cfq_driver_data *,
+						struct cfq_data *);
+struct cfq_ops {
+	cfq_init_driver_data_opt_fn *cfq_init_driver_data_opt_fn;
 };
 
+
 extern struct elevator_type iosched_cfq;
+extern struct cfq_data *cfq_init_cfq_data(struct request_queue *,
+				struct cfq_driver_data *, struct cfq_ops *);
+extern void cfq_free_cfq_data(struct cfq_data *cfqd);
 
 #endif  /* _LINUX_CFQ_IOSCHED_H */
-- 
1.5.6.5
