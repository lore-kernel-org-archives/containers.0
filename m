From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: [PATCH][cfq-cgroups][09/12] Develop service tree control.
Date: Wed, 12 Nov 2008 17:29:37 +0900
Message-ID: <001601c944a0$ccb01e00$66105a00$__23795.1888856061$1226480836$gmane$org@jp.nec.com>
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


  This patch introduces and controls a service tree for cfq data, namely
  group layer control.
  This functions expand IPRIO_BE class section of traditional CFQ scheduler.


    Signed-off-by: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>

---
 block/cfq-cgroup.c          |  266 +++++++++++++++++++++++++++++++++++++++++++
 block/cfq-iosched.c         |   32 ++++-
 include/linux/cfq-iosched.h |   32 +++++-
 3 files changed, 323 insertions(+), 7 deletions(-)

diff --git a/block/cfq-cgroup.c b/block/cfq-cgroup.c
index 99f3d94..ff652fe 100644
--- a/block/cfq-cgroup.c
+++ b/block/cfq-cgroup.c
@@ -15,8 +15,11 @@
 #include <linux/cgroup.h>
 #include <linux/cfq-iosched.h>
 
+#define CFQ_CGROUP_SLICE_SCALE		(5)
 #define CFQ_CGROUP_MAX_IOPRIO		(7)
 
+static const int cfq_cgroup_slice = HZ / 10;
+
 static struct cfq_ops cfq_cgroup_op;
 
 struct cfq_cgroup {
@@ -27,6 +30,28 @@ struct cfq_cgroup {
 	unsigned int siblings;
 };
 
+enum cfqd_state_flags {
+	CFQ_CFQD_FLAG_on_rr = 0,	/* on round-robin busy list */
+	CFQ_CFQD_FLAG_slice_new,	/* no requests dispatched in slice */
+};
+
+#define CFQ_CFQD_FNS(name)						\
+static inline void cfq_mark_cfqd_##name(struct cfq_data *cfqd)		\
+{									\
+	(cfqd)->flags |= (1 << CFQ_CFQD_FLAG_##name);			\
+}									\
+static inline void cfq_clear_cfqd_##name(struct cfq_data *cfqd)	\
+{									\
+	(cfqd)->flags &= ~(1 << CFQ_CFQD_FLAG_##name);			\
+}									\
+static inline int cfq_cfqd_##name(const struct cfq_data *cfqd)		\
+{									\
+	return ((cfqd)->flags & (1 << CFQ_CFQD_FLAG_##name)) != 0;	\
+}
+
+CFQ_CFQD_FNS(on_rr);
+CFQ_CFQD_FNS(slice_new);
+#undef CFQ_CFQD_FNS
 
 static inline struct cfq_cgroup *cgroup_to_cfq_cgroup(struct cgroup *cont)
 {
@@ -49,6 +74,11 @@ static void cfq_cgroup_init_driver_data_opt(struct cfq_driver_data *cfqdd,
 {
 	cfqdd->sibling_tree = RB_ROOT;
 	cfqdd->siblings = 0;
+
+	cfqdd->service_tree = CFQ_RB_ROOT;
+	cfqdd->busy_data = 0;
+
+	cfqdd->cfq_cgroup_slice = cfq_cgroup_slice;
 }
 
 static void cfq_driver_sibling_tree_add(struct cfq_driver_data *cfqdd,
@@ -155,6 +185,8 @@ __cfq_cgroup_init_queue(struct request_queue *q, struct cfq_driver_data *cfqdd)
 
 	RB_CLEAR_NODE(&cfqd->sib_node);
 	RB_CLEAR_NODE(&cfqd->group_node);
+	RB_CLEAR_NODE(&cfqd->rb_node);
+	cfqd->rb_key = 0;
 
 	cfq_driver_sibling_tree_add(cfqd->cfqdd, cfqd);
 
@@ -294,6 +326,237 @@ static void cfq_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
 
 
 /*
+ *  service tree control.
+ */
+static inline int cfq_cgroup_slice_used(struct cfq_data *cfqd)
+{
+	if (cfq_cfqd_slice_new(cfqd))
+		return 0;
+	if (time_before(jiffies, cfqd->slice_end))
+		return 0;
+
+	return 1;
+}
+
+static inline int
+cfq_cgroup_prio_slice(struct cfq_data *cfqd, unsigned short prio)
+{
+	const int base_slice = cfqd->cfqdd->cfq_cgroup_slice;
+
+	WARN_ON(prio >= IOPRIO_BE_NR);
+
+	return base_slice + (base_slice/CFQ_CGROUP_SLICE_SCALE *
+			     (CFQ_CGROUP_MAX_IOPRIO / 2 - prio));
+}
+
+static inline void
+cfq_cgroup_set_prio_slice(struct cfq_data *cfqd)
+{
+	cfqd->slice_end = cfq_cgroup_prio_slice(cfqd, cfqd->ioprio)
+			  + jiffies;
+}
+
+static unsigned long cfq_cgroup_slice_offset(struct cfq_data *cfqd)
+{
+	return (cfqd->cfqdd->busy_data - 1) *
+		(cfq_cgroup_prio_slice(cfqd, 0) -
+		 cfq_cgroup_prio_slice(cfqd, cfqd->ioprio));
+}
+
+static void cfq_cgroup_service_tree_add(struct cfq_data *cfqd, int add_front)
+{
+	struct rb_node **p, *parent;
+	struct cfq_data *__cfqd;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
+	unsigned long rb_key;
+	int left;
+
+	if (!add_front) {
+		rb_key = cfq_cgroup_slice_offset(cfqd) + jiffies;
+		rb_key += cfqd->slice_resid;
+		cfqd->slice_resid = 0;
+	} else
+		rb_key = 0;
+
+	if (!RB_EMPTY_NODE(&cfqd->rb_node)) {
+		if (rb_key == cfqd->rb_key)
+			return;
+		cfq_rb_erase(&cfqd->rb_node, &cfqdd->service_tree);
+	}
+
+	left = 1;
+	parent = NULL;
+	p = &cfqdd->service_tree.rb.rb_node;
+	while (*p) {
+		struct rb_node **n;
+
+		parent = *p;
+		__cfqd = rb_entry(parent, struct cfq_data, rb_node);
+
+		if (rb_key < __cfqd->rb_key)
+			n = &(*p)->rb_left;
+		else
+			n = &(*p)->rb_right;
+
+		if (n == &(*p)->rb_right)
+			left = 0;
+
+		p = n;
+	}
+
+	if (left)
+		cfqdd->service_tree.left = &cfqd->rb_node;
+
+	cfqd->rb_key = rb_key;
+	rb_link_node(&cfqd->rb_node, parent, p);
+	rb_insert_color(&cfqd->rb_node, &cfqdd->service_tree.rb);
+}
+
+static void __cfq_cgroup_slice_expired(struct cfq_driver_data *cfqdd,
+					struct cfq_data *cfqd, int timed_out)
+{
+	if (timed_out && !cfq_cfqd_slice_new(cfqd))
+		cfqd->slice_resid = cfqd->slice_end - jiffies;
+
+	if (cfq_cfqd_on_rr(cfqd))
+		cfq_cgroup_service_tree_add(cfqd, 0);
+
+	if (cfqd == cfqdd->active_data)
+		cfqdd->active_data = NULL;
+}
+
+static inline void
+cfq_cgroup_slice_expired(struct cfq_driver_data *cfqdd, int timed_out)
+{
+	struct cfq_data *cfqd = cfqdd->active_data;
+
+	if (cfqd) {
+		cfq_slice_expired(cfqd, 1);
+		__cfq_cgroup_slice_expired(cfqdd, cfqd, timed_out);
+	}
+}
+
+static struct cfq_data *cfq_cgroup_rb_first(struct cfq_rb_root *root)
+{
+	if (!root->left)
+		root->left = rb_first(&root->rb);
+
+	if (root->left)
+		return rb_entry(root->left, struct cfq_data, rb_node);
+
+	return NULL;
+}
+
+static struct cfq_data *cfq_cgroup_get_next_data(struct cfq_driver_data *cfqdd)
+{
+	if (RB_EMPTY_ROOT(&cfqdd->service_tree.rb))
+		return NULL;
+
+	return cfq_cgroup_rb_first(&cfqdd->service_tree);
+}
+
+static void __cfq_cgroup_set_active_data(struct cfq_driver_data*cfqdd,
+					struct cfq_data *cfqd)
+{
+	if (cfqd) {
+		cfqd->slice_end = 0;
+		cfq_mark_cfqd_slice_new(cfqd);
+	}
+
+	cfqdd->active_data = cfqd;
+}
+
+static struct cfq_data *
+cfq_cgroup_set_active_data(struct cfq_driver_data *cfqdd)
+{
+	struct cfq_data *cfqd;
+
+	cfqd = cfq_cgroup_get_next_data(cfqdd);
+	__cfq_cgroup_set_active_data(cfqdd , cfqd);
+
+	return cfqd;
+}
+
+struct cfq_data *cfq_cgroup_select_data(struct cfq_driver_data *cfqdd)
+{
+	struct cfq_data *cfqd;
+
+	cfqd = cfqdd->active_data;
+	if (!cfqd)
+		goto new_data;
+
+	if (cfq_cgroup_slice_used(cfqd))
+		goto expire;
+
+	if (!RB_EMPTY_ROOT(&cfqd->service_tree.rb))
+		goto keep_data;
+
+	if (wait_request_checker(cfqd))
+		goto keep_data;
+
+expire:
+	cfq_cgroup_slice_expired(cfqdd, 0);
+new_data:
+	cfqd = cfq_cgroup_set_active_data(cfqdd);
+keep_data:
+	return cfqd;
+}
+
+int cfq_cgroup_forced_dispatch(struct cfq_data *cfqd)
+{
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
+	int dispatched = 0;
+
+	while ((cfqd = cfq_cgroup_rb_first(&cfqdd->service_tree)) != NULL)
+		dispatched += cfq_forced_dispatch(cfqd);
+
+	cfq_cgroup_slice_expired(cfqdd, 0);
+
+	BUG_ON(cfqdd->busy_data);
+
+	return dispatched;
+}
+
+int cfq_cgroup_dispatch_requests(struct request_queue *q, int force)
+{
+	struct cfq_data *cfqd = q->elevator->elevator_data;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
+	int dispatched;
+
+	if (!cfqdd->busy_data)
+		return 0;
+
+	if (unlikely(force))
+		return cfq_cgroup_forced_dispatch(cfqd);
+
+	dispatched = 0;
+	cfqd = cfq_cgroup_select_data(cfqdd);
+
+	if (cfqd)
+		dispatched = cfq_queue_dispatch_requests(cfqd, force);
+
+	return dispatched;
+}
+
+int cfq_cgroup_completed_request_opt(struct cfq_data *cfqd)
+{
+	if (cfqd->cfqdd->active_data == cfqd) {
+		if (cfq_cfqd_slice_new(cfqd)) {
+			cfq_cgroup_set_prio_slice(cfqd);
+			cfq_clear_cfqd_slice_new(cfqd);
+
+		}
+		if (cfq_cgroup_slice_used(cfqd)) {
+			cfq_cgroup_slice_expired(cfqd->cfqdd, 1);
+			return 0;
+		}
+		return 1;
+	}
+
+	return 0;
+}
+
+/*
  * cgroupfs parts below -->
  */
 static void
@@ -680,6 +943,7 @@ static struct elevator_type iosched_cfq_cgroup = {
 
 static struct cfq_ops cfq_cgroup_op = {
 	.cfq_init_driver_data_opt_fn	= cfq_cgroup_init_driver_data_opt,
+	.cfq_completed_request_opt_fn	= cfq_cgroup_completed_request_opt,
 };
 
 static int __init cfq_cgroup_init(void)
@@ -687,6 +951,8 @@ static int __init cfq_cgroup_init(void)
 	iosched_cfq_cgroup.ops = iosched_cfq.ops;
 	iosched_cfq_cgroup.ops.elevator_init_fn = cfq_cgroup_init_queue;
 	iosched_cfq_cgroup.ops.elevator_exit_fn = cfq_cgroup_exit_queue;
+	iosched_cfq_cgroup.ops.elevator_dispatch_fn =
+					cfq_cgroup_dispatch_requests,
 
 	elv_register(&iosched_cfq_cgroup);
 
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index fd1ed0c..5fbef85 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -354,7 +354,7 @@ static struct cfq_queue *cfq_rb_first(struct cfq_rb_root *root)
 	return NULL;
 }
 
-static void cfq_rb_erase(struct rb_node *n, struct cfq_rb_root *root)
+void cfq_rb_erase(struct rb_node *n, struct cfq_rb_root *root)
 {
 	if (root->left == n)
 		root->left = NULL;
@@ -751,7 +751,7 @@ __cfq_slice_expired(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 	}
 }
 
-static inline void cfq_slice_expired(struct cfq_data *cfqd, int timed_out)
+inline void cfq_slice_expired(struct cfq_data *cfqd, int timed_out)
 {
 	struct cfq_queue *cfqq = cfqd->active_queue;
 
@@ -932,6 +932,16 @@ cfq_prio_to_maxrq(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 	return 2 * (base_rq + base_rq * (CFQ_PRIO_LISTS - 1 - cfqq->ioprio));
 }
 
+int wait_request_checker(struct cfq_data *cfqd)
+{
+	struct cfq_queue *cfqq = cfqd->active_queue;
+	if (cfqq)
+		return timer_pending(&cfqd->cfqdd->idle_slice_timer)
+			|| (cfqq->dispatched && cfq_cfqq_idle_window(cfqq));
+	else
+		return 0;
+}
+
 /*
  * Select a queue for service. If we have a current active queue,
  * check whether to continue servicing it, or retrieve and set a new one.
@@ -1047,7 +1057,7 @@ static int __cfq_forced_dispatch_cfqq(struct cfq_queue *cfqq)
  * Drain our current requests. Used for barriers and when switching
  * io schedulers on-the-fly.
  */
-static int cfq_forced_dispatch(struct cfq_data *cfqd)
+int cfq_forced_dispatch(struct cfq_data *cfqd)
 {
 	struct cfq_queue *cfqq;
 	int dispatched = 0;
@@ -1063,9 +1073,8 @@ static int cfq_forced_dispatch(struct cfq_data *cfqd)
 	return dispatched;
 }
 
-static int cfq_dispatch_requests(struct request_queue *q, int force)
+int cfq_queue_dispatch_requests(struct cfq_data *cfqd, int force)
 {
-	struct cfq_data *cfqd = q->elevator->elevator_data;
 	struct cfq_queue *cfqq;
 	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 	int dispatched;
@@ -1105,6 +1114,13 @@ static int cfq_dispatch_requests(struct request_queue *q, int force)
 	return dispatched;
 }
 
+static int cfq_dispatch_requests(struct request_queue *q, int force)
+{
+	struct cfq_data *cfqd = q->elevator->elevator_data;
+
+	return cfq_queue_dispatch_requests(cfqd, force);
+}
+
 /*
  * task holds one reference to the queue, dropped when task exits. each rq
  * in-flight on this queue also holds a reference, dropped when rq is freed.
@@ -1876,6 +1892,7 @@ static void cfq_completed_request(struct request_queue *q, struct request *rq)
 	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 	const int sync = rq_is_sync(rq);
 	unsigned long now;
+	int flag = 1;
 
 	now = jiffies;
 	cfq_log_cfqq(cfqd, cfqq, "complete");
@@ -1900,7 +1917,10 @@ static void cfq_completed_request(struct request_queue *q, struct request *rq)
 	 * If this is the active queue, check if it needs to be expired,
 	 * or if we want to idle in case it has no pending requests.
 	 */
-	if (cfqd->active_queue == cfqq) {
+	if (cfqd->cfqdd->op->cfq_completed_request_opt_fn)
+		flag = cfqd->cfqdd->op->cfq_completed_request_opt_fn(cfqd);
+
+	if ((flag) && (cfqd->active_queue == cfqq)) {
 		if (cfq_cfqq_slice_new(cfqq)) {
 			cfq_set_prio_slice(cfqd, cfqq);
 			cfq_clear_cfqq_slice_new(cfqq);
diff --git a/include/linux/cfq-iosched.h b/include/linux/cfq-iosched.h
index b58d476..30702c9 100644
--- a/include/linux/cfq-iosched.h
+++ b/include/linux/cfq-iosched.h
@@ -54,6 +54,15 @@ struct cfq_driver_data {
 	/* device siblings */
 	struct rb_root sibling_tree;
 	unsigned int siblings;
+
+	/*
+	 * rr list of cfq_data with requests and the count of them
+	 */
+	struct cfq_rb_root service_tree;
+	unsigned int busy_data;
+	struct cfq_data *active_data;
+
+	unsigned int cfq_cgroup_slice;
 #endif
 };
 
@@ -100,6 +109,20 @@ struct cfq_data {
 	struct cfq_cgroup *cfqc;
 	/* group_tree member for cfq_cgroup */
 	struct rb_node group_node;
+
+	/* service_tree member */
+	struct rb_node rb_node;
+	/* service_tree key */
+	unsigned long rb_key;
+
+	/*
+	 * slice parameter
+	 */
+	unsigned long slice_end;
+	long slice_resid;
+
+	/* various state flags, see below */
+	unsigned int flags;
 #endif
 };
 
@@ -108,14 +131,21 @@ struct cfq_data {
  */
 typedef void (cfq_init_driver_data_opt_fn)(struct cfq_driver_data *,
 						struct cfq_data *);
+typedef int (cfq_completed_request_opt_fn)(struct cfq_data *);
 struct cfq_ops {
 	cfq_init_driver_data_opt_fn *cfq_init_driver_data_opt_fn;
+	cfq_completed_request_opt_fn *cfq_completed_request_opt_fn;
 };
 
 
 extern struct elevator_type iosched_cfq;
 extern struct cfq_data *cfq_init_cfq_data(struct request_queue *,
 				struct cfq_driver_data *, struct cfq_ops *);
-extern void cfq_free_cfq_data(struct cfq_data *cfqd);
+extern void cfq_free_cfq_data(struct cfq_data *);
+extern void cfq_rb_erase(struct rb_node *, struct cfq_rb_root *);
+extern void cfq_slice_expired(struct cfq_data *, int);
+extern int wait_request_checker(struct cfq_data *cfqd);
+extern int cfq_forced_dispatch(struct cfq_data *);
+extern int cfq_queue_dispatch_requests(struct cfq_data *, int);
 
 #endif  /* _LINUX_CFQ_IOSCHED_H */
-- 
1.5.6.5
