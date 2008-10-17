From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/10] Introduce functions to restart a process
Date: Sat, 18 Oct 2008 03:11:36 +0400
Message-ID: <1224285098-573-9-git-send-email-major__307.748272507702$1224285432$gmane$org@openvz.org>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-2-git-send-email-major@openvz.org>
	<1224285098-573-3-git-send-email-major@openvz.org>
	<1224285098-573-4-git-send-email-major@openvz.org>
	<1224285098-573-5-git-send-email-major@openvz.org>
	<1224285098-573-6-git-send-email-major@openvz.org>
	<1224285098-573-7-git-send-email-major@openvz.org>
	<1224285098-573-8-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224285098-573-8-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Functions to restart process, restore its state, fpu and registers are added.

Signed-off-by: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 arch/x86/kernel/entry_32.S   |   21 +++
 arch/x86/kernel/process_32.c |    3 +
 checkpoint/Makefile          |    3 +-
 checkpoint/checkpoint.h      |    2 +
 checkpoint/restart.c         |    2 +-
 checkpoint/rst_process.c     |  277 ++++++++++++++++++++++++++++++++++++++++++
 kernel/sched.c               |    1 +
 7 files changed, 307 insertions(+), 2 deletions(-)
 create mode 100644 checkpoint/rst_process.c

diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
index 109792b..a4848a3 100644
--- a/arch/x86/kernel/entry_32.S
+++ b/arch/x86/kernel/entry_32.S
@@ -225,6 +225,7 @@ ENTRY(ret_from_fork)
 	GET_THREAD_INFO(%ebp)
 	popl %eax
 	CFI_ADJUST_CFA_OFFSET -4
+ret_from_fork_tail:
 	pushl $0x0202			# Reset kernel eflags
 	CFI_ADJUST_CFA_OFFSET 4
 	popfl
@@ -233,6 +234,26 @@ ENTRY(ret_from_fork)
 	CFI_ENDPROC
 END(ret_from_fork)
 
+ENTRY(i386_ret_from_resume)
+	CFI_STARTPROC
+	pushl %eax
+	CFI_ADJUST_CFA_OFFSET 4
+	call schedule_tail
+	GET_THREAD_INFO(%ebp)
+	popl %eax
+	CFI_ADJUST_CFA_OFFSET -4
+	movl (%esp), %eax
+	testl %eax, %eax
+	jz    1f
+	pushl %esp
+	call  *%eax
+	addl  $4, %esp
+1:
+	addl  $256, %esp
+	jmp   ret_from_fork_tail
+	CFI_ENDPROC
+END(i386_ret_from_resume)
+
 /*
  * Return to user mode is not as complex as all this looks,
  * but we want the default path for a system call return to
diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index 4711eed..1bdec02 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -58,6 +58,9 @@
 #include <asm/kdebug.h>
 
 asmlinkage void ret_from_fork(void) __asm__("ret_from_fork");
+EXPORT_SYMBOL(ret_from_fork);
+asmlinkage void i386_ret_from_resume(void) __asm__("i386_ret_from_resume");
+EXPORT_SYMBOL(i386_ret_from_resume);
 
 DEFINE_PER_CPU(struct task_struct *, current_task) = &init_task;
 EXPORT_PER_CPU_SYMBOL(current_task);
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 47c7852..689a0eb 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -2,4 +2,5 @@ obj-y += sys_core.o
 
 obj-$(CONFIG_CHECKPOINT) += cptrst.o
 
-cptrst-objs := sys.o checkpoint.o cpt_process.o cpt_mm.o restart.o
+cptrst-objs := sys.o checkpoint.o cpt_process.o cpt_mm.o restart.o \
+	       rst_process.o
diff --git a/checkpoint/checkpoint.h b/checkpoint/checkpoint.h
index 0608bb9..1d0ca49 100644
--- a/checkpoint/checkpoint.h
+++ b/checkpoint/checkpoint.h
@@ -63,3 +63,5 @@ int dump_container(struct cpt_context *ctx);
 int cpt_dump_task(struct task_struct *tsk, struct cpt_context *ctx);
 int cpt_dump_mm(struct task_struct *tsk, struct cpt_context *ctx);
 int restart_container(struct cpt_context *ctx);
+int rst_get_object(int type, void *tmp, int size, struct cpt_context *ctx);
+int rst_restart_process(struct cpt_context *ctx);
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index acfcadb..62cef28 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -81,7 +81,7 @@ int restart_container(struct cpt_context *ctx)
 
 	/* Restart process */
 	if (!err)
-		err = -ENOSYS;
+		err = rst_restart_process(ctx);
 
 	return err;
 }
diff --git a/checkpoint/rst_process.c b/checkpoint/rst_process.c
new file mode 100644
index 0000000..b9f745e
--- /dev/null
+++ b/checkpoint/rst_process.c
@@ -0,0 +1,277 @@
+/*
+ *  Copyright (C) 2008 Parallels, Inc.
+ *
+ *  Author: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ *
+ */
+
+#include <linux/sched.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/version.h>
+#include <linux/module.h>
+
+#include "checkpoint.h"
+#include "cpt_image.h"
+
+#define HOOK_RESERVE	256
+
+struct thr_context {
+	struct completion complete;
+	int error;
+	struct cpt_context *ctx;
+	struct task_struct *tsk;
+};
+
+int local_kernel_thread(int (*fn)(void *), void * arg, unsigned long flags, pid_t pid)
+{
+	pid_t ret;
+
+	if (current->fs == NULL) {
+		/* do_fork_pid() hates processes without fs, oopses. */
+		eprintk("local_kernel_thread: current->fs==NULL\n");
+		return -EINVAL;
+	}
+	if (!try_module_get(THIS_MODULE))
+		return -EBUSY;
+	ret = kernel_thread(fn, arg, flags);
+	if (ret < 0)
+		module_put(THIS_MODULE);
+	return ret;
+}
+
+static unsigned int decode_task_flags(unsigned int task_flags)
+{
+	unsigned int flags = 0;
+
+	if (task_flags & (1 << CPT_PF_EXITING))
+		flags |= PF_EXITING;
+	if (task_flags & (1 << CPT_PF_FORKNOEXEC))
+		flags |= PF_FORKNOEXEC;
+	if (task_flags & (1 << CPT_PF_SUPERPRIV))
+		flags |= PF_SUPERPRIV;
+	if (task_flags & (1 << CPT_PF_DUMPCORE))
+		flags |= PF_DUMPCORE;
+	if (task_flags & (1 << CPT_PF_SIGNALED))
+		flags |= PF_SIGNALED;
+	
+	return flags;
+		
+}
+
+int rst_restore_task_struct(struct task_struct *tsk, struct cpt_task_image *ti,
+			    struct cpt_context *ctx)
+{
+	int i;
+
+	/* Restore only saved flags, comm and tls for now */
+	tsk->flags = decode_task_flags(ti->cpt_flags);
+	clear_tsk_thread_flag(tsk, TIF_FREEZE);
+	memcpy(tsk->comm, ti->cpt_comm, TASK_COMM_LEN);
+	for (i = 0; i < GDT_ENTRY_TLS_ENTRIES; i++) {
+		tsk->thread.tls_array[i].a = ti->cpt_tls[i] & 0xFFFFFFFF;
+		tsk->thread.tls_array[i].b = ti->cpt_tls[i] >> 32;
+	}
+
+	return 0;
+}
+
+static int rst_restore_fpustate(struct task_struct *tsk, struct cpt_task_image *ti,
+				struct cpt_context *ctx)
+{
+	struct cpt_obj_bits hdr;
+	int err;
+	char *buf;
+
+	clear_stopped_child_used_math(tsk);
+
+	err = rst_get_object(CPT_OBJ_BITS, &hdr, sizeof(hdr), ctx);
+	if (err < 0)
+		return err;
+
+	buf = kmalloc(hdr.cpt_size, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	err = ctx->read(buf, hdr.cpt_size, ctx);
+	if (err)
+		goto out;
+
+	if (hdr.cpt_content == CPT_CONTENT_X86_FPUSTATE && cpu_has_fxsr) {
+		memcpy(&tsk->thread.xstate, buf,
+				sizeof(struct i387_fxsave_struct));
+		if (ti->cpt_flags & CPT_PF_USED_MATH)
+			set_stopped_child_used_math(tsk);
+	}
+#ifndef CONFIG_X86_64
+	else if (hdr.cpt_content == CPT_CONTENT_X86_FPUSTATE_OLD &&
+			!cpu_has_fxsr) {		
+		memcpy(&tsk->thread.xstate, buf,
+				sizeof(struct i387_fsave_struct));
+		if (ti->cpt_flags & CPT_PF_USED_MATH)
+			set_stopped_child_used_math(tsk);
+	}
+#endif
+
+out:
+	kfree(buf);
+	return err;
+}
+
+static u32 decode_segment(u32 segid)
+{
+	if (segid == CPT_SEG_ZERO)
+		return 0;
+
+	/* TLS descriptors */
+	if (segid <= CPT_SEG_TLS3)
+		return ((GDT_ENTRY_TLS_MIN + segid - CPT_SEG_TLS1) << 3) + 3;
+
+	/* LDT descriptor, it is just an index to LDT array */
+	if (segid >= CPT_SEG_LDT)
+		return ((segid - CPT_SEG_LDT) << 3) | 7;
+
+	/* Check for one of standard descriptors */
+	if (segid == CPT_SEG_USER32_DS)
+		return __USER_DS;
+	if (segid == CPT_SEG_USER32_CS)
+		return __USER_CS;
+
+	eprintk("Invalid segment reg %d\n", segid);
+	return 0;
+}
+
+static int rst_restore_registers(struct task_struct *tsk, struct cpt_context *ctx)
+{
+	struct cpt_x86_regs ri;
+	struct pt_regs *regs = task_pt_regs(tsk);
+	extern char i386_ret_from_resume;
+	int err;
+
+	err = rst_get_object(CPT_OBJ_X86_REGS, &ri, sizeof(ri), ctx);
+	if (err < 0)
+		return err;
+
+	tsk->thread.sp = (unsigned long) regs;
+	tsk->thread.sp0 = (unsigned long) (regs+1);
+	tsk->thread.ip = (unsigned long) &i386_ret_from_resume;
+
+	tsk->thread.gs = decode_segment(ri.cpt_gs);
+	tsk->thread.debugreg0 = ri.cpt_debugreg[0];
+	tsk->thread.debugreg1 = ri.cpt_debugreg[1];
+	tsk->thread.debugreg2 = ri.cpt_debugreg[2];
+	tsk->thread.debugreg3 = ri.cpt_debugreg[3];
+	tsk->thread.debugreg6 = ri.cpt_debugreg[6];
+	tsk->thread.debugreg7 = ri.cpt_debugreg[7];
+
+	regs->bx = ri.cpt_bx;
+	regs->cx = ri.cpt_cx;
+	regs->dx = ri.cpt_dx;
+	regs->si = ri.cpt_si;
+	regs->di = ri.cpt_di;
+	regs->bp = ri.cpt_bp;
+	regs->ax = ri.cpt_ax;
+	regs->orig_ax = ri.cpt_orig_ax;
+	regs->ip = ri.cpt_ip;
+	regs->flags = ri.cpt_flags;
+	regs->sp = ri.cpt_sp;
+
+	regs->cs = decode_segment(ri.cpt_cs);
+	regs->ss = decode_segment(ri.cpt_ss);
+	regs->ds = decode_segment(ri.cpt_ds);
+	regs->es = decode_segment(ri.cpt_es);
+	regs->fs = decode_segment(ri.cpt_fs);
+
+	tsk->thread.sp -= HOOK_RESERVE;
+	memset((void*)tsk->thread.sp, 0, HOOK_RESERVE);
+
+	return 0;
+}
+
+static int restart_thread(void *arg)
+{
+	struct thr_context *thr_ctx = arg;
+	struct cpt_context *ctx;
+	struct cpt_task_image *ti;
+	int err;
+
+	current->state = TASK_UNINTERRUPTIBLE;
+
+	ctx = thr_ctx->ctx;
+	ti = kmalloc(sizeof(*ti), GFP_KERNEL);
+	if (!ti)
+		return -ENOMEM;
+
+	err = rst_get_object(CPT_OBJ_TASK, ti, sizeof(*ti), ctx);
+	if (!err)
+		err = rst_restore_task_struct(current, ti, ctx);
+	/* Restore mm here */
+	if (!err)
+		err = rst_restore_fpustate(current, ti, ctx);
+	if (!err)
+		err = rst_restore_registers(current, ctx);
+
+	thr_ctx->error = err;
+	complete(&thr_ctx->complete);
+
+	if (!err && (ti->cpt_state & (EXIT_ZOMBIE|EXIT_DEAD))) {
+		do_exit(ti->cpt_exit_code);
+	} else {
+		__set_current_state(TASK_UNINTERRUPTIBLE);
+	}
+
+	kfree(ti);
+	schedule();
+
+	eprintk("leaked %d/%d %p\n", task_pid_nr(current), task_pid_vnr(current), current->mm);
+
+	module_put(THIS_MODULE);
+	complete_and_exit(NULL, 0);
+	return 0;
+}
+static int create_root_task(struct cpt_context *ctx,
+			    struct thr_context *thr_ctx)
+{
+	struct task_struct *tsk;
+	int pid;
+
+	thr_ctx->ctx = ctx;
+	thr_ctx->error = 0;
+	init_completion(&thr_ctx->complete);
+
+	/* We should also create container here */ 
+	pid = local_kernel_thread(restart_thread, thr_ctx,
+			CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC | 
+			CLONE_NEWUSER | CLONE_NEWPID | CLONE_NEWNET, 0);
+	if (pid < 0)
+		return pid;
+	read_lock(&tasklist_lock);
+	tsk = find_task_by_vpid(pid);
+	if (tsk)
+		get_task_struct(tsk);
+	read_unlock(&tasklist_lock);
+	if (tsk == NULL)
+		return -ESRCH;
+	thr_ctx->tsk = tsk;
+	return 0;
+}
+
+int rst_restart_process(struct cpt_context *ctx)
+{
+	struct thr_context thr_ctx_root;
+	int err;
+
+	err = create_root_task(ctx, &thr_ctx_root);
+	if (err)
+		return err;
+
+	wait_for_completion(&thr_ctx_root.complete);
+	wait_task_inactive(thr_ctx_root.tsk, 0);
+
+	return err;
+}
diff --git a/kernel/sched.c b/kernel/sched.c
index 04160d2..94a23e5 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -1970,6 +1970,7 @@ unsigned long wait_task_inactive(struct task_struct *p, long match_state)
 
 	return ncsw;
 }
+EXPORT_SYMBOL(wait_task_inactive);
 
 /***
  * kick_process - kick a running thread to enter/exit the kernel
-- 
1.5.6
