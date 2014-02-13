From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 5/7] cgroup: update how a newly forked task gets associated
	with css_set
Date: Thu, 13 Feb 2014 15:28:51 -0500
Message-ID: <1392323333-18907-6-git-send-email-tj@kernel.org>
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

When a new process is forked, cgroup_fork() associates it with the
css_set of its parent but doesn't link it into it.  After the new
process is linked to tasklist, cgroup_post_fork() does the linking.

This is problematic for cgroup_transfer_tasks() as there's no way to
tell whether there are tasks which are pointing to a css_set but not
linked yet.  It is impossible to implement an operation which transfer
all tasks of a cgroup to another and the current
cgroup_transfer_tasks() can easily be tricked into leaving a newly
forked process behind if it gets called between cgroup_fork() and
cgroup_post_fork().

Let's make association with a css_set and linking atomic by moving it
to cgroup_post_fork().  cgroup_fork() sets child->cgroups to
init_css_set as a placeholder and cgroup_post_fork() is updated to
perform both the association with the parent's cgroup and linking
there.  This means that a newly created task will point to
init_css_set without holding a ref to it much like what it does on the
exit path.  Empty cg_list is used to indicate that the task isn't
holding a ref to the associated css_set.

This fixes an actual bug with cgroup_transfer_tasks(); however, I'm
not marking it for -stable.  The whole thing is broken in multiple
other ways which require invasive updates to fix and I don't think
it's worthwhile to bother with backporting this particular one.
Fortunately, the only user is cpuset and these bugs don't crash the
machine.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 86 ++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 55 insertions(+), 31 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index aca3661..1fdc38e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1342,8 +1342,12 @@ static void cgroup_enable_task_cg_lists(void)
 		 * racing against cgroup_exit().
 		 */
 		spin_lock_irq(&p->sighand->siglock);
-		if (!(p->flags & PF_EXITING))
-			list_add(&p->cg_list, &task_css_set(p)->tasks);
+		if (!(p->flags & PF_EXITING)) {
+			struct css_set *cset = task_css_set(p);
+
+			list_add(&p->cg_list, &cset->tasks);
+			get_css_set(cset);
+		}
 		spin_unlock_irq(&p->sighand->siglock);
 
 		task_unlock(p);
@@ -1909,6 +1913,10 @@ static int cgroup_migrate(struct cgroup *cgrp, struct task_struct *leader,
 		if (task->flags & PF_EXITING)
 			goto next;
 
+		/* leave @task alone if post_fork() hasn't linked it yet */
+		if (list_empty(&task->cg_list))
+			goto next;
+
 		cset = task_css_set(task);
 		if (!cset->mg_src_cgrp)
 			goto next;
@@ -2812,6 +2820,12 @@ void css_task_iter_end(struct css_task_iter *it)
  * cgroup_trasnsfer_tasks - move tasks from one cgroup to another
  * @to: cgroup to which the tasks will be moved
  * @from: cgroup in which the tasks currently reside
+ *
+ * Locking rules between cgroup_post_fork() and the migration path
+ * guarantee that, if a task is forking while being migrated, the new child
+ * is guaranteed to be either visible in the source cgroup after the
+ * parent's migration is complete or put into the target cgroup.  No task
+ * can slip out of migration through forking.
  */
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from)
 {
@@ -4240,27 +4254,16 @@ static const struct file_operations proc_cgroupstats_operations = {
 };
 
 /**
- * cgroup_fork - attach newly forked task to its parents cgroup.
+ * cgroup_fork - initialize cgroup related fields during copy_process()
  * @child: pointer to task_struct of forking parent process.
  *
- * Description: A task inherits its parent's cgroup at fork().
- *
- * A pointer to the shared css_set was automatically copied in
- * fork.c by dup_task_struct().  However, we ignore that copy, since
- * it was not made under the protection of RCU or cgroup_mutex, so
- * might no longer be a valid cgroup pointer.  cgroup_attach_task() might
- * have already changed current->cgroups, allowing the previously
- * referenced cgroup group to be removed and freed.
- *
- * At the point that cgroup_fork() is called, 'current' is the parent
- * task, and the passed argument 'child' points to the child task.
+ * A task is associated with the init_css_set until cgroup_post_fork()
+ * attaches it to the parent's css_set.  Empty cg_list indicates that
+ * @child isn't holding reference to its css_set.
  */
 void cgroup_fork(struct task_struct *child)
 {
-	task_lock(current);
-	get_css_set(task_css_set(current));
-	child->cgroups = current->cgroups;
-	task_unlock(current);
+	RCU_INIT_POINTER(child->cgroups, &init_css_set);
 	INIT_LIST_HEAD(&child->cg_list);
 }
 
@@ -4280,21 +4283,38 @@ void cgroup_post_fork(struct task_struct *child)
 	int i;
 
 	/*
-	 * use_task_css_set_links is set to 1 before we walk the tasklist
-	 * under the tasklist_lock and we read it here after we added the child
-	 * to the tasklist under the tasklist_lock as well. If the child wasn't
-	 * yet in the tasklist when we walked through it from
-	 * cgroup_enable_task_cg_lists(), then use_task_css_set_links value
-	 * should be visible now due to the paired locking and barriers implied
-	 * by LOCK/UNLOCK: it is written before the tasklist_lock unlock
-	 * in cgroup_enable_task_cg_lists() and read here after the tasklist_lock
-	 * lock on fork.
+	 * This may race against cgroup_enable_task_cg_links().  As that
+	 * function sets use_task_css_set_links before grabbing
+	 * tasklist_lock and we just went through tasklist_lock to add
+	 * @child, it's guaranteed that either we see the set
+	 * use_task_css_set_links or cgroup_enable_task_cg_lists() sees
+	 * @child during its iteration.
+	 *
+	 * If we won the race, @child is associated with %current's
+	 * css_set.  Grabbing css_set_rwsem guarantees both that the
+	 * association is stable, and, on completion of the parent's
+	 * migration, @child is visible in the source of migration or
+	 * already in the destination cgroup.  This guarantee is necessary
+	 * when implementing operations which need to migrate all tasks of
+	 * a cgroup to another.
+	 *
+	 * Note that if we lose to cgroup_enable_task_cg_links(), @child
+	 * will remain in init_css_set.  This is safe because all tasks are
+	 * in the init_css_set before cg_links is enabled and there's no
+	 * operation which transfers all tasks out of init_css_set.
 	 */
 	if (use_task_css_set_links) {
+		struct css_set *cset;
+
 		down_write(&css_set_rwsem);
+		cset = task_css_set_check(current,
+					  lockdep_is_held(&css_set_rwsem));
 		task_lock(child);
-		if (list_empty(&child->cg_list))
-			list_add(&child->cg_list, &task_css_set(child)->tasks);
+		if (list_empty(&child->cg_list)) {
+			rcu_assign_pointer(child->cgroups, cset);
+			list_add(&child->cg_list, &cset->tasks);
+			get_css_set(cset);
+		}
 		task_unlock(child);
 		up_write(&css_set_rwsem);
 	}
@@ -4350,6 +4370,7 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 {
 	struct cgroup_subsys *ss;
 	struct css_set *cset;
+	bool put_cset = false;
 	int i;
 
 	/*
@@ -4358,8 +4379,10 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 	 */
 	if (!list_empty(&tsk->cg_list)) {
 		down_write(&css_set_rwsem);
-		if (!list_empty(&tsk->cg_list))
+		if (!list_empty(&tsk->cg_list)) {
 			list_del_init(&tsk->cg_list);
+			put_cset = true;
+		}
 		up_write(&css_set_rwsem);
 	}
 
@@ -4381,7 +4404,8 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 	}
 	task_unlock(tsk);
 
-	put_css_set(cset, true);
+	if (put_cset)
+		put_css_set(cset, true);
 }
 
 static void check_for_release(struct cgroup *cgrp)
-- 
1.8.5.3
