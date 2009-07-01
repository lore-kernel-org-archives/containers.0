From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] io-controller: Don't expire an idle ioq if it's the
	only ioq in hierarchy
Date: Tue, 30 Jun 2009 21:32:39 -0400
Message-ID: <20090701013239.GB13958__8877.78943074427$1246412153$gmane$org@redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<1245443858-8487-9-git-send-email-vgoyal@redhat.com>
	<4A49C381.3040302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A49C381.3040302-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jun 30, 2009 at 03:49:21PM +0800, Gui Jianfeng wrote:
> Hi Vivek,
> 
> We don't expect expiring an idle ioq if it's the only ioq 
> in the hierarchy.
> 

Hi Gui,

This patch will avoid idle queue expiry for single ioq schedulers. But
that's not an issue anyway as single ioq schedulers don't have the notion
of idle queue. It is only CFQ which allows creation of idle ioq.

Thanks
Vivek

> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  block/elevator-fq.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index 4270cfd..0b65e16 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -4058,12 +4058,6 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
>  			elv_clear_ioq_slice_new(ioq);
>  		}
>  
> -		if (elv_ioq_class_idle(ioq)) {
> -			if (elv_iosched_expire_ioq(q, 1, 0))
> -				elv_ioq_slice_expired(q);
> -			goto done;
> -		}
> -
>  		/*
>  		 * If there is only root group present, don't expire the queue
>  		 * for single queue ioschedulers (noop, deadline, AS). It is
> @@ -4077,6 +4071,12 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
>  			goto done;
>  		}
>  
> +		if (elv_ioq_class_idle(ioq)) {
> +			if (elv_iosched_expire_ioq(q, 1, 0))
> +				elv_ioq_slice_expired(q);
> +			goto done;
> +		}
> +
>  		/* For async queue try to do wait busy */
>  		if (efqd->fairness && !elv_ioq_sync(ioq) && !ioq->nr_queued
>  		    && (elv_iog_nr_active(iog) <= 1)) {
> -- 
> 1.5.4.rc3
> 
