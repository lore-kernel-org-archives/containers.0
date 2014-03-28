From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 11/12] cgroup: prepare migration path for unified hierarchy
Date: Thu, 27 Mar 2014 22:41:00 -0400
Message-ID: <1395974461-12735-12-git-send-email-tj__41532.0448264994$1395974565$gmane$org@kernel.org>
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

Unified hierarchy implementation would require re-migrating tasks onto
the same cgroup on the default hierarchy to reflect updated effective
csses.  Update cgroup_migrate_prepare_dst() so that it accepts NULL as
the destination cgrp.  When NULL is specified, the destination is
considered to be the cgroup on the default hierarchy associated with
each css_set.

After this change, the identity check in cgroup_migrate_add_src()
isn't sufficient for noop detection as the associated csses may change
without any cgroup association changing.  The only way to tell whether
a migration is noop or not is testing whether the source and
destination csets are identical.  The noop check in
cgroup_migrate_add_src() is removed and cset identity test is added to
cgroup_migreate_prepare_dst().  If it's detected that source and
destination csets are identical, the cset is removed removed from
@preloaded_csets and all the migration nodes are cleared which makes
cgroup_migrate() ignore the cset.

Also, make the function append the destination css_sets to
@preloaded_list so that destination css_sets always come after source
css_sets.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 34 +++++++++++++++++++++++-----------
 1 file changed, 23 insertions(+), 11 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0c67141..5faa115 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1901,10 +1901,6 @@ static void cgroup_migrate_add_src(struct css_set *src_cset,
 
 	src_cgrp = cset_cgroup_from_root(src_cset, dst_cgrp->root);
 
-	/* nothing to do if this cset already belongs to the cgroup */
-	if (src_cgrp == dst_cgrp)
-		return;
-
 	if (!list_empty(&src_cset->mg_preload_node))
 		return;
 
@@ -1919,13 +1915,14 @@ static void cgroup_migrate_add_src(struct css_set *src_cset,
 
 /**
  * cgroup_migrate_prepare_dst - prepare destination css_sets for migration
- * @dst_cgrp: the destination cgroup
+ * @dst_cgrp: the destination cgroup (may be %NULL)
  * @preloaded_csets: list of preloaded source css_sets
  *
  * Tasks are about to be moved to @dst_cgrp and all the source css_sets
  * have been preloaded to @preloaded_csets.  This function looks up and
- * pins all destination css_sets, links each to its source, and put them on
- * @preloaded_csets.
+ * pins all destination css_sets, links each to its source, and append them
+ * to @preloaded_csets.  If @dst_cgrp is %NULL, the destination of each
+ * source css_set is assumed to be its cgroup on the default hierarchy.
  *
  * This function must be called after cgroup_migrate_add_src() has been
  * called on each migration source css_set.  After migration is performed
@@ -1936,19 +1933,34 @@ static int cgroup_migrate_prepare_dst(struct cgroup *dst_cgrp,
 				      struct list_head *preloaded_csets)
 {
 	LIST_HEAD(csets);
-	struct css_set *src_cset;
+	struct css_set *src_cset, *tmp_cset;
 
 	lockdep_assert_held(&cgroup_mutex);
 
 	/* look up the dst cset for each src cset and link it to src */
-	list_for_each_entry(src_cset, preloaded_csets, mg_preload_node) {
+	list_for_each_entry_safe(src_cset, tmp_cset, preloaded_csets, mg_preload_node) {
 		struct css_set *dst_cset;
 
-		dst_cset = find_css_set(src_cset, dst_cgrp);
+		dst_cset = find_css_set(src_cset,
+					dst_cgrp ?: src_cset->dfl_cgrp);
 		if (!dst_cset)
 			goto err;
 
 		WARN_ON_ONCE(src_cset->mg_dst_cset || dst_cset->mg_dst_cset);
+
+		/*
+		 * If src cset equals dst, it's noop.  Drop the src.
+		 * cgroup_migrate() will skip the cset too.  Note that we
+		 * can't handle src == dst as some nodes are used by both.
+		 */
+		if (src_cset == dst_cset) {
+			src_cset->mg_src_cgrp = NULL;
+			list_del_init(&src_cset->mg_preload_node);
+			put_css_set(src_cset, false);
+			put_css_set(dst_cset, false);
+			continue;
+		}
+
 		src_cset->mg_dst_cset = dst_cset;
 
 		if (list_empty(&dst_cset->mg_preload_node))
@@ -1957,7 +1969,7 @@ static int cgroup_migrate_prepare_dst(struct cgroup *dst_cgrp,
 			put_css_set(dst_cset, false);
 	}
 
-	list_splice(&csets, preloaded_csets);
+	list_splice_tail(&csets, preloaded_csets);
 	return 0;
 err:
 	cgroup_migrate_finish(&csets);
-- 
1.8.5.3
