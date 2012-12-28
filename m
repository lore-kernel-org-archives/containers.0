From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 22/24] cfq-iosched: separate out cfqg_stats_reset() from
	cfq_pd_reset_stats()
Date: Fri, 28 Dec 2012 12:35:44 -0800
Message-ID: <1356726946-26037-23-git-send-email-tj__46477.0790226341$1356727141$gmane$org@kernel.org>
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

Separate out cfqg_stats_reset() which takes struct cfqg_stats * from
cfq_pd_reset_stats() and move the latter to where other pd methods are
defined.  cfqg_stats_reset() will be used to implement hierarchical
stats.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/cfq-iosched.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index d43145cc..f8b34bb 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -688,11 +688,9 @@ static inline void cfqg_stats_update_completion(struct cfq_group *cfqg,
 				io_start_time - start_time);
 }
 
-static void cfq_pd_reset_stats(struct blkcg_gq *blkg)
+/* @stats = 0 */
+static void cfqg_stats_reset(struct cfqg_stats *stats)
 {
-	struct cfq_group *cfqg = blkg_to_cfqg(blkg);
-	struct cfqg_stats *stats = &cfqg->stats;
-
 	/* queued stats shouldn't be cleared */
 	blkg_rwstat_reset(&stats->service_bytes);
 	blkg_rwstat_reset(&stats->serviced);
@@ -1477,6 +1475,13 @@ static void cfq_pd_init(struct blkcg_gq *blkg)
 	cfqg->leaf_weight = blkg->blkcg->cfq_leaf_weight;
 }
 
+static void cfq_pd_reset_stats(struct blkcg_gq *blkg)
+{
+	struct cfq_group *cfqg = blkg_to_cfqg(blkg);
+
+	cfqg_stats_reset(&cfqg->stats);
+}
+
 /*
  * Search for the cfq group current task belongs to. request_queue lock must
  * be held.
-- 
1.8.0.2
