From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/19] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Tue, 16 Jun 2009 09:02:27 -0400
Message-ID: <20090616130227.GA10730__34627.582532312$1245157713$gmane$org@redhat.com>
References: <1244513342-11758-1-git-send-email-vgoyal@redhat.com>
	<1244513342-11758-3-git-send-email-vgoyal@redhat.com>
	<4A37175C.80906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A37175C.80906-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Tue, Jun 16, 2009 at 11:54:04AM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> ...
> > +
> > +int elv_nr_busy_rt_ioq(struct elevator_queue *e)
> > +{
> > +	return e->efqd.busy_rt_queues;
> > +}
> > +EXPORT_SYMBOL(elv_nr_busy_rt_ioq);
> 
> This function is no need now.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Thanks Gui. Queued for next posting.

Thanks
Vivek

> ---
>  block/elevator-fq.c |    6 ------
>  block/elevator-fq.h |    1 -
>  2 files changed, 0 insertions(+), 7 deletions(-)
> 
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index f33155c..912ac6a 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -2553,12 +2553,6 @@ int elv_nr_busy_ioq(struct elevator_queue *e)
>  }
>  EXPORT_SYMBOL(elv_nr_busy_ioq);
>  
> -int elv_nr_busy_rt_ioq(struct elevator_queue *e)
> -{
> -	return e->efqd.busy_rt_queues;
> -}
> -EXPORT_SYMBOL(elv_nr_busy_rt_ioq);
> -
>  int elv_hw_tag(struct elevator_queue *e)
>  {
>  	return e->efqd.hw_tag;
> diff --git a/block/elevator-fq.h b/block/elevator-fq.h
> index 0939735..285a1ff 100644
> --- a/block/elevator-fq.h
> +++ b/block/elevator-fq.h
> @@ -711,7 +711,6 @@ extern void io_group_set_async_queue(struct io_group *iog, int ioprio_class,
>  extern struct io_group *io_get_io_group(struct request_queue *q,
>  					struct bio *bio, int create);
>  extern int elv_nr_busy_ioq(struct elevator_queue *e);
> -extern int elv_nr_busy_rt_ioq(struct elevator_queue *e);
>  extern struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp_mask);
>  extern void elv_free_ioq(struct io_queue *ioq);
>  
> -- 
> 1.5.4.rc3
> 
