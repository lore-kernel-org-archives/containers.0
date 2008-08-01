From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/6] Container Freezer: Make refrigerator always available
Date: Thu, 31 Jul 2008 22:07:01 -0700
Message-ID: <20080801050700.528446138__2449.16695305637$1217568462$gmane$org@us.ibm.com>
References: <20080801050659.924495279@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Now that the TIF_FREEZE flag is available in all architectures,
extract the refrigerator() and freeze_task() from kernel/power/process.c
and make it available to all.

The refrigerator() can now be used in a control group subsystem
implementing a control group freezer.

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/freezer.h |   24 +++++----
 kernel/Makefile         |    2 +-
 kernel/freezer.c        |  122 +++++++++++++++++++++++++++++++++++++++++++++++
 kernel/power/process.c  |  116 --------------------------------------------
 4 files changed, 136 insertions(+), 128 deletions(-)
 create mode 100644 kernel/freezer.c

diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index deddeed..4081768 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -6,7 +6,6 @@
 #include <linux/sched.h>
 #include <linux/wait.h>
 
-#ifdef CONFIG_PM_SLEEP
 /*
  * Check if a process has been frozen
  */
@@ -39,6 +38,11 @@ static inline void clear_freeze_flag(struct task_struct *p)
 	clear_tsk_thread_flag(p, TIF_FREEZE);
 }
 
+static inline bool should_send_signal(struct task_struct *p)
+{
+	return !(p->flags & PF_FREEZER_NOSIG);
+}
+
 /*
  * Wake up a frozen process
  *
@@ -63,8 +67,6 @@ static inline int thaw_process(struct task_struct *p)
 }
 
 extern void refrigerator(void);
-extern int freeze_processes(void);
-extern void thaw_processes(void);
 
 static inline int try_to_freeze(void)
 {
@@ -75,6 +77,14 @@ static inline int try_to_freeze(void)
 		return 0;
 }
 
+extern bool freeze_task(struct task_struct *p, bool sig_only);
+extern void cancel_freezing(struct task_struct *p);
+
+#ifdef CONFIG_PM_SLEEP
+
+extern int freeze_processes(void);
+extern void thaw_processes(void);
+
 /*
  * The PF_FREEZER_SKIP flag should be set by a vfork parent right before it
  * calls wait_for_completion(&vfork) and reset right after it returns from this
@@ -167,18 +177,10 @@ static inline void set_freezable_with_signal(void)
 	__retval;							\
 })
 #else /* !CONFIG_PM_SLEEP */
-static inline int frozen(struct task_struct *p) { return 0; }
-static inline int freezing(struct task_struct *p) { return 0; }
-static inline void set_freeze_flag(struct task_struct *p) {}
-static inline void clear_freeze_flag(struct task_struct *p) {}
-static inline int thaw_process(struct task_struct *p) { return 1; }
 
-static inline void refrigerator(void) {}
 static inline int freeze_processes(void) { BUG(); return 0; }
 static inline void thaw_processes(void) {}
 
-static inline int try_to_freeze(void) { return 0; }
-
 static inline void freezer_do_not_count(void) {}
 static inline void freezer_count(void) {}
 static inline int freezer_should_skip(struct task_struct *p) { return 0; }
diff --git a/kernel/Makefile b/kernel/Makefile
index 4e1d7df..9844f47 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -5,7 +5,7 @@
 obj-y     = sched.o fork.o exec_domain.o panic.o printk.o \
 	    cpu.o exit.o itimer.o time.o softirq.o resource.o \
 	    sysctl.o capability.o ptrace.o timer.o user.o \
-	    signal.o sys.o kmod.o workqueue.o pid.o \
+	    signal.o sys.o kmod.o workqueue.o pid.o freezer.o \
 	    rcupdate.o extable.o params.o posix-timers.o \
 	    kthread.o wait.o kfifo.o sys_ni.o posix-cpu-timers.o mutex.o \
 	    hrtimer.o rwsem.o nsproxy.o srcu.o semaphore.o \
diff --git a/kernel/freezer.c b/kernel/freezer.c
new file mode 100644
index 0000000..cb0931f
--- /dev/null
+++ b/kernel/freezer.c
@@ -0,0 +1,122 @@
+/*
+ * kernel/freezer.c - Function to freeze a process
+ *
+ * Originally from kernel/power/process.c
+ */
+
+#include <linux/interrupt.h>
+#include <linux/suspend.h>
+#include <linux/module.h>
+#include <linux/syscalls.h>
+#include <linux/freezer.h>
+
+/*
+ * freezing is complete, mark current process as frozen
+ */
+static inline void frozen_process(void)
+{
+	if (!unlikely(current->flags & PF_NOFREEZE)) {
+		current->flags |= PF_FROZEN;
+		wmb();
+	}
+	clear_freeze_flag(current);
+}
+
+/* Refrigerator is place where frozen processes are stored :-). */
+void refrigerator(void)
+{
+	/* Hmm, should we be allowed to suspend when there are realtime
+	   processes around? */
+	long save;
+
+	task_lock(current);
+	if (freezing(current)) {
+		frozen_process();
+		task_unlock(current);
+	} else {
+		task_unlock(current);
+		return;
+	}
+	save = current->state;
+	pr_debug("%s entered refrigerator\n", current->comm);
+
+	spin_lock_irq(&current->sighand->siglock);
+	recalc_sigpending(); /* We sent fake signal, clean it up */
+	spin_unlock_irq(&current->sighand->siglock);
+
+	for (;;) {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		if (!frozen(current))
+			break;
+		schedule();
+	}
+	pr_debug("%s left refrigerator\n", current->comm);
+	__set_current_state(save);
+}
+EXPORT_SYMBOL(refrigerator);
+
+static void fake_signal_wake_up(struct task_struct *p)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&p->sighand->siglock, flags);
+	signal_wake_up(p, 0);
+	spin_unlock_irqrestore(&p->sighand->siglock, flags);
+}
+
+/**
+ *	freeze_task - send a freeze request to given task
+ *	@p: task to send the request to
+ *	@sig_only: if set, the request will only be sent if the task has the
+ *		PF_FREEZER_NOSIG flag unset
+ *	Return value: 'false', if @sig_only is set and the task has
+ *		PF_FREEZER_NOSIG set or the task is frozen, 'true', otherwise
+ *
+ *	The freeze request is sent by setting the tasks's TIF_FREEZE flag and
+ *	either sending a fake signal to it or waking it up, depending on whether
+ *	or not it has PF_FREEZER_NOSIG set.  If @sig_only is set and the task
+ *	has PF_FREEZER_NOSIG set (ie. it is a typical kernel thread), its
+ *	TIF_FREEZE flag will not be set.
+ */
+bool freeze_task(struct task_struct *p, bool sig_only)
+{
+	/*
+	 * We first check if the task is freezing and next if it has already
+	 * been frozen to avoid the race with frozen_process() which first marks
+	 * the task as frozen and next clears its TIF_FREEZE.
+	 */
+	if (!freezing(p)) {
+		rmb();
+		if (frozen(p))
+			return false;
+
+		if (!sig_only || should_send_signal(p))
+			set_freeze_flag(p);
+		else
+			return false;
+	}
+
+	if (should_send_signal(p)) {
+		if (!signal_pending(p))
+			fake_signal_wake_up(p);
+	} else if (sig_only) {
+		return false;
+	} else {
+		wake_up_state(p, TASK_INTERRUPTIBLE);
+	}
+
+	return true;
+}
+
+void cancel_freezing(struct task_struct *p)
+{
+	unsigned long flags;
+
+	if (freezing(p)) {
+		pr_debug("  clean up: %s\n", p->comm);
+		clear_freeze_flag(p);
+		spin_lock_irqsave(&p->sighand->siglock, flags);
+		recalc_sigpending_and_wake(p);
+		spin_unlock_irqrestore(&p->sighand->siglock, flags);
+	}
+}
diff --git a/kernel/power/process.c b/kernel/power/process.c
index 278946a..444cea8 100644
--- a/kernel/power/process.c
+++ b/kernel/power/process.c
@@ -28,121 +28,6 @@ static inline int freezeable(struct task_struct * p)
 	return 1;
 }
 
-/*
- * freezing is complete, mark current process as frozen
- */
-static inline void frozen_process(void)
-{
-	if (!unlikely(current->flags & PF_NOFREEZE)) {
-		current->flags |= PF_FROZEN;
-		wmb();
-	}
-	clear_freeze_flag(current);
-}
-
-/* Refrigerator is place where frozen processes are stored :-). */
-void refrigerator(void)
-{
-	/* Hmm, should we be allowed to suspend when there are realtime
-	   processes around? */
-	long save;
-
-	task_lock(current);
-	if (freezing(current)) {
-		frozen_process();
-		task_unlock(current);
-	} else {
-		task_unlock(current);
-		return;
-	}
-	save = current->state;
-	pr_debug("%s entered refrigerator\n", current->comm);
-
-	spin_lock_irq(&current->sighand->siglock);
-	recalc_sigpending(); /* We sent fake signal, clean it up */
-	spin_unlock_irq(&current->sighand->siglock);
-
-	for (;;) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		if (!frozen(current))
-			break;
-		schedule();
-	}
-	pr_debug("%s left refrigerator\n", current->comm);
-	__set_current_state(save);
-}
-
-static void fake_signal_wake_up(struct task_struct *p)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&p->sighand->siglock, flags);
-	signal_wake_up(p, 0);
-	spin_unlock_irqrestore(&p->sighand->siglock, flags);
-}
-
-static inline bool should_send_signal(struct task_struct *p)
-{
-	return !(p->flags & PF_FREEZER_NOSIG);
-}
-
-/**
- *	freeze_task - send a freeze request to given task
- *	@p: task to send the request to
- *	@sig_only: if set, the request will only be sent if the task has the
- *		PF_FREEZER_NOSIG flag unset
- *	Return value: 'false', if @sig_only is set and the task has
- *		PF_FREEZER_NOSIG set or the task is frozen, 'true', otherwise
- *
- *	The freeze request is sent by setting the tasks's TIF_FREEZE flag and
- *	either sending a fake signal to it or waking it up, depending on whether
- *	or not it has PF_FREEZER_NOSIG set.  If @sig_only is set and the task
- *	has PF_FREEZER_NOSIG set (ie. it is a typical kernel thread), its
- *	TIF_FREEZE flag will not be set.
- */
-static bool freeze_task(struct task_struct *p, bool sig_only)
-{
-	/*
-	 * We first check if the task is freezing and next if it has already
-	 * been frozen to avoid the race with frozen_process() which first marks
-	 * the task as frozen and next clears its TIF_FREEZE.
-	 */
-	if (!freezing(p)) {
-		rmb();
-		if (frozen(p))
-			return false;
-
-		if (!sig_only || should_send_signal(p))
-			set_freeze_flag(p);
-		else
-			return false;
-	}
-
-	if (should_send_signal(p)) {
-		if (!signal_pending(p))
-			fake_signal_wake_up(p);
-	} else if (sig_only) {
-		return false;
-	} else {
-		wake_up_state(p, TASK_INTERRUPTIBLE);
-	}
-
-	return true;
-}
-
-static void cancel_freezing(struct task_struct *p)
-{
-	unsigned long flags;
-
-	if (freezing(p)) {
-		pr_debug("  clean up: %s\n", p->comm);
-		clear_freeze_flag(p);
-		spin_lock_irqsave(&p->sighand->siglock, flags);
-		recalc_sigpending_and_wake(p);
-		spin_unlock_irqrestore(&p->sighand->siglock, flags);
-	}
-}
-
 static int try_to_freeze_tasks(bool sig_only)
 {
 	struct task_struct *g, *p;
@@ -264,4 +149,3 @@ void thaw_processes(void)
 	printk("done.\n");
 }
 
-EXPORT_SYMBOL(refrigerator);
-- 
1.5.3.7

-- 
