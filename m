From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH linux-cr RFC] change sysctl and default for unprivileged
	use
Date: Mon, 01 Mar 2010 14:10:59 -0500
Message-ID: <4B8C1143.5020404@cs.columbia.edu>
References: <20100225051441.GA27100@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100225051441.GA27100-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


Ack.

And since there was no objection, I'll pull into a new development
branch, ckpt-v19-dev.

Oren

Serge E. Hallyn wrote:
> ckpt_unpriv_allowed now can be 0 meaning privilege required
> for both checkpoint and restart, 1 meaning privilege required
> only for restart, or 2 meaning both can be done unprivileged.
> Make 1 the default.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/sys.c |   14 ++++++++------
>  kernel/sysctl.c  |    2 +-
>  2 files changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index d34ff98..b605784 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -24,12 +24,14 @@
>  #include <linux/deferqueue.h>
>  
>  /*
> - * ckpt_unpriv_allowed - sysctl controlled, do not allow checkpoints or
> - * restarts unless caller has CAP_SYS_ADMIN, if 0 (prevent unprivileged
> - * useres from expoitling any privilege escalation bugs). If it is 1,
> - * then regular permissions checks are intended to do the job.
> + * ckpt_unpriv_allowed - sysctl controlled.
> + *   If 0, then caller of sys_checkpoint() or sys_restart() must have
> + *	CAP_SYS_ADMIN
> + *   If 1, then only sys_restart() requires CAP_SYS_ADMIN.
> + *   If 2, then both can be called without privilege - regular permissions
> + *	checks are intended to do the job.
>   */
> -int ckpt_unpriv_allowed = 1;	/* default: allow */
> +int ckpt_unpriv_allowed = 1;	/* default: unpriv checkpoint not restart */
>  
>  /*
>   * Helpers to write(read) from(to) kernel space to(from) the checkpoint
> @@ -681,7 +683,7 @@ long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd)
>  	if (flags & ~RESTART_USER_FLAGS)
>  		return -EINVAL;
>  
> -	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
> +	if (ckpt_unpriv_allowed < 2 && !capable(CAP_SYS_ADMIN))
>  		return -EPERM;
>  
>  	if (pid)
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index e476ba0..8443bb0 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -948,7 +948,7 @@ static struct ctl_table kern_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_minmax,
>  		.extra1		= &zero,
> -		.extra2		= &one,
> +		.extra2		= &two,
>  	},
>  #endif
>  
