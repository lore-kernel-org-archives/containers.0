From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 11/13] cpuset: pin down cpus and mems while a task is being
	attached
Date: Thu,  3 Jan 2013 13:36:05 -0800
Message-ID: <1357248967-24959-12-git-send-email-tj__32051.7066670165$1357249066$gmane$org@kernel.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cpuset is scheduled to be decoupled from cgroup_lock which will make
configuration updates race with task migration.  Any config update
will be allowed to happen between ->can_attach() and ->attach().  If
such config update removes either all cpus or mems, by the time
->attach() is called, the condition verified by ->can_attach(), that
the cpuset is capable of hosting the tasks, is no longer true.

This patch adds cpuset->attach_in_progress which is incremented from
->can_attach() and decremented when the attach operation finishes
either successfully or not.  validate_change() treats cpusets w/
non-zero ->attach_in_progress like cpusets w/ tasks and refuses to
remove all cpus or mems from it.

This currently doesn't make any functional difference as everything is
protected by cgroup_mutex but enables decoupling the locking.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cpuset.c | 28 ++++++++++++++++++++++++++--
 1 file changed, 26 insertions(+), 2 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 2d0b9bc..27e8614 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -91,6 +91,12 @@ struct cpuset {
 
 	struct fmeter fmeter;		/* memory_pressure filter */
 
+	/*
+	 * Tasks are being attached to this cpuset.  Used to prevent
+	 * zeroing cpus/mems_allowed between ->can_attach() and ->attach().
+	 */
+	int attach_in_progress;
+
 	/* partition number for rebuild_sched_domains() */
 	int pn;
 
@@ -468,9 +474,12 @@ static int validate_change(const struct cpuset *cur, const struct cpuset *trial)
 			goto out;
 	}
 
-	/* Cpusets with tasks can't have empty cpus_allowed or mems_allowed */
+	/*
+	 * Cpusets with tasks - existing or newly being attached - can't
+	 * have empty cpus_allowed or mems_allowed.
+	 */
 	ret = -ENOSPC;
-	if (cgroup_task_count(cur->css.cgroup) &&
+	if ((cgroup_task_count(cur->css.cgroup) || cur->attach_in_progress) &&
 	    (cpumask_empty(trial->cpus_allowed) ||
 	     nodes_empty(trial->mems_allowed)))
 		goto out;
@@ -1386,9 +1395,21 @@ static int cpuset_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 			return ret;
 	}
 
+	/*
+	 * Mark attach is in progress.  This makes validate_change() fail
+	 * changes which zero cpus/mems_allowed.
+	 */
+	cs->attach_in_progress++;
+
 	return 0;
 }
 
+static void cpuset_cancel_attach(struct cgroup *cgrp,
+				 struct cgroup_taskset *tset)
+{
+	cgroup_cs(cgrp)->attach_in_progress--;
+}
+
 /*
  * Protected by cgroup_mutex.  cpus_attach is used only by cpuset_attach()
  * but we can't allocate it dynamically there.  Define it global and
@@ -1441,6 +1462,8 @@ static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 					  &cpuset_attach_nodemask_to);
 		mmput(mm);
 	}
+
+	cs->attach_in_progress--;
 }
 
 /* The various types of files and directories in a cpuset file system */
@@ -1908,6 +1931,7 @@ struct cgroup_subsys cpuset_subsys = {
 	.css_offline = cpuset_css_offline,
 	.css_free = cpuset_css_free,
 	.can_attach = cpuset_can_attach,
+	.cancel_attach = cpuset_cancel_attach,
 	.attach = cpuset_attach,
 	.subsys_id = cpuset_subsys_id,
 	.base_cftypes = files,
-- 
1.8.0.2
