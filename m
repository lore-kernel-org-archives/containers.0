From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 03/10] mempool: add @gfp_mask to mempool_create_node()
Date: Mon,  4 Jun 2012 20:40:53 -0700
Message-ID: <1338867660-4689-4-git-send-email-tj@kernel.org>
References: <1338867660-4689-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1338867660-4689-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

mempool_create_node() currently assumes %GFP_KERNEL.  Its only user,
blk_init_free_list(), is about to be updated to use other allocation
flags - add @gfp_mask argument to the function.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 block/blk-core.c        |    4 ++--
 include/linux/mempool.h |    3 ++-
 mm/mempool.c            |   12 +++++++-----
 3 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 3c923a7..7465d89 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -518,8 +518,8 @@ static int blk_init_free_list(struct request_queue *q)
 	init_waitqueue_head(&rl->wait[BLK_RW_ASYNC]);
 
 	rl->rq_pool = mempool_create_node(BLKDEV_MIN_RQ, mempool_alloc_slab,
-				mempool_free_slab, request_cachep, q->node);
-
+					  mempool_free_slab, request_cachep,
+					  GFP_KERNEL, q->node);
 	if (!rl->rq_pool)
 		return -ENOMEM;
 
diff --git a/include/linux/mempool.h b/include/linux/mempool.h
index 7c08052..39ed62a 100644
--- a/include/linux/mempool.h
+++ b/include/linux/mempool.h
@@ -26,7 +26,8 @@ typedef struct mempool_s {
 extern mempool_t *mempool_create(int min_nr, mempool_alloc_t *alloc_fn,
 			mempool_free_t *free_fn, void *pool_data);
 extern mempool_t *mempool_create_node(int min_nr, mempool_alloc_t *alloc_fn,
-			mempool_free_t *free_fn, void *pool_data, int nid);
+			mempool_free_t *free_fn, void *pool_data,
+			gfp_t gfp_mask, int nid);
 
 extern int mempool_resize(mempool_t *pool, int new_min_nr, gfp_t gfp_mask);
 extern void mempool_destroy(mempool_t *pool);
diff --git a/mm/mempool.c b/mm/mempool.c
index d904981..5499047 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -63,19 +63,21 @@ EXPORT_SYMBOL(mempool_destroy);
 mempool_t *mempool_create(int min_nr, mempool_alloc_t *alloc_fn,
 				mempool_free_t *free_fn, void *pool_data)
 {
-	return  mempool_create_node(min_nr,alloc_fn,free_fn, pool_data,-1);
+	return mempool_create_node(min_nr,alloc_fn,free_fn, pool_data,
+				   GFP_KERNEL, NUMA_NO_NODE);
 }
 EXPORT_SYMBOL(mempool_create);
 
 mempool_t *mempool_create_node(int min_nr, mempool_alloc_t *alloc_fn,
-			mempool_free_t *free_fn, void *pool_data, int node_id)
+			       mempool_free_t *free_fn, void *pool_data,
+			       gfp_t gfp_mask, int node_id)
 {
 	mempool_t *pool;
-	pool = kmalloc_node(sizeof(*pool), GFP_KERNEL | __GFP_ZERO, node_id);
+	pool = kmalloc_node(sizeof(*pool), gfp_mask | __GFP_ZERO, node_id);
 	if (!pool)
 		return NULL;
 	pool->elements = kmalloc_node(min_nr * sizeof(void *),
-					GFP_KERNEL, node_id);
+				      gfp_mask, node_id);
 	if (!pool->elements) {
 		kfree(pool);
 		return NULL;
@@ -93,7 +95,7 @@ mempool_t *mempool_create_node(int min_nr, mempool_alloc_t *alloc_fn,
 	while (pool->curr_nr < pool->min_nr) {
 		void *element;
 
-		element = pool->alloc(GFP_KERNEL, pool->pool_data);
+		element = pool->alloc(gfp_mask, pool->pool_data);
 		if (unlikely(!element)) {
 			mempool_destroy(pool);
 			return NULL;
-- 
1.7.7.3
