From: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 7/7] Makes procs file writable to move all threads by tgid at
	once
Date: Mon, 10 Aug 2009 17:58:06 -0700
Message-ID: <20090811005806.21950.94843.stgit__40142.0298767791$1249952933$gmane$org@hastromil.mtv.corp.google.com>
References: <20090811004737.21950.29188.stgit@hastromil.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090811004737.21950.29188.stgit-/yCBOHwbXCxd3OlUiQof+WCaruZE5nAUZeezCHUQhQ4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Makes procs file writable to move all threads by tgid at once

This patch adds functionality that enables users to move all threads in a
threadgroup at once to a cgroup by writing the tgid to the 'cgroup.procs'
file. This current implementation makes use of a per-threadgroup rwsem that's
taken for reading in the fork() path to prevent newly forking threads within
the threadgroup from "escaping" while the move is in progress.

There is a gap between releasing the fork_mutex and calling each subsystem's
attach function, which could possibly lead to problems if the subsystem relies
on something that could change in the meantime as caused by forking threads.
No particular issue seems apparent, but were some subsystem to have a problem
here, the per-threadgroup fork mutex could be held longer until after the
attach calls are done.

Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 Documentation/cgroups/cgroups.txt |   13 +
 kernel/cgroup.c                   |  401 +++++++++++++++++++++++++++++++++----
 2 files changed, 371 insertions(+), 43 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 568b320..e9d244c 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -9,6 +9,7 @@ Portions Copyright (C) 2004 BULL SA.
 Portions Copyright (c) 2004-2006 Silicon Graphics, Inc.
 Modified by Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
 Modified by Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
+Modified by Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
 
 CONTENTS:
 =========
@@ -228,6 +229,7 @@ Each cgroup is represented by a directory in the cgroup file system
 containing the following files describing that cgroup:
 
  - tasks: list of tasks (by pid) attached to that cgroup
+ - cgroup.procs: list of unique tgids in the cgroup
  - notify_on_release flag: run the release agent on exit?
  - release_agent: the path to use for release notifications (this file
    exists in the top cgroup only)
@@ -374,7 +376,7 @@ Now you want to do something with this cgroup.
 
 In this directory you can find several files:
 # ls
-notify_on_release tasks
+cgroup.procs notify_on_release tasks
 (plus whatever files added by the attached subsystems)
 
 Now attach your shell to this cgroup:
@@ -408,6 +410,15 @@ You can attach the current shell task by echoing 0:
 
 # echo 0 > tasks
 
+The cgroup.procs file is useful for managing all tasks in a threadgroup at
+once. It works the same way as the tasks file, but moves all tasks in the
+threadgroup with the specified tgid.
+
+Writing the pid of a task that's not the threadgroup leader (i.e., a pid
+that isn't a tgid) is treated as invalid. Writing a '0' to cgroup.procs will
+attach the writing task and all tasks in its threadgroup, but is invalid if
+the writing task is not the leader of the threadgroup.
+
 3. Kernel API
 =============
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 1d0d733..0ea5cf4 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1297,6 +1297,87 @@ static void get_first_subsys(const struct cgroup *cgrp,
 		*subsys_id = test_ss->subsys_id;
 }
 
+/*
+ * cgroup_task_migrate - move a task from one cgroup to another.
+ *
+ * 'guarantee' is set if the caller promises that a new css_set for the task
+ * will already exist. If not set, this function might sleep, and can fail
+ * with -ENOMEM. Otherwise, it can only fail with -ESRCH.
+ */
+static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
+			       struct task_struct *tsk, int guarantee)
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
+	/*
+	 * locate or allocate a new css_set for this task. 'guarantee' tells
+	 * us whether or not we are sure that a new css_set already exists;
+	 * in that case, we are not allowed to fail or sleep, as we won't need
+	 * malloc.
+	 */
+	if (guarantee) {
+		/*
+		 * our caller promises us that the css_set we want already
+		 * exists, so we use find_existing_css_set directly.
+		 */
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
+	/*
+	 * we cannot move a task that's declared itself as exiting, as once
+	 * PF_EXITING is set, the tsk->cgroups pointer is no longer safe.
+	 */
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
+	 * trading it for newcg is protected by cgroup_mutex, we're safe to
+	 * drop it here; it will be freed under RCU.
+	 */
+	put_css_set(oldcg);
+
+	set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
+	return 0;
+}
+
 /**
  * threadgroup_fork_lock - block all CLONE_THREAD forks in the threadgroup
  * @tsk: the task whose threadgroup should be locked
@@ -1366,11 +1447,9 @@ void threadgroup_fork_unlock(struct sighand_struct *sighand)
  */
 int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 {
-	int retval = 0;
+	int retval;
 	struct cgroup_subsys *ss;
 	struct cgroup *oldcgrp;
-	struct css_set *cg;
-	struct css_set *newcg;
 	struct cgroupfs_root *root = cgrp->root;
 	int subsys_id;
 
@@ -1389,75 +1468,307 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 		}
 	}
 
-	task_lock(tsk);
-	cg = tsk->cgroups;
-	get_css_set(cg);
-	task_unlock(tsk);
+	retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, 0);
+	if (retval)
+		return retval;
+
+	for_each_subsys(root, ss) {
+		if (ss->attach)
+			ss->attach(ss, cgrp, oldcgrp, tsk, false);
+	}
+
+	synchronize_rcu();
+
 	/*
-	 * Locate or allocate a new css_set for this task,
-	 * based on its final set of cgroups
+	 * wake up rmdir() waiter. the rmdir should fail since the cgroup
+	 * is no longer empty.
 	 */
+	cgroup_wakeup_rmdir_waiters(cgrp);
+	return 0;
+}
+
+/*
+ * cgroup_attach_proc works in two stages, the first of which prefetches all
+ * new css_sets needed (to make sure we have enough memory before committing
+ * to the move) and stores them in a list, of entries of the following type.
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
+ * Find the new css_set and store it in the list in preparation for moving
+ * the given task to the given cgroup. Returns 0 on success, -ENOMEM if we
+ * run out of memory.
+ */
+static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
+			    struct list_head *newcg_list)
+{
+	struct css_set *newcg;
+	struct cg_list_entry *cg_entry;
+	/* ensure a new css_set will exist for this thread */
 	newcg = find_css_set(cg, cgrp);
-	put_css_set(cg);
 	if (!newcg)
 		return -ENOMEM;
+	/* add new element to list */
+	cg_entry = kmalloc(sizeof(struct cg_list_entry), GFP_KERNEL);
+	if (!cg_entry) {
+		put_css_set(newcg);
+		return -ENOMEM;
+	}
+	cg_entry->cg = newcg;
+	list_add(&cg_entry->links, newcg_list);
+	return 0;
+}
 
-	task_lock(tsk);
-	if (tsk->flags & PF_EXITING) {
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
+	struct cgroup_subsys *ss;
+	struct cgroup *oldcgrp;
+	struct css_set *oldcg;
+	struct cgroupfs_root *root = cgrp->root;
+	int subsys_id;
+	/* threadgroup list cursor */
+	struct task_struct *tsk;
+	/*
+	 * we need to make sure we have css_sets for all the tasks we're
+	 * going to move -before- we actually start moving them, so that in
+	 * case we get an ENOMEM we can bail out before making any changes.
+	 */
+	struct list_head newcg_list;
+	struct cg_list_entry *cg_entry;
+	/* needed for locking the threadgroup */
+	struct sighand_struct *threadgroup_sighand;
+
+	/* first, make sure this came from a valid tgid */
+	if (!thread_group_leader(leader))
+		return -EINVAL;
+	/*
+	 * check that we can legitimately attach to the cgroup.
+	 */
+	for_each_subsys(root, ss) {
+		if (ss->can_attach) {
+			retval = ss->can_attach(ss, cgrp, leader, true);
+			if (retval)
+				return retval;
+		}
+	}
+
+	get_first_subsys(cgrp, NULL, &subsys_id);
+
+	/*
+	 * step 1: make sure css_sets exist for all threads to be migrated.
+	 * we use find_css_set, which allocates a new one if necessary.
+	 */
+	INIT_LIST_HEAD(&newcg_list);
+	oldcgrp = task_cgroup(leader, subsys_id);
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
+	/*
+	 * if we need to fetch a new css_set for this task, we must exit the
+	 * rcu_read section because allocating it can sleep. afterwards, we'll
+	 * need to restart iteration on the threadgroup list - the whole thing
+	 * will be O(nm) in the number of threads and css_sets; as the typical
+	 * case only has one css_set for all of them, usually O(n).
+	 */
+	list_for_each_entry_rcu(tsk, &leader->thread_group, thread_group) {
+		/* nothing to do if this task is already in the cgroup */
+		oldcgrp = task_cgroup(tsk, subsys_id);
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
 		task_unlock(tsk);
-		put_css_set(newcg);
-		return -ESRCH;
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
 	}
-	rcu_assign_pointer(tsk->cgroups, newcg);
-	task_unlock(tsk);
+	rcu_read_unlock();
 
-	/* Update the css_set linked lists if we're using them */
-	write_lock(&css_set_lock);
-	if (!list_empty(&tsk->cg_list)) {
-		list_del(&tsk->cg_list);
-		list_add(&tsk->cg_list, &newcg->tasks);
+	/*
+	 * step 2: now that we're guaranteed success wrt the css_sets, proceed
+	 * to move all tasks to the new cgroup. Even if the threadgroup leader
+	 * is PF_EXITING, we still proceed to move all of its sub-threads to
+	 * the new cgroup; if everybody is PF_EXITING, we'll just end up doing
+	 * nothing, which is ok.
+	 */
+	oldcgrp = task_cgroup(leader, subsys_id);
+	/* if leader is already there, skip moving him */
+	if (cgrp != oldcgrp) {
+		retval = cgroup_task_migrate(cgrp, oldcgrp, leader, 1);
+		BUG_ON(retval != 0 && retval != -ESRCH);
 	}
-	write_unlock(&css_set_lock);
+	/*
+	 * now move all the rest of the threads - need to lock against
+	 * possible races with fork().
+	 */
+	threadgroup_sighand = threadgroup_fork_lock(leader);
+	if (unlikely(!threadgroup_sighand)) {
+		/*
+		 * it is okay to have a failure case after the move-the-leader
+		 * code, because we will only have failed here if the leader
+		 * was PF_EXITING, and then task_migrate on him will have done
+		 * nothing.
+		 */
+		retval = -ESRCH;
+		goto list_teardown;
+	}
+	rcu_read_lock();
+	list_for_each_entry_rcu(tsk, &leader->thread_group, thread_group) {
+		/* leave current thread as it is if it's already there */
+		oldcgrp = task_cgroup(tsk, subsys_id);
+		if (cgrp == oldcgrp)
+			continue;
+		/* we don't care whether these threads are exiting */
+		retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, 1);
+		BUG_ON(retval != 0 && retval != -ESRCH);
+	}
+	rcu_read_unlock();
+	threadgroup_fork_unlock(threadgroup_sighand);
 
+	/*
+	 * step 3: attach whole threadgroup to each subsystem
+	 * TODO: if ever a subsystem needs to know the oldcgrp for each task
+	 * being moved, this call will need to be reworked to communicate that
+	 * information.
+	 */
 	for_each_subsys(root, ss) {
 		if (ss->attach)
-			ss->attach(ss, cgrp, oldcgrp, tsk, false);
+			ss->attach(ss, cgrp, oldcgrp, tsk, true);
 	}
-	set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
-	synchronize_rcu();
-	put_css_set(cg);
 
 	/*
-	 * wake up rmdir() waiter. the rmdir should fail since the cgroup
-	 * is no longer empty.
+	 * step 4: success! ...and cleanup
 	 */
+	synchronize_rcu();
 	cgroup_wakeup_rmdir_waiters(cgrp);
-	return 0;
+	retval = 0;
+list_teardown:
+	/* no longer need the list of css_sets, so get rid of it */
+	while (!list_empty(&newcg_list)) {
+		/* pop from the list */
+		cg_entry = list_first_entry(&newcg_list, struct cg_list_entry,
+					    links);
+		list_del(&cg_entry->links);
+		/* drop the refcount */
+		put_css_set(cg_entry->cg);
+		kfree(cg_entry);
+	}
+	/* done! */
+	return retval;
 }
 
 /*
- * Attach task with pid 'pid' to cgroup 'cgrp'. Call with cgroup_mutex
- * held. May take task_lock of task
+ * Find the task_struct of the task to attach by vpid and pass it along to the
+ * function to attach either it or all tasks in its threadgroup. Will take
+ * cgroup_mutex; may take task_lock of task.
  */
-static int attach_task_by_pid(struct cgroup *cgrp, u64 pid)
+static int attach_task_by_pid(struct cgroup *cgrp, u64 pid,
+			      int attach(struct cgroup *,
+					 struct task_struct *))
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
 		if (!tsk || tsk->flags & PF_EXITING) {
 			rcu_read_unlock();
+			cgroup_unlock();
 			return -ESRCH;
 		}
-
+		/*
+		 * even if we're attaching all tasks in the thread group, we
+		 * only need to check permissions on the group leader, because
+		 * even if another task has different permissions, the group
+		 * leader will have sufficient access to change it.
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
@@ -1467,19 +1778,25 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid)
 		get_task_struct(tsk);
 	}
 
-	ret = cgroup_attach_task(cgrp, tsk);
+	/*
+	 * Note that the check for whether the task is its threadgroup leader
+	 * is done in cgroup_attach_proc. This means that writing 0 to the
+	 * procs file will only work if the writing task is the leader.
+	 */
+	ret = attach(cgrp, tsk);
 	put_task_struct(tsk);
+	cgroup_unlock();
 	return ret;
 }
 
 static int cgroup_tasks_write(struct cgroup *cgrp, struct cftype *cft, u64 pid)
 {
-	int ret;
-	if (!cgroup_lock_live_group(cgrp))
-		return -ENODEV;
-	ret = attach_task_by_pid(cgrp, pid);
-	cgroup_unlock();
-	return ret;
+	return attach_task_by_pid(cgrp, pid, cgroup_attach_task);
+}
+
+static int cgroup_procs_write(struct cgroup *cgrp, struct cftype *cft, u64 tgid)
+{
+	return attach_task_by_pid(cgrp, tgid, cgroup_attach_proc);
 }
 
 /**
@@ -2638,9 +2955,9 @@ static struct cftype files[] = {
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
