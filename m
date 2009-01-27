From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [PATCH] c/r: define s390-specific checkpoint-restart code
Date: Tue, 27 Jan 2009 12:08:47 -0500
Message-ID: <497F3F9F.2000803@cs.columbia.edu>
References: <20090116173633.GB8477@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758035AbZA0RPj@vger.kernel.org>
In-Reply-To: <20090116173633.GB8477@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Mike Waychison <mikew@google.com>, Andrew Morton <akpm@osdl.org>, linux-s390@vger.kernel.org, linux390@de.ibm.com
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Implement the s390 arch-specific checkpoint/restart helpers.  This

Thanks for the patch.

I will assume that the s390 specifics are correct...

> is on top of Oren Laadan's c/r code (which so far was x86_32-only)
> submitted here: http://lkml.org/lkml/2008/12/29/38, plus two more
> patches by Nathan Lynch to fix some 64-bit issues (see
> https://lists.linux-foundation.org/pipermail/containers/2009-January/015313.html
> and
> https://lists.linux-foundation.org/pipermail/containers/2009-January/015314.html
> ).

ckpt-v13 already has these two fixed.

> 
> With these, I am able to checkpoint and restart simple programs as per
> Oren's patch intro.  While on x86 I never had to freeze a single task
> to checkpoint it, on s390 I do need to.  That is a prereq for consistent
> snapshots (esp with multiple processes) anyway so I don't see that as
> a problem.
> 
> Oren, should we be putting a byte at the front of the format to
> specify the architecture?

If we add a field to 'struct cr_hdr_head', then we'll need arch-dependent
code in a non-arch dependent source, to ensure that no two architectures
choose the same value as an identifier.

Can we not use the 'machine' string fiels in 'struct cr_hdr_head' - and
then additional classification can take place in cr_read/write_head_arch() ?

> 
> Changelog:
> 	Jan 15: Stopped restoring ksp and vdso_base

[...]

> +/*
> + * Notes
> + * NUM_GPRS defined in <asm/ptrace.h> to be 16
> + * NUM_FPRS defined in <asm/ptrace.h> to be 16
> + * NUM_APRS defined in <asm/ptrace.h> to be 16
> + */
> +struct cr_hdr_cpu {
> +	psw_t psw;
> +	unsigned long args[1];
> +	s390_fp_regs fp_regs;
> +	unsigned long gprs[NUM_GPRS];
> +	unsigned long orig_gpr2;
> +	unsigned short svcnr;
> +	unsigned short ilc;
> +	unsigned int acrs[NUM_ACRS];
> +	unsigned long ksp;
> +	unsigned long prot_addr;
> +	unsigned int trap_no;
> +	per_struct per_info;
> +	unsigned long ieee_instruction_pointer;
> +	unsigned long pfault_wait;
> +};

This header file will be included from user space, e.g. by a utility to
convert image format between kernel versions. For that, and for 32/64
bit compatibility (while shouldn't be an issue with s390...), please
substitue:   '__u64' for 'unsigned long', etc, and avoid including an
entire structure as is.

> +
> +#endif /* __ASM_S390_CKPT_HDR__H */

[...]

>   */
>  
> +#define DEBUG 1
> +
>  #include <linux/version.h>
>  #include <linux/sched.h>
>  #include <linux/ptrace.h>
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index 6b4cd75..f65a63e 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -8,6 +8,8 @@
>   *  distribution for more details.
>   */
>  
> +#define DEBUG 1
> +
>  #include <linux/version.h>
>  #include <linux/sched.h>
>  #include <linux/wait.h>
> 

Probably unrelated ?

Thanks,

Oren.
