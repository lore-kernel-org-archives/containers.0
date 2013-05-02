From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 07/31] blk-throttle: removed deferred config application
	mechanism
Date: Thu, 2 May 2013 10:49:12 -0400
Message-ID: <20130502144912.GE30020@redhat.com>
References: <1367455189-6957-1-git-send-email-tj@kernel.org>
	<1367455189-6957-8-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1367455189-6957-8-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, May 01, 2013 at 05:39:25PM -0700, Tejun Heo wrote:

[..]
> @@ -1023,9 +975,27 @@ static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
>  	else
>  		*(unsigned int *)((void *)tg + cft->private) = ctx.v;
>  
> -	/* XXX: we don't need the following deferred processing */
> -	xchg(&tg->limits_changed, true);
> -	xchg(&td->limits_changed, true);
> +	throtl_log_tg(td, tg, "limit change rbps=%llu wbps=%llu riops=%u wiops=%u",
> +		      tg->bps[READ], tg->bps[WRITE],
> +		      tg->iops[READ], tg->iops[WRITE]);
> +
> +	/*
> +	 * We're already holding queue_lock and know @tg is valid.  Let's
> +	 * apply the new config directly.
> +	 *
> +	 * Restart the slices for both READ and WRITES. It might happen
> +	 * that a group's limit are dropped suddenly and we don't want to
> +	 * account recently dispatched IO with new low rate.
> +	 */
> +	throtl_start_new_slice(td, tg, 0);
> +	throtl_start_new_slice(td, tg, 1);
> +
> +	if (throtl_tg_on_rr(tg)) {
> +		tg_update_disptime(td, tg);
> +		throtl_schedule_next_dispatch(td);
> +	}
> +
> +	/* kick dispatch in case disptime got shortened */
>  	throtl_schedule_delayed_work(td, 0);

Hi Tejun,

Do we need above throtl_schedule_delayed_work() now?
throtl_schedule_next_dispatch() should take care of it. And if group
is not on service tree at the time of limit change, then anyway, we don't
have to schedule any work.

Thanks
Vivek
