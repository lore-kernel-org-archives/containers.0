From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/6] blkcg: style cleanups for blk-cgroup.h
Date: Mon, 16 Apr 2012 13:57:24 -0700
Message-ID: <1334609847-12747-4-git-send-email-tj__15802.5111807094$1334609882$gmane$org@kernel.org>
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

* Update indentation on struct field declarations.

* Uniformly don't use "extern" on function declarations.

* Merge the two #ifdef CONFIG_BLK_CGROUP blocks.

All changes in this patch are cosmetic.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.h |  108 +++++++++++++++++++++++++---------------------------
 1 files changed, 52 insertions(+), 56 deletions(-)

diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index c524267..b347aa0 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -38,15 +38,15 @@ enum blkg_rwstat_type {
 };
 
 struct blkio_cgroup {
-	struct cgroup_subsys_state css;
-	spinlock_t lock;
-	struct hlist_head blkg_list;
+	struct cgroup_subsys_state	css;
+	spinlock_t			lock;
+	struct hlist_head		blkg_list;
 
 	/* for policies to test whether associated blkcg has changed */
-	uint64_t id;
+	uint64_t			id;
 
 	/* TODO: per-policy storage in blkio_cgroup */
-	unsigned int cfq_weight;	/* belongs to cfq */
+	unsigned int			cfq_weight;	/* belongs to cfq */
 };
 
 struct blkg_stat {
@@ -62,27 +62,27 @@ struct blkg_rwstat {
 /* per-blkg per-policy data */
 struct blkg_policy_data {
 	/* the blkg this per-policy data belongs to */
-	struct blkio_group *blkg;
+	struct blkio_group		*blkg;
 
 	/* used during policy activation */
-	struct list_head alloc_node;
+	struct list_head		alloc_node;
 
 	/* pol->pdata_size bytes of private data used by policy impl */
-	char pdata[] __aligned(__alignof__(unsigned long long));
+	char				pdata[] __aligned(__alignof__(unsigned long long));
 };
 
 struct blkio_group {
 	/* Pointer to the associated request_queue */
-	struct request_queue *q;
-	struct list_head q_node;
-	struct hlist_node blkcg_node;
-	struct blkio_cgroup *blkcg;
+	struct request_queue		*q;
+	struct list_head		q_node;
+	struct hlist_node		blkcg_node;
+	struct blkio_cgroup		*blkcg;
 	/* reference count */
-	int refcnt;
+	int				refcnt;
 
-	struct blkg_policy_data *pd[BLKCG_MAX_POLS];
+	struct blkg_policy_data		*pd[BLKCG_MAX_POLS];
 
-	struct rcu_head rcu_head;
+	struct rcu_head			rcu_head;
 };
 
 typedef void (blkio_init_group_fn)(struct blkio_group *blkg);
@@ -90,29 +90,39 @@ typedef void (blkio_exit_group_fn)(struct blkio_group *blkg);
 typedef void (blkio_reset_group_stats_fn)(struct blkio_group *blkg);
 
 struct blkio_policy_ops {
-	blkio_init_group_fn *blkio_init_group_fn;
-	blkio_exit_group_fn *blkio_exit_group_fn;
-	blkio_reset_group_stats_fn *blkio_reset_group_stats_fn;
+	blkio_init_group_fn		*blkio_init_group_fn;
+	blkio_exit_group_fn		*blkio_exit_group_fn;
+	blkio_reset_group_stats_fn	*blkio_reset_group_stats_fn;
 };
 
 struct blkio_policy_type {
-	struct blkio_policy_ops ops;
-	int plid;
-	size_t pdata_size;		/* policy specific private data size */
-	struct cftype *cftypes;		/* cgroup files for the policy */
+	struct blkio_policy_ops		ops;
+	int				plid;
+	/* policy specific private data size */
+	size_t				pdata_size;
+	/* cgroup files for the policy */
+	struct cftype			*cftypes;
 };
 
-extern int blkcg_init_queue(struct request_queue *q);
-extern void blkcg_drain_queue(struct request_queue *q);
-extern void blkcg_exit_queue(struct request_queue *q);
+extern struct blkio_cgroup blkio_root_cgroup;
+
+struct blkio_cgroup *cgroup_to_blkio_cgroup(struct cgroup *cgroup);
+struct blkio_cgroup *bio_blkio_cgroup(struct bio *bio);
+struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg,
+				struct request_queue *q);
+struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
+				       struct request_queue *q);
+int blkcg_init_queue(struct request_queue *q);
+void blkcg_drain_queue(struct request_queue *q);
+void blkcg_exit_queue(struct request_queue *q);
 
 /* Blkio controller policy registration */
-extern int blkio_policy_register(struct blkio_policy_type *);
-extern void blkio_policy_unregister(struct blkio_policy_type *);
-extern int blkcg_activate_policy(struct request_queue *q,
-				 const struct blkio_policy_type *pol);
-extern void blkcg_deactivate_policy(struct request_queue *q,
-				    const struct blkio_policy_type *pol);
+int blkio_policy_register(struct blkio_policy_type *);
+void blkio_policy_unregister(struct blkio_policy_type *);
+int blkcg_activate_policy(struct request_queue *q,
+			  const struct blkio_policy_type *pol);
+void blkcg_deactivate_policy(struct request_queue *q,
+			     const struct blkio_policy_type *pol);
 
 void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
 		       u64 (*prfill)(struct seq_file *, void *, int),
@@ -125,9 +135,9 @@ u64 blkg_prfill_stat(struct seq_file *sf, void *pdata, int off);
 u64 blkg_prfill_rwstat(struct seq_file *sf, void *pdata, int off);
 
 struct blkg_conf_ctx {
-	struct gendisk		*disk;
-	struct blkio_group	*blkg;
-	u64			v;
+	struct gendisk			*disk;
+	struct blkio_group		*blkg;
+	u64				v;
 };
 
 int blkg_conf_prep(struct blkio_cgroup *blkcg,
@@ -329,7 +339,9 @@ static inline void blkg_rwstat_reset(struct blkg_rwstat *rwstat)
 	memset(rwstat->cnt, 0, sizeof(rwstat->cnt));
 }
 
-#else
+#else	/* CONFIG_BLK_CGROUP */
+
+struct cgroup;
 
 struct blkio_group {
 };
@@ -337,6 +349,9 @@ struct blkio_group {
 struct blkio_policy_type {
 };
 
+static inline struct blkio_cgroup *cgroup_to_blkio_cgroup(struct cgroup *cgroup) { return NULL; }
+static inline struct blkio_cgroup *bio_blkio_cgroup(struct bio *bio) { return NULL; }
+static inline struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg, void *key) { return NULL; }
 static inline int blkcg_init_queue(struct request_queue *q) { return 0; }
 static inline void blkcg_drain_queue(struct request_queue *q) { }
 static inline void blkcg_exit_queue(struct request_queue *q) { }
@@ -355,24 +370,5 @@ static inline char *blkg_path(struct blkio_group *blkg) { return NULL; }
 static inline void blkg_get(struct blkio_group *blkg) { }
 static inline void blkg_put(struct blkio_group *blkg) { }
 
-#endif
-
-#ifdef CONFIG_BLK_CGROUP
-extern struct blkio_cgroup blkio_root_cgroup;
-extern struct blkio_cgroup *cgroup_to_blkio_cgroup(struct cgroup *cgroup);
-extern struct blkio_cgroup *bio_blkio_cgroup(struct bio *bio);
-extern struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg,
-				       struct request_queue *q);
-struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
-				       struct request_queue *q);
-#else
-struct cgroup;
-static inline struct blkio_cgroup *
-cgroup_to_blkio_cgroup(struct cgroup *cgroup) { return NULL; }
-static inline struct blkio_cgroup *
-bio_blkio_cgroup(struct bio *bio) { return NULL; }
-
-static inline struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg,
-					      void *key) { return NULL; }
-#endif
-#endif /* _BLK_CGROUP_H */
+#endif	/* CONFIG_BLK_CGROUP */
+#endif	/* _BLK_CGROUP_H */
-- 
1.7.7.3
