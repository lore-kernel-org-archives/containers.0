From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] IO-Controller: clear ioq wait flag if a request goes into
	that ioq
Date: Thu, 20 Aug 2009 09:46:10 +0800
Message-ID: <4A8CAAE2.1030804__14838.9291171499$1250732868$gmane$org@cn.fujitsu.com>
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
>  		/*
>  		 * Remember that we saw a request from this process, but
> @@ -1940,7 +2013,7 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
>  		 * has other work pending, don't risk delaying until the
>  		 * idle timer unplug to continue working.
>  		 */
> -		if (elv_ioq_wait_request(ioq)) {
> +		if (group_wait || elv_ioq_wait_request(ioq)) {

Hi Vivek,

I guess we need to clear ioq_wait_request flags if there are requests to 
go in this ioq. Otherwise, once waitting request on ioq, it will go into
this path every time when a request is enqueued.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/elevator-fq.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index b3c387d..201543e 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -2708,6 +2708,9 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
 				__blk_run_queue(q);
 			else
 				elv_mark_ioq_must_dispatch(ioq);
+
+			if (elv_ioq_wait_request(ioq))
+				elv_clear_ioq_wait_request(ioq);
 		}
 	} else if (elv_should_preempt(q, ioq, rq)) {
 		/*
-- 
1.5.4.rc3
