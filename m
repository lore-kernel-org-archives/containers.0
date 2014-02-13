From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 6/7] cgroup: drop task_lock() protection around task->cgroups
Date: Thu, 13 Feb 2014 15:28:52 -0500
Message-ID: <1392323333-18907-7-git-send-email-tj@kernel.org>
References: <1392323333-18907-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1392323333-18907-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

For optimization, task_lock() is additionally used to protect
task->cgroups.  The optimization is pretty dubious as either
css_set_rwsem is grabbed anyway or PF_EXITING already protects
task->cgroups.  It adds only overhead and confusion at this point.
Let's drop task_[un]lock() and update comments accordingly.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  6 ++--
 kernel/cgroup.c        | 97 +++++++++++++-------------------------------------
 2 files changed, 28 insertions(+), 75 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 366a2cc..588cc9a 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -650,10 +650,12 @@ struct cgroup_subsys_state *css_parent(struct cgroup_subsys_state *css)
  */
 #ifdef CONFIG_PROVE_RCU
 extern struct mutex cgroup_mutex;
+extern struct rw_semaphore css_set_rwsem;
 #define task_css_set_check(task, __c)					\
 	rcu_dereference_check((task)->cgroups,				\
-		lockdep_is_held(&(task)->alloc_lock) ||			\
-		lockdep_is_held(&cgroup_mutex) || (__c))
+		lockdep_is_held(&cgroup_mutex) ||			\
+		lockdep_is_held(&css_set_rwsem) ||			\
+		((task)->flags & PF_EXITING) || (__c))
 #else
 #define task_css_set_check(task, __c)					\
 	rcu_dereference((task)->cgroups)
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 1fdc38e..e373520 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -80,12 +80,21 @@ static DEFINE_MUTEX(cgroup_tree_mutex);
 /*
  * cgroup_mutex is the master lock.  Any modification to cgroup or its
  * hierarchy must be performed while holding it.
+ *
+ * css_set_rwsem protects task->cgroups pointer, the list of css_set
+ * objects, and the chain of tasks off each css_set.
+ *
+ * These locks are exported if CONFIG_PROVE_RCU so that accessors in
+ * cgroup.h can use them for lockdep annotations.
  */
 #ifdef CONFIG_PROVE_RCU
 DEFINE_MUTEX(cgroup_mutex);
-EXPORT_SYMBOL_GPL(cgroup_mutex);	/* only for lockdep */
+DECLARE_RWSEM(css_set_rwsem);
+EXPORT_SYMBOL_GPL(cgroup_mutex);
+EXPORT_SYMBOL_GPL(css_set_rwsem);
 #else
 static DEFINE_MUTEX(cgroup_mutex);
+static DECLARE_RWSEM(css_set_rwsem);
 #endif
 
 /*
@@ -338,12 +347,6 @@ struct cgrp_cset_link {
 
 static struct css_set init_css_set;
 static struct cgrp_cset_link init_cgrp_cset_link;
-
-/*
- * css_set_rwsem protects the list of css_set objects, and the chain of
- * tasks off each css_set.
- */
-static DECLARE_RWSEM(css_set_rwsem);
 static int css_set_count;
 
 /*
@@ -803,10 +806,6 @@ static struct cgroup *task_cgroup_from_root(struct task_struct *task,
 }
 
 /*
- * There is one global cgroup mutex. We also require taking
- * task_lock() when dereferencing a task's cgroup subsys pointers.
- * See "The task_lock() exception", at the end of this comment.
- *
  * A task must hold cgroup_mutex to modify cgroups.
  *
  * Any task can increment and decrement the count field without lock.
@@ -836,18 +835,6 @@ static struct cgroup *task_cgroup_from_root(struct task_struct *task,
  * always has either children cgroups and/or using tasks.  So we don't
  * need a special hack to ensure that top_cgroup cannot be deleted.
  *
- *	The task_lock() exception
- *
- * The need for this exception arises from the action of
- * cgroup_attach_task(), which overwrites one task's cgroup pointer with
- * another.  It does so using cgroup_mutex, however there are
- * several performance critical places that need to reference
- * task->cgroup without the expense of grabbing a system global
- * mutex.  Therefore except as noted below, when dereferencing or, as
- * in cgroup_attach_task(), modifying a task's cgroup pointer we use
- * task_lock(), which acts on a spinlock (task->alloc_lock) already in
- * the task_struct routinely used for such matters.
- *
  * P.S.  One more locking exception.  RCU is used to guard the
  * update of a tasks cgroup pointer by cgroup_attach_task()
  */
@@ -1329,8 +1316,6 @@ static void cgroup_enable_task_cg_lists(void)
 	 */
 	read_lock(&tasklist_lock);
 	do_each_thread(g, p) {
-		task_lock(p);
-
 		WARN_ON_ONCE(!list_empty(&p->cg_list) ||
 			     task_css_set(p) != &init_css_set);
 
@@ -1349,8 +1334,6 @@ static void cgroup_enable_task_cg_lists(void)
 			get_css_set(cset);
 		}
 		spin_unlock_irq(&p->sighand->siglock);
-
-		task_unlock(p);
 	} while_each_thread(g, p);
 	read_unlock(&tasklist_lock);
 out_unlock:
@@ -1741,11 +1724,7 @@ static void cgroup_task_migrate(struct cgroup *old_cgrp,
 	old_cset = task_css_set(tsk);
 
 	get_css_set(new_cset);
-
-	task_lock(tsk);
 	rcu_assign_pointer(tsk->cgroups, new_cset);
-	task_unlock(tsk);
-
 	list_move(&tsk->cg_list, &new_cset->mg_tasks);
 
 	/*
@@ -1997,8 +1976,7 @@ out_release_tset:
  * @leader: the task or the leader of the threadgroup to be attached
  * @threadgroup: attach the whole threadgroup?
  *
- * Call holding cgroup_mutex and the group_rwsem of the leader. Will take
- * task_lock of @tsk or each thread in the threadgroup individually in turn.
+ * Call holding cgroup_mutex and threadgroup_lock of @leader.
  */
 static int cgroup_attach_task(struct cgroup *dst_cgrp,
 			      struct task_struct *leader, bool threadgroup)
@@ -2032,7 +2010,7 @@ static int cgroup_attach_task(struct cgroup *dst_cgrp,
 /*
  * Find the task_struct of the task to attach by vpid and pass it along to the
  * function to attach either it or all tasks in its threadgroup. Will lock
- * cgroup_mutex and threadgroup; may take task_lock of task.
+ * cgroup_mutex and threadgroup.
  */
 static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 {
@@ -4152,12 +4130,6 @@ core_initcall(cgroup_wq_init);
  * proc_cgroup_show()
  *  - Print task's cgroup paths into seq_file, one line for each hierarchy
  *  - Used for /proc/<pid>/cgroup.
- *  - No need to task_lock(tsk) on this tsk->cgroup reference, as it
- *    doesn't really matter if tsk->cgroup changes after we read it,
- *    and we take cgroup_mutex, keeping cgroup_attach_task() from changing it
- *    anyway.  No need to check that tsk->cgroup != NULL, thanks to
- *    the_top_cgroup_hack in cgroup_exit(), which sets an exiting tasks
- *    cgroup to top_cgroup.
  */
 
 /* TODO: Use a proper seq_file iterator */
@@ -4307,15 +4279,12 @@ void cgroup_post_fork(struct task_struct *child)
 		struct css_set *cset;
 
 		down_write(&css_set_rwsem);
-		cset = task_css_set_check(current,
-					  lockdep_is_held(&css_set_rwsem));
-		task_lock(child);
+		cset = task_css_set(current);
 		if (list_empty(&child->cg_list)) {
 			rcu_assign_pointer(child->cgroups, cset);
 			list_add(&child->cg_list, &cset->tasks);
 			get_css_set(cset);
 		}
-		task_unlock(child);
 		up_write(&css_set_rwsem);
 	}
 
@@ -4344,27 +4313,13 @@ void cgroup_post_fork(struct task_struct *child)
  * use notify_on_release cgroups where very high task exit scaling
  * is required on large systems.
  *
- * the_top_cgroup_hack:
- *
- *    Set the exiting tasks cgroup to the root cgroup (top_cgroup).
- *
- *    We call cgroup_exit() while the task is still competent to
- *    handle notify_on_release(), then leave the task attached to the
- *    root cgroup in each hierarchy for the remainder of its exit.
- *
- *    To do this properly, we would increment the reference count on
- *    top_cgroup, and near the very end of the kernel/exit.c do_exit()
- *    code we would add a second cgroup function call, to drop that
- *    reference.  This would just create an unnecessary hot spot on
- *    the top_cgroup reference count, to no avail.
- *
- *    Normally, holding a reference to a cgroup without bumping its
- *    count is unsafe.   The cgroup could go away, or someone could
- *    attach us to a different cgroup, decrementing the count on
- *    the first cgroup that we never incremented.  But in this case,
- *    top_cgroup isn't going away, and either task has PF_EXITING set,
- *    which wards off any cgroup_attach_task() attempts, or task is a failed
- *    fork, never visible to cgroup_attach_task.
+ * We set the exiting tasks cgroup to the root cgroup (top_cgroup).  We
+ * call cgroup_exit() while the task is still competent to handle
+ * notify_on_release(), then leave the task attached to the root cgroup in
+ * each hierarchy for the remainder of its exit.  No need to bother with
+ * init_css_set refcnting.  init_css_set never goes away and we can't race
+ * with migration path - either PF_EXITING is visible to migration path or
+ * @tsk never got on the tasklist.
  */
 void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 {
@@ -4374,20 +4329,17 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 	int i;
 
 	/*
-	 * Unlink from the css_set task list if necessary.  Optimistically
-	 * check cg_list before taking css_set_rwsem.
+	 * Unlink from @tsk from its css_set.  As migration path can't race
+	 * with us, we can check cg_list without grabbing css_set_rwsem.
 	 */
 	if (!list_empty(&tsk->cg_list)) {
 		down_write(&css_set_rwsem);
-		if (!list_empty(&tsk->cg_list)) {
-			list_del_init(&tsk->cg_list);
-			put_cset = true;
-		}
+		list_del_init(&tsk->cg_list);
 		up_write(&css_set_rwsem);
+		put_cset = true;
 	}
 
 	/* Reassign the task to the init_css_set. */
-	task_lock(tsk);
 	cset = task_css_set(tsk);
 	RCU_INIT_POINTER(tsk->cgroups, &init_css_set);
 
@@ -4402,7 +4354,6 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 			}
 		}
 	}
-	task_unlock(tsk);
 
 	if (put_cset)
 		put_css_set(cset, true);
-- 
1.8.5.3
