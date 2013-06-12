From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 03/11] cgroup: bring some sanity to naming around
	cg_cgroup_link
Date: Wed, 12 Jun 2013 14:03:08 -0700
Message-ID: <1371070996-20613-4-git-send-email-tj@kernel.org>
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

cgroups and css_sets are mapped M:N and this M:N mapping is
represented by struct cg_cgroup_link which points to forms linked
lists on both sides.  The naming around this already confusing struct
is pretty bad.

From cgroup side, it starts off ->css_sets and runs through
->cgrp_link_list.  From css_set side, it starts off ->cg_links and
runs through ->cg_link_list.  This is rather reversed as
cgrp_link_list is used to iterate css_sets and cg_link_list cgroups.
Also, this is the only place which is still using the confusing "cg"
for css_sets.  This patch cleans it up a bit.

* s/cgroup->css_sets/cgroup->cset_links/
  s/css_set->cg_links/css_set->cgrp_links/
  s/cgroup_iter->cg_link/cgroup_iter->cset_link/

* s/cg_cgroup_link/cgrp_cset_link/

* s/cgrp_cset_link->cg/cgrp_cset_link->cset/
  s/cgrp_cset_link->cgrp_link_list/cgrp_cset_link->cset_link/
  s/cgrp_cset_link->cg_link_list/cgrp_cset_link->cgrp_link/

* s/init_css_set_link/init_cgrp_cset_link/
  s/free_cg_links/free_cgrp_cset_links/
  s/allocate_cg_links/allocate_cgrp_cset_links/

* s/cgl[12]/link[12]/ in compare_css_sets()

* s/saved_link/tmp_link/ s/tmp/tmp_links/ and a couple similar
  adustments.

* Comment and whiteline adjustments.

After the changes, we have

	list_for_each_entry(link, &cont->cset_links, cset_link) {
		struct css_set *cset = link->cset;

instead of

	list_for_each_entry(link, &cont->css_sets, cgrp_link_list) {
		struct css_set *cset = link->cg;

This patch is purely cosmetic.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  15 ++--
 kernel/cgroup.c        | 226 ++++++++++++++++++++++++-------------------------
 2 files changed, 120 insertions(+), 121 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 5830592..0e32855 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -215,10 +215,10 @@ struct cgroup {
 	struct cgroupfs_root *root;
 
 	/*
-	 * List of cg_cgroup_links pointing at css_sets with
-	 * tasks in this cgroup. Protected by css_set_lock
+	 * List of cgrp_cset_links pointing at css_sets with tasks in this
+	 * cgroup.  Protected by css_set_lock.
 	 */
-	struct list_head css_sets;
+	struct list_head cset_links;
 
 	struct list_head allcg_node;	/* cgroupfs_root->allcg_list */
 	struct list_head cft_q_node;	/* used during cftype add/rm */
@@ -365,11 +365,10 @@ struct css_set {
 	struct list_head tasks;
 
 	/*
-	 * List of cg_cgroup_link objects on link chains from
-	 * cgroups referenced from this css_set. Protected by
-	 * css_set_lock
+	 * List of cgrp_cset_links pointing at cgroups referenced from this
+	 * css_set.  Protected by css_set_lock.
 	 */
-	struct list_head cg_links;
+	struct list_head cgrp_links;
 
 	/*
 	 * Set of subsystem states, one for each subsystem. This array
@@ -792,7 +791,7 @@ struct cgroup *cgroup_next_descendant_post(struct cgroup *pos,
 
 /* A cgroup_iter should be treated as an opaque object */
 struct cgroup_iter {
-	struct list_head *cg_link;
+	struct list_head *cset_link;
 	struct list_head *task;
 };
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e7f6845..0b5cd0e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -315,20 +315,24 @@ static void cgroup_release_agent(struct work_struct *work);
 static DECLARE_WORK(release_agent_work, cgroup_release_agent);
 static void check_for_release(struct cgroup *cgrp);
 
-/* Link structure for associating css_set objects with cgroups */
-struct cg_cgroup_link {
-	/*
-	 * List running through cg_cgroup_links associated with a
-	 * cgroup, anchored on cgroup->css_sets
-	 */
-	struct list_head cgrp_link_list;
-	struct cgroup *cgrp;
-	/*
-	 * List running through cg_cgroup_links pointing at a
-	 * single css_set object, anchored on css_set->cg_links
-	 */
-	struct list_head cg_link_list;
-	struct css_set *cg;
+/*
+ * A cgroup can be associated with multiple css_sets as different tasks may
+ * belong to different cgroups on different hierarchies.  In the other
+ * direction, a css_set is naturally associated with multiple cgroups.
+ * This M:N relationship is represented by the following link structure
+ * which exists for each association and allows traversing the associations
+ * from both sides.
+ */
+struct cgrp_cset_link {
+	/* the cgroup and css_set this link associates */
+	struct cgroup		*cgrp;
+	struct css_set		*cset;
+
+	/* list of cgrp_cset_links anchored at cgrp->cset_links */
+	struct list_head	cset_link;
+
+	/* list of cgrp_cset_links anchored at css_set->cgrp_links */
+	struct list_head	cgrp_link;
 };
 
 /* The default css_set - used by init and its children prior to any
@@ -339,7 +343,7 @@ struct cg_cgroup_link {
  */
 
 static struct css_set init_css_set;
-static struct cg_cgroup_link init_css_set_link;
+static struct cgrp_cset_link init_cgrp_cset_link;
 
 static int cgroup_init_idr(struct cgroup_subsys *ss,
 			   struct cgroup_subsys_state *css);
@@ -378,8 +382,7 @@ static int use_task_css_set_links __read_mostly;
 
 static void __put_css_set(struct css_set *cset, int taskexit)
 {
-	struct cg_cgroup_link *link;
-	struct cg_cgroup_link *saved_link;
+	struct cgrp_cset_link *link, *tmp_link;
 
 	/*
 	 * Ensure that the refcount doesn't hit zero while any readers
@@ -398,12 +401,11 @@ static void __put_css_set(struct css_set *cset, int taskexit)
 	hash_del(&cset->hlist);
 	css_set_count--;
 
-	list_for_each_entry_safe(link, saved_link, &cset->cg_links,
-				 cg_link_list) {
+	list_for_each_entry_safe(link, tmp_link, &cset->cgrp_links, cgrp_link) {
 		struct cgroup *cgrp = link->cgrp;
 
-		list_del(&link->cg_link_list);
-		list_del(&link->cgrp_link_list);
+		list_del(&link->cset_link);
+		list_del(&link->cgrp_link);
 
 		/*
 		 * We may not be holding cgroup_mutex, and if cgrp->count is
@@ -475,26 +477,26 @@ static bool compare_css_sets(struct css_set *cset,
 	 * candidates.
 	 */
 
-	l1 = &cset->cg_links;
-	l2 = &old_cset->cg_links;
+	l1 = &cset->cgrp_links;
+	l2 = &old_cset->cgrp_links;
 	while (1) {
-		struct cg_cgroup_link *cgl1, *cgl2;
+		struct cgrp_cset_link *link1, *link2;
 		struct cgroup *cgrp1, *cgrp2;
 
 		l1 = l1->next;
 		l2 = l2->next;
 		/* See if we reached the end - both lists are equal length. */
-		if (l1 == &cset->cg_links) {
-			BUG_ON(l2 != &old_cset->cg_links);
+		if (l1 == &cset->cgrp_links) {
+			BUG_ON(l2 != &old_cset->cgrp_links);
 			break;
 		} else {
-			BUG_ON(l2 == &old_cset->cg_links);
+			BUG_ON(l2 == &old_cset->cgrp_links);
 		}
 		/* Locate the cgroups associated with these links. */
-		cgl1 = list_entry(l1, struct cg_cgroup_link, cg_link_list);
-		cgl2 = list_entry(l2, struct cg_cgroup_link, cg_link_list);
-		cgrp1 = cgl1->cgrp;
-		cgrp2 = cgl2->cgrp;
+		link1 = list_entry(l1, struct cgrp_cset_link, cgrp_link);
+		link2 = list_entry(l2, struct cgrp_cset_link, cgrp_link);
+		cgrp1 = link1->cgrp;
+		cgrp2 = link2->cgrp;
 		/* Hierarchies should be linked in the same order. */
 		BUG_ON(cgrp1->root != cgrp2->root);
 
@@ -569,61 +571,64 @@ static struct css_set *find_existing_css_set(struct css_set *old_cset,
 	return NULL;
 }
 
-static void free_cg_links(struct list_head *tmp)
+static void free_cgrp_cset_links(struct list_head *links_to_free)
 {
-	struct cg_cgroup_link *link;
-	struct cg_cgroup_link *saved_link;
+	struct cgrp_cset_link *link, *tmp_link;
 
-	list_for_each_entry_safe(link, saved_link, tmp, cgrp_link_list) {
-		list_del(&link->cgrp_link_list);
+	list_for_each_entry_safe(link, tmp_link, links_to_free, cset_link) {
+		list_del(&link->cset_link);
 		kfree(link);
 	}
 }
 
-/*
- * allocate_cg_links() allocates "count" cg_cgroup_link structures
- * and chains them on tmp through their cgrp_link_list fields. Returns 0 on
- * success or a negative error
+/**
+ * allocate_cgrp_cset_links - allocate cgrp_cset_links
+ * @count: the number of links to allocate
+ * @tmp_links: list_head the allocated links are put on
+ *
+ * Allocate @count cgrp_cset_link structures and chain them on @tmp_links
+ * through ->cset_link.  Returns 0 on success or -errno.
  */
-static int allocate_cg_links(int count, struct list_head *tmp)
+static int allocate_cgrp_cset_links(int count, struct list_head *tmp_links)
 {
-	struct cg_cgroup_link *link;
+	struct cgrp_cset_link *link;
 	int i;
-	INIT_LIST_HEAD(tmp);
+
+	INIT_LIST_HEAD(tmp_links);
+
 	for (i = 0; i < count; i++) {
 		link = kmalloc(sizeof(*link), GFP_KERNEL);
 		if (!link) {
-			free_cg_links(tmp);
+			free_cgrp_cset_links(tmp_links);
 			return -ENOMEM;
 		}
-		list_add(&link->cgrp_link_list, tmp);
+		list_add(&link->cset_link, tmp_links);
 	}
 	return 0;
 }
 
 /**
  * link_css_set - a helper function to link a css_set to a cgroup
- * @tmp_cg_links: cg_cgroup_link objects allocated by allocate_cg_links()
+ * @tmp_links: cgrp_cset_link objects allocated by allocate_cgrp_cset_links()
  * @cset: the css_set to be linked
  * @cgrp: the destination cgroup
  */
-static void link_css_set(struct list_head *tmp_cg_links,
-			 struct css_set *cset, struct cgroup *cgrp)
+static void link_css_set(struct list_head *tmp_links, struct css_set *cset,
+			 struct cgroup *cgrp)
 {
-	struct cg_cgroup_link *link;
+	struct cgrp_cset_link *link;
 
-	BUG_ON(list_empty(tmp_cg_links));
-	link = list_first_entry(tmp_cg_links, struct cg_cgroup_link,
-				cgrp_link_list);
-	link->cg = cset;
+	BUG_ON(list_empty(tmp_links));
+	link = list_first_entry(tmp_links, struct cgrp_cset_link, cset_link);
+	link->cset = cset;
 	link->cgrp = cgrp;
 	atomic_inc(&cgrp->count);
-	list_move(&link->cgrp_link_list, &cgrp->css_sets);
+	list_move(&link->cset_link, &cgrp->cset_links);
 	/*
 	 * Always add links to the tail of the list so that the list
 	 * is sorted by order of hierarchy creation
 	 */
-	list_add_tail(&link->cg_link_list, &cset->cg_links);
+	list_add_tail(&link->cgrp_link, &cset->cgrp_links);
 }
 
 /*
@@ -638,10 +643,8 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 {
 	struct css_set *cset;
 	struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
-
-	struct list_head tmp_cg_links;
-
-	struct cg_cgroup_link *link;
+	struct list_head tmp_links;
+	struct cgrp_cset_link *link;
 	unsigned long key;
 
 	/* First see if we already have a cgroup group that matches
@@ -659,14 +662,14 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 	if (!cset)
 		return NULL;
 
-	/* Allocate all the cg_cgroup_link objects that we'll need */
-	if (allocate_cg_links(root_count, &tmp_cg_links) < 0) {
+	/* Allocate all the cgrp_cset_link objects that we'll need */
+	if (allocate_cgrp_cset_links(root_count, &tmp_links) < 0) {
 		kfree(cset);
 		return NULL;
 	}
 
 	atomic_set(&cset->refcount, 1);
-	INIT_LIST_HEAD(&cset->cg_links);
+	INIT_LIST_HEAD(&cset->cgrp_links);
 	INIT_LIST_HEAD(&cset->tasks);
 	INIT_HLIST_NODE(&cset->hlist);
 
@@ -676,14 +679,15 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 
 	write_lock(&css_set_lock);
 	/* Add reference counts and links from the new css_set. */
-	list_for_each_entry(link, &old_cset->cg_links, cg_link_list) {
+	list_for_each_entry(link, &old_cset->cgrp_links, cgrp_link) {
 		struct cgroup *c = link->cgrp;
+
 		if (c->root == cgrp->root)
 			c = cgrp;
-		link_css_set(&tmp_cg_links, cset, c);
+		link_css_set(&tmp_links, cset, c);
 	}
 
-	BUG_ON(!list_empty(&tmp_cg_links));
+	BUG_ON(!list_empty(&tmp_links));
 
 	css_set_count++;
 
@@ -717,9 +721,11 @@ static struct cgroup *task_cgroup_from_root(struct task_struct *task,
 	if (cset == &init_css_set) {
 		res = &root->top_cgroup;
 	} else {
-		struct cg_cgroup_link *link;
-		list_for_each_entry(link, &cset->cg_links, cg_link_list) {
+		struct cgrp_cset_link *link;
+
+		list_for_each_entry(link, &cset->cgrp_links, cgrp_link) {
 			struct cgroup *c = link->cgrp;
+
 			if (c->root == root) {
 				res = c;
 				break;
@@ -1405,7 +1411,7 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	INIT_LIST_HEAD(&cgrp->sibling);
 	INIT_LIST_HEAD(&cgrp->children);
 	INIT_LIST_HEAD(&cgrp->files);
-	INIT_LIST_HEAD(&cgrp->css_sets);
+	INIT_LIST_HEAD(&cgrp->cset_links);
 	INIT_LIST_HEAD(&cgrp->allcg_node);
 	INIT_LIST_HEAD(&cgrp->release_list);
 	INIT_LIST_HEAD(&cgrp->pidlists);
@@ -1604,7 +1610,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	BUG_ON(!root);
 	if (root == opts.new_root) {
 		/* We used the new root structure, so this is a new hierarchy */
-		struct list_head tmp_cg_links;
+		struct list_head tmp_links;
 		struct cgroup *root_cgrp = &root->top_cgroup;
 		struct cgroupfs_root *existing_root;
 		const struct cred *cred;
@@ -1636,7 +1642,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		 * that's us. The worst that can happen is that we
 		 * have some link structures left over
 		 */
-		ret = allocate_cg_links(css_set_count, &tmp_cg_links);
+		ret = allocate_cgrp_cset_links(css_set_count, &tmp_links);
 		if (ret)
 			goto unlock_drop;
 
@@ -1646,7 +1652,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 
 		ret = rebind_subsystems(root, root->subsys_mask);
 		if (ret == -EBUSY) {
-			free_cg_links(&tmp_cg_links);
+			free_cgrp_cset_links(&tmp_links);
 			goto unlock_drop;
 		}
 		/*
@@ -1668,10 +1674,10 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		 * the css_set objects */
 		write_lock(&css_set_lock);
 		hash_for_each(css_set_table, i, cset, hlist)
-			link_css_set(&tmp_cg_links, cset, root_cgrp);
+			link_css_set(&tmp_links, cset, root_cgrp);
 		write_unlock(&css_set_lock);
 
-		free_cg_links(&tmp_cg_links);
+		free_cgrp_cset_links(&tmp_links);
 
 		BUG_ON(!list_empty(&root_cgrp->children));
 		BUG_ON(root->number_of_cgroups != 1);
@@ -1725,9 +1731,8 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 static void cgroup_kill_sb(struct super_block *sb) {
 	struct cgroupfs_root *root = sb->s_fs_info;
 	struct cgroup *cgrp = &root->top_cgroup;
+	struct cgrp_cset_link *link, *tmp_link;
 	int ret;
-	struct cg_cgroup_link *link;
-	struct cg_cgroup_link *saved_link;
 
 	BUG_ON(!root);
 
@@ -1743,15 +1748,14 @@ static void cgroup_kill_sb(struct super_block *sb) {
 	BUG_ON(ret);
 
 	/*
-	 * Release all the links from css_sets to this hierarchy's
+	 * Release all the links from cset_links to this hierarchy's
 	 * root cgroup
 	 */
 	write_lock(&css_set_lock);
 
-	list_for_each_entry_safe(link, saved_link, &cgrp->css_sets,
-				 cgrp_link_list) {
-		list_del(&link->cg_link_list);
-		list_del(&link->cgrp_link_list);
+	list_for_each_entry_safe(link, tmp_link, &cgrp->cset_links, cset_link) {
+		list_del(&link->cset_link);
+		list_del(&link->cgrp_link);
 		kfree(link);
 	}
 	write_unlock(&css_set_lock);
@@ -2911,12 +2915,11 @@ int cgroup_rm_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
 int cgroup_task_count(const struct cgroup *cgrp)
 {
 	int count = 0;
-	struct cg_cgroup_link *link;
+	struct cgrp_cset_link *link;
 
 	read_lock(&css_set_lock);
-	list_for_each_entry(link, &cgrp->css_sets, cgrp_link_list) {
-		count += atomic_read(&link->cg->refcount);
-	}
+	list_for_each_entry(link, &cgrp->cset_links, cset_link)
+		count += atomic_read(&link->cset->refcount);
 	read_unlock(&css_set_lock);
 	return count;
 }
@@ -2925,24 +2928,23 @@ int cgroup_task_count(const struct cgroup *cgrp)
  * Advance a list_head iterator.  The iterator should be positioned at
  * the start of a css_set
  */
-static void cgroup_advance_iter(struct cgroup *cgrp,
-				struct cgroup_iter *it)
+static void cgroup_advance_iter(struct cgroup *cgrp, struct cgroup_iter *it)
 {
-	struct list_head *l = it->cg_link;
-	struct cg_cgroup_link *link;
+	struct list_head *l = it->cset_link;
+	struct cgrp_cset_link *link;
 	struct css_set *cset;
 
 	/* Advance to the next non-empty css_set */
 	do {
 		l = l->next;
-		if (l == &cgrp->css_sets) {
-			it->cg_link = NULL;
+		if (l == &cgrp->cset_links) {
+			it->cset_link = NULL;
 			return;
 		}
-		link = list_entry(l, struct cg_cgroup_link, cgrp_link_list);
-		cset = link->cg;
+		link = list_entry(l, struct cgrp_cset_link, cset_link);
+		cset = link->cset;
 	} while (list_empty(&cset->tasks));
-	it->cg_link = l;
+	it->cset_link = l;
 	it->task = cset->tasks.next;
 }
 
@@ -3163,7 +3165,7 @@ void cgroup_iter_start(struct cgroup *cgrp, struct cgroup_iter *it)
 		cgroup_enable_task_cg_lists();
 
 	read_lock(&css_set_lock);
-	it->cg_link = &cgrp->css_sets;
+	it->cset_link = &cgrp->cset_links;
 	cgroup_advance_iter(cgrp, it);
 }
 
@@ -3172,16 +3174,16 @@ struct task_struct *cgroup_iter_next(struct cgroup *cgrp,
 {
 	struct task_struct *res;
 	struct list_head *l = it->task;
-	struct cg_cgroup_link *link;
+	struct cgrp_cset_link *link;
 
 	/* If the iterator cg is NULL, we have no tasks */
-	if (!it->cg_link)
+	if (!it->cset_link)
 		return NULL;
 	res = list_entry(l, struct task_struct, cg_list);
 	/* Advance iterator to find next entry */
 	l = l->next;
-	link = list_entry(it->cg_link, struct cg_cgroup_link, cgrp_link_list);
-	if (l == &link->cg->tasks) {
+	link = list_entry(it->cset_link, struct cgrp_cset_link, cset_link);
+	if (l == &link->cset->tasks) {
 		/* We reached the end of this task list - move on to
 		 * the next cg_cgroup_link */
 		cgroup_advance_iter(cgrp, it);
@@ -4628,7 +4630,7 @@ EXPORT_SYMBOL_GPL(cgroup_load_subsys);
  */
 void cgroup_unload_subsys(struct cgroup_subsys *ss)
 {
-	struct cg_cgroup_link *link;
+	struct cgrp_cset_link *link;
 
 	BUG_ON(ss->module == NULL);
 
@@ -4657,8 +4659,8 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	 * in loading, we need to pay our respects to the hashtable gods.
 	 */
 	write_lock(&css_set_lock);
-	list_for_each_entry(link, &dummytop->css_sets, cgrp_link_list) {
-		struct css_set *cset = link->cg;
+	list_for_each_entry(link, &dummytop->cset_links, cset_link) {
+		struct css_set *cset = link->cset;
 		unsigned long key;
 
 		hash_del(&cset->hlist);
@@ -4691,7 +4693,7 @@ int __init cgroup_init_early(void)
 {
 	int i;
 	atomic_set(&init_css_set.refcount, 1);
-	INIT_LIST_HEAD(&init_css_set.cg_links);
+	INIT_LIST_HEAD(&init_css_set.cgrp_links);
 	INIT_LIST_HEAD(&init_css_set.tasks);
 	INIT_HLIST_NODE(&init_css_set.hlist);
 	css_set_count = 1;
@@ -4699,12 +4701,10 @@ int __init cgroup_init_early(void)
 	root_count = 1;
 	init_task.cgroups = &init_css_set;
 
-	init_css_set_link.cg = &init_css_set;
-	init_css_set_link.cgrp = dummytop;
-	list_add(&init_css_set_link.cgrp_link_list,
-		 &rootnode.top_cgroup.css_sets);
-	list_add(&init_css_set_link.cg_link_list,
-		 &init_css_set.cg_links);
+	init_cgrp_cset_link.cset = &init_css_set;
+	init_cgrp_cset_link.cgrp = dummytop;
+	list_add(&init_cgrp_cset_link.cset_link, &rootnode.top_cgroup.cset_links);
+	list_add(&init_cgrp_cset_link.cgrp_link, &init_css_set.cgrp_links);
 
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
@@ -5457,13 +5457,13 @@ static int current_css_set_cg_links_read(struct cgroup *cont,
 					 struct cftype *cft,
 					 struct seq_file *seq)
 {
-	struct cg_cgroup_link *link;
+	struct cgrp_cset_link *link;
 	struct css_set *cset;
 
 	read_lock(&css_set_lock);
 	rcu_read_lock();
 	cset = rcu_dereference(current->cgroups);
-	list_for_each_entry(link, &cset->cg_links, cg_link_list) {
+	list_for_each_entry(link, &cset->cgrp_links, cgrp_link) {
 		struct cgroup *c = link->cgrp;
 		const char *name;
 
@@ -5484,11 +5484,11 @@ static int cgroup_css_links_read(struct cgroup *cont,
 				 struct cftype *cft,
 				 struct seq_file *seq)
 {
-	struct cg_cgroup_link *link;
+	struct cgrp_cset_link *link;
 
 	read_lock(&css_set_lock);
-	list_for_each_entry(link, &cont->css_sets, cgrp_link_list) {
-		struct css_set *cset = link->cg;
+	list_for_each_entry(link, &cont->cset_links, cset_link) {
+		struct css_set *cset = link->cset;
 		struct task_struct *task;
 		int count = 0;
 		seq_printf(seq, "css_set %p\n", cset);
-- 
1.8.2.1
