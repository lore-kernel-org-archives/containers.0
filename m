From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Revert "ckpt/powerpc: handle syscall restart"
Date: Sun, 14 Mar 2010 22:51:03 -0400
Message-ID: <4B9DA097.1020401@cs.columbia.edu>
References: <1268418393-18325-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1268418393-18325-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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


All three applied, thanks !

Oren.

Nathan Lynch wrote:
> This reverts commit 64dab5da66f4fe212b43272ffa5e7a3403a64deb.
> 
> This way of handling syscall restart is incorrect -- it occurs too
> early in the restart process, and restore_retval is doing the wrong
> thing for powerpc anyway (fixed in a later patch).  While the reverted
> patch managed to address the case of system calls with restart blocks,
> other restartable system calls behave incorrectly after restart.
> ---
>  arch/powerpc/kernel/checkpoint.c |   25 -------------------------
>  1 files changed, 0 insertions(+), 25 deletions(-)
> 
> diff --git a/arch/powerpc/kernel/checkpoint.c b/arch/powerpc/kernel/checkpoint.c
> index cd384df..2634011 100644
> --- a/arch/powerpc/kernel/checkpoint.c
> +++ b/arch/powerpc/kernel/checkpoint.c
> @@ -307,31 +307,6 @@ static int restore_gprs(const struct ckpt_hdr_cpu *cpu_hdr,
>  	regs->orig_gpr3 = cpu_hdr->orig_gpr3;
>  
>  	regs->msr = sanitize_msr(regs->msr);
> -
> -	/* The normal servicing of the freezer's fake signal is
> -	 * short-circuited by checkpoint/restart.  See
> -	 * arch/powerpc/kernel/signal.c::do_signal_pending().
> -	 */
> -	if (TRAP(regs) != 0x0C00)
> -		goto out;
> -	if (!(regs->ccr & 0x10000000))
> -		goto out;
> -
> -	switch (regs->gpr[3]) {
> -	case ERESTARTNOHAND:
> -	case ERESTARTSYS:
> -	case ERESTARTNOINTR:
> -		regs->gpr[3] = regs->orig_gpr3;
> -		break;
> -	case ERESTART_RESTARTBLOCK:
> -		regs->gpr[0] = __NR_restart_syscall;
> -		break;
> -	default:
> -		goto out;
> -	}
> -
> -	regs->nip -= 4;
> -	regs->result = 0;
>  out:
>  	return rc;
>  }
