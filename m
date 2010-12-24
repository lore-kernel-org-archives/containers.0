From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [PATCH v6 3/3] cgroups: make procs file writable
Date: Fri, 24 Dec 2010 03:24:45 -0500
Message-ID: <20101224082445.GD13872@ghc17.ghc.andrew.cmu.edu>
References: <20100730235649.GA22644@ghc17.ghc.andrew.cmu.edu>
	<20100811054604.GA8743@ghc17.ghc.andrew.cmu.edu>
	<20101224082226.GA13872@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: attachment; filename="cgroup-procs-writable.patch"
In-Reply-To: <20101224082226.GA13872-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Makes procs file writable to move all threads by tgid at once

From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

This patch adds functionality that enables users to move all threads in a
threadgroup at once to a cgroup by writing the tgid to the 'cgroup.procs'
file. This current implementation makes use of a per-threadgroup rwsem that's
taken for reading in the fork() path to prevent newly forking threads within
the threadgroup from "escaping" while the move is in progress.

Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |   13 +
 kernel/cgroup.c                   |  424 +++++++++++++++++++++++++++++++++----
 2 files changed, 387 insertions(+), 50 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 190018b..07674e5 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -236,7 +236,8 @@ containing the following files describing that cgroup:
  - cgroup.procs: list of tgids in the cgroup.  This list is not
    guaranteed to be sorted or free of duplicate tgids, and userspace
    should sort/uniquify the list if this property is required.
-   This is a read-only file, for now.
+   Writing a thread group id into this file moves all threads in that
+   group into this cgroup.
  - notify_on_release flag: run the release agent on exit?
  - release_agent: the path to use for release notifications (this file
    exists in the top cgroup only)
@@ -426,6 +427,12 @@ You can attach the current shell task by echoing 0:
 
 # echo 0 > tasks
 
+You can use the cgroup.procs file instead of the tasks file to move all
+threads in a threadgroup at once. Echoing the pid of any task in a
+threadgroup to cgroup.procs causes all tasks in that threadgroup to be
+be attached to the cgroup. Writing 0 to cgroup.procs moves all tasks
+in the writing task's threadgroup.
+
 2.3 Mounting hierarchies by name
 --------------------------------
 
@@ -574,7 +581,9 @@ called on a fork. If this method returns 0 (success) then this should
 remain valid while the caller holds cgroup_mutex and it is ensured that either
 attach() or cancel_attach() will be called in future. If threadgroup is
 true, then a successful result indicates that all threads in the given
-thread's threadgroup can be moved together.
+thread's threadgroup can be moved together. If the subsystem wants to
+iterate over task->thread_group, it must take rcu_read_lock then check
+if thread_group_leader(task), returning -EAGAIN if that fails.
 
 void cancel_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	       struct task_struct *task, bool threadgroup)
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f86dd9c..74be02c 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1771,6 +1771,76 @@ int cgroup_can_attach_per_thread(struct cgroup *cgrp, struct task_struct *task,
 }
 EXPORT_SYMBOL_GPL(cgroup_can_attach_per_thread);
 
+/*
+ * cgroup_task_migrate - move a task from one cgroup to another.
+ *
+ * 'guarantee' is set if the caller promises that a new css_set for the task
+ * will already exit. If not set, this function might sleep, and can fail with
+ * -ENOMEM. Otherwise, it can only fail with -ESRCH.
+ */
+static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
+			       struct task_struct *tsk, bool guarantee)
+{
+	struct css_set *oldcg;
+	struct css_set *newcg;
+
+	/*
+	 * get old css_set. we need to take task_lock and refcount it, because
+	 * an exiting task can change its css_set to init_css_set and drop its
+	 * old one without taking cgroup_mutex.
+	 */
+	task_lock(tsk);
+	oldcg = tsk->cgroups;
+	get_css_set(oldcg);
+	task_unlock(tsk);
+
+	/* locate or allocate a new css_set for this task. */
+	if (guarantee) {
+		/* we know the css_set we want already exists. */
+		struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
+		read_lock(&css_set_lock);
+		newcg = find_existing_css_set(oldcg, cgrp, template);
+		BUG_ON(!newcg);
+		get_css_set(newcg);
+		read_unlock(&css_set_lock);
+	} else {
+		might_sleep();
+		/* find_css_set will give us newcg already referenced. */
+		newcg = find_css_set(oldcg, cgrp);
+		if (!newcg) {
+			put_css_set(oldcg);
+			return -ENOMEM;
+		}
+	}
+	put_css_set(oldcg);
+
+	/* if PF_EXITING is set, the tsk->cgroups pointer is no longer safe. */
+	task_lock(tsk);
+	if (tsk->flags & PF_EXITING) {
+		task_unlock(tsk);
+		put_css_set(newcg);
+		return -ESRCH;
+	}
+	rcu_assign_pointer(tsk->cgroups, newcg);
+	task_unlock(tsk);
+
+	/* Update the css_set linked lists if we're using them */
+	write_lock(&css_set_lock);
+	if (!list_empty(&tsk->cg_list))
+		list_move(&tsk->cg_list, &newcg->tasks);
+	write_unlock(&css_set_lock);
+
+	/*
+	 * We just gained a reference on oldcg by taking it from the task. As
+	 * trading it for newcg is protected by cgroup_mutex, we're safe to drop
+	 * it here; it will be freed under RCU.
+	 */
+	put_css_set(oldcg);
+
+	set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
+	return 0;
+}
+
 /**
  * cgroup_attach_task - attach task 'tsk' to cgroup 'cgrp'
  * @cgrp: the cgroup the task is attaching to
@@ -1781,11 +1851,9 @@ EXPORT_SYMBOL_GPL(cgroup_can_attach_per_thread);
  */
 int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 {
-	int retval = 0;
+	int retval;
 	struct cgroup_subsys *ss, *failed_ss = NULL;
 	struct cgroup *oldcgrp;
-	struct css_set *cg;
-	struct css_set *newcg;
 	struct cgroupfs_root *root = cgrp->root;
 
 	/* Nothing to do if the task is already in that cgroup */
@@ -1809,46 +1877,16 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 		}
 	}
 
-	task_lock(tsk);
-	cg = tsk->cgroups;
-	get_css_set(cg);
-	task_unlock(tsk);
-	/*
-	 * Locate or allocate a new css_set for this task,
-	 * based on its final set of cgroups
-	 */
-	newcg = find_css_set(cg, cgrp);
-	put_css_set(cg);
-	if (!newcg) {
-		retval = -ENOMEM;
-		goto out;
-	}
-
-	task_lock(tsk);
-	if (tsk->flags & PF_EXITING) {
-		task_unlock(tsk);
-		put_css_set(newcg);
-		retval = -ESRCH;
+	retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, false);
+	if (retval)
 		goto out;
-	}
-	rcu_assign_pointer(tsk->cgroups, newcg);
-	task_unlock(tsk);
-
-	/* Update the css_set linked lists if we're using them */
-	write_lock(&css_set_lock);
-	if (!list_empty(&tsk->cg_list)) {
-		list_del(&tsk->cg_list);
-		list_add(&tsk->cg_list, &newcg->tasks);
-	}
-	write_unlock(&css_set_lock);
 
 	for_each_subsys(root, ss) {
 		if (ss->attach)
 			ss->attach(ss, cgrp, oldcgrp, tsk, false);
 	}
-	set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
+
 	synchronize_rcu();
-	put_css_set(cg);
 
 	/*
 	 * wake up rmdir() waiter. the rmdir should fail since the cgroup
@@ -1898,49 +1936,339 @@ int cgroup_attach_task_all(struct task_struct *from, struct task_struct *tsk)
 EXPORT_SYMBOL_GPL(cgroup_attach_task_all);
 
 /*
- * Attach task with pid 'pid' to cgroup 'cgrp'. Call with cgroup_mutex
- * held. May take task_lock of task
+ * cgroup_attach_proc works in two stages, the first of which prefetches all
+ * new css_sets needed (to make sure we have enough memory before committing
+ * to the move) and stores them in a list of entries of the following type.
+ * TODO: possible optimization: use css_set->rcu_head for chaining instead
+ */
+struct cg_list_entry {
+	struct css_set *cg;
+	struct list_head links;
+};
+
+static bool css_set_check_fetched(struct cgroup *cgrp,
+				  struct task_struct *tsk, struct css_set *cg,
+				  struct list_head *newcg_list)
+{
+	struct css_set *newcg;
+	struct cg_list_entry *cg_entry;
+	struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
+
+	read_lock(&css_set_lock);
+	newcg = find_existing_css_set(cg, cgrp, template);
+	if (newcg)
+		get_css_set(newcg);
+	read_unlock(&css_set_lock);
+
+	/* doesn't exist at all? */
+	if (!newcg)
+		return false;
+	/* see if it's already in the list */
+	list_for_each_entry(cg_entry, newcg_list, links) {
+		if (cg_entry->cg == newcg) {
+			put_css_set(newcg);
+			return true;
+		}
+	}
+
+	/* not found */
+	put_css_set(newcg);
+	return false;
+}
+
+/*
+ * Find the new css_set and store it in the list in preparation for moving the
+ * given task to the given cgroup. Returns 0 or -ENOMEM.
  */
-static int attach_task_by_pid(struct cgroup *cgrp, u64 pid)
+static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
+			    struct list_head *newcg_list)
+{
+	struct css_set *newcg;
+	struct cg_list_entry *cg_entry;
+
+	/* ensure a new css_set will exist for this thread */
+	newcg = find_css_set(cg, cgrp);
+	if (!newcg)
+		return -ENOMEM;
+	/* add it to the list */
+	cg_entry = kmalloc(sizeof(struct cg_list_entry), GFP_KERNEL);
+	if (!cg_entry) {
+		put_css_set(newcg);
+		return -ENOMEM;
+	}
+	cg_entry->cg = newcg;
+	list_add(&cg_entry->links, newcg_list);
+	return 0;
+}
+
+/**
+ * cgroup_attach_proc - attach all threads in a threadgroup to a cgroup
+ * @cgrp: the cgroup to attach to
+ * @leader: the threadgroup leader task_struct of the group to be attached
+ *
+ * Call holding cgroup_mutex. Will take task_lock of each thread in leader's
+ * threadgroup individually in turn.
+ */
+int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
+{
+	int retval;
+	struct cgroup_subsys *ss, *failed_ss = NULL;
+	struct cgroup *oldcgrp;
+	struct css_set *oldcg;
+	struct cgroupfs_root *root = cgrp->root;
+	/* threadgroup list cursor */
+	struct task_struct *tsk;
+	/*
+	 * we need to make sure we have css_sets for all the tasks we're
+	 * going to move -before- we actually start moving them, so that in
+	 * case we get an ENOMEM we can bail out before making any changes.
+	 */
+	struct list_head newcg_list;
+	struct cg_list_entry *cg_entry, *temp_nobe;
+
+	/* check that we can legitimately attach to the cgroup. */
+	for_each_subsys(root, ss) {
+		if (ss->can_attach) {
+			retval = ss->can_attach(ss, cgrp, leader, true);
+			if (retval) {
+				failed_ss = ss;
+				goto out;
+			}
+		}
+	}
+
+	/*
+	 * step 1: make sure css_sets exist for all threads to be migrated.
+	 * we use find_css_set, which allocates a new one if necessary.
+	 */
+	INIT_LIST_HEAD(&newcg_list);
+	oldcgrp = task_cgroup_from_root(leader, root);
+	if (cgrp != oldcgrp) {
+		/* get old css_set */
+		task_lock(leader);
+		if (leader->flags & PF_EXITING) {
+			task_unlock(leader);
+			goto prefetch_loop;
+		}
+		oldcg = leader->cgroups;
+		get_css_set(oldcg);
+		task_unlock(leader);
+		/* acquire new one */
+		retval = css_set_prefetch(cgrp, oldcg, &newcg_list);
+		put_css_set(oldcg);
+		if (retval)
+			goto list_teardown;
+	}
+prefetch_loop:
+	rcu_read_lock();
+	/* sanity check - if we raced with de_thread, we must abort */
+	if (!thread_group_leader(leader)) {
+		retval = -EAGAIN;
+		goto list_teardown;
+	}
+	/*
+	 * if we need to fetch a new css_set for this task, we must exit the
+	 * rcu_read section because allocating it can sleep. afterwards, we'll
+	 * need to restart iteration on the threadgroup list - the whole thing
+	 * will be O(nm) in the number of threads and css_sets; as the typical
+	 * case has only one css_set for all of them, usually O(n). which ones
+	 * we need allocated won't change as long as we hold cgroup_mutex.
+	 */
+	list_for_each_entry_rcu(tsk, &leader->thread_group, thread_group) {
+		/* nothing to do if this task is already in the cgroup */
+		oldcgrp = task_cgroup_from_root(tsk, root);
+		if (cgrp == oldcgrp)
+			continue;
+		/* get old css_set pointer */
+		task_lock(tsk);
+		if (tsk->flags & PF_EXITING) {
+			/* ignore this task if it's going away */
+			task_unlock(tsk);
+			continue;
+		}
+		oldcg = tsk->cgroups;
+		get_css_set(oldcg);
+		task_unlock(tsk);
+		/* see if the new one for us is already in the list? */
+		if (css_set_check_fetched(cgrp, tsk, oldcg, &newcg_list)) {
+			/* was already there, nothing to do. */
+			put_css_set(oldcg);
+		} else {
+			/* we don't already have it. get new one. */
+			rcu_read_unlock();
+			retval = css_set_prefetch(cgrp, oldcg, &newcg_list);
+			put_css_set(oldcg);
+			if (retval)
+				goto list_teardown;
+			/* begin iteration again. */
+			goto prefetch_loop;
+		}
+	}
+	rcu_read_unlock();
+
+	/*
+	 * step 2: now that we're guaranteed success wrt the css_sets, proceed
+	 * to move all tasks to the new cgroup. we need to lock against possible
+	 * races with fork(). note: we can safely take the threadgroup_fork_lock
+	 * of leader since attach_task_by_pid took a reference.
+	 * threadgroup_fork_lock must be taken outside of tasklist_lock to match
+	 * the order in the fork path.
+	 */
+	threadgroup_fork_write_lock(leader);
+	read_lock(&tasklist_lock);
+	/* sanity check - if we raced with de_thread, we must abort */
+	if (!thread_group_leader(leader)) {
+		retval = -EAGAIN;
+		read_unlock(&tasklist_lock);
+		threadgroup_fork_write_unlock(leader);
+		goto list_teardown;
+	}
+	/*
+	 * No failure cases left, so this is the commit point.
+	 *
+	 * If the leader is already there, skip moving him. Note: even if the
+	 * leader is PF_EXITING, we still move all other threads; if everybody
+	 * is PF_EXITING, we end up doing nothing, which is ok.
+	 */
+	oldcgrp = task_cgroup_from_root(leader, root);
+	if (cgrp != oldcgrp) {
+		retval = cgroup_task_migrate(cgrp, oldcgrp, leader, true);
+		BUG_ON(retval != 0 && retval != -ESRCH);
+	}
+	/* Now iterate over each thread in the group. */
+	list_for_each_entry_rcu(tsk, &leader->thread_group, thread_group) {
+		/* leave current thread as it is if it's already there */
+		oldcgrp = task_cgroup_from_root(tsk, root);
+		if (cgrp == oldcgrp)
+			continue;
+		/* we don't care whether these threads are exiting */
+		retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, true);
+		BUG_ON(retval != 0 && retval != -ESRCH);
+	}
+
+	/*
+	 * step 3: attach whole threadgroup to each subsystem
+	 * TODO: if ever a subsystem needs to know the oldcgrp for each task
+	 * being moved, this call will need to be reworked to communicate that.
+	 */
+	for_each_subsys(root, ss) {
+		if (ss->attach)
+			ss->attach(ss, cgrp, oldcgrp, leader, true);
+	}
+	/* holding these until here keeps us safe from exec() and fork(). */
+	read_unlock(&tasklist_lock);
+	threadgroup_fork_write_unlock(leader);
+
+	/*
+	 * step 4: success! and cleanup
+	 */
+	synchronize_rcu();
+	cgroup_wakeup_rmdir_waiter(cgrp);
+	retval = 0;
+list_teardown:
+	/* clean up the list of prefetched css_sets. */
+	list_for_each_entry_safe(cg_entry, temp_nobe, &newcg_list, links) {
+		list_del(&cg_entry->links);
+		put_css_set(cg_entry->cg);
+		kfree(cg_entry);
+	}
+out:
+	if (retval) {
+		/* same deal as in cgroup_attach_task, with threadgroup=true */
+		for_each_subsys(root, ss) {
+			if (ss == failed_ss)
+				break;
+			if (ss->cancel_attach)
+				ss->cancel_attach(ss, cgrp, leader, true);
+		}
+	}
+	return retval;
+}
+
+/*
+ * Find the task_struct of the task to attach by vpid and pass it along to the
+ * function to attach either it or all tasks in its threadgroup. Will take
+ * cgroup_mutex; may take task_lock of task.
+ */
+static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 {
 	struct task_struct *tsk;
 	const struct cred *cred = current_cred(), *tcred;
 	int ret;
 
+	if (!cgroup_lock_live_group(cgrp))
+		return -ENODEV;
+
 	if (pid) {
 		rcu_read_lock();
 		tsk = find_task_by_vpid(pid);
-		if (!tsk || tsk->flags & PF_EXITING) {
+		if (!tsk) {
+			rcu_read_unlock();
+			cgroup_unlock();
+			return -ESRCH;
+		}
+		if (threadgroup) {
+			/*
+			 * it is safe to find group_leader because tsk was found
+			 * in the tid map, meaning it can't have been unhashed
+			 * by someone in de_thread changing the leadership.
+			 */
+			tsk = tsk->group_leader;
+			BUG_ON(!thread_group_leader(tsk));
+		} else if (tsk->flags & PF_EXITING) {
+			/* optimization for the single-task-only case */
 			rcu_read_unlock();
+			cgroup_unlock();
 			return -ESRCH;
 		}
 
+		/*
+		 * even if we're attaching all tasks in the thread group, we
+		 * only need to check permissions on one of them.
+		 */
 		tcred = __task_cred(tsk);
 		if (cred->euid &&
 		    cred->euid != tcred->uid &&
 		    cred->euid != tcred->suid) {
 			rcu_read_unlock();
+			cgroup_unlock();
 			return -EACCES;
 		}
 		get_task_struct(tsk);
 		rcu_read_unlock();
 	} else {
-		tsk = current;
+		if (threadgroup)
+			tsk = current->group_leader;
+		else
+			tsk = current;
 		get_task_struct(tsk);
 	}
 
-	ret = cgroup_attach_task(cgrp, tsk);
+	if (threadgroup)
+		ret = cgroup_attach_proc(cgrp, tsk);
+	else
+		ret = cgroup_attach_task(cgrp, tsk);
 	put_task_struct(tsk);
+	cgroup_unlock();
 	return ret;
 }
 
 static int cgroup_tasks_write(struct cgroup *cgrp, struct cftype *cft, u64 pid)
 {
+	return attach_task_by_pid(cgrp, pid, false);
+}
+
+static int cgroup_procs_write(struct cgroup *cgrp, struct cftype *cft, u64 tgid)
+{
 	int ret;
-	if (!cgroup_lock_live_group(cgrp))
-		return -ENODEV;
-	ret = attach_task_by_pid(cgrp, pid);
-	cgroup_unlock();
+	do {
+		/*
+		 * attach_proc fails with -EAGAIN if threadgroup leadership
+		 * changes in the middle of the operation, in which case we need
+		 * to find the task_struct for the new leader and start over.
+		 */
+		ret = attach_task_by_pid(cgrp, tgid, true);
+	} while (ret == -EAGAIN);
 	return ret;
 }
 
@@ -3294,9 +3622,9 @@ static struct cftype files[] = {
 	{
 		.name = CGROUP_FILE_GENERIC_PREFIX "procs",
 		.open = cgroup_procs_open,
-		/* .write_u64 = cgroup_procs_write, TODO */
+		.write_u64 = cgroup_procs_write,
 		.release = cgroup_pidlist_release,
-		.mode = S_IRUGO,
+		.mode = S_IRUGO | S_IWUSR,
 	},
 	{
 		.name = "notify_on_release",
