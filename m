From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [PATCH 1/7][v8] Remove 'handler' parameter to tracehook functions
Date: Wed, 18 Feb 2009 19:05:27 -0800
Message-ID: <20090219030527.GA18990@us.ibm.com>
References: <20090219030207.GA18783@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756063AbZBSDFv@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090219030207.GA18783@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: Oleg Nesterov <oleg@tv-sign.ru>, roland@redhat.com, "Eric W. Biederman" <ebiederm@xmission.com>, daniel@hozac.com, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


From: Oleg Nesterov <oleg@redhat.com>
Date: Wed, 24 Dec 2008 13:35:17 -0800
Subject: [PATCH 1/7][v8] Remove 'handler' parameter to tracehook functions

Based on an earlier patch submitted by Oleg Nesterov and comments
from Roland McGrath (http://lkml.org/lkml/2008/11/19/258).

The handler parameter is currently unused in the tracehook functions.
Besides, the tracehook functions are called with siglock held, so the
functions can check the handler if they later need to.

Removing the parameter simiplifies changes to sig_ignored() in a follow-on
patch.

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Acked-by: Roland McGrath <roland@redhat.com>
---
 arch/x86/kernel/ptrace.c  |    2 +-
 include/linux/tracehook.h |   13 ++++---------
 kernel/signal.c           |    6 +++---
 3 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index 5a4c23d..2117492 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -1461,6 +1461,6 @@ asmregparm void syscall_trace_leave(struct pt_regs *regs)
 	 * system call instruction.
 	 */
 	if (test_thread_flag(TIF_SINGLESTEP) &&
-	    tracehook_consider_fatal_signal(current, SIGTRAP, SIG_DFL))
+	    tracehook_consider_fatal_signal(current, SIGTRAP))
 		send_sigtrap(current, regs, 0, TRAP_BRKPT);
 }
diff --git a/include/linux/tracehook.h b/include/linux/tracehook.h
index c913155..c7aa154 100644
--- a/include/linux/tracehook.h
+++ b/include/linux/tracehook.h
@@ -388,17 +388,14 @@ static inline void tracehook_signal_handler(int sig, siginfo_t *info,
  * tracehook_consider_ignored_signal - suppress short-circuit of ignored signal
  * @task:		task receiving the signal
  * @sig:		signal number being sent
- * @handler:		%SIG_IGN or %SIG_DFL
  *
  * Return zero iff tracing doesn't care to examine this ignored signal,
  * so it can short-circuit normal delivery and never even get queued.
- * Either @handler is %SIG_DFL and @sig's default is ignore, or it's %SIG_IGN.
  *
  * Called with @task->sighand->siglock held.
  */
 static inline int tracehook_consider_ignored_signal(struct task_struct *task,
-						    int sig,
-						    void __user *handler)
+						    int sig)
 {
 	return (task_ptrace(task) & PT_PTRACED) != 0;
 }
@@ -407,19 +404,17 @@ static inline int tracehook_consider_ignored_signal(struct task_struct *task,
  * tracehook_consider_fatal_signal - suppress special handling of fatal signal
  * @task:		task receiving the signal
  * @sig:		signal number being sent
- * @handler:		%SIG_DFL or %SIG_IGN
  *
  * Return nonzero to prevent special handling of this termination signal.
- * Normally @handler is %SIG_DFL.  It can be %SIG_IGN if @sig is ignored,
- * in which case force_sig() is about to reset it to %SIG_DFL.
+ * Normally handler for signal is %SIG_DFL.  It can be %SIG_IGN if @sig is
+ * ignored, in which case force_sig() is about to reset it to %SIG_DFL.
  * When this returns zero, this signal might cause a quick termination
  * that does not give the debugger a chance to intercept the signal.
  *
  * Called with or without @task->sighand->siglock held.
  */
 static inline int tracehook_consider_fatal_signal(struct task_struct *task,
-						  int sig,
-						  void __user *handler)
+						  int sig)
 {
 	return (task_ptrace(task) & PT_PTRACED) != 0;
 }
diff --git a/kernel/signal.c b/kernel/signal.c
index 2a74fe8..ee8a8f1 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -74,7 +74,7 @@ static int sig_ignored(struct task_struct *t, int sig)
 	/*
 	 * Tracers may want to know about even ignored signals.
 	 */
-	return !tracehook_consider_ignored_signal(t, sig, handler);
+	return !tracehook_consider_ignored_signal(t, sig);
 }
 
 /*
@@ -318,7 +318,7 @@ int unhandled_signal(struct task_struct *tsk, int sig)
 		return 1;
 	if (handler != SIG_IGN && handler != SIG_DFL)
 		return 0;
-	return !tracehook_consider_fatal_signal(tsk, sig, handler);
+	return !tracehook_consider_fatal_signal(tsk, sig);
 }
 
 
@@ -777,7 +777,7 @@ static void complete_signal(int sig, struct task_struct *p, int group)
 	    !(signal->flags & (SIGNAL_UNKILLABLE | SIGNAL_GROUP_EXIT)) &&
 	    !sigismember(&t->real_blocked, sig) &&
 	    (sig == SIGKILL ||
-	     !tracehook_consider_fatal_signal(t, sig, SIG_DFL))) {
+	     !tracehook_consider_fatal_signal(t, sig))) {
 		/*
 		 * This signal will be fatal to the whole group.
 		 */
-- 
1.5.2.5
