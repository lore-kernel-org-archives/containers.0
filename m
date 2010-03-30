From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] checkpoint/powerpc: fix build break with
	CONFIG_CHECKPOINT=n
Date: Tue, 30 Mar 2010 00:53:59 -0400
Message-ID: <4BB183E7.8040104@cs.columbia.edu>
References: <1268847440-26975-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1268847440-26975-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Applied for ckpt-v21

Nathan Lynch wrote:
> do_sys_checkpoint and do_sys_restart don't exist when checkpoint is
> turned off, so move references to these to code which is built only
> when CONFIG_CHECKPOINT=y.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  arch/powerpc/kernel/checkpoint.c |   18 ++++++++++++++++++
>  arch/powerpc/kernel/process.c    |   18 ------------------
>  2 files changed, 18 insertions(+), 18 deletions(-)
> 
> diff --git a/arch/powerpc/kernel/checkpoint.c b/arch/powerpc/kernel/checkpoint.c
> index 2634011..c73acda 100644
> --- a/arch/powerpc/kernel/checkpoint.c
> +++ b/arch/powerpc/kernel/checkpoint.c
> @@ -531,3 +531,21 @@ int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
>  {
>  	return 0;
>  }
> +
> +int sys_checkpoint(unsigned long pid, unsigned long fd, unsigned long flags,
> +		   unsigned long logfd, unsigned long p5, unsigned long p6,
> +		   struct pt_regs *regs)
> +{
> +	CHECK_FULL_REGS(regs);
> +
> +	return do_sys_checkpoint(pid, fd, flags, logfd);
> +}
> +
> +int sys_restart(unsigned long pid, unsigned long fd, unsigned long flags,
> +		unsigned long logfd, unsigned long p5, unsigned long p6,
> +		struct pt_regs *regs)
> +{
> +	CHECK_FULL_REGS(regs);
> +
> +	return do_sys_restart(pid, fd, flags, logfd);
> +}
> diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
> index 6457530..0aafbf1 100644
> --- a/arch/powerpc/kernel/process.c
> +++ b/arch/powerpc/kernel/process.c
> @@ -979,24 +979,6 @@ out:
>  	return error;
>  }
>  
> -int sys_checkpoint(unsigned long pid, unsigned long fd, unsigned long flags,
> -		   unsigned long logfd, unsigned long p5, unsigned long p6,
> -		   struct pt_regs *regs)
> -{
> -	CHECK_FULL_REGS(regs);
> -
> -	return do_sys_checkpoint(pid, fd, flags, logfd);
> -}
> -
> -int sys_restart(unsigned long pid, unsigned long fd, unsigned long flags,
> -		unsigned long logfd, unsigned long p5, unsigned long p6,
> -		struct pt_regs *regs)
> -{
> -	CHECK_FULL_REGS(regs);
> -
> -	return do_sys_restart(pid, fd, flags, logfd);
> -}
> -
>  #ifdef CONFIG_IRQSTACKS
>  static inline int valid_irq_stack(unsigned long sp, struct task_struct *p,
>  				  unsigned long nbytes)
