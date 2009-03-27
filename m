From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] IO Controller: No need to stop idling in as
Date: Fri, 27 Mar 2009 14:58:34 +0800
Message-ID: <49CC791A.10008__13914.5294706852$1238137410$gmane$org@cn.fujitsu.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-11-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1236823015-4183-11-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:

>  		.elevator_alloc_sched_queue_fn = as_alloc_as_queue,
>  		.elevator_free_sched_queue_fn = as_free_as_queue,
> +#ifdef CONFIG_IOSCHED_AS_HIER
> +		.elevator_expire_ioq_fn =       as_expire_ioq,
> +		.elevator_active_ioq_set_fn =   as_active_ioq_set,
>  	},
> -
> +	.elevator_features = ELV_IOSCHED_NEED_FQ | ELV_IOSCHED_SINGLE_IOQ | ELV_IOSCHED_DONT_IDLE,

  Hi Vivek,

  I found the IO Controller doesn't work in as.
  I dig into this issue, and notice that you stop idling in as. IMHO, this will cause
  active ioq is always expired when tring to choose a new ioq to serve(elv_fq_select_ioq). 
  Because idling is disabled, active ioq can't be kept anymore.
  So i just get rid of ELV_IOSCHED_DONT_IDLE, and it works fine this time.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/as-iosched.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/block/as-iosched.c b/block/as-iosched.c
index 27c14a7..499c521 100644
--- a/block/as-iosched.c
+++ b/block/as-iosched.c
@@ -1689,7 +1689,7 @@ static struct elevator_type iosched_as = {
 		.elevator_expire_ioq_fn =       as_expire_ioq,
 		.elevator_active_ioq_set_fn =   as_active_ioq_set,
 	},
-	.elevator_features = ELV_IOSCHED_NEED_FQ | ELV_IOSCHED_SINGLE_IOQ | ELV_IOSCHED_DONT_IDLE,
+	.elevator_features = ELV_IOSCHED_NEED_FQ | ELV_IOSCHED_SINGLE_IOQ,
 #else
 	},
 #endif
-- 
1.5.4.rc3
