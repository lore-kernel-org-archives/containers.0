From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH user-cr] restart: unshare mounts ns when unsharing pidns
	(for --pidns)
Date: Tue, 30 Mar 2010 03:07:25 -0400
Message-ID: <4BB1A32D.4090001@cs.columbia.edu>
References: <20100324160251.GA18717@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100324160251.GA18717-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Applied in ckpt-v20-dev.

Serge E. Hallyn wrote:
> NOTE - this is against Suka's latest user-cr patchset.  Without
> this patch, the cr_tests/simple testcase ends up remounting
> /proc at restart without having unshared mounts.  Therefore,
> after running the testcase no tasks show up in /proc.
> 
> With this patch on top of Suka's user-cr patchset, all cr_tests
> pass.
> 
> Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  restart.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/restart.c b/restart.c
> index 484668a..677033d 100644
> --- a/restart.c
> +++ b/restart.c
> @@ -554,7 +554,7 @@ int app_restart(struct app_restart_args *args)
>  		ret = ckpt_coordinator_pidns(&ctx);
>  	} else if (ctx.args->pidns) {
>  		ckpt_dbg("new pidns with init\n");
> -		ctx.tasks_arr[0].flags |= TASK_NEWPID;
> +		ctx.tasks_arr[0].flags |= TASK_NEWPID | TASK_NEWNS;
>  		if (global_send_sigint == -1)
>  			global_send_sigint = SIGKILL;
>  		ret = ckpt_coordinator(&ctx);
