From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 5/6] Makes procs file writable to move all threads by
	tgid at	once
Date: Mon, 09 Nov 2009 18:07:52 +0100
Message-ID: <4AF84C68.7010803__38867.9113043056$1257786858$gmane$org@free.fr>
References: <20090724032033.2463.79256.stgit@hastromil.mtv.corp.google.com>
	<20090724032200.2463.82408.stgit@hastromil.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010908060905020000010907"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090724032200.2463.82408.stgit-/yCBOHwbXCxd3OlUiQof+WCaruZE5nAUZeezCHUQhQ4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------010908060905020000010907
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Ben Blum wrote:
> Makes procs file writable to move all threads by tgid at once
>
> This patch adds functionality that enables users to move all threads in a
> threadgroup at once to a cgroup by writing the tgid to the 'cgroup.procs'
> file. This current implementation makes use of a rwsem that's taken for
> reading in the fork() path to prevent newly forking threads within the
> threadgroup from "escaping" while moving is in progress.
>
> Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>   
[ cut ]
>  /**
> + * cgroup_fork_failed - undo operations for fork failure
> + * @tsk: pointer to  task_struct of exiting process
> + * @run_callback: run exit callbacks?
> + *
> + * Description: Undo cgroup operations after cgroup_fork in fork failure.
> + *
> + * We release the read lock that was taken in cgroup_fork(), since it is
> + * supposed to be dropped in cgroup_post_fork in the success case. The other
> + * thing that wants to be done is detaching the failed child task from the
> + * cgroup, so we wrap cgroup_exit.
> + */
> +void cgroup_fork_failed(struct task_struct *tsk, int run_callbacks)
> +{
> +	up_read(&cgroup_fork_mutex);
> +	cgroup_exit(tsk, run_callbacks);
> +}
> +
> +/**
>   * cgroup_clone - clone the cgroup the given subsystem is attached to
>   * @tsk: the task to be moved
>   * @subsys: the given subsystem
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 926c117..027ec16 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1300,7 +1300,7 @@ bad_fork_cleanup_policy:
>  	mpol_put(p->mempolicy);
>  bad_fork_cleanup_cgroup:
>  #endif
> -	cgroup_exit(p, cgroup_callbacks_done);
> +	cgroup_fork_failed(p, cgroup_callbacks_done);
>  	delayacct_tsk_free(p);
>  	if (p->binfmt)
>  		module_put(p->binfmt->module);
>   
Hi Ben,

The current code (with or without your patch) may lead to an error 
because the fork hook can fail and the exit hook is called in all the 
cases making the fork / exit asymmetric.

I will take the usual example with a cgroup with a counter of tasks, in 
the fork hook it increments the counter, in the exit hook it decrements 
the counter. There is one process in the cgroup, hence the counter value 
is 1. Now this process forks and the fork hook fails before the task 
counter is incremented to 2, this is not detected in copy process 
function because the cgroup_fork_callbacks does not return an error, so 
the process will be forked without error and when the process will exits 
the counter will be decremented reaching 0 instead of 1.

IMO, the correct fix should be to make the fork hook to return an error 
and have the cgroup to call the exit method of the subsystem where the 
fork hook was called. For example, there are 10 subsystems using the 
fork / exit hooks, when the a process forks, the fork callbacks is 
called for these subsystems but, let's say, the 3rd fails. So we undo, 
by calling the exit hooks of the first two.

I wrote a patchset to consolidate the hooks called in the cgroup for 
fork and exit, and one of them does a rollback for the fork hook when an 
error occurs. I added an attachment the patch as an example.

Thanks
  -- Daniel
>   



--------------010908060905020000010907
Content-Type: text/x-diff;
 name="0001-cgroup-make-fork-hook-to-return-an-error.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0001-cgroup-make-fork-hook-to-return-an-error.patch"

Subject: make the fork hook to return an error
From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

The fork hooks does not do any error checking making possible to have
a cgroup subsystem to fail without detecting an error.

This patch makes the fork hook to return an error if a fork hook failed
in one of the subsystems. When a fork hook fails for a subsystem,
the function 'cgroup_fork_callbacks' rollbacks, by calling the exit
callback for all the subsystem the fork callback were called at this
point.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 include/linux/cgroup.h  |    8 ++++----
 kernel/cgroup.c         |   37 +++++++++++++++++++++++++++----------
 kernel/cgroup_freezer.c |    6 ++++--
 kernel/exit.c           |    2 +-
 kernel/fork.c           |   13 +++++++------
 5 files changed, 43 insertions(+), 23 deletions(-)

Index: linux-2.6/include/linux/cgroup.h
===================================================================
--- linux-2.6.orig/include/linux/cgroup.h
+++ linux-2.6/include/linux/cgroup.h
@@ -31,9 +31,9 @@ extern void cgroup_lock(void);
 extern bool cgroup_lock_live_group(struct cgroup *cgrp);
 extern void cgroup_unlock(void);
 extern void cgroup_fork(struct task_struct *p);
-extern void cgroup_fork_callbacks(struct task_struct *p);
+extern int cgroup_fork_callbacks(struct task_struct *p);
 extern void cgroup_post_fork(struct task_struct *p);
-extern void cgroup_exit(struct task_struct *p, int run_callbacks);
+extern void cgroup_exit(struct task_struct *p);
 extern int cgroupstats_build(struct cgroupstats *stats,
 				struct dentry *dentry);
 
@@ -430,7 +430,7 @@ struct cgroup_subsys {
 	void (*attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			struct cgroup *old_cgrp, struct task_struct *tsk,
 			bool threadgroup);
-	void (*fork)(struct cgroup_subsys *ss, struct task_struct *task);
+	int  (*fork)(struct cgroup_subsys *ss, struct task_struct *task);
 	void (*exit)(struct cgroup_subsys *ss, struct task_struct *task);
 	int (*populate)(struct cgroup_subsys *ss,
 			struct cgroup *cgrp);
@@ -569,7 +569,7 @@ unsigned short css_depth(struct cgroup_s
 static inline int cgroup_init_early(void) { return 0; }
 static inline int cgroup_init(void) { return 0; }
 static inline void cgroup_fork(struct task_struct *p) {}
-static inline void cgroup_fork_callbacks(struct task_struct *p) {}
+static inline int cgroup_fork_callbacks(struct task_struct *p) {}
 static inline void cgroup_post_fork(struct task_struct *p) {}
 static inline void cgroup_exit(struct task_struct *p, int callbacks) {}
 
Index: linux-2.6/kernel/cgroup.c
===================================================================
--- linux-2.6.orig/kernel/cgroup.c
+++ linux-2.6/kernel/cgroup.c
@@ -3436,16 +3436,33 @@ void cgroup_fork(struct task_struct *chi
  * tasklist. No need to take any locks since no-one can
  * be operating on this task.
  */
-void cgroup_fork_callbacks(struct task_struct *child)
+int cgroup_fork_callbacks(struct task_struct *child)
 {
-	if (need_forkexit_callback) {
-		int i;
-		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-			struct cgroup_subsys *ss = subsys[i];
-			if (ss->fork)
-				ss->fork(ss, child);
-		}
+	int i, ret = 0;
+	struct cgroup_subsys *ss;
+
+	if (!need_forkexit_callback)
+		goto out;
+
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+		ss = subsys[i];
+		if (!ss->fork)
+			continue;
+		ret = ss->fork(ss, child);
+		if (ret)
+			goto out_exit;
 	}
+out:
+	return ret;
+
+out_exit:
+	for (i--; i >= 0; i--) {
+		ss = subsys[i];
+		if (!ss->exit)
+			continue;
+		ss->exit(ss, child);
+	}
+	goto out;
 }
 
 /**
@@ -3503,12 +3520,12 @@ void cgroup_post_fork(struct task_struct
  *    which wards off any cgroup_attach_task() attempts, or task is a failed
  *    fork, never visible to cgroup_attach_task.
  */
-void cgroup_exit(struct task_struct *tsk, int run_callbacks)
+void cgroup_exit(struct task_struct *tsk)
 {
 	int i;
 	struct css_set *cg;
 
-	if (run_callbacks && need_forkexit_callback) {
+	if (need_forkexit_callback) {
 		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss = subsys[i];
 			if (ss->exit)
Index: linux-2.6/kernel/cgroup_freezer.c
===================================================================
--- linux-2.6.orig/kernel/cgroup_freezer.c
+++ linux-2.6/kernel/cgroup_freezer.c
@@ -193,7 +193,7 @@ static int freezer_can_attach(struct cgr
 	return 0;
 }
 
-static void freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
+static int freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
 {
 	struct freezer *freezer;
 
@@ -210,7 +210,7 @@ static void freezer_fork(struct cgroup_s
 	 * following check.
 	 */
 	if (!freezer->css.cgroup->parent)
-		return;
+		goto out;
 
 	spin_lock_irq(&freezer->lock);
 	BUG_ON(freezer->state == CGROUP_FROZEN);
@@ -219,6 +219,8 @@ static void freezer_fork(struct cgroup_s
 	if (freezer->state == CGROUP_FREEZING)
 		freeze_task(task, true);
 	spin_unlock_irq(&freezer->lock);
+out:
+	return 0;
 }
 
 /*
Index: linux-2.6/kernel/exit.c
===================================================================
--- linux-2.6.orig/kernel/exit.c
+++ linux-2.6/kernel/exit.c
@@ -968,7 +968,7 @@ NORET_TYPE void do_exit(long code)
 	exit_fs(tsk);
 	check_stack_usage();
 	exit_thread();
-	cgroup_exit(tsk, 1);
+	cgroup_exit(tsk);
 
 	if (group_dead && tsk->signal->leader)
 		disassociate_ctty(1);
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -979,7 +979,6 @@ static struct task_struct *copy_process(
 {
 	int retval;
 	struct task_struct *p;
-	int cgroup_callbacks_done = 0;
 
 	if ((clone_flags & (CLONE_NEWNS|CLONE_FS)) == (CLONE_NEWNS|CLONE_FS))
 		return ERR_PTR(-EINVAL);
@@ -1217,13 +1216,14 @@ static struct task_struct *copy_process(
 	/* Now that the task is set up, run cgroup callbacks if
 	 * necessary. We need to run them before the task is visible
 	 * on the tasklist. */
-	cgroup_fork_callbacks(p);
-	cgroup_callbacks_done = 1;
+	retval = cgroup_fork_callbacks(p);
+	if (retval)
+		goto bad_fork_free_pid;
 
 	if (current->nsproxy != p->nsproxy) {
 		retval = ns_cgroup_clone(p, pid);
 		if (retval)
-			goto bad_fork_free_pid;
+			goto bad_fork_cgroup_callbacks;
 	}
 
 	/* Need tasklist lock for parent etc handling! */
@@ -1268,7 +1268,7 @@ static struct task_struct *copy_process(
 		spin_unlock(&current->sighand->siglock);
 		write_unlock_irq(&tasklist_lock);
 		retval = -ERESTARTNOINTR;
-		goto bad_fork_free_pid;
+		goto bad_fork_cgroup_callbacks;
 	}
 
 	if (clone_flags & CLONE_THREAD) {
@@ -1306,6 +1306,8 @@ static struct task_struct *copy_process(
 	perf_event_fork(p);
 	return p;
 
+bad_fork_cgroup_callbacks:
+	cgroup_exit(p);
 bad_fork_free_pid:
 	if (pid != &init_struct_pid)
 		free_pid(pid);
@@ -1335,7 +1337,6 @@ bad_fork_cleanup_policy:
 	mpol_put(p->mempolicy);
 bad_fork_cleanup_cgroup:
 #endif
-	cgroup_exit(p, cgroup_callbacks_done);
 	delayacct_tsk_free(p);
 	module_put(task_thread_info(p)->exec_domain->module);
 bad_fork_cleanup_count:

--------------010908060905020000010907
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------010908060905020000010907--
