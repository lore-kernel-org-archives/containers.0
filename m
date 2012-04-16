From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/6] blkcg: remove blkio_group->path[]
Date: Mon, 16 Apr 2012 13:57:23 -0700
Message-ID: <1334609847-12747-3-git-send-email-tj__16330.0378052101$1334609877$gmane$org@kernel.org>
References: <1334609847-12747-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1334609847-12747-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

blkio_group->path[] stores the path of the associated cgroup and is
used only for debug messages.  Just format the path from blkg->cgroup
when printing debug messages.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c   |    1 -
 block/blk-cgroup.h   |   21 +++++++++++++++++----
 block/blk-throttle.c |    9 ++++++---
 block/cfq-iosched.c  |   21 ++++++++++++++-------
 4 files changed, 37 insertions(+), 15 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index b1807d4..6333702 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -114,7 +114,6 @@ static struct blkio_group *blkg_alloc(struct blkio_cgroup *blkcg,
 	INIT_LIST_HEAD(&blkg->q_node);
 	blkg->blkcg = blkcg;
 	blkg->refcnt = 1;
-	cgroup_path(blkcg->css.cgroup, blkg->path, sizeof(blkg->path));
 
 	for (i = 0; i < BLKCG_MAX_POLS; i++) {
 		struct blkio_policy_type *pol = blkio_policy[i];
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index ef6550a..c524267 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -77,8 +77,6 @@ struct blkio_group {
 	struct list_head q_node;
 	struct hlist_node blkcg_node;
 	struct blkio_cgroup *blkcg;
-	/* Store cgroup path */
-	char path[128];
 	/* reference count */
 	int refcnt;
 
@@ -167,9 +165,24 @@ static inline struct blkio_group *pdata_to_blkg(void *pdata)
 	return NULL;
 }
 
-static inline char *blkg_path(struct blkio_group *blkg)
+/**
+ * blkg_path - format cgroup path of blkg
+ * @blkg: blkg of interest
+ * @buf: target buffer
+ * @buflen: target buffer length
+ *
+ * Format the path of the cgroup of @blkg into @buf.
+ */
+static inline int blkg_path(struct blkio_group *blkg, char *buf, int buflen)
 {
-	return blkg->path;
+	int ret;
+
+	rcu_read_lock();
+	ret = cgroup_path(blkg->blkcg->css.cgroup, buf, buflen);
+	rcu_read_unlock();
+	if (ret)
+		strncpy(buf, "<unavailable>", buflen);
+	return ret;
 }
 
 /**
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index e2aaf27..e9b7a47 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -155,9 +155,12 @@ static inline int throtl_tg_##name(const struct throtl_grp *tg)		\
 
 THROTL_TG_FNS(on_rr);
 
-#define throtl_log_tg(td, tg, fmt, args...)				\
-	blk_add_trace_msg((td)->queue, "throtl %s " fmt,		\
-			  blkg_path(tg_to_blkg(tg)), ##args);		\
+#define throtl_log_tg(td, tg, fmt, args...)	do {			\
+	char __pbuf[128];						\
+									\
+	blkg_path(tg_to_blkg(tg), __pbuf, sizeof(__pbuf));		\
+	blk_add_trace_msg((td)->queue, "throtl %s " fmt, __pbuf, ##args); \
+} while (0)
 
 #define throtl_log(td, fmt, args...)	\
 	blk_add_trace_msg((td)->queue, "throtl " fmt, ##args)
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index eb07eb6..901286b 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -573,14 +573,21 @@ static inline void cfqg_put(struct cfq_group *cfqg)
 	return blkg_put(cfqg_to_blkg(cfqg));
 }
 
-#define cfq_log_cfqq(cfqd, cfqq, fmt, args...)	\
+#define cfq_log_cfqq(cfqd, cfqq, fmt, args...)	do {			\
+	char __pbuf[128];						\
+									\
+	blkg_path(cfqg_to_blkg((cfqq)->cfqg), __pbuf, sizeof(__pbuf));	\
 	blk_add_trace_msg((cfqd)->queue, "cfq%d%c %s " fmt, (cfqq)->pid, \
-			cfq_cfqq_sync((cfqq)) ? 'S' : 'A', \
-			blkg_path(cfqg_to_blkg((cfqq)->cfqg)), ##args)
-
-#define cfq_log_cfqg(cfqd, cfqg, fmt, args...)				\
-	blk_add_trace_msg((cfqd)->queue, "%s " fmt,			\
-			blkg_path(cfqg_to_blkg((cfqg))), ##args)	\
+			  cfq_cfqq_sync((cfqq)) ? 'S' : 'A',		\
+			  __pbuf, ##args);				\
+} while (0)
+
+#define cfq_log_cfqg(cfqd, cfqg, fmt, args...)	do {			\
+	char __pbuf[128];						\
+									\
+	blkg_path(cfqg_to_blkg(cfqg), __pbuf, sizeof(__pbuf));		\
+	blk_add_trace_msg((cfqd)->queue, "%s " fmt, __pbuf, ##args);	\
+} while (0)
 
 static inline void cfqg_stats_update_io_add(struct cfq_group *cfqg,
 					    struct cfq_group *curr_cfqg, int rw)
-- 
1.7.7.3
