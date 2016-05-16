From: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Subject: [PATCH RFC 1/3] sched/fair: call __refill_cfs_bandwidth_runtime
	only for finite quota
Date: Mon, 16 May 2016 12:36:26 +0300
Message-ID: <146339138652.25295.12568582885578664992.stgit__41260.8018880293$1463392041$gmane$org@buzz>
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

Both call sites (tg_set_cfs_bandwidth and do_sched_cfs_period_timer)
already have checks for infinite quota.

Signed-off-by: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
---
 kernel/sched/core.c |    5 +++--
 kernel/sched/fair.c |    6 +-----
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index d1f7149f8704..355698188ea9 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -8196,10 +8196,11 @@ static int tg_set_cfs_bandwidth(struct task_group *tg, u64 period, u64 quota)
 	cfs_b->period = ns_to_ktime(period);
 	cfs_b->quota = quota;
 
-	__refill_cfs_bandwidth_runtime(cfs_b);
 	/* restart the period timer (if active) to handle new period expiry */
-	if (runtime_enabled)
+	if (runtime_enabled) {
+		__refill_cfs_bandwidth_runtime(cfs_b);
 		start_cfs_bandwidth(cfs_b);
+	}
 	raw_spin_unlock_irq(&cfs_b->lock);
 
 	for_each_online_cpu(i) {
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index e7dd0ec169be..d26b631a9a1d 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -3559,12 +3559,8 @@ static inline u64 sched_cfs_bandwidth_slice(void)
  */
 void __refill_cfs_bandwidth_runtime(struct cfs_bandwidth *cfs_b)
 {
-	u64 now;
+	u64 now = sched_clock_cpu(smp_processor_id());
 
-	if (cfs_b->quota == RUNTIME_INF)
-		return;
-
-	now = sched_clock_cpu(smp_processor_id());
 	cfs_b->runtime = cfs_b->quota;
 	cfs_b->runtime_expires = now + ktime_to_ns(cfs_b->period);
 }
