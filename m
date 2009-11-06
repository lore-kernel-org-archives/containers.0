From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/1] don't swap 0 sids if ctx->arg->pids
Date: Fri, 06 Nov 2009 13:23:03 -0500
Message-ID: <4AF46987.4050506@librato.com>
References: <20091106073708.GA18978@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091106073708.GA18978-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


pulled with a slight change: tests for !ctx->args->pidns instead
of ctx->args->pids.

Oren.


Serge E. Hallyn wrote:
> It breaks restart --pidns
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  restart.c |   13 +++++++------
>  1 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/restart.c b/restart.c
> index 47d729a..f523adf 100644
> --- a/restart.c
> +++ b/restart.c
> @@ -2039,12 +2039,13 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
>  	 * NOTE: thanks to the construction of tasks_arr[], the first
>  	 * ctx->pid_nr entries in both arrays match (the same pids).
>  	 */
> -	for (m = 0; m < ctx->pids_nr; m++) {
> -		if (ctx->tasks_arr[m].flags & TASK_ZERO_SID)
> -			ctx->copy_arr[m].vsid = coord_sid;
> -		if (ctx->tasks_arr[m].flags & TASK_ZERO_PGID)
> -			ctx->copy_arr[m].vpgid = coord_sid;
> -	}
> +	if (!ctx->args->pids)
> +		for (m = 0; m < ctx->pids_nr; m++) {
> +			if (ctx->tasks_arr[m].flags & TASK_ZERO_SID)
> +				ctx->copy_arr[m].vsid = coord_sid;
> +			if (ctx->tasks_arr[m].flags & TASK_ZERO_PGID)
> +				ctx->copy_arr[m].vpgid = coord_sid;
> +		}
>  
>  	memcpy(ctx->pids_arr, ctx->copy_arr, len);
>  	close(ctx->pipe_in);
