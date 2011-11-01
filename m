From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 09/10] cgroup, cpuset: don't use ss->pre_attach()
Date: Tue,  1 Nov 2011 16:46:32 -0700
Message-ID: <1320191193-8110-10-git-send-email-tj@kernel.org>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1320191193-8110-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

->pre_attach() is supposed to be called before migration, which is
observed during process migration but task migration does it the other
way around.  The only ->pre_attach() user is cpuset which can do the
same operaitons in ->can_attach().  Collapse cpuset_pre_attach() into
cpuset_can_attach().

-v2: Patch contamination from later patch removed.  Spotted by Paul
     Menage.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cpuset.c |   29 ++++++++++++-----------------
 1 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 472ddd6..f0b8df3 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1367,6 +1367,15 @@ static int fmeter_getrate(struct fmeter *fmp)
 	return val;
 }
 
+/*
+ * Protected by cgroup_lock. The nodemasks must be stored globally because
+ * dynamically allocating them is not allowed in can_attach, and they must
+ * persist until attach.
+ */
+static cpumask_var_t cpus_attach;
+static nodemask_t cpuset_attach_nodemask_from;
+static nodemask_t cpuset_attach_nodemask_to;
+
 /* Called by cgroups to determine if a cpuset is usable; cgroup_mutex held */
 static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			     struct cgroup_taskset *tset)
@@ -1393,29 +1402,16 @@ static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 		if ((ret = security_task_setscheduler(task)))
 			return ret;
 	}
-	return 0;
-}
-
-/*
- * Protected by cgroup_lock. The nodemasks must be stored globally because
- * dynamically allocating them is not allowed in pre_attach, and they must
- * persist among pre_attach, and attach.
- */
-static cpumask_var_t cpus_attach;
-static nodemask_t cpuset_attach_nodemask_from;
-static nodemask_t cpuset_attach_nodemask_to;
-
-/* Set-up work for before attaching each task. */
-static void cpuset_pre_attach(struct cgroup *cont)
-{
-	struct cpuset *cs = cgroup_cs(cont);
 
+	/* prepare for attach */
 	if (cs == &top_cpuset)
 		cpumask_copy(cpus_attach, cpu_possible_mask);
 	else
 		guarantee_online_cpus(cs, cpus_attach);
 
 	guarantee_online_mems(cs, &cpuset_attach_nodemask_to);
+
+	return 0;
 }
 
 static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
@@ -1901,7 +1897,6 @@ struct cgroup_subsys cpuset_subsys = {
 	.create = cpuset_create,
 	.destroy = cpuset_destroy,
 	.can_attach = cpuset_can_attach,
-	.pre_attach = cpuset_pre_attach,
 	.attach = cpuset_attach,
 	.populate = cpuset_populate,
 	.post_clone = cpuset_post_clone,
-- 
1.7.3.1
