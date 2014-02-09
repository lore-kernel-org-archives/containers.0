From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 11/16] cgroup: move css_set_rwsem locking outside of
	cgroup_task_migrate()
Date: Sun,  9 Feb 2014 08:52:39 -0500
Message-ID: <1391953964-22088-12-git-send-email-tj__16185.6445287869$1391954077$gmane$org@kernel.org>
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

Instead of repeatedly locking and unlocking css_set_rwsem inside
cgroup_task_migrate(), update cgroup_attach_task() to grab it outside
of the loop and update cgroup_task_migrate() to use
put_css_set_locked().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 63d1a4e..ac78311 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1713,10 +1713,13 @@ int cgroup_taskset_size(struct cgroup_taskset *tset)
 EXPORT_SYMBOL_GPL(cgroup_taskset_size);
 
 
-/*
+/**
  * cgroup_task_migrate - move a task from one cgroup to another.
+ * @old_cgrp; the cgroup @tsk is being migrated from
+ * @tsk: the task being migrated
+ * @new_cset: the new css_set @tsk is being attached to
  *
- * Must be called with cgroup_mutex and threadgroup locked.
+ * Must be called with cgroup_mutex, threadgroup and css_set_rwsem locked.
  */
 static void cgroup_task_migrate(struct cgroup *old_cgrp,
 				struct task_struct *tsk,
@@ -1724,6 +1727,9 @@ static void cgroup_task_migrate(struct cgroup *old_cgrp,
 {
 	struct css_set *old_cset;
 
+	lockdep_assert_held(&cgroup_mutex);
+	lockdep_assert_held(&css_set_rwsem);
+
 	/*
 	 * We are synchronized through threadgroup_lock() against PF_EXITING
 	 * setting such that we can't race against cgroup_exit() changing the
@@ -1737,9 +1743,7 @@ static void cgroup_task_migrate(struct cgroup *old_cgrp,
 	task_unlock(tsk);
 
 	/* Update the css_set linked lists if we're using them */
-	down_write(&css_set_rwsem);
 	list_move(&tsk->cg_list, &new_cset->tasks);
-	up_write(&css_set_rwsem);
 
 	/*
 	 * We just gained a reference on old_cset by taking it from the
@@ -1747,7 +1751,7 @@ static void cgroup_task_migrate(struct cgroup *old_cgrp,
 	 * we're safe to drop it here; it will be freed under RCU.
 	 */
 	set_bit(CGRP_RELEASABLE, &old_cgrp->flags);
-	put_css_set(old_cset, false);
+	put_css_set_locked(old_cset, false);
 }
 
 /**
@@ -1870,10 +1874,12 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
 	 * proceed to move all tasks to the new cgroup.  There are no
 	 * failure cases after here, so this is the commit point.
 	 */
+	down_write(&css_set_rwsem);
 	for (i = 0; i < group_size; i++) {
 		tc = flex_array_get(group, i);
 		cgroup_task_migrate(tc->cgrp, tc->task, tc->cset);
 	}
+	up_write(&css_set_rwsem);
 	/* nothing is sensitive to fork() after this point. */
 
 	/*
-- 
1.8.5.3
