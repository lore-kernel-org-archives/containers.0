From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/20] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Mon, 8 Jun 2009 09:56:52 -0400
Message-ID: <20090608135652.GE3652__46681.4315565445$1244469807$gmane$org@redhat.com>
References: <1243377729-2176-1-git-send-email-vgoyal@redhat.com>
	<1243377729-2176-3-git-send-email-vgoyal@redhat.com>
	<4A2CC15F.2010708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A2CC15F.2010708-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Mon, Jun 08, 2009 at 03:44:31PM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> ...
> > +
> > +static inline pid_t elv_ioq_pid(struct io_queue *ioq)
> > +{
> > +	return ioq->pid;
> > +}
> > +
> > +static inline unsigned long elv_ioq_ttime_mean(struct io_queue *ioq)
> > +{
> > +	return ioq->ttime_mean;
> > +}
> > +
> > +static inline unsigned long elv_ioq_sample_valid(struct io_queue *ioq)
> > +{
> > +	return ioq_sample_valid(ioq->ttime_samples);
> > +}
> > +
> 
> These three functions are dead now, just remove them.
> 

Thanks Gui. queued up for next posting.

Thanks
Vivek

> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  block/elevator-fq.h |   15 ---------------
>  1 files changed, 0 insertions(+), 15 deletions(-)
> 
> diff --git a/block/elevator-fq.h b/block/elevator-fq.h
> index 24a3af9..b2bb11a 100644
> --- a/block/elevator-fq.h
> +++ b/block/elevator-fq.h
> @@ -452,21 +452,6 @@ static inline int elv_ioq_nr_queued(struct io_queue *ioq)
>  	return ioq->nr_queued;
>  }
>  
> -static inline pid_t elv_ioq_pid(struct io_queue *ioq)
> -{
> -	return ioq->pid;
> -}
> -
> -static inline unsigned long elv_ioq_ttime_mean(struct io_queue *ioq)
> -{
> -	return ioq->ttime_mean;
> -}
> -
> -static inline unsigned long elv_ioq_sample_valid(struct io_queue *ioq)
> -{
> -	return ioq_sample_valid(ioq->ttime_samples);
> -}
> -
>  static inline void elv_get_ioq(struct io_queue *ioq)
>  {
>  	atomic_inc(&ioq->ref);
> -- 
> 1.5.4.rc3
