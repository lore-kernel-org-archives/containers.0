From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 05/24] io-controller: Modify cfq to make use of flat
	elevator fair queuing
Date: Thu, 30 Jul 2009 14:30:40 +0800
Message-ID: <4A713E10.2030204__24854.0910114118$1248935569$gmane$org@cn.fujitsu.com>
References: <1248467274-32073-1-git-send-email-vgoyal@redhat.com>
	<1248467274-32073-6-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248467274-32073-6-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
...
>  /*
>   * Check if new_cfqq should preempt the currently active queue. Return 0 for
> - * no or if we aren't sure, a 1 will cause a preempt.
> + * no or if we aren't sure, a 1 will cause a preemption attempt.
> + * Some of the preemption logic has been moved to common layer. Only cfq
> + * specific parts are left here.
>   */
>  static int
> -cfq_should_preempt(struct cfq_data *cfqd, struct cfq_queue *new_cfqq,
> -		   struct request *rq)
> +cfq_should_preempt(struct request_queue *q, void *new_cfqq, struct request *rq)
>  {
> -	struct cfq_queue *cfqq;
> +	struct cfq_data *cfqd = q->elevator->elevator_data;
> +	struct cfq_queue *cfqq = elv_active_sched_queue(q->elevator);
>  
> -	cfqq = cfqd->active_queue;
>  	if (!cfqq)
>  		return 0;
>  
> -	if (cfq_slice_used(cfqq))
> +	if (elv_ioq_slice_used(cfqq->ioq))
>  		return 1;
>  
>  	if (cfq_class_idle(new_cfqq))
> @@ -2018,13 +1661,7 @@ cfq_should_preempt(struct cfq_data *cfqd, struct cfq_queue *new_cfqq,
>  	if (rq_is_meta(rq) && !cfqq->meta_pending)
>  		return 1;
>  
> -	/*
> -	 * Allow an RT request to pre-empt an ongoing non-RT cfqq timeslice.
> -	 */
> -	if (cfq_class_rt(new_cfqq) && !cfq_class_rt(cfqq))
> -		return 1;
> -
> -	if (!cfqd->active_cic || !cfq_cfqq_wait_request(cfqq))
> +	if (!cfqd->active_cic || !elv_ioq_wait_request(cfqq->ioq))
>  		return 0;
>  
>  	/*

Hi Vivek,

cfq_should_preempt() will do the check "if (cfq_rq_close(cfqd, rq)) to see whether
it should preempt the current cfqq. From fairness point of view,  should we also 
check "fairness" value, if it's set fairness == 1, don't allow to preempt the current
cfqq?


-- 
Regards
Gui Jianfeng
