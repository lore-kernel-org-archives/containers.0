From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/8] cgroup: remove cftype_set
Date: Sat,  8 Feb 2014 11:38:24 -0500
Message-ID: <1391877509-10855-4-git-send-email-tj__38546.1192498498$1391877547$gmane$org@kernel.org>
References: <1391877509-10855-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391877509-10855-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

cftype_set was added primarily to allow registering the same cftype
array more than once for different subsystems.  Nobody uses or needs
such thing and it's already broken because each cftype has ->ss
pointer which is initialized during registration.

Let's add list_head ->node to cftype and use the first cftype entry in
the array to link them instead of allocating separate cftype_set.
While at it, trigger WARN if cft seems previously initialized during
registration.

This simplifies cftype handling a bit.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 26 +++++++++-----------------
 kernel/cgroup.c        | 41 +++++++++++++----------------------------
 2 files changed, 22 insertions(+), 45 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 6fe238e..3c0c7e4 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -410,12 +410,11 @@ struct cftype {
 	unsigned int flags;
 
 	/*
-	 * The subsys this file belongs to.  Initialized automatically
-	 * during registration.  NULL for cgroup core files.
+	 * Fields used for internal bookkeeping.  Initialized automatically
+	 * during registration.
 	 */
-	struct cgroup_subsys *ss;
-
-	/* kernfs_ops to use, initialized automatically during registration */
+	struct cgroup_subsys *ss;	/* NULL for cgroup core files */
+	struct list_head node;		/* anchored at ss->cfts */
 	struct kernfs_ops *kf_ops;
 
 	/*
@@ -470,16 +469,6 @@ struct cftype {
 };
 
 /*
- * cftype_sets describe cftypes belonging to a subsystem and are chained at
- * cgroup_subsys->cftsets.  Each cftset points to an array of cftypes
- * terminated by zero length name.
- */
-struct cftype_set {
-	struct list_head		node;	/* chained at subsys->cftsets */
-	struct cftype			*cfts;
-};
-
-/*
  * See the comment above CGRP_ROOT_SANE_BEHAVIOR for details.  This
  * function can be called as long as @cgrp is accessible.
  */
@@ -595,8 +584,11 @@ struct cgroup_subsys {
 	/* link to parent, protected by cgroup_lock() */
 	struct cgroupfs_root *root;
 
-	/* list of cftype_sets */
-	struct list_head cftsets;
+	/*
+	 * List of cftypes.  Each entry is the first entry of an array
+	 * terminated by zero length name.
+	 */
+	struct list_head cfts;
 
 	/* base cftypes, automatically registered with subsys itself */
 	struct cftype *base_cftypes;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f718cbb..a3ade20 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1014,12 +1014,12 @@ static void cgroup_clear_dir(struct cgroup *cgrp, unsigned long subsys_mask)
 	int i;
 
 	for_each_subsys(ss, i) {
-		struct cftype_set *set;
+		struct cftype *cfts;
 
 		if (!test_bit(i, &subsys_mask))
 			continue;
-		list_for_each_entry(set, &ss->cftsets, node)
-			cgroup_addrm_files(cgrp, set->cfts, false);
+		list_for_each_entry(cfts, &ss->cfts, node)
+			cgroup_addrm_files(cgrp, cfts, false);
 	}
 }
 
@@ -2390,6 +2390,8 @@ static int cgroup_init_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
 	for (cft = cfts; cft->name[0] != '\0'; cft++) {
 		struct kernfs_ops *kf_ops;
 
+		WARN_ON(cft->ss || cft->kf_ops);
+
 		if (cft->seq_start)
 			kf_ops = &cgroup_kf_ops;
 		else
@@ -2428,26 +2430,15 @@ static int cgroup_init_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
  */
 int cgroup_rm_cftypes(struct cftype *cfts)
 {
-	struct cftype *found = NULL;
-	struct cftype_set *set;
-
 	if (!cfts || !cfts[0].ss)
 		return -ENOENT;
 
 	cgroup_cfts_prepare();
+	list_del(&cfts->node);
+	cgroup_cfts_commit(cfts, false);
 
-	list_for_each_entry(set, &cfts[0].ss->cftsets, node) {
-		if (set->cfts == cfts) {
-			list_del(&set->node);
-			kfree(set);
-			found = cfts;
-			break;
-		}
-	}
-
-	cgroup_cfts_commit(found, false);
 	cgroup_exit_cftypes(cfts);
-	return found ? 0 : -ENOENT;
+	return 0;
 }
 
 /**
@@ -2466,20 +2457,14 @@ int cgroup_rm_cftypes(struct cftype *cfts)
  */
 int cgroup_add_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
 {
-	struct cftype_set *set;
 	int ret;
 
-	set = kzalloc(sizeof(*set), GFP_KERNEL);
-	if (!set)
-		return -ENOMEM;
-
 	ret = cgroup_init_cftypes(ss, cfts);
 	if (ret)
 		return ret;
 
 	cgroup_cfts_prepare();
-	set->cfts = cfts;
-	list_add_tail(&set->node, &ss->cftsets);
+	list_add_tail(&cfts->node, &ss->cfts);
 	ret = cgroup_cfts_commit(cfts, true);
 	if (ret)
 		cgroup_rm_cftypes(cfts);
@@ -3572,13 +3557,13 @@ static int cgroup_populate_dir(struct cgroup *cgrp, unsigned long subsys_mask)
 
 	/* process cftsets of each subsystem */
 	for_each_subsys(ss, i) {
-		struct cftype_set *set;
+		struct cftype *cfts;
 
 		if (!test_bit(i, &subsys_mask))
 			continue;
 
-		list_for_each_entry(set, &ss->cftsets, node) {
-			ret = cgroup_addrm_files(cgrp, set->cfts, true);
+		list_for_each_entry(cfts, &ss->cfts, node) {
+			ret = cgroup_addrm_files(cgrp, cfts, true);
 			if (ret < 0)
 				goto err;
 		}
@@ -4167,7 +4152,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 
-	INIT_LIST_HEAD(&ss->cftsets);
+	INIT_LIST_HEAD(&ss->cfts);
 
 	/* Create the top cgroup state for this subsystem */
 	ss->root = &cgroup_dummy_root;
-- 
1.8.5.3
