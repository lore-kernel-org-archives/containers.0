From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 13/16] cpuset: don't use cgroup_taskset_cur_css()
Date: Sun,  9 Feb 2014 08:52:41 -0500
Message-ID: <1391953964-22088-14-git-send-email-tj__45814.5421384417$1391954095$gmane$org@kernel.org>
References: <1391953964-22088-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391953964-22088-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

cgroup_taskset_cur_css() will be removed during the planned
resturcturing of migration path.  The only use of
cgroup_taskset_cur_css() is finding out the old cgroup_subsys_state of
the leader in cpuset_attach().  This usage can easily be removed by
remembering the old value from cpuset_can_attach().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index bf20e4a..d8bec21 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1379,6 +1379,8 @@ static int fmeter_getrate(struct fmeter *fmp)
 	return val;
 }
 
+static struct cpuset *cpuset_attach_old_cs;
+
 /* Called by cgroups to determine if a cpuset is usable; cpuset_mutex held */
 static int cpuset_can_attach(struct cgroup_subsys_state *css,
 			     struct cgroup_taskset *tset)
@@ -1387,6 +1389,9 @@ static int cpuset_can_attach(struct cgroup_subsys_state *css,
 	struct task_struct *task;
 	int ret;
 
+	/* used later by cpuset_attach() */
+	cpuset_attach_old_cs = task_cs(cgroup_taskset_first(tset));
+
 	mutex_lock(&cpuset_mutex);
 
 	/*
@@ -1450,10 +1455,8 @@ static void cpuset_attach(struct cgroup_subsys_state *css,
 	struct mm_struct *mm;
 	struct task_struct *task;
 	struct task_struct *leader = cgroup_taskset_first(tset);
-	struct cgroup_subsys_state *oldcss = cgroup_taskset_cur_css(tset,
-							cpuset_cgrp_id);
 	struct cpuset *cs = css_cs(css);
-	struct cpuset *oldcs = css_cs(oldcss);
+	struct cpuset *oldcs = cpuset_attach_old_cs;
 	struct cpuset *cpus_cs = effective_cpumask_cpuset(cs);
 	struct cpuset *mems_cs = effective_nodemask_cpuset(cs);
 
-- 
1.8.5.3
