From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 04/19] io-controller: Modify cfq to make use of flat
	elevator fair queuing
Date: Thu, 11 Jun 2009 14:12:44 +0800
Message-ID: <4A30A05C.4060703__38875.9785368622$1244700929$gmane$org@cn.fujitsu.com>
References: <1244513342-11758-1-git-send-email-vgoyal@redhat.com>
	<1244513342-11758-5-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1244513342-11758-5-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
> This patch changes cfq to use fair queuing code from elevator layer.
> 

last_end_request in cic is of no use anymore. Get rid of it.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/cfq-iosched.c       |    4 ----
 include/linux/iocontext.h |    1 -
 2 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 5871568..705e7ba 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1170,7 +1170,6 @@ cfq_alloc_io_context(struct cfq_data *cfqd, gfp_t gfp_mask)
 	cic = kmem_cache_alloc_node(cfq_ioc_pool, gfp_mask | __GFP_ZERO,
 							q->node);
 	if (cic) {
-		cic->last_end_request = jiffies;
 		INIT_LIST_HEAD(&cic->queue_list);
 		INIT_HLIST_NODE(&cic->cic_list);
 		cic->dtor = cfq_free_io_context;
@@ -1794,9 +1793,6 @@ static void cfq_completed_request(struct request_queue *q, struct request *rq)
 
 	if (!cfq_class_idle(cfqq))
 		cfqd->last_end_request = now;
-
-	if (sync)
-		RQ_CIC(rq)->last_end_request = now;
 }
 
 /*
diff --git a/include/linux/iocontext.h b/include/linux/iocontext.h
index 1fe9d78..9c4587b 100644
--- a/include/linux/iocontext.h
+++ b/include/linux/iocontext.h
@@ -39,7 +39,6 @@ struct cfq_io_context {
 
 	struct io_context *ioc;
 
-	unsigned long last_end_request;
 	sector_t last_request_pos;
 
 	unsigned int seek_samples;
-- 
1.5.4.rc3
