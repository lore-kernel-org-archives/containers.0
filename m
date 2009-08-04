From: Munehiro Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [PATCH] io-controller: implement per group request allocation
	limitation
Date: Mon, 03 Aug 2009 22:02:58 -0400
Message-ID: <4A7796D2.4030104__43624.204331036$1249351588$gmane$org@ds.jp.nec.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<4A569FC5.7090801@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A569FC5.7090801-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Gui Jianfeng wrote, on 07/09/2009 09:56 PM:
> Hi Vivek,
>
> This patch exports a cgroup based per group request limits interface.
> and removes the global one. Now we can use this interface to perform
> different request allocation limitation for different groups.
>
> Signed-off-by: Gui Jianfeng<guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
(snip)

Hi Jianfeng,

If this helps.

If calling elv_io_group_congestion_threshold() before
setting iog->iocg_id, iocg->nr_group_requests cannot be
referred.  As a result of it, iog->nr_congestion_on is
always misculculated as 0.
This patch moves the calling of
elv_io_group_congestion_threshold() after setting
iog->iocg_id.

Signed-off-by: Munehiro "Muuhh" Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
---
  block/elevator-fq.c |    3 ++-
  1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 7c83d1e..3368a7f 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -2195,7 +2195,6 @@ static struct io_group *io_alloc_root_group(struct request_queue *q,
  		iog->sched_data.service_tree[i] = IO_SERVICE_TREE_INIT;
  
  	blk_init_request_list(&iog->rl);
-	elv_io_group_congestion_threshold(q, iog);
  
  	iocg = &io_root_cgroup;
  	spin_lock_irq(&iocg->lock);
@@ -2204,6 +2203,8 @@ static struct io_group *io_alloc_root_group(struct request_queue *q,
  	iog->iocg_id = css_id(&iocg->css);
  	spin_unlock_irq(&iocg->lock);
  
+	elv_io_group_congestion_threshold(q, iog);
+
  #ifdef CONFIG_DEBUG_GROUP_IOSCHED
  	io_group_path(iog, iog->path, sizeof(iog->path));
  #endif
-- 
1.6.2.5




-- 
IKEDA, Munehiro
   NEC Corporation of America
     m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org
