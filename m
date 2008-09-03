From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 8/9] Introduce functions to restart a process
Date: Wed, 3 Sep 2008 16:32:48 +0200
Message-ID: <20080903143248.GU14473__8494.40092356435$1220452676$gmane$org@hawkmoon.kerlabs.com>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<1220439476-16465-2-git-send-email-major@openvz.org>
	<1220439476-16465-3-git-send-email-major@openvz.org>
	<1220439476-16465-4-git-send-email-major@openvz.org>
	<1220439476-16465-5-git-send-email-major@openvz.org>
	<1220439476-16465-6-git-send-email-major@openvz.org>
	<1220439476-16465-7-git-send-email-major@openvz.org>
	<1220439476-16465-8-git-send-email-major@openvz.org>
	<1220439476-16465-9-git-send-email-major@openvz.org>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5069650025759096731=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1220439476-16465-9-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============5069650025759096731==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-24101-1220452235-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-24101-1220452235-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 03, 2008 at 02:57:55PM +0400, Andrey Mirkin wrote:
> Functions to restart process, restore its state, fpu and registers are ad=
ded.
>=20
> Signed-off-by: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> ---
>  arch/x86/kernel/entry_32.S   |   21 +++
>  arch/x86/kernel/process_32.c |    3 +
>  cpt/Makefile                 |    3 +-
>  cpt/cpt.h                    |    2 +
>  cpt/restart.c                |    2 +-
>  cpt/rst_process.c            |  277 ++++++++++++++++++++++++++++++++++++=
++++++
>  kernel/sched.c               |    1 +
>  7 files changed, 307 insertions(+), 2 deletions(-)
>  create mode 100644 cpt/rst_process.c
>=20
> diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
> index 109792b..a4848a3 100644
> --- a/arch/x86/kernel/entry_32.S
> +++ b/arch/x86/kernel/entry_32.S
> @@ -225,6 +225,7 @@ ENTRY(ret_from_fork)
>  	GET_THREAD_INFO(%ebp)
>  	popl %eax
>  	CFI_ADJUST_CFA_OFFSET -4
> +ret_from_fork_tail:
>  	pushl $0x0202			# Reset kernel eflags
>  	CFI_ADJUST_CFA_OFFSET 4
>  	popfl
> @@ -233,6 +234,26 @@ ENTRY(ret_from_fork)
>  	CFI_ENDPROC
>  END(ret_from_fork)
> =20
> +ENTRY(i386_ret_from_resume)
> +	CFI_STARTPROC
> +	pushl %eax
> +	CFI_ADJUST_CFA_OFFSET 4
> +	call schedule_tail
> +	GET_THREAD_INFO(%ebp)
> +	popl %eax
> +	CFI_ADJUST_CFA_OFFSET -4
> +	movl (%esp), %eax
> +	testl %eax, %eax
> +	jz    1f
> +	pushl %esp
> +	call  *%eax
> +	addl  $4, %esp
> +1:
> +	addl  $256, %esp

This space reserved for hooks deserves some explanations IMO. I partly know=
 the
reasons, since I have looked at OpenVZ code with you, but I'm sure that alm=
ost
nobody knows...

Btw, the constant HOOK_RESERVE should be defined in a common place for asse=
mbly
and C as well.

> +	jmp   ret_from_fork_tail
> +	CFI_ENDPROC
> +END(i386_ret_from_resume)
> +
>  /*
>   * Return to user mode is not as complex as all this looks,
>   * but we want the default path for a system call return to

[...]

> diff --git a/cpt/rst_process.c b/cpt/rst_process.c
> new file mode 100644
> index 0000000..6d47f3c
> --- /dev/null
> +++ b/cpt/rst_process.c
> @@ -0,0 +1,277 @@
> +/*
> + *  Copyright (C) 2008 Parallels, Inc.
> + *
> + *  Author: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> + *
> + *  This program is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU General Public License as
> + *  published by the Free Software Foundation, version 2 of the
> + *  License.
> + *
> + */
> +
> +#include <linux/sched.h>
> +#include <linux/fs.h>
> +#include <linux/file.h>
> +#include <linux/version.h>
> +#include <linux/module.h>
> +
> +#include "cpt.h"
> +#include "cpt_image.h"
> +
> +#define HOOK_RESERVE	256
> +
> +struct thr_context {
> +	struct completion complete;
> +	int error;
> +	struct cpt_context *ctx;
> +	struct task_struct *tsk;
> +};
> +
> +int local_kernel_thread(int (*fn)(void *), void * arg, unsigned long fla=
gs, pid_t pid)
> +{
> +	pid_t ret;
> +
> +	if (current->fs =3D=3D NULL) {
> +		/* do_fork_pid() hates processes without fs, oopses. */
> +		eprintk("local_kernel_thread: current->fs=3D=3DNULL\n");
> +		return -EINVAL;
> +	}
> +	if (!try_module_get(THIS_MODULE))
> +		return -EBUSY;

Doing try_module_get(THIS_MODULE) and checking its result is almost always =
the
symptom of a BUG. I explain myself:
If it is possible that THIS_MODULE is currently unloading, its memory
(especially its text section) can be freed at any time during the call to
local_kernel_thread(), which leads to a beautiful OOPS.

So, either the code is buggy, or this check is useless. I agree however tha=
t the
module ref count must be incremented, since the new thread will run code fr=
om
it.

> +	ret =3D kernel_thread(fn, arg, flags);
> +	if (ret < 0)
> +		module_put(THIS_MODULE);
> +	return ret;
> +}
> +
> +static unsigned int decode_task_flags(unsigned int task_flags)
> +{
> +	unsigned int flags =3D 0;
> +
> +	if (task_flags & (1 << CPT_PF_EXITING))
> +		flags |=3D PF_EXITING;
> +	if (task_flags & (1 << CPT_PF_FORKNOEXEC))
> +		flags |=3D PF_FORKNOEXEC;
> +	if (task_flags & (1 << CPT_PF_SUPERPRIV))
> +		flags |=3D PF_SUPERPRIV;
> +	if (task_flags & (1 << CPT_PF_DUMPCORE))
> +		flags |=3D PF_DUMPCORE;
> +	if (task_flags & (1 << CPT_PF_SIGNALED))
> +		flags |=3D PF_SIGNALED;
> +=09
> +	return flags;
> +	=09
> +}
> +
> +int rst_restore_task_struct(struct task_struct *tsk, struct cpt_task_ima=
ge *ti,
> +			    struct cpt_context *ctx)
> +{
> +	int i;
> +
> +	/* Restore only saved flags, comm and tls for now */
> +	tsk->flags =3D decode_task_flags(ti->cpt_flags);
> +	clear_tsk_thread_flag(tsk, TIF_FREEZE);
> +	memcpy(tsk->comm, ti->cpt_comm, TASK_COMM_LEN);
> +	for (i =3D 0; i < GDT_ENTRY_TLS_ENTRIES; i++) {
> +		tsk->thread.tls_array[i].a =3D ti->cpt_tls[i] & 0xFFFFFFFF;
> +		tsk->thread.tls_array[i].b =3D ti->cpt_tls[i] >> 32;
> +	}
> +
> +	return 0;
> +}
> +
> +static int rst_restore_fpustate(struct task_struct *tsk, struct cpt_task=
_image *ti,
> +				struct cpt_context *ctx)
> +{
> +	struct cpt_obj_bits hdr;
> +	int err;
> +	char *buf;
> +
> +	clear_stopped_child_used_math(tsk);
> +
> +	err =3D rst_get_object(CPT_OBJ_BITS, &hdr, sizeof(hdr), ctx);
> +	if (err < 0)
> +		return err;
> +
> +	buf =3D kmalloc(hdr.cpt_size, GFP_KERNEL);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	err =3D ctx->read(buf, hdr.cpt_size, ctx);
> +	if (err)
> +		goto out;
> +
> +	if (hdr.cpt_content =3D=3D CPT_CONTENT_X86_FPUSTATE && cpu_has_fxsr) {
> +		memcpy(&tsk->thread.xstate, buf,
> +				sizeof(struct i387_fxsave_struct));
> +		if (ti->cpt_flags & CPT_PF_USED_MATH)
> +			set_stopped_child_used_math(tsk);
> +	}
> +#ifndef CONFIG_X86_64
> +	else if (hdr.cpt_content =3D=3D CPT_CONTENT_X86_FPUSTATE_OLD &&
> +			!cpu_has_fxsr) {	=09
> +		memcpy(&tsk->thread.xstate, buf,
> +				sizeof(struct i387_fsave_struct));
> +		if (ti->cpt_flags & CPT_PF_USED_MATH)
> +			set_stopped_child_used_math(tsk);
> +	}
> +#endif
> +
> +out:
> +	kfree(buf);
> +	return err;
> +}
> +
> +static u32 decode_segment(u32 segid)
> +{
> +	if (segid =3D=3D CPT_SEG_ZERO)
> +		return 0;
> +
> +	/* TLS descriptors */
> +	if (segid <=3D CPT_SEG_TLS3)
> +		return ((GDT_ENTRY_TLS_MIN + segid - CPT_SEG_TLS1) << 3) + 3;
> +
> +	/* LDT descriptor, it is just an index to LDT array */
> +	if (segid >=3D CPT_SEG_LDT)
> +		return ((segid - CPT_SEG_LDT) << 3) | 7;
> +
> +	/* Check for one of standard descriptors */
> +	if (segid =3D=3D CPT_SEG_USER32_DS)
> +		return __USER_DS;
> +	if (segid =3D=3D CPT_SEG_USER32_CS)
> +		return __USER_CS;
> +
> +	eprintk("Invalid segment reg %d\n", segid);
> +	return 0;
> +}
> +
> +static int rst_restore_registers(struct task_struct *tsk, struct cpt_con=
text *ctx)
> +{
> +	struct cpt_x86_regs ri;
> +	struct pt_regs *regs =3D task_pt_regs(tsk);
> +	extern char i386_ret_from_resume;
> +	int err;
> +
> +	err =3D rst_get_object(CPT_OBJ_X86_REGS, &ri, sizeof(ri), ctx);
> +	if (err < 0)
> +		return err;
> +
> +	tsk->thread.sp =3D (unsigned long) regs;
> +	tsk->thread.sp0 =3D (unsigned long) (regs+1);
> +	tsk->thread.ip =3D (unsigned long) &i386_ret_from_resume;
> +
> +	tsk->thread.gs =3D decode_segment(ri.cpt_gs);
> +	tsk->thread.debugreg0 =3D ri.cpt_debugreg[0];
> +	tsk->thread.debugreg1 =3D ri.cpt_debugreg[1];
> +	tsk->thread.debugreg2 =3D ri.cpt_debugreg[2];
> +	tsk->thread.debugreg3 =3D ri.cpt_debugreg[3];
> +	tsk->thread.debugreg6 =3D ri.cpt_debugreg[6];
> +	tsk->thread.debugreg7 =3D ri.cpt_debugreg[7];
> +
> +	regs->bx =3D ri.cpt_bx;
> +	regs->cx =3D ri.cpt_cx;
> +	regs->dx =3D ri.cpt_dx;
> +	regs->si =3D ri.cpt_si;
> +	regs->di =3D ri.cpt_di;
> +	regs->bp =3D ri.cpt_bp;
> +	regs->ax =3D ri.cpt_ax;
> +	regs->orig_ax =3D ri.cpt_orig_ax;
> +	regs->ip =3D ri.cpt_ip;
> +	regs->flags =3D ri.cpt_flags;
> +	regs->sp =3D ri.cpt_sp;
> +
> +	regs->cs =3D decode_segment(ri.cpt_cs);
> +	regs->ss =3D decode_segment(ri.cpt_ss);
> +	regs->ds =3D decode_segment(ri.cpt_ds);
> +	regs->es =3D decode_segment(ri.cpt_es);
> +	regs->fs =3D decode_segment(ri.cpt_fs);
> +
> +	tsk->thread.sp -=3D HOOK_RESERVE;
> +	memset((void*)tsk->thread.sp, 0, HOOK_RESERVE);
> +
> +	return 0;
> +}
> +
> +static int restart_thread(void *arg)
> +{
> +	struct thr_context *thr_ctx =3D arg;
> +	struct cpt_context *ctx;
> +	struct cpt_task_image *ti;
> +	int err;
> +
> +	current->state =3D TASK_UNINTERRUPTIBLE;
> +
> +	ctx =3D thr_ctx->ctx;
> +	ti =3D kmalloc(sizeof(*ti), GFP_KERNEL);
> +	if (!ti)
> +		return -ENOMEM;
> +
> +	err =3D rst_get_object(CPT_OBJ_TASK, ti, sizeof(*ti), ctx);
> +	if (!err)
> +		err =3D rst_restore_task_struct(current, ti, ctx);
> +	/* Restore mm here */
> +	if (!err)
> +		err =3D rst_restore_fpustate(current, ti, ctx);
> +	if (!err)
> +		err =3D rst_restore_registers(current, ctx);
> +
> +	thr_ctx->error =3D err;
> +	complete(&thr_ctx->complete);
> +
> +	if (!err && (ti->cpt_state & (EXIT_ZOMBIE|EXIT_DEAD))) {
> +		do_exit(ti->cpt_exit_code);
> +	} else {
> +		__set_current_state(TASK_UNINTERRUPTIBLE);
> +	}
> +
> +	kfree(ti);
> +	schedule();
> +
> +	eprintk("leaked %d/%d %p\n", task_pid_nr(current), task_pid_vnr(current=
), current->mm);
> +
> +	module_put(THIS_MODULE);

Where is the module ref count dropped in case of success?

> +	complete_and_exit(NULL, 0);
> +	return 0;
> +}
> +static int create_root_task(struct cpt_context *ctx,
> +			    struct thr_context *thr_ctx)
> +{
> +	struct task_struct *tsk;
> +	int pid;
> +
> +	thr_ctx->ctx =3D ctx;
> +	thr_ctx->error =3D 0;
> +	init_completion(&thr_ctx->complete);
> +
> +	/* We should also create container here */=20
> +	pid =3D local_kernel_thread(restart_thread, thr_ctx,
> +			CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |=20
> +			CLONE_NEWUSER | CLONE_NEWPID | CLONE_NEWNET, 0);
> +	if (pid < 0)
> +		return pid;
> +	read_lock(&tasklist_lock);
> +	tsk =3D find_task_by_vpid(pid);
> +	if (tsk)
> +		get_task_struct(tsk);
> +	read_unlock(&tasklist_lock);
> +	if (tsk =3D=3D NULL)
> +		return -ESRCH;
> +	thr_ctx->tsk =3D tsk;
> +	return 0;
> +}
> +
> +int rst_restart_process(struct cpt_context *ctx)
> +{
> +	struct thr_context thr_ctx_root;
> +	int err;
> +
> +	err =3D create_root_task(ctx, &thr_ctx_root);
> +	if (err)
> +		return err;
> +
> +	wait_for_completion(&thr_ctx_root.complete);
> +	wait_task_inactive(thr_ctx_root.tsk, 0);

I don't see the point of this two-steps completion. Could you explain?

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-24101-1220452235-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIvqAQVKcRuvQ9Q1QRAjZoAKCYJ2PheaasiqN1xifJWs21k0pPmgCgwd+D
9qOE346PimWKuoWDoKi+dnw=
=VuG+
-----END PGP SIGNATURE-----

--=_bohort-24101-1220452235-0001-2--

--===============5069650025759096731==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============5069650025759096731==--
