From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 11/24] io-controller: Introduce group idling
Date: Fri, 28 Aug 2009 09:12:57 +0800
Message-ID: <4A972F19.4090408__31209.4346540563$1251422249$gmane$org@cn.fujitsu.com>
References: <1250451046-9966-1-git-send-email-vgoyal@redhat.com>
	<1250451046-9966-12-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1250451046-9966-12-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
> @@ -2201,13 +2362,44 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
>  		 * mean seek distance, give them a chance to run instead
>  		 * of idling.
>  		 */
> -		if (elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq))
> +		if (elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq)) {
> +			/*
> +			 * This is the last empty queue in the group and it
> +			 * has consumed its slice. If we expire it right away
> +			 * group might loose its share. Wait for an extra
> +			 * group_idle period for a request before queue
> +			 * expires.
> +			 */
> +			if (elv_iog_should_idle(ioq)) {
> +				elv_iog_arm_slice_timer(q, iog, 1);
> +				goto done;
> +			}
> +

Hi Vivek,

I think we shouldn't arm idle timer on iog again, if it's already on.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/elevator-fq.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index a4161c2..04f646f 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -3116,7 +3116,8 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 			 * group_idle period for a request before queue
 			 * expires.
 			 */
-			if (elv_iog_should_idle(ioq)) {
+			if (elv_iog_should_idle(ioq) &&
+			    !elv_iog_wait_busy(iog)) {
 				elv_iog_arm_slice_timer(q, iog, 1);
 				goto done;
 			}
-- 
1.5.4.rc3
