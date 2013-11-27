From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 01/12] cgroup, sched: convert away from cftype->read_map()
Date: Wed, 27 Nov 2013 18:42:28 -0500
Message-ID: <1385595759-17656-2-git-send-email-tj__38812.1475735263$1385595779$gmane$org@kernel.org>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1385595759-17656-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

In preparation of conversion to kernfs, cgroup file handling is being
consolidated so that it can be easily mapped to the seq_file based
interface of kernfs.

cftype->read_map() doesn't add any value and being replaced with
->read_seq_string().  Update cpu_stats_show() and cpuacct_stats_show()
accordingly.

This patch doesn't make any visible behavior changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
---
 kernel/sched/core.c    | 10 +++++-----
 kernel/sched/cpuacct.c |  8 ++++----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index c180860..f28ec67 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7257,14 +7257,14 @@ static int __cfs_schedulable(struct task_group *tg, u64 period, u64 quota)
 }
 
 static int cpu_stats_show(struct cgroup_subsys_state *css, struct cftype *cft,
-		struct cgroup_map_cb *cb)
+			  struct seq_file *sf)
 {
 	struct task_group *tg = css_tg(css);
 	struct cfs_bandwidth *cfs_b = &tg->cfs_bandwidth;
 
-	cb->fill(cb, "nr_periods", cfs_b->nr_periods);
-	cb->fill(cb, "nr_throttled", cfs_b->nr_throttled);
-	cb->fill(cb, "throttled_time", cfs_b->throttled_time);
+	seq_printf(sf, "nr_periods %d\n", cfs_b->nr_periods);
+	seq_printf(sf, "nr_throttled %d\n", cfs_b->nr_throttled);
+	seq_printf(sf, "throttled_time %llu\n", cfs_b->throttled_time);
 
 	return 0;
 }
@@ -7318,7 +7318,7 @@ static struct cftype cpu_files[] = {
 	},
 	{
 		.name = "stat",
-		.read_map = cpu_stats_show,
+		.read_seq_string = cpu_stats_show,
 	},
 #endif
 #ifdef CONFIG_RT_GROUP_SCHED
diff --git a/kernel/sched/cpuacct.c b/kernel/sched/cpuacct.c
index f64722f..dd88738 100644
--- a/kernel/sched/cpuacct.c
+++ b/kernel/sched/cpuacct.c
@@ -184,7 +184,7 @@ static const char * const cpuacct_stat_desc[] = {
 };
 
 static int cpuacct_stats_show(struct cgroup_subsys_state *css,
-			      struct cftype *cft, struct cgroup_map_cb *cb)
+			      struct cftype *cft, struct seq_file *sf)
 {
 	struct cpuacct *ca = css_ca(css);
 	int cpu;
@@ -196,7 +196,7 @@ static int cpuacct_stats_show(struct cgroup_subsys_state *css,
 		val += kcpustat->cpustat[CPUTIME_NICE];
 	}
 	val = cputime64_to_clock_t(val);
-	cb->fill(cb, cpuacct_stat_desc[CPUACCT_STAT_USER], val);
+	seq_printf(sf, "%s %lld\n", cpuacct_stat_desc[CPUACCT_STAT_USER], val);
 
 	val = 0;
 	for_each_online_cpu(cpu) {
@@ -207,7 +207,7 @@ static int cpuacct_stats_show(struct cgroup_subsys_state *css,
 	}
 
 	val = cputime64_to_clock_t(val);
-	cb->fill(cb, cpuacct_stat_desc[CPUACCT_STAT_SYSTEM], val);
+	seq_printf(sf, "%s %lld\n", cpuacct_stat_desc[CPUACCT_STAT_SYSTEM], val);
 
 	return 0;
 }
@@ -224,7 +224,7 @@ static struct cftype files[] = {
 	},
 	{
 		.name = "stat",
-		.read_map = cpuacct_stats_show,
+		.read_seq_string = cpuacct_stats_show,
 	},
 	{ }	/* terminate */
 };
-- 
1.8.4.2
