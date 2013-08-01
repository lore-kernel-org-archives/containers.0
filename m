From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 13/23] cgroup: convert cgroup_next_sibling() to
	cgroup_next_child()
Date: Thu,  1 Aug 2013 17:49:51 -0400
Message-ID: <1375393801-4817-14-git-send-email-tj@kernel.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup is transitioning to using css (cgroup_subsys_state) as the main
subsys interface handle instead of cgroup and the iterators will be
updated to use css too.  The iterators need to walk the cgroup
hierarchy and return the css's matching the origin css, which is a bit
cumbersome to open code.

This patch converts cgroup_next_sibling() to cgroup_next_child() so
that it can handle all steps of direct child iteration.  This will be
used to update iterators to take @css instead of @cgrp.  In addition
to the new iteration init handling, cgroup_next_child() is
restructured so that the different branches share the end of iteration
condition check.

This patch doesn't change any behavior.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  4 ++--
 kernel/cgroup.c        | 59 +++++++++++++++++++++++++-------------------------
 2 files changed, 32 insertions(+), 31 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 9749d63..a91c304 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -780,7 +780,7 @@ static inline struct cgroup *cgroup_from_id(struct cgroup_subsys *ss, int id)
 	return idr_find(&ss->root->cgroup_idr, id);
 }
 
-struct cgroup *cgroup_next_sibling(struct cgroup *pos);
+struct cgroup *cgroup_next_child(struct cgroup *pos, struct cgroup *cgrp);
 
 /**
  * cgroup_for_each_child - iterate through children of a cgroup
@@ -803,7 +803,7 @@ struct cgroup *cgroup_next_sibling(struct cgroup *pos);
 #define cgroup_for_each_child(pos, cgrp)				\
 	for ((pos) = list_first_or_null_rcu(&(cgrp)->children,		\
 					    struct cgroup, sibling);	\
-	     (pos); (pos) = cgroup_next_sibling((pos)))
+	     (pos); (pos) = cgroup_next_child((pos), (cgrp)))
 
 struct cgroup *cgroup_next_descendant_pre(struct cgroup *pos,
 					  struct cgroup *cgroup);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 6c68192..e88b50e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3030,15 +3030,16 @@ static void cgroup_enable_task_cg_lists(void)
 }
 
 /**
- * cgroup_next_sibling - find the next sibling of a given cgroup
- * @pos: the current cgroup
+ * cgroup_next_child - find the next child of a given cgroup
+ * @pos: the current position (%NULL to initiate traversal)
+ * @cgrp: cgroup whose descendants to walk
  *
- * This function returns the next sibling of @pos and should be called
- * under RCU read lock.  The only requirement is that @pos is accessible.
- * The next sibling is guaranteed to be returned regardless of @pos's
- * state.
+ * This function returns the next child of @cgrp and should be called under
+ * RCU read lock.  The only requirement is that @cgrp and @pos are
+ * accessible.  The next sibling is guaranteed to be returned regardless of
+ * their states.
  */
-struct cgroup *cgroup_next_sibling(struct cgroup *pos)
+struct cgroup *cgroup_next_child(struct cgroup *pos, struct cgroup *cgrp)
 {
 	struct cgroup *next;
 
@@ -3054,30 +3055,30 @@ struct cgroup *cgroup_next_sibling(struct cgroup *pos)
 	 * safe to dereference from this RCU critical section.  If
 	 * ->sibling.next is inaccessible, cgroup_is_dead() is guaranteed
 	 * to be visible as %true here.
+	 *
+	 * If @pos is dead, its next pointer can't be dereferenced;
+	 * however, as each cgroup is given a monotonically increasing
+	 * unique serial number and always appended to the sibling list,
+	 * the next one can be found by walking the parent's children until
+	 * we see a cgroup with higher serial number than @pos's.  While
+	 * this path can be slower, it's taken only when either the current
+	 * cgroup is removed or iteration and removal race.
 	 */
-	if (likely(!cgroup_is_dead(pos))) {
+	if (!pos) {
+		next = list_entry_rcu(cgrp->children.next, struct cgroup, sibling);
+	} else if (likely(!cgroup_is_dead(pos))) {
 		next = list_entry_rcu(pos->sibling.next, struct cgroup, sibling);
-		if (&next->sibling != &pos->parent->children)
-			return next;
-		return NULL;
+	} else {
+		list_for_each_entry_rcu(next, &cgrp->children, sibling)
+			if (next->serial_nr > pos->serial_nr)
+				break;
 	}
 
-	/*
-	 * Can't dereference the next pointer.  Each cgroup is given a
-	 * monotonically increasing unique serial number and always
-	 * appended to the sibling list, so the next one can be found by
-	 * walking the parent's children until we see a cgroup with higher
-	 * serial number than @pos's.
-	 *
-	 * While this path can be slow, it's taken only when either the
-	 * current cgroup is removed or iteration and removal race.
-	 */
-	list_for_each_entry_rcu(next, &pos->parent->children, sibling)
-		if (next->serial_nr > pos->serial_nr)
-			return next;
+	if (&next->sibling != &cgrp->children)
+		return next;
 	return NULL;
 }
-EXPORT_SYMBOL_GPL(cgroup_next_sibling);
+EXPORT_SYMBOL_GPL(cgroup_next_child);
 
 /**
  * cgroup_next_descendant_pre - find the next descendant for pre-order walk
@@ -3110,7 +3111,7 @@ struct cgroup *cgroup_next_descendant_pre(struct cgroup *pos,
 
 	/* no child, visit my or the closest ancestor's next sibling */
 	while (pos != cgroup) {
-		next = cgroup_next_sibling(pos);
+		next = cgroup_next_child(pos, pos->parent);
 		if (next)
 			return next;
 		pos = pos->parent;
@@ -3191,7 +3192,7 @@ struct cgroup *cgroup_next_descendant_post(struct cgroup *pos,
 	}
 
 	/* if there's an unvisited sibling, visit its leftmost descendant */
-	next = cgroup_next_sibling(pos);
+	next = cgroup_next_child(pos, pos->parent);
 	if (next)
 		return cgroup_leftmost_descendant(next);
 
@@ -4540,9 +4541,9 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	/*
 	 * Mark @cgrp dead.  This prevents further task migration and child
 	 * creation by disabling cgroup_lock_live_group().  Note that
-	 * CGRP_DEAD assertion is depended upon by cgroup_next_sibling() to
+	 * CGRP_DEAD assertion is depended upon by cgroup_next_child() to
 	 * resume iteration after dropping RCU read lock.  See
-	 * cgroup_next_sibling() for details.
+	 * cgroup_next_child() for details.
 	 */
 	set_bit(CGRP_DEAD, &cgrp->flags);
 
-- 
1.8.3.1
