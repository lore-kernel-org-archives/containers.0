From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 01/21] blkcg: remove unused @pol and @plid parameters
Date: Wed, 28 Mar 2012 15:51:11 -0700
Message-ID: <1332975091-10950-2-git-send-email-tj__1012.38460415534$1332975114$gmane$org@kernel.org>
References: <1332975091-10950-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1332975091-10950-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

@pol to blkg_to_pdata() and @plid to blkg_lookup_create() are no
longer necessary.  Drop them.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c   |    3 +--
 block/blk-cgroup.h   |    8 ++------
 block/blk-throttle.c |    7 +++----
 block/cfq-iosched.c  |    7 +++----
 4 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 7947e17..d4cf77d 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -568,7 +568,6 @@ static struct blkio_group *blkg_alloc(struct blkio_cgroup *blkcg,
 
 struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
 				       struct request_queue *q,
-				       enum blkio_policy_id plid,
 				       bool for_root)
 	__releases(q->queue_lock) __acquires(q->queue_lock)
 {
@@ -1027,7 +1026,7 @@ static int blkio_policy_parse_and_set(char *buf, enum blkio_policy_id plid,
 	rcu_read_lock();
 
 	spin_lock_irq(disk->queue->queue_lock);
-	blkg = blkg_lookup_create(blkcg, disk->queue, plid, false);
+	blkg = blkg_lookup_create(blkcg, disk->queue, false);
 	spin_unlock_irq(disk->queue->queue_lock);
 
 	if (IS_ERR(blkg)) {
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 1cb8f76..1add3dc 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -266,13 +266,10 @@ static inline void *blkg_to_pdata(struct blkio_group *blkg,
 /**
  * pdata_to_blkg - get blkg associated with policy private data
  * @pdata: policy private data of interest
- * @pol: policy @pdata is for
  *
- * @pdata is policy private data for @pol.  Determine the blkg it's
- * associated with.
+ * @pdata is policy private data.  Determine the blkg it's associated with.
  */
-static inline struct blkio_group *pdata_to_blkg(void *pdata,
-						struct blkio_policy_type *pol)
+static inline struct blkio_group *pdata_to_blkg(void *pdata)
 {
 	if (pdata) {
 		struct blkg_policy_data *pd =
@@ -402,7 +399,6 @@ extern struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg,
 				       struct request_queue *q);
 struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
 				       struct request_queue *q,
-				       enum blkio_policy_id plid,
 				       bool for_root);
 void blkiocg_update_timeslice_used(struct blkio_group *blkg,
 				   struct blkio_policy_type *pol,
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 4ba1418..1cc6c23d 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -107,7 +107,7 @@ static inline struct throtl_grp *blkg_to_tg(struct blkio_group *blkg)
 
 static inline struct blkio_group *tg_to_blkg(struct throtl_grp *tg)
 {
-	return pdata_to_blkg(tg, &blkio_policy_throtl);
+	return pdata_to_blkg(tg);
 }
 
 enum tg_state_flags {
@@ -185,7 +185,7 @@ static struct throtl_grp *throtl_lookup_create_tg(struct throtl_data *td,
 	} else {
 		struct blkio_group *blkg;
 
-		blkg = blkg_lookup_create(blkcg, q, BLKIO_POLICY_THROTL, false);
+		blkg = blkg_lookup_create(blkcg, q, false);
 
 		/* if %NULL and @q is alive, fall back to root_tg */
 		if (!IS_ERR(blkg))
@@ -1033,8 +1033,7 @@ int blk_throtl_init(struct request_queue *q)
 	rcu_read_lock();
 	spin_lock_irq(q->queue_lock);
 
-	blkg = blkg_lookup_create(&blkio_root_cgroup, q, BLKIO_POLICY_THROTL,
-				  true);
+	blkg = blkg_lookup_create(&blkio_root_cgroup, q, true);
 	if (!IS_ERR(blkg))
 		td->root_tg = blkg_to_tg(blkg);
 
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 39c4330..8cca6161 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -374,7 +374,7 @@ static inline struct cfq_group *blkg_to_cfqg(struct blkio_group *blkg)
 
 static inline struct blkio_group *cfqg_to_blkg(struct cfq_group *cfqg)
 {
-	return pdata_to_blkg(cfqg, &blkio_policy_cfq);
+	return pdata_to_blkg(cfqg);
 }
 
 static inline void cfqg_get(struct cfq_group *cfqg)
@@ -1092,7 +1092,7 @@ static struct cfq_group *cfq_lookup_create_cfqg(struct cfq_data *cfqd,
 	} else {
 		struct blkio_group *blkg;
 
-		blkg = blkg_lookup_create(blkcg, q, BLKIO_POLICY_PROP, false);
+		blkg = blkg_lookup_create(blkcg, q, false);
 		if (!IS_ERR(blkg))
 			cfqg = blkg_to_cfqg(blkg);
 	}
@@ -3523,8 +3523,7 @@ static int cfq_init_queue(struct request_queue *q)
 	rcu_read_lock();
 	spin_lock_irq(q->queue_lock);
 
-	blkg = blkg_lookup_create(&blkio_root_cgroup, q, BLKIO_POLICY_PROP,
-				  true);
+	blkg = blkg_lookup_create(&blkio_root_cgroup, q, true);
 	if (!IS_ERR(blkg))
 		cfqd->root_group = blkg_to_cfqg(blkg);
 
-- 
1.7.7.3
