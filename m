From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] checkpoint/powerpc: fix up checkpoint syscall,
	tidy restart
Date: Fri, 05 Feb 2010 16:30:13 -0500
Message-ID: <4B6C8DE5.9040900@cs.columbia.edu>
References: <1265403510-977-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1265403510-977-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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


Thanks !

This one and the other two (user-cr) applied and pushed.

Oren.


Nathan Lynch wrote:
> Fix up fallout from changing checkpoint to ptregscall; use named
> parameters in sys_restart() instead of redundantly loading the syscall
> arguments from ptregs.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  arch/powerpc/kernel/process.c |   23 +++++++++++------------
>  1 files changed, 11 insertions(+), 12 deletions(-)
> 
> diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
> index f9da9eb..4b9019b 100644
> --- a/arch/powerpc/kernel/process.c
> +++ b/arch/powerpc/kernel/process.c
> @@ -991,21 +991,20 @@ out:
>  	return error;
>  }
>  
> -int sys_restart(unsigned long a0, unsigned long a1, unsigned long a2,
> -	       unsigned long a3, unsigned long a4, unsigned long a5,
> -	       struct pt_regs *regs)
> +int sys_checkpoint(unsigned long pid, unsigned long fd, unsigned long flags,
> +		   unsigned long logfd, unsigned long p5, unsigned long p6,
> +		   struct pt_regs *regs)
>  {
> -	unsigned long flags;
> -	pid_t pid;
> -	int logfd;
> -	int fd;
> -
>  	CHECK_FULL_REGS(regs);
>  
> -	pid = a0;
> -	fd = a1;
> -	flags = a2;
> -	logfd = a3;
> +	return do_sys_checkpoint(pid, fd, flags, logfd);
> +}
> +
> +int sys_restart(unsigned long pid, unsigned long fd, unsigned long flags,
> +		unsigned long logfd, unsigned long p5, unsigned long p6,
> +		struct pt_regs *regs)
> +{
> +	CHECK_FULL_REGS(regs);
>  
>  	return do_sys_restart(pid, fd, flags, logfd);
>  }
