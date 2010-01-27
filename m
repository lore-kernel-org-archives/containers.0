From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] switch s390 sys_checkpoint as well
Date: Wed, 27 Jan 2010 16:06:48 -0500
Message-ID: <4B60AAE8.3000206@cs.columbia.edu>
References: <20100127200111.GA24277@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100127200111.GA24277-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


got it.

Serge E. Hallyn wrote:
> I thought I had sent this before and was surprised to not see it
> in ckpt-v19-rc2.6, but actually it's not in my Sent folder so I
> think I was remiss...
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  arch/s390/kernel/process.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
> index 087f52c..ef66fa3 100644
> --- a/arch/s390/kernel/process.c
> +++ b/arch/s390/kernel/process.c
> @@ -242,7 +242,16 @@ SYSCALL_DEFINE4(clone, unsigned long, newsp, unsigned long, clone_flags,
>  }
>  
>  #ifdef CONFIG_CHECKPOINT
> +extern long do_sys_checkpoint(pid_t pid, int fd, unsigned long flags,
> +				int logfd);
>  extern long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd);
> +
> +SYSCALL_DEFINE4(checkpoint, pid_t, pid, int, fd, unsigned long, flags,
> +		int, logfd)
> +{
> +	return do_sys_checkpoint(pid, fd, flags, logfd);
> +}
> +
>  SYSCALL_DEFINE4(restart, pid_t, pid, int, fd, unsigned long, flags,
>  		int, logfd)
>  {
