From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/3] restart debug: add final process tree status
Date: Thu, 01 Oct 2009 19:29:49 -0400
Message-ID: <4AC53B6D.7000703@librato.com>
References: <20090929165342.GA10076@us.ibm.com>
	<20090929165402.GA10114@us.ibm.com> <4AC40CA0.8020305@librato.com>
	<20091001153356.GA20565@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091001153356.GA20565-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Serge E. Hallyn wrote:
> 
> Here:
> 
> From 8cf006a1bf26a4b280841401302c99689d629e0a Mon Sep 17 00:00:00 2001
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Date: Thu, 1 Oct 2009 11:09:40 -0400
> Subject: [PATCH 1/1] restart debug: add final process tree status (v2)
> 
> Have tasks in sys_restart keep some status in a list off
> of checkpoint_ctx, and print this info when the checkpoint_ctx
> is freed.
> 
> This version is mainly just ported against ckpt-v18-hallyn.
> 
> Sample output:
> 
> [3519:2:c/r:free_per_task_status:207] 3 tasks registered, nr_tasks was 0 nr_total 0
> [3519:2:c/r:free_per_task_status:210] active pid was 1, ctx->errno 0
> [3519:2:c/r:free_per_task_status:212] kflags 6 uflags 0 oflags 1
> [3519:2:c/r:free_per_task_status:214] task 0 to run was 2
> [3519:2:c/r:free_per_task_status:217] pid 3517
> [3519:2:c/r:free_per_task_status:219] it was coordinator
> [3519:2:c/r:free_per_task_status:227] it was running
> [3519:2:c/r:free_per_task_status:217] pid 3519
> [3519:2:c/r:free_per_task_status:223] it was the root task
> [3519:2:c/r:free_per_task_status:229] it was a normal task
> [3519:2:c/r:free_per_task_status:217] pid 3520
> [3519:2:c/r:free_per_task_status:221] it was a ghost
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Looks good.. I'll massage it a bit and add. Meanwhile, a
couple of questions:

[...]

> ---
>  checkpoint/restart.c             |  106 ++++++++++++++++++++++++++++++++++++++
>  checkpoint/sys.c                 |   57 ++++++++++++++++++++
>  include/linux/checkpoint_types.h |   20 +++++++
>  3 files changed, 183 insertions(+), 0 deletions(-)
> 
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index b12c8bd..1f356c0 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -26,6 +26,98 @@
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
>  
> +#ifdef CONFIG_CHECKPOINT_DEBUG
> +static struct ckpt_task_status *ckpt_debug_checkin(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_task_status *s;
> +	s = kmalloc(sizeof(*s), GFP_KERNEL);
> +	if (!s)
> +		return NULL;
> +	s->pid = current->pid;
> +	s->error = 0;
> +	s->flags = RESTART_DBG_WAITING;
> +	if (current == ctx->root_task)
> +		s->flags |= RESTART_DBG_ROOT;
> +	list_add_tail(&s->list, &ctx->per_task_status);
> +	return s;
> +}

The logic would be a bit simpler if you allow check-in to fail
(and then fail the restart) - you then don't need to test for
validity of @s everywhere.

> +
> +static struct ckpt_task_status *getme(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_task_status *s = NULL;
> +	list_for_each_entry(s, &ctx->per_task_status, list) {
> +		if (s->pid == current->pid)
> +			break;
> +	}
> +	if (!s || s->pid != current->pid)
> +		return NULL;

Note that here @s is never NULL.

[...]

> @@ -680,11 +772,17 @@ static int do_ghost_task(void)
>  	if (IS_ERR(ctx))
>  		return PTR_ERR(ctx);
>  
> +	ckpt_debug_ghost(ctx);
> +
> +	ckpt_debug_log_running(ctx);
> +
>  	current->flags |= PF_RESTARTING;
>  
>  	ret = wait_event_interruptible(ctx->ghostq,
>  				       all_tasks_activated(ctx) ||
>  				       ckpt_test_ctx_error(ctx));
> +
> +	ckpt_debug_log_error(ctx, 0);

Did you mean s/0/ret/ ?

[...]

> +	list_for_each_entry_safe(s, p, &ctx->per_task_status, list) {
> +		ckpt_debug("pid %d\n", s->pid);
> +		if (s->flags & RESTART_DBG_COORD)
> +			ckpt_debug("it was coordinator\n");
> +		if (s->flags & RESTART_DBG_GHOST)
> +			ckpt_debug("it was a ghost\n");
> +		if (s->flags & RESTART_DBG_ROOT)
> +			ckpt_debug("it was the root task\n");
> +		if (s->flags & RESTART_DBG_WAITING)
> +			ckpt_debug("it was still waiting to run restart\n");
> +		if (s->flags & RESTART_DBG_RUNNING)
> +			ckpt_debug("it was running\n");
> +		if (s->flags & RESTART_DBG_NORMAL)
> +			ckpt_debug("it was a normal task\n");
> +		if (s->flags & RESTART_DBG_FAILED)
> +			ckpt_debug("it finished with error %d\n", s->error);
> +		if (s->flags & RESTART_DBG_FAILED)

s/FAILED/SUCCESS/ ... :p

[...]

Oren.
