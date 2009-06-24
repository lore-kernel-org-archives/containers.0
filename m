From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] C/R: simplify checkpoint debugging
Date: Wed, 24 Jun 2009 12:49:43 -0400
Message-ID: <4A425927.6080109@cs.columbia.edu>
References: <m33a9st5yk.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m33a9st5yk.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


Nathan Lynch wrote:
> To enable printing of checkpoint/restart messages, one must enable
> CHECKPOINT_DEBUG and boot with ckpt_debug= ... something I haven't
> been able to figure out.  Further complicating matters is that if
> DYNAMIC_DEBUG is enabled, you still won't get any debugging output
> unless you manually enable debug output for all the functions you're
> interested in via <debugfs>/dynamic_debug/control.  At this stage of
> development most users will want all C/R messages either on or off and
> don't need a fancy filtering mechanism.

Thanks for bringing this up. In part it has been annoying to me too.

I'm all for replacing pr_debug(...) with printk(KERN_DEBUG ...).
Done.

I prefer to keep the selection of debug verbosity in - it becomes
useful when debugging a checkpoint or restart that produce plenty
of output. It keeps the noise (and time) to an acceptable level.

So I did also change the default (CKPT_DDEFAULT) to select all
debug flags. So the normal behavior is as intended in this patch.

Given the enthusiastic responses to the proposed changes, do you
still wish to remove the option to select verbosity level ?

Oren.


> Change ckpt_debug to print messages if CHECKPOINT_DEBUG=y.  Otherwise
> it will emit nothing.  Remove ckpt_debug= setup code.  Reword
> CHECKPOINT_DEBUG config help text appropriately.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  checkpoint/sys.c           |   22 ----------------------
>  include/linux/checkpoint.h |    4 +---
>  lib/Kconfig.debug          |    9 +++------
>  3 files changed, 4 insertions(+), 31 deletions(-)
> 
> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index 38a5299..3c0056f 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -338,25 +338,3 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
>  	ckpt_ctx_put(ctx);
>  	return ret;
>  }
> -
> -
> -/* 'ckpt_debug_level' controls the verbosity level of c/r code */
> -#ifdef CONFIG_CHECKPOINT_DEBUG
> -
> -/* FIX: allow to change during runtime */
> -unsigned long __read_mostly ckpt_debug_level = CKPT_DDEFAULT;
> -
> -static __init int ckpt_debug_setup(char *s)
> -{
> -	long val, ret;
> -
> -	ret = strict_strtoul(s, 10, &val);
> -	if (ret < 0)
> -		return ret;
> -	ckpt_debug_level = val;
> -	return 0;
> -}
> -
> -__setup("ckpt_debug=", ckpt_debug_setup);
> -
> -#endif /* CONFIG_CHECKPOINT_DEBUG */
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index b92bf95..f1aad34 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -264,13 +264,11 @@ extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
>  #endif
>  
>  #ifdef CONFIG_CHECKPOINT_DEBUG
> -extern unsigned long ckpt_debug_level;
>  
>  /* use this to select a specific debug level */
>  #define _ckpt_debug(level, fmt, args...)			\
>  	do {						\
> -		if (ckpt_debug_level & (level))		\
> -			pr_debug("[%d:c/r:%s] " fmt,	\
> +		printk(KERN_DEBUG "[%d:c/r:%s] " fmt,	\
>  				task_pid_vnr(current),	\
>  				 __func__, ## args);	\
>  	} while (0)
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index ab795a6..2f6556b 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -966,13 +966,10 @@ config CHECKPOINT_DEBUG
>  	depends on CHECKPOINT
>  	default y
>  	help
> -	  This options turns on the debugging output of checkpoint/restart.
> -	  The level of verbosity is controlled by 'ckpt_debug_level' and can
> -	  be set at boot time with "ckpt_debug=" option.
> +	  If enabled, debugging messages related to checkpoint and
> +	  restart operations will be printed to the kernel log.
>  
> -	  Turning this option off will reduce the size of the c/r code. If
> -	  turned on, it is unlikely to incur visible overhead if the debug
> -	  level is set to zero.
> +	  Turn this on if you plan to test checkpoint/restart.
>  
>  source "samples/Kconfig"
>  
