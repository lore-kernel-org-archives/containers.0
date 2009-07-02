From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [C/R][PATCH] Have ckpt_debug() print global pid and __LINE__
Date: Thu, 02 Jul 2009 02:49:58 -0400
Message-ID: <4A4C5896.8060604@cs.columbia.edu>
References: <20090702022541.GA31350@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702022541.GA31350-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Good idea - in queue for v17.

Thanks,

Oren.

Sukadev Bhattiprolu wrote:
> Have ckpt_debug() print global-pid and __LINE__
> 
> Printing both global and virtual pid helps correlating dmesg with 
> logs from mktree.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> ---
>  include/linux/checkpoint.h |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> Index: linux-cr/include/linux/checkpoint.h
> ===================================================================
> --- linux-cr.orig/include/linux/checkpoint.h	2009-07-01 19:09:36.000000000 -0700
> +++ linux-cr/include/linux/checkpoint.h	2009-07-01 19:20:29.000000000 -0700
> @@ -281,12 +281,12 @@ extern int restore_signal(struct ckpt_ct
>  extern unsigned long ckpt_debug_level;
>  
>  /* use this to select a specific debug level */
> -#define _ckpt_debug(level, fmt, args...)			\
> -	do {							\
> -		if (ckpt_debug_level & (level))			\
> -			printk(KERN_DEBUG "[%d:c/r:%s] " fmt,	\
> -				task_pid_vnr(current),		\
> -				 __func__, ## args);		\
> +#define _ckpt_debug(level, fmt, args...)				\
> +	do {								\
> +		if (ckpt_debug_level & (level))				\
> +			printk(KERN_DEBUG "[%d:%d:c/r:%s:%d] " fmt,	\
> +				current->pid, task_pid_vnr(current),	\
> +				 __func__, __LINE__, ## args);		\
>  	} while (0)
>  
>  /*
> 
