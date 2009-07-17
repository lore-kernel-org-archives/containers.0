From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: [patch 2/2] sched: fix nr_uninterruptible accounting of frozen tasks
	really
Date: Fri, 17 Jul 2009 12:25:01 -0000
Message-ID: <20090717122103.225652146__4729.09687455303$1247833671$gmane$org@linutronix.de>
References: <20090717121545.489258927@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=freezer-fix-accounting-for-real.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Rafael Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>, Nigel Cunningham <nigel-jrkICu/7yk3k1uMJSBkQmQ@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

commit e3c8ca8336 (sched: do not count frozen tasks toward load) broke
the nr_uninterruptible accounting on freeze/thaw. On freeze the task
is excluded from accounting with a check for (task->flags &
PF_FROZEN), but that flag is cleared before the task is thawed. So
while we prevent that the freezing task with state
TASK_UNINTERRUPTIBLE is accounted to nr_uninterruptible we decrement
nr_uninterruptible on thaw.

Use a separate flag which is handled by the freezing task itself. Set
it before calling the scheduler with TASK_UNINTERRUPTIBLE state and
clear it after we return from frozen state.

Signed-off-by: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Cc: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Nigel Cunningham <nigel-jrkICu/7yk3k1uMJSBkQmQ@public.gmane.org>
Cc: <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

---
 include/linux/sched.h |    3 ++-
 kernel/freezer.c      |    7 +++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -209,7 +209,7 @@ extern unsigned long long time_sync_thre
 			((task->state & (__TASK_STOPPED | __TASK_TRACED)) != 0)
 #define task_contributes_to_load(task)	\
 				((task->state & TASK_UNINTERRUPTIBLE) != 0 && \
-				 (task->flags & PF_FROZEN) == 0)
+				 (task->flags & PF_FREEZING) == 0)
 
 #define __set_task_state(tsk, state_value)		\
 	do { (tsk)->state = (state_value); } while (0)
@@ -1680,6 +1680,7 @@ extern cputime_t task_gtime(struct task_
 #define PF_MEMALLOC	0x00000800	/* Allocating memory */
 #define PF_FLUSHER	0x00001000	/* responsible for disk writeback */
 #define PF_USED_MATH	0x00002000	/* if unset the fpu must be initialized before use */
+#define PF_FREEZING	0x00004000	/* freeze in progress. do not account to load */
 #define PF_NOFREEZE	0x00008000	/* this thread should not be frozen */
 #define PF_FROZEN	0x00010000	/* frozen for system suspend */
 #define PF_FSTRANS	0x00020000	/* inside a filesystem transaction */
Index: linux-2.6/kernel/freezer.c
===================================================================
--- linux-2.6.orig/kernel/freezer.c
+++ linux-2.6/kernel/freezer.c
@@ -44,12 +44,19 @@ void refrigerator(void)
 	recalc_sigpending(); /* We sent fake signal, clean it up */
 	spin_unlock_irq(&current->sighand->siglock);
 
+	/* prevent accounting of that task to load */
+	current->flags |= PF_FREEZING;
+
 	for (;;) {
 		set_current_state(TASK_UNINTERRUPTIBLE);
 		if (!frozen(current))
 			break;
 		schedule();
 	}
+
+	/* Remove the accounting blocker */
+	current->flags &= ~PF_FREEZING;
+
 	pr_debug("%s left refrigerator\n", current->comm);
 	__set_current_state(save);
 }
