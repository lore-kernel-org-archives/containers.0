From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 05/10] Introduce function to dump process
Date: Mon, 20 Oct 2008 13:02:26 +0200
Message-ID: <20081020110226.GP15171__32598.6584219665$1224516611$gmane$org@hawkmoon.kerlabs.com>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-2-git-send-email-major@openvz.org>
	<1224285098-573-3-git-send-email-major@openvz.org>
	<1224285098-573-4-git-send-email-major@openvz.org>
	<1224285098-573-5-git-send-email-major@openvz.org>
	<1224285098-573-6-git-send-email-major@openvz.org>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7422891518582050718=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224285098-573-6-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============7422891518582050718==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-18226-1224500403-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-18226-1224500403-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Sat, Oct 18, 2008 at 03:11:33AM +0400, Andrey Mirkin wrote:
> Functions to dump task struct, fpu state and registers are added.
> All IDs are saved from the POV of process (container) namespace.

Just a couple of little comments, in case this series should keep on living.

[...]

> diff --git a/checkpoint/cpt_process.c b/checkpoint/cpt_process.c
> new file mode 100644
> index 0000000..58f608d
> --- /dev/null
> +++ b/checkpoint/cpt_process.c
> @@ -0,0 +1,236 @@
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
> +#include <linux/nsproxy.h>
> +
> +#include "checkpoint.h"
> +#include "cpt_image.h"
> +
> +static unsigned int encode_task_flags(unsigned int task_flags)
> +{
> +	unsigned int flags =3D 0;
> +
> +	if (task_flags & PF_EXITING)
> +		flags |=3D (1 << CPT_PF_EXITING);
> +	if (task_flags & PF_FORKNOEXEC)
> +		flags |=3D (1 << CPT_PF_FORKNOEXEC);
> +	if (task_flags & PF_SUPERPRIV)
> +		flags |=3D (1 << CPT_PF_SUPERPRIV);
> +	if (task_flags & PF_DUMPCORE)
> +		flags |=3D (1 << CPT_PF_DUMPCORE);
> +	if (task_flags & PF_SIGNALED)
> +		flags |=3D (1 << CPT_PF_SIGNALED);
> +	if (task_flags & PF_USED_MATH)
> +		flags |=3D (1 << CPT_PF_USED_MATH);
> +=09
> +	return flags;
> +	=09
> +}
> +
> +int cpt_dump_task_struct(struct task_struct *tsk, struct cpt_context *ct=
x)
> +{
> +	struct cpt_task_image *t;
> +	int i;
> +	int err;
> +
> +	t =3D kzalloc(sizeof(*t), GFP_KERNEL);
> +	if (!t)
> +		return -ENOMEM;
> +
> +	t->cpt_len =3D sizeof(*t);
> +	t->cpt_type =3D CPT_OBJ_TASK;
> +	t->cpt_hdrlen =3D sizeof(*t);
> +	t->cpt_content =3D CPT_CONTENT_ARRAY;
> +
> +	t->cpt_state =3D tsk->state;
> +	t->cpt_flags =3D encode_task_flags(tsk->flags);
> +	t->cpt_exit_code =3D tsk->exit_code;
> +	t->cpt_exit_signal =3D tsk->exit_signal;
> +	t->cpt_pdeath_signal =3D tsk->pdeath_signal;
> +	t->cpt_pid =3D task_pid_nr_ns(tsk, ctx->nsproxy->pid_ns);
> +	t->cpt_tgid =3D task_tgid_nr_ns(tsk, ctx->nsproxy->pid_ns);
> +	t->cpt_ppid =3D tsk->parent ?
> +		task_pid_nr_ns(tsk->parent, ctx->nsproxy->pid_ns) : 0;
> +	t->cpt_rppid =3D tsk->real_parent ?
> +		task_pid_nr_ns(tsk->real_parent, ctx->nsproxy->pid_ns) : 0;
> +	t->cpt_pgrp =3D task_pgrp_nr_ns(tsk, ctx->nsproxy->pid_ns);
> +	t->cpt_session =3D task_session_nr_ns(tsk, ctx->nsproxy->pid_ns);
> +	t->cpt_old_pgrp =3D 0;
> +	if (tsk->signal->tty_old_pgrp)
> +		t->cpt_old_pgrp =3D pid_vnr(tsk->signal->tty_old_pgrp);
> +	t->cpt_leader =3D tsk->group_leader ? task_pid_vnr(tsk->group_leader) :=
 0;

Why pid_vnr() here, and task_*_nr_ns() above? According to the introducing
comment, I'd expect something like pid_nr_ns(tsk->signal->tty_old_pgrp,
tsk->nsproxy->pid_ns), and the same for tsk->group_leader.

IIUC, pid_vnr() is correct only if ctx->nsproxy->pid_ns =3D=3D tsk->nsproxy=
->pid_ns
=3D=3D current->nsproxy->pid_ns, and I expect current to live in a differen=
t pid_ns.

Comments?

> +	t->cpt_utime =3D tsk->utime;
> +	t->cpt_stime =3D tsk->stime;
> +	t->cpt_utimescaled =3D tsk->utimescaled;
> +	t->cpt_stimescaled =3D tsk->stimescaled;
> +	t->cpt_gtime =3D tsk->gtime;
> +	t->cpt_prev_utime =3D tsk->prev_utime;
> +	t->cpt_prev_stime =3D tsk->prev_stime;
> +	t->cpt_nvcsw =3D tsk->nvcsw;
> +	t->cpt_nivcsw =3D tsk->nivcsw;
> +	t->cpt_start_time =3D cpt_timespec_export(&tsk->start_time);
> +	t->cpt_real_start_time =3D cpt_timespec_export(&tsk->real_start_time);
> +	t->cpt_min_flt =3D tsk->min_flt;
> +	t->cpt_maj_flt =3D tsk->maj_flt;
> +	memcpy(t->cpt_comm, tsk->comm, TASK_COMM_LEN);
> +	for (i =3D 0; i < GDT_ENTRY_TLS_ENTRIES; i++) {
> +		t->cpt_tls[i] =3D (((u64)tsk->thread.tls_array[i].b) << 32) +
> +			tsk->thread.tls_array[i].a;
> +	}
> +	/* TODO: encode thread flags and status like task flags */
> +	t->cpt_thrflags =3D task_thread_info(tsk)->flags & ~(1<<TIF_FREEZE);
> +	t->cpt_thrstatus =3D task_thread_info(tsk)->status;
> +	t->cpt_user =3D tsk->user->uid;
> +	t->cpt_uid =3D tsk->uid;
> +	t->cpt_euid =3D tsk->euid;
> +	t->cpt_suid =3D tsk->suid;
> +	t->cpt_fsuid =3D tsk->fsuid;
> +	t->cpt_gid =3D tsk->gid;
> +	t->cpt_egid =3D tsk->egid;
> +	t->cpt_sgid =3D tsk->sgid;
> +	t->cpt_fsgid =3D tsk->fsgid;
> +
> +	err =3D ctx->write(t, sizeof(*t), ctx);
> +
> +	kfree(t);
> +	return err;
> +}
> +
> +static int cpt_dump_fpustate(struct task_struct *tsk, struct cpt_context=
 *ctx)
> +{
> +	struct cpt_obj_bits hdr;
> +	int err;
> +	int content;
> +	unsigned long size;
> +
> +	content =3D CPT_CONTENT_X86_FPUSTATE;
> +	size =3D sizeof(struct i387_fxsave_struct);
> +#ifndef CONFIG_X86_64
> +	if (!cpu_has_fxsr) {
> +		size =3D sizeof(struct i387_fsave_struct);
> +		content =3D CPT_CONTENT_X86_FPUSTATE_OLD;
> +	}
> +#endif
> +
> +	hdr.cpt_len =3D sizeof(hdr) + size;
> +	hdr.cpt_type =3D CPT_OBJ_BITS;
> +	hdr.cpt_hdrlen =3D sizeof(hdr);
> +	hdr.cpt_content =3D content;
> +	hdr.cpt_size =3D size;
> +	err =3D ctx->write(&hdr, sizeof(hdr), ctx);
> +	if (!err)
> +		ctx->write(tsk->thread.xstate, size, ctx);

Should check the error code of the line above, right?

> +	return err;
> +}
> +
> +static u32 encode_segment(u32 segreg)
> +{
> +	segreg &=3D 0xFFFF;
> +
> +	if (segreg =3D=3D 0)
> +		return CPT_SEG_ZERO;
> +	if ((segreg & 3) !=3D 3) {
> +		eprintk("Invalid RPL of a segment reg %x\n", segreg);
> +		return CPT_SEG_ZERO;
> +	}
> +
> +	/* LDT descriptor, it is just an index to LDT array */
> +	if (segreg & 4)
> +		return CPT_SEG_LDT + (segreg >> 3);
> +
> +	/* TLS descriptor. */
> +	if ((segreg >> 3) >=3D GDT_ENTRY_TLS_MIN &&
> +			(segreg >> 3) <=3D GDT_ENTRY_TLS_MAX)
> +		return CPT_SEG_TLS1 + ((segreg>>3) - GDT_ENTRY_TLS_MIN);
> +
> +	/* One of standard desriptors */
> +#ifdef CONFIG_X86_64
> +	if (segreg =3D=3D __USER32_DS)
> +		return CPT_SEG_USER32_DS;
> +	if (segreg =3D=3D __USER32_CS)
> +		return CPT_SEG_USER32_CS;
> +	if (segreg =3D=3D __USER_DS)
> +		return CPT_SEG_USER64_DS;
> +	if (segreg =3D=3D __USER_CS)
> +		return CPT_SEG_USER64_CS;
> +#else
> +	if (segreg =3D=3D __USER_DS)
> +		return CPT_SEG_USER32_DS;
> +	if (segreg =3D=3D __USER_CS)
> +		return CPT_SEG_USER32_CS;
> +#endif
> +	eprintk("Invalid segment reg %x\n", segreg);
> +	return CPT_SEG_ZERO;
> +}
> +
> +static int cpt_dump_registers(struct task_struct *tsk, struct cpt_contex=
t *ctx)
> +{
> +	struct cpt_x86_regs ri;
> +	struct pt_regs *pt_regs;
> +
> +	ri.cpt_len =3D sizeof(ri);
> +	ri.cpt_type =3D CPT_OBJ_X86_REGS;
> +	ri.cpt_hdrlen =3D sizeof(ri);
> +	ri.cpt_content =3D CPT_CONTENT_VOID;
> +
> +	ri.cpt_debugreg[0] =3D tsk->thread.debugreg0;
> +	ri.cpt_debugreg[1] =3D tsk->thread.debugreg1;
> +	ri.cpt_debugreg[2] =3D tsk->thread.debugreg2;
> +	ri.cpt_debugreg[3] =3D tsk->thread.debugreg3;
> +	ri.cpt_debugreg[4] =3D 0;
> +	ri.cpt_debugreg[5] =3D 0;
> +	ri.cpt_debugreg[6] =3D tsk->thread.debugreg6;
> +	ri.cpt_debugreg[7] =3D tsk->thread.debugreg7;
> +
> +	pt_regs =3D task_pt_regs(tsk);
> +
> +	ri.cpt_fs =3D encode_segment(pt_regs->fs);
> +	ri.cpt_gs =3D encode_segment(tsk->thread.gs);
> +
> +	ri.cpt_bx =3D pt_regs->bx;
> +	ri.cpt_cx =3D pt_regs->cx;
> +	ri.cpt_dx =3D pt_regs->dx;
> +	ri.cpt_si =3D pt_regs->si;
> +	ri.cpt_di =3D pt_regs->di;
> +	ri.cpt_bp =3D pt_regs->bp;
> +	ri.cpt_ax =3D pt_regs->ax;
> +	ri.cpt_ds =3D encode_segment(pt_regs->ds);
> +	ri.cpt_es =3D encode_segment(pt_regs->es);
> +	ri.cpt_orig_ax =3D pt_regs->orig_ax;
> +	ri.cpt_ip =3D pt_regs->ip;
> +	ri.cpt_cs =3D encode_segment(pt_regs->cs);
> +	ri.cpt_flags =3D pt_regs->flags;
> +	ri.cpt_sp =3D pt_regs->sp;
> +	ri.cpt_ss =3D encode_segment(pt_regs->ss);
> +=09
> +	return ctx->write(&ri, sizeof(ri), ctx);
> +}
> +
> +int cpt_dump_task(struct task_struct *tsk, struct cpt_context *ctx)
> +{
> +	int err;
> +
> +	err =3D cpt_dump_task_struct(tsk, ctx);
> +
> +	/* Dump task mm */
> +
> +	if (!err)
> +		cpt_dump_fpustate(tsk, ctx);

error checking...

> +	if (!err)
> +		cpt_dump_registers(tsk, ctx);

error checking...

> +
> +	return err;
> +}
> --=20
> 1.5.6
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-18226-1224500403-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFI/GVCVKcRuvQ9Q1QRAj0HAKCPboBYRdTcoqVGaQpNm2CwyybUAACgzXm0
c4x6rxEAKKV9UpKc6PcVkV8=
=0bvq
-----END PGP SIGNATURE-----

--=_bohort-18226-1224500403-0001-2--

--===============7422891518582050718==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============7422891518582050718==--
