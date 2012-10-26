From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 1/1] freezer: change ptrace_stop/do_signal_stop to use
	freezable_schedule()
Date: Fri, 26 Oct 2012 19:46:06 +0200
Message-ID: <20121026174606.GB21639@redhat.com>
References: <20121022174404.GA21553@redhat.com>
	<20121022211317.GD5951@atj.dyndns.org>
	<20121023153919.GA16201@redhat.com>
	<20121024185710.GA12182@atj.dyndns.org>
	<20121025163941.GA3801@redhat.com>
	<20121025163959.GB3801@redhat.com>
	<20121025171812.GE11442@htj.dyndns.org>
	<20121025173433.GA7650@redhat.com>
	<20121025173632.GI11442@htj.dyndns.org>
	<20121026174545.GA21639@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121026174545.GA21639-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

try_to_freeze_tasks() and cgroup_freezer rely on scheduler locks
to ensure that a task doing STOPPED/TRACED -> RUNNING transition
can't escape freezing. This mostly works, but ptrace_stop() does
not necessarily call schedule(), it can change task->state back to
RUNNING and check freezing() without any lock/barrier in between.

We could add the necessary barrier, but this patch changes
ptrace_stop() and do_signal_stop() to use freezable_schedule().
This fixes the race, freezer_count() and freezer_should_skip()
carefully avoid the race.

And this simplifies the code, try_to_freeze_tasks/update_if_frozen
no longer need to use task_is_stopped_or_traced() checks with the
non trivial assumptions. We can rely on the mechanism which was
specially designed to mark the sleeping task as "frozen enough".

v2: As Tejun pointed out, we can also change get_signal_to_deliver()
and move try_to_freeze() up before 'relock' label.

Signed-off-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/linux/freezer.h |    7 +++----
 kernel/cgroup_freezer.c |    3 +--
 kernel/freezer.c        |   11 ++---------
 kernel/power/process.c  |   13 +------------
 kernel/signal.c         |   20 ++++++--------------
 5 files changed, 13 insertions(+), 41 deletions(-)

diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index ee89932..8039893 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -134,10 +134,9 @@ static inline bool freezer_should_skip(struct task_struct *p)
 }
 
 /*
- * These macros are intended to be used whenever you want allow a task that's
- * sleeping in TASK_UNINTERRUPTIBLE or TASK_KILLABLE state to be frozen. Note
- * that neither return any clear indication of whether a freeze event happened
- * while in this function.
+ * These macros are intended to be used whenever you want allow a sleeping
+ * task to be frozen. Note that neither return any clear indication of
+ * whether a freeze event happened while in this function.
  */
 
 /* Like schedule(), but should not block the freezer. */
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 8a92b0e..bedefd9 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -198,8 +198,7 @@ static void update_if_frozen(struct cgroup *cgroup, struct freezer *freezer)
 			 * completion.  Consider it frozen in addition to
 			 * the usual frozen condition.
 			 */
-			if (!frozen(task) && !task_is_stopped_or_traced(task) &&
-			    !freezer_should_skip(task))
+			if (!frozen(task) && !freezer_should_skip(task))
 				goto notyet;
 		}
 	}
diff --git a/kernel/freezer.c b/kernel/freezer.c
index 11f82a4..c38893b 100644
--- a/kernel/freezer.c
+++ b/kernel/freezer.c
@@ -116,17 +116,10 @@ bool freeze_task(struct task_struct *p)
 		return false;
 	}
 
-	if (!(p->flags & PF_KTHREAD)) {
+	if (!(p->flags & PF_KTHREAD))
 		fake_signal_wake_up(p);
-		/*
-		 * fake_signal_wake_up() goes through p's scheduler
-		 * lock and guarantees that TASK_STOPPED/TRACED ->
-		 * TASK_RUNNING transition can't race with task state
-		 * testing in try_to_freeze_tasks().
-		 */
-	} else {
+	else
 		wake_up_state(p, TASK_INTERRUPTIBLE);
-	}
 
 	spin_unlock_irqrestore(&freezer_lock, flags);
 	return true;
diff --git a/kernel/power/process.c b/kernel/power/process.c
index 87da817..d5a258b 100644
--- a/kernel/power/process.c
+++ b/kernel/power/process.c
@@ -48,18 +48,7 @@ static int try_to_freeze_tasks(bool user_only)
 			if (p == current || !freeze_task(p))
 				continue;
 
-			/*
-			 * Now that we've done set_freeze_flag, don't
-			 * perturb a task in TASK_STOPPED or TASK_TRACED.
-			 * It is "frozen enough".  If the task does wake
-			 * up, it will immediately call try_to_freeze.
-			 *
-			 * Because freeze_task() goes through p's scheduler lock, it's
-			 * guaranteed that TASK_STOPPED/TRACED -> TASK_RUNNING
-			 * transition can't race with task state testing here.
-			 */
-			if (!task_is_stopped_or_traced(p) &&
-			    !freezer_should_skip(p))
+			if (!freezer_should_skip(p))
 				todo++;
 		} while_each_thread(g, p);
 		read_unlock(&tasklist_lock);
diff --git a/kernel/signal.c b/kernel/signal.c
index 0af8868..5ffb562 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1908,7 +1908,7 @@ static void ptrace_stop(int exit_code, int why, int clear_code, siginfo_t *info)
 		preempt_disable();
 		read_unlock(&tasklist_lock);
 		preempt_enable_no_resched();
-		schedule();
+		freezable_schedule();
 	} else {
 		/*
 		 * By the time we got the lock, our tracer went away.
@@ -1930,13 +1930,6 @@ static void ptrace_stop(int exit_code, int why, int clear_code, siginfo_t *info)
 	}
 
 	/*
-	 * While in TASK_TRACED, we were considered "frozen enough".
-	 * Now that we woke up, it's crucial if we're supposed to be
-	 * frozen that we freeze now before running anything substantial.
-	 */
-	try_to_freeze();
-
-	/*
 	 * We are back.  Now reacquire the siglock before touching
 	 * last_siginfo, so that we are sure to have synchronized with
 	 * any signal-sending on another CPU that wants to examine it.
@@ -2092,7 +2085,7 @@ static bool do_signal_stop(int signr)
 		}
 
 		/* Now we don't run again until woken by SIGCONT or SIGKILL */
-		schedule();
+		freezable_schedule();
 		return true;
 	} else {
 		/*
@@ -2200,15 +2193,14 @@ int get_signal_to_deliver(siginfo_t *info, struct k_sigaction *return_ka,
 	if (unlikely(uprobe_deny_signal()))
 		return 0;
 
-relock:
 	/*
-	 * We'll jump back here after any time we were stopped in TASK_STOPPED.
-	 * While in TASK_STOPPED, we were considered "frozen enough".
-	 * Now that we woke up, it's crucial if we're supposed to be
-	 * frozen that we freeze now before running anything substantial.
+	 * Do this once, we can't return to user-mode if freezing() == T.
+	 * do_signal_stop() and ptrace_stop() do freezable_schedule() and
+	 * thus do not need another check after return.
 	 */
 	try_to_freeze();
 
+relock:
 	spin_lock_irq(&sighand->siglock);
 	/*
 	 * Every stopped thread goes here after wakeup. Check to see if
-- 
1.5.5.1
