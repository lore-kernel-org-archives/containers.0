From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: fix cgroup_iter_next() bug.
Date: Fri, 21 Nov 2008 16:49:20 +0800
Message-ID: <49267610.6090003__23006.783592473$1227258295$gmane$org@cn.fujitsu.com>
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


we access to res->cgroups without the task_lock(),
so res->cgroups may be changed. it's unreliable,
and "if (l == &res->cgroups->tasks)" may be false forever.

we don't need add any lock for fixing this bug. we just access to
struct css_set by struct cg_cgroup_link, not by struct task_struct.

since we hold css_set_lock, struct cg_cgroup_link is reliable.

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 358e775..ddc10ac 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1810,6 +1819,7 @@ struct task_struct *cgroup_iter_next(struct cgroup *cgrp,
 {
 	struct task_struct *res;
 	struct list_head *l = it->task;
+	struct cg_cgroup_link *link;
 
 	/* If the iterator cg is NULL, we have no tasks */
 	if (!it->cg_link)
@@ -1817,7 +1827,8 @@ struct task_struct *cgroup_iter_next(struct cgroup *cgrp,
 	res = list_entry(l, struct task_struct, cg_list);
 	/* Advance iterator to find next entry */
 	l = l->next;
-	if (l == &res->cgroups->tasks) {
+	link = list_entry(it->cg_link, struct cg_cgroup_link, cgrp_link_list);
+	if (l == &link->cg->tasks) {
 		/* We reached the end of this task list - move on to
 		 * the next cg_cgroup_link */
 		cgroup_advance_iter(cgrp, it);
