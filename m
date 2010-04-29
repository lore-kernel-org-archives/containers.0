From: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [C/R ARM v2][PATCH 1/3] ARM: Rudimentary syscall interfaces
Date: Wed, 28 Apr 2010 17:08:08 -0700 (PDT)
Message-ID: <20100429000808.CFFBD7154__10909.9494330168$1272499820$gmane$org@magilla.sf.frob.com>
References: <1272318223-28438-1-git-send-email-christofferdall@christofferdall.dk>
	<1272318223-28438-2-git-send-email-christofferdall@christofferdall.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Christoffer Dall's message of  Monday,
	26 April 2010 17:43:41 -0400
	<1272318223-28438-2-git-send-email-christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

> + * syscalls.h - Linux syscall interfaces for ARM

s/syscalls/syscall/

> +static inline int get_swi_instruction(struct task_struct *task,
> +				      struct pt_regs *regs,
> +				      unsigned long *instr)
> +{

Why doesn't this just use access_process_vm?

> +/*
> + * This function essentially duplicates the logic from vector_swi in
> + * arch/arm/kernel/entry-common.S. However, that code is in the
> + * critical path for system calls and is hard to factor out without
> + * compromising performance. 
> + */

No clue about the ARM details, not reviewing that.  I think this is too big
to be an inline and should be in some arch/arm/kernel/*.c place instead.
Of course, if (config_aeabi && !config_oabi) is true at compile time, it's
not large at all.  So perhaps just move the compelx cases to a function
and leave the "Pure EABI" fork in the inline.


Thanks,
Roland
