From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/5] cgroup: update iterators to use cgroup_next_sibling()
Date: Tue, 21 May 2013 10:50:24 +0900
Message-ID: <1369101025-28335-5-git-send-email-tj__29208.827779121$1369101071$gmane$org@kernel.org>
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

This patch converts cgroup_for_each_child(),
cgroup_next_descendant_pre/post() and thus
cgroup_for_each_descendant_pre/post() to use cgroup_next_sibling()
instead of manually dereferencing ->sibling.next.

The only reason the iterators couldn't allow dropping RCU read lock
while iteration is in progress was because they couldn't determine the
next sibling safely once RCU read lock is dropped.  Using
cgroup_next_sibling() removes that problem and enables all iterators
to allow dropping RCU read lock in the middle.  Comments are updated
accordingly.

This makes the iterators easier to use and will simplify controllers.

Note that @cgroup argument is renamed to @cgrp in
cgroup_for_each_child() because it conflicts with "struct cgroup" used
in the new macro body.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 18 ++++++++++++++----
 kernel/cgroup.c        | 25 +++++++++++++++++++------
 2 files changed, 33 insertions(+), 10 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index ee041a0..d0ad379 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -688,9 +688,9 @@ struct cgroup *cgroup_next_sibling(struct cgroup *pos);
 /**
  * cgroup_for_each_child - iterate through children of a cgroup
  * @pos: the cgroup * to use as the loop cursor
- * @cgroup: cgroup whose children to walk
+ * @cgrp: cgroup whose children to walk
  *
- * Walk @cgroup's children.  Must be called under rcu_read_lock().  A child
+ * Walk @cgrp's children.  Must be called under rcu_read_lock().  A child
  * cgroup which hasn't finished ->css_online() or already has finished
  * ->css_offline() may show up during traversal and it's each subsystem's
  * responsibility to verify that each @pos is alive.
@@ -698,9 +698,15 @@ struct cgroup *cgroup_next_sibling(struct cgroup *pos);
  * If a subsystem synchronizes against the parent in its ->css_online() and
  * before starting iterating, a cgroup which finished ->css_online() is
  * guaranteed to be visible in the future iterations.
+ *
+ * It is allowed to temporarily drop RCU read lock during iteration.  The
+ * caller is responsible for ensuring that @pos remains accessible until
+ * the start of the next iteration by, for example, bumping the css refcnt.
  */
-#define cgroup_for_each_child(pos, cgroup)				\
-	list_for_each_entry_rcu(pos, &(cgroup)->children, sibling)
+#define cgroup_for_each_child(pos, cgrp)				\
+	for ((pos) = list_first_or_null_rcu(&(cgrp)->children,		\
+					    struct cgroup, sibling);	\
+	     (pos); (pos) = cgroup_next_sibling((pos)))
 
 struct cgroup *cgroup_next_descendant_pre(struct cgroup *pos,
 					  struct cgroup *cgroup);
@@ -759,6 +765,10 @@ struct cgroup *cgroup_rightmost_descendant(struct cgroup *pos);
  * Alternatively, a subsystem may choose to use a single global lock to
  * synchronize ->css_online() and ->css_offline() against tree-walking
  * operations.
+ *
+ * It is allowed to temporarily drop RCU read lock during iteration.  The
+ * caller is responsible for ensuring that @pos remains accessible until
+ * the start of the next iteration by, for example, bumping the css refcnt.
  */
 #define cgroup_for_each_descendant_pre(pos, cgroup)			\
 	for (pos = cgroup_next_descendant_pre(NULL, (cgroup)); (pos);	\
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index bc757d7..21b1ee4 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3030,6 +3030,11 @@ EXPORT_SYMBOL_GPL(cgroup_next_sibling);
  *
  * To be used by cgroup_for_each_descendant_pre().  Find the next
  * descendant to visit for pre-order traversal of @cgroup's descendants.
+ *
+ * While this function requires RCU read locking, it doesn't require the
+ * whole traversal to be contained in a single RCU critical section.  This
+ * function will return the correct next descendant as long as both @pos
+ * and @cgroup are accessible and @pos is a descendant of @cgroup.
  */
 struct cgroup *cgroup_next_descendant_pre(struct cgroup *pos,
 					  struct cgroup *cgroup)
@@ -3049,11 +3054,9 @@ struct cgroup *cgroup_next_descendant_pre(struct cgroup *pos,
 
 	/* no child, visit my or the closest ancestor's next sibling */
 	while (pos != cgroup) {
-		next = list_entry_rcu(pos->sibling.next, struct cgroup,
-				      sibling);
-		if (&next->sibling != &pos->parent->children)
+		next = cgroup_next_sibling(pos);
+		if (next)
 			return next;
-
 		pos = pos->parent;
 	}
 
@@ -3068,6 +3071,11 @@ EXPORT_SYMBOL_GPL(cgroup_next_descendant_pre);
  * Return the rightmost descendant of @pos.  If there's no descendant,
  * @pos is returned.  This can be used during pre-order traversal to skip
  * subtree of @pos.
+ *
+ * While this function requires RCU read locking, it doesn't require the
+ * whole traversal to be contained in a single RCU critical section.  This
+ * function will return the correct rightmost descendant as long as @pos is
+ * accessible.
  */
 struct cgroup *cgroup_rightmost_descendant(struct cgroup *pos)
 {
@@ -3107,6 +3115,11 @@ static struct cgroup *cgroup_leftmost_descendant(struct cgroup *pos)
  *
  * To be used by cgroup_for_each_descendant_post().  Find the next
  * descendant to visit for post-order traversal of @cgroup's descendants.
+ *
+ * While this function requires RCU read locking, it doesn't require the
+ * whole traversal to be contained in a single RCU critical section.  This
+ * function will return the correct next descendant as long as both @pos
+ * and @cgroup are accessible and @pos is a descendant of @cgroup.
  */
 struct cgroup *cgroup_next_descendant_post(struct cgroup *pos,
 					   struct cgroup *cgroup)
@@ -3122,8 +3135,8 @@ struct cgroup *cgroup_next_descendant_post(struct cgroup *pos,
 	}
 
 	/* if there's an unvisited sibling, visit its leftmost descendant */
-	next = list_entry_rcu(pos->sibling.next, struct cgroup, sibling);
-	if (&next->sibling != &pos->parent->children)
+	next = cgroup_next_sibling(pos);
+	if (next)
 		return cgroup_leftmost_descendant(next);
 
 	/* no sibling left, visit parent */
-- 
1.8.1.4
