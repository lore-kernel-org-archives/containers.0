From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v3 2/6] cgroup: drop module support
Date: Wed, 29 Jan 2014 11:05:02 -0500
Message-ID: <20140129160502.GF30842__32130.8450228118$1391011520$gmane$org@htj.dyndns.org>
References: <1390952641-15950-1-git-send-email-tj@kernel.org>
	<1390952641-15950-3-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1390952641-15950-3-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

From 9eabfa8710f51e6b865b4d6668fa7356656f05d8 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Wed, 29 Jan 2014 11:01:26 -0500

With module supported dropped from net_prio, no controller is using
cgroup module support.  None of actual resource controllers can be
built as a module and we aren't gonna add new controllers which don't
control resources.  This patch drops module support from cgroup.

* cgroup_[un]load_subsys() and cgroup_subsys->module removed.

* As there's no point in distinguishing IS_BUILTIN() and IS_MODULE(),
  cgroup_subsys.h now uses IS_ENABLED() directly.

* enum cgroup_subsys_id now exactly matches the list of enabled
  controllers as ordered in cgroup_subsys.h.

* cgroup_subsys[] is now a contiguously occupied array.  Size
  specification is no longer necessary and dropped.

* for_each_builtin_subsys() is removed and for_each_subsys() is
  updated to not require any locking.

* module ref handling is removed from rebind_subsystems().

* Module related comments dropped.

v2: Rebased on top of fe1217c4f3f7 ("net: net_cls: move cgroupfs
    classid handling into core").

v3: Added {} around the if (need_forkexit_callback) block in
    cgroup_post_fork() for readability as suggested by Li.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c            |   1 -
 include/linux/cgroup.h        |  29 +----
 include/linux/cgroup_subsys.h |  24 ++--
 kernel/cgroup.c               | 284 +++---------------------------------------
 net/core/netclassid_cgroup.c  |   1 -
 net/core/netprio_cgroup.c     |   1 -
 6 files changed, 32 insertions(+), 308 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 4e491d9..660d419 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -914,7 +914,6 @@ struct cgroup_subsys blkio_subsys = {
 	.can_attach = blkcg_can_attach,
 	.subsys_id = blkio_subsys_id,
 	.base_cftypes = blkcg_files,
-	.module = THIS_MODULE,
 };
 EXPORT_SYMBOL_GPL(blkio_subsys);
 
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 5c09759..d842a73 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -37,28 +37,13 @@ extern void cgroup_post_fork(struct task_struct *p);
 extern void cgroup_exit(struct task_struct *p, int run_callbacks);
 extern int cgroupstats_build(struct cgroupstats *stats,
 				struct dentry *dentry);
-extern int cgroup_load_subsys(struct cgroup_subsys *ss);
-extern void cgroup_unload_subsys(struct cgroup_subsys *ss);
 
 extern int proc_cgroup_show(struct seq_file *, void *);
 
-/*
- * Define the enumeration of all cgroup subsystems.
- *
- * We define ids for builtin subsystems and then modular ones.
- */
+/* define the enumeration of all cgroup subsystems */
 #define SUBSYS(_x) _x ## _subsys_id,
 enum cgroup_subsys_id {
-#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
 #include <linux/cgroup_subsys.h>
-#undef IS_SUBSYS_ENABLED
-	CGROUP_BUILTIN_SUBSYS_COUNT,
-
-	__CGROUP_SUBSYS_TEMP_PLACEHOLDER = CGROUP_BUILTIN_SUBSYS_COUNT - 1,
-
-#define IS_SUBSYS_ENABLED(option) IS_MODULE(option)
-#include <linux/cgroup_subsys.h>
-#undef IS_SUBSYS_ENABLED
 	CGROUP_SUBSYS_COUNT,
 };
 #undef SUBSYS
@@ -370,10 +355,9 @@ struct css_set {
 	struct list_head cgrp_links;
 
 	/*
-	 * Set of subsystem states, one for each subsystem. This array
-	 * is immutable after creation apart from the init_css_set
-	 * during subsystem registration (at boot time) and modular subsystem
-	 * loading/unloading.
+	 * Set of subsystem states, one for each subsystem. This array is
+	 * immutable after creation apart from the init_css_set during
+	 * subsystem registration (at boot time).
 	 */
 	struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT];
 
@@ -620,15 +604,10 @@ struct cgroup_subsys {
 	/* base cftypes, automatically [de]registered with subsys itself */
 	struct cftype *base_cftypes;
 	struct cftype_set base_cftset;
-
-	/* should be defined only by modular subsystems */
-	struct module *module;
 };
 
 #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
-#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
 #include <linux/cgroup_subsys.h>
-#undef IS_SUBSYS_ENABLED
 #undef SUBSYS
 
 /**
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 7b99d71..11c42f6 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -3,51 +3,51 @@
  *
  * DO NOT ADD ANY SUBSYSTEM WITHOUT EXPLICIT ACKS FROM CGROUP MAINTAINERS.
  */
-#if IS_SUBSYS_ENABLED(CONFIG_CPUSETS)
+#if IS_ENABLED(CONFIG_CPUSETS)
 SUBSYS(cpuset)
 #endif
 
-#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_DEBUG)
+#if IS_ENABLED(CONFIG_CGROUP_DEBUG)
 SUBSYS(debug)
 #endif
 
-#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_SCHED)
+#if IS_ENABLED(CONFIG_CGROUP_SCHED)
 SUBSYS(cpu_cgroup)
 #endif
 
-#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_CPUACCT)
+#if IS_ENABLED(CONFIG_CGROUP_CPUACCT)
 SUBSYS(cpuacct)
 #endif
 
-#if IS_SUBSYS_ENABLED(CONFIG_MEMCG)
+#if IS_ENABLED(CONFIG_MEMCG)
 SUBSYS(mem_cgroup)
 #endif
 
-#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_DEVICE)
+#if IS_ENABLED(CONFIG_CGROUP_DEVICE)
 SUBSYS(devices)
 #endif
 
-#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_FREEZER)
+#if IS_ENABLED(CONFIG_CGROUP_FREEZER)
 SUBSYS(freezer)
 #endif
 
-#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_NET_CLASSID)
+#if IS_ENABLED(CONFIG_CGROUP_NET_CLASSID)
 SUBSYS(net_cls)
 #endif
 
-#if IS_SUBSYS_ENABLED(CONFIG_BLK_CGROUP)
+#if IS_ENABLED(CONFIG_BLK_CGROUP)
 SUBSYS(blkio)
 #endif
 
-#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_PERF)
+#if IS_ENABLED(CONFIG_CGROUP_PERF)
 SUBSYS(perf)
 #endif
 
-#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_NET_PRIO)
+#if IS_ENABLED(CONFIG_CGROUP_NET_PRIO)
 SUBSYS(net_prio)
 #endif
 
-#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_HUGETLB)
+#if IS_ENABLED(CONFIG_CGROUP_HUGETLB)
 SUBSYS(hugetlb)
 #endif
 /*
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b0e030f..7f809c5 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -47,7 +47,6 @@
 #include <linux/string.h>
 #include <linux/sort.h>
 #include <linux/kmod.h>
-#include <linux/module.h>
 #include <linux/delayacct.h>
 #include <linux/cgroupstats.h>
 #include <linux/hashtable.h>
@@ -120,15 +119,9 @@ static struct workqueue_struct *cgroup_destroy_wq;
  */
 static struct workqueue_struct *cgroup_pidlist_destroy_wq;
 
-/*
- * Generate an array of cgroup subsystem pointers. At boot time, this is
- * populated with the built in subsystems, and modular subsystems are
- * registered after that. The mutable section of this array is protected by
- * cgroup_mutex.
- */
+/* generate an array of cgroup subsystem pointers */
 #define SUBSYS(_x) [_x ## _subsys_id] = &_x ## _subsys,
-#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
-static struct cgroup_subsys *cgroup_subsys[CGROUP_SUBSYS_COUNT] = {
+static struct cgroup_subsys *cgroup_subsys[] = {
 #include <linux/cgroup_subsys.h>
 };
 
@@ -258,30 +251,13 @@ static int notify_on_release(const struct cgroup *cgrp)
 		else
 
 /**
- * for_each_subsys - iterate all loaded cgroup subsystems
+ * for_each_subsys - iterate all enabled cgroup subsystems
  * @ss: the iteration cursor
  * @ssid: the index of @ss, CGROUP_SUBSYS_COUNT after reaching the end
- *
- * Iterates through all loaded subsystems.  Should be called under
- * cgroup_mutex or cgroup_root_mutex.
  */
 #define for_each_subsys(ss, ssid)					\
-	for (({ cgroup_assert_mutex_or_root_locked(); (ssid) = 0; });	\
-	     (ssid) < CGROUP_SUBSYS_COUNT; (ssid)++)			\
-		if (!((ss) = cgroup_subsys[(ssid)])) { }		\
-		else
-
-/**
- * for_each_builtin_subsys - iterate all built-in cgroup subsystems
- * @ss: the iteration cursor
- * @i: the index of @ss, CGROUP_BUILTIN_SUBSYS_COUNT after reaching the end
- *
- * Bulit-in subsystems are always present and iteration itself doesn't
- * require any synchronization.
- */
-#define for_each_builtin_subsys(ss, i)					\
-	for ((i) = 0; (i) < CGROUP_BUILTIN_SUBSYS_COUNT &&		\
-	     (((ss) = cgroup_subsys[i]) || true); (i)++)
+	for ((ssid) = 0; (ssid) < CGROUP_SUBSYS_COUNT &&		\
+	     (((ss) = cgroup_subsys[ssid]) || true); (ssid)++)
 
 /* iterate across the active hierarchies */
 #define for_each_active_root(root)					\
@@ -975,50 +951,24 @@ static void cgroup_d_remove_dir(struct dentry *dentry)
 	remove_dir(dentry);
 }
 
-/*
- * Call with cgroup_mutex held. Drops reference counts on modules, including
- * any duplicate ones that parse_cgroupfs_options took. If this function
- * returns an error, no reference counts are touched.
- */
 static int rebind_subsystems(struct cgroupfs_root *root,
 			     unsigned long added_mask, unsigned removed_mask)
 {
 	struct cgroup *cgrp = &root->top_cgroup;
 	struct cgroup_subsys *ss;
-	unsigned long pinned = 0;
 	int i, ret;
 
 	BUG_ON(!mutex_is_locked(&cgroup_mutex));
 	BUG_ON(!mutex_is_locked(&cgroup_root_mutex));
 
 	/* Check that any added subsystems are currently free */
-	for_each_subsys(ss, i) {
-		if (!(added_mask & (1 << i)))
-			continue;
-
-		/* is the subsystem mounted elsewhere? */
-		if (ss->root != &cgroup_dummy_root) {
-			ret = -EBUSY;
-			goto out_put;
-		}
-
-		/* pin the module */
-		if (!try_module_get(ss->module)) {
-			ret = -ENOENT;
-			goto out_put;
-		}
-		pinned |= 1 << i;
-	}
-
-	/* subsys could be missing if unloaded between parsing and here */
-	if (added_mask != pinned) {
-		ret = -ENOENT;
-		goto out_put;
-	}
+	for_each_subsys(ss, i)
+		if ((added_mask & (1 << i)) && ss->root != &cgroup_dummy_root)
+			return -EBUSY;
 
 	ret = cgroup_populate_dir(cgrp, added_mask);
 	if (ret)
-		goto out_put;
+		return ret;
 
 	/*
 	 * Nothing can fail from this point on.  Remove files for the
@@ -1057,9 +1007,6 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			RCU_INIT_POINTER(cgrp->subsys[i], NULL);
 
 			cgroup_subsys[i]->root = &cgroup_dummy_root;
-
-			/* subsystem is now free - drop reference on module */
-			module_put(ss->module);
 			root->subsys_mask &= ~bit;
 		}
 	}
@@ -1071,12 +1018,6 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	root->flags |= CGRP_ROOT_SUBSYS_BOUND;
 
 	return 0;
-
-out_put:
-	for_each_subsys(ss, i)
-		if (pinned & (1 << i))
-			module_put(ss->module);
-	return ret;
 }
 
 static int cgroup_show_options(struct seq_file *seq, struct dentry *dentry)
@@ -4503,7 +4444,7 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 	return ret;
 }
 
-static void __init_or_module cgroup_init_cftsets(struct cgroup_subsys *ss)
+static void __init cgroup_init_cftsets(struct cgroup_subsys *ss)
 {
 	INIT_LIST_HEAD(&ss->cftsets);
 
@@ -4556,186 +4497,9 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	BUG_ON(online_css(css));
 
 	mutex_unlock(&cgroup_mutex);
-
-	/* this function shouldn't be used with modular subsystems, since they
-	 * need to register a subsys_id, among other things */
-	BUG_ON(ss->module);
 }
 
 /**
- * cgroup_load_subsys: load and register a modular subsystem at runtime
- * @ss: the subsystem to load
- *
- * This function should be called in a modular subsystem's initcall. If the
- * subsystem is built as a module, it will be assigned a new subsys_id and set
- * up for use. If the subsystem is built-in anyway, work is delegated to the
- * simpler cgroup_init_subsys.
- */
-int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
-{
-	struct cgroup_subsys_state *css;
-	int i, ret;
-	struct hlist_node *tmp;
-	struct css_set *cset;
-	unsigned long key;
-
-	/* check name and function validity */
-	if (ss->name == NULL || strlen(ss->name) > MAX_CGROUP_TYPE_NAMELEN ||
-	    ss->css_alloc == NULL || ss->css_free == NULL)
-		return -EINVAL;
-
-	/*
-	 * we don't support callbacks in modular subsystems. this check is
-	 * before the ss->module check for consistency; a subsystem that could
-	 * be a module should still have no callbacks even if the user isn't
-	 * compiling it as one.
-	 */
-	if (ss->fork || ss->exit)
-		return -EINVAL;
-
-	/*
-	 * an optionally modular subsystem is built-in: we want to do nothing,
-	 * since cgroup_init_subsys will have already taken care of it.
-	 */
-	if (ss->module == NULL) {
-		/* a sanity check */
-		BUG_ON(cgroup_subsys[ss->subsys_id] != ss);
-		return 0;
-	}
-
-	/* init base cftset */
-	cgroup_init_cftsets(ss);
-
-	mutex_lock(&cgroup_mutex);
-	mutex_lock(&cgroup_root_mutex);
-	cgroup_subsys[ss->subsys_id] = ss;
-
-	/*
-	 * no ss->css_alloc seems to need anything important in the ss
-	 * struct, so this can happen first (i.e. before the dummy root
-	 * attachment).
-	 */
-	css = ss->css_alloc(cgroup_css(cgroup_dummy_top, ss));
-	if (IS_ERR(css)) {
-		/* failure case - need to deassign the cgroup_subsys[] slot. */
-		cgroup_subsys[ss->subsys_id] = NULL;
-		mutex_unlock(&cgroup_root_mutex);
-		mutex_unlock(&cgroup_mutex);
-		return PTR_ERR(css);
-	}
-
-	ss->root = &cgroup_dummy_root;
-
-	/* our new subsystem will be attached to the dummy hierarchy. */
-	init_css(css, ss, cgroup_dummy_top);
-
-	/*
-	 * Now we need to entangle the css into the existing css_sets. unlike
-	 * in cgroup_init_subsys, there are now multiple css_sets, so each one
-	 * will need a new pointer to it; done by iterating the css_set_table.
-	 * furthermore, modifying the existing css_sets will corrupt the hash
-	 * table state, so each changed css_set will need its hash recomputed.
-	 * this is all done under the css_set_lock.
-	 */
-	write_lock(&css_set_lock);
-	hash_for_each_safe(css_set_table, i, tmp, cset, hlist) {
-		/* skip entries that we already rehashed */
-		if (cset->subsys[ss->subsys_id])
-			continue;
-		/* remove existing entry */
-		hash_del(&cset->hlist);
-		/* set new value */
-		cset->subsys[ss->subsys_id] = css;
-		/* recompute hash and restore entry */
-		key = css_set_hash(cset->subsys);
-		hash_add(css_set_table, &cset->hlist, key);
-	}
-	write_unlock(&css_set_lock);
-
-	ret = online_css(css);
-	if (ret) {
-		ss->css_free(css);
-		goto err_unload;
-	}
-
-	/* success! */
-	mutex_unlock(&cgroup_root_mutex);
-	mutex_unlock(&cgroup_mutex);
-	return 0;
-
-err_unload:
-	mutex_unlock(&cgroup_root_mutex);
-	mutex_unlock(&cgroup_mutex);
-	/* @ss can't be mounted here as try_module_get() would fail */
-	cgroup_unload_subsys(ss);
-	return ret;
-}
-EXPORT_SYMBOL_GPL(cgroup_load_subsys);
-
-/**
- * cgroup_unload_subsys: unload a modular subsystem
- * @ss: the subsystem to unload
- *
- * This function should be called in a modular subsystem's exitcall. When this
- * function is invoked, the refcount on the subsystem's module will be 0, so
- * the subsystem will not be attached to any hierarchy.
- */
-void cgroup_unload_subsys(struct cgroup_subsys *ss)
-{
-	struct cgrp_cset_link *link;
-	struct cgroup_subsys_state *css;
-
-	BUG_ON(ss->module == NULL);
-
-	/*
-	 * we shouldn't be called if the subsystem is in use, and the use of
-	 * try_module_get() in rebind_subsystems() should ensure that it
-	 * doesn't start being used while we're killing it off.
-	 */
-	BUG_ON(ss->root != &cgroup_dummy_root);
-
-	mutex_lock(&cgroup_mutex);
-	mutex_lock(&cgroup_root_mutex);
-
-	css = cgroup_css(cgroup_dummy_top, ss);
-	if (css)
-		offline_css(css);
-
-	/* deassign the subsys_id */
-	cgroup_subsys[ss->subsys_id] = NULL;
-
-	/*
-	 * disentangle the css from all css_sets attached to the dummy
-	 * top. as in loading, we need to pay our respects to the hashtable
-	 * gods.
-	 */
-	write_lock(&css_set_lock);
-	list_for_each_entry(link, &cgroup_dummy_top->cset_links, cset_link) {
-		struct css_set *cset = link->cset;
-		unsigned long key;
-
-		hash_del(&cset->hlist);
-		cset->subsys[ss->subsys_id] = NULL;
-		key = css_set_hash(cset->subsys);
-		hash_add(css_set_table, &cset->hlist, key);
-	}
-	write_unlock(&css_set_lock);
-
-	/*
-	 * remove subsystem's css from the cgroup_dummy_top and free it -
-	 * need to free before marking as null because ss->css_free needs
-	 * the cgrp->subsys pointer to find their state.
-	 */
-	if (css)
-		ss->css_free(css);
-	RCU_INIT_POINTER(cgroup_dummy_top->subsys[ss->subsys_id], NULL);
-
-	mutex_unlock(&cgroup_root_mutex);
-	mutex_unlock(&cgroup_mutex);
-}
-EXPORT_SYMBOL_GPL(cgroup_unload_subsys);
-
-/**
  * cgroup_init_early - cgroup initialization at system boot
  *
  * Initialize cgroups at system boot, and initialize any
@@ -4760,8 +4524,7 @@ int __init cgroup_init_early(void)
 	list_add(&init_cgrp_cset_link.cset_link, &cgroup_dummy_top->cset_links);
 	list_add(&init_cgrp_cset_link.cgrp_link, &init_css_set.cgrp_links);
 
-	/* at bootup time, we don't worry about modular subsystems */
-	for_each_builtin_subsys(ss, i) {
+	for_each_subsys(ss, i) {
 		BUG_ON(!ss->name);
 		BUG_ON(strlen(ss->name) > MAX_CGROUP_TYPE_NAMELEN);
 		BUG_ON(!ss->css_alloc);
@@ -4794,7 +4557,7 @@ int __init cgroup_init(void)
 	if (err)
 		return err;
 
-	for_each_builtin_subsys(ss, i) {
+	for_each_subsys(ss, i) {
 		if (!ss->early_init)
 			cgroup_init_subsys(ss);
 	}
@@ -5029,15 +4792,7 @@ void cgroup_post_fork(struct task_struct *child)
 	 * and addition to css_set.
 	 */
 	if (need_forkexit_callback) {
-		/*
-		 * fork/exit callbacks are supported only for builtin
-		 * subsystems, and the builtin section of the subsys
-		 * array is immutable, so we don't need to lock the
-		 * subsys array here. On the other hand, modular section
-		 * of the array can be freed at module unload, so we
-		 * can't touch that.
-		 */
-		for_each_builtin_subsys(ss, i)
+		for_each_subsys(ss, i)
 			if (ss->fork)
 				ss->fork(child);
 	}
@@ -5102,11 +4857,8 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 	RCU_INIT_POINTER(tsk->cgroups, &init_css_set);
 
 	if (run_callbacks && need_forkexit_callback) {
-		/*
-		 * fork/exit callbacks are supported only for builtin
-		 * subsystems, see cgroup_post_fork() for details.
-		 */
-		for_each_builtin_subsys(ss, i) {
+		/* see cgroup_post_fork() for details */
+		for_each_subsys(ss, i) {
 			if (ss->exit) {
 				struct cgroup_subsys_state *old_css = cset->subsys[i];
 				struct cgroup_subsys_state *css = task_css(tsk, i);
@@ -5225,11 +4977,7 @@ static int __init cgroup_disable(char *str)
 		if (!*token)
 			continue;
 
-		/*
-		 * cgroup_disable, being at boot time, can't know about
-		 * module subsystems, so we don't worry about them.
-		 */
-		for_each_builtin_subsys(ss, i) {
+		for_each_subsys(ss, i) {
 			if (!strcmp(token, ss->name)) {
 				ss->disabled = 1;
 				printk(KERN_INFO "Disabling %s control group"
diff --git a/net/core/netclassid_cgroup.c b/net/core/netclassid_cgroup.c
index 9fc7f90..9e5ad5d 100644
--- a/net/core/netclassid_cgroup.c
+++ b/net/core/netclassid_cgroup.c
@@ -110,5 +110,4 @@ struct cgroup_subsys net_cls_subsys = {
 	.attach			= cgrp_attach,
 	.subsys_id		= net_cls_subsys_id,
 	.base_cftypes		= ss_files,
-	.module			= THIS_MODULE,
 };
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index cc3a31e..857e160 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -252,7 +252,6 @@ struct cgroup_subsys net_prio_subsys = {
 	.attach		= net_prio_attach,
 	.subsys_id	= net_prio_subsys_id,
 	.base_cftypes	= ss_files,
-	.module		= THIS_MODULE,
 };
 
 static int netprio_device_event(struct notifier_block *unused,
-- 
1.8.5.3
