From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/8] cgroup: simplify dynamic cftype addition and removal
Date: Tue, 28 Jan 2014 18:59:41 -0500
Message-ID: <1390953585-16554-5-git-send-email-tj@kernel.org>
References: <1390953585-16554-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390953585-16554-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Dynamic cftype addition and removal using cgroup_add/rm_cftypes()
respectively has been quite hairy due to vfs i_mutex.  As i_mutex
nests outside cgroup_mutex, cgroup_mutex has to be released and
regrabbed on each iteration through the hierarchy complicating the
process.  Now that i_mutex is no longer in play, it can be simplified.

* Just holding cgroup_tree_mutex is enough.  No need to meddle with
  cgroup_mutex.

* No reason to play the unlock - relock - check serial_nr dancing.
  Everything can be atomically while holding cgroup_tree_mutex.

* cgroup_cfts_prepare() is replaced with direct locking of
  cgroup_tree_mutex.

* cgroup_cfts_commit() no longer fiddles with locking.  It just
  applies the cftypes change to the existing cgroups in the hierarchy.
  Renamed to cgroup_cfts_apply().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 87 +++++++++++++++++++++------------------------------------
 1 file changed, 32 insertions(+), 55 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 64eccb2..5d015c1 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2287,46 +2287,19 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
 	return 0;
 }
 
-static void cgroup_cfts_prepare(void)
-	__acquires(&cgroup_mutex)
-{
-	/*
-	 * Thanks to the entanglement with vfs inode locking, we can't walk
-	 * the existing cgroups under cgroup_mutex and create files.
-	 * Instead, we use css_for_each_descendant_pre() and drop RCU read
-	 * lock before calling cgroup_addrm_files().
-	 */
-	mutex_lock(&cgroup_tree_mutex);
-	mutex_lock(&cgroup_mutex);
-}
-
-static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
-	__releases(&cgroup_mutex)
+static int cgroup_apply_cftypes(struct cftype *cfts, bool is_add)
 {
 	LIST_HEAD(pending);
 	struct cgroup_subsys *ss = cfts[0].ss;
 	struct cgroup *root = &ss->root->top_cgroup;
-	struct cgroup *prev = NULL;
 	struct cgroup_subsys_state *css;
-	u64 update_before;
 	int ret = 0;
 
-	mutex_unlock(&cgroup_mutex);
+	lockdep_assert_held(&cgroup_tree_mutex);
 
-	/* %NULL @cfts indicates abort and don't bother if @ss isn't attached */
-	if (!cfts || ss->root == &cgroup_dummy_root) {
-		mutex_unlock(&cgroup_tree_mutex);
+	/* don't bother if @ss isn't attached */
+	if (ss->root == &cgroup_dummy_root)
 		return 0;
-	}
-
-	cgroup_get_root(ss->root);
-
-	/*
-	 * All cgroups which are created after we drop cgroup_mutex will
-	 * have the updated set of files, so we only need to update the
-	 * cgroups created before the current @cgroup_serial_nr_next.
-	 */
-	update_before = cgroup_serial_nr_next;
 
 	/* add/rm files for all cgroups created before */
 	css_for_each_descendant_pre(css, cgroup_css(root, ss)) {
@@ -2335,22 +2308,13 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 		if (cgroup_is_dead(cgrp))
 			continue;
 
-		cgroup_get(cgrp);
-		if (prev)
-			cgroup_put(prev);
-		prev = cgrp;
-
-		if (cgrp->serial_nr < update_before && !cgroup_is_dead(cgrp)) {
-			ret = cgroup_addrm_files(cgrp, cfts, is_add);
-			if (is_add)
-				kernfs_activate(cgrp->kn);
-		}
+		ret = cgroup_addrm_files(cgrp, cfts, is_add);
 		if (ret)
 			break;
 	}
-	mutex_unlock(&cgroup_tree_mutex);
-	cgroup_put(prev);
-	cgroup_put_root(ss->root);
+
+	if (is_add && !ret)
+		kernfs_activate(root->kn);
 	return ret;
 }
 
@@ -2401,6 +2365,19 @@ static int cgroup_init_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
 	return 0;
 }
 
+static int cgroup_rm_cftypes_locked(struct cftype *cfts)
+{
+	lockdep_assert_held(&cgroup_tree_mutex);
+
+	if (!cfts || !cfts[0].ss)
+		return -ENOENT;
+
+	list_del(&cfts->node);
+	cgroup_apply_cftypes(cfts, false);
+	cgroup_exit_cftypes(cfts);
+	return 0;
+}
+
 /**
  * cgroup_rm_cftypes - remove an array of cftypes from a subsystem
  * @cfts: zero-length name terminated array of cftypes
@@ -2414,15 +2391,12 @@ static int cgroup_init_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
  */
 int cgroup_rm_cftypes(struct cftype *cfts)
 {
-	if (!cfts || !cfts[0].ss)
-		return -ENOENT;
-
-	cgroup_cfts_prepare();
-	list_del(&cfts->node);
-	cgroup_cfts_commit(cfts, false);
+	int ret;
 
-	cgroup_exit_cftypes(cfts);
-	return 0;
+	mutex_lock(&cgroup_tree_mutex);
+	ret = cgroup_rm_cftypes_locked(cfts);
+	mutex_unlock(&cgroup_tree_mutex);
+	return ret;
 }
 
 /**
@@ -2447,11 +2421,14 @@ int cgroup_add_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
 	if (ret)
 		return ret;
 
-	cgroup_cfts_prepare();
+	mutex_lock(&cgroup_tree_mutex);
+
 	list_add_tail(&cfts->node, &ss->cfts);
-	ret = cgroup_cfts_commit(cfts, true);
+	ret = cgroup_apply_cftypes(cfts, true);
 	if (ret)
-		cgroup_rm_cftypes(cfts);
+		cgroup_rm_cftypes_locked(cfts);
+
+	mutex_unlock(&cgroup_tree_mutex);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(cgroup_add_cftypes);
-- 
1.8.5.3
