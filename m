From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/4] Add a back-pointer from struct cg_cgroup_link to struct
	cgroup
Date: Tue, 28 Jul 2009 16:26:31 -0700
Message-ID: <20090728232631.20156.21291.stgit__12250.7262429737$1248825678$gmane$org@menage.mtv.corp.google.com>
References: <20090728232508.20156.17943.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090728232508.20156.17943.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Add a back-pointer from struct cg_cgroup_link to struct cgroup

Currently the cgroups code makes the assumption that the subsystem
pointers in a struct css_set uniquely identify the hierarchy->cgroup
mappings associated with the css_set; and there's no way to directly
identify the associated set of cgroups other than by indirecting
through the appropriate subsystem state pointers.

This patch removes the need for that assumption by adding a
back-pointer from struct cg_cgroup_link object to its associated
cgroup; this allows the set of cgroups to be determined by traversing
the cg_links list in the struct css_set.

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

---

 kernel/cgroup.c |  248 ++++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 199 insertions(+), 49 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 9491dbb..9972814 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -207,6 +207,7 @@ struct cg_cgroup_link {
 	 * cgroup, anchored on cgroup->css_sets
 	 */
 	struct list_head cgrp_link_list;
+	struct cgroup *cgrp;
 	/*
 	 * List running through cg_cgroup_links pointing at a
 	 * single css_set object, anchored on css_set->cg_links
@@ -233,8 +234,11 @@ static int cgroup_subsys_init_idr(struct cgroup_subsys *ss);
 static DEFINE_RWLOCK(css_set_lock);
 static int css_set_count;
 
-/* hash table for cgroup groups. This improves the performance to
- * find an existing css_set */
+/*
+ * hash table for cgroup groups. This improves the performance to find
+ * an existing css_set. This hash doesn't (currently) take into
+ * account cgroups in empty hierarchies.
+ */
 #define CSS_SET_HASH_BITS	7
 #define CSS_SET_TABLE_SIZE	(1 << CSS_SET_HASH_BITS)
 static struct hlist_head css_set_table[CSS_SET_TABLE_SIZE];
@@ -344,6 +348,78 @@ static inline void put_css_set_taskexit(struct css_set *cg)
 }
 
 /*
+ * compare_css_sets - helper function for find_existing_css_set().
+ * @cg: candidate css_set being tested
+ * @old_cg: existing css_set for a task
+ * @new_cgrp: cgroup that's being entered by the task
+ * @template: desired set of css pointers in css_set (pre-calculated)
+ *
+ * Returns true if "cg" matches "old_cg" except for the hierarchy
+ * which "new_cgrp" belongs to, for which it should match "new_cgrp".
+ */
+static bool compare_css_sets(struct css_set *cg,
+			     struct css_set *old_cg,
+			     struct cgroup *new_cgrp,
+			     struct cgroup_subsys_state *template[])
+{
+	struct list_head *l1, *l2;
+
+	if (memcmp(template, cg->subsys, sizeof(cg->subsys))) {
+		/* Not all subsystems matched */
+		return false;
+	}
+
+	/*
+	 * Compare cgroup pointers in order to distinguish between
+	 * different cgroups in heirarchies with no subsystems. We
+	 * could get by with just this check alone (and skip the
+	 * memcmp above) but on most setups the memcmp check will
+	 * avoid the need for this more expensive check on almost all
+	 * candidates.
+	 */
+
+	l1 = &cg->cg_links;
+	l2 = &old_cg->cg_links;
+	while (1) {
+		struct cg_cgroup_link *cgl1, *cgl2;
+		struct cgroup *cg1, *cg2;
+
+		l1 = l1->next;
+		l2 = l2->next;
+		/* See if we reached the end - both lists are equal length. */
+		if (l1 == &cg->cg_links) {
+			BUG_ON(l2 != &old_cg->cg_links);
+			break;
+		} else {
+			BUG_ON(l2 == &old_cg->cg_links);
+		}
+		/* Locate the cgroups associated with these links. */
+		cgl1 = list_entry(l1, struct cg_cgroup_link, cg_link_list);
+		cgl2 = list_entry(l2, struct cg_cgroup_link, cg_link_list);
+		cg1 = cgl1->cgrp;
+		cg2 = cgl2->cgrp;
+		/* Hierarchies should be linked in the same order. */
+		BUG_ON(cg1->root != cg2->root);
+
+		/*
+		 * If this hierarchy is the hierarchy of the cgroup
+		 * that's changing, then we need to check that this
+		 * css_set points to the new cgroup; if it's any other
+		 * hierarchy, then this css_set should point to the
+		 * same cgroup as the old css_set.
+		 */
+		if (cg1->root == new_cgrp->root) {
+			if (cg1 != new_cgrp)
+				return false;
+		} else {
+			if (cg1 != cg2)
+				return false;
+		}
+	}
+	return true;
+}
+
+/*
  * find_existing_css_set() is a helper for
  * find_css_set(), and checks to see whether an existing
  * css_set is suitable.
@@ -384,10 +460,11 @@ static struct css_set *find_existing_css_set(
 
 	hhead = css_set_hash(template);
 	hlist_for_each_entry(cg, node, hhead, hlist) {
-		if (!memcmp(template, cg->subsys, sizeof(cg->subsys))) {
-			/* All subsystems matched */
-			return cg;
-		}
+		if (!compare_css_sets(cg, oldcg, cgrp, template))
+			continue;
+
+		/* This css_set matches what we need */
+		return cg;
 	}
 
 	/* No existing cgroup group matched */
@@ -441,8 +518,13 @@ static void link_css_set(struct list_head *tmp_cg_links,
 	link = list_first_entry(tmp_cg_links, struct cg_cgroup_link,
 				cgrp_link_list);
 	link->cg = cg;
+	link->cgrp = cgrp;
 	list_move(&link->cgrp_link_list, &cgrp->css_sets);
-	list_add(&link->cg_link_list, &cg->cg_links);
+	/*
+	 * Always add links to the tail of the list so that the list
+	 * is sorted by order of hierarchy creation
+	 */
+	list_add_tail(&link->cg_link_list, &cg->cg_links);
 }
 
 /*
@@ -462,6 +544,7 @@ static struct css_set *find_css_set(
 	struct list_head tmp_cg_links;
 
 	struct hlist_head *hhead;
+	struct cg_cgroup_link *link;
 
 	/* First see if we already have a cgroup group that matches
 	 * the desired set */
@@ -497,18 +580,14 @@ static struct css_set *find_css_set(
 	/* Add reference counts and links from the new css_set. */
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup *cgrp = res->subsys[i]->cgroup;
-		struct cgroup_subsys *ss = subsys[i];
 		atomic_inc(&cgrp->count);
-		/*
-		 * We want to add a link once per cgroup, so we
-		 * only do it for the first subsystem in each
-		 * hierarchy
-		 */
-		if (ss->root->subsys_list.next == &ss->sibling)
-			link_css_set(&tmp_cg_links, res, cgrp);
 	}
-	if (list_empty(&rootnode.subsys_list))
-		link_css_set(&tmp_cg_links, res, dummytop);
+	list_for_each_entry(link, &oldcg->cg_links, cg_link_list) {
+		struct cgroup *c = link->cgrp;
+		if (c->root == cgrp->root)
+			c = cgrp;
+		link_css_set(&tmp_cg_links, res, c);
+	}
 
 	BUG_ON(!list_empty(&tmp_cg_links));
 
@@ -524,6 +603,41 @@ static struct css_set *find_css_set(
 }
 
 /*
+ * Return the cgroup for "task" from the given hierarchy. Must be
+ * called with cgroup_mutex held.
+ */
+static struct cgroup *task_cgroup_from_root(struct task_struct *task,
+					    struct cgroupfs_root *root)
+{
+	struct css_set *css;
+	struct cgroup *res = NULL;
+
+	BUG_ON(!mutex_is_locked(&cgroup_mutex));
+	read_lock(&css_set_lock);
+	/*
+	 * No need to lock the task - since we hold cgroup_mutex the
+	 * task can't change groups, so the only thing that can happen
+	 * is that it exits and its css is set back to init_css_set.
+	 */
+	css = task->cgroups;
+	if (css == &init_css_set) {
+		res = &root->top_cgroup;
+	} else {
+		struct cg_cgroup_link *link;
+		list_for_each_entry(link, &css->cg_links, cg_link_list) {
+			struct cgroup *c = link->cgrp;
+			if (c->root == root) {
+				res = c;
+				break;
+			}
+		}
+	}
+	read_unlock(&css_set_lock);
+	BUG_ON(!res);
+	return res;
+}
+
+/*
  * There is one global cgroup mutex. We also require taking
  * task_lock() when dereferencing a task's cgroup subsys pointers.
  * See "The task_lock() exception", at the end of this comment.
@@ -1350,27 +1464,6 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 	return 0;
 }
 
-/*
- * Return the first subsystem attached to a cgroup's hierarchy, and
- * its subsystem id.
- */
-
-static void get_first_subsys(const struct cgroup *cgrp,
-			struct cgroup_subsys_state **css, int *subsys_id)
-{
-	const struct cgroupfs_root *root = cgrp->root;
-	const struct cgroup_subsys *test_ss;
-	BUG_ON(list_empty(&root->subsys_list));
-	test_ss = list_entry(root->subsys_list.next,
-			     struct cgroup_subsys, sibling);
-	if (css) {
-		*css = cgrp->subsys[test_ss->subsys_id];
-		BUG_ON(!*css);
-	}
-	if (subsys_id)
-		*subsys_id = test_ss->subsys_id;
-}
-
 /**
  * cgroup_attach_task - attach task 'tsk' to cgroup 'cgrp'
  * @cgrp: the cgroup the task is attaching to
@@ -1387,12 +1480,9 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	struct css_set *cg;
 	struct css_set *newcg;
 	struct cgroupfs_root *root = cgrp->root;
-	int subsys_id;
-
-	get_first_subsys(cgrp, NULL, &subsys_id);
 
 	/* Nothing to do if the task is already in that cgroup */
-	oldcgrp = task_cgroup(tsk, subsys_id);
+	oldcgrp = task_cgroup_from_root(tsk, root);
 	if (cgrp == oldcgrp)
 		return 0;
 
@@ -1950,7 +2040,7 @@ int cgroup_task_count(const struct cgroup *cgrp)
  * the start of a css_set
  */
 static void cgroup_advance_iter(struct cgroup *cgrp,
-					  struct cgroup_iter *it)
+				struct cgroup_iter *it)
 {
 	struct list_head *l = it->cg_link;
 	struct cg_cgroup_link *link;
@@ -2944,6 +3034,7 @@ int __init cgroup_init_early(void)
 	init_task.cgroups = &init_css_set;
 
 	init_css_set_link.cg = &init_css_set;
+	init_css_set_link.cgrp = dummytop;
 	list_add(&init_css_set_link.cgrp_link_list,
 		 &rootnode.top_cgroup.css_sets);
 	list_add(&init_css_set_link.cg_link_list,
@@ -3051,7 +3142,6 @@ static int proc_cgroup_show(struct seq_file *m, void *v)
 	for_each_active_root(root) {
 		struct cgroup_subsys *ss;
 		struct cgroup *cgrp;
-		int subsys_id;
 		int count = 0;
 
 		seq_printf(m, "%lu:", root->subsys_bits);
@@ -3061,8 +3151,7 @@ static int proc_cgroup_show(struct seq_file *m, void *v)
 			seq_printf(m, "%sname=%s", count ? "," : "",
 				   root->name);
 		seq_putc(m, ':');
-		get_first_subsys(&root->top_cgroup, NULL, &subsys_id);
-		cgrp = task_cgroup(tsk, subsys_id);
+		cgrp = task_cgroup_from_root(tsk, root);
 		retval = cgroup_path(cgrp, buf, PAGE_SIZE);
 		if (retval < 0)
 			goto out_unlock;
@@ -3388,13 +3477,11 @@ int cgroup_is_descendant(const struct cgroup *cgrp, struct task_struct *task)
 {
 	int ret;
 	struct cgroup *target;
-	int subsys_id;
 
 	if (cgrp == dummytop)
 		return 1;
 
-	get_first_subsys(cgrp, NULL, &subsys_id);
-	target = task_cgroup(task, subsys_id);
+	target = task_cgroup_from_root(task, cgrp->root);
 	while (cgrp != target && cgrp!= cgrp->top_cgroup)
 		cgrp = cgrp->parent;
 	ret = (cgrp == target);
@@ -3804,6 +3891,59 @@ static u64 current_css_set_refcount_read(struct cgroup *cont,
 	return count;
 }
 
+static int current_css_set_cg_links_read(struct cgroup *cont,
+					 struct cftype *cft,
+					 struct seq_file *seq)
+{
+	struct cg_cgroup_link *link;
+	struct css_set *cg;
+
+	read_lock(&css_set_lock);
+	rcu_read_lock();
+	cg = rcu_dereference(current->cgroups);
+	list_for_each_entry(link, &cg->cg_links, cg_link_list) {
+		struct cgroup *c = link->cgrp;
+		const char *name;
+
+		if (c->dentry)
+			name = c->dentry->d_name.name;
+		else
+			name = "?";
+		seq_printf(seq, "Root %lu group %s\n",
+			   c->root->subsys_bits, name);
+	}
+	rcu_read_unlock();
+	read_unlock(&css_set_lock);
+	return 0;
+}
+
+#define MAX_TASKS_SHOWN_PER_CSS 25
+static int cgroup_css_links_read(struct cgroup *cont,
+				 struct cftype *cft,
+				 struct seq_file *seq)
+{
+	struct cg_cgroup_link *link;
+
+	read_lock(&css_set_lock);
+	list_for_each_entry(link, &cont->css_sets, cgrp_link_list) {
+		struct css_set *cg = link->cg;
+		struct task_struct *task;
+		int count = 0;
+		seq_printf(seq, "css_set %p\n", cg);
+		list_for_each_entry(task, &cg->tasks, cg_list) {
+			if (count++ > MAX_TASKS_SHOWN_PER_CSS) {
+				seq_puts(seq, "  ...\n");
+				break;
+			} else {
+				seq_printf(seq, "  task %d\n",
+					   task_pid_vnr(task));
+			}
+		}
+	}
+	read_unlock(&css_set_lock);
+	return 0;
+}
+
 static u64 releasable_read(struct cgroup *cgrp, struct cftype *cft)
 {
 	return test_bit(CGRP_RELEASABLE, &cgrp->flags);
@@ -3830,6 +3970,16 @@ static struct cftype debug_files[] =  {
 	},
 
 	{
+		.name = "current_css_set_cg_links",
+		.read_seq_string = current_css_set_cg_links_read,
+	},
+
+	{
+		.name = "cgroup_css_links",
+		.read_seq_string = cgroup_css_links_read,
+	},
+
+	{
 		.name = "releasable",
 		.read_u64 = releasable_read,
 	},
