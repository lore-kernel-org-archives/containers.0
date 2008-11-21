From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: call find_css_set() safely in cgroup_attach_task()
Date: Fri, 21 Nov 2008 16:49:59 +0800
Message-ID: <49267637.1020404__13815.8118505546$1227258502$gmane$org@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers@lists.l>
List-Id: containers.vger.kernel.org


in cgroup_attach_task(), tsk maybe exit when we call find_css_set().
and find_css_set() will access to invalid css_set.

this patch increase the count before get_css_set(), and decrease it
after find_css_set().

NOTICE:
css_set's refcount is also taskcount, after this patch applied, taskcount
may be off-by-one WHEN cgroup_lock() is not held.
but I reviewed other code which use taskcount, they are still correct.
No regression found by reviewing and simply testing.

So I do not use two counters in css_set.
(one counter for taskcount, the other for refcount. like struct mm_struct)
If this fix cause regression, we will use two counters in css_set.

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 358e775..ddc10ac 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1217,7 +1222,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	int retval = 0;
 	struct cgroup_subsys *ss;
 	struct cgroup *oldcgrp;
-	struct css_set *cg = tsk->cgroups;
+	struct css_set *cg;
 	struct css_set *newcg;
 	struct cgroupfs_root *root = cgrp->root;
 	int subsys_id;
@@ -1237,11 +1242,16 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 		}
 	}
 
+	task_lock(tsk);
+	cg = tsk->cgroups;
+	get_css_set(cg);
+	task_unlock(tsk);
 	/*
 	 * Locate or allocate a new css_set for this task,
 	 * based on its final set of cgroups
 	 */
 	newcg = find_css_set(cg, cgrp);
+	put_css_set(cg);
 	if (!newcg)
 		return -ENOMEM;
