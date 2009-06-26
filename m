From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 1/2] io-controller: Prepare a rt ioq list in efqd to keep
	track of busy rt ioqs
Date: Fri, 26 Jun 2009 16:13:31 +0800
Message-ID: <4A44832B.1020108__2681.72282162613$1246004197$gmane$org@cn.fujitsu.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<1245443858-8487-21-git-send-email-vgoyal@redhat.com>
	<4A3F3648.7080007@cn.fujitsu.com>
	<20090622172123.GE15600@redhat.com>
	<4A4079B8.4020402@cn.fujitsu.com>
	<20090623140250.GA4262@redhat.com>
	<4A41EFE1.5050101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A41EFE1.5050101-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

Maintain a busy rt ioq list in efqd so that we can easily
keep track of all busy rt ioqs in system.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/elevator-fq.c |    8 ++++++++
 block/elevator-fq.h |    6 ++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index d779282..1d4ec1f 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -3247,6 +3247,10 @@ void elv_add_ioq_busy(struct elv_fq_data *efqd, struct io_queue *ioq)
 	if (elv_ioq_class_rt(ioq)) {
 		struct io_group *iog = ioq_to_io_group(ioq);
 		iog->busy_rt_queues++;
+
+		/* queue lock has been already held by caller */
+		hlist_add_head_rcu(&ioq->rt_node,
+				   &ioq->efqd->rt_ioq_list);
 	}
 
 #ifdef CONFIG_DEBUG_GROUP_IOSCHED
@@ -3293,6 +3297,9 @@ void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq,
 	if (elv_ioq_class_rt(ioq)) {
 		struct io_group *iog = ioq_to_io_group(ioq);
 		iog->busy_rt_queues--;
+
+		/* queue lock has been already held by caller */
+		hlist_del_rcu(&ioq->rt_node);
 	}
 
 	elv_deactivate_ioq(efqd, ioq, requeue);
@@ -4196,6 +4203,7 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 
 	INIT_WORK(&efqd->unplug_work, elv_kick_queue);
 	INIT_HLIST_HEAD(&efqd->group_list);
+	INIT_HLIST_HEAD(&efqd->rt_ioq_list);
 
 	efqd->elv_slice[0] = elv_slice_async;
 	efqd->elv_slice[1] = elv_slice_sync;
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index b3193f8..53a64b6 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -169,6 +169,9 @@ struct io_queue {
 	atomic_t ref;
 	unsigned int flags;
 
+	/* node to insert into efqd->rt_ioq_list */
+	struct hlist_node rt_node;
+
 	/* Pointer to generic elevator data structure */
 	struct elv_fq_data *efqd;
 	pid_t pid;
@@ -336,6 +339,9 @@ struct elv_fq_data {
 	/* List of io groups hanging on this elevator */
 	struct hlist_head group_list;
 
+	/* List of rt ioqs in hierarchy*/
+	struct hlist_head rt_ioq_list;
+
 	struct request_queue *queue;
 	unsigned int busy_queues;
 
-- 
1.5.4.rc3
