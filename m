From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 03/10] threadgroup: extend threadgroup_lock() to cover exit
	and exec
Date: Tue,  1 Nov 2011 16:46:26 -0700
Message-ID: <1320191193-8110-4-git-send-email-tj__15217.9022822112$1320191236$gmane$org@kernel.org>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1320191193-8110-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
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

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/sched.h |   36 ++++++++++++++++++++++++++++++------
 kernel/exit.c         |   17 +++++++++++++----
 2 files changed, 43 insertions(+), 10 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index aa47d0f..6fb546e 100644
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
@@ -2367,7 +2368,6 @@ static inline void unlock_task_sighand(struct task_struct *tsk,
 	spin_unlock_irqrestore(&tsk->sighand->siglock, *flags);
 }
 
-/* See the declaration of group_rwsem in signal_struct. */
 #ifdef CONFIG_CGROUPS
 static inline void threadgroup_change_begin(struct task_struct *tsk)
 {
@@ -2377,13 +2377,37 @@ static inline void threadgroup_change_done(struct task_struct *tsk)
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
+ * synchronization.  exec is already synchronized with cread_guard_mutex
+ * which we grab here.
+ */
 static inline void threadgroup_lock(struct task_struct *tsk)
 {
+	/* exec uses exit for de-threading, grab cred_guard_mutex first */
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
index 2913b35..3565f00 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -938,6 +938,12 @@ NORET_TYPE void do_exit(long code)
 		schedule();
 	}
 
+	/*
+	 * @tsk's threadgroup is going through changes - lock out users
+	 * which expect stable threadgroup.
+	 */
+	threadgroup_change_begin(tsk);
+
 	exit_irq_thread();
 
 	exit_signals(tsk);  /* sets PF_EXITING */
@@ -1020,10 +1026,6 @@ NORET_TYPE void do_exit(long code)
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
@@ -1040,6 +1042,13 @@ NORET_TYPE void do_exit(long code)
 
 	preempt_disable();
 	exit_rcu();
+
+	/*
+	 * Release threadgroup and make sure we are holding no locks.
+	 */
+	threadgroup_change_done(tsk);
+	debug_check_no_locks_held(tsk);
+
 	/* causes final put_task_struct in finish_task_switch(). */
 	tsk->state = TASK_DEAD;
 	schedule();
-- 
1.7.3.1
