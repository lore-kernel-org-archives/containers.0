From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 10/19] io-conroller: Prepare elevator layer for single
	queue schedulers
Date: Thu, 11 Jun 2009 16:10:55 +0800
Message-ID: <4A30BC0F.3000401__16812.1670991697$1244708012$gmane$org@cn.fujitsu.com>
References: <1244513342-11758-1-git-send-email-vgoyal@redhat.com>
	<1244513342-11758-11-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1244513342-11758-11-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
>  
>  /*
> @@ -1296,6 +1302,13 @@ void io_group_chain_link(struct request_queue *q, void *key,
>  		iog = io_cgroup_lookup_group(iocg, key);
>  		io_group_set_parent(prev, iog);
>  	}
> +
> +	if (unlikely(efqd->only_root_group))
> +		/*
> +		 * TODO: Take care of force expiry of existing queue before
> +		 * new queue is queued.
> +		 */
> +		efqd->only_root_group = 0;

  Hi Vivek,

  This flag isn't set back when all child groups go away. Am i missing something?
  BTW, why not just determine "only root group" by cgroup itself? Although there might be 
  some impact if cgroup is built but no request goes into it. but i think this isn't a big
  deal. How about the following patch?

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/elevator-fq.c |   21 ++++++++++-----------
 block/elevator-fq.h |    1 -
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index a516dce..f33155c 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -76,7 +76,6 @@ void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq,
 void elv_activate_ioq(struct io_queue *ioq, int add_front);
 void elv_deactivate_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
 					int requeue);
-
 static int bfq_update_next_active(struct io_sched_data *sd)
 {
 	struct io_group *iog;
@@ -1131,6 +1130,14 @@ struct io_cgroup io_root_cgroup = {
 	.ioprio_class = IO_DEFAULT_GRP_CLASS,
 };
 
+static int is_only_root_group(void)
+{
+	if (list_empty(&io_root_cgroup.css.cgroup->children))
+		return 1;
+
+	return 0;
+}
+
 void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
 {
 	entity->ioprio = entity->new_ioprio;
@@ -1543,13 +1550,6 @@ void io_group_chain_link(struct request_queue *q, void *key,
 		iog = io_cgroup_lookup_group(iocg, key);
 		io_group_set_parent(prev, iog);
 	}
-
-	if (unlikely(efqd->only_root_group))
-		/*
-		 * TODO: Take care of force expiry of existing queue before
-		 * new queue is queued.
-		 */
-		efqd->only_root_group = 0;
 }
 
 /**
@@ -3601,7 +3601,7 @@ void *elv_fq_select_ioq(struct request_queue *q, int force)
 	 * overhead.
 	 */
 
-	if (efqd->only_root_group && elv_iosched_single_ioq(q->elevator)) {
+	if (is_only_root_group() && elv_iosched_single_ioq(q->elevator)) {
 		elv_log_ioq(efqd, ioq, "select: only root group, no expiry");
 		goto keep_queue;
 	}
@@ -3872,7 +3872,7 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 		 * unnecessary overhead.
 		 */
 
-		if (efqd->only_root_group &&
+		if (is_only_root_group() &&
 			elv_iosched_single_ioq(q->elevator)) {
 			elv_log_ioq(efqd, ioq, "select: only root group,"
 					" no expiry");
@@ -4019,7 +4019,6 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 
 	/* For the time being keep fairness enabled by default */
 	efqd->fairness = 1;
-	efqd->only_root_group = 1;
 	return 0;
 }
 
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 1b1fb0b..0939735 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -368,7 +368,6 @@ struct elv_fq_data {
 	 * queues.
 	 */
 	unsigned int fairness;
-	int only_root_group;
 };
 
 extern int elv_slice_idle;
-- 
1.5.4.rc3
