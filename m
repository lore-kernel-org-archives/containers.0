From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/11] cgroup: consistently use @cset for struct css_set
	variables
Date: Wed, 12 Jun 2013 14:03:07 -0700
Message-ID: <1371070996-20613-3-git-send-email-tj@kernel.org>
References: <1371070996-20613-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371070996-20613-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup.c uses @cg for most struct css_set variables, which in itself
could be a bit confusing, but made much worse by the fact that there
are places which use @cg for struct cgroup variables.
compare_css_sets() epitomizes this confusion - @[old_]cg are struct
css_set while @cg[12] are struct cgroup.

It's not like the whole deal with cgroup, css_set and cg_cgroup_link
isn't already confusing enough.  Let's give it some sanity by
uniformly using @cset for all struct css_set variables.

* s/cg/cset/ for all css_set variables.

* s/oldcg/old_cset/ s/oldcgrp/old_cgrp/.  The same for the ones
  prefixed with "new".

* s/cg/cgrp/ for cgroup variables in compare_css_sets().

* s/css/cset/ for the cgroup variable in task_cgroup_from_root().

* Whiteline adjustments.

This patch is purely cosmetic.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 216 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 109 insertions(+), 107 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index dc8997a..e7f6845 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -376,30 +376,32 @@ static unsigned long css_set_hash(struct cgroup_subsys_state *css[])
  * compiled into their kernel but not actually in use */
 static int use_task_css_set_links __read_mostly;
 
-static void __put_css_set(struct css_set *cg, int taskexit)
+static void __put_css_set(struct css_set *cset, int taskexit)
 {
 	struct cg_cgroup_link *link;
 	struct cg_cgroup_link *saved_link;
+
 	/*
 	 * Ensure that the refcount doesn't hit zero while any readers
 	 * can see it. Similar to atomic_dec_and_lock(), but for an
 	 * rwlock
 	 */
-	if (atomic_add_unless(&cg->refcount, -1, 1))
+	if (atomic_add_unless(&cset->refcount, -1, 1))
 		return;
 	write_lock(&css_set_lock);
-	if (!atomic_dec_and_test(&cg->refcount)) {
+	if (!atomic_dec_and_test(&cset->refcount)) {
 		write_unlock(&css_set_lock);
 		return;
 	}
 
 	/* This css_set is dead. unlink it and release cgroup refcounts */
-	hash_del(&cg->hlist);
+	hash_del(&cset->hlist);
 	css_set_count--;
 
-	list_for_each_entry_safe(link, saved_link, &cg->cg_links,
+	list_for_each_entry_safe(link, saved_link, &cset->cg_links,
 				 cg_link_list) {
 		struct cgroup *cgrp = link->cgrp;
+
 		list_del(&link->cg_link_list);
 		list_del(&link->cgrp_link_list);
 
@@ -421,45 +423,45 @@ static void __put_css_set(struct css_set *cg, int taskexit)
 	}
 
 	write_unlock(&css_set_lock);
-	kfree_rcu(cg, rcu_head);
+	kfree_rcu(cset, rcu_head);
 }
 
 /*
  * refcounted get/put for css_set objects
  */
-static inline void get_css_set(struct css_set *cg)
+static inline void get_css_set(struct css_set *cset)
 {
-	atomic_inc(&cg->refcount);
+	atomic_inc(&cset->refcount);
 }
 
-static inline void put_css_set(struct css_set *cg)
+static inline void put_css_set(struct css_set *cset)
 {
-	__put_css_set(cg, 0);
+	__put_css_set(cset, 0);
 }
 
-static inline void put_css_set_taskexit(struct css_set *cg)
+static inline void put_css_set_taskexit(struct css_set *cset)
 {
-	__put_css_set(cg, 1);
+	__put_css_set(cset, 1);
 }
 
 /*
  * compare_css_sets - helper function for find_existing_css_set().
- * @cg: candidate css_set being tested
- * @old_cg: existing css_set for a task
+ * @cset: candidate css_set being tested
+ * @old_cset: existing css_set for a task
  * @new_cgrp: cgroup that's being entered by the task
  * @template: desired set of css pointers in css_set (pre-calculated)
  *
  * Returns true if "cg" matches "old_cg" except for the hierarchy
  * which "new_cgrp" belongs to, for which it should match "new_cgrp".
  */
-static bool compare_css_sets(struct css_set *cg,
-			     struct css_set *old_cg,
+static bool compare_css_sets(struct css_set *cset,
+			     struct css_set *old_cset,
 			     struct cgroup *new_cgrp,
 			     struct cgroup_subsys_state *template[])
 {
 	struct list_head *l1, *l2;
 
-	if (memcmp(template, cg->subsys, sizeof(cg->subsys))) {
+	if (memcmp(template, cset->subsys, sizeof(cset->subsys))) {
 		/* Not all subsystems matched */
 		return false;
 	}
@@ -473,28 +475,28 @@ static bool compare_css_sets(struct css_set *cg,
 	 * candidates.
 	 */
 
-	l1 = &cg->cg_links;
-	l2 = &old_cg->cg_links;
+	l1 = &cset->cg_links;
+	l2 = &old_cset->cg_links;
 	while (1) {
 		struct cg_cgroup_link *cgl1, *cgl2;
-		struct cgroup *cg1, *cg2;
+		struct cgroup *cgrp1, *cgrp2;
 
 		l1 = l1->next;
 		l2 = l2->next;
 		/* See if we reached the end - both lists are equal length. */
-		if (l1 == &cg->cg_links) {
-			BUG_ON(l2 != &old_cg->cg_links);
+		if (l1 == &cset->cg_links) {
+			BUG_ON(l2 != &old_cset->cg_links);
 			break;
 		} else {
-			BUG_ON(l2 == &old_cg->cg_links);
+			BUG_ON(l2 == &old_cset->cg_links);
 		}
 		/* Locate the cgroups associated with these links. */
 		cgl1 = list_entry(l1, struct cg_cgroup_link, cg_link_list);
 		cgl2 = list_entry(l2, struct cg_cgroup_link, cg_link_list);
-		cg1 = cgl1->cgrp;
-		cg2 = cgl2->cgrp;
+		cgrp1 = cgl1->cgrp;
+		cgrp2 = cgl2->cgrp;
 		/* Hierarchies should be linked in the same order. */
-		BUG_ON(cg1->root != cg2->root);
+		BUG_ON(cgrp1->root != cgrp2->root);
 
 		/*
 		 * If this hierarchy is the hierarchy of the cgroup
@@ -503,11 +505,11 @@ static bool compare_css_sets(struct css_set *cg,
 		 * hierarchy, then this css_set should point to the
 		 * same cgroup as the old css_set.
 		 */
-		if (cg1->root == new_cgrp->root) {
-			if (cg1 != new_cgrp)
+		if (cgrp1->root == new_cgrp->root) {
+			if (cgrp1 != new_cgrp)
 				return false;
 		} else {
-			if (cg1 != cg2)
+			if (cgrp1 != cgrp2)
 				return false;
 		}
 	}
@@ -527,14 +529,13 @@ static bool compare_css_sets(struct css_set *cg,
  * template: location in which to build the desired set of subsystem
  * state objects for the new cgroup group
  */
-static struct css_set *find_existing_css_set(
-	struct css_set *oldcg,
-	struct cgroup *cgrp,
-	struct cgroup_subsys_state *template[])
+static struct css_set *find_existing_css_set(struct css_set *old_cset,
+					struct cgroup *cgrp,
+					struct cgroup_subsys_state *template[])
 {
 	int i;
 	struct cgroupfs_root *root = cgrp->root;
-	struct css_set *cg;
+	struct css_set *cset;
 	unsigned long key;
 
 	/*
@@ -551,17 +552,17 @@ static struct css_set *find_existing_css_set(
 		} else {
 			/* Subsystem is not in this hierarchy, so we
 			 * don't want to change the subsystem state */
-			template[i] = oldcg->subsys[i];
+			template[i] = old_cset->subsys[i];
 		}
 	}
 
 	key = css_set_hash(template);
-	hash_for_each_possible(css_set_table, cg, hlist, key) {
-		if (!compare_css_sets(cg, oldcg, cgrp, template))
+	hash_for_each_possible(css_set_table, cset, hlist, key) {
+		if (!compare_css_sets(cset, old_cset, cgrp, template))
 			continue;
 
 		/* This css_set matches what we need */
-		return cg;
+		return cset;
 	}
 
 	/* No existing cgroup group matched */
@@ -603,18 +604,18 @@ static int allocate_cg_links(int count, struct list_head *tmp)
 /**
  * link_css_set - a helper function to link a css_set to a cgroup
  * @tmp_cg_links: cg_cgroup_link objects allocated by allocate_cg_links()
- * @cg: the css_set to be linked
+ * @cset: the css_set to be linked
  * @cgrp: the destination cgroup
  */
 static void link_css_set(struct list_head *tmp_cg_links,
-			 struct css_set *cg, struct cgroup *cgrp)
+			 struct css_set *cset, struct cgroup *cgrp)
 {
 	struct cg_cgroup_link *link;
 
 	BUG_ON(list_empty(tmp_cg_links));
 	link = list_first_entry(tmp_cg_links, struct cg_cgroup_link,
 				cgrp_link_list);
-	link->cg = cg;
+	link->cg = cset;
 	link->cgrp = cgrp;
 	atomic_inc(&cgrp->count);
 	list_move(&link->cgrp_link_list, &cgrp->css_sets);
@@ -622,7 +623,7 @@ static void link_css_set(struct list_head *tmp_cg_links,
 	 * Always add links to the tail of the list so that the list
 	 * is sorted by order of hierarchy creation
 	 */
-	list_add_tail(&link->cg_link_list, &cg->cg_links);
+	list_add_tail(&link->cg_link_list, &cset->cg_links);
 }
 
 /*
@@ -632,10 +633,10 @@ static void link_css_set(struct list_head *tmp_cg_links,
  * substituted into the appropriate hierarchy. Must be called with
  * cgroup_mutex held
  */
-static struct css_set *find_css_set(
-	struct css_set *oldcg, struct cgroup *cgrp)
+static struct css_set *find_css_set(struct css_set *old_cset,
+				    struct cgroup *cgrp)
 {
-	struct css_set *res;
+	struct css_set *cset;
 	struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
 
 	struct list_head tmp_cg_links;
@@ -646,40 +647,40 @@ static struct css_set *find_css_set(
 	/* First see if we already have a cgroup group that matches
 	 * the desired set */
 	read_lock(&css_set_lock);
-	res = find_existing_css_set(oldcg, cgrp, template);
-	if (res)
-		get_css_set(res);
+	cset = find_existing_css_set(old_cset, cgrp, template);
+	if (cset)
+		get_css_set(cset);
 	read_unlock(&css_set_lock);
 
-	if (res)
-		return res;
+	if (cset)
+		return cset;
 
-	res = kmalloc(sizeof(*res), GFP_KERNEL);
-	if (!res)
+	cset = kmalloc(sizeof(*cset), GFP_KERNEL);
+	if (!cset)
 		return NULL;
 
 	/* Allocate all the cg_cgroup_link objects that we'll need */
 	if (allocate_cg_links(root_count, &tmp_cg_links) < 0) {
-		kfree(res);
+		kfree(cset);
 		return NULL;
 	}
 
-	atomic_set(&res->refcount, 1);
-	INIT_LIST_HEAD(&res->cg_links);
-	INIT_LIST_HEAD(&res->tasks);
-	INIT_HLIST_NODE(&res->hlist);
+	atomic_set(&cset->refcount, 1);
+	INIT_LIST_HEAD(&cset->cg_links);
+	INIT_LIST_HEAD(&cset->tasks);
+	INIT_HLIST_NODE(&cset->hlist);
 
 	/* Copy the set of subsystem state objects generated in
 	 * find_existing_css_set() */
-	memcpy(res->subsys, template, sizeof(res->subsys));
+	memcpy(cset->subsys, template, sizeof(cset->subsys));
 
 	write_lock(&css_set_lock);
 	/* Add reference counts and links from the new css_set. */
-	list_for_each_entry(link, &oldcg->cg_links, cg_link_list) {
+	list_for_each_entry(link, &old_cset->cg_links, cg_link_list) {
 		struct cgroup *c = link->cgrp;
 		if (c->root == cgrp->root)
 			c = cgrp;
-		link_css_set(&tmp_cg_links, res, c);
+		link_css_set(&tmp_cg_links, cset, c);
 	}
 
 	BUG_ON(!list_empty(&tmp_cg_links));
@@ -687,12 +688,12 @@ static struct css_set *find_css_set(
 	css_set_count++;
 
 	/* Add this cgroup group to the hash table */
-	key = css_set_hash(res->subsys);
-	hash_add(css_set_table, &res->hlist, key);
+	key = css_set_hash(cset->subsys);
+	hash_add(css_set_table, &cset->hlist, key);
 
 	write_unlock(&css_set_lock);
 
-	return res;
+	return cset;
 }
 
 /*
@@ -702,7 +703,7 @@ static struct css_set *find_css_set(
 static struct cgroup *task_cgroup_from_root(struct task_struct *task,
 					    struct cgroupfs_root *root)
 {
-	struct css_set *css;
+	struct css_set *cset;
 	struct cgroup *res = NULL;
 
 	BUG_ON(!mutex_is_locked(&cgroup_mutex));
@@ -712,12 +713,12 @@ static struct cgroup *task_cgroup_from_root(struct task_struct *task,
 	 * task can't change groups, so the only thing that can happen
 	 * is that it exits and its css is set back to init_css_set.
 	 */
-	css = task->cgroups;
-	if (css == &init_css_set) {
+	cset = task->cgroups;
+	if (cset == &init_css_set) {
 		res = &root->top_cgroup;
 	} else {
 		struct cg_cgroup_link *link;
-		list_for_each_entry(link, &css->cg_links, cg_link_list) {
+		list_for_each_entry(link, &cset->cg_links, cg_link_list) {
 			struct cgroup *c = link->cgrp;
 			if (c->root == root) {
 				res = c;
@@ -1608,7 +1609,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		struct cgroupfs_root *existing_root;
 		const struct cred *cred;
 		int i;
-		struct css_set *cg;
+		struct css_set *cset;
 
 		BUG_ON(sb->s_root != NULL);
 
@@ -1666,8 +1667,8 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		/* Link the top cgroup in this hierarchy into all
 		 * the css_set objects */
 		write_lock(&css_set_lock);
-		hash_for_each(css_set_table, i, cg, hlist)
-			link_css_set(&tmp_cg_links, cg, root_cgrp);
+		hash_for_each(css_set_table, i, cset, hlist)
+			link_css_set(&tmp_cg_links, cset, root_cgrp);
 		write_unlock(&css_set_lock);
 
 		free_cg_links(&tmp_cg_links);
@@ -1947,10 +1948,11 @@ EXPORT_SYMBOL_GPL(cgroup_taskset_size);
  *
  * Must be called with cgroup_mutex and threadgroup locked.
  */
-static void cgroup_task_migrate(struct cgroup *oldcgrp,
-				struct task_struct *tsk, struct css_set *newcg)
+static void cgroup_task_migrate(struct cgroup *old_cgrp,
+				struct task_struct *tsk,
+				struct css_set *new_cset)
 {
-	struct css_set *oldcg;
+	struct css_set *old_cset;
 
 	/*
 	 * We are synchronized through threadgroup_lock() against PF_EXITING
@@ -1958,25 +1960,25 @@ static void cgroup_task_migrate(struct cgroup *oldcgrp,
 	 * css_set to init_css_set and dropping the old one.
 	 */
 	WARN_ON_ONCE(tsk->flags & PF_EXITING);
-	oldcg = tsk->cgroups;
+	old_cset = tsk->cgroups;
 
 	task_lock(tsk);
-	rcu_assign_pointer(tsk->cgroups, newcg);
+	rcu_assign_pointer(tsk->cgroups, new_cset);
 	task_unlock(tsk);
 
 	/* Update the css_set linked lists if we're using them */
 	write_lock(&css_set_lock);
 	if (!list_empty(&tsk->cg_list))
-		list_move(&tsk->cg_list, &newcg->tasks);
+		list_move(&tsk->cg_list, &new_cset->tasks);
 	write_unlock(&css_set_lock);
 
 	/*
-	 * We just gained a reference on oldcg by taking it from the task. As
-	 * trading it for newcg is protected by cgroup_mutex, we're safe to drop
-	 * it here; it will be freed under RCU.
+	 * We just gained a reference on old_cset by taking it from the
+	 * task. As trading it for new_cset is protected by cgroup_mutex,
+	 * we're safe to drop it here; it will be freed under RCU.
 	 */
-	set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
-	put_css_set(oldcg);
+	set_bit(CGRP_RELEASABLE, &old_cgrp->flags);
+	put_css_set(old_cset);
 }
 
 /**
@@ -2928,7 +2930,7 @@ static void cgroup_advance_iter(struct cgroup *cgrp,
 {
 	struct list_head *l = it->cg_link;
 	struct cg_cgroup_link *link;
-	struct css_set *cg;
+	struct css_set *cset;
 
 	/* Advance to the next non-empty css_set */
 	do {
@@ -2938,10 +2940,10 @@ static void cgroup_advance_iter(struct cgroup *cgrp,
 			return;
 		}
 		link = list_entry(l, struct cg_cgroup_link, cgrp_link_list);
-		cg = link->cg;
-	} while (list_empty(&cg->tasks));
+		cset = link->cg;
+	} while (list_empty(&cset->tasks));
 	it->cg_link = l;
-	it->task = cg->tasks.next;
+	it->task = cset->tasks.next;
 }
 
 /*
@@ -4519,7 +4521,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	struct cgroup_subsys_state *css;
 	int i, ret;
 	struct hlist_node *tmp;
-	struct css_set *cg;
+	struct css_set *cset;
 	unsigned long key;
 
 	/* check name and function validity */
@@ -4586,17 +4588,17 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	 * this is all done under the css_set_lock.
 	 */
 	write_lock(&css_set_lock);
-	hash_for_each_safe(css_set_table, i, tmp, cg, hlist) {
+	hash_for_each_safe(css_set_table, i, tmp, cset, hlist) {
 		/* skip entries that we already rehashed */
-		if (cg->subsys[ss->subsys_id])
+		if (cset->subsys[ss->subsys_id])
 			continue;
 		/* remove existing entry */
-		hash_del(&cg->hlist);
+		hash_del(&cset->hlist);
 		/* set new value */
-		cg->subsys[ss->subsys_id] = css;
+		cset->subsys[ss->subsys_id] = css;
 		/* recompute hash and restore entry */
-		key = css_set_hash(cg->subsys);
-		hash_add(css_set_table, &cg->hlist, key);
+		key = css_set_hash(cset->subsys);
+		hash_add(css_set_table, &cset->hlist, key);
 	}
 	write_unlock(&css_set_lock);
 
@@ -4656,13 +4658,13 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	 */
 	write_lock(&css_set_lock);
 	list_for_each_entry(link, &dummytop->css_sets, cgrp_link_list) {
-		struct css_set *cg = link->cg;
+		struct css_set *cset = link->cg;
 		unsigned long key;
 
-		hash_del(&cg->hlist);
-		cg->subsys[ss->subsys_id] = NULL;
-		key = css_set_hash(cg->subsys);
-		hash_add(css_set_table, &cg->hlist, key);
+		hash_del(&cset->hlist);
+		cset->subsys[ss->subsys_id] = NULL;
+		key = css_set_hash(cset->subsys);
+		hash_add(css_set_table, &cset->hlist, key);
 	}
 	write_unlock(&css_set_lock);
 
@@ -5009,7 +5011,7 @@ void cgroup_post_fork(struct task_struct *child)
  */
 void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 {
-	struct css_set *cg;
+	struct css_set *cset;
 	int i;
 
 	/*
@@ -5026,7 +5028,7 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 
 	/* Reassign the task to the init_css_set. */
 	task_lock(tsk);
-	cg = tsk->cgroups;
+	cset = tsk->cgroups;
 	tsk->cgroups = &init_css_set;
 
 	if (run_callbacks && need_forkexit_callback) {
@@ -5039,7 +5041,7 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 
 			if (ss->exit) {
 				struct cgroup *old_cgrp =
-					rcu_dereference_raw(cg->subsys[i])->cgroup;
+					rcu_dereference_raw(cset->subsys[i])->cgroup;
 				struct cgroup *cgrp = task_cgroup(tsk, i);
 				ss->exit(cgrp, old_cgrp, tsk);
 			}
@@ -5047,7 +5049,7 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 	}
 	task_unlock(tsk);
 
-	put_css_set_taskexit(cg);
+	put_css_set_taskexit(cset);
 }
 
 static void check_for_release(struct cgroup *cgrp)
@@ -5456,12 +5458,12 @@ static int current_css_set_cg_links_read(struct cgroup *cont,
 					 struct seq_file *seq)
 {
 	struct cg_cgroup_link *link;
-	struct css_set *cg;
+	struct css_set *cset;
 
 	read_lock(&css_set_lock);
 	rcu_read_lock();
-	cg = rcu_dereference(current->cgroups);
-	list_for_each_entry(link, &cg->cg_links, cg_link_list) {
+	cset = rcu_dereference(current->cgroups);
+	list_for_each_entry(link, &cset->cg_links, cg_link_list) {
 		struct cgroup *c = link->cgrp;
 		const char *name;
 
@@ -5486,11 +5488,11 @@ static int cgroup_css_links_read(struct cgroup *cont,
 
 	read_lock(&css_set_lock);
 	list_for_each_entry(link, &cont->css_sets, cgrp_link_list) {
-		struct css_set *cg = link->cg;
+		struct css_set *cset = link->cg;
 		struct task_struct *task;
 		int count = 0;
-		seq_printf(seq, "css_set %p\n", cg);
-		list_for_each_entry(task, &cg->tasks, cg_list) {
+		seq_printf(seq, "css_set %p\n", cset);
+		list_for_each_entry(task, &cset->tasks, cg_list) {
 			if (count++ > MAX_TASKS_SHOWN_PER_CSS) {
 				seq_puts(seq, "  ...\n");
 				break;
-- 
1.8.2.1
