From: Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 2/5] Fix minor bug in yield + add more debug o/p
Date: Mon, 24 Sep 2007 22:08:26 +0530
Message-ID: <20070924163826.GC10291@linux.vnet.ibm.com>
References: <20070924163326.GA10291@linux.vnet.ibm.com>
Reply-To: vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070924163326.GA10291-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: efault-Mmb7MZpHnFY@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


- Fix a minor bug in yield (seen for CONFIG_FAIR_GROUP_SCHED)
- Print nr_running and load information for cfs_rq in /proc/sched_debug
- Print &rq->cfs statistics as well (usefull for group scheduling)


Signed-off-by : Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by : Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>


---
 kernel/sched_debug.c |    2 ++
 kernel/sched_fair.c  |    3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

Index: current/kernel/sched_debug.c
===================================================================
--- current.orig/kernel/sched_debug.c
+++ current/kernel/sched_debug.c
@@ -136,6 +136,8 @@ void print_cfs_rq(struct seq_file *m, in
 			SPLIT_NS(spread0));
 	SEQ_printf(m, "  .%-30s: %ld\n", "spread0",
 			cfs_rq->nr_sync_min_vruntime);
+	SEQ_printf(m, "  .%-30s: %ld\n", "nr_running", cfs_rq->nr_running);
+	SEQ_printf(m, "  .%-30s: %ld\n", "load", cfs_rq->load.weight);
 }
 
 static void print_cpu(struct seq_file *m, int cpu)
Index: current/kernel/sched_fair.c
===================================================================
--- current.orig/kernel/sched_fair.c
+++ current/kernel/sched_fair.c
@@ -726,7 +726,7 @@ static void dequeue_task_fair(struct rq 
  */
 static void yield_task_fair(struct rq *rq)
 {
-	struct cfs_rq *cfs_rq = &rq->cfs;
+	struct cfs_rq *cfs_rq = task_cfs_rq(rq->curr);
 	struct rb_node **link = &cfs_rq->tasks_timeline.rb_node;
 	struct sched_entity *rightmost, *se = &rq->curr->se;
 	struct rb_node *parent;
@@ -1025,6 +1025,7 @@ static void print_cfs_stats(struct seq_f
 {
 	struct cfs_rq *cfs_rq;
 
+	print_cfs_rq(m, cpu, &cpu_rq(cpu)->cfs);
 	for_each_leaf_cfs_rq(cpu_rq(cpu), cfs_rq)
 		print_cfs_rq(m, cpu, cfs_rq);
 }

-- 
Regards,
vatsa
