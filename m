From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH user-cr] fix sid swap buglet
Date: Thu, 05 Nov 2009 18:43:30 -0500
Message-ID: <4AF36322.4050402@librato.com>
References: <20091105232436.GA301@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091105232436.GA301-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Oops ...already patched and pushed as per our discussion on IRC.
The patch is functionally identical but adds a comment.

Oren.

Serge E. Hallyn wrote:
> In the case of a restart of a subtree checkpoint, some sids
> may be recorded as 0.  If so, then we substitute the coordinator's
> sid.  The code to do that wasn't quite right, and in fact writes
> past the end of the pids_arr, which happens to be into the
> copy_arr.  As a result, the kernel was getting bogus data for
> substituted pids.  In my own case that lead to sys_restart()
> waiting on a bogus vpid (in particular, the pid of my bash shell).
> 
> Fix that.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  restart.c |   22 ++++++++++++----------
>  1 files changed, 12 insertions(+), 10 deletions(-)
> 
> diff --git a/restart.c b/restart.c
> index 20f5055..f0b7862 100644
> --- a/restart.c
> +++ b/restart.c
> @@ -2029,17 +2029,19 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
>  			if (ctx->pids_arr[m].vpgid == swap.old)
>  				ctx->copy_arr[m].vpgid = swap.new;
>  		}
> +	}
>  
> -		/*
> -		 * If the task's {sid,pgid} was zeroed out (inside
> -		 * ckpt_init_tree) then substitute the coordinator's
> -		 * sid for it now. (This should leave no more 0's in
> -		 * restart of a subtree-checkpoint).
> -		 */
> -		if (ctx->tasks_arr[n].flags & TASK_ZERO_SID)
> -			ctx->pids_arr[m].vsid = coord_sid;
> -		if (ctx->tasks_arr[n].flags & TASK_ZERO_PGID)
> -			ctx->pids_arr[m].vpgid = coord_sid;
> +	/*
> +	 * If the task's {sid,pgid} was zeroed out (inside
> +	 * ckpt_init_tree) then substitute the coordinator's
> +	 * sid for it now. (This should leave no more 0's in
> +	 * restart of a subtree-checkpoint).
> +	 */
> +	for (m = 0; m < ctx->pids_nr; m++) {
> +		if (ctx->tasks_arr[m].flags & TASK_ZERO_SID)
> +			ctx->copy_arr[m].vsid = coord_sid;
> +		if (ctx->tasks_arr[m].flags & TASK_ZERO_PGID)
> +			ctx->copy_arr[m].vpgid = coord_sid;
>  	}
>  
>  	memcpy(ctx->pids_arr, ctx->copy_arr, len);
