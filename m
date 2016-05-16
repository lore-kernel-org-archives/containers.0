From: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Subject: [PATCH RFC 2/3] sched/fair: copy taskgroup shares to each cfs_rq
Date: Mon, 16 May 2016 12:36:31 +0300
Message-ID: <146339139131.25295.4898290002699620951.stgit__18709.8569972024$1463391920$gmane$org@buzz>
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

This will be used for tweaking shares in runtime.

Signed-off-by: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
---
 kernel/sched/fair.c  |   12 +++++++-----
 kernel/sched/sched.h |    1 +
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index d26b631a9a1d..5bf34532d364 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2469,21 +2469,21 @@ static long calc_cfs_shares(struct cfs_rq *cfs_rq, struct task_group *tg)
 	tg_weight = calc_tg_weight(tg, cfs_rq);
 	load = cfs_rq->load.weight;
 
-	shares = (tg->shares * load);
+	shares = (cfs_rq->shares * load);
 	if (tg_weight)
 		shares /= tg_weight;
 
 	if (shares < MIN_SHARES)
 		shares = MIN_SHARES;
-	if (shares > tg->shares)
-		shares = tg->shares;
+	if (shares > cfs_rq->shares)
+		shares = cfs_rq->shares;
 
 	return shares;
 }
 # else /* CONFIG_SMP */
 static inline long calc_cfs_shares(struct cfs_rq *cfs_rq, struct task_group *tg)
 {
-	return tg->shares;
+	return cfs_rq->shares;
 }
 # endif /* CONFIG_SMP */
 static void reweight_entity(struct cfs_rq *cfs_rq, struct sched_entity *se,
@@ -2515,7 +2515,7 @@ static void update_cfs_shares(struct cfs_rq *cfs_rq)
 	if (!se || throttled_hierarchy(cfs_rq))
 		return;
 #ifndef CONFIG_SMP
-	if (likely(se->load.weight == tg->shares))
+	if (likely(se->load.weight == cfs_rq->shares))
 		return;
 #endif
 	shares = calc_cfs_shares(cfs_rq, tg);
@@ -8439,6 +8439,7 @@ void init_tg_cfs_entry(struct task_group *tg, struct cfs_rq *cfs_rq,
 
 	se->my_q = cfs_rq;
 	/* guarantee group entities always have weight */
+	cfs_rq->shares = NICE_0_LOAD;
 	update_load_set(&se->load, NICE_0_LOAD);
 	se->parent = parent;
 }
@@ -8473,6 +8474,7 @@ int sched_group_set_shares(struct task_group *tg, unsigned long shares)
 
 		/* Possible calls to update_curr() need rq clock */
 		update_rq_clock(rq);
+		group_cfs_rq(se)->shares = shares;
 		for_each_sched_entity(se)
 			update_cfs_shares(group_cfs_rq(se));
 		raw_spin_unlock_irqrestore(&rq->lock, flags);
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index ec2e8d23527e..e75e755ee5e9 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -422,6 +422,7 @@ struct cfs_rq {
 	int on_list;
 	struct list_head leaf_cfs_rq_list;
 	struct task_group *tg;	/* group that "owns" this runqueue */
+	unsigned long shares;
 
 #ifdef CONFIG_CFS_BANDWIDTH
 	int runtime_enabled;
