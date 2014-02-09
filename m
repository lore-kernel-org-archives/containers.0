From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 09/16] cgroup: remove css_scan_tasks()
Date: Sun,  9 Feb 2014 08:52:37 -0500
Message-ID: <1391953964-22088-10-git-send-email-tj@kernel.org>
References: <1391953964-22088-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391953964-22088-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

css_scan_tasks() doesn't have any user left.  Remove it.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |   6 --
 kernel/cgroup.c        | 162 -------------------------------------------------
 2 files changed, 168 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index f173cfb..db5ccf4 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -14,7 +14,6 @@
 #include <linux/rcupdate.h>
 #include <linux/rculist.h>
 #include <linux/cgroupstats.h>
-#include <linux/prio_heap.h>
 #include <linux/rwsem.h>
 #include <linux/idr.h>
 #include <linux/workqueue.h>
@@ -811,11 +810,6 @@ void css_task_iter_start(struct cgroup_subsys_state *css,
 struct task_struct *css_task_iter_next(struct css_task_iter *it);
 void css_task_iter_end(struct css_task_iter *it);
 
-int css_scan_tasks(struct cgroup_subsys_state *css,
-		   bool (*test)(struct task_struct *, void *),
-		   void (*process)(struct task_struct *, void *),
-		   void *data, struct ptr_heap *heap);
-
 int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5ad1b25..8c1f840 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2696,168 +2696,6 @@ void css_task_iter_end(struct css_task_iter *it)
 	up_read(&css_set_rwsem);
 }
 
-static inline int started_after_time(struct task_struct *t1,
-				     struct timespec *time,
-				     struct task_struct *t2)
-{
-	int start_diff = timespec_compare(&t1->start_time, time);
-	if (start_diff > 0) {
-		return 1;
-	} else if (start_diff < 0) {
-		return 0;
-	} else {
-		/*
-		 * Arbitrarily, if two processes started at the same
-		 * time, we'll say that the lower pointer value
-		 * started first. Note that t2 may have exited by now
-		 * so this may not be a valid pointer any longer, but
-		 * that's fine - it still serves to distinguish
-		 * between two tasks started (effectively) simultaneously.
-		 */
-		return t1 > t2;
-	}
-}
-
-/*
- * This function is a callback from heap_insert() and is used to order
- * the heap.
- * In this case we order the heap in descending task start time.
- */
-static inline int started_after(void *p1, void *p2)
-{
-	struct task_struct *t1 = p1;
-	struct task_struct *t2 = p2;
-	return started_after_time(t1, &t2->start_time, t2);
-}
-
-/**
- * css_scan_tasks - iterate though all the tasks in a css
- * @css: the css to iterate tasks of
- * @test: optional test callback
- * @process: process callback
- * @data: data passed to @test and @process
- * @heap: optional pre-allocated heap used for task iteration
- *
- * Iterate through all the tasks in @css, calling @test for each, and if it
- * returns %true, call @process for it also.
- *
- * @test may be NULL, meaning always true (select all tasks), which
- * effectively duplicates css_task_iter_{start,next,end}() but does not
- * lock css_set_rwsem for the call to @process.
- *
- * It is guaranteed that @process will act on every task that is a member
- * of @css for the duration of this call.  This function may or may not
- * call @process for tasks that exit or move to a different css during the
- * call, or are forked or move into the css during the call.
- *
- * Note that @test may be called with locks held, and may in some
- * situations be called multiple times for the same task, so it should be
- * cheap.
- *
- * If @heap is non-NULL, a heap has been pre-allocated and will be used for
- * heap operations (and its "gt" member will be overwritten), else a
- * temporary heap will be used (allocation of which may cause this function
- * to fail).
- */
-int css_scan_tasks(struct cgroup_subsys_state *css,
-		   bool (*test)(struct task_struct *, void *),
-		   void (*process)(struct task_struct *, void *),
-		   void *data, struct ptr_heap *heap)
-{
-	int retval, i;
-	struct css_task_iter it;
-	struct task_struct *p, *dropped;
-	/* Never dereference latest_task, since it's not refcounted */
-	struct task_struct *latest_task = NULL;
-	struct ptr_heap tmp_heap;
-	struct timespec latest_time = { 0, 0 };
-
-	if (heap) {
-		/* The caller supplied our heap and pre-allocated its memory */
-		heap->gt = &started_after;
-	} else {
-		/* We need to allocate our own heap memory */
-		heap = &tmp_heap;
-		retval = heap_init(heap, PAGE_SIZE, GFP_KERNEL, &started_after);
-		if (retval)
-			/* cannot allocate the heap */
-			return retval;
-	}
-
- again:
-	/*
-	 * Scan tasks in the css, using the @test callback to determine
-	 * which are of interest, and invoking @process callback on the
-	 * ones which need an update.  Since we don't want to hold any
-	 * locks during the task updates, gather tasks to be processed in a
-	 * heap structure.  The heap is sorted by descending task start
-	 * time.  If the statically-sized heap fills up, we overflow tasks
-	 * that started later, and in future iterations only consider tasks
-	 * that started after the latest task in the previous pass. This
-	 * guarantees forward progress and that we don't miss any tasks.
-	 */
-	heap->size = 0;
-	css_task_iter_start(css, &it);
-	while ((p = css_task_iter_next(&it))) {
-		/*
-		 * Only affect tasks that qualify per the caller's callback,
-		 * if he provided one
-		 */
-		if (test && !test(p, data))
-			continue;
-		/*
-		 * Only process tasks that started after the last task
-		 * we processed
-		 */
-		if (!started_after_time(p, &latest_time, latest_task))
-			continue;
-		dropped = heap_insert(heap, p);
-		if (dropped == NULL) {
-			/*
-			 * The new task was inserted; the heap wasn't
-			 * previously full
-			 */
-			get_task_struct(p);
-		} else if (dropped != p) {
-			/*
-			 * The new task was inserted, and pushed out a
-			 * different task
-			 */
-			get_task_struct(p);
-			put_task_struct(dropped);
-		}
-		/*
-		 * Else the new task was newer than anything already in
-		 * the heap and wasn't inserted
-		 */
-	}
-	css_task_iter_end(&it);
-
-	if (heap->size) {
-		for (i = 0; i < heap->size; i++) {
-			struct task_struct *q = heap->ptrs[i];
-			if (i == 0) {
-				latest_time = q->start_time;
-				latest_task = q;
-			}
-			/* Process the task per the caller's callback */
-			process(q, data);
-			put_task_struct(q);
-		}
-		/*
-		 * If we had to process any tasks at all, scan again
-		 * in case some of them were in the middle of forking
-		 * children that didn't get processed.
-		 * Not the most efficient way to do it, but it avoids
-		 * having to take callback_mutex in the fork path
-		 */
-		goto again;
-	}
-	if (heap == &tmp_heap)
-		heap_free(&tmp_heap);
-	return 0;
-}
-
 /**
  * cgroup_trasnsfer_tasks - move tasks from one cgroup to another
  * @to: cgroup to which the tasks will be moved
-- 
1.8.5.3
