From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH cgroup/for-3.15] cgroup: fix cgroup_taskset walking order
Date: Wed, 19 Mar 2014 17:45:56 -0400
Message-ID: <20140319214556.GD3656@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From 1b9aba49eab5e85b0d3de8ba630cda6d68546297 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Wed, 19 Mar 2014 17:43:21 -0400

cgroup_taskset is used to track and iterate target tasks while
migrating a task or process and should guarantee that the first task
iterated is the task group leader if a process is being migrated.

b3dc094e9390 ("cgroup: use css_set->mg_tasks to track target tasks
during migration") replaced flex array cgroup_taskset->tc_array with
css_set->mg_tasks list to remove process size limit and dynamic
allocation during migration; unfortunately, it incorrectly used list
operations which don't preserve order breaking the guarantee that
cgroup_taskset_first() returns the leader for a process target.

Fix it by using order preserving list operations.  Note that as
multiple src_csets may map to a single dst_cset, the iteration order
may change across cgroup_task_migrate(); however, the leader is still
guaranteed to be the first entry.

The switch to list_splice_tail_init() at the end of cgroup_migrate()
isn't strictly necessary.  Let's still do it for consistency.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
Li, as the merge window is right around the corner, I think it'd be
best to apply this one ASAP.  Applied to cgroup/for-3.15.

Thanks.

 kernel/cgroup.c | 24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 37b6d53..98a8045 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1761,7 +1761,14 @@ static void cgroup_task_migrate(struct cgroup *old_cgrp,
 
 	get_css_set(new_cset);
 	rcu_assign_pointer(tsk->cgroups, new_cset);
-	list_move(&tsk->cg_list, &new_cset->mg_tasks);
+
+	/*
+	 * Use move_tail so that cgroup_taskset_first() still returns the
+	 * leader after migration.  This works because cgroup_migrate()
+	 * ensures that the dst_cset of the leader is the first on the
+	 * tset's dst_csets list.
+	 */
+	list_move_tail(&tsk->cg_list, &new_cset->mg_tasks);
 
 	/*
 	 * We just gained a reference on old_cset by taking it from the
@@ -1936,9 +1943,16 @@ static int cgroup_migrate(struct cgroup *cgrp, struct task_struct *leader,
 		if (!cset->mg_src_cgrp)
 			goto next;
 
-		list_move(&task->cg_list, &cset->mg_tasks);
-		list_move(&cset->mg_node, &tset.src_csets);
-		list_move(&cset->mg_dst_cset->mg_node, &tset.dst_csets);
+		/*
+		 * cgroup_taskset_first() must always return the leader.
+		 * Take care to avoid disturbing the ordering.
+		 */
+		list_move_tail(&task->cg_list, &cset->mg_tasks);
+		if (list_empty(&cset->mg_node))
+			list_add_tail(&cset->mg_node, &tset.src_csets);
+		if (list_empty(&cset->mg_dst_cset->mg_node))
+			list_move_tail(&cset->mg_dst_cset->mg_node,
+				       &tset.dst_csets);
 	next:
 		if (!threadgroup)
 			break;
@@ -1999,7 +2013,7 @@ out_release_tset:
 	down_write(&css_set_rwsem);
 	list_splice_init(&tset.dst_csets, &tset.src_csets);
 	list_for_each_entry_safe(cset, tmp_cset, &tset.src_csets, mg_node) {
-		list_splice_init(&cset->mg_tasks, &cset->tasks);
+		list_splice_tail_init(&cset->mg_tasks, &cset->tasks);
 		list_del_init(&cset->mg_node);
 	}
 	up_write(&css_set_rwsem);
-- 
1.8.5.3
