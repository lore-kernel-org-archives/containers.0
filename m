From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/12] cgroup: introduce effective cgroup_subsys_state
Date: Mon, 14 Apr 2014 17:37:00 -0400
Message-ID: <1397511430-2673-3-git-send-email-tj@kernel.org>
References: <1397511430-2673-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1397511430-2673-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

In the planned default unified hierarchy, controllers may get
dynamically attached to and detached from a cgroup and a cgroup may
not have csses for all the controllers associated with the hierarchy.

When a cgroup doesn't have its own css for a given controller, the css
of the nearest ancestor with the controller enabled will be used,
which is called the effective css.  This patch introduces
cgroup_e_css() and for_each_e_css() to access the effective csses and
convert compare_css_sets(), find_existing_css_set() and
cgroup_migrate() to use the effective csses so that they can handle
cgroups with partial csses correctly.

This means that for two css_sets to be considered identical, they
should have both matching csses and cgroups.  compare_css_sets()
already compares both, not for correctness but for optimization.  As
this now becomes a matter of correctness, update the comments
accordingly.

For all !default hierarchies, cgroup_e_css() always equals
cgroup_css(), so this patch doesn't change behavior.

While at it, fix incorrect locking comment for for_each_css().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 83 ++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 64 insertions(+), 19 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index dd40679..a6a438f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -208,6 +208,34 @@ static struct cgroup_subsys_state *cgroup_css(struct cgroup *cgrp,
 		return &cgrp->dummy_css;
 }
 
+/**
+ * cgroup_e_css - obtain a cgroup's effective css for the specified subsystem
+ * @cgrp: the cgroup of interest
+ * @ss: the subsystem of interest (%NULL returns the dummy_css)
+ *
+ * Similar to cgroup_css() but returns the effctive css, which is defined
+ * as the matching css of the nearest ancestor including self which has @ss
+ * enabled.  If @ss is associated with the hierarchy @cgrp is on, this
+ * function is guaranteed to return non-NULL css.
+ */
+static struct cgroup_subsys_state *cgroup_e_css(struct cgroup *cgrp,
+						struct cgroup_subsys *ss)
+{
+	lockdep_assert_held(&cgroup_mutex);
+
+	if (!ss)
+		return &cgrp->dummy_css;
+
+	if (!(cgrp->root->subsys_mask & (1 << ss->id)))
+		return NULL;
+
+	while (cgrp->parent &&
+	       !(cgrp->parent->child_subsys_mask & (1 << ss->id)))
+		cgrp = cgrp->parent;
+
+	return cgroup_css(cgrp, ss);
+}
+
 /* convenient tests for these bits */
 static inline bool cgroup_is_dead(const struct cgroup *cgrp)
 {
@@ -273,7 +301,7 @@ static int notify_on_release(const struct cgroup *cgrp)
  * @ssid: the index of the subsystem, CGROUP_SUBSYS_COUNT after reaching the end
  * @cgrp: the target cgroup to iterate css's of
  *
- * Should be called under cgroup_mutex.
+ * Should be called under cgroup_[tree_]mutex.
  */
 #define for_each_css(css, ssid, cgrp)					\
 	for ((ssid) = 0; (ssid) < CGROUP_SUBSYS_COUNT; (ssid)++)	\
@@ -284,6 +312,20 @@ static int notify_on_release(const struct cgroup *cgrp)
 		else
 
 /**
+ * for_each_e_css - iterate all effective css's of a cgroup
+ * @css: the iteration cursor
+ * @ssid: the index of the subsystem, CGROUP_SUBSYS_COUNT after reaching the end
+ * @cgrp: the target cgroup to iterate css's of
+ *
+ * Should be called under cgroup_[tree_]mutex.
+ */
+#define for_each_e_css(css, ssid, cgrp)					\
+	for ((ssid) = 0; (ssid) < CGROUP_SUBSYS_COUNT; (ssid)++)	\
+		if (!((css) = cgroup_e_css(cgrp, cgroup_subsys[(ssid)]))) \
+			;						\
+		else
+
+/**
  * for_each_subsys - iterate all enabled cgroup subsystems
  * @ss: the iteration cursor
  * @ssid: the index of @ss, CGROUP_SUBSYS_COUNT after reaching the end
@@ -452,20 +494,20 @@ static bool compare_css_sets(struct css_set *cset,
 {
 	struct list_head *l1, *l2;
 
-	if (memcmp(template, cset->subsys, sizeof(cset->subsys))) {
-		/* Not all subsystems matched */
+	/*
+	 * On the default hierarchy, there can be csets which are
+	 * associated with the same set of cgroups but different csses.
+	 * Let's first ensure that csses match.
+	 */
+	if (memcmp(template, cset->subsys, sizeof(cset->subsys)))
 		return false;
-	}
 
 	/*
 	 * Compare cgroup pointers in order to distinguish between
-	 * different cgroups in heirarchies with no subsystems. We
-	 * could get by with just this check alone (and skip the
-	 * memcmp above) but on most setups the memcmp check will
-	 * avoid the need for this more expensive check on almost all
-	 * candidates.
+	 * different cgroups in hierarchies.  As different cgroups may
+	 * share the same effective css, this comparison is always
+	 * necessary.
 	 */
-
 	l1 = &cset->cgrp_links;
 	l2 = &old_cset->cgrp_links;
 	while (1) {
@@ -530,13 +572,16 @@ static struct css_set *find_existing_css_set(struct css_set *old_cset,
 	 */
 	for_each_subsys(ss, i) {
 		if (root->subsys_mask & (1UL << i)) {
-			/* Subsystem is in this hierarchy. So we want
-			 * the subsystem state from the new
-			 * cgroup */
-			template[i] = cgroup_css(cgrp, ss);
+			/*
+			 * @ss is in this hierarchy, so we want the
+			 * effective css from @cgrp.
+			 */
+			template[i] = cgroup_e_css(cgrp, ss);
 		} else {
-			/* Subsystem is not in this hierarchy, so we
-			 * don't want to change the subsystem state */
+			/*
+			 * @ss is not in this hierarchy, so we don't want
+			 * to change the css.
+			 */
 			template[i] = old_cset->subsys[i];
 		}
 	}
@@ -1969,7 +2014,7 @@ static int cgroup_migrate(struct cgroup *cgrp, struct task_struct *leader,
 		return 0;
 
 	/* check that we can legitimately attach to the cgroup */
-	for_each_css(css, i, cgrp) {
+	for_each_e_css(css, i, cgrp) {
 		if (css->ss->can_attach) {
 			ret = css->ss->can_attach(css, &tset);
 			if (ret) {
@@ -1999,7 +2044,7 @@ static int cgroup_migrate(struct cgroup *cgrp, struct task_struct *leader,
 	 */
 	tset.csets = &tset.dst_csets;
 
-	for_each_css(css, i, cgrp)
+	for_each_e_css(css, i, cgrp)
 		if (css->ss->attach)
 			css->ss->attach(css, &tset);
 
@@ -2007,7 +2052,7 @@ static int cgroup_migrate(struct cgroup *cgrp, struct task_struct *leader,
 	goto out_release_tset;
 
 out_cancel_attach:
-	for_each_css(css, i, cgrp) {
+	for_each_e_css(css, i, cgrp) {
 		if (css == failed_css)
 			break;
 		if (css->ss->cancel_attach)
-- 
1.9.0
