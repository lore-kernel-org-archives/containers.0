From: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Subject: [PATCH RFC 3/3] sched/fair: pulse-weight modulation controller for
	cpu cgroup
Date: Mon, 16 May 2016 12:36:35 +0300
Message-ID: <146339139540.25295.8841485116383963880.stgit__42286.468941211$1463391767$gmane$org@buzz>
References: <146339085068.25295.7687045977863852568.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <146339085068.25295.7687045977863852568.stgit@buzz>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This implements "low limit"-ish thing for cpu bandwidth controller.

Cgroup interface:
cpu.cfs_reserve_us      - reserved time for each cpu.cfs_period_us
cpu.cfs_reserve_shares  - group weight for reserved time

While cfs group consumes reserved cpu time it has different weight,
thus vruntime penalty for that execution differs too.

Distribution of reserved time is similar to distribution of cpu quota:
cfs rq pulls reserved time from shared pool which is refilled by a timer.

This feature also can work as "high limit": reserve can boost weight
from tiny to normal for limited amount of time. Such group can use
cpu even after depleting reserves if nobody else needs it.

Signed-off-by: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
---
 kernel/sched/core.c  |   91 ++++++++++++++++++++++++++++++++++++++++++++++----
 kernel/sched/fair.c  |   85 ++++++++++++++++++++++++++++++++++++++---------
 kernel/sched/sched.h |    4 ++
 3 files changed, 157 insertions(+), 23 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 355698188ea9..4a583c6e5d4e 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -8150,7 +8150,8 @@ const u64 min_cfs_quota_period = 1 * NSEC_PER_MSEC; /* 1ms */
 
 static int __cfs_schedulable(struct task_group *tg, u64 period, u64 runtime);
 
-static int tg_set_cfs_bandwidth(struct task_group *tg, u64 period, u64 quota)
+static int tg_set_cfs_bandwidth(struct task_group *tg, u64 period,
+				u64 quota, u64 reserve)
 {
 	int i, ret = 0, runtime_enabled, runtime_was_enabled;
 	struct cfs_bandwidth *cfs_b = &tg->cfs_bandwidth;
@@ -8184,8 +8185,9 @@ static int tg_set_cfs_bandwidth(struct task_group *tg, u64 period, u64 quota)
 	if (ret)
 		goto out_unlock;
 
-	runtime_enabled = quota != RUNTIME_INF;
-	runtime_was_enabled = cfs_b->quota != RUNTIME_INF;
+	runtime_enabled = quota != RUNTIME_INF || reserve != 0;
+	runtime_was_enabled = cfs_b->quota != RUNTIME_INF ||
+			      cfs_b->reserve != 0;
 	/*
 	 * If we need to toggle cfs_bandwidth_used, off->on must occur
 	 * before making related changes, and on->off must occur afterwards
@@ -8195,6 +8197,7 @@ static int tg_set_cfs_bandwidth(struct task_group *tg, u64 period, u64 quota)
 	raw_spin_lock_irq(&cfs_b->lock);
 	cfs_b->period = ns_to_ktime(period);
 	cfs_b->quota = quota;
+	cfs_b->reserve = reserve;
 
 	/* restart the period timer (if active) to handle new period expiry */
 	if (runtime_enabled) {
@@ -8213,6 +8216,10 @@ static int tg_set_cfs_bandwidth(struct task_group *tg, u64 period, u64 quota)
 
 		if (cfs_rq->throttled)
 			unthrottle_cfs_rq(cfs_rq);
+
+		if (cfs_rq->reserve_active)
+			deactivate_cfs_rq_reserve(cfs_rq);
+
 		raw_spin_unlock_irq(&rq->lock);
 	}
 	if (runtime_was_enabled && !runtime_enabled)
@@ -8224,17 +8231,39 @@ out_unlock:
 	return ret;
 }
 
+static int tg_set_cfs_reserve(struct task_group *tg, long cfs_reserve_us)
+{
+	u64 reserve, quota, period;
+
+	period = ktime_to_ns(tg->cfs_bandwidth.period);
+	quota = tg->cfs_bandwidth.quota;
+	reserve = (u64)cfs_reserve_us * NSEC_PER_USEC;
+
+	return tg_set_cfs_bandwidth(tg, period, quota, reserve);
+}
+
+static long tg_get_cfs_reserve(struct task_group *tg)
+{
+	u64 reserve_us;
+
+	reserve_us = tg->cfs_bandwidth.reserve;
+	do_div(reserve_us, NSEC_PER_USEC);
+
+	return reserve_us;
+}
+
 int tg_set_cfs_quota(struct task_group *tg, long cfs_quota_us)
 {
-	u64 quota, period;
+	u64 reserve, quota, period;
 
 	period = ktime_to_ns(tg->cfs_bandwidth.period);
 	if (cfs_quota_us < 0)
 		quota = RUNTIME_INF;
 	else
 		quota = (u64)cfs_quota_us * NSEC_PER_USEC;
+	reserve = tg->cfs_bandwidth.reserve;
 
-	return tg_set_cfs_bandwidth(tg, period, quota);
+	return tg_set_cfs_bandwidth(tg, period, quota, reserve);
 }
 
 long tg_get_cfs_quota(struct task_group *tg)
@@ -8252,12 +8281,13 @@ long tg_get_cfs_quota(struct task_group *tg)
 
 int tg_set_cfs_period(struct task_group *tg, long cfs_period_us)
 {
-	u64 quota, period;
+	u64 reserve, quota, period;
 
 	period = (u64)cfs_period_us * NSEC_PER_USEC;
 	quota = tg->cfs_bandwidth.quota;
+	reserve = tg->cfs_bandwidth.reserve;
 
-	return tg_set_cfs_bandwidth(tg, period, quota);
+	return tg_set_cfs_bandwidth(tg, period, quota, reserve);
 }
 
 long tg_get_cfs_period(struct task_group *tg)
@@ -8270,6 +8300,43 @@ long tg_get_cfs_period(struct task_group *tg)
 	return cfs_period_us;
 }
 
+static u64 cpu_cfs_reserve_read_u64(struct cgroup_subsys_state *css,
+				    struct cftype *cft)
+{
+	return tg_get_cfs_reserve(css_tg(css));
+}
+
+static int cpu_cfs_reserve_write_u64(struct cgroup_subsys_state *css,
+				     struct cftype *cftype, u64 cfs_reserve_us)
+{
+	return tg_set_cfs_reserve(css_tg(css), cfs_reserve_us);
+}
+
+static u64 cpu_cfs_reserve_shares_read_u64(struct cgroup_subsys_state *css,
+					   struct cftype *cft)
+{
+	return scale_load_down(css_tg(css)->cfs_bandwidth.reserve_shares);
+}
+
+static int cpu_cfs_reserve_shares_write_u64(struct cgroup_subsys_state *css,
+					    struct cftype *cftype, u64 shares)
+{
+	struct task_group *tg = css_tg(css);
+	u64 reserve, quota, period;
+
+	if (!css->parent)
+		return -EINVAL;
+
+	shares = clamp_t(u64, shares, MIN_SHARES, MAX_SHARES);
+	css_tg(css)->cfs_bandwidth.reserve_shares = scale_load(shares);
+
+	period = ktime_to_ns(tg->cfs_bandwidth.period);
+	quota = tg->cfs_bandwidth.quota;
+	reserve = tg->cfs_bandwidth.reserve;
+
+	return tg_set_cfs_bandwidth(tg, period, quota, reserve);
+}
+
 static s64 cpu_cfs_quota_read_s64(struct cgroup_subsys_state *css,
 				  struct cftype *cft)
 {
@@ -8422,6 +8489,16 @@ static struct cftype cpu_files[] = {
 #endif
 #ifdef CONFIG_CFS_BANDWIDTH
 	{
+		.name = "cfs_reserve_us",
+		.read_u64 = cpu_cfs_reserve_read_u64,
+		.write_u64 = cpu_cfs_reserve_write_u64,
+	},
+	{
+		.name = "cfs_reserve_shares",
+		.read_u64 = cpu_cfs_reserve_shares_read_u64,
+		.write_u64 = cpu_cfs_reserve_shares_write_u64,
+	},
+	{
 		.name = "cfs_quota_us",
 		.read_s64 = cpu_cfs_quota_read_s64,
 		.write_s64 = cpu_cfs_quota_write_s64,
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 5bf34532d364..02f94bb8ff4f 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -3562,6 +3562,7 @@ void __refill_cfs_bandwidth_runtime(struct cfs_bandwidth *cfs_b)
 	u64 now = sched_clock_cpu(smp_processor_id());
 
 	cfs_b->runtime = cfs_b->quota;
+	cfs_b->reserve_runtime = cfs_b->reserve;
 	cfs_b->runtime_expires = now + ktime_to_ns(cfs_b->period);
 }
 
@@ -3584,26 +3585,41 @@ static int assign_cfs_rq_runtime(struct cfs_rq *cfs_rq)
 {
 	struct task_group *tg = cfs_rq->tg;
 	struct cfs_bandwidth *cfs_b = tg_cfs_bandwidth(tg);
-	u64 amount = 0, min_amount, expires;
+	u64 amount, expires;
+	int reserve_active = 0;
 
 	/* note: this is a positive sum as runtime_remaining <= 0 */
-	min_amount = sched_cfs_bandwidth_slice() - cfs_rq->runtime_remaining;
+	amount = sched_cfs_bandwidth_slice() - cfs_rq->runtime_remaining;
 
 	raw_spin_lock(&cfs_b->lock);
-	if (cfs_b->quota == RUNTIME_INF)
-		amount = min_amount;
-	else {
+	if (cfs_b->reserve_runtime) {
+		start_cfs_bandwidth(cfs_b);
+		amount = min(amount, cfs_b->reserve_runtime);
+		cfs_b->reserve_runtime -= amount;
+		cfs_b->idle = 0;
+		reserve_active = 1;
+	}
+	if (cfs_b->quota != RUNTIME_INF) {
 		start_cfs_bandwidth(cfs_b);
-
 		if (cfs_b->runtime > 0) {
-			amount = min(cfs_b->runtime, min_amount);
+			amount = min(cfs_b->runtime, amount);
 			cfs_b->runtime -= amount;
 			cfs_b->idle = 0;
-		}
+		} else
+			amount = 0;
 	}
 	expires = cfs_b->runtime_expires;
 	raw_spin_unlock(&cfs_b->lock);
 
+	if (cfs_rq->reserve_active != reserve_active) {
+		cfs_rq->reserve_active = reserve_active;
+		if (reserve_active)
+			cfs_rq->shares = cfs_b->reserve_shares;
+		else
+			cfs_rq->shares = tg->shares;
+		update_cfs_shares(cfs_rq);
+	}
+
 	cfs_rq->runtime_remaining += amount;
 	/*
 	 * we may have advanced our local expiration to account for allowed
@@ -3888,7 +3904,7 @@ static int do_sched_cfs_period_timer(struct cfs_bandwidth *cfs_b, int overrun)
 	int throttled;
 
 	/* no need to continue the timer with no bandwidth constraint */
-	if (cfs_b->quota == RUNTIME_INF)
+	if (cfs_b->quota == RUNTIME_INF && cfs_b->reserve == 0)
 		goto out_deactivate;
 
 	throttled = !list_empty(&cfs_b->throttled_cfs_rq);
@@ -3997,17 +4013,19 @@ static void __return_cfs_rq_runtime(struct cfs_rq *cfs_rq)
 {
 	struct cfs_bandwidth *cfs_b = tg_cfs_bandwidth(cfs_rq->tg);
 	s64 slack_runtime = cfs_rq->runtime_remaining - min_cfs_rq_runtime;
+	s64 slack_reserve = cfs_rq->reserve_active ? slack_runtime : 0;
 
 	if (slack_runtime <= 0)
 		return;
 
 	raw_spin_lock(&cfs_b->lock);
-	if (cfs_b->quota != RUNTIME_INF &&
-	    cfs_rq->runtime_expires == cfs_b->runtime_expires) {
+	if (cfs_rq->runtime_expires == cfs_b->runtime_expires) {
 		cfs_b->runtime += slack_runtime;
+		cfs_b->reserve_runtime += slack_reserve;
 
 		/* we are under rq->lock, defer unthrottling using a timer */
-		if (cfs_b->runtime > sched_cfs_bandwidth_slice() &&
+		if (cfs_b->quota != RUNTIME_INF &&
+		    cfs_b->runtime > sched_cfs_bandwidth_slice() &&
 		    !list_empty(&cfs_b->throttled_cfs_rq))
 			start_cfs_slack_bandwidth(cfs_b);
 	}
@@ -4142,6 +4160,9 @@ void init_cfs_bandwidth(struct cfs_bandwidth *cfs_b)
 	raw_spin_lock_init(&cfs_b->lock);
 	cfs_b->runtime = 0;
 	cfs_b->quota = RUNTIME_INF;
+	cfs_b->reserve = 0;
+	cfs_b->reserve_runtime = 0;
+	cfs_b->reserve_shares = NICE_0_LOAD;
 	cfs_b->period = ns_to_ktime(default_cfs_period());
 
 	INIT_LIST_HEAD(&cfs_b->throttled_cfs_rq);
@@ -4157,6 +4178,28 @@ static void init_cfs_rq_runtime(struct cfs_rq *cfs_rq)
 	INIT_LIST_HEAD(&cfs_rq->throttled_list);
 }
 
+static inline unsigned long tg_cfs_shares(struct task_group *tg)
+{
+	struct cfs_bandwidth *cfs_b = tg_cfs_bandwidth(tg);
+
+	if (cfs_bandwidth_used() && cfs_b->reserve_runtime > 0)
+		return cfs_b->reserve_shares;
+
+	return tg->shares;
+}
+
+static inline bool cfs_rq_reserve_active(struct cfs_rq *cfs_rq)
+{
+	return cfs_bandwidth_used() && cfs_rq->reserve_active;
+}
+
+void deactivate_cfs_rq_reserve(struct cfs_rq *cfs_rq)
+{
+	cfs_rq->reserve_active = 0;
+	cfs_rq->shares = cfs_rq->tg->shares;
+	update_cfs_shares(cfs_rq);
+}
+
 void start_cfs_bandwidth(struct cfs_bandwidth *cfs_b)
 {
 	lockdep_assert_held(&cfs_b->lock);
@@ -4186,7 +4229,8 @@ static void __maybe_unused update_runtime_enabled(struct rq *rq)
 		struct cfs_bandwidth *cfs_b = &cfs_rq->tg->cfs_bandwidth;
 
 		raw_spin_lock(&cfs_b->lock);
-		cfs_rq->runtime_enabled = cfs_b->quota != RUNTIME_INF;
+		cfs_rq->runtime_enabled = cfs_b->quota != RUNTIME_INF ||
+					  cfs_b->reserve != 0;
 		raw_spin_unlock(&cfs_b->lock);
 	}
 }
@@ -4246,6 +4290,14 @@ void init_cfs_bandwidth(struct cfs_bandwidth *cfs_b) {}
 
 #ifdef CONFIG_FAIR_GROUP_SCHED
 static void init_cfs_rq_runtime(struct cfs_rq *cfs_rq) {}
+static inline unsigned long tg_cfs_shares(struct task_group *tg)
+{
+	return tg->shares;
+}
+static inline bool cfs_rq_reserve_active(struct cfs_rq *cfs_rq)
+{
+	return false;
+}
 #endif
 
 static inline struct cfs_bandwidth *tg_cfs_bandwidth(struct task_group *tg)
@@ -4819,9 +4871,9 @@ static long effective_load(struct task_group *tg, int cpu, long wl, long wg)
 		 * wl = S * s'_i; see (2)
 		 */
 		if (W > 0 && w < W)
-			wl = (w * (long)tg->shares) / W;
+			wl = (w * (long)tg_cfs_shares(tg)) / W;
 		else
-			wl = tg->shares;
+			wl = tg_cfs_shares(tg);
 
 		/*
 		 * Per the above, wl is the new se->load.weight value; since
@@ -8474,7 +8526,8 @@ int sched_group_set_shares(struct task_group *tg, unsigned long shares)
 
 		/* Possible calls to update_curr() need rq clock */
 		update_rq_clock(rq);
-		group_cfs_rq(se)->shares = shares;
+		if (!cfs_rq_reserve_active(group_cfs_rq(se)))
+			group_cfs_rq(se)->shares = shares;
 		for_each_sched_entity(se)
 			update_cfs_shares(group_cfs_rq(se));
 		raw_spin_unlock_irqrestore(&rq->lock, flags);
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index e75e755ee5e9..80730e5620fb 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -224,9 +224,11 @@ struct cfs_bandwidth {
 	raw_spinlock_t lock;
 	ktime_t period;
 	u64 quota, runtime;
+	u64 reserve, reserve_runtime;
 	s64 hierarchical_quota;
 	u64 runtime_expires;
 
+	unsigned long reserve_shares;
 	int idle, period_active;
 	struct hrtimer period_timer, slack_timer;
 	struct list_head throttled_cfs_rq;
@@ -323,6 +325,7 @@ extern void init_cfs_bandwidth(struct cfs_bandwidth *cfs_b);
 extern void __refill_cfs_bandwidth_runtime(struct cfs_bandwidth *cfs_b);
 extern void start_cfs_bandwidth(struct cfs_bandwidth *cfs_b);
 extern void unthrottle_cfs_rq(struct cfs_rq *cfs_rq);
+extern void deactivate_cfs_rq_reserve(struct cfs_rq *cfs_rq);
 
 extern void free_rt_sched_group(struct task_group *tg);
 extern int alloc_rt_sched_group(struct task_group *tg, struct task_group *parent);
@@ -432,6 +435,7 @@ struct cfs_rq {
 	u64 throttled_clock, throttled_clock_task;
 	u64 throttled_clock_task_time;
 	int throttled, throttle_count;
+	int reserve_active;
 	struct list_head throttled_list;
 #endif /* CONFIG_CFS_BANDWIDTH */
 #endif /* CONFIG_FAIR_GROUP_SCHED */
