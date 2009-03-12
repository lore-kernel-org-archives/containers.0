From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 6/7] [RFC] Support multiply-bindable cgroup subsystems
Date: Thu, 12 Mar 2009 03:51:48 -0700
Message-ID: <20090312105147.24154.62638.stgit@menage.corp.google.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090312104507.24154.71691.stgit-B63HFAS8fGlSzHKm+aFRNNkmqwFzkYv6@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
List-Id: containers.vger.kernel.org

[RFC] Support multiply-bindable cgroup subsystems

This patch allows a cgroup subsystem to be marked as bindable on
multiple cgroup hierarchies independently, when declared in
cgroup_subsys.h via MULTI_SUBSYS() rather than SUBSYS().

The state for such subsystems cannot be accessed directly from a
task->cgroups (since there's no unique mapping for a task) but instead
must be accessed via a particular control group object.

Multiply-bound subsystems are useful in cases where there's no direct
correspondence between the cgroup configuration and some property of
the kernel outside of the cgroups subsystem.  So this would not be
applicable to e.g. the CFS cgroup, since there has to a unique mapping
from a task to its CFS run queue.

As an example, the "debug" subsystem is marked multiply-bindable,
since it has no state outside the cgroups framework itself.

Example usage:

mount -t cgroup -o name=foo,debug,cpu cgroup /mnt1
mount -t cgroup -o name=bar,debug,memory cgroup /mnt2

Open issues:

- what should /proc/cgroup show for multiply-bindable subsystems?
  Currently it shows just one entry for each hierarchy the subsystem
  is bound to, which means the subsystem doesn't show up when unbound,
  and is indistinguishable from a regular (singleton) subsystem when
  singly-bound.

- should the bind() callback be extended to support passing more
  information to multiply-bindable subsystems? Or should we just scrap
  the bind() callback since nothing appears to be using it.

- how to stop checkpatch.pl complaining about the way the
  SUBSYS/MULTI_SUBSYS macros as used to define the cgroup_subsys_id
  enum in cgroup.h?

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 include/linux/cgroup.h        |   37 ++++++++++-
 include/linux/cgroup_subsys.h |    2 -
 kernel/cgroup.c               |  137 ++++++++++++++++++++++++++---------------
 3 files changed, 123 insertions(+), 53 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index adf6739..9b5999d 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -39,10 +39,37 @@ extern int cgroupstats_build(struct cgroupstats *stats,
 
 extern struct file_operations proc_cgroup_operations;
 
-/* Define the enumeration of all cgroup subsystems */
-#define SUBSYS(_x) _x ## _subsys_id,
+/* Define the enumeration of all cgroup subsystems. There are two
+ * kinds of subsystems:
+ *
+ * - regular (singleton) subsystems can be only mounted once; these
+ * generally correspond to some system that has substantial state
+ * outside of the cgroups framework, or where the state is being used
+ * to control some external behaviour (e.g. CPU scheduler).  Every
+ * task has an associated state pointer (accessed efficiently through
+ * task->cgroups) for each singleton subsystem.
+ *
+ * - multiply-bound subsystems may be mounted on zero or more
+ * hierarchies. Since there's no unique mapping from a task to a
+ * subsystem state pointer for multiply-bound subsystems, the state of
+ * these subsystems cannot be accessed rapidly from a task
+ * pointer. These correspond to subsystems where most or all of the
+ * state is maintained within the subsystem itself, and/or the
+ * subsystem is used for monitoring rather than control.
+ */
 enum cgroup_subsys_id {
+#define SUBSYS(_x) _x ## _subsys_id,
+#define MULTI_SUBSYS(_x)
 #include <linux/cgroup_subsys.h>
+#undef SUBSYS
+#undef MULTI_SUBSYS
+	CGROUP_SINGLETON_SUBSYS_COUNT,
+	CGROUP_DUMMY_ENUM_RESET = CGROUP_SINGLETON_SUBSYS_COUNT - 1,
+#define SUBSYS(_x)
+#define MULTI_SUBSYS(_x) _x ## _subsys_id,
+#include <linux/cgroup_subsys.h>
+#undef SUBSYS
+#undef MULTI_SUBSYS
 	CGROUP_SUBSYS_COUNT
 };
 #undef SUBSYS
@@ -231,7 +258,7 @@ struct css_set {
 	 * time). Multi-subsystems don't have an entry in here since
 	 * there's no unique state for a given task.
 	 */
-	struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT];
+	struct cgroup_subsys_state *subsys[CGROUP_SINGLETON_SUBSYS_COUNT];
 };
 
 /*
@@ -419,8 +446,10 @@ struct cgroup_subsys {
 };
 
 #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
+#define MULTI_SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
 #include <linux/cgroup_subsys.h>
 #undef SUBSYS
+#undef MULTI_SUBSYS
 
 static inline struct cgroup_subsys_state *cgroup_subsys_state(
 	struct cgroup *cgrp, int subsys_id)
@@ -431,6 +460,8 @@ static inline struct cgroup_subsys_state *cgroup_subsys_state(
 static inline struct cgroup_subsys_state *task_subsys_state(
 	struct task_struct *task, int subsys_id)
 {
+	/* This check is optimized out for most callers */
+	BUG_ON(subsys_id >= CGROUP_SINGLETON_SUBSYS_COUNT);
 	return rcu_dereference(task->cgroups->subsys[subsys_id]);
 }
 
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 9c8d31b..f78605e 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -14,7 +14,7 @@ SUBSYS(cpuset)
 /* */
 
 #ifdef CONFIG_CGROUP_DEBUG
-SUBSYS(debug)
+MULTI_SUBSYS(debug)
 #endif
 
 /* */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index fcb8181..942a951 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -52,10 +52,18 @@
 static DEFINE_MUTEX(cgroup_mutex);
 
 /* Generate an array of cgroup subsystem pointers */
-#define SUBSYS(_x) &_x ## _subsys,
 
 static struct cgroup_subsys *subsys[] = {
+#define SUBSYS(_x) &_x ## _subsys,
+#define MULTI_SUBSYS(_x)
+#include <linux/cgroup_subsys.h>
+#undef SUBSYS
+#undef MULTI_SUBSYS
+#define SUBSYS(_x)
+#define MULTI_SUBSYS(_x) &_x ## _subsys,
 #include <linux/cgroup_subsys.h>
+#undef SUBSYS
+#undef MULTI_SUBSYS
 };
 
 /*
@@ -265,7 +273,7 @@ static struct hlist_head *css_set_hash(struct cgroup_subsys_state *css[])
 	int index;
 	unsigned long tmp = 0UL;
 
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++)
+	for (i = 0; i < CGROUP_SINGLETON_SUBSYS_COUNT; i++)
 		tmp += (unsigned long)css[i];
 	tmp = (tmp >> 16) ^ tmp;
 
@@ -435,7 +443,7 @@ static struct css_set *find_existing_css_set(
 
 	/* Build the set of subsystem state objects that we want to
 	 * see in the new css_set */
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+	for (i = 0; i < CGROUP_SINGLETON_SUBSYS_COUNT; i++) {
 		if (root->subsys_bits & (1UL << i)) {
 			/* Subsystem is in this hierarchy. So we want
 			 * the subsystem state from the new
@@ -529,7 +537,7 @@ static struct css_set *find_css_set(
 	struct css_set *oldcg, struct cgroup *cgrp)
 {
 	struct css_set *res;
-	struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
+	struct cgroup_subsys_state *template[CGROUP_SINGLETON_SUBSYS_COUNT];
 
 	struct list_head tmp_cg_links;
 
@@ -853,6 +861,20 @@ static void cgroup_wakeup_rmdir_waiters(const struct cgroup *cgrp)
 		wake_up_all(&cgroup_rmdir_waitq);
 }
 
+static void init_cgroup_css(struct cgroup_subsys_state *css,
+			       struct cgroup_subsys *ss,
+			       struct cgroup *cgrp)
+{
+	css->cgroup = cgrp;
+	atomic_set(&css->refcnt, 1);
+	css->flags = 0;
+	css->id = NULL;
+	if (cgrp == &cgrp->root->top_cgroup)
+		set_bit(CSS_ROOT, &css->flags);
+	BUG_ON(cgrp->subsys[ss->subsys_id]);
+	cgrp->subsys[ss->subsys_id] = css;
+}
+
 static int rebind_subsystems(struct cgroupfs_root *root,
 			     unsigned long final_bits)
 {
@@ -863,7 +885,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	removed_bits = root->subsys_bits & ~final_bits;
 	added_bits = final_bits & ~root->subsys_bits;
 	/* Check that any added subsystems are currently free */
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+	for (i = 0; i < CGROUP_SINGLETON_SUBSYS_COUNT; i++) {
 		unsigned long bit = 1UL << i;
 		if (!(bit & added_bits))
 			continue;
@@ -883,33 +905,57 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	/* Process each subsystem */
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
+		bool singleton = i < CGROUP_SINGLETON_SUBSYS_COUNT;
 		unsigned long bit = 1UL << i;
 		if (bit & added_bits) {
+			struct cgroup_subsys_state *css;
 			/* We're binding this subsystem to this hierarchy */
 			BUG_ON(cgrp->subsys[i]);
-			BUG_ON(!dummytop->subsys[i]);
-			BUG_ON(dummytop->subsys[i]->cgroup != dummytop);
-			BUG_ON(!(rootnode.subsys_bits & bit));
+			if (singleton) {
+				css = dummytop->subsys[i];
+				BUG_ON(!css);
+
+				BUG_ON(css->cgroup != dummytop);
+				BUG_ON(!(rootnode.subsys_bits & bit));
+			} else {
+				BUG_ON(dummytop->subsys[i]);
+				BUG_ON(rootnode.subsys_bits & bit);
+				css = ss->create(ss, cgrp);
+				if (IS_ERR(css))
+					return PTR_ERR(css);
+				init_cgroup_css(css, ss, cgrp);
+			}
 			mutex_lock(&ss->hierarchy_mutex);
-			cgrp->subsys[i] = dummytop->subsys[i];
-			cgrp->subsys[i]->cgroup = cgrp;
+			cgrp->subsys[i] = css;
+			css->cgroup = cgrp;
 			if (ss->bind)
 				ss->bind(ss, cgrp);
-			rootnode.subsys_bits &= ~bit;
+			if (singleton)
+				rootnode.subsys_bits &= ~bit;
 			root->subsys_bits |= bit;
 			mutex_unlock(&ss->hierarchy_mutex);
 		} else if (bit & removed_bits) {
+			struct cgroup_subsys_state *css;
 			/* We're removing this subsystem */
-			BUG_ON(cgrp->subsys[i] != dummytop->subsys[i]);
-			BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
-			BUG_ON(rootnode.subsys_bits & bit);
+			css = cgrp->subsys[i];
+			BUG_ON(css->cgroup != cgrp);
+			if (singleton) {
+				BUG_ON(css != dummytop->subsys[i]);
+				BUG_ON(rootnode.subsys_bits & bit);
+			}
 			mutex_lock(&ss->hierarchy_mutex);
 			if (ss->bind)
 				ss->bind(ss, dummytop);
-			dummytop->subsys[i]->cgroup = dummytop;
+			if (singleton) {
+				css->cgroup = dummytop;
+			} else {
+				/* Is this safe? */
+				ss->destroy(ss, cgrp);
+			}
 			cgrp->subsys[i] = NULL;
 			root->subsys_bits &= ~bit;
-			rootnode.subsys_bits |= bit;
+			if (singleton)
+				rootnode.subsys_bits |= bit;
 			mutex_unlock(&ss->hierarchy_mutex);
 		} else if (bit & final_bits) {
 			/* Subsystem state should already exist */
@@ -974,7 +1020,7 @@ static int parse_cgroupfs_options(char *data,
 			/* Add all non-disabled subsystems */
 			int i;
 			opts->subsys_bits = 0;
-			for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+			for (i = 0; i < CGROUP_SINGLETON_SUBSYS_COUNT; i++) {
 				struct cgroup_subsys *ss = subsys[i];
 				if (!ss->disabled)
 					opts->subsys_bits |= 1ul << i;
@@ -1040,6 +1086,7 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	struct cgroupfs_root *root = sb->s_fs_info;
 	struct cgroup *cgrp = &root->top_cgroup;
 	struct cgroup_sb_opts opts;
+	unsigned long original_bits;
 
 	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
 	mutex_lock(&cgroup_mutex);
@@ -1061,9 +1108,13 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 		goto out_unlock;
 	}
 
+	original_bits = root->subsys_bits;
 	ret = rebind_subsystems(root, opts.subsys_bits);
-	if (ret)
+	if (ret) {
+		int tmp = rebind_subsystems(root, original_bits);
+		BUG_ON(tmp);
 		goto out_unlock;
+	}
 
 	/* (re)populate subsystem files */
 	cgroup_populate_dir(cgrp);
@@ -1265,16 +1316,15 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 		}
 
 		ret = rebind_subsystems(root, opts.subsys_bits);
-		if (ret == -EBUSY) {
+		if (ret) {
+			int tmp = rebind_subsystems(root, 0);
+			BUG_ON(tmp);
 			mutex_unlock(&cgroup_mutex);
 			mutex_unlock(&inode->i_mutex);
 			free_cg_links(&tmp_cg_links);
 			goto drop_new_super;
 		}
 
-		/* EBUSY should be the only error here */
-		BUG_ON(ret);
-
 		list_add(&root->root_list, &roots);
 		root_count++;
 
@@ -2591,20 +2641,6 @@ static int cgroup_populate_dir(struct cgroup *cgrp)
 	return 0;
 }
 
-static void init_cgroup_css(struct cgroup_subsys_state *css,
-			       struct cgroup_subsys *ss,
-			       struct cgroup *cgrp)
-{
-	css->cgroup = cgrp;
-	atomic_set(&css->refcnt, 1);
-	css->flags = 0;
-	css->id = NULL;
-	if (cgrp == dummytop)
-		set_bit(CSS_ROOT, &css->flags);
-	BUG_ON(cgrp->subsys[ss->subsys_id]);
-	cgrp->subsys[ss->subsys_id] = css;
-}
-
 static void cgroup_lock_hierarchy(struct cgroupfs_root *root)
 {
 	/* We need to take each hierarchy_mutex in a consistent order */
@@ -2890,21 +2926,23 @@ again:
 static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 {
 	struct cgroup_subsys_state *css;
-
+	bool singleton = ss->subsys_id < CGROUP_SINGLETON_SUBSYS_COUNT;
 	printk(KERN_INFO "Initializing cgroup subsys %s\n", ss->name);
 
-	/* Create the top cgroup state for this subsystem */
-	css = ss->create(ss, dummytop);
-	/* We don't handle early failures gracefully */
-	BUG_ON(IS_ERR(css));
-	init_cgroup_css(css, ss, dummytop);
-
-	/* Update the init_css_set to contain a subsys
-	 * pointer to this state - since the subsystem is
-	 * newly registered, all tasks and hence the
-	 * init_css_set is in the subsystem's top cgroup. */
-	init_css_set.subsys[ss->subsys_id] = dummytop->subsys[ss->subsys_id];
+	if (singleton) {
+		/* Create the top cgroup state for this subsystem */
+		css = ss->create(ss, dummytop);
+		/* We don't handle early failures gracefully */
+		BUG_ON(IS_ERR(css));
+		init_cgroup_css(css, ss, dummytop);
 
+		/* Update the init_css_set to contain a subsys
+		 * pointer to this state - since the subsystem is
+		 * newly registered, all tasks and hence the
+		 * init_css_set is in the subsystem's top cgroup. */
+		init_css_set.subsys[ss->subsys_id] = css;
+		rootnode.subsys_bits |= 1ULL << ss->subsys_id;
+	}
 	need_forkexit_callback |= ss->fork || ss->exit;
 
 	/* At system boot, before all subsystems have been
@@ -2916,7 +2954,6 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	lockdep_set_class(&ss->hierarchy_mutex, &ss->subsys_key);
 	ss->active = 1;
 
-	rootnode.subsys_bits |= 1ULL << ss->subsys_id;
 }
 
 /**
@@ -3285,6 +3322,8 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
 
 	/* We shouldn't be called by an unregistered subsystem */
 	BUG_ON(!subsys->active);
+	/* We can only support singleton subsystems */
+	BUG_ON(subsys->subsys_id >= CGROUP_SINGLETON_SUBSYS_COUNT);
 
 	/* First figure out what hierarchy and cgroup we're dealing
 	 * with, and pin them so we can drop cgroup_mutex */
