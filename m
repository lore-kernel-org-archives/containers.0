From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 04/19] io-controller: Modify cfq to make use of flat
	elevator fair queuing
Date: Mon, 15 Jun 2009 09:02:25 -0400
Message-ID: <20090615130225.GB5717__49329.5896020301$1245071002$gmane$org@redhat.com>
References: <1244513342-11758-1-git-send-email-vgoyal@redhat.com>
	<1244513342-11758-5-git-send-email-vgoyal@redhat.com>
	<4A360CD2.8060707@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A360CD2.8060707-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Mon, Jun 15, 2009 at 04:56:50PM +0800, Gui Jianfeng wrote:
> > -static inline int
> > -cfq_prio_to_slice(struct cfq_data *cfqd, struct cfq_queue *cfqq)
> > +static inline int cfq_class_rt(struct cfq_queue *cfqq)
> >  {
> > -	return cfq_prio_slice(cfqd, cfq_cfqq_sync(cfqq), cfqq->ioprio);
> > +	return elv_ioq_class_rt(cfqq->ioq);
> >  }
> 
> Hi Vivek,
> 
> cfq_class_rt isn't needed now, clean it up.
> 

Thanks Gui. Queued up for next posting.

Vivek

> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  block/cfq-iosched.c |    5 -----
>  1 files changed, 0 insertions(+), 5 deletions(-)
> 
> diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
> index 705e7ba..23b24b9 100644
> --- a/block/cfq-iosched.c
> +++ b/block/cfq-iosched.c
> @@ -234,11 +234,6 @@ static inline int cfq_class_idle(struct cfq_queue *cfqq)
>  	return elv_ioq_class_idle(cfqq->ioq);
>  }
>  
> -static inline int cfq_class_rt(struct cfq_queue *cfqq)
> -{
> -	return elv_ioq_class_rt(cfqq->ioq);
> -}
> -
>  static inline int cfq_cfqq_sync(struct cfq_queue *cfqq)
>  {
>  	return elv_ioq_sync(cfqq->ioq);
> -- 
> 1.5.4.rc3
> 
