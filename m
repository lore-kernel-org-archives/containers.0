From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 02/20] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Mon, 08 Jun 2009 09:08:44 +0800
Message-ID: <4A2C649C.8070806__43990.0919016965$1244423470$gmane$org@cn.fujitsu.com>
References: <1243377729-2176-1-git-send-email-vgoyal@redhat.com>
	<1243377729-2176-3-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1243377729-2176-3-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
> +/* Get next queue for service. */
> +struct io_queue *elv_get_next_ioq(struct request_queue *q, int extract)
> +{
> +	struct elv_fq_data *efqd = &q->elevator->efqd;
> +	struct io_entity *entity = NULL;
> +	struct io_queue *ioq = NULL;
> +	struct io_sched_data *sd;
> +
> +	/*
> +	 * one can check for which queue will be selected next while having
> +	 * one queue active. preempt logic uses it.
> +	 */
> +	BUG_ON(extract && efqd->active_queue != NULL);
> +
> +	if (!efqd->busy_queues)
> +		return NULL;
> +
> +	sd = &efqd->root_group->sched_data;
> +	if (extract)
> +		entity = bfq_lookup_next_entity(sd, 1);
> +	else
> +		entity = bfq_lookup_next_entity(sd, 0);

This if and else branch is not needed.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/elevator-fq.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 3c5f9da..655162b 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -3069,10 +3069,7 @@ struct io_queue *elv_get_next_ioq(struct request_queue *q, int extract)
 
 	sd = &efqd->root_group->sched_data;
 	for (; sd != NULL; sd = entity->my_sched_data) {
-		if (extract)
-			entity = bfq_lookup_next_entity(sd, 1);
-		else
-			entity = bfq_lookup_next_entity(sd, 0);
+		entity = bfq_lookup_next_entity(sd, extract);
 
 		/*
 		 * entity can be null despite the fact that there are busy
-- 
1.5.4.rc3
