From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 18/23] cgroup: make cgroup_task_iter remember the cgroup being
	iterated
Date: Thu,  1 Aug 2013 17:49:56 -0400
Message-ID: <1375393801-4817-19-git-send-email-tj@kernel.org>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375393801-4817-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently all cgroup_task_iter functions require @cgrp to be passed
in, which is superflous and increases chance of usage error.  Make
cgroup_task_iter remember the cgroup being iterated and drop @cgrp
argument from next and end functions.

This patch doesn't introduce any behavior differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/cgroup.h  |  6 +++---
 kernel/cgroup.c         | 32 +++++++++++++++-----------------
 kernel/cgroup_freezer.c | 12 ++++++------
 mm/memcontrol.c         |  6 +++---
 4 files changed, 27 insertions(+), 29 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 4478336..2b10152 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -892,14 +892,14 @@ css_next_descendant_post(struct cgroup_subsys_state *pos,
 
 /* A cgroup_task_iter should be treated as an opaque object */
 struct cgroup_task_iter {
+	struct cgroup			*origin_cgrp;
 	struct list_head		*cset_link;
 	struct list_head		*task;
 };
 
 void cgroup_task_iter_start(struct cgroup *cgrp, struct cgroup_task_iter *it);
-struct task_struct *cgroup_task_iter_next(struct cgroup *cgrp,
-					  struct cgroup_task_iter *it);
-void cgroup_task_iter_end(struct cgroup *cgrp, struct cgroup_task_iter *it);
+struct task_struct *cgroup_task_iter_next(struct cgroup_task_iter *it);
+void cgroup_task_iter_end(struct cgroup_task_iter *it);
 int cgroup_scan_tasks(struct cgroup_scanner *scan);
 int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7a4f89b..7adaaa6 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3198,13 +3198,11 @@ EXPORT_SYMBOL_GPL(css_next_descendant_post);
 
 /**
  * cgroup_advance_task_iter - advance a task itererator to the next css_set
- * @cgrp: the cgroup to walk tasks of
  * @it: the iterator to advance
  *
  * Advance @it to the next css_set to walk.
  */
-static void cgroup_advance_task_iter(struct cgroup *cgrp,
-				     struct cgroup_task_iter *it)
+static void cgroup_advance_task_iter(struct cgroup_task_iter *it)
 {
 	struct list_head *l = it->cset_link;
 	struct cgrp_cset_link *link;
@@ -3213,7 +3211,7 @@ static void cgroup_advance_task_iter(struct cgroup *cgrp,
 	/* Advance to the next non-empty css_set */
 	do {
 		l = l->next;
-		if (l == &cgrp->cset_links) {
+		if (l == &it->origin_cgrp->cset_links) {
 			it->cset_link = NULL;
 			return;
 		}
@@ -3250,21 +3248,22 @@ void cgroup_task_iter_start(struct cgroup *cgrp, struct cgroup_task_iter *it)
 		cgroup_enable_task_cg_lists();
 
 	read_lock(&css_set_lock);
+
+	it->origin_cgrp = cgrp;
 	it->cset_link = &cgrp->cset_links;
-	cgroup_advance_task_iter(cgrp, it);
+
+	cgroup_advance_task_iter(it);
 }
 
 /**
  * cgroup_task_iter_next - return the next task for the iterator
- * @cgrp: the cgroup to walk tasks of
  * @it: the task iterator being iterated
  *
  * The "next" function for task iteration.  @it should have been
  * initialized via cgroup_task_iter_start().  Returns NULL when the
  * iteration reaches the end.
  */
-struct task_struct *cgroup_task_iter_next(struct cgroup *cgrp,
-					  struct cgroup_task_iter *it)
+struct task_struct *cgroup_task_iter_next(struct cgroup_task_iter *it)
 {
 	struct task_struct *res;
 	struct list_head *l = it->task;
@@ -3282,7 +3281,7 @@ struct task_struct *cgroup_task_iter_next(struct cgroup *cgrp,
 		 * We reached the end of this task list - move on to the
 		 * next cgrp_cset_link.
 		 */
-		cgroup_advance_task_iter(cgrp, it);
+		cgroup_advance_task_iter(it);
 	} else {
 		it->task = l;
 	}
@@ -3291,12 +3290,11 @@ struct task_struct *cgroup_task_iter_next(struct cgroup *cgrp,
 
 /**
  * cgroup_task_iter_end - finish task iteration
- * @cgrp: the cgroup to walk tasks of
  * @it: the task iterator to finish
  *
  * Finish task iteration started by cgroup_task_iter_start().
  */
-void cgroup_task_iter_end(struct cgroup *cgrp, struct cgroup_task_iter *it)
+void cgroup_task_iter_end(struct cgroup_task_iter *it)
 	__releases(css_set_lock)
 {
 	read_unlock(&css_set_lock);
@@ -3402,7 +3400,7 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
 	 */
 	heap->size = 0;
 	cgroup_task_iter_start(scan->cgrp, &it);
-	while ((p = cgroup_task_iter_next(scan->cgrp, &it))) {
+	while ((p = cgroup_task_iter_next(&it))) {
 		/*
 		 * Only affect tasks that qualify per the caller's callback,
 		 * if he provided one
@@ -3435,7 +3433,7 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
 		 * the heap and wasn't inserted
 		 */
 	}
-	cgroup_task_iter_end(scan->cgrp, &it);
+	cgroup_task_iter_end(&it);
 
 	if (heap->size) {
 		for (i = 0; i < heap->size; i++) {
@@ -3657,7 +3655,7 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
 		return -ENOMEM;
 	/* now, populate the array */
 	cgroup_task_iter_start(cgrp, &it);
-	while ((tsk = cgroup_task_iter_next(cgrp, &it))) {
+	while ((tsk = cgroup_task_iter_next(&it))) {
 		if (unlikely(n == length))
 			break;
 		/* get tgid or pid for procs or tasks file respectively */
@@ -3668,7 +3666,7 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
 		if (pid > 0) /* make sure to only use valid results */
 			array[n++] = pid;
 	}
-	cgroup_task_iter_end(cgrp, &it);
+	cgroup_task_iter_end(&it);
 	length = n;
 	/* now sort & (if procs) strip out duplicates */
 	sort(array, length, sizeof(pid_t), cmppid, NULL);
@@ -3717,7 +3715,7 @@ int cgroupstats_build(struct cgroupstats *stats, struct dentry *dentry)
 	cgrp = dentry->d_fsdata;
 
 	cgroup_task_iter_start(cgrp, &it);
-	while ((tsk = cgroup_task_iter_next(cgrp, &it))) {
+	while ((tsk = cgroup_task_iter_next(&it))) {
 		switch (tsk->state) {
 		case TASK_RUNNING:
 			stats->nr_running++;
@@ -3737,7 +3735,7 @@ int cgroupstats_build(struct cgroupstats *stats, struct dentry *dentry)
 			break;
 		}
 	}
-	cgroup_task_iter_end(cgrp, &it);
+	cgroup_task_iter_end(&it);
 
 err:
 	return ret;
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index c9177f8..e0ab9bf 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -281,7 +281,7 @@ static void update_if_frozen(struct cgroup_subsys_state *css)
 	/* are all tasks frozen? */
 	cgroup_task_iter_start(css->cgroup, &it);
 
-	while ((task = cgroup_task_iter_next(css->cgroup, &it))) {
+	while ((task = cgroup_task_iter_next(&it))) {
 		if (freezing(task)) {
 			/*
 			 * freezer_should_skip() indicates that the task
@@ -296,7 +296,7 @@ static void update_if_frozen(struct cgroup_subsys_state *css)
 
 	freezer->state |= CGROUP_FROZEN;
 out_iter_end:
-	cgroup_task_iter_end(css->cgroup, &it);
+	cgroup_task_iter_end(&it);
 out_unlock:
 	spin_unlock_irq(&freezer->lock);
 }
@@ -327,9 +327,9 @@ static void freeze_cgroup(struct freezer *freezer)
 	struct task_struct *task;
 
 	cgroup_task_iter_start(cgroup, &it);
-	while ((task = cgroup_task_iter_next(cgroup, &it)))
+	while ((task = cgroup_task_iter_next(&it)))
 		freeze_task(task);
-	cgroup_task_iter_end(cgroup, &it);
+	cgroup_task_iter_end(&it);
 }
 
 static void unfreeze_cgroup(struct freezer *freezer)
@@ -339,9 +339,9 @@ static void unfreeze_cgroup(struct freezer *freezer)
 	struct task_struct *task;
 
 	cgroup_task_iter_start(cgroup, &it);
-	while ((task = cgroup_task_iter_next(cgroup, &it)))
+	while ((task = cgroup_task_iter_next(&it)))
 		__thaw_task(task);
-	cgroup_task_iter_end(cgroup, &it);
+	cgroup_task_iter_end(&it);
 }
 
 /**
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 00b055d..5a5f4dc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1804,7 +1804,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		struct task_struct *task;
 
 		cgroup_task_iter_start(cgroup, &it);
-		while ((task = cgroup_task_iter_next(cgroup, &it))) {
+		while ((task = cgroup_task_iter_next(&it))) {
 			switch (oom_scan_process_thread(task, totalpages, NULL,
 							false)) {
 			case OOM_SCAN_SELECT:
@@ -1817,7 +1817,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 			case OOM_SCAN_CONTINUE:
 				continue;
 			case OOM_SCAN_ABORT:
-				cgroup_task_iter_end(cgroup, &it);
+				cgroup_task_iter_end(&it);
 				mem_cgroup_iter_break(memcg, iter);
 				if (chosen)
 					put_task_struct(chosen);
@@ -1834,7 +1834,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				get_task_struct(chosen);
 			}
 		}
-		cgroup_task_iter_end(cgroup, &it);
+		cgroup_task_iter_end(&it);
 	}
 
 	if (!chosen)
-- 
1.8.3.1
