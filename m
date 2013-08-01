From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/23] cpuset: drop "const" qualifiers from struct cpuset
	instances
Date: Thu,  1 Aug 2013 17:49:40 -0400
Message-ID: <1375393801-4817-3-git-send-email-tj@kernel.org>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375393801-4817-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cpuset uses "const" qualifiers on struct cpuset in some functions;
however, it doesn't work well when a value derived from returned const
pointer has to be passed to an accessor.  It's C after all.

Drop the "const" qualifiers except for the trivially leaf ones.  This
patch doesn't make any functional changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index be4512b..f737134 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -128,7 +128,7 @@ static inline struct cpuset *task_cs(struct task_struct *task)
 			    struct cpuset, css);
 }
 
-static inline struct cpuset *parent_cs(const struct cpuset *cs)
+static inline struct cpuset *parent_cs(struct cpuset *cs)
 {
 	struct cgroup *pcgrp = cs->css.cgroup->parent;
 
@@ -319,8 +319,7 @@ static struct file_system_type cpuset_fs_type = {
  *
  * Call with callback_mutex held.
  */
-static void guarantee_online_cpus(const struct cpuset *cs,
-				  struct cpumask *pmask)
+static void guarantee_online_cpus(struct cpuset *cs, struct cpumask *pmask)
 {
 	while (!cpumask_intersects(cs->cpus_allowed, cpu_online_mask))
 		cs = parent_cs(cs);
@@ -338,7 +337,7 @@ static void guarantee_online_cpus(const struct cpuset *cs,
  *
  * Call with callback_mutex held.
  */
-static void guarantee_online_mems(const struct cpuset *cs, nodemask_t *pmask)
+static void guarantee_online_mems(struct cpuset *cs, nodemask_t *pmask)
 {
 	while (!nodes_intersects(cs->mems_allowed, node_states[N_MEMORY]))
 		cs = parent_cs(cs);
@@ -383,7 +382,7 @@ static int is_cpuset_subset(const struct cpuset *p, const struct cpuset *q)
  * alloc_trial_cpuset - allocate a trial cpuset
  * @cs: the cpuset that the trial cpuset duplicates
  */
-static struct cpuset *alloc_trial_cpuset(const struct cpuset *cs)
+static struct cpuset *alloc_trial_cpuset(struct cpuset *cs)
 {
 	struct cpuset *trial;
 
@@ -430,7 +429,7 @@ static void free_trial_cpuset(struct cpuset *trial)
  * Return 0 if valid, -errno if not.
  */
 
-static int validate_change(const struct cpuset *cur, const struct cpuset *trial)
+static int validate_change(struct cpuset *cur, struct cpuset *trial)
 {
 	struct cgroup *cgrp;
 	struct cpuset *c, *par;
@@ -2343,7 +2342,7 @@ void cpuset_cpus_allowed(struct task_struct *tsk, struct cpumask *pmask)
 
 void cpuset_cpus_allowed_fallback(struct task_struct *tsk)
 {
-	const struct cpuset *cpus_cs;
+	struct cpuset *cpus_cs;
 
 	rcu_read_lock();
 	cpus_cs = effective_cpumask_cpuset(task_cs(tsk));
@@ -2416,7 +2415,7 @@ int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
  * callback_mutex.  If no ancestor is mem_exclusive or mem_hardwall
  * (an unusual configuration), then returns the root cpuset.
  */
-static const struct cpuset *nearest_hardwall_ancestor(const struct cpuset *cs)
+static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
 {
 	while (!(is_mem_exclusive(cs) || is_mem_hardwall(cs)) && parent_cs(cs))
 		cs = parent_cs(cs);
@@ -2486,7 +2485,7 @@ static const struct cpuset *nearest_hardwall_ancestor(const struct cpuset *cs)
  */
 int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
 {
-	const struct cpuset *cs;	/* current cpuset ancestors */
+	struct cpuset *cs;		/* current cpuset ancestors */
 	int allowed;			/* is allocation in zone z allowed? */
 
 	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
-- 
1.8.3.1
