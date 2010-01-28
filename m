From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH RFC] s390: let tasks know to restart syscalls after
	sys_restart()
Date: Thu, 28 Jan 2010 17:35:28 -0600
Message-ID: <20100128233528.GA10140@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

(This is a patch against the checkpoint/restart kernel tree at
http://git.ncl.cs.columbia.edu/?p=linux-cr.git;a=shortlog;h=refs/heads/ckpt-v19-rc2.9)

On x86, do_signal() leaves -516 in eax while it freezes, which
sys_restart() can use to detect that it should restart the
syscall which was interrupted by a signal (or the freezer).

On s390, gprs[2] gets tweaked to -EINTR (-4) instead, leaving
us no reliable way to tell whether should be restarted.  If the
task is checkpointed here and then restarted, then the last part
of do_signal() won't be done, and the interrupted syscall won't
be restarted.

This patch defines TIF_RESTARTBLOCK as a thread flag showing that
the thread expects to be frozen while kicked out of a restartable
syscall by a signal.

The TIF_RESTARTBLOCK flag is only set for the duration of the
get get_signal_to_deliver() which is where the task may get
frozen.  We also set it in sys_restart() if the checkpointed task
had had TIF_RESTARTBLOCK set.  It will get cleared if upon exiting
sys_restart() we jump to sysc_sigpending.  If instead we jump back
to do_signal(), then TIF_RESTARTBLOCK will stay set again until
after get_signal_to_deliver() so that if it immediately freezes and
is re-checkpointed, the resulting second checkpoint image again
will have TIF_RESTARTBLOCK set.

To test this, add a dummy handler for SIGUSR1 to cr_tests/sleep/sleeptest.c,
open two terminals, and do:

Terminal 1:                             Terminal :
mount -t cgroup -o freezer freezer /cgroup
mkdir /cgroup/1 /cgroup/2
echo $$ > /cgroup/1/tasks
./sleeptest

				    echo FROZEN > /cgroup/1/freezer.state
				    checkpoint `pidof sleeptest` > /tmp/out
				    thaw

restart -F /cgroup/2 < /tmp/out

				    kill -USR1 `pidof sleeptest`;
				    echo THAWED > /cgroup/2/freezer.state ;
				    sleep 0.3;
				    echo FROZEN > /cgroup/2/freezer.state;
				    checkpoint `pidof sleeptest` > /tmp/out2;
				    echo THAWED > /cgroup/2/freezer.state

restart < /tmp/out2

Without this patch, the first restart will immediately exit.  Without
re-setting TIF_RESTARTBLOCK in sys_restart(), the second restart will
immediately exit.  With this full patch, it will restart the sleep
correctly.

Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/include/asm/checkpoint_hdr.h |    5 +++
 arch/s390/include/asm/thread_info.h    |    2 +
 arch/s390/kernel/checkpoint.c          |   52 +++++++++++++++++++++++++++++++-
 arch/s390/kernel/entry64.S             |    2 +
 arch/s390/kernel/signal.c              |    6 ++++
 5 files changed, 66 insertions(+), 1 deletions(-)

diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
index a8c2a3d..fd8be2a 100644
--- a/arch/s390/include/asm/checkpoint_hdr.h
+++ b/arch/s390/include/asm/checkpoint_hdr.h
@@ -76,6 +76,11 @@ struct ckpt_hdr_cpu {
 	__u8 instruction_fetch;
 };
 
+struct ckpt_hdr_thread {
+	struct ckpt_hdr h;
+	__u64 thread_info_flags;
+};
+
 struct ckpt_hdr_mm_context {
 	struct ckpt_hdr h;
 	unsigned long vdso_base;
diff --git a/arch/s390/include/asm/thread_info.h b/arch/s390/include/asm/thread_info.h
index 07eb61b..6ef11b2 100644
--- a/arch/s390/include/asm/thread_info.h
+++ b/arch/s390/include/asm/thread_info.h
@@ -100,6 +100,7 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_MEMDIE		19
 #define TIF_RESTORE_SIGMASK	20	/* restore signal mask in do_signal() */
 #define TIF_FREEZE		21	/* thread is freezing for suspend */
+#define TIF_RESTARTBLOCK	23	/* use restart block after sys_restart */
 
 #define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
@@ -116,6 +117,7 @@ static inline struct thread_info *current_thread_info(void)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_31BIT		(1<<TIF_31BIT)
 #define _TIF_FREEZE		(1<<TIF_FREEZE)
+#define _TIF_RESTARTBLOCK	(1<<TIF_RESTARTBLOCK)
 
 #endif /* __KERNEL__ */
 
diff --git a/arch/s390/kernel/checkpoint.c b/arch/s390/kernel/checkpoint.c
index 60ba04d..092fd87 100644
--- a/arch/s390/kernel/checkpoint.c
+++ b/arch/s390/kernel/checkpoint.c
@@ -65,6 +65,16 @@ static void s390_copy_regs(int op, struct ckpt_hdr_cpu *h,
 		BUG_ON(h->gprs[2] < 0);
 		h->gprs[2] = 0;
 	}
+
+	/*
+	 * if checkpoint was taken while interrupted from restartable
+	 * system call, then restore_thread() will have already reset
+	 * TIF_RESTARTBLOCK, but it did not set gprs[2].  It's easier to
+	 * do that here where gprs registers are all restored.
+	 */
+	if (op == CKPT_RST && test_thread_flag(TIF_RESTARTBLOCK))
+		regs->gprs[2] = __NR_restart_syscall;
+
 	CKPT_COPY_ARRAY(op, h->fprs, thr->fp_regs.fprs, NUM_FPRS);
 	CKPT_COPY_ARRAY(op, h->acrs, thr->acrs, NUM_ACRS);
 	CKPT_COPY_ARRAY(op, h->per_control_regs,
@@ -83,12 +93,24 @@ static void s390_mm(int op, struct ckpt_hdr_mm_context *h,
 
 int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
 {
+	struct ckpt_hdr_thread *h;
+	int ret;
+
 	/* we will eventually support this, as we do on x86-64 */
 	if (test_tsk_thread_flag(t, TIF_31BIT)) {
 		ckpt_err(ctx, -EINVAL, "checkpoint of 31-bit task\n");
 		return -EINVAL;
 	}
-	return 0;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_THREAD);
+	if (!h)
+		return -ENOMEM;
+
+	h->thread_info_flags = task_thread_info(t)->flags;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
 }
 
 /* dump the cpu state and registers of a given task */
@@ -148,11 +170,39 @@ int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
 
 int restore_thread(struct ckpt_ctx *ctx)
 {
+	struct ckpt_hdr_thread *h;
+
 	/* a 31-bit task cannot call sys_restart right now */
 	if (test_thread_flag(TIF_31BIT)) {
 		ckpt_err(ctx, -EINVAL, "restart from 31-bit task\n");
 		return -EINVAL;
 	}
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_THREAD);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	/*
+	 * if the checkpointed task was frozen in a syscall with
+	 * -ERESTART_RESTARTBLOCK (switched to -EINTR during do_signal()
+	 * before try_to_freeze() happened) then after restart we need
+	 * to call __NR_restart_syscall to continue.  Fix up here.
+	 * In other words, we're doing the rest of the fixup which the
+	 * end of do_signal(), which won't now be run, would have done.
+	 *
+	 * We also re-set TIF_RESTARTBLOCK in case we hit do_signal
+	 * right after sys_restart() instead of sysc_restart, since
+	 * we would enter do_signal() with different inital conditions
+	 * than usual for being "inside" a restartable syscall.
+	 */
+	if (h->thread_info_flags & _TIF_RESTARTBLOCK) {
+		set_thread_flag(TIF_RESTART_SVC);
+		set_thread_flag(TIF_RESTARTBLOCK);
+	}
+
+	/* need to do something with TIF_RESTORE_SIGMASK ? */
+
+	ckpt_hdr_put(ctx, h);
 	return 0;
 }
 
diff --git a/arch/s390/kernel/entry64.S b/arch/s390/kernel/entry64.S
index 9aff1d4..798ea9c 100644
--- a/arch/s390/kernel/entry64.S
+++ b/arch/s390/kernel/entry64.S
@@ -58,6 +58,7 @@ _TIF_WORK_INT = (_TIF_SIGPENDING | _TIF_NOTIFY_RESUME | _TIF_NEED_RESCHED | \
 		 _TIF_MCCK_PENDING)
 _TIF_SYSCALL = (_TIF_SYSCALL_TRACE>>8 | _TIF_SYSCALL_AUDIT>>8 | \
 		_TIF_SECCOMP>>8 | _TIF_SYSCALL_TRACEPOINT>>8)
+CLR_TIF_RESTARTBLOCK = (255 - (_TIF_RESTARTBLOCK>>16))
 
 #define BASED(name) name-system_call(%r13)
 
@@ -338,6 +339,7 @@ sysc_mcck_pending:
 #
 sysc_sigpending:
 	ni	__TI_flags+7(%r9),255-_TIF_SINGLE_STEP # clear TIF_SINGLE_STEP
+	ni	__TI_flags+6(%r9),CLR_TIF_RESTARTBLOCK # clear TIF_RESTARTBLOCK
 	la	%r2,SP_PTREGS(%r15)	# load pt_regs
 	brasl	%r14,do_signal		# call do_signal
 	tm	__TI_flags+7(%r9),_TIF_RESTART_SVC
diff --git a/arch/s390/kernel/signal.c b/arch/s390/kernel/signal.c
index 6b4fef8..503fd09 100644
--- a/arch/s390/kernel/signal.c
+++ b/arch/s390/kernel/signal.c
@@ -458,6 +458,8 @@ void do_signal(struct pt_regs *regs)
 			regs->psw.addr = restart_addr;
 			break;
 		case -ERESTART_RESTARTBLOCK:
+			/* if checkpointed here, set needs_restart */
+			set_thread_flag(TIF_RESTARTBLOCK);
 			regs->gprs[2] = -EINTR;
 		}
 		regs->svcnr = 0;	/* Don't deal with this again. */
@@ -467,6 +469,10 @@ void do_signal(struct pt_regs *regs)
 	   the debugger may change all our registers ... */
 	signr = get_signal_to_deliver(&info, &ka, regs, NULL);
 
+	/* we've passed the try_to_freeze() in get_signal_to_deliver(), won't
+	 * be checkpointed before end of do_signal() */
+	clear_thread_flag(TIF_RESTARTBLOCK);
+
 	/* Depending on the signal settings we may need to revert the
 	   decision to restart the system call. */
 	if (signr > 0 && regs->psw.addr == restart_addr) {
-- 
1.6.1
