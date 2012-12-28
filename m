From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 14/24] cfq-iosched: convert cfq_group_slice() to use
	cfqg->vfraction
Date: Fri, 28 Dec 2012 12:35:36 -0800
Message-ID: <1356726946-26037-15-git-send-email-tj__23367.1947884888$1356727089$gmane$org@kernel.org>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1356726946-26037-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cfq_group_slice() calculates slice by taking a fraction of
cfq_target_latency according to the ratio of cfqg->weight against
service_tree->total_weight.  This currently works only because all
cfqgs are treated to be at the same level.

To prepare for proper hierarchy support, convert cfq_group_slice() to
base the calculation on cfqg->vfraction.  As cfqg->vfraction is always
a fraction of 1 and represents the fraction allocated to the cfqg with
hierarchy considered, the slice can be simply calculated by
multiplying cfqg->vfraction to cfq_target_latency (with fixed point
shift factored in).

As vfraction calculation currently treats all non-root cfqgs as
children of the root cfqg, this patch doesn't introduce noticeable
behavior difference.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/cfq-iosched.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index b24acf6..ee34282 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -85,7 +85,6 @@ struct cfq_rb_root {
 	struct rb_root rb;
 	struct rb_node *left;
 	unsigned count;
-	unsigned total_weight;
 	u64 min_vdisktime;
 	struct cfq_ttime ttime;
 };
@@ -979,9 +978,7 @@ static inline unsigned cfq_group_get_avg_queues(struct cfq_data *cfqd,
 static inline unsigned
 cfq_group_slice(struct cfq_data *cfqd, struct cfq_group *cfqg)
 {
-	struct cfq_rb_root *st = &cfqd->grp_service_tree;
-
-	return cfqd->cfq_target_latency * cfqg->weight / st->total_weight;
+	return cfqd->cfq_target_latency * cfqg->vfraction >> CFQ_SERVICE_SHIFT;
 }
 
 static inline unsigned
@@ -1273,7 +1270,6 @@ cfq_group_service_tree_add(struct cfq_rb_root *st, struct cfq_group *cfqg)
 
 	cfq_update_group_weight(cfqg);
 	__cfq_group_service_tree_add(st, cfqg);
-	st->total_weight += cfqg->weight;
 
 	/*
 	 * Activate @cfqg and calculate the portion of vfraction @cfqg is
@@ -1360,7 +1356,6 @@ cfq_group_service_tree_del(struct cfq_rb_root *st, struct cfq_group *cfqg)
 	}
 
 	/* remove from the service tree */
-	st->total_weight -= cfqg->weight;
 	if (!RB_EMPTY_NODE(&cfqg->rb_node))
 		cfq_rb_erase(&cfqg->rb_node, st);
 }
-- 
1.8.0.2
