From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 05/20] io-controller: Common hierarchical fair queuing
	code in elevaotor layer
Date: Fri, 5 Jun 2009 09:21:44 -0400
Message-ID: <20090605132144.GB3491__49250.3511290581$1244208174$gmane$org@redhat.com>
References: <1243377729-2176-1-git-send-email-vgoyal@redhat.com>
	<1243377729-2176-6-git-send-email-vgoyal@redhat.com>
	<4A28E710.5080307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A28E710.5080307-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, jbaron-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jun 05, 2009 at 05:36:16PM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> ...
> > +#ifdef CONFIG_GROUP_IOSCHED
> > +extern int io_group_allow_merge(struct request *rq, struct bio *bio);
> > +extern void io_ioq_move(struct elevator_queue *e, struct io_queue *ioq,
> 
> io_ioq_move is not used anymore, removing the dead code.
> 

Thanks Gui. Will include the patch in next posting.

Vivek

> Singed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  block/elevator-fq.h |   11 -----------
>  1 files changed, 0 insertions(+), 11 deletions(-)
> 
> diff --git a/block/elevator-fq.h b/block/elevator-fq.h
> index 1c99e83..24a3af9 100644
> --- a/block/elevator-fq.h
> +++ b/block/elevator-fq.h
> @@ -537,8 +537,6 @@ static inline struct io_group *ioq_to_io_group(struct io_queue *ioq)
>  
>  #ifdef CONFIG_GROUP_IOSCHED
>  extern int io_group_allow_merge(struct request *rq, struct bio *bio);
> -extern void io_ioq_move(struct elevator_queue *e, struct io_queue *ioq,
> -					struct io_group *iog);
>  static inline bfq_weight_t iog_weight(struct io_group *iog)
>  {
>  	return iog->entity.weight;
> @@ -588,15 +586,6 @@ static inline int update_requeue(struct io_queue *ioq, int requeue)
>  }
>  
>  #else /* !GROUP_IOSCHED */
> -/*
> - * No ioq movement is needed in case of flat setup. root io group gets cleaned
> - * up upon elevator exit and before that it has been made sure that both
> - * active and idle tree are empty.
> - */
> -static inline void io_ioq_move(struct elevator_queue *e, struct io_queue *ioq,
> -					struct io_group *iog)
> -{
> -}
>  
>  static inline int io_group_allow_merge(struct request *rq, struct bio *bio)
>  {
> -- 
> 1.5.4.rc3
> 
