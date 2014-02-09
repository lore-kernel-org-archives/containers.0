From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 14/16] cgroup: remove cgroup_taskset_cur_css() and
	cgroup_taskset_size()
Date: Sun,  9 Feb 2014 08:52:42 -0500
Message-ID: <1391953964-22088-15-git-send-email-tj__6818.83396250686$1391954099$gmane$org@kernel.org>
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

The two functions don't have any users left.  Remove them along with
cgroup_taskset->cur_cgrp.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  3 ---
 kernel/cgroup.c        | 30 ------------------------------
 2 files changed, 33 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 3c67883..21887b6 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -526,9 +526,6 @@ bool cgroup_is_descendant(struct cgroup *cgrp, struct cgroup *ancestor);
 struct cgroup_taskset;
 struct task_struct *cgroup_taskset_first(struct cgroup_taskset *tset);
 struct task_struct *cgroup_taskset_next(struct cgroup_taskset *tset);
-struct cgroup_subsys_state *cgroup_taskset_cur_css(struct cgroup_taskset *tset,
-						   int subsys_id);
-int cgroup_taskset_size(struct cgroup_taskset *tset);
 
 /**
  * cgroup_taskset_for_each - iterate cgroup_taskset
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ac78311..0108753 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1645,7 +1645,6 @@ struct cgroup_taskset {
 	struct flex_array	*tc_array;
 	int			tc_array_len;
 	int			idx;
-	struct cgroup		*cur_cgrp;
 };
 
 /**
@@ -1660,7 +1659,6 @@ struct task_struct *cgroup_taskset_first(struct cgroup_taskset *tset)
 		tset->idx = 0;
 		return cgroup_taskset_next(tset);
 	} else {
-		tset->cur_cgrp = tset->single.cgrp;
 		return tset->single.task;
 	}
 }
@@ -1681,39 +1679,11 @@ struct task_struct *cgroup_taskset_next(struct cgroup_taskset *tset)
 		return NULL;
 
 	tc = flex_array_get(tset->tc_array, tset->idx++);
-	tset->cur_cgrp = tc->cgrp;
 	return tc->task;
 }
 EXPORT_SYMBOL_GPL(cgroup_taskset_next);
 
 /**
- * cgroup_taskset_cur_css - return the matching css for the current task
- * @tset: taskset of interest
- * @subsys_id: the ID of the target subsystem
- *
- * Return the css for the current (last returned) task of @tset for
- * subsystem specified by @subsys_id.  This function must be preceded by
- * either cgroup_taskset_first() or cgroup_taskset_next().
- */
-struct cgroup_subsys_state *cgroup_taskset_cur_css(struct cgroup_taskset *tset,
-						   int subsys_id)
-{
-	return cgroup_css(tset->cur_cgrp, cgroup_subsys[subsys_id]);
-}
-EXPORT_SYMBOL_GPL(cgroup_taskset_cur_css);
-
-/**
- * cgroup_taskset_size - return the number of tasks in taskset
- * @tset: taskset of interest
- */
-int cgroup_taskset_size(struct cgroup_taskset *tset)
-{
-	return tset->tc_array ? tset->tc_array_len : 1;
-}
-EXPORT_SYMBOL_GPL(cgroup_taskset_size);
-
-
-/**
  * cgroup_task_migrate - move a task from one cgroup to another.
  * @old_cgrp; the cgroup @tsk is being migrated from
  * @tsk: the task being migrated
-- 
1.8.5.3
