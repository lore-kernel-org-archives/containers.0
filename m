From: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Tue, 29 Sep 2009 07:55:19 +0200
Message-ID: <1254203719.8018.21.camel__34291.8946793818$1254203883$gmane$org@marge.simson.net>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<4ABC28DE.7050809@datenparkplatz.de>
	<20090925202636.GC15007@redhat.com>
	<4e5e476b0909271000u69d79346s27cccad219e49902@mail.gmail.com>
	<20090928145655.GB8192@redhat.com>
	<4e5e476b0909280835w3410d58aod93a29d1dcda8909@mail.gmail.com>
	<1254160274.9820.25.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1254160274.9820.25.camel-YqMYhexLQo1vAv1Ojkdn7Q@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Corrado Zoccolo <czoccolo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Tobias Oetiker <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2009-09-28 at 19:51 +0200, Mike Galbraith wrote:

> I'll give your patch a spin as well.

I applied it to tip, and fixed up rejects.  I haven't done a line for
line verification against the original patch yet (brave or..), so add
giant economy sized pinch of salt.

In the form it ended up in, it didn't help here.  I tried twiddling
knobs, but it didn't help either.  Reducing latency target from 300 to
30 did nada, but dropping to 3 did... I got to poke BRB.

Plugging Vivek's fairness tweakable on top, and enabling it, my timings
return to decent numbers, so that one liner absatively posilutely is
where my write vs read woes are coming from.

FWIW, below is patch wedged into tip v2.6.31-10215-ga3c9602

---
 block/cfq-iosched.c |  281 ++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 227 insertions(+), 54 deletions(-)

Index: linux-2.6/block/cfq-iosched.c
===================================================================
--- linux-2.6.orig/block/cfq-iosched.c
+++ linux-2.6/block/cfq-iosched.c
@@ -27,6 +27,12 @@ static const int cfq_slice_sync = HZ / 1
 static int cfq_slice_async = HZ / 25;
 static const int cfq_slice_async_rq = 2;
 static int cfq_slice_idle = HZ / 125;
+static int cfq_target_latency = HZ * 3/10; /* 300 ms */
+static int cfq_hist_divisor = 4;
+/*
+ * Number of times that other workloads can be scheduled before async
+ */
+static const unsigned int cfq_async_penalty = 4;
 
 /*
  * offset from end of service tree
@@ -36,7 +42,7 @@ static int cfq_slice_idle = HZ / 125;
 /*
  * below this threshold, we consider thinktime immediate
  */
-#define CFQ_MIN_TT		(2)
+#define CFQ_MIN_TT		(1)
 
 #define CFQ_SLICE_SCALE		(5)
 #define CFQ_HW_QUEUE_MIN	(5)
@@ -67,8 +73,9 @@ static DEFINE_SPINLOCK(ioc_gone_lock);
 struct cfq_rb_root {
 	struct rb_root rb;
 	struct rb_node *left;
+	unsigned count;
 };
-#define CFQ_RB_ROOT	(struct cfq_rb_root) { RB_ROOT, NULL, }
+#define CFQ_RB_ROOT	(struct cfq_rb_root) { RB_ROOT, NULL, 0, }
 
 /*
  * Per process-grouping structure
@@ -113,6 +120,21 @@ struct cfq_queue {
 	unsigned short ioprio_class, org_ioprio_class;
 
 	pid_t pid;
+
+	struct cfq_rb_root *service_tree;
+	struct cfq_io_context *cic;
+};
+
+enum wl_prio_t {
+	IDLE_WL = -1,
+	BE_WL = 0,
+	RT_WL = 1
+};
+
+enum wl_type_t {
+	ASYNC_WL = 0,
+	SYNC_NOIDLE_WL = 1,
+	SYNC_WL = 2
 };
 
 /*
@@ -124,7 +146,13 @@ struct cfq_data {
 	/*
 	 * rr list of queues with requests and the count of them
 	 */
-	struct cfq_rb_root service_tree;
+	struct cfq_rb_root service_trees[2][3];
+	struct cfq_rb_root service_tree_idle;
+
+	enum wl_prio_t serving_prio;
+	enum wl_type_t serving_type;
+	unsigned long workload_expires;
+	unsigned int async_starved;
 
 	/*
 	 * Each priority tree is sorted by next_request position.  These
@@ -134,9 +162,11 @@ struct cfq_data {
 	struct rb_root prio_trees[CFQ_PRIO_LISTS];
 
 	unsigned int busy_queues;
+	unsigned int busy_queues_avg[2];
 
 	int rq_in_driver[2];
 	int sync_flight;
+	int reads_delayed;
 
 	/*
 	 * queue-depth detection
@@ -173,6 +203,9 @@ struct cfq_data {
 	unsigned int cfq_slice[2];
 	unsigned int cfq_slice_async_rq;
 	unsigned int cfq_slice_idle;
+	unsigned int cfq_target_latency;
+	unsigned int cfq_hist_divisor;
+	unsigned int cfq_async_penalty;
 
 	struct list_head cic_list;
 
@@ -182,6 +215,11 @@ struct cfq_data {
 	struct cfq_queue oom_cfqq;
 };
 
+static struct cfq_rb_root * service_tree_for(enum wl_prio_t prio, enum wl_type_t type,
+							  struct cfq_data *cfqd) {
+	return prio == IDLE_WL ? &cfqd->service_tree_idle :  &cfqd->service_trees[prio][type];
+}
+
 enum cfqq_state_flags {
 	CFQ_CFQQ_FLAG_on_rr = 0,	/* on round-robin busy list */
 	CFQ_CFQQ_FLAG_wait_request,	/* waiting for a request */
@@ -226,6 +264,17 @@ CFQ_CFQQ_FNS(coop);
 #define cfq_log(cfqd, fmt, args...)	\
 	blk_add_trace_msg((cfqd)->queue, "cfq " fmt, ##args)
 
+#define CIC_SEEK_THR	1024
+#define CIC_SEEKY(cic)	((cic)->seek_mean > CIC_SEEK_THR)
+#define CFQQ_SEEKY(cfqq) (!cfqq->cic || CIC_SEEKY(cfqq->cic))
+
+static inline int cfq_busy_queues_wl(enum wl_prio_t wl, struct cfq_data *cfqd) {
+	return wl==IDLE_WL? cfqd->service_tree_idle.count :
+		cfqd->service_trees[wl][ASYNC_WL].count
+		+ cfqd->service_trees[wl][SYNC_NOIDLE_WL].count
+		+ cfqd->service_trees[wl][SYNC_WL].count;
+}
+
 static void cfq_dispatch_insert(struct request_queue *, struct request *);
 static struct cfq_queue *cfq_get_queue(struct cfq_data *, int,
 				       struct io_context *, gfp_t);
@@ -247,6 +296,7 @@ static inline void cic_set_cfqq(struct c
 				struct cfq_queue *cfqq, int is_sync)
 {
 	cic->cfqq[!!is_sync] = cfqq;
+	cfqq->cic = cic;
 }
 
 /*
@@ -301,10 +351,33 @@ cfq_prio_to_slice(struct cfq_data *cfqd,
 	return cfq_prio_slice(cfqd, cfq_cfqq_sync(cfqq), cfqq->ioprio);
 }
 
+static inline unsigned
+cfq_get_interested_queues(struct cfq_data *cfqd, bool rt) {
+	unsigned min_q, max_q;
+	unsigned mult  = cfqd->cfq_hist_divisor - 1;
+	unsigned round = cfqd->cfq_hist_divisor / 2;
+	unsigned busy  = cfq_busy_queues_wl(rt, cfqd);
+	min_q = min(cfqd->busy_queues_avg[rt], busy);
+	max_q = max(cfqd->busy_queues_avg[rt], busy);
+	cfqd->busy_queues_avg[rt] = (mult * max_q + min_q + round) /
+		cfqd->cfq_hist_divisor;
+	return cfqd->busy_queues_avg[rt];
+}
+
 static inline void
 cfq_set_prio_slice(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 {
-	cfqq->slice_end = cfq_prio_to_slice(cfqd, cfqq) + jiffies;
+	unsigned process_thr = cfqd->cfq_target_latency / cfqd->cfq_slice[1];
+	unsigned iq = cfq_get_interested_queues(cfqd, cfq_class_rt(cfqq));
+	unsigned slice = cfq_prio_to_slice(cfqd, cfqq);
+
+	if (iq > process_thr) {
+		unsigned low_slice = 2 * slice * cfqd->cfq_slice_idle
+			/ cfqd->cfq_slice[1];
+		slice = max(slice * process_thr / iq, min(slice, low_slice));
+	}
+
+	cfqq->slice_end = jiffies + slice;
 	cfq_log_cfqq(cfqd, cfqq, "set_slice=%lu", cfqq->slice_end - jiffies);
 }
 
@@ -443,6 +516,7 @@ static void cfq_rb_erase(struct rb_node
 	if (root->left == n)
 		root->left = NULL;
 	rb_erase_init(n, &root->rb);
+	--root->count;
 }
 
 /*
@@ -483,46 +557,56 @@ static unsigned long cfq_slice_offset(st
 }
 
 /*
- * The cfqd->service_tree holds all pending cfq_queue's that have
+ * The cfqd->service_trees holds all pending cfq_queue's that have
  * requests waiting to be processed. It is sorted in the order that
  * we will service the queues.
  */
-static void cfq_service_tree_add(struct cfq_data *cfqd, struct cfq_queue *cfqq,
-				 int add_front)
+static void cfq_service_tree_add(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 {
 	struct rb_node **p, *parent;
 	struct cfq_queue *__cfqq;
 	unsigned long rb_key;
+	struct cfq_rb_root *service_tree;
 	int left;
 
 	if (cfq_class_idle(cfqq)) {
 		rb_key = CFQ_IDLE_DELAY;
-		parent = rb_last(&cfqd->service_tree.rb);
+		service_tree = &cfqd->service_tree_idle;
+		parent = rb_last(&service_tree->rb);
 		if (parent && parent != &cfqq->rb_node) {
 			__cfqq = rb_entry(parent, struct cfq_queue, rb_node);
 			rb_key += __cfqq->rb_key;
 		} else
 			rb_key += jiffies;
-	} else if (!add_front) {
+	} else {
+		enum wl_prio_t prio = cfq_class_rt(cfqq) ? RT_WL : BE_WL;
+		enum wl_type_t type = cfq_cfqq_sync(cfqq) ? SYNC_WL : ASYNC_WL;
+
 		rb_key = cfq_slice_offset(cfqd, cfqq) + jiffies;
 		rb_key += cfqq->slice_resid;
 		cfqq->slice_resid = 0;
-	} else
-		rb_key = 0;
+
+		if (type == SYNC_WL && (CFQQ_SEEKY(cfqq) || !cfq_cfqq_idle_window(cfqq)))
+			type = SYNC_NOIDLE_WL;
+
+		service_tree = service_tree_for(prio, type, cfqd);
+	}
 
 	if (!RB_EMPTY_NODE(&cfqq->rb_node)) {
 		/*
 		 * same position, nothing more to do
 		 */
-		if (rb_key == cfqq->rb_key)
+		if (rb_key == cfqq->rb_key && cfqq->service_tree == service_tree)
 			return;
 
-		cfq_rb_erase(&cfqq->rb_node, &cfqd->service_tree);
+		cfq_rb_erase(&cfqq->rb_node, cfqq->service_tree);
+		cfqq->service_tree = NULL;
 	}
 
 	left = 1;
 	parent = NULL;
-	p = &cfqd->service_tree.rb.rb_node;
+	cfqq->service_tree = service_tree;
+	p = &service_tree->rb.rb_node;
 	while (*p) {
 		struct rb_node **n;
 
@@ -554,11 +638,12 @@ static void cfq_service_tree_add(struct
 	}
 
 	if (left)
-		cfqd->service_tree.left = &cfqq->rb_node;
+		service_tree->left = &cfqq->rb_node;
 
 	cfqq->rb_key = rb_key;
 	rb_link_node(&cfqq->rb_node, parent, p);
-	rb_insert_color(&cfqq->rb_node, &cfqd->service_tree.rb);
+	rb_insert_color(&cfqq->rb_node, &service_tree->rb);
+	service_tree->count++;
 }
 
 static struct cfq_queue *
@@ -631,7 +716,7 @@ static void cfq_resort_rr_list(struct cf
 	 * Resorting requires the cfqq to be on the RR list already.
 	 */
 	if (cfq_cfqq_on_rr(cfqq)) {
-		cfq_service_tree_add(cfqd, cfqq, 0);
+		cfq_service_tree_add(cfqd, cfqq);
 		cfq_prio_tree_add(cfqd, cfqq);
 	}
 }
@@ -660,8 +745,10 @@ static void cfq_del_cfqq_rr(struct cfq_d
 	BUG_ON(!cfq_cfqq_on_rr(cfqq));
 	cfq_clear_cfqq_on_rr(cfqq);
 
-	if (!RB_EMPTY_NODE(&cfqq->rb_node))
-		cfq_rb_erase(&cfqq->rb_node, &cfqd->service_tree);
+	if (!RB_EMPTY_NODE(&cfqq->rb_node)) {
+		cfq_rb_erase(&cfqq->rb_node, cfqq->service_tree);
+		cfqq->service_tree = NULL;
+	}
 	if (cfqq->p_root) {
 		rb_erase(&cfqq->p_node, cfqq->p_root);
 		cfqq->p_root = NULL;
@@ -923,10 +1010,11 @@ static inline void cfq_slice_expired(str
  */
 static struct cfq_queue *cfq_get_next_queue(struct cfq_data *cfqd)
 {
-	if (RB_EMPTY_ROOT(&cfqd->service_tree.rb))
-		return NULL;
+	struct cfq_rb_root *service_tree = service_tree_for(cfqd->serving_prio, cfqd->serving_type, cfqd);
 
-	return cfq_rb_first(&cfqd->service_tree);
+	if (RB_EMPTY_ROOT(&service_tree->rb))
+		return NULL;
+	return cfq_rb_first(service_tree);
 }
 
 /*
@@ -954,9 +1042,6 @@ static inline sector_t cfq_dist_from_las
 		return cfqd->last_position - blk_rq_pos(rq);
 }
 
-#define CIC_SEEK_THR	8 * 1024
-#define CIC_SEEKY(cic)	((cic)->seek_mean > CIC_SEEK_THR)
-
 static inline int cfq_rq_close(struct cfq_data *cfqd, struct request *rq)
 {
 	struct cfq_io_context *cic = cfqd->active_cic;
@@ -1044,6 +1129,10 @@ static struct cfq_queue *cfq_close_coope
 	if (cfq_cfqq_coop(cfqq))
 		return NULL;
 
+	/* we don't want to mix processes with different characteristics */
+	if (cfqq->service_tree != cur_cfqq->service_tree)
+		return NULL;
+
 	if (!probe)
 		cfq_mark_cfqq_coop(cfqq);
 	return cfqq;
@@ -1087,14 +1176,15 @@ static void cfq_arm_slice_timer(struct c
 
 	cfq_mark_cfqq_wait_request(cfqq);
 
-	/*
-	 * we don't want to idle for seeks, but we do want to allow
-	 * fair distribution of slice time for a process doing back-to-back
-	 * seeks. so allow a little bit of time for him to submit a new rq
-	 */
-	sl = cfqd->cfq_slice_idle;
-	if (sample_valid(cic->seek_samples) && CIC_SEEKY(cic))
+	sl = min_t(unsigned, cfqd->cfq_slice_idle, cfqq->slice_end - jiffies);
+
+	/* very small idle if we are serving noidle trees, and there are more trees */
+	if (cfqd->serving_type == SYNC_NOIDLE_WL &&
+	    service_tree_for(cfqd->serving_prio, SYNC_NOIDLE_WL, cfqd)->count > 0) {
+		if (blk_queue_nonrot(cfqd->queue))
+			return;
 		sl = min(sl, msecs_to_jiffies(CFQ_MIN_TT));
+	}
 
 	mod_timer(&cfqd->idle_slice_timer, jiffies + sl);
 	cfq_log_cfqq(cfqd, cfqq, "arm_idle: %lu", sl);
@@ -1110,6 +1200,11 @@ static void cfq_dispatch_insert(struct r
 
 	cfq_log_cfqq(cfqd, cfqq, "dispatch_insert");
 
+	if (!time_before(jiffies, rq->start_time + cfqd->cfq_target_latency / 2) && rq_data_dir(rq)==READ) {
+		cfqd->reads_delayed = max_t(int, cfqd->reads_delayed,
+					    (jiffies - rq->start_time) / (cfqd->cfq_target_latency / 2));
+	}
+
 	cfqq->next_rq = cfq_find_next_rq(cfqd, cfqq, rq);
 	cfq_remove_request(rq);
 	cfqq->dispatched++;
@@ -1156,6 +1251,16 @@ cfq_prio_to_maxrq(struct cfq_data *cfqd,
 	return 2 * (base_rq + base_rq * (CFQ_PRIO_LISTS - 1 - cfqq->ioprio));
 }
 
+enum wl_type_t cfq_choose_sync_async(struct cfq_data *cfqd, enum wl_prio_t prio) {
+	struct cfq_queue *id, *ni;
+	ni = cfq_rb_first(service_tree_for(prio, SYNC_NOIDLE_WL, cfqd));
+	id = cfq_rb_first(service_tree_for(prio, SYNC_WL, cfqd));
+	if (id && ni && id->rb_key < ni->rb_key)
+		return SYNC_WL;
+	if (!ni) return SYNC_WL;
+	return SYNC_NOIDLE_WL;
+}
+
 /*
  * Select a queue for service. If we have a current active queue,
  * check whether to continue servicing it, or retrieve and set a new one.
@@ -1196,15 +1301,68 @@ static struct cfq_queue *cfq_select_queu
 	 * flight or is idling for a new request, allow either of these
 	 * conditions to happen (or time out) before selecting a new queue.
 	 */
-	if (timer_pending(&cfqd->idle_slice_timer) ||
+	if (timer_pending(&cfqd->idle_slice_timer) || 
 	    (cfqq->dispatched && cfq_cfqq_idle_window(cfqq))) {
 		cfqq = NULL;
 		goto keep_queue;
 	}
-
 expire:
 	cfq_slice_expired(cfqd, 0);
 new_queue:
+	if (!new_cfqq) {
+		enum wl_prio_t previous_prio = cfqd->serving_prio;
+
+		if (cfq_busy_queues_wl(RT_WL, cfqd))
+			cfqd->serving_prio = RT_WL;
+		else if (cfq_busy_queues_wl(BE_WL, cfqd))
+			cfqd->serving_prio = BE_WL;
+		else {
+			cfqd->serving_prio = IDLE_WL;
+			cfqd->workload_expires = jiffies + 1;
+			cfqd->reads_delayed = 0;
+		}
+
+		if (cfqd->serving_prio != IDLE_WL) {
+			int counts[]={
+				service_tree_for(cfqd->serving_prio, ASYNC_WL, cfqd)->count,
+				service_tree_for(cfqd->serving_prio, SYNC_NOIDLE_WL, cfqd)->count,
+				service_tree_for(cfqd->serving_prio, SYNC_WL, cfqd)->count
+			};
+			int nonzero_counts= !!counts[0] + !!counts[1] + !!counts[2];
+
+			if (previous_prio != cfqd->serving_prio || (nonzero_counts == 1)) {
+				cfqd->serving_type = counts[1] ? SYNC_NOIDLE_WL : counts[2] ? SYNC_WL : ASYNC_WL;
+				cfqd->async_starved = 0;
+				cfqd->reads_delayed = 0;
+			} else {
+				if (!counts[cfqd->serving_type] || time_after(jiffies, cfqd->workload_expires)) {
+					if (cfqd->serving_type != ASYNC_WL && counts[ASYNC_WL] &&
+					    cfqd->async_starved++ > cfqd->cfq_async_penalty * (1 + cfqd->reads_delayed))
+						cfqd->serving_type = ASYNC_WL;
+					else 
+						cfqd->serving_type = cfq_choose_sync_async(cfqd, cfqd->serving_prio);
+				} else
+					goto same_wl;
+			}
+
+			{
+				unsigned slice = cfqd->cfq_target_latency;
+				slice = slice * counts[cfqd->serving_type] /
+					max_t(unsigned, cfqd->busy_queues_avg[cfqd->serving_prio],
+					      counts[SYNC_WL] + counts[SYNC_NOIDLE_WL] + counts[ASYNC_WL]);
+					    
+				if (cfqd->serving_type == ASYNC_WL)
+					slice = max(1U, (slice / (1 + cfqd->reads_delayed))
+						    * cfqd->cfq_slice[0] / cfqd->cfq_slice[1]);
+				else
+					slice = max(slice, 2U * max(1U, cfqd->cfq_slice_idle));
+
+				cfqd->workload_expires = jiffies + slice;
+				cfqd->async_starved *= (cfqd->serving_type != ASYNC_WL);
+			}
+		}
+	}
+ same_wl:
 	cfqq = cfq_set_active_queue(cfqd, new_cfqq);
 keep_queue:
 	return cfqq;
@@ -1231,8 +1389,13 @@ static int cfq_forced_dispatch(struct cf
 {
 	struct cfq_queue *cfqq;
 	int dispatched = 0;
+	int i,j;
+	for (i = 0; i < 2; ++i)
+		for (j = 0; j < 3; ++j)
+			while ((cfqq = cfq_rb_first(&cfqd->service_trees[i][j])) != NULL)
+				dispatched += __cfq_forced_dispatch_cfqq(cfqq);
 
-	while ((cfqq = cfq_rb_first(&cfqd->service_tree)) != NULL)
+	while ((cfqq = cfq_rb_first(&cfqd->service_tree_idle)) != NULL)
 		dispatched += __cfq_forced_dispatch_cfqq(cfqq);
 
 	cfq_slice_expired(cfqd, 0);
@@ -1300,6 +1463,12 @@ static int cfq_dispatch_requests(struct
 		return 0;
 
 	/*
+	 * Drain async requests before we start sync IO
+	 */
+	if (cfq_cfqq_idle_window(cfqq) && cfqd->rq_in_driver[BLK_RW_ASYNC])
+		return 0;
+
+	/*
 	 * If this is an async queue and we have sync IO in flight, let it wait
 	 */
 	if (cfqd->sync_flight && !cfq_cfqq_sync(cfqq))
@@ -1993,18 +2162,8 @@ cfq_should_preempt(struct cfq_data *cfqd
 	if (cfq_class_idle(cfqq))
 		return 1;
 
-	/*
-	 * if the new request is sync, but the currently running queue is
-	 * not, let the sync request have priority.
-	 */
-	if (rq_is_sync(rq) && !cfq_cfqq_sync(cfqq))
-		return 1;
-
-	/*
-	 * So both queues are sync. Let the new request get disk time if
-	 * it's a metadata request and the current queue is doing regular IO.
-	 */
-	if (rq_is_meta(rq) && !cfqq->meta_pending)
+	if (cfqd->serving_type == SYNC_NOIDLE_WL
+	    && new_cfqq->service_tree == cfqq->service_tree)
 		return 1;
 
 	/*
@@ -2035,13 +2194,9 @@ static void cfq_preempt_queue(struct cfq
 	cfq_log_cfqq(cfqd, cfqq, "preempt");
 	cfq_slice_expired(cfqd, 1);
 
-	/*
-	 * Put the new queue at the front of the of the current list,
-	 * so we know that it will be selected next.
-	 */
 	BUG_ON(!cfq_cfqq_on_rr(cfqq));
 
-	cfq_service_tree_add(cfqd, cfqq, 1);
+	cfq_service_tree_add(cfqd, cfqq);
 
 	cfqq->slice_end = 0;
 	cfq_mark_cfqq_slice_new(cfqq);
@@ -2438,13 +2593,16 @@ static void cfq_exit_queue(struct elevat
 static void *cfq_init_queue(struct request_queue *q)
 {
 	struct cfq_data *cfqd;
-	int i;
+	int i,j;
 
 	cfqd = kmalloc_node(sizeof(*cfqd), GFP_KERNEL | __GFP_ZERO, q->node);
 	if (!cfqd)
 		return NULL;
 
-	cfqd->service_tree = CFQ_RB_ROOT;
+	for (i = 0; i < 2; ++i)
+		for (j = 0; j < 3; ++j)
+			cfqd->service_trees[i][j] = CFQ_RB_ROOT;
+	cfqd->service_tree_idle = CFQ_RB_ROOT;
 
 	/*
 	 * Not strictly needed (since RB_ROOT just clears the node and we
@@ -2481,6 +2639,9 @@ static void *cfq_init_queue(struct reque
 	cfqd->cfq_slice[1] = cfq_slice_sync;
 	cfqd->cfq_slice_async_rq = cfq_slice_async_rq;
 	cfqd->cfq_slice_idle = cfq_slice_idle;
+	cfqd->cfq_target_latency = cfq_target_latency;
+	cfqd->cfq_hist_divisor = cfq_hist_divisor;
+	cfqd->cfq_async_penalty = cfq_async_penalty;
 	cfqd->hw_tag = 1;
 
 	return cfqd;
@@ -2517,6 +2678,7 @@ fail:
 /*
  * sysfs parts below -->
  */
+
 static ssize_t
 cfq_var_show(unsigned int var, char *page)
 {
@@ -2550,6 +2712,9 @@ SHOW_FUNCTION(cfq_slice_idle_show, cfqd-
 SHOW_FUNCTION(cfq_slice_sync_show, cfqd->cfq_slice[1], 1);
 SHOW_FUNCTION(cfq_slice_async_show, cfqd->cfq_slice[0], 1);
 SHOW_FUNCTION(cfq_slice_async_rq_show, cfqd->cfq_slice_async_rq, 0);
+SHOW_FUNCTION(cfq_target_latency_show, cfqd->cfq_target_latency, 1);
+SHOW_FUNCTION(cfq_hist_divisor_show, cfqd->cfq_hist_divisor, 0);
+SHOW_FUNCTION(cfq_async_penalty_show, cfqd->cfq_async_penalty, 0);
 #undef SHOW_FUNCTION
 
 #define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
@@ -2581,6 +2746,11 @@ STORE_FUNCTION(cfq_slice_sync_store, &cf
 STORE_FUNCTION(cfq_slice_async_store, &cfqd->cfq_slice[0], 1, UINT_MAX, 1);
 STORE_FUNCTION(cfq_slice_async_rq_store, &cfqd->cfq_slice_async_rq, 1,
 		UINT_MAX, 0);
+
+STORE_FUNCTION(cfq_target_latency_store, &cfqd->cfq_target_latency, 1, 1000, 1);
+STORE_FUNCTION(cfq_hist_divisor_store, &cfqd->cfq_hist_divisor, 1, 100, 0);
+STORE_FUNCTION(cfq_async_penalty_store, &cfqd->cfq_async_penalty, 1, UINT_MAX, 0);
+
 #undef STORE_FUNCTION
 
 #define CFQ_ATTR(name) \
@@ -2596,6 +2766,9 @@ static struct elv_fs_entry cfq_attrs[] =
 	CFQ_ATTR(slice_async),
 	CFQ_ATTR(slice_async_rq),
 	CFQ_ATTR(slice_idle),
+	CFQ_ATTR(target_latency),
+	CFQ_ATTR(hist_divisor),
+	CFQ_ATTR(async_penalty),
 	__ATTR_NULL
 };
