From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/5] cgroup: add cgroup->serial_nr and implement
	cgroup_next_sibling()
Date: Tue, 21 May 2013 10:50:23 +0900
Message-ID: <1369101025-28335-4-git-send-email-tj__1761.29948017678$1369101073$gmane$org@kernel.org>
References: <1369101025-28335-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1369101025-28335-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, there's no easy way to find out the next sibling cgroup
unless it's known that the current cgroup is accessed from the
parent's children list in a single RCU critical section.  This in turn
forces all iterators to require whole iteration to be enclosed in a
single RCU critical section, which sometimes is too restrictive.  This
patch implements cgroup_next_sibling() which can reliably determine
the next sibling regardless of the state of the current cgroup as long
as it's accessible.

It currently is impossible to determine the next sibling after
dropping RCU read lock because the cgroup being iterated could be
removed anytime and if RCU read lock is dropped, nothing guarantess
its ->sibling.next pointer is accessible.  A removed cgroup would
continue to point to its next sibling for RCU accesses but stop
receiving updates from the sibling.  IOW, the next sibling could be
removed and then complete its grace period while RCU read lock is
dropped, making it unsafe to dereference ->sibling.next after dropping
and re-acquiring RCU read lock.

This can be solved by adding a way to traverse to the next sibling
without dereferencing ->sibling.next.  This patch adds a monotonically
increasing cgroup serial number, cgroup->serial_nr, which guarantees
that all cgroup->children lists are kept in increasing serial_nr
order.  A new function, cgroup_next_sibling(), is implemented, which,
if CGRP_REMOVED is not set on the current cgroup, follows
->sibling.next; otherwise, traverses the parent's ->children list
until it sees a sibling with higher ->serial_nr.

This allows the function to always return the next sibling regardless
of the state of the current cgroup without adding overhead in the fast
path.

Further patches will update the iterators to use cgroup_next_sibling()
so that they allow dropping RCU read lock and blocking while iteration
is in progress which in turn will be used to simplify controllers.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 10 ++++++++
 kernel/cgroup.c        | 62 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 72 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8d9f3c9..ee041a0 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -189,6 +189,14 @@ struct cgroup {
 	struct dentry *dentry;		/* cgroup fs entry, RCU protected */
 
 	/*
+	 * Monotonically increasing unique serial number which defines a
+	 * uniform order among all cgroups.  It's guaranteed that all
+	 * ->children lists are in the ascending order of ->serial_nr.
+	 * It's used to allow interrupting and resuming iterations.
+	 */
+	u64 serial_nr;
+
+	/*
 	 * This is a copy of dentry->d_name, and it's needed because
 	 * we can't use dentry->d_name in cgroup_path().
 	 *
@@ -675,6 +683,8 @@ static inline struct cgroup* task_cgroup(struct task_struct *task,
 	return task_subsys_state(task, subsys_id)->cgroup;
 }
 
+struct cgroup *cgroup_next_sibling(struct cgroup *pos);
+
 /**
  * cgroup_for_each_child - iterate through children of a cgroup
  * @pos: the cgroup * to use as the loop cursor
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3222f93..bc757d7 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2975,6 +2975,55 @@ static void cgroup_enable_task_cg_lists(void)
 }
 
 /**
+ * cgroup_next_sibling - find the next sibling of a given cgroup
+ * @pos: the current cgroup
+ *
+ * This function returns the next sibling of @pos and should be called
+ * under RCU read lock.  The only requirement is that @pos is accessible.
+ * The next sibling is guaranteed to be returned regardless of @pos's
+ * state.
+ */
+struct cgroup *cgroup_next_sibling(struct cgroup *pos)
+{
+	struct cgroup *next;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	/*
+	 * @pos could already have been removed.  Once a cgroup is removed,
+	 * its ->sibling.next is no longer updated when its next sibling
+	 * changes.  As CGRP_REMOVED is set on removal which is fully
+	 * serialized, if we see it unasserted, it's guaranteed that the
+	 * next sibling hasn't finished its grace period even if it's
+	 * already removed, and thus safe to dereference from this RCU
+	 * critical section.  If ->sibling.next is inaccessible,
+	 * cgroup_is_removed() is guaranteed to be visible as %true here.
+	 */
+	if (likely(!cgroup_is_removed(pos))) {
+		next = list_entry_rcu(pos->sibling.next, struct cgroup, sibling);
+		if (&next->sibling != &pos->parent->children)
+			return next;
+		return NULL;
+	}
+
+	/*
+	 * Can't dereference the next pointer.  Each cgroup is given a
+	 * monotonically increasing unique serial number and always
+	 * appended to the sibling list, so the next one can be found by
+	 * walking the parent's children until we see a cgroup with higher
+	 * serial number than @pos's.
+	 *
+	 * While this path can be slow, it's taken only when either the
+	 * current cgroup is removed or iteration and reomval race.
+	 */
+	list_for_each_entry_rcu(next, &pos->parent->children, sibling)
+		if (next->serial_nr > pos->serial_nr)
+			return next;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(cgroup_next_sibling);
+
+/**
  * cgroup_next_descendant_pre - find the next descendant for pre-order walk
  * @pos: the current position (%NULL to initiate traversal)
  * @cgroup: cgroup whose descendants to walk
@@ -4136,6 +4185,7 @@ static void offline_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
 static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 			     umode_t mode)
 {
+	static atomic64_t serial_nr_cursor = ATOMIC64_INIT(0);
 	struct cgroup *cgrp;
 	struct cgroup_name *name;
 	struct cgroupfs_root *root = parent->root;
@@ -4216,6 +4266,14 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		goto err_free_all;
 	lockdep_assert_held(&dentry->d_inode->i_mutex);
 
+	/*
+	 * Assign a monotonically increasing serial number.  With the list
+	 * appending below, it guarantees that sibling cgroups are always
+	 * sorted in the ascending serial number order on the parent's
+	 * ->children.
+	 */
+	cgrp->serial_nr = atomic64_inc_return(&serial_nr_cursor);
+
 	/* allocation complete, commit to creation */
 	list_add_tail(&cgrp->allcg_node, &root->allcg_list);
 	list_add_tail_rcu(&cgrp->sibling, &cgrp->parent->children);
@@ -4303,6 +4361,10 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	 * removed.  This makes future css_tryget() and child creation
 	 * attempts fail thus maintaining the removal conditions verified
 	 * above.
+	 *
+	 * Note that CGRP_REMVOED clearing is depended upon by
+	 * cgroup_next_sibling() to resume iteration after dropping RCU
+	 * read lock.  See cgroup_next_sibling() for details.
 	 */
 	for_each_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
-- 
1.8.1.4
