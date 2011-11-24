From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH UPDATED 03/10] threadgroup: extend threadgroup_lock() to
	cover exit and exec
Date: Thu, 24 Nov 2011 14:50:54 -0800
Message-ID: <20111124225054.GA14828__23204.5720135377$1322175077$gmane$org@google.com>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
	<1320191193-8110-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1320191193-8110-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

threadgroup_lock() protected only protected against new addition to
the threadgroup, which was inherently somewhat incomplete and
problematic for its only user cgroup.  On-going migration could race
against exec and exit leading to interesting problems - the symmetry
between various attach methods, task exiting during method execution,
->exit() racing against attach methods, migrating task switching basic
properties during exec and so on.

This patch extends threadgroup_lock() such that it protects against
all three threadgroup altering operations - fork, exit and exec.  For
exit, threadgroup_change_begin/end() calls are added to exit path.
For exec, threadgroup_[un]lock() are updated to also grab and release
cred_guard_mutex.

With this change, threadgroup_lock() guarantees that the target
threadgroup will remain stable - no new task will be added, no new
PF_EXITING will be set and exec won't happen.

The next patch will update cgroup so that it can take full advantage
of this change.

-v2: beefed up comment as suggested by Frederic.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Acked-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
---

Linus, this is something being scheduled for the next merge window.
It extends threadgroup locking which cgroup used to do to exclude only
fork path so that it includes exit and exec paths.  threadgroup
locking is used by cgroup to implement process-scope cgroup migration.

Migration happens in multiple steps, at each of which the matching
method of each cgroup plugin is called.  When a whole process is being
migrated, methods being called at those different steps expect to see
consistent image of the thread group.

cgroup currently only locks out addition of new tasks into the thread
group and holds extra ref to member tasks.  This mandates all cgroup
plugins to deal with tasks being torn down and exec morphing the
threadgroup.  This patch extends the scope of threadgroup locking such
that the thread group is guaranteed to be stable (no new task, tasks
are either live or dead and no exec morphing) while locked.

This is part of changes to clean up cgroup methods and iron out corner
case fuzziness and should make difficult-to-reproduce race conditions
less likely and cgroup plugins easier to implement and verify.

The synchronization is strictly per-threadgroup and goes away if
cgroup is not configured.

The whole series is avilable at

  http://thread.gmane.org/gmane.linux.kernel.containers/21716
  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.3

Thank you.

 include/linux/sched.h |   47 +++++++++++++++++++++++++++++++++++++++++------
 kernel/exit.c         |   19 +++++++++++++++----
 2 files changed, 56 insertions(+), 10 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index c5acbce..481c5ed 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -635,11 +635,12 @@ struct signal_struct {
 #endif
 #ifdef CONFIG_CGROUPS
 	/*
-	 * The group_rwsem prevents threads from forking with
-	 * CLONE_THREAD while held for writing. Use this for fork-sensitive
-	 * threadgroup-wide operations. It's taken for reading in fork.c in
-	 * copy_process().
-	 * Currently only needed write-side by cgroups.
+	 * group_rwsem prevents new tasks from entering the threadgroup and
+	 * member tasks from exiting.  fork and exit paths are protected
+	 * with this rwsem using threadgroup_change_begin/end().  Users
+	 * which require threadgroup to remain stable should use
+	 * threadgroup_[un]lock() which also takes care of exec path.
+	 * Currently, cgroup is the only user.
 	 */
 	struct rw_semaphore group_rwsem;
 #endif
@@ -2374,7 +2375,6 @@ static inline void unlock_task_sighand(struct task_struct *tsk,
 	spin_unlock_irqrestore(&tsk->sighand->siglock, *flags);
 }
 
-/* See the declaration of group_rwsem in signal_struct. */
 #ifdef CONFIG_CGROUPS
 static inline void threadgroup_change_begin(struct task_struct *tsk)
 {
@@ -2384,13 +2384,48 @@ static inline void threadgroup_change_end(struct task_struct *tsk)
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
+ * fork and exit explicitly call threadgroup_change_{begin|end}() for
+ * synchronization.  This excludes most of do_exit() to ensure that, while
+ * locked, tasks belonging to a locked group are not in the process of
+ * deconstruction - they're either alive or dead.
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
diff --git a/kernel/exit.c b/kernel/exit.c
index d0b7d98..b2cb562 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -936,6 +936,14 @@ NORET_TYPE void do_exit(long code)
 		schedule();
 	}
 
+	/*
+	 * @tsk's threadgroup is going through changes - lock out users
+	 * which expect stable threadgroup.  Do this before actually
+	 * starting tearing down @tsk so that locked threadgroup has either
+	 * alive or dead tasks, not something inbetween.
+	 */
+	threadgroup_change_begin(tsk);
+
 	exit_irq_thread();
 
 	exit_signals(tsk);  /* sets PF_EXITING */
@@ -1018,10 +1026,6 @@ NORET_TYPE void do_exit(long code)
 		kfree(current->pi_state_cache);
 #endif
 	/*
-	 * Make sure we are holding no locks:
-	 */
-	debug_check_no_locks_held(tsk);
-	/*
 	 * We can do this unlocked here. The futex code uses this flag
 	 * just to verify whether the pi state cleanup has been done
 	 * or not. In the worst case it loops once more.
@@ -1038,6 +1042,13 @@ NORET_TYPE void do_exit(long code)
 
 	preempt_disable();
 	exit_rcu();
+
+	/*
+	 * Release threadgroup and make sure we are holding no locks.
+	 */
+	threadgroup_change_end(tsk);
+	debug_check_no_locks_held(tsk);
+
 	/* causes final put_task_struct in finish_task_switch(). */
 	tsk->state = TASK_DEAD;
 	schedule();
-- 
1.7.3.1
