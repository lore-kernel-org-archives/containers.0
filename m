From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cpuset: rename cont to cgrp
Date: Fri, 14 Jun 2013 11:18:27 +0800
Message-ID: <51BA8B83.8090607__20017.8994135515$1371179928$gmane$org@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Cont is short for container. control group was named process container
at first, but then people found container already has a meaning in
linux kernel.

Clean up the leftover variable name @cont.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 3be9597..171fe5c 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -116,9 +116,9 @@ struct cpuset {
 };
 
 /* Retrieve the cpuset for a cgroup */
-static inline struct cpuset *cgroup_cs(struct cgroup *cont)
+static inline struct cpuset *cgroup_cs(struct cgroup *cgrp)
 {
-	return container_of(cgroup_subsys_state(cont, cpuset_subsys_id),
+	return container_of(cgroup_subsys_state(cgrp, cpuset_subsys_id),
 			    struct cpuset, css);
 }
 
@@ -433,7 +433,7 @@ static void free_trial_cpuset(struct cpuset *trial)
 
 static int validate_change(const struct cpuset *cur, const struct cpuset *trial)
 {
-	struct cgroup *cont;
+	struct cgroup *cgrp;
 	struct cpuset *c, *par;
 	int ret;
 
@@ -441,7 +441,7 @@ static int validate_change(const struct cpuset *cur, const struct cpuset *trial)
 
 	/* Each of our child cpusets must be a subset of us */
 	ret = -EBUSY;
-	cpuset_for_each_child(c, cont, cur)
+	cpuset_for_each_child(c, cgrp, cur)
 		if (!is_cpuset_subset(c, trial))
 			goto out;
 
@@ -462,7 +462,7 @@ static int validate_change(const struct cpuset *cur, const struct cpuset *trial)
 	 * overlap
 	 */
 	ret = -EINVAL;
-	cpuset_for_each_child(c, cont, par) {
+	cpuset_for_each_child(c, cgrp, par) {
 		if ((is_cpu_exclusive(trial) || is_cpu_exclusive(c)) &&
 		    c != cur &&
 		    cpumask_intersects(trial->cpus_allowed, c->cpus_allowed))
@@ -1759,13 +1759,13 @@ static size_t cpuset_sprintf_memlist(char *page, struct cpuset *cs)
 	return count;
 }
 
-static ssize_t cpuset_common_file_read(struct cgroup *cont,
+static ssize_t cpuset_common_file_read(struct cgroup *cgrp,
 				       struct cftype *cft,
 				       struct file *file,
 				       char __user *buf,
 				       size_t nbytes, loff_t *ppos)
 {
-	struct cpuset *cs = cgroup_cs(cont);
+	struct cpuset *cs = cgroup_cs(cgrp);
 	cpuset_filetype_t type = cft->private;
 	char *page;
 	ssize_t retval = 0;
@@ -1795,9 +1795,9 @@ out:
 	return retval;
 }
 
-static u64 cpuset_read_u64(struct cgroup *cont, struct cftype *cft)
+static u64 cpuset_read_u64(struct cgroup *cgrp, struct cftype *cft)
 {
-	struct cpuset *cs = cgroup_cs(cont);
+	struct cpuset *cs = cgroup_cs(cgrp);
 	cpuset_filetype_t type = cft->private;
 	switch (type) {
 	case FILE_CPU_EXCLUSIVE:
@@ -1826,9 +1826,9 @@ static u64 cpuset_read_u64(struct cgroup *cont, struct cftype *cft)
 	return 0;
 }
 
-static s64 cpuset_read_s64(struct cgroup *cont, struct cftype *cft)
+static s64 cpuset_read_s64(struct cgroup *cgrp, struct cftype *cft)
 {
-	struct cpuset *cs = cgroup_cs(cont);
+	struct cpuset *cs = cgroup_cs(cgrp);
 	cpuset_filetype_t type = cft->private;
 	switch (type) {
 	case FILE_SCHED_RELAX_DOMAIN_LEVEL:
@@ -1940,14 +1940,14 @@ static struct cftype files[] = {
 
 /*
  *	cpuset_css_alloc - allocate a cpuset css
- *	cont:	control group that the new cpuset will be part of
+ *	cgrp:	control group that the new cpuset will be part of
  */
 
-static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cont)
+static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cgrp)
 {
 	struct cpuset *cs;
 
-	if (!cont->parent)
+	if (!cgrp->parent)
 		return &top_cpuset.css;
 
 	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
@@ -2042,9 +2042,9 @@ static void cpuset_css_offline(struct cgroup *cgrp)
  * will call rebuild_sched_domains_locked().
  */
 
-static void cpuset_css_free(struct cgroup *cont)
+static void cpuset_css_free(struct cgroup *cgrp)
 {
-	struct cpuset *cs = cgroup_cs(cont);
+	struct cpuset *cs = cgroup_cs(cgrp);
 
 	free_cpumask_var(cs->cpus_allowed);
 	kfree(cs);
-- 
1.8.0.2
