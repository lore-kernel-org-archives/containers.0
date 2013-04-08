From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v3 20/32] shrinker: Kill old ->shrink API.
Date: Mon,  8 Apr 2013 18:00:47 +0400
Message-ID: <1365429659-22108-21-git-send-email-glommer__24971.3064091795$1365438693$gmane$org@parallels.com>
References: <1365429659-22108-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1365429659-22108-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
Cc: hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

There are no more users of this API, so kill it dead, dead, dead and
quietly bury the corpse in a shallow, unmarked grave in a dark
forest deep in the hills...

[ glommer: added flowers to the grave ]
Signed-off-by: Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/linux/shrinker.h      | 15 +++++----------
 include/trace/events/vmscan.h |  4 ++--
 mm/vmscan.c                   | 40 ++++++++--------------------------------
 3 files changed, 15 insertions(+), 44 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index e71286f..d4636a0 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -7,14 +7,15 @@
  *
  * The 'gfpmask' refers to the allocation we are currently trying to
  * fulfil.
- *
- * Note that 'shrink' will be passed nr_to_scan == 0 when the VM is
- * querying the cache size, so a fastpath for that case is appropriate.
  */
 struct shrink_control {
 	gfp_t gfp_mask;
 
-	/* How many slab objects shrinker() should scan and try to reclaim */
+	/*
+	 * How many objects scan_objects should scan and try to reclaim.
+	 * This is reset before every call, so it is safe for callees
+	 * to modify.
+	 */
 	long nr_to_scan;
 
 	/* shrink from these nodes */
@@ -24,11 +25,6 @@ struct shrink_control {
 /*
  * A callback you can register to apply pressure to ageable caches.
  *
- * @shrink() should look through the least-recently-used 'nr_to_scan' entries
- * and attempt to free them up.  It should return the number of objects which
- * remain in the cache.  If it returns -1, it means it cannot do any scanning at
- * this time (eg. there is a risk of deadlock).
- *
  * @count_objects should return the number of freeable items in the cache. If
  * there are no objects to free or the number of freeable items cannot be
  * determined, it should return 0. No deadlock checks should be done during the
@@ -44,7 +40,6 @@ struct shrink_control {
  * @scan_objects will be made from the current reclaim context.
  */
 struct shrinker {
-	int (*shrink)(struct shrinker *, struct shrink_control *sc);
 	long (*count_objects)(struct shrinker *, struct shrink_control *sc);
 	long (*scan_objects)(struct shrinker *, struct shrink_control *sc);
 
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 63cfccc..132a985 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -202,7 +202,7 @@ TRACE_EVENT(mm_shrink_slab_start,
 
 	TP_fast_assign(
 		__entry->shr = shr;
-		__entry->shrink = shr->shrink;
+		__entry->shrink = shr->scan_objects;
 		__entry->nr_objects_to_shrink = nr_objects_to_shrink;
 		__entry->gfp_flags = sc->gfp_mask;
 		__entry->pgs_scanned = pgs_scanned;
@@ -241,7 +241,7 @@ TRACE_EVENT(mm_shrink_slab_end,
 
 	TP_fast_assign(
 		__entry->shr = shr;
-		__entry->shrink = shr->shrink;
+		__entry->shrink = shr->scan_objects;
 		__entry->unused_scan = unused_scan_cnt;
 		__entry->new_scan = new_scan_cnt;
 		__entry->retval = shrinker_retval;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6926e09..232dfcb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -176,14 +176,6 @@ void unregister_shrinker(struct shrinker *shrinker)
 }
 EXPORT_SYMBOL(unregister_shrinker);
 
-static inline int do_shrinker_shrink(struct shrinker *shrinker,
-				     struct shrink_control *sc,
-				     unsigned long nr_to_scan)
-{
-	sc->nr_to_scan = nr_to_scan;
-	return (*shrinker->shrink)(shrinker, sc);
-}
-
 #define SHRINK_BATCH 128
 /*
  * Call the shrink functions to age shrinkable caches
@@ -229,11 +221,8 @@ unsigned long shrink_slab(struct shrink_control *sc,
 		long batch_size = shrinker->batch ? shrinker->batch
 						  : SHRINK_BATCH;
 
-		if (shrinker->scan_objects) {
-			max_pass = shrinker->count_objects(shrinker, sc);
-			WARN_ON(max_pass < 0);
-		} else
-			max_pass = do_shrinker_shrink(shrinker, sc, 0);
+		max_pass = shrinker->count_objects(shrinker, sc);
+		WARN_ON(max_pass < 0);
 		if (max_pass <= 0)
 			continue;
 
@@ -252,7 +241,7 @@ unsigned long shrink_slab(struct shrink_control *sc,
 		if (total_scan < 0) {
 			printk(KERN_ERR
 			"shrink_slab: %pF negative objects to delete nr=%ld\n",
-			       shrinker->shrink, total_scan);
+			       shrinker->scan_objects, total_scan);
 			total_scan = max_pass;
 		}
 
@@ -286,24 +275,11 @@ unsigned long shrink_slab(struct shrink_control *sc,
 		do {
 			long ret;
 
-			if (shrinker->scan_objects) {
-				sc->nr_to_scan = batch_size;
-				ret = shrinker->scan_objects(shrinker, sc);
-
-				if (ret == -1)
-					break;
-				freed += ret;
-			} else {
-				int nr_before;
-
-				nr_before = do_shrinker_shrink(shrinker, sc, 0);
-				ret = do_shrinker_shrink(shrinker, sc,
-								batch_size);
-				if (ret == -1)
-					break;
-				if (ret < nr_before)
-					freed += nr_before - ret;
-			}
+			sc->nr_to_scan = batch_size;
+			ret = shrinker->scan_objects(shrinker, sc);
+			if (ret == -1)
+				break;
+			freed += ret;
 
 			count_vm_events(SLABS_SCANNED, batch_size);
 			total_scan -= batch_size;
-- 
1.8.1.4
