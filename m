From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 12/31] blk-throttle: simplify throtl_grp flag handling
Date: Wed,  1 May 2013 17:39:30 -0700
Message-ID: <1367455189-6957-13-git-send-email-tj@kernel.org>
References: <1367455189-6957-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1367455189-6957-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

blk-throttle is still using function-defining macros to define flag
handling functions, which went out style at least a decade ago.

Just define the flag as bitmask and use direct bit operations.

This patch doesn't make any functional changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 34 +++++++++-------------------------
 1 file changed, 9 insertions(+), 25 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 6723ca2..fc55dda 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -36,6 +36,10 @@ struct throtl_service_queue {
 #define THROTL_SERVICE_QUEUE_INITIALIZER				\
 	(struct throtl_service_queue){ .pending_tree = RB_ROOT }
 
+enum tg_state_flags {
+	THROTL_TG_PENDING	= 1 << 0,	/* on parent's pending tree */
+};
+
 #define rb_entry_tg(node)	rb_entry((node), struct throtl_grp, rb_node)
 
 /* Per-cpu group stats */
@@ -136,26 +140,6 @@ static inline struct throtl_grp *td_root_tg(struct throtl_data *td)
 	return blkg_to_tg(td->queue->root_blkg);
 }
 
-enum tg_state_flags {
-	THROTL_TG_FLAG_on_rr = 0,	/* on round-robin busy list */
-};
-
-#define THROTL_TG_FNS(name)						\
-static inline void throtl_mark_tg_##name(struct throtl_grp *tg)		\
-{									\
-	(tg)->flags |= (1 << THROTL_TG_FLAG_##name);			\
-}									\
-static inline void throtl_clear_tg_##name(struct throtl_grp *tg)	\
-{									\
-	(tg)->flags &= ~(1 << THROTL_TG_FLAG_##name);			\
-}									\
-static inline int throtl_tg_##name(const struct throtl_grp *tg)		\
-{									\
-	return ((tg)->flags & (1 << THROTL_TG_FLAG_##name)) != 0;	\
-}
-
-THROTL_TG_FNS(on_rr);
-
 #define throtl_log_tg(td, tg, fmt, args...)	do {			\
 	char __pbuf[128];						\
 									\
@@ -369,25 +353,25 @@ static void __throtl_enqueue_tg(struct throtl_data *td, struct throtl_grp *tg)
 	struct throtl_service_queue *sq = &td->service_queue;
 
 	tg_service_queue_add(sq, tg);
-	throtl_mark_tg_on_rr(tg);
+	tg->flags |= THROTL_TG_PENDING;
 	sq->nr_pending++;
 }
 
 static void throtl_enqueue_tg(struct throtl_data *td, struct throtl_grp *tg)
 {
-	if (!throtl_tg_on_rr(tg))
+	if (!(tg->flags & THROTL_TG_PENDING))
 		__throtl_enqueue_tg(td, tg);
 }
 
 static void __throtl_dequeue_tg(struct throtl_data *td, struct throtl_grp *tg)
 {
 	throtl_rb_erase(&tg->rb_node, &td->service_queue);
-	throtl_clear_tg_on_rr(tg);
+	tg->flags &= ~THROTL_TG_PENDING;
 }
 
 static void throtl_dequeue_tg(struct throtl_data *td, struct throtl_grp *tg)
 {
-	if (throtl_tg_on_rr(tg))
+	if (tg->flags & THROTL_TG_PENDING)
 		__throtl_dequeue_tg(td, tg);
 }
 
@@ -964,7 +948,7 @@ static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
 	throtl_start_new_slice(td, tg, 0);
 	throtl_start_new_slice(td, tg, 1);
 
-	if (throtl_tg_on_rr(tg)) {
+	if (tg->flags & THROTL_TG_PENDING) {
 		tg_update_disptime(td, tg);
 		throtl_schedule_next_dispatch(td);
 	}
-- 
1.8.1.4
