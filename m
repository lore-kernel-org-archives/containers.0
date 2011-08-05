From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v2 1/4] factor out single-shrinker code
Date: Fri,  5 Aug 2011 04:35:41 +0400
Message-ID: <1312504544-1108-2-git-send-email-glommer__1492.59698014266$1312504652$gmane$org@parallels.com>
References: <1312504544-1108-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1312504544-1108-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, David Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

While shrinking our caches, vmscan.c passes through all
registered shrinkers, trying to free objects as it goes.

We would like to do that individually for some caches,
like the dcache, when certain conditions apply (for
example, when we reach a soon-to-exist maximum allowed size)

To avoid re-writing the same logic at more than one place,
this patch factors out the shrink logic at shrink_one_shrinker(),
that we can call from other places of the kernel.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
---
 include/linux/shrinker.h |    6 ++
 mm/vmscan.c              |  185 ++++++++++++++++++++++++----------------------
 2 files changed, 104 insertions(+), 87 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 790651b..c5db650 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -39,4 +39,10 @@ struct shrinker {
 #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
 extern void register_shrinker(struct shrinker *);
 extern void unregister_shrinker(struct shrinker *);
+
+unsigned long shrink_one_shrinker(struct shrinker *shrinker,
+				  struct shrink_control *shrink,
+				  unsigned long nr_pages_scanned,                      
+				  unsigned long lru_pages);
+
 #endif
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7ef6912..50dfc61 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -211,6 +211,102 @@ static inline int do_shrinker_shrink(struct shrinker *shrinker,
 }
 
 #define SHRINK_BATCH 128
+unsigned long shrink_one_shrinker(struct shrinker *shrinker,
+				  struct shrink_control *shrink,
+				  unsigned long nr_pages_scanned,
+				  unsigned long lru_pages)
+{
+	unsigned long ret = 0;
+	unsigned long long delta;
+	unsigned long total_scan;
+	unsigned long max_pass;
+	int shrink_ret = 0;
+	long nr;
+	long new_nr;
+	long batch_size = shrinker->batch ? shrinker->batch
+					  : SHRINK_BATCH;
+
+	/*
+	 * copy the current shrinker scan count into a local variable
+	 * and zero it so that other concurrent shrinker invocations
+	 * don't also do this scanning work.
+	 */
+	do {
+		nr = shrinker->nr;
+	} while (cmpxchg(&shrinker->nr, nr, 0) != nr);
+
+	total_scan = nr;
+	max_pass = do_shrinker_shrink(shrinker, shrink, 0);
+	delta = (4 * nr_pages_scanned) / shrinker->seeks;
+	delta *= max_pass;
+	do_div(delta, lru_pages + 1);
+	total_scan += delta;
+	if (total_scan < 0) {
+		printk(KERN_ERR "shrink_slab: %pF negative objects to "
+		       "delete nr=%ld\n",
+		       shrinker->shrink, total_scan);
+		total_scan = max_pass;
+	}
+
+	/*
+	 * We need to avoid excessive windup on filesystem shrinkers
+	 * due to large numbers of GFP_NOFS allocations causing the
+	 * shrinkers to return -1 all the time. This results in a large
+	 * nr being built up so when a shrink that can do some work
+	 * comes along it empties the entire cache due to nr >>>
+	 * max_pass.  This is bad for sustaining a working set in
+	 * memory.
+	 *
+	 * Hence only allow the shrinker to scan the entire cache when
+	 * a large delta change is calculated directly.
+	 */
+	if (delta < max_pass / 4)
+		total_scan = min(total_scan, max_pass / 2);
+
+	/*
+	 * Avoid risking looping forever due to too large nr value:
+	 * never try to free more than twice the estimate number of
+	 * freeable entries.
+	 */
+	if (total_scan > max_pass * 2)
+		total_scan = max_pass * 2;
+
+	trace_mm_shrink_slab_start(shrinker, shrink, nr,
+				nr_pages_scanned, lru_pages,
+				max_pass, delta, total_scan);
+
+	while (total_scan >= batch_size) {
+		int nr_before;
+
+		nr_before = do_shrinker_shrink(shrinker, shrink, 0);
+		shrink_ret = do_shrinker_shrink(shrinker, shrink,
+						batch_size);
+		if (shrink_ret == -1)
+			break;
+		if (shrink_ret < nr_before)
+			ret += nr_before - shrink_ret;
+		count_vm_events(SLABS_SCANNED, batch_size);
+		total_scan -= batch_size;
+
+		cond_resched();
+	}
+
+	/*
+	 * move the unused scan count back into the shrinker in a
+	 * manner that handles concurrent updates. If we exhausted the
+	 * scan, there is no need to do an update.
+	 */
+	do {
+		nr = shrinker->nr;
+		new_nr = total_scan + nr;
+		if (total_scan <= 0)
+			break;
+	} while (cmpxchg(&shrinker->nr, nr, new_nr) != nr);
+
+	trace_mm_shrink_slab_end(shrinker, shrink_ret, nr, new_nr);
+	return ret;
+}
+
 /*
  * Call the shrink functions to age shrinkable caches
  *
@@ -247,93 +343,8 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 	}
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
-		unsigned long long delta;
-		unsigned long total_scan;
-		unsigned long max_pass;
-		int shrink_ret = 0;
-		long nr;
-		long new_nr;
-		long batch_size = shrinker->batch ? shrinker->batch
-						  : SHRINK_BATCH;
-
-		/*
-		 * copy the current shrinker scan count into a local variable
-		 * and zero it so that other concurrent shrinker invocations
-		 * don't also do this scanning work.
-		 */
-		do {
-			nr = shrinker->nr;
-		} while (cmpxchg(&shrinker->nr, nr, 0) != nr);
-
-		total_scan = nr;
-		max_pass = do_shrinker_shrink(shrinker, shrink, 0);
-		delta = (4 * nr_pages_scanned) / shrinker->seeks;
-		delta *= max_pass;
-		do_div(delta, lru_pages + 1);
-		total_scan += delta;
-		if (total_scan < 0) {
-			printk(KERN_ERR "shrink_slab: %pF negative objects to "
-			       "delete nr=%ld\n",
-			       shrinker->shrink, total_scan);
-			total_scan = max_pass;
-		}
-
-		/*
-		 * We need to avoid excessive windup on filesystem shrinkers
-		 * due to large numbers of GFP_NOFS allocations causing the
-		 * shrinkers to return -1 all the time. This results in a large
-		 * nr being built up so when a shrink that can do some work
-		 * comes along it empties the entire cache due to nr >>>
-		 * max_pass.  This is bad for sustaining a working set in
-		 * memory.
-		 *
-		 * Hence only allow the shrinker to scan the entire cache when
-		 * a large delta change is calculated directly.
-		 */
-		if (delta < max_pass / 4)
-			total_scan = min(total_scan, max_pass / 2);
-
-		/*
-		 * Avoid risking looping forever due to too large nr value:
-		 * never try to free more than twice the estimate number of
-		 * freeable entries.
-		 */
-		if (total_scan > max_pass * 2)
-			total_scan = max_pass * 2;
-
-		trace_mm_shrink_slab_start(shrinker, shrink, nr,
-					nr_pages_scanned, lru_pages,
-					max_pass, delta, total_scan);
-
-		while (total_scan >= batch_size) {
-			int nr_before;
-
-			nr_before = do_shrinker_shrink(shrinker, shrink, 0);
-			shrink_ret = do_shrinker_shrink(shrinker, shrink,
-							batch_size);
-			if (shrink_ret == -1)
-				break;
-			if (shrink_ret < nr_before)
-				ret += nr_before - shrink_ret;
-			count_vm_events(SLABS_SCANNED, batch_size);
-			total_scan -= batch_size;
-
-			cond_resched();
-		}
-
-		/*
-		 * move the unused scan count back into the shrinker in a
-		 * manner that handles concurrent updates. If we exhausted the
-		 * scan, there is no need to do an update.
-		 */
-		do {
-			nr = shrinker->nr;
-			new_nr = total_scan + nr;
-			if (total_scan <= 0)
-				break;
-		} while (cmpxchg(&shrinker->nr, nr, new_nr) != nr);
-
-		trace_mm_shrink_slab_end(shrinker, shrink_ret, nr, new_nr);
+		ret += shrink_one_shrinker(shrinker, shrink,
+					   nr_pages_scanned, lru_pages);
 	}
 	up_read(&shrinker_rwsem);
 out:
-- 
1.7.6
