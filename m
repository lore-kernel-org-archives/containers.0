From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 08/10] Introduce functions to restart a process
Date: Thu, 23 Oct 2008 14:56:26 +0400
Message-ID: <200810231456.27902.major__24852.5068317123$1224759513$gmane$org@openvz.org>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-9-git-send-email-major@openvz.org>
	<20081020132536.GS15171@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081020132536.GS15171-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
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
To: devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Monday 20 October 2008 17:25 Louis Rilling wrote:
> On Sat, Oct 18, 2008 at 03:11:36AM +0400, Andrey Mirkin wrote:
> > Functions to restart process, restore its state, fpu and registers are
> > added.
>
> [...]
>
> > diff --git a/checkpoint/rst_process.c b/checkpoint/rst_process.c
> > new file mode 100644
> > index 0000000..b9f745e
> > --- /dev/null
> > +++ b/checkpoint/rst_process.c
> > @@ -0,0 +1,277 @@
> > +/*
> > + *  Copyright (C) 2008 Parallels, Inc.
> > + *
> > + *  Author: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> > + *
> > + *  This program is free software; you can redistribute it and/or
> > + *  modify it under the terms of the GNU General Public License as
> > + *  published by the Free Software Foundation, version 2 of the
> > + *  License.
> > + *
> > + */
> > +
> > +#include <linux/sched.h>
> > +#include <linux/fs.h>
> > +#include <linux/file.h>
> > +#include <linux/version.h>
> > +#include <linux/module.h>
> > +
> > +#include "checkpoint.h"
> > +#include "cpt_image.h"
> > +
> > +#define HOOK_RESERVE	256
> > +
> > +struct thr_context {
> > +	struct completion complete;
> > +	int error;
> > +	struct cpt_context *ctx;
> > +	struct task_struct *tsk;
> > +};
> > +
> > +int local_kernel_thread(int (*fn)(void *), void * arg, unsigned long
> > flags, pid_t pid) +{
> > +	pid_t ret;
> > +
> > +	if (current->fs == NULL) {
> > +		/* do_fork_pid() hates processes without fs, oopses. */
> > +		eprintk("local_kernel_thread: current->fs==NULL\n");
> > +		return -EINVAL;
> > +	}
> > +	if (!try_module_get(THIS_MODULE))
> > +		return -EBUSY;
> > +	ret = kernel_thread(fn, arg, flags);
> > +	if (ret < 0)
> > +		module_put(THIS_MODULE);
> > +	return ret;
> > +}
> > +
> > +static unsigned int decode_task_flags(unsigned int task_flags)
> > +{
> > +	unsigned int flags = 0;
> > +
> > +	if (task_flags & (1 << CPT_PF_EXITING))
> > +		flags |= PF_EXITING;
> > +	if (task_flags & (1 << CPT_PF_FORKNOEXEC))
> > +		flags |= PF_FORKNOEXEC;
> > +	if (task_flags & (1 << CPT_PF_SUPERPRIV))
> > +		flags |= PF_SUPERPRIV;
> > +	if (task_flags & (1 << CPT_PF_DUMPCORE))
> > +		flags |= PF_DUMPCORE;
> > +	if (task_flags & (1 << CPT_PF_SIGNALED))
> > +		flags |= PF_SIGNALED;
> > +
> > +	return flags;
> > +
> > +}
> > +
> > +int rst_restore_task_struct(struct task_struct *tsk, struct
> > cpt_task_image *ti, +			    struct cpt_context *ctx)
> > +{
> > +	int i;
> > +
> > +	/* Restore only saved flags, comm and tls for now */
> > +	tsk->flags = decode_task_flags(ti->cpt_flags);
> > +	clear_tsk_thread_flag(tsk, TIF_FREEZE);
> > +	memcpy(tsk->comm, ti->cpt_comm, TASK_COMM_LEN);
> > +	for (i = 0; i < GDT_ENTRY_TLS_ENTRIES; i++) {
> > +		tsk->thread.tls_array[i].a = ti->cpt_tls[i] & 0xFFFFFFFF;
> > +		tsk->thread.tls_array[i].b = ti->cpt_tls[i] >> 32;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static int rst_restore_fpustate(struct task_struct *tsk, struct
> > cpt_task_image *ti, +				struct cpt_context *ctx)
> > +{
> > +	struct cpt_obj_bits hdr;
> > +	int err;
> > +	char *buf;
> > +
> > +	clear_stopped_child_used_math(tsk);
> > +
> > +	err = rst_get_object(CPT_OBJ_BITS, &hdr, sizeof(hdr), ctx);
> > +	if (err < 0)
> > +		return err;
> > +
> > +	buf = kmalloc(hdr.cpt_size, GFP_KERNEL);
> > +	if (!buf)
> > +		return -ENOMEM;
> > +
> > +	err = ctx->read(buf, hdr.cpt_size, ctx);
> > +	if (err)
> > +		goto out;
> > +
> > +	if (hdr.cpt_content == CPT_CONTENT_X86_FPUSTATE && cpu_has_fxsr) {
> > +		memcpy(&tsk->thread.xstate, buf,
> > +				sizeof(struct i387_fxsave_struct));
> > +		if (ti->cpt_flags & CPT_PF_USED_MATH)
> > +			set_stopped_child_used_math(tsk);
> > +	}
> > +#ifndef CONFIG_X86_64
> > +	else if (hdr.cpt_content == CPT_CONTENT_X86_FPUSTATE_OLD &&
> > +			!cpu_has_fxsr) {
> > +		memcpy(&tsk->thread.xstate, buf,
> > +				sizeof(struct i387_fsave_struct));
> > +		if (ti->cpt_flags & CPT_PF_USED_MATH)
> > +			set_stopped_child_used_math(tsk);
> > +	}
> > +#endif
> > +
> > +out:
> > +	kfree(buf);
> > +	return err;
> > +}
> > +
> > +static u32 decode_segment(u32 segid)
> > +{
> > +	if (segid == CPT_SEG_ZERO)
> > +		return 0;
> > +
> > +	/* TLS descriptors */
> > +	if (segid <= CPT_SEG_TLS3)
> > +		return ((GDT_ENTRY_TLS_MIN + segid - CPT_SEG_TLS1) << 3) + 3;
> > +
> > +	/* LDT descriptor, it is just an index to LDT array */
> > +	if (segid >= CPT_SEG_LDT)
> > +		return ((segid - CPT_SEG_LDT) << 3) | 7;
> > +
> > +	/* Check for one of standard descriptors */
> > +	if (segid == CPT_SEG_USER32_DS)
> > +		return __USER_DS;
> > +	if (segid == CPT_SEG_USER32_CS)
> > +		return __USER_CS;
> > +
> > +	eprintk("Invalid segment reg %d\n", segid);
> > +	return 0;
> > +}
> > +
> > +static int rst_restore_registers(struct task_struct *tsk, struct
> > cpt_context *ctx) +{
> > +	struct cpt_x86_regs ri;
> > +	struct pt_regs *regs = task_pt_regs(tsk);
> > +	extern char i386_ret_from_resume;
> > +	int err;
> > +
> > +	err = rst_get_object(CPT_OBJ_X86_REGS, &ri, sizeof(ri), ctx);
> > +	if (err < 0)
> > +		return err;
> > +
> > +	tsk->thread.sp = (unsigned long) regs;
> > +	tsk->thread.sp0 = (unsigned long) (regs+1);
> > +	tsk->thread.ip = (unsigned long) &i386_ret_from_resume;
> > +
> > +	tsk->thread.gs = decode_segment(ri.cpt_gs);
> > +	tsk->thread.debugreg0 = ri.cpt_debugreg[0];
> > +	tsk->thread.debugreg1 = ri.cpt_debugreg[1];
> > +	tsk->thread.debugreg2 = ri.cpt_debugreg[2];
> > +	tsk->thread.debugreg3 = ri.cpt_debugreg[3];
> > +	tsk->thread.debugreg6 = ri.cpt_debugreg[6];
> > +	tsk->thread.debugreg7 = ri.cpt_debugreg[7];
> > +
> > +	regs->bx = ri.cpt_bx;
> > +	regs->cx = ri.cpt_cx;
> > +	regs->dx = ri.cpt_dx;
> > +	regs->si = ri.cpt_si;
> > +	regs->di = ri.cpt_di;
> > +	regs->bp = ri.cpt_bp;
> > +	regs->ax = ri.cpt_ax;
> > +	regs->orig_ax = ri.cpt_orig_ax;
> > +	regs->ip = ri.cpt_ip;
> > +	regs->flags = ri.cpt_flags;
> > +	regs->sp = ri.cpt_sp;
> > +
> > +	regs->cs = decode_segment(ri.cpt_cs);
> > +	regs->ss = decode_segment(ri.cpt_ss);
> > +	regs->ds = decode_segment(ri.cpt_ds);
> > +	regs->es = decode_segment(ri.cpt_es);
> > +	regs->fs = decode_segment(ri.cpt_fs);
> > +
> > +	tsk->thread.sp -= HOOK_RESERVE;
> > +	memset((void*)tsk->thread.sp, 0, HOOK_RESERVE);
> > +
> > +	return 0;
> > +}
> > +
> > +static int restart_thread(void *arg)
> > +{
> > +	struct thr_context *thr_ctx = arg;
> > +	struct cpt_context *ctx;
> > +	struct cpt_task_image *ti;
> > +	int err;
> > +
> > +	current->state = TASK_UNINTERRUPTIBLE;
> > +
> > +	ctx = thr_ctx->ctx;
> > +	ti = kmalloc(sizeof(*ti), GFP_KERNEL);
> > +	if (!ti)
> > +		return -ENOMEM;
> > +
> > +	err = rst_get_object(CPT_OBJ_TASK, ti, sizeof(*ti), ctx);
> > +	if (!err)
> > +		err = rst_restore_task_struct(current, ti, ctx);
> > +	/* Restore mm here */
> > +	if (!err)
> > +		err = rst_restore_fpustate(current, ti, ctx);
> > +	if (!err)
> > +		err = rst_restore_registers(current, ctx);
> > +
> > +	thr_ctx->error = err;
> > +	complete(&thr_ctx->complete);
> > +
> > +	if (!err && (ti->cpt_state & (EXIT_ZOMBIE|EXIT_DEAD))) {
> > +		do_exit(ti->cpt_exit_code);
> > +	} else {
> > +		__set_current_state(TASK_UNINTERRUPTIBLE);
> > +	}
> > +
> > +	kfree(ti);
> > +	schedule();
> > +
> > +	eprintk("leaked %d/%d %p\n", task_pid_nr(current),
> > task_pid_vnr(current), current->mm); +
> > +	module_put(THIS_MODULE);
>
> I'm sorry, I still do not understand what you are doing with this
> self-module pinning stuff. AFAICS, we should not get here unless there is a
> bug. So the checkpoint module ref count is never decreased, right?
>
> Could you detail what is this self-module pinning for? As I already told
> you, this looks like a bogus solution to avoid unloading the checkpoint
> module during restart.

Actually right now module ref count increase/decrease is not needed.
But in some cases restore work should be done only after unfreezing the 
process. So, in this case we should grab ref count during process creation 
and put it after this special work is done.
I will rework this place and send it in next version to make it more clear how 
it will be used in future.

Andrey
