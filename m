From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 07/16] cgroup: make css_set_lock a rwsem and rename it to
	css_set_rwsem
Date: Sun,  9 Feb 2014 08:52:35 -0500
Message-ID: <1391953964-22088-8-git-send-email-tj@kernel.org>
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

Currently there are two ways to walk tasks of a cgroup -
css_task_iter_start/next/end() and css_scan_tasks().  The latter
builds on the former but allows blocking while iterating.
Unfortunately, the way css_scan_tasks() is implemented is rather
nasty, it uses a priority heap of pointers to extract some number of
tasks in task creation order and loops over them invoking the callback
and repeats that until it reaches the end.  It requires either
preallocated heap or may fail under memory pressure, while unlikely to
be problematic, the complexity is O(N^2), and in general just nasty.

We're gonna convert all css_scan_users() to
css_task_iter_start/next/end() and remove css_scan_users().  As
css_scan_tasks() users may block, let's convert css_set_lock to a
rwsem so that tasks can block during css_task_iter_*() is in progress.

While this does increase the chance of possible deadlock scenarios,
given the current usage, the probability is relatively low, and even
if that happens, the right thing to do is updating the iteration in
the similar way to css iterators so that it can handle blocking.

Most conversions are trivial; however, task_cgroup_path() now expects
to be called with css_set_rwsem locked instead of locking itself.
This is because the function is called with RCU read lock held and
rwsem locking should nest outside RCU read lock.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 104 +++++++++++++++++++++++++++++++-------------------------
 1 file changed, 57 insertions(+), 47 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a5f965c..5ad1b25 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -42,6 +42,7 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/rwsem.h>
 #include <linux/string.h>
 #include <linux/sort.h>
 #include <linux/kmod.h>
@@ -341,11 +342,10 @@ static struct css_set init_css_set;
 static struct cgrp_cset_link init_cgrp_cset_link;
 
 /*
- * css_set_lock protects the list of css_set objects, and the chain of
- * tasks off each css_set.  Nests outside task->alloc_lock due to
- * css_task_iter_start().
+ * css_set_rwsem protects the list of css_set objects, and the chain of
+ * tasks off each css_set.
  */
-static DEFINE_RWLOCK(css_set_lock);
+static DECLARE_RWSEM(css_set_rwsem);
 static int css_set_count;
 
 /*
@@ -380,9 +380,9 @@ static void __put_css_set(struct css_set *cset, int taskexit)
 	 */
 	if (atomic_add_unless(&cset->refcount, -1, 1))
 		return;
-	write_lock(&css_set_lock);
+	down_write(&css_set_rwsem);
 	if (!atomic_dec_and_test(&cset->refcount)) {
-		write_unlock(&css_set_lock);
+		up_write(&css_set_rwsem);
 		return;
 	}
 
@@ -396,7 +396,7 @@ static void __put_css_set(struct css_set *cset, int taskexit)
 		list_del(&link->cset_link);
 		list_del(&link->cgrp_link);
 
-		/* @cgrp can't go away while we're holding css_set_lock */
+		/* @cgrp can't go away while we're holding css_set_rwsem */
 		if (list_empty(&cgrp->cset_links) && notify_on_release(cgrp)) {
 			if (taskexit)
 				set_bit(CGRP_RELEASABLE, &cgrp->flags);
@@ -406,7 +406,7 @@ static void __put_css_set(struct css_set *cset, int taskexit)
 		kfree(link);
 	}
 
-	write_unlock(&css_set_lock);
+	up_write(&css_set_rwsem);
 	kfree_rcu(cset, rcu_head);
 }
 
@@ -627,11 +627,11 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 
 	/* First see if we already have a cgroup group that matches
 	 * the desired set */
-	read_lock(&css_set_lock);
+	down_read(&css_set_rwsem);
 	cset = find_existing_css_set(old_cset, cgrp, template);
 	if (cset)
 		get_css_set(cset);
-	read_unlock(&css_set_lock);
+	up_read(&css_set_rwsem);
 
 	if (cset)
 		return cset;
@@ -655,7 +655,7 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 	 * find_existing_css_set() */
 	memcpy(cset->subsys, template, sizeof(cset->subsys));
 
-	write_lock(&css_set_lock);
+	down_write(&css_set_rwsem);
 	/* Add reference counts and links from the new css_set. */
 	list_for_each_entry(link, &old_cset->cgrp_links, cgrp_link) {
 		struct cgroup *c = link->cgrp;
@@ -673,7 +673,7 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 	key = css_set_hash(cset->subsys);
 	hash_add(css_set_table, &cset->hlist, key);
 
-	write_unlock(&css_set_lock);
+	up_write(&css_set_rwsem);
 
 	return cset;
 }
@@ -739,14 +739,14 @@ static void cgroup_destroy_root(struct cgroupfs_root *root)
 	 * Release all the links from cset_links to this hierarchy's
 	 * root cgroup
 	 */
-	write_lock(&css_set_lock);
+	down_write(&css_set_rwsem);
 
 	list_for_each_entry_safe(link, tmp_link, &cgrp->cset_links, cset_link) {
 		list_del(&link->cset_link);
 		list_del(&link->cgrp_link);
 		kfree(link);
 	}
-	write_unlock(&css_set_lock);
+	up_write(&css_set_rwsem);
 
 	if (!list_empty(&root->root_list)) {
 		list_del(&root->root_list);
@@ -764,7 +764,7 @@ static void cgroup_destroy_root(struct cgroupfs_root *root)
 
 /*
  * Return the cgroup for "task" from the given hierarchy. Must be
- * called with cgroup_mutex held.
+ * called with cgroup_mutex and css_set_rwsem held.
  */
 static struct cgroup *task_cgroup_from_root(struct task_struct *task,
 					    struct cgroupfs_root *root)
@@ -772,8 +772,9 @@ static struct cgroup *task_cgroup_from_root(struct task_struct *task,
 	struct css_set *cset;
 	struct cgroup *res = NULL;
 
-	BUG_ON(!mutex_is_locked(&cgroup_mutex));
-	read_lock(&css_set_lock);
+	lockdep_assert_held(&cgroup_mutex);
+	lockdep_assert_held(&css_set_rwsem);
+
 	/*
 	 * No need to lock the task - since we hold cgroup_mutex the
 	 * task can't change groups, so the only thing that can happen
@@ -794,7 +795,7 @@ static struct cgroup *task_cgroup_from_root(struct task_struct *task,
 			}
 		}
 	}
-	read_unlock(&css_set_lock);
+
 	BUG_ON(!res);
 	return res;
 }
@@ -1308,7 +1309,7 @@ static void cgroup_enable_task_cg_lists(void)
 {
 	struct task_struct *p, *g;
 
-	write_lock(&css_set_lock);
+	down_write(&css_set_rwsem);
 
 	if (use_task_css_set_links)
 		goto out_unlock;
@@ -1341,7 +1342,7 @@ static void cgroup_enable_task_cg_lists(void)
 	} while_each_thread(g, p);
 	read_unlock(&tasklist_lock);
 out_unlock:
-	write_unlock(&css_set_lock);
+	up_write(&css_set_rwsem);
 }
 
 static void init_cgroup_housekeeping(struct cgroup *cgrp)
@@ -1406,7 +1407,7 @@ static int cgroup_setup_root(struct cgroupfs_root *root, unsigned long ss_mask)
 	root_cgrp->id = ret;
 
 	/*
-	 * We're accessing css_set_count without locking css_set_lock here,
+	 * We're accessing css_set_count without locking css_set_rwsem here,
 	 * but that's OK - it can only be increased by someone holding
 	 * cgroup_lock, and that's us. The worst that can happen is that we
 	 * have some link structures left over
@@ -1449,10 +1450,10 @@ static int cgroup_setup_root(struct cgroupfs_root *root, unsigned long ss_mask)
 	 * Link the top cgroup in this hierarchy into all the css_set
 	 * objects.
 	 */
-	write_lock(&css_set_lock);
+	down_write(&css_set_rwsem);
 	hash_for_each(css_set_table, i, cset, hlist)
 		link_css_set(&tmp_links, cset, root_cgrp);
-	write_unlock(&css_set_lock);
+	up_write(&css_set_rwsem);
 
 	BUG_ON(!list_empty(&root_cgrp->children));
 	BUG_ON(atomic_read(&root->nr_cgrps) != 1);
@@ -1615,6 +1616,7 @@ char *task_cgroup_path(struct task_struct *task, char *buf, size_t buflen)
 	char *path = NULL;
 
 	mutex_lock(&cgroup_mutex);
+	down_read(&css_set_rwsem);
 
 	root = idr_get_next(&cgroup_hierarchy_idr, &hierarchy_id);
 
@@ -1627,6 +1629,7 @@ char *task_cgroup_path(struct task_struct *task, char *buf, size_t buflen)
 			path = buf;
 	}
 
+	up_read(&css_set_rwsem);
 	mutex_unlock(&cgroup_mutex);
 	return path;
 }
@@ -1738,9 +1741,9 @@ static void cgroup_task_migrate(struct cgroup *old_cgrp,
 	task_unlock(tsk);
 
 	/* Update the css_set linked lists if we're using them */
-	write_lock(&css_set_lock);
+	down_write(&css_set_rwsem);
 	list_move(&tsk->cg_list, &new_cset->tasks);
-	write_unlock(&css_set_lock);
+	up_write(&css_set_rwsem);
 
 	/*
 	 * We just gained a reference on old_cset by taking it from the
@@ -1798,6 +1801,7 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
 	 * already PF_EXITING could be freed from underneath us unless we
 	 * take an rcu_read_lock.
 	 */
+	down_read(&css_set_rwsem);
 	rcu_read_lock();
 	do {
 		struct task_and_cgroup ent;
@@ -1825,6 +1829,7 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
 			break;
 	} while_each_thread(leader, tsk);
 	rcu_read_unlock();
+	up_read(&css_set_rwsem);
 	/* remember the number of threads in the array for later. */
 	group_size = i;
 	tset.tc_array = group;
@@ -2002,7 +2007,11 @@ int cgroup_attach_task_all(struct task_struct *from, struct task_struct *tsk)
 
 	mutex_lock(&cgroup_mutex);
 	for_each_active_root(root) {
-		struct cgroup *from_cgrp = task_cgroup_from_root(from, root);
+		struct cgroup *from_cgrp;
+
+		down_read(&css_set_rwsem);
+		from_cgrp = task_cgroup_from_root(from, root);
+		up_read(&css_set_rwsem);
 
 		retval = cgroup_attach_task(from_cgrp, tsk, false);
 		if (retval)
@@ -2395,10 +2404,10 @@ static int cgroup_task_count(const struct cgroup *cgrp)
 	int count = 0;
 	struct cgrp_cset_link *link;
 
-	read_lock(&css_set_lock);
+	down_read(&css_set_rwsem);
 	list_for_each_entry(link, &cgrp->cset_links, cset_link)
 		count += atomic_read(&link->cset->refcount);
-	read_unlock(&css_set_lock);
+	up_read(&css_set_rwsem);
 	return count;
 }
 
@@ -2629,12 +2638,12 @@ static void css_advance_task_iter(struct css_task_iter *it)
  */
 void css_task_iter_start(struct cgroup_subsys_state *css,
 			 struct css_task_iter *it)
-	__acquires(css_set_lock)
+	__acquires(css_set_rwsem)
 {
 	/* no one should try to iterate before mounting cgroups */
 	WARN_ON_ONCE(!use_task_css_set_links);
 
-	read_lock(&css_set_lock);
+	down_read(&css_set_rwsem);
 
 	it->origin_css = css;
 	it->cset_link = &css->cgroup->cset_links;
@@ -2682,9 +2691,9 @@ struct task_struct *css_task_iter_next(struct css_task_iter *it)
  * Finish task iteration started by css_task_iter_start().
  */
 void css_task_iter_end(struct css_task_iter *it)
-	__releases(css_set_lock)
+	__releases(css_set_rwsem)
 {
-	read_unlock(&css_set_lock);
+	up_read(&css_set_rwsem);
 }
 
 static inline int started_after_time(struct task_struct *t1,
@@ -2734,7 +2743,7 @@ static inline int started_after(void *p1, void *p2)
  *
  * @test may be NULL, meaning always true (select all tasks), which
  * effectively duplicates css_task_iter_{start,next,end}() but does not
- * lock css_set_lock for the call to @process.
+ * lock css_set_rwsem for the call to @process.
  *
  * It is guaranteed that @process will act on every task that is a member
  * of @css for the duration of this call.  This function may or may not
@@ -3866,12 +3875,12 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	lockdep_assert_held(&cgroup_mutex);
 
 	/*
-	 * css_set_lock synchronizes access to ->cset_links and prevents
+	 * css_set_rwsem synchronizes access to ->cset_links and prevents
 	 * @cgrp from being removed while __put_css_set() is in progress.
 	 */
-	read_lock(&css_set_lock);
+	down_read(&css_set_rwsem);
 	empty = list_empty(&cgrp->cset_links);
-	read_unlock(&css_set_lock);
+	up_read(&css_set_rwsem);
 	if (!empty)
 		return -EBUSY;
 
@@ -4207,6 +4216,7 @@ int proc_cgroup_show(struct seq_file *m, void *v)
 	retval = 0;
 
 	mutex_lock(&cgroup_mutex);
+	down_read(&css_set_rwsem);
 
 	for_each_active_root(root) {
 		struct cgroup_subsys *ss;
@@ -4232,6 +4242,7 @@ int proc_cgroup_show(struct seq_file *m, void *v)
 	}
 
 out_unlock:
+	up_read(&css_set_rwsem);
 	mutex_unlock(&cgroup_mutex);
 	put_task_struct(tsk);
 out_free:
@@ -4327,12 +4338,12 @@ void cgroup_post_fork(struct task_struct *child)
 	 * lock on fork.
 	 */
 	if (use_task_css_set_links) {
-		write_lock(&css_set_lock);
+		down_write(&css_set_rwsem);
 		task_lock(child);
 		if (list_empty(&child->cg_list))
 			list_add(&child->cg_list, &task_css_set(child)->tasks);
 		task_unlock(child);
-		write_unlock(&css_set_lock);
+		up_write(&css_set_rwsem);
 	}
 
 	/*
@@ -4389,15 +4400,14 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 	int i;
 
 	/*
-	 * Unlink from the css_set task list if necessary.
-	 * Optimistically check cg_list before taking
-	 * css_set_lock
+	 * Unlink from the css_set task list if necessary.  Optimistically
+	 * check cg_list before taking css_set_rwsem.
 	 */
 	if (!list_empty(&tsk->cg_list)) {
-		write_lock(&css_set_lock);
+		down_write(&css_set_rwsem);
 		if (!list_empty(&tsk->cg_list))
 			list_del_init(&tsk->cg_list);
-		write_unlock(&css_set_lock);
+		up_write(&css_set_rwsem);
 	}
 
 	/* Reassign the task to the init_css_set. */
@@ -4649,7 +4659,7 @@ static int current_css_set_cg_links_read(struct seq_file *seq, void *v)
 	if (!name_buf)
 		return -ENOMEM;
 
-	read_lock(&css_set_lock);
+	down_read(&css_set_rwsem);
 	rcu_read_lock();
 	cset = rcu_dereference(current->cgroups);
 	list_for_each_entry(link, &cset->cgrp_links, cgrp_link) {
@@ -4665,7 +4675,7 @@ static int current_css_set_cg_links_read(struct seq_file *seq, void *v)
 			   c->root->hierarchy_id, name);
 	}
 	rcu_read_unlock();
-	read_unlock(&css_set_lock);
+	up_read(&css_set_rwsem);
 	kfree(name_buf);
 	return 0;
 }
@@ -4676,7 +4686,7 @@ static int cgroup_css_links_read(struct seq_file *seq, void *v)
 	struct cgroup_subsys_state *css = seq_css(seq);
 	struct cgrp_cset_link *link;
 
-	read_lock(&css_set_lock);
+	down_read(&css_set_rwsem);
 	list_for_each_entry(link, &css->cgroup->cset_links, cset_link) {
 		struct css_set *cset = link->cset;
 		struct task_struct *task;
@@ -4692,7 +4702,7 @@ static int cgroup_css_links_read(struct seq_file *seq, void *v)
 			}
 		}
 	}
-	read_unlock(&css_set_lock);
+	up_read(&css_set_rwsem);
 	return 0;
 }
 
-- 
1.8.5.3
