From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 12/24] io-controller: Wait for requests to complete from
	last queue before new queue is scheduled
Date: Mon, 24 Aug 2009 11:30:34 +0800
Message-ID: <4A92095A.4070804__33192.0720790096$1251084805$gmane$org@cn.fujitsu.com>
References: <1250451046-9966-1-git-send-email-vgoyal@redhat.com>
	<1250451046-9966-13-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1250451046-9966-13-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
...
>  void elv_schedule_dispatch(struct request_queue *q)
> @@ -2260,6 +2264,17 @@ void *elv_select_ioq(struct request_queue *q, int force)
>  	}
>  
>  expire:
> +	if (efqd->fairness && !force && ioq && ioq->dispatched) {
> +		/*
> +		 * If there are request dispatched from this queue, don't
> +		 * dispatch requests from new queue till all the requests from
> +		 * this queue have completed.
> +		 */
> +		elv_log_ioq(efqd, ioq, "select: wait for requests to finish"
> +				" disp=%lu", ioq->dispatched);
> +		ioq = NULL;
> +		goto keep_queue;
> +	}
>  	elv_slice_expired(q);
>  new_queue:
>  	ioq = elv_set_active_ioq(q, new_ioq);
> @@ -2375,6 +2390,10 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
>  				goto done;
>  			}
>  
> +			/* Wait for requests to finish from this queue */
> +			if (efqd->fairness && ioq->dispatched)

Since we have the routing to access to ioq->dispatched, why not to use it.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/elevator-fq.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index d04e925..f1e0de5 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -3120,7 +3120,7 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 			}
 
 			/* Wait for requests to finish from this queue */
-			if (efqd->fairness && ioq->dispatched)
+			if (efqd->fairness && elv_ioq_nr_dispatched(ioq))
 				goto done;
 
 			/* Expire the queue */
@@ -3135,7 +3135,7 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 		 * If this is the last queue in the group and we did not
 		 * decide to idle on queue, idle on group.
 		 */
-		if (elv_iog_should_idle(ioq) && !ioq->dispatched
+		if (elv_iog_should_idle(ioq) && !elv_ioq_nr_dispatched(ioq)
 		    && !timer_pending(&efqd->idle_slice_timer)) {
 			/*
 			 * If queue has used up its slice, wait for the
-- 
1.5.4.rc3
