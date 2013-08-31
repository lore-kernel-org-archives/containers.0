From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 2/9] cgroup: css iterations and css_from_dir() are safe
	under cgroup_mutex
Date: Sat, 31 Aug 2013 09:56:57 -0400
Message-ID: <20130831135657.GA26539@htj.dyndns.org>
References: <1377723829-22814-1-git-send-email-tj@kernel.org>
	<1377723829-22814-3-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1377723829-22814-3-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, all css iterations and css_from_dir() require RCU read lock
whether the caller is holding cgroup_mutex or not, which is
unnecessarily restrictive.  They are all safe to use under
cgroup_mutex without holding RCU read lock.

Factor out cgroup_assert_mutex_or_rcu_locked() from css_from_id() and
apply it to all css iteration functions and css_from_dir().

v2: cgroup_assert_mutex_or_rcu_locked() definition doesn't need to be
    inside CONFIG_PROVE_RCU ifdef as rcu_lockdep_assert() is always
    defined and conditionalized.  Move it outside of the ifdef block.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c |   56 ++++++++++++++++++++++++++++++--------------------------
 1 file changed, 30 insertions(+), 26 deletions(-)

--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -88,6 +88,11 @@ static DEFINE_MUTEX(cgroup_mutex);
 
 static DEFINE_MUTEX(cgroup_root_mutex);
 
+#define cgroup_assert_mutex_or_rcu_locked()				\
+	rcu_lockdep_assert(rcu_read_lock_held() ||			\
+			   lockdep_is_held(&cgroup_mutex),		\
+			   "cgroup_mutex or RCU read lock required");
+
 /*
  * Generate an array of cgroup subsystem pointers. At boot time, this is
  * populated with the built in subsystems, and modular subsystems are
@@ -3036,9 +3041,9 @@ static void cgroup_enable_task_cg_lists(
  * @parent_css: css whose children to walk
  *
  * This function returns the next child of @parent_css and should be called
- * under RCU read lock.  The only requirement is that @parent_css and
- * @pos_css are accessible.  The next sibling is guaranteed to be returned
- * regardless of their states.
+ * under either cgroup_mutex or RCU read lock.  The only requirement is
+ * that @parent_css and @pos_css are accessible.  The next sibling is
+ * guaranteed to be returned regardless of their states.
  */
 struct cgroup_subsys_state *
 css_next_child(struct cgroup_subsys_state *pos_css,
@@ -3048,7 +3053,7 @@ css_next_child(struct cgroup_subsys_stat
 	struct cgroup *cgrp = parent_css->cgroup;
 	struct cgroup *next;
 
-	WARN_ON_ONCE(!rcu_read_lock_held());
+	cgroup_assert_mutex_or_rcu_locked();
 
 	/*
 	 * @pos could already have been removed.  Once a cgroup is removed,
@@ -3095,10 +3100,10 @@ EXPORT_SYMBOL_GPL(css_next_child);
  * to visit for pre-order traversal of @root's descendants.  @root is
  * included in the iteration and the first node to be visited.
  *
- * While this function requires RCU read locking, it doesn't require the
- * whole traversal to be contained in a single RCU critical section.  This
- * function will return the correct next descendant as long as both @pos
- * and @root are accessible and @pos is a descendant of @root.
+ * While this function requires cgroup_mutex or RCU read locking, it
+ * doesn't require the whole traversal to be contained in a single critical
+ * section.  This function will return the correct next descendant as long
+ * as both @pos and @root are accessible and @pos is a descendant of @root.
  */
 struct cgroup_subsys_state *
 css_next_descendant_pre(struct cgroup_subsys_state *pos,
@@ -3106,7 +3111,7 @@ css_next_descendant_pre(struct cgroup_su
 {
 	struct cgroup_subsys_state *next;
 
-	WARN_ON_ONCE(!rcu_read_lock_held());
+	cgroup_assert_mutex_or_rcu_locked();
 
 	/* if first iteration, visit @root */
 	if (!pos)
@@ -3137,17 +3142,17 @@ EXPORT_SYMBOL_GPL(css_next_descendant_pr
  * is returned.  This can be used during pre-order traversal to skip
  * subtree of @pos.
  *
- * While this function requires RCU read locking, it doesn't require the
- * whole traversal to be contained in a single RCU critical section.  This
- * function will return the correct rightmost descendant as long as @pos is
- * accessible.
+ * While this function requires cgroup_mutex or RCU read locking, it
+ * doesn't require the whole traversal to be contained in a single critical
+ * section.  This function will return the correct rightmost descendant as
+ * long as @pos is accessible.
  */
 struct cgroup_subsys_state *
 css_rightmost_descendant(struct cgroup_subsys_state *pos)
 {
 	struct cgroup_subsys_state *last, *tmp;
 
-	WARN_ON_ONCE(!rcu_read_lock_held());
+	cgroup_assert_mutex_or_rcu_locked();
 
 	do {
 		last = pos;
@@ -3183,10 +3188,11 @@ css_leftmost_descendant(struct cgroup_su
  * to visit for post-order traversal of @root's descendants.  @root is
  * included in the iteration and the last node to be visited.
  *
- * While this function requires RCU read locking, it doesn't require the
- * whole traversal to be contained in a single RCU critical section.  This
- * function will return the correct next descendant as long as both @pos
- * and @cgroup are accessible and @pos is a descendant of @cgroup.
+ * While this function requires cgroup_mutex or RCU read locking, it
+ * doesn't require the whole traversal to be contained in a single critical
+ * section.  This function will return the correct next descendant as long
+ * as both @pos and @cgroup are accessible and @pos is a descendant of
+ * @cgroup.
  */
 struct cgroup_subsys_state *
 css_next_descendant_post(struct cgroup_subsys_state *pos,
@@ -3194,7 +3200,7 @@ css_next_descendant_post(struct cgroup_s
 {
 	struct cgroup_subsys_state *next;
 
-	WARN_ON_ONCE(!rcu_read_lock_held());
+	cgroup_assert_mutex_or_rcu_locked();
 
 	/* if first iteration, visit the leftmost descendant */
 	if (!pos) {
@@ -5698,16 +5704,16 @@ EXPORT_SYMBOL_GPL(css_lookup);
  * @dentry: directory dentry of interest
  * @ss: subsystem of interest
  *
- * Must be called under RCU read lock.  The caller is responsible for
- * pinning the returned css if it needs to be accessed outside the RCU
- * critical section.
+ * Must be called under cgroup_mutex or RCU read lock.  The caller is
+ * responsible for pinning the returned css if it needs to be accessed
+ * outside the critical section.
  */
 struct cgroup_subsys_state *css_from_dir(struct dentry *dentry,
 					 struct cgroup_subsys *ss)
 {
 	struct cgroup *cgrp;
 
-	WARN_ON_ONCE(!rcu_read_lock_held());
+	cgroup_assert_mutex_or_rcu_locked();
 
 	/* is @dentry a cgroup dir? */
 	if (!dentry->d_inode ||
@@ -5730,9 +5736,7 @@ struct cgroup_subsys_state *css_from_id(
 {
 	struct cgroup *cgrp;
 
-	rcu_lockdep_assert(rcu_read_lock_held() ||
-			   lockdep_is_held(&cgroup_mutex),
-			   "css_from_id() needs proper protection");
+	cgroup_assert_mutex_or_rcu_locked();
 
 	cgrp = idr_find(&ss->root->cgroup_idr, id);
 	if (cgrp)
