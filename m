From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/13] cpuset: cleanup cpuset[_can]_attach()
Date: Thu,  3 Jan 2013 13:36:00 -0800
Message-ID: <1357248967-24959-7-git-send-email-tj__35635.246980428$1357249036$gmane$org@kernel.org>
References: <1357248967-24959-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1357248967-24959-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cpuset_can_attach() prepare global variables cpus_attach and
cpuset_attach_nodemask_{to|from} which are used by cpuset_attach().
There is no reason to prepare in cpuset_can_attach().  The same
information can be accessed from cpuset_attach().

Move the prepartion logic from cpuset_can_attach() to cpuset_attach()
and make the global variables static ones inside cpuset_attach().

With this change, there's no reason to keep
cpuset_attach_nodemask_{from|to} global.  Move them inside
cpuset_attach().  Unfortunately, we need to keep cpus_attach global as
it can't be allocated from cpuset_attach().

v2: cpus_attach not converted to cpumask_t as per Li Zefan and Rusty
    Russell.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 35 ++++++++++++++++++-----------------
 1 file changed, 18 insertions(+), 17 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 4b054b9..c5edc6b 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1395,15 +1395,6 @@ static int fmeter_getrate(struct fmeter *fmp)
 	return val;
 }
 
-/*
- * Protected by cgroup_lock. The nodemasks must be stored globally because
- * dynamically allocating them is not allowed in can_attach, and they must
- * persist until attach.
- */
-static cpumask_var_t cpus_attach;
-static nodemask_t cpuset_attach_nodemask_from;
-static nodemask_t cpuset_attach_nodemask_to;
-
 /* Called by cgroups to determine if a cpuset is usable; cgroup_mutex held */
 static int cpuset_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 {
@@ -1430,19 +1421,21 @@ static int cpuset_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 			return ret;
 	}
 
-	/* prepare for attach */
-	if (cs == &top_cpuset)
-		cpumask_copy(cpus_attach, cpu_possible_mask);
-	else
-		guarantee_online_cpus(cs, cpus_attach);
-
-	guarantee_online_mems(cs, &cpuset_attach_nodemask_to);
-
 	return 0;
 }
 
+/*
+ * Protected by cgroup_mutex.  cpus_attach is used only by cpuset_attach()
+ * but we can't allocate it dynamically there.  Define it global and
+ * allocate from cpuset_init().
+ */
+static cpumask_var_t cpus_attach;
+
 static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 {
+	/* static bufs protected by cgroup_mutex */
+	static nodemask_t cpuset_attach_nodemask_from;
+	static nodemask_t cpuset_attach_nodemask_to;
 	struct mm_struct *mm;
 	struct task_struct *task;
 	struct task_struct *leader = cgroup_taskset_first(tset);
@@ -1450,6 +1443,14 @@ static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 	struct cpuset *cs = cgroup_cs(cgrp);
 	struct cpuset *oldcs = cgroup_cs(oldcgrp);
 
+	/* prepare for attach */
+	if (cs == &top_cpuset)
+		cpumask_copy(cpus_attach, cpu_possible_mask);
+	else
+		guarantee_online_cpus(cs, cpus_attach);
+
+	guarantee_online_mems(cs, &cpuset_attach_nodemask_to);
+
 	cgroup_taskset_for_each(task, cgrp, tset) {
 		/*
 		 * can_attach beforehand should guarantee that this doesn't
-- 
1.8.0.2
