From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 02/18] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Fri, 22 May 2009 14:43:04 +0800
Message-ID: <4A164978.1020604__16676.8180476085$1242974700$gmane$org@cn.fujitsu.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<1241553525-28095-3-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1241553525-28095-3-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
...
> +/* A request got completed from io_queue. Do the accounting. */
> +void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
> +{
> +	const int sync = rq_is_sync(rq);
> +	struct io_queue *ioq = rq->ioq;
> +	struct elv_fq_data *efqd = &q->elevator->efqd;
> +
> +	if (!elv_iosched_fair_queuing_enabled(q->elevator))
> +		return;
> +
> +	elv_log_ioq(efqd, ioq, "complete");
> +
> +	elv_update_hw_tag(efqd);
> +
> +	WARN_ON(!efqd->rq_in_driver);
> +	WARN_ON(!ioq->dispatched);
> +	efqd->rq_in_driver--;
> +	ioq->dispatched--;
> +
> +	if (sync)
> +		ioq->last_end_request = jiffies;
> +
> +	/*
> +	 * If this is the active queue, check if it needs to be expired,
> +	 * or if we want to idle in case it has no pending requests.
> +	 */
> +
> +	if (elv_active_ioq(q->elevator) == ioq) {
> +		if (elv_ioq_slice_new(ioq)) {
> +			elv_ioq_set_prio_slice(q, ioq);

  Hi Vivek,

  Would you explain a bit why slice_end should be set when first request completes.
  Why not set it just when an ioq gets active?
  
  Thanks.
  Gui Jianfeng
