From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] RFC: s390: Move get_signal_to_deliver() up in do_signal
Date: Thu, 11 Feb 2010 17:03:31 -0600
Message-ID: <20100211230331.GA28209@us.ibm.com>
References: <20100210204019.GA24269@us.ibm.com>
	<20100211094838.4550edd9@mschwide.boeblingen.de.ibm.com>
	<20100211172917.GD6884@us.ibm.com>
	<4B7442EC.5080903@cs.columbia.edu>
	<20100211183903.GA17753@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100211183903.GA17753-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, s390 <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Well, perhaps I've been making this more complicated than it
> needs to be.
> 
> If we get frozen+checkpointed, then no matter whether we were
> frozen with a real pending signal or not, we won't handle the
> signal during restart, so we can treat it as though signr==0.
> 
> So, in that case, the only thing we need to change at end of
> sys_restart is to handle the case:
> 
> 	/* Restart a different system call. */
> 	if (retval == -ERESTART_RESTARTBLOCK
> 			&& regs->psw.addr == continue_addr) {
> 		regs->gprs[2] = __NR_restart_syscall;
> 		set_thread_flag(TIF_RESTART_SVC);
> 	}
> 
> Now that's of course a problem bc we don't know continue_addr
> when we're in sys_restart().  So before we go into get_signal_to_deliver(),
> we should set a new TIF flag which represents the fact that we are
> inside do_signal with those conditions.
> 
> Then at end of restore_thread(), if that flag is set, we do the
> 
> 	regs->gprs[2] = __NR_restart_syscall;
> 	set_thread_flag(TIF_RESTART_SVC);
> 
> (which presumably goes into a helper)
> 
> If there was a pending signal which we were intending to handle
> when checkpointed, then that will simply be delivered after we
> exit sys_restart.  That is no different from the case where we
> got another signal delivered while a slow sighandler was executing.
> 
> I'll try implementing that idea.
> 
> -serge

Like so:

From b50eb90da03e82ae6e7a2f1a8362e93c18d52074 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Thu, 11 Feb 2010 14:05:16 -0500
Subject: [PATCH 1/1] set TIF_RESTART_SVC when needed after sys_restart

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/include/asm/checkpoint_hdr.h |    5 +++
 arch/s390/include/asm/thread_info.h    |    2 +
 arch/s390/kernel/checkpoint.c          |   52 +++++++++++++++++++++++++++++++-
 arch/s390/kernel/signal.c              |   16 ++++++++++
 4 files changed, 74 insertions(+), 1 deletions(-)

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
index 66069e7..61e84e5 100644
--- a/arch/s390/include/asm/thread_info.h
+++ b/arch/s390/include/asm/thread_info.h
@@ -99,6 +99,7 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_MEMDIE		18
 #define TIF_RESTORE_SIGMASK	19	/* restore signal mask in do_signal() */
 #define TIF_FREEZE		20	/* thread is freezing for suspend */
+#define TIF_SIG_RESTARTBLOCK	23	/* restart must set TIF_RESTART_SVC */
 
 #define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
@@ -114,6 +115,7 @@ static inline struct thread_info *current_thread_info(void)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_31BIT		(1<<TIF_31BIT)
 #define _TIF_FREEZE		(1<<TIF_FREEZE)
+#define _TIF_SIG_RESTARTBLOCK	(1<<TIF_SIG_RESTARTBLOCK)
 
 #endif /* __KERNEL__ */
 
diff --git a/arch/s390/kernel/checkpoint.c b/arch/s390/kernel/checkpoint.c
index 60ba04d..cc7f341 100644
--- a/arch/s390/kernel/checkpoint.c
+++ b/arch/s390/kernel/checkpoint.c
@@ -12,6 +12,7 @@
 #include <asm/system.h>
 #include <asm/pgtable.h>
 #include <asm/elf.h>
+#include <asm/unistd.h>
 
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
@@ -65,6 +66,18 @@ static void s390_copy_regs(int op, struct ckpt_hdr_cpu *h,
 		BUG_ON(h->gprs[2] < 0);
 		h->gprs[2] = 0;
 	}
+
+	/*
+	 * if a checkpoint was taken while interrupted from a restartable
+	 * syscall, then treat this as though signr==0 (since we did not
+	 * handle the signal) and finish the last part of do_signal
+	 */
+	if (op == CKPT_RST && test_thread_flag(TIF_SIG_RESTARTBLOCK)) {
+		regs->gprs[2] = __NR_restart_syscall;
+		set_thread_flag(TIF_RESTART_SVC);
+		clear_thread_flag(TIF_SIG_RESTARTBLOCK);
+	}
+
 	CKPT_COPY_ARRAY(op, h->fprs, thr->fp_regs.fprs, NUM_FPRS);
 	CKPT_COPY_ARRAY(op, h->acrs, thr->acrs, NUM_ACRS);
 	CKPT_COPY_ARRAY(op, h->per_control_regs,
@@ -83,12 +96,24 @@ static void s390_mm(int op, struct ckpt_hdr_mm_context *h,
 
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
@@ -148,11 +173,36 @@ int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
 
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
+	 * If we were checkpointed while do_signal() interrupted a
+	 * syscall with restart blocks, then we have some cleanup to
+	 * do at end of restart, in order to finish our pretense of
+	 * having handled signr==0.  (See last part of do_signal).
+	 *
+	 * We can't set gprs[2] here bc we haven't copied registers
+	 * yet, that happens later in restore_cpu().  So re-set the
+	 * TIF_SIG_RESTARTBLOCK thread flag so we can detect it
+	 * at restore_cpu()->s390_copy_regs() and do the right thing.
+	 */
+	if (h->thread_info_flags & _TIF_SIG_RESTARTBLOCK)
+		set_thread_flag(TIF_SIG_RESTARTBLOCK);
+
+	/* will have to handle TIF_RESTORE_SIGMASK as well */
+
+	ckpt_hdr_put(ctx, h);
+
 	return 0;
 }
 
diff --git a/arch/s390/kernel/signal.c b/arch/s390/kernel/signal.c
index 1675c48..9b6ca21 100644
--- a/arch/s390/kernel/signal.c
+++ b/arch/s390/kernel/signal.c
@@ -459,6 +459,16 @@ void do_signal(struct pt_regs *regs)
 			break;
 		case -ERESTART_RESTARTBLOCK:
 			regs->gprs[2] = -EINTR;
+			/*
+			 * This condition is the only one which requires
+			 * special care after handling a signr==0.  So if
+			 * we get frozen and checkpointed at the
+			 * get_signal_to_deliver() below, then we need
+			 * to convey this condition to sys_restart() so it
+			 * can set the restored thread up to run the restart
+			 * block.
+			 */
+			set_thread_flag(TIF_SIG_RESTARTBLOCK);
 		}
 		regs->svcnr = 0;	/* Don't deal with this again. */
 	}
@@ -467,6 +477,12 @@ void do_signal(struct pt_regs *regs)
 	   the debugger may change all our registers ... */
 	signr = get_signal_to_deliver(&info, &ka, regs, NULL);
 
+	/*
+	 * we won't get frozen past this so clear the thread flag hinting
+	 * to sys_restart that TIF_RESTART_SVC must be set.
+	 */
+	clear_thread_flag(TIF_SIG_RESTARTBLOCK);
+
 	/* Depending on the signal settings we may need to revert the
 	   decision to restart the system call. */
 	if (signr > 0 && regs->psw.addr == restart_addr) {
-- 
1.6.1
