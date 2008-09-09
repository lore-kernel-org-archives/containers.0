From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [RFC v4][PATCH 3/9] x86 support for checkpoint/restart
Date: Tue, 9 Sep 2008 10:17:13 +0200
Message-ID: <20080909081713.GA18946__36182.2595740252$1220948466$gmane$org@elte.hu>
References: <1220946154-15174-1-git-send-email-orenl@cs.columbia.edu>
	<1220946154-15174-4-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1220946154-15174-4-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


* Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:

> +	/* for checkpoint in process context (from within a container)
> +	   the GS and FS registers should be saved from the hardware;
> +	   otherwise they are already sabed on the thread structure */

please use the correct comment style consistently throughout your 
patches. The correct one is like this one:

> +	/*
> +	 * for checkpoint in process context (from within a container),
> +	 * the actual syscall is taking place at this very moment; so
> +	 * we (optimistically) subtitute the future return value (0) of
> +	 * this syscall into the orig_eax, so that upon restart it will
> +	 * succeed (or it will endlessly retry checkpoint...)
> +	 */

incorrect/inconsistent ones are like these:

> +		/* normally, no need to unlazy_fpu(), since TS_USEDFPU flag
> +		 * have been cleared when task was conexted-switched out...
> +		 * except if we are in process context, in which case we do */

> +		/* restore TLS by hand: why convert to struct user_desc if
> +		 * sys_set_thread_entry() will convert it back ? */

> +			/* FIX: add sanity checks (eg. that values makes
> +			 * sense, that we don't overwrite old values, etc */

(and there's many more examples throughout the series)

> +int cr_read_cpu_debug(struct cr_hdr_cpu *hh, struct task_struct *t)
> +{
> +	/* debug regs */
> +
> +	preempt_disable();
> +
> +	if (hh->uses_debug) {
> +		set_debugreg(hh->debugreg0, 0);
> +		set_debugreg(hh->debugreg1, 1);
> +		/* ignore 4, 5 */
> +		set_debugreg(hh->debugreg2, 2);
> +		set_debugreg(hh->debugreg3, 3);
> +		set_debugreg(hh->debugreg6, 6);
> +		set_debugreg(hh->debugreg7, 7);
> +	}
> +
> +	preempt_enable();
> +
> +	return 0;
> +}

hm, the preemption disabling seems pointless here. What does it protect 
against?

> +++ b/checkpoint/ckpt_arch.h
> @@ -0,0 +1,7 @@
> +#include <linux/ckpt.h>
> +
> +int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t);
> +int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t);
> +
> +int cr_read_thread(struct cr_ctx *ctx);
> +int cr_read_cpu(struct cr_ctx *ctx);

please add 'extern' to prototypes in include files.

> @@ -15,6 +15,8 @@
>  #include <linux/ckpt.h>
>  #include <linux/ckpt_hdr.h>
>  
> +#include "ckpt_arch.h"
> +

plsdntuseannyngabbrvtsngnrcd. [1]

"checkpoint_" should be just fine in most cases.

	Ingo

[1] (please dont use annoying abbreviations in generic code)
