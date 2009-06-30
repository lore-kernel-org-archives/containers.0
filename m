From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 02/20] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Tue, 30 Jun 2009 14:40:36 +0800
Message-ID: <4A49B364.5000508__13133.2502155148$1246344294$gmane$org@cn.fujitsu.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<1245443858-8487-3-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1245443858-8487-3-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
...
> +
> +/*
> + * Do the accounting. Determine how much service (in terms of time slices)
> + * current queue used and adjust the start, finish time of queue and vtime
> + * of the tree accordingly.
> + *
> + * Determining the service used in terms of time is tricky in certain
> + * situations. Especially when underlying device supports command queuing
> + * and requests from multiple queues can be there at same time, then it
> + * is not clear which queue consumed how much of disk time.
> + *
> + * To mitigate this problem, cfq starts the time slice of the queue only
> + * after first request from the queue has completed. This does not work
> + * very well if we expire the queue before we wait for first and more
> + * request to finish from the queue. For seeky queues, we will expire the
> + * queue after dispatching few requests without waiting and start dispatching
> + * from next queue.
> + *
> + * Not sure how to determine the time consumed by queue in such scenarios.
> + * Currently as a crude approximation, we are charging 25% of time slice
> + * for such cases. A better mechanism is needed for accurate accounting.
> + */

  Hi Vivek,

  The comment is out of date, would you update it accordingly?

> +void __elv_ioq_slice_expired(struct request_queue *q, struct io_queue *ioq)
> +{
> +	struct elv_fq_data *efqd = &q->elevator->efqd;
> +	struct io_entity *entity = &ioq->entity;
> +	long slice_unused = 0, slice_used = 0, slice_overshoot = 0;
> +
> +	assert_spin_locked(q->queue_lock);
> +	elv_log_ioq(efqd, ioq, "slice expired");
> +
> +	if (elv_ioq_wait_request(ioq))
> +		del_timer(&efqd->idle_slice_timer);
> +
> +	elv_clear_ioq_wait_request(ioq);
> +
> +	/*

-- 
Regards
Gui Jianfeng
