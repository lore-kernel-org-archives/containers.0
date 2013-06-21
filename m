From: Tejun Heo <theo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH cgroup/for-3.11 2/3] cgroup: fix RCU accesses around
	task->cgroups
Date: Fri, 21 Jun 2013 15:52:04 -0700
Message-ID: <20130621225204.GD3949@htj.dyndns.org>
References: <20130621225116.GC3949@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130621225116.GC3949-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

There are several places in kernel/cgroup.c where task->cgroups is
accessed and modified without going through proper RCU accessors.
None is broken as they're all lock protected accesses; however, this
still triggers sparse RCU address space warnings.

* Consistently use task_css_set() for task->cgroups dereferencing.

* Use RCU_INIT_POINTER() to clear task->cgroups to &init_css_set on
  exit.

* Remove unnecessary rcu_dereference_raw() from cset->subsys[]
  dereference in cgroup_exit().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Reported-by: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 kernel/cgroup.c |   24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -704,7 +704,7 @@ static struct cgroup *task_cgroup_from_r
 	 * task can't change groups, so the only thing that can happen
 	 * is that it exits and its css is set back to init_css_set.
 	 */
-	cset = task->cgroups;
+	cset = task_css_set(task);
 	if (cset == &init_css_set) {
 		res = &root->top_cgroup;
 	} else {
@@ -1948,7 +1948,7 @@ static void cgroup_task_migrate(struct c
 	 * css_set to init_css_set and dropping the old one.
 	 */
 	WARN_ON_ONCE(tsk->flags & PF_EXITING);
-	old_cset = tsk->cgroups;
+	old_cset = task_css_set(tsk);
 
 	task_lock(tsk);
 	rcu_assign_pointer(tsk->cgroups, new_cset);
@@ -2071,8 +2071,11 @@ static int cgroup_attach_task(struct cgr
 	 * we use find_css_set, which allocates a new one if necessary.
 	 */
 	for (i = 0; i < group_size; i++) {
+		struct css_set *old_cset;
+
 		tc = flex_array_get(group, i);
-		tc->cg = find_css_set(tc->task->cgroups, cgrp);
+		old_cset = task_css_set(tc->task);
+		tc->cg = find_css_set(old_cset, cgrp);
 		if (!tc->cg) {
 			retval = -ENOMEM;
 			goto out_put_css_set_refs;
@@ -2989,7 +2992,7 @@ static void cgroup_enable_task_cg_lists(
 		 * entry won't be deleted though the process has exited.
 		 */
 		if (!(p->flags & PF_EXITING) && list_empty(&p->cg_list))
-			list_add(&p->cg_list, &p->cgroups->tasks);
+			list_add(&p->cg_list, &task_css_set(p)->tasks);
 		task_unlock(p);
 	} while_each_thread(g, p);
 	read_unlock(&tasklist_lock);
@@ -5046,8 +5049,8 @@ static const struct file_operations proc
 void cgroup_fork(struct task_struct *child)
 {
 	task_lock(current);
+	get_css_set(task_css_set(current));
 	child->cgroups = current->cgroups;
-	get_css_set(child->cgroups);
 	task_unlock(current);
 	INIT_LIST_HEAD(&child->cg_list);
 }
@@ -5081,7 +5084,7 @@ void cgroup_post_fork(struct task_struct
 		write_lock(&css_set_lock);
 		task_lock(child);
 		if (list_empty(&child->cg_list))
-			list_add(&child->cg_list, &child->cgroups->tasks);
+			list_add(&child->cg_list, &task_css_set(child)->tasks);
 		task_unlock(child);
 		write_unlock(&css_set_lock);
 	}
@@ -5163,8 +5166,8 @@ void cgroup_exit(struct task_struct *tsk
 
 	/* Reassign the task to the init_css_set. */
 	task_lock(tsk);
-	cset = tsk->cgroups;
-	tsk->cgroups = &init_css_set;
+	cset = task_css_set(tsk);
+	RCU_INIT_POINTER(tsk->cgroups, &init_css_set);
 
 	if (run_callbacks && need_forkexit_callback) {
 		/*
@@ -5175,8 +5178,7 @@ void cgroup_exit(struct task_struct *tsk
 			struct cgroup_subsys *ss = subsys[i];
 
 			if (ss->exit) {
-				struct cgroup *old_cgrp =
-					rcu_dereference_raw(cset->subsys[i])->cgroup;
+				struct cgroup *old_cgrp = cset->subsys[i]->cgroup;
 				struct cgroup *cgrp = task_cgroup(tsk, i);
 				ss->exit(cgrp, old_cgrp, tsk);
 			}
@@ -5546,7 +5548,7 @@ static u64 current_css_set_refcount_read
 	u64 count;
 
 	rcu_read_lock();
-	count = atomic_read(&current->cgroups->refcount);
+	count = atomic_read(&task_css_set(current)->refcount);
 	rcu_read_unlock();
 	return count;
 }
