From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 02/11] cpuset: add cs->real_cpus_allowed and
	cs->real_mems_allowed
Date: Wed, 21 Aug 2013 17:59:11 +0800
Message-ID: <52148F6F.4070507__27633.639452006$1377079363$gmane$org@huawei.com>
References: <52148F52.0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <52148F52.0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

We're going to have separate user-configured masks and effective ones.

At last configured masks can only be changed by writing cpuset.cpus
and cpuset.mems, and they won't be restricted by parent cpuset. While
effective masks reflect cpu/memory hotplug and hierachical restriction.

This patch adds and initializes the effective masks. The effective
masks of the top cpuset is the same with configured masks, and a child
cpuset inherites its parent's effective masks.

This won't introduce behavior change.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 46 insertions(+), 11 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 70ab3fd..404fea5 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -81,8 +81,14 @@ struct cpuset {
 	struct cgroup_subsys_state css;
 
 	unsigned long flags;		/* "unsigned long" so bitops work */
-	cpumask_var_t cpus_allowed;	/* CPUs allowed to tasks in cpuset */
-	nodemask_t mems_allowed;	/* Memory Nodes allowed to tasks */
+
+	/* user-configured CPUs and Memory Nodes allow to tasks */
+	cpumask_var_t cpus_allowed;
+	nodemask_t mems_allowed;
+
+	/* effective CPUs and Memory Nodes allow to tasks */
+	cpumask_var_t real_cpus_allowed;
+	nodemask_t real_mems_allowed;
 
 	/*
 	 * This is old Memory Nodes tasks took on.
@@ -381,13 +387,20 @@ static struct cpuset *alloc_trial_cpuset(struct cpuset *cs)
 	if (!trial)
 		return NULL;
 
-	if (!alloc_cpumask_var(&trial->cpus_allowed, GFP_KERNEL)) {
-		kfree(trial);
-		return NULL;
-	}
-	cpumask_copy(trial->cpus_allowed, cs->cpus_allowed);
+	if (!alloc_cpumask_var(&trial->cpus_allowed, GFP_KERNEL))
+		goto free_cs;
+	if (!alloc_cpumask_var(&trial->real_cpus_allowed, GFP_KERNEL))
+		goto free_cpus;
 
+	cpumask_copy(trial->cpus_allowed, cs->cpus_allowed);
+	cpumask_copy(trial->real_cpus_allowed, cs->real_cpus_allowed);
 	return trial;
+
+free_cpus:
+	free_cpumask_var(trial->cpus_allowed);
+free_cs:
+	kfree(trial);
+	return NULL;
 }
 
 /**
@@ -396,6 +409,7 @@ static struct cpuset *alloc_trial_cpuset(struct cpuset *cs)
  */
 static void free_trial_cpuset(struct cpuset *trial)
 {
+	free_cpumask_var(trial->real_cpus_allowed);
 	free_cpumask_var(trial->cpus_allowed);
 	kfree(trial);
 }
@@ -1949,18 +1963,26 @@ cpuset_css_alloc(struct cgroup_subsys_state *parent_css)
 	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
 	if (!cs)
 		return ERR_PTR(-ENOMEM);
-	if (!alloc_cpumask_var(&cs->cpus_allowed, GFP_KERNEL)) {
-		kfree(cs);
-		return ERR_PTR(-ENOMEM);
-	}
+	if (!alloc_cpumask_var(&cs->cpus_allowed, GFP_KERNEL))
+		goto free_cs;
+	if (!alloc_cpumask_var(&cs->real_cpus_allowed, GFP_KERNEL))
+		goto free_cpus;
 
 	set_bit(CS_SCHED_LOAD_BALANCE, &cs->flags);
 	cpumask_clear(cs->cpus_allowed);
 	nodes_clear(cs->mems_allowed);
+	cpumask_clear(cs->real_cpus_allowed);
+	nodes_clear(cs->real_mems_allowed);
 	fmeter_init(&cs->fmeter);
 	cs->relax_domain_level = -1;
 
 	return &cs->css;
+
+free_cpus:
+	free_cpumask_var(cs->cpus_allowed);
+free_cs:
+	kfree(cs);
+	return ERR_PTR(-ENOMEM);
 }
 
 static int cpuset_css_online(struct cgroup_subsys_state *css)
@@ -1983,6 +2005,11 @@ static int cpuset_css_online(struct cgroup_subsys_state *css)
 
 	number_of_cpusets++;
 
+	mutex_lock(&callback_mutex);
+	cpumask_copy(cs->real_cpus_allowed, parent->real_cpus_allowed);
+	cs->real_mems_allowed = parent->real_mems_allowed;
+	mutex_unlock(&callback_mutex);
+
 	if (!test_bit(CGRP_CPUSET_CLONE_CHILDREN, &css->cgroup->flags))
 		goto out_unlock;
 
@@ -2042,6 +2069,7 @@ static void cpuset_css_free(struct cgroup_subsys_state *css)
 {
 	struct cpuset *cs = css_cs(css);
 
+	free_cpumask_var(cs->real_cpus_allowed);
 	free_cpumask_var(cs->cpus_allowed);
 	kfree(cs);
 }
@@ -2072,9 +2100,13 @@ int __init cpuset_init(void)
 
 	if (!alloc_cpumask_var(&top_cpuset.cpus_allowed, GFP_KERNEL))
 		BUG();
+	if (!alloc_cpumask_var(&top_cpuset.real_cpus_allowed, GFP_KERNEL))
+		BUG();
 
 	cpumask_setall(top_cpuset.cpus_allowed);
 	nodes_setall(top_cpuset.mems_allowed);
+	cpumask_setall(top_cpuset.real_cpus_allowed);
+	nodes_setall(top_cpuset.real_mems_allowed);
 
 	fmeter_init(&top_cpuset.fmeter);
 	set_bit(CS_SCHED_LOAD_BALANCE, &top_cpuset.flags);
@@ -2312,6 +2344,9 @@ void __init cpuset_init_smp(void)
 	top_cpuset.mems_allowed = node_states[N_MEMORY];
 	top_cpuset.old_mems_allowed = top_cpuset.mems_allowed;
 
+	cpumask_copy(top_cpuset.real_cpus_allowed, cpu_active_mask);
+	top_cpuset.real_mems_allowed = node_states[N_MEMORY];
+
 	register_hotmemory_notifier(&cpuset_track_online_nodes_nb);
 }
 
-- 
1.8.0.2
