From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] ckpt/powerpc: handle syscall restart
Date: Mon, 01 Mar 2010 14:20:03 -0500
Message-ID: <4B8C1363.6030206@cs.columbia.edu>
References: <1267214073-32348-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1267214073-32348-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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


Applied, thanks.

Nathan Lynch wrote:
> If a task is checkpointed while servicing a restartable system call
> like nanosleep, we need to ensure that the syscall is restarted
> appropriately after a checkpoint/restart cycle.  This gets
> cr_tests/sleeptest passing on powerpc.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  arch/powerpc/kernel/checkpoint.c |   25 +++++++++++++++++++++++++
>  1 files changed, 25 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/powerpc/kernel/checkpoint.c b/arch/powerpc/kernel/checkpoint.c
> index 2634011..cd384df 100644
> --- a/arch/powerpc/kernel/checkpoint.c
> +++ b/arch/powerpc/kernel/checkpoint.c
> @@ -307,6 +307,31 @@ static int restore_gprs(const struct ckpt_hdr_cpu *cpu_hdr,
>  	regs->orig_gpr3 = cpu_hdr->orig_gpr3;
>  
>  	regs->msr = sanitize_msr(regs->msr);
> +
> +	/* The normal servicing of the freezer's fake signal is
> +	 * short-circuited by checkpoint/restart.  See
> +	 * arch/powerpc/kernel/signal.c::do_signal_pending().
> +	 */
> +	if (TRAP(regs) != 0x0C00)
> +		goto out;
> +	if (!(regs->ccr & 0x10000000))
> +		goto out;
> +
> +	switch (regs->gpr[3]) {
> +	case ERESTARTNOHAND:
> +	case ERESTARTSYS:
> +	case ERESTARTNOINTR:
> +		regs->gpr[3] = regs->orig_gpr3;
> +		break;
> +	case ERESTART_RESTARTBLOCK:
> +		regs->gpr[0] = __NR_restart_syscall;
> +		break;
> +	default:
> +		goto out;
> +	}
> +
> +	regs->nip -= 4;
> +	regs->result = 0;
>  out:
>  	return rc;
>  }
