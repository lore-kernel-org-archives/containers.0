From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 6/8] blkcg: add request_queue->root_blkg
Date: Thu, 12 Apr 2012 16:29:38 -0700
Message-ID: <1334273380-30233-7-git-send-email-tj__2031.53093248165$1334273432$gmane$org@kernel.org>
References: <1334273380-30233-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1334273380-30233-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

With per-queue policy activation, root blkg creation will be moved to
blkcg core.  Add q->root_blkg in preparation.  For blk-throtl, this
replaces throtl_data->root_tg; however, cfq needs to keep
cfqd->root_group for !CONFIG_CFQ_GROUP_IOSCHED.

This is to prepare for per-queue policy activation and doesn't cause
any functional difference.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-throttle.c   |   16 ++++++++++------
 block/cfq-iosched.c    |    4 +++-
 include/linux/blkdev.h |    2 ++
 3 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 6f1bfdf..8c520fa 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -97,7 +97,6 @@ struct throtl_data
 	/* service tree for active throtl groups */
 	struct throtl_rb_root tg_service_tree;
 
-	struct throtl_grp *root_tg;
 	struct request_queue *queue;
 
 	/* Total Number of queued bios on READ and WRITE lists */
@@ -131,6 +130,11 @@ static inline struct blkio_group *tg_to_blkg(struct throtl_grp *tg)
 	return pdata_to_blkg(tg);
 }
 
+static inline struct throtl_grp *td_root_tg(struct throtl_data *td)
+{
+	return blkg_to_tg(td->queue->root_blkg);
+}
+
 enum tg_state_flags {
 	THROTL_TG_FLAG_on_rr = 0,	/* on round-robin busy list */
 };
@@ -261,7 +265,7 @@ throtl_grp *throtl_lookup_tg(struct throtl_data *td, struct blkio_cgroup *blkcg)
 	 * Avoid lookup in this case
 	 */
 	if (blkcg == &blkio_root_cgroup)
-		return td->root_tg;
+		return td_root_tg(td);
 
 	return blkg_to_tg(blkg_lookup(blkcg, td->queue));
 }
@@ -277,7 +281,7 @@ static struct throtl_grp *throtl_lookup_create_tg(struct throtl_data *td,
 	 * Avoid lookup in this case
 	 */
 	if (blkcg == &blkio_root_cgroup) {
-		tg = td->root_tg;
+		tg = td_root_tg(td);
 	} else {
 		struct blkio_group *blkg;
 
@@ -287,7 +291,7 @@ static struct throtl_grp *throtl_lookup_create_tg(struct throtl_data *td,
 		if (!IS_ERR(blkg))
 			tg = blkg_to_tg(blkg);
 		else if (!blk_queue_dead(q))
-			tg = td->root_tg;
+			tg = td_root_tg(td);
 	}
 
 	return tg;
@@ -1245,12 +1249,12 @@ int blk_throtl_init(struct request_queue *q)
 
 	blkg = blkg_lookup_create(&blkio_root_cgroup, q, true);
 	if (!IS_ERR(blkg))
-		td->root_tg = blkg_to_tg(blkg);
+		q->root_blkg = blkg;
 
 	spin_unlock_irq(q->queue_lock);
 	rcu_read_unlock();
 
-	if (!td->root_tg) {
+	if (!q->root_blkg) {
 		kfree(td);
 		return -ENOMEM;
 	}
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 761a376..b70425f 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -3965,8 +3965,10 @@ static int cfq_init_queue(struct request_queue *q)
 	spin_lock_irq(q->queue_lock);
 
 	blkg = blkg_lookup_create(&blkio_root_cgroup, q, true);
-	if (!IS_ERR(blkg))
+	if (!IS_ERR(blkg)) {
+		q->root_blkg = blkg;
 		cfqd->root_group = blkg_to_cfqg(blkg);
+	}
 
 	spin_unlock_irq(q->queue_lock);
 	rcu_read_unlock();
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index d2c69f8..b01c377 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -31,6 +31,7 @@ struct blk_trace;
 struct request;
 struct sg_io_hdr;
 struct bsg_job;
+struct blkio_group;
 
 #define BLKDEV_MIN_RQ	4
 #define BLKDEV_MAX_RQ	128	/* Default maximum */
@@ -369,6 +370,7 @@ struct request_queue {
 
 	struct list_head	icq_list;
 #ifdef CONFIG_BLK_CGROUP
+	struct blkio_group	*root_blkg;
 	struct list_head	blkg_list;
 #endif
 
-- 
1.7.7.3
