From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] userns: Allow unprivileged reboot
Date: Wed, 2 Jan 2013 09:13:44 -0600
Message-ID: <20130102151344.GA5822@sergelap>
References: <50DBC2E0.3040908@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50DBC2E0.3040908-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Li Zefan (lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org):
> In a container with its own pid namespace and user namespace, rebooting
> the system won't reboot the host, but terminate all the processes in
> it and thus have the container shutdown, so it's safe.
> 
> Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Thanks, Li.

fwiw,
Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

-serge

> ---
>  kernel/sys.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 265b376..24d1ef5 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -433,11 +433,12 @@ static DEFINE_MUTEX(reboot_mutex);
>  SYSCALL_DEFINE4(reboot, int, magic1, int, magic2, unsigned int, cmd,
>  		void __user *, arg)
>  {
> +	struct pid_namespace *pid_ns = task_active_pid_ns(current);
>  	char buffer[256];
>  	int ret = 0;
>  
>  	/* We only trust the superuser with rebooting the system. */
> -	if (!capable(CAP_SYS_BOOT))
> +	if (!ns_capable(pid_ns->user_ns, CAP_SYS_BOOT))
>  		return -EPERM;
>  
>  	/* For safety, we require "magic" arguments. */
> @@ -453,7 +454,7 @@ SYSCALL_DEFINE4(reboot, int, magic1, int, magic2, unsigned int, cmd,
>  	 * pid_namespace, the command is handled by reboot_pid_ns() which will
>  	 * call do_exit().
>  	 */
> -	ret = reboot_pid_ns(task_active_pid_ns(current), cmd);
> +	ret = reboot_pid_ns(pid_ns, cmd);
>  	if (ret)
>  		return ret;
>  
> -- 
> 1.8.0.2
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
