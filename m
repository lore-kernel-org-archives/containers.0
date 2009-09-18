From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] io-controller: Fix another bug that causing system hanging
Date: Fri, 18 Sep 2009 11:56:56 +0800
Message-ID: <4AB30508.6010206__16498.7428150654$1253246399$gmane$org@cn.fujitsu.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<1251495072-7780-12-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1251495072-7780-12-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
...

>   * If io scheduler has functionality of keeping track of close cooperator, check
>   * with it if it has got a closely co-operating queue.
> @@ -2057,6 +2171,7 @@ void *elv_select_ioq(struct request_queue *q, int force)
>  {
>  	struct elv_fq_data *efqd = q->elevator->efqd;
>  	struct io_queue *new_ioq = NULL, *ioq = elv_active_ioq(q->elevator);
> +	struct io_group *iog;
>  
>  	if (!elv_nr_busy_ioq(q->elevator))
>  		return NULL;
> @@ -2064,6 +2179,8 @@ void *elv_select_ioq(struct request_queue *q, int force)
>  	if (ioq == NULL)
>  		goto new_queue;
>  
> +	iog = ioq_to_io_group(ioq);
> +
>  	/*
>  	 * Force dispatch. Continue to dispatch from current queue as long
>  	 * as it has requests.
> @@ -2075,11 +2192,47 @@ void *elv_select_ioq(struct request_queue *q, int force)
>  			goto expire;
>  	}
>  
> +	/* We are waiting for this group to become busy before it expires.*/
> +	if (elv_iog_wait_busy(iog)) {
> +		ioq = NULL;
> +		goto keep_queue;
> +	}
> +
>  	/*
>  	 * The active queue has run out of time, expire it and select new.
>  	 */
> -	if (elv_ioq_slice_used(ioq) && !elv_ioq_must_dispatch(ioq))
> -		goto expire;
> +	if ((elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq))
> +	     && !elv_ioq_must_dispatch(ioq)) {
> +		/*
> +		 * Queue has used up its slice. Wait busy is not on otherwise
> +		 * we wouldn't have been here. If this group will be deleted
> +		 * after the queue expiry, then make sure we have onece
> +		 * done wait busy on the group in an attempt to make it
> +		 * backlogged.
> +		 *
> +		 * Following check helps in two conditions.
> +		 * - If there are requests dispatched from the queue and
> +		 *   select_ioq() comes before a request completed from the
> +		 *   queue and got a chance to arm any of the idle timers.
> +		 *
> +		 * - If at request completion time slice had not expired and
> +		 *   we armed either a ioq timer or group timer but when
> +		 *   select_ioq() hits, slice has expired and it will expire
> +		 *   the queue without doing busy wait on group.
> +		 *
> +		 * In similar situations cfq lets delte the queue even if
> +		 * idle timer is armed. That does not impact fairness in non
> +		 * hierarhical setup due to weighted slice lengths. But in
> +		 * hierarchical setup where group slice lengths are derived
> +		 * from queue and is not proportional to group's weight, it
> +		 * harms the fairness of the group.
> +		 */
> +		if (elv_iog_should_idle(ioq) && !elv_iog_wait_busy_done(iog)) {

Hi Vivek,

Here is another bug which will cause task hanging when accessing into a certain disk.
For the moment, last ioq(corresponding CGroup has been removed) is optimized not to 
expire unitl another ioq get backlogged. Here just checking "iog_wait_busy_done" flag
is not sufficient, because idle timer can be inactive at that moment. This will cause
the ioq keeping service all the time and won't stop, causing the whole system hanging. 
This patch adds extra check for "iog_wait_busy" to make sure that the idle timer is 
pending, and this ioq will be expired after timer is up.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/elevator-fq.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 40d0eb5..c039ba2 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -3364,7 +3364,8 @@ void *elv_select_ioq(struct request_queue *q, int force)
 		 * harms the fairness of the group.
 		 */
 		slice_expired = 1;
-		if (elv_iog_should_idle(ioq) && !elv_iog_wait_busy_done(iog)) {
+		if (elv_iog_should_idle(ioq) && !elv_iog_wait_busy_done(iog) &&
+		    elv_iog_wait_busy(iog)) {
 			ioq = NULL;
 			goto keep_queue;
 		} else
-- 
1.5.4.rc3
