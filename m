From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH UPDATED AGAIN 03/10] threadgroup: extend threadgroup_lock()
	to cover exit and exec
Date: Thu, 8 Dec 2011 12:50:55 -0800
Message-ID: <20111208205055.GB12108__47661.4320571118$1323377477$gmane$org@google.com>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
	<1320191193-8110-4-git-send-email-tj@kernel.org>
	<20111124225054.GA14828@google.com>
	<20111125140136.GC23307@somewhere.redhat.com>
	<20111127193001.GC4266@google.com>
	<20111202162753.GA19752@somewhere.redhat.com>
	<20111205184315.GJ627@google.com>
	<20111207153046.GC13252@somewhere.redhat.com>
	<20111207182214.GA7610@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111207182214.GA7610-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

(Note for Linus at the bottom)

threadgroup_lock() protected only protected against new addition to
the threadgroup, which was inherently somewhat incomplete and
problematic for its only user cgroup.  On-going migration could race
against exec and exit leading to interesting problems - the symmetry
between various attach methods, task exiting during method execution,
->exit() racing against attach methods, migrating task switching basic
properties during exec and so on.

This patch extends threadgroup_lock() such that it protects against
all three threadgroup altering operations - fork, exit and exec.  For
exit, threadgroup_change_begin/end() calls are added to exit_signals
around assertion of PF_EXITING.  For exec, threadgroup_[un]lock() are
updated to also grab and release cred_guard_mutex.

With this change, threadgroup_lock() guarantees that the target
threadgroup will remain stable - no new task will be added, no new
PF_EXITING will be set and exec won't happen.

The next patch will update cgroup so that it can take full advantage
of this change.

-v2: beefed up comment as suggested by Frederic.

-v3: narrowed scope of protection in exit path as suggested by
     Frederic.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Acked-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
---
Okay, narrowed exit path protection down to setting of PF_EXITING
itself.  ->exit() on dangling tasks is a bit weird but I don't think
it's too bad.  Frederic, are you okay with this version?

Linus, if Frederic is okay with it, I'm gonna rebase the series on top
of freezer changes in pm tree to avoid conflicts in cgroup_freezer,
which sits between cgroup and freezer, both of which are going through
non-trivial changes, push the branch to linux-next and put pending
cgroup patches on top.  Please scream if you're mighty unhappy with it
or have a better idea.

Thank you.

 include/linux/sched.h |   47 +++++++++++++++++++++++++++++++++++++++++------
 kernel/signal.c       |   10 ++++++++++
 2 files changed, 51 insertions(+), 6 deletions(-)

Index: work/include/linux/sched.h
===================================================================
--- work.orig/include/linux/sched.h
+++ work/include/linux/sched.h
@@ -635,11 +635,13 @@ struct signal_struct {
 #endif
 #ifdef CONFIG_CGROUPS
 	/*
-	 * The group_rwsem prevents threads from forking with
-	 * CLONE_THREAD while held for writing. Use this for fork-sensitive
-	 * threadgroup-wide operations. It's taken for reading in fork.c in
-	 * copy_process().
-	 * Currently only needed write-side by cgroups.
+	 * group_rwsem prevents new tasks from entering the threadgroup and
+	 * member tasks from exiting,a more specifically, setting of
+	 * PF_EXITING.  fork and exit paths are protected with this rwsem
+	 * using threadgroup_change_begin/end().  Users which require
+	 * threadgroup to remain stable should use threadgroup_[un]lock()
+	 * which also takes care of exec path.  Currently, cgroup is the
+	 * only user.
 	 */
 	struct rw_semaphore group_rwsem;
 #endif
@@ -2374,7 +2376,6 @@ static inline void unlock_task_sighand(s
 	spin_unlock_irqrestore(&tsk->sighand->siglock, *flags);
 }
 
-/* See the declaration of group_rwsem in signal_struct. */
 #ifdef CONFIG_CGROUPS
 static inline void threadgroup_change_begin(struct task_struct *tsk)
 {
@@ -2384,13 +2385,47 @@ static inline void threadgroup_change_en
 {
 	up_read(&tsk->signal->group_rwsem);
 }
+
+/**
+ * threadgroup_lock - lock threadgroup
+ * @tsk: member task of the threadgroup to lock
+ *
+ * Lock the threadgroup @tsk belongs to.  No new task is allowed to enter
+ * and member tasks aren't allowed to exit (as indicated by PF_EXITING) or
+ * perform exec.  This is useful for cases where the threadgroup needs to
+ * stay stable across blockable operations.
+ *
+ * fork and exit paths explicitly call threadgroup_change_{begin|end}() for
+ * synchronization.  While held, no new task will be added to threadgroup
+ * and no existing live task will have its PF_EXITING set.
+ *
+ * During exec, a task goes and puts its thread group through unusual
+ * changes.  After de-threading, exclusive access is assumed to resources
+ * which are usually shared by tasks in the same group - e.g. sighand may
+ * be replaced with a new one.  Also, the exec'ing task takes over group
+ * leader role including its pid.  Exclude these changes while locked by
+ * grabbing cred_guard_mutex which is used to synchronize exec path.
+ */
 static inline void threadgroup_lock(struct task_struct *tsk)
 {
+	/*
+	 * exec uses exit for de-threading nesting group_rwsem inside
+	 * cred_guard_mutex. Grab cred_guard_mutex first.
+	 */
+	mutex_lock(&tsk->signal->cred_guard_mutex);
 	down_write(&tsk->signal->group_rwsem);
 }
+
+/**
+ * threadgroup_unlock - unlock threadgroup
+ * @tsk: member task of the threadgroup to unlock
+ *
+ * Reverse threadgroup_lock().
+ */
 static inline void threadgroup_unlock(struct task_struct *tsk)
 {
 	up_write(&tsk->signal->group_rwsem);
+	mutex_unlock(&tsk->signal->cred_guard_mutex);
 }
 #else
 static inline void threadgroup_change_begin(struct task_struct *tsk) {}
Index: work/kernel/signal.c
===================================================================
--- work.orig/kernel/signal.c
+++ work/kernel/signal.c
@@ -2359,8 +2359,15 @@ void exit_signals(struct task_struct *ts
 	int group_stop = 0;
 	sigset_t unblocked;
 
+	/*
+	 * @tsk is about to have PF_EXITING set - lock out users which
+	 * expect stable threadgroup.
+	 */
+	threadgroup_change_begin(tsk);
+
 	if (thread_group_empty(tsk) || signal_group_exit(tsk->signal)) {
 		tsk->flags |= PF_EXITING;
+		threadgroup_change_end(tsk);
 		return;
 	}
 
@@ -2370,6 +2377,9 @@ void exit_signals(struct task_struct *ts
 	 * see wants_signal(), do_signal_stop().
 	 */
 	tsk->flags |= PF_EXITING;
+
+	threadgroup_change_end(tsk);
+
 	if (!signal_pending(tsk))
 		goto out;
