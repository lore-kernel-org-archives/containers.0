From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 03/12] cgroup: implement cgroup->e_csets[]
Date: Thu, 27 Mar 2014 22:40:52 -0400
Message-ID: <1395974461-12735-4-git-send-email-tj@kernel.org>
References: <1395974461-12735-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1395974461-12735-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On the default unified hierarchy, a cgroup may be associated with
csses of its ancestors, which means that a css of a given cgroup may
be associated with css_sets of descendant cgroups.  This means that we
can't walk all tasks associated with a css by iterating the css_sets
associated with the cgroup as there are css_sets which are pointing to
the css but linked on the descendants.

This patch adds per-subsystem list heads cgroup->e_csets[].  Any
css_set which is pointing to a css is linked to
css->cgroup->e_csets[$SUBSYS_ID] through
css_set->e_cset_node[$SUBSYS_ID].  The lists are protected by
css_set_rwsem and will allow us to walk all css_sets associated with a
given css so that we can find out all associated tasks.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 18 ++++++++++++++++++
 kernel/cgroup.c        | 30 ++++++++++++++++++++++++++++--
 2 files changed, 46 insertions(+), 2 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index e351a18..e902eee 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -188,6 +188,15 @@ struct cgroup {
 	struct list_head cset_links;
 
 	/*
+	 * On the default hierarchy, a css_set for a cgroup with some
+	 * susbsys disabled will point to css's which are associated with
+	 * the closest ancestor which has the subsys enabled.  The
+	 * following lists all css_sets which point to this cgroup's css
+	 * for the given subsystem.
+	 */
+	struct list_head e_csets[CGROUP_SUBSYS_COUNT];
+
+	/*
 	 * Linked list running through all cgroups that can
 	 * potentially be reaped by the release agent. Protected by
 	 * release_list_lock
@@ -369,6 +378,15 @@ struct css_set {
 	struct cgroup *mg_src_cgrp;
 	struct css_set *mg_dst_cset;
 
+	/*
+	 * On the default hierarhcy, ->subsys[ssid] may point to a css
+	 * attached to an ancestor instead of the cgroup this css_set is
+	 * associated with.  The following node is anchored at
+	 * ->subsys[ssid]->cgroup->e_csets[ssid] and provides a way to
+	 * iterate through all css's attached to a given cgroup.
+	 */
+	struct list_head e_cset_node[CGROUP_SUBSYS_COUNT];
+
 	/* For RCU-protected deletion */
 	struct rcu_head rcu_head;
 };
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ae1fe5a..2899a6f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -425,6 +425,8 @@ static unsigned long css_set_hash(struct cgroup_subsys_state *css[])
 static void put_css_set_locked(struct css_set *cset, bool taskexit)
 {
 	struct cgrp_cset_link *link, *tmp_link;
+	struct cgroup_subsys *ss;
+	int ssid;
 
 	lockdep_assert_held(&css_set_rwsem);
 
@@ -432,6 +434,8 @@ static void put_css_set_locked(struct css_set *cset, bool taskexit)
 		return;
 
 	/* This css_set is dead. unlink it and release cgroup refcounts */
+	for_each_subsys(ss, ssid)
+		list_del(&cset->e_cset_node[ssid]);
 	hash_del(&cset->hlist);
 	css_set_count--;
 
@@ -673,7 +677,9 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 	struct css_set *cset;
 	struct list_head tmp_links;
 	struct cgrp_cset_link *link;
+	struct cgroup_subsys *ss;
 	unsigned long key;
+	int ssid;
 
 	lockdep_assert_held(&cgroup_mutex);
 
@@ -724,10 +730,14 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 
 	css_set_count++;
 
-	/* Add this cgroup group to the hash table */
+	/* Add @cset to the hash table */
 	key = css_set_hash(cset->subsys);
 	hash_add(css_set_table, &cset->hlist, key);
 
+	for_each_subsys(ss, ssid)
+		list_add_tail(&cset->e_cset_node[ssid],
+			      &cset->subsys[ssid]->cgroup->e_csets[ssid]);
+
 	up_write(&css_set_rwsem);
 
 	return cset;
@@ -1028,7 +1038,7 @@ static int rebind_subsystems(struct cgroup_root *dst_root,
 			     unsigned long ss_mask)
 {
 	struct cgroup_subsys *ss;
-	int ssid, ret;
+	int ssid, i, ret;
 
 	lockdep_assert_held(&cgroup_tree_mutex);
 	lockdep_assert_held(&cgroup_mutex);
@@ -1081,6 +1091,7 @@ static int rebind_subsystems(struct cgroup_root *dst_root,
 	for_each_subsys(ss, ssid) {
 		struct cgroup_root *src_root;
 		struct cgroup_subsys_state *css;
+		struct css_set *cset;
 
 		if (!(ss_mask & (1 << ssid)))
 			continue;
@@ -1095,6 +1106,12 @@ static int rebind_subsystems(struct cgroup_root *dst_root,
 		ss->root = dst_root;
 		css->cgroup = &dst_root->cgrp;
 
+		down_write(&css_set_rwsem);
+		hash_for_each(css_set_table, i, cset, hlist)
+			list_move_tail(&cset->e_cset_node[ss->id],
+				       &dst_root->cgrp.e_csets[ss->id]);
+		up_write(&css_set_rwsem);
+
 		src_root->subsys_mask &= ~(1 << ssid);
 		src_root->cgrp.child_subsys_mask &= ~(1 << ssid);
 
@@ -1417,6 +1434,9 @@ out_unlock:
 
 static void init_cgroup_housekeeping(struct cgroup *cgrp)
 {
+	struct cgroup_subsys *ss;
+	int ssid;
+
 	atomic_set(&cgrp->refcnt, 1);
 	INIT_LIST_HEAD(&cgrp->sibling);
 	INIT_LIST_HEAD(&cgrp->children);
@@ -1425,6 +1445,9 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	INIT_LIST_HEAD(&cgrp->pidlists);
 	mutex_init(&cgrp->pidlist_mutex);
 	cgrp->dummy_css.cgroup = cgrp;
+
+	for_each_subsys(ss, ssid)
+		INIT_LIST_HEAD(&cgrp->e_csets[ssid]);
 }
 
 static void init_cgroup_root(struct cgroup_root *root,
@@ -4224,6 +4247,9 @@ int __init cgroup_init(void)
 		if (!ss->early_init)
 			cgroup_init_subsys(ss);
 
+		list_add_tail(&init_css_set.e_cset_node[ssid],
+			      &cgrp_dfl_root.cgrp.e_csets[ssid]);
+
 		/*
 		 * cftype registration needs kmalloc and can't be done
 		 * during early_init.  Register base cftypes separately.
-- 
1.8.5.3
