From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 17/17] cgroup: rename
	->create/post_create/pre_destroy/destroy() to
	->css_alloc/online/offline/free()
Date: Mon, 12 Nov 2012 19:01:44 -0800
Message-ID: <1352775704-9023-18-git-send-email-tj__44591.7033394382$1352775836$gmane$org@kernel.org>
References: <1352775704-9023-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1352775704-9023-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Rename cgroup_subsys css lifetime related callbacks to better describe
what their roles are.  Also, update documentation.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt | 49 ++++++++++++++++++++++---------------
 block/blk-cgroup.c                | 14 +++++------
 include/linux/cgroup.h            | 35 ++++++++++++++-------------
 kernel/cgroup.c                   | 51 ++++++++++++++++++++-------------------
 kernel/cgroup_freezer.c           | 20 +++++++--------
 kernel/cpuset.c                   | 10 ++++----
 kernel/events/core.c              |  8 +++---
 kernel/sched/core.c               | 16 ++++++------
 mm/hugetlb_cgroup.c               | 14 +++++------
 mm/memcontrol.c                   | 12 ++++-----
 net/core/netprio_cgroup.c         |  8 +++---
 net/sched/cls_cgroup.c            |  8 +++---
 security/device_cgroup.c          |  8 +++---
 13 files changed, 132 insertions(+), 121 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 9e04196..b06eea2 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -553,16 +553,16 @@ call to cgroup_unload_subsys(). It should also set its_subsys.module =
 THIS_MODULE in its .c file.
 
 Each subsystem may export the following methods. The only mandatory
-methods are create/destroy. Any others that are null are presumed to
+methods are css_alloc/free. Any others that are null are presumed to
 be successful no-ops.
 
-struct cgroup_subsys_state *create(struct cgroup *cgrp)
+struct cgroup_subsys_state *css_alloc(struct cgroup *cgrp)
 (cgroup_mutex held by caller)
 
-Called to create a subsystem state object for a cgroup. The
+Called to allocate a subsystem state object for a cgroup. The
 subsystem should allocate its subsystem state object for the passed
 cgroup, returning a pointer to the new object on success or a
-negative error code. On success, the subsystem pointer should point to
+ERR_PTR() value. On success, the subsystem pointer should point to
 a structure of type cgroup_subsys_state (typically embedded in a
 larger subsystem-specific object), which will be initialized by the
 cgroup system. Note that this will be called at initialization to
@@ -571,24 +571,33 @@ identified by the passed cgroup object having a NULL parent (since
 it's the root of the hierarchy) and may be an appropriate place for
 initialization code.
 
-void destroy(struct cgroup *cgrp)
+int css_online(struct cgroup *cgrp)
 (cgroup_mutex held by caller)
 
-The cgroup system is about to destroy the passed cgroup; the subsystem
-should do any necessary cleanup and free its subsystem state
-object. By the time this method is called, the cgroup has already been
-unlinked from the file system and from the child list of its parent;
-cgroup->parent is still valid. (Note - can also be called for a
-newly-created cgroup if an error occurs after this subsystem's
-create() method has been called for the new cgroup).
-
-int pre_destroy(struct cgroup *cgrp);
-
-Called before checking the reference count on each subsystem. This may
-be useful for subsystems which have some extra references even if
-there are not tasks in the cgroup. If pre_destroy() returns error code,
-rmdir() will fail with it. From this behavior, pre_destroy() can be
-called multiple times against a cgroup.
+Called after @cgrp successfully completed all allocations and made
+visible to cgroup_for_each_child/descendant_*() iterators. The
+subsystem may choose to fail creation by returning -errno. This
+callback can be used to implement reliable state sharing and
+propagation along the hierarchy. See the comment on
+cgroup_for_each_descendant_pre() for details.
+
+void css_offline(struct cgroup *cgrp);
+
+This is the counterpart of css_online() and called iff css_online()
+has succeeded on @cgrp. This signifies the beginning of the end of
+@cgrp. @cgrp is being removed and the subsystem should start dropping
+all references it's holding on @cgrp. When all references are dropped,
+cgroup removal will proceed to the next step - css_free(). After this
+callback, @cgrp should be considered dead to the subsystem.
+
+void css_free(struct cgroup *cgrp)
+(cgroup_mutex held by caller)
+
+The cgroup system is about to free @cgrp; the subsystem should free
+its subsystem state object. By the time this method is called, @cgrp
+is completely unused; @cgrp->parent is still valid. (Note - can also
+be called for a newly-created cgroup if an error occurs after this
+subsystem's create() method has been called for the new cgroup).
 
 int can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 (cgroup_mutex held by caller)
diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 3dc60fc..3f6d39d 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -600,7 +600,7 @@ struct cftype blkcg_files[] = {
 };
 
 /**
- * blkcg_pre_destroy - cgroup pre_destroy callback
+ * blkcg_css_offline - cgroup css_offline callback
  * @cgroup: cgroup of interest
  *
  * This function is called when @cgroup is about to go away and responsible
@@ -610,7 +610,7 @@ struct cftype blkcg_files[] = {
  *
  * This is the blkcg counterpart of ioc_release_fn().
  */
-static void blkcg_pre_destroy(struct cgroup *cgroup)
+static void blkcg_css_offline(struct cgroup *cgroup)
 {
 	struct blkcg *blkcg = cgroup_to_blkcg(cgroup);
 
@@ -634,7 +634,7 @@ static void blkcg_pre_destroy(struct cgroup *cgroup)
 	spin_unlock_irq(&blkcg->lock);
 }
 
-static void blkcg_destroy(struct cgroup *cgroup)
+static void blkcg_css_free(struct cgroup *cgroup)
 {
 	struct blkcg *blkcg = cgroup_to_blkcg(cgroup);
 
@@ -642,7 +642,7 @@ static void blkcg_destroy(struct cgroup *cgroup)
 		kfree(blkcg);
 }
 
-static struct cgroup_subsys_state *blkcg_create(struct cgroup *cgroup)
+static struct cgroup_subsys_state *blkcg_css_alloc(struct cgroup *cgroup)
 {
 	static atomic64_t id_seq = ATOMIC64_INIT(0);
 	struct blkcg *blkcg;
@@ -739,10 +739,10 @@ static int blkcg_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 
 struct cgroup_subsys blkio_subsys = {
 	.name = "blkio",
-	.create = blkcg_create,
+	.css_alloc = blkcg_css_alloc,
+	.css_offline = blkcg_css_offline,
+	.css_free = blkcg_css_free,
 	.can_attach = blkcg_can_attach,
-	.pre_destroy = blkcg_pre_destroy,
-	.destroy = blkcg_destroy,
 	.subsys_id = blkio_subsys_id,
 	.base_cftypes = blkcg_files,
 	.module = THIS_MODULE,
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index fb79d7a..89c631d 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -82,7 +82,7 @@ struct cgroup_subsys_state {
 /* bits in struct cgroup_subsys_state flags field */
 enum {
 	CSS_ROOT	= (1 << 0), /* this CSS is the root of the subsystem */
-	CSS_ONLINE	= (1 << 1), /* between ->post_create() and ->pre_destroy() */
+	CSS_ONLINE	= (1 << 1), /* between ->css_online() and ->css_offline() */
 };
 
 /* Caller must verify that the css is not for root cgroup */
@@ -436,10 +436,11 @@ int cgroup_taskset_size(struct cgroup_taskset *tset);
  */
 
 struct cgroup_subsys {
-	struct cgroup_subsys_state *(*create)(struct cgroup *cgrp);
-	int (*post_create)(struct cgroup *cgrp);
-	void (*pre_destroy)(struct cgroup *cgrp);
-	void (*destroy)(struct cgroup *cgrp);
+	struct cgroup_subsys_state *(*css_alloc)(struct cgroup *cgrp);
+	int (*css_online)(struct cgroup *cgrp);
+	void (*css_offline)(struct cgroup *cgrp);
+	void (*css_free)(struct cgroup *cgrp);
+
 	int (*can_attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
 	void (*cancel_attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
 	void (*attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
@@ -538,13 +539,13 @@ static inline struct cgroup* task_cgroup(struct task_struct *task,
  * @cgroup: cgroup whose children to walk
  *
  * Walk @cgroup's children.  Must be called under rcu_read_lock().  A child
- * cgroup which hasn't finished ->post_create() or already has finished
- * ->pre_destroy() may show up during traversal and it's each subsystem's
+ * cgroup which hasn't finished ->css_online() or already has finished
+ * ->css_offline() may show up during traversal and it's each subsystem's
  * responsibility to verify that each @pos is alive.
  *
- * If a subsystem synchronizes against the parent in its ->post_create()
- * and before starting iterating, a cgroup which finished ->post_create()
- * is guaranteed to be visible in the future iterations.
+ * If a subsystem synchronizes against the parent in its ->css_online() and
+ * before starting iterating, a cgroup which finished ->css_online() is
+ * guaranteed to be visible in the future iterations.
  */
 #define cgroup_for_each_child(pos, cgroup)				\
 	list_for_each_entry_rcu(pos, &(cgroup)->children, sibling)
@@ -558,19 +559,19 @@ struct cgroup *cgroup_next_descendant_pre(struct cgroup *pos,
  * @cgroup: cgroup whose descendants to walk
  *
  * Walk @cgroup's descendants.  Must be called under rcu_read_lock().  A
- * descendant cgroup which hasn't finished ->post_create() or already has
- * finished ->pre_destroy() may show up during traversal and it's each
+ * descendant cgroup which hasn't finished ->css_online() or already has
+ * finished ->css_offline() may show up during traversal and it's each
  * subsystem's responsibility to verify that each @pos is alive.
  *
- * If a subsystem synchronizes against the parent in its ->post_create()
- * and before starting iterating, and synchronizes against @pos on each
- * iteration, any descendant cgroup which finished ->post_create() is
+ * If a subsystem synchronizes against the parent in its ->css_online() and
+ * before starting iterating, and synchronizes against @pos on each
+ * iteration, any descendant cgroup which finished ->css_offline() is
  * guaranteed to be visible in the future iterations.
  *
  * In other words, the following guarantees that a descendant can't escape
  * state updates of its ancestors.
  *
- * my_post_create(@cgrp)
+ * my_online(@cgrp)
  * {
  *	Lock @cgrp->parent and @cgrp;
  *	Inherit state from @cgrp->parent;
@@ -603,7 +604,7 @@ struct cgroup *cgroup_next_descendant_pre(struct cgroup *pos,
  * iteration should lock and unlock both @pos->parent and @pos.
  *
  * Alternatively, a subsystem may choose to use a single global lock to
- * synchronize ->post_create() and ->pre_destroy() against tree-walking
+ * synchronize ->css_online() and ->css_offline() against tree-walking
  * operations.
  */
 #define cgroup_for_each_descendant_pre(pos, cgroup)			\
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index de97cf2..46c5119 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -876,7 +876,7 @@ static void cgroup_diput(struct dentry *dentry, struct inode *inode)
 		 * Release the subsystem state objects.
 		 */
 		for_each_subsys(cgrp->root, ss)
-			ss->destroy(cgrp);
+			ss->css_free(cgrp);
 
 		cgrp->root->number_of_cgroups--;
 		mutex_unlock(&cgroup_mutex);
@@ -4048,8 +4048,8 @@ static int online_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
 
 	lockdep_assert_held(&cgroup_mutex);
 
-	if (ss->post_create)
-		ret = ss->post_create(cgrp);
+	if (ss->css_online)
+		ret = ss->css_online(cgrp);
 	if (!ret)
 		cgrp->subsys[ss->subsys_id]->flags |= CSS_ONLINE;
 	return ret;
@@ -4067,14 +4067,14 @@ static void offline_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
 		return;
 
 	/*
-	 * pre_destroy() should be called with cgroup_mutex unlocked.  See
+	 * css_offline() should be called with cgroup_mutex unlocked.  See
 	 * 3fa59dfbc3 ("cgroup: fix potential deadlock in pre_destroy") for
 	 * details.  This temporary unlocking should go away once
 	 * cgroup_mutex is unexported from controllers.
 	 */
-	if (ss->pre_destroy) {
+	if (ss->css_offline) {
 		mutex_unlock(&cgroup_mutex);
-		ss->pre_destroy(cgrp);
+		ss->css_offline(cgrp);
 		mutex_lock(&cgroup_mutex);
 	}
 
@@ -4136,7 +4136,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	for_each_subsys(root, ss) {
 		struct cgroup_subsys_state *css;
 
-		css = ss->create(cgrp);
+		css = ss->css_alloc(cgrp);
 		if (IS_ERR(css)) {
 			err = PTR_ERR(css);
 			goto err_free_all;
@@ -4147,7 +4147,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 			if (err)
 				goto err_free_all;
 		}
-		/* At error, ->destroy() callback has to free assigned ID. */
+		/* At error, ->css_free() callback has to free assigned ID. */
 		if (clone_children(parent) && ss->post_clone)
 			ss->post_clone(cgrp);
 
@@ -4201,7 +4201,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 err_free_all:
 	for_each_subsys(root, ss) {
 		if (cgrp->subsys[ss->subsys_id])
-			ss->destroy(cgrp);
+			ss->css_free(cgrp);
 	}
 	mutex_unlock(&cgroup_mutex);
 	/* Release the reference count that we took on the superblock */
@@ -4381,7 +4381,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	/* Create the top cgroup state for this subsystem */
 	list_add(&ss->sibling, &rootnode.subsys_list);
 	ss->root = &rootnode;
-	css = ss->create(dummytop);
+	css = ss->css_alloc(dummytop);
 	/* We don't handle early failures gracefully */
 	BUG_ON(IS_ERR(css));
 	init_cgroup_css(css, ss, dummytop);
@@ -4425,7 +4425,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 
 	/* check name and function validity */
 	if (ss->name == NULL || strlen(ss->name) > MAX_CGROUP_TYPE_NAMELEN ||
-	    ss->create == NULL || ss->destroy == NULL)
+	    ss->css_alloc == NULL || ss->css_free == NULL)
 		return -EINVAL;
 
 	/*
@@ -4454,10 +4454,11 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	subsys[ss->subsys_id] = ss;
 
 	/*
-	 * no ss->create seems to need anything important in the ss struct, so
-	 * this can happen first (i.e. before the rootnode attachment).
+	 * no ss->css_alloc seems to need anything important in the ss
+	 * struct, so this can happen first (i.e. before the rootnode
+	 * attachment).
 	 */
-	css = ss->create(dummytop);
+	css = ss->css_alloc(dummytop);
 	if (IS_ERR(css)) {
 		/* failure case - need to deassign the subsys[] slot. */
 		subsys[ss->subsys_id] = NULL;
@@ -4577,12 +4578,12 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	write_unlock(&css_set_lock);
 
 	/*
-	 * remove subsystem's css from the dummytop and free it - need to free
-	 * before marking as null because ss->destroy needs the cgrp->subsys
-	 * pointer to find their state. note that this also takes care of
-	 * freeing the css_id.
+	 * remove subsystem's css from the dummytop and free it - need to
+	 * free before marking as null because ss->css_free needs the
+	 * cgrp->subsys pointer to find their state. note that this also
+	 * takes care of freeing the css_id.
 	 */
-	ss->destroy(dummytop);
+	ss->css_free(dummytop);
 	dummytop->subsys[ss->subsys_id] = NULL;
 
 	mutex_unlock(&cgroup_mutex);
@@ -4626,8 +4627,8 @@ int __init cgroup_init_early(void)
 
 		BUG_ON(!ss->name);
 		BUG_ON(strlen(ss->name) > MAX_CGROUP_TYPE_NAMELEN);
-		BUG_ON(!ss->create);
-		BUG_ON(!ss->destroy);
+		BUG_ON(!ss->css_alloc);
+		BUG_ON(!ss->css_free);
 		if (ss->subsys_id != i) {
 			printk(KERN_ERR "cgroup: Subsys %s id == %d\n",
 			       ss->name, ss->subsys_id);
@@ -5439,7 +5440,7 @@ struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id)
 }
 
 #ifdef CONFIG_CGROUP_DEBUG
-static struct cgroup_subsys_state *debug_create(struct cgroup *cont)
+static struct cgroup_subsys_state *debug_css_alloc(struct cgroup *cont)
 {
 	struct cgroup_subsys_state *css = kzalloc(sizeof(*css), GFP_KERNEL);
 
@@ -5449,7 +5450,7 @@ static struct cgroup_subsys_state *debug_create(struct cgroup *cont)
 	return css;
 }
 
-static void debug_destroy(struct cgroup *cont)
+static void debug_css_free(struct cgroup *cont)
 {
 	kfree(cont->subsys[debug_subsys_id]);
 }
@@ -5578,8 +5579,8 @@ static struct cftype debug_files[] =  {
 
 struct cgroup_subsys debug_subsys = {
 	.name = "debug",
-	.create = debug_create,
-	.destroy = debug_destroy,
+	.css_alloc = debug_css_alloc,
+	.css_free = debug_css_free,
 	.subsys_id = debug_subsys_id,
 	.base_cftypes = debug_files,
 };
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index ee8bb67..75dda1e 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -92,7 +92,7 @@ static const char *freezer_state_strs(unsigned int state)
 
 struct cgroup_subsys freezer_subsys;
 
-static struct cgroup_subsys_state *freezer_create(struct cgroup *cgroup)
+static struct cgroup_subsys_state *freezer_css_alloc(struct cgroup *cgroup)
 {
 	struct freezer *freezer;
 
@@ -105,14 +105,14 @@ static struct cgroup_subsys_state *freezer_create(struct cgroup *cgroup)
 }
 
 /**
- * freezer_post_create - commit creation of a freezer cgroup
+ * freezer_css_online - commit creation of a freezer cgroup
  * @cgroup: cgroup being created
  *
  * We're committing to creation of @cgroup.  Mark it online and inherit
  * parent's freezing state while holding both parent's and our
  * freezer->lock.
  */
-static int freezer_post_create(struct cgroup *cgroup)
+static int freezer_css_online(struct cgroup *cgroup)
 {
 	struct freezer *freezer = cgroup_freezer(cgroup);
 	struct freezer *parent = parent_freezer(freezer);
@@ -141,13 +141,13 @@ static int freezer_post_create(struct cgroup *cgroup)
 }
 
 /**
- * freezer_pre_destroy - initiate destruction of @cgroup
+ * freezer_css_offline - initiate destruction of @cgroup
  * @cgroup: cgroup being destroyed
  *
  * @cgroup is going away.  Mark it dead and decrement system_freezing_count
  * if it was holding one.
  */
-static void freezer_pre_destroy(struct cgroup *cgroup)
+static void freezer_css_offline(struct cgroup *cgroup)
 {
 	struct freezer *freezer = cgroup_freezer(cgroup);
 
@@ -161,7 +161,7 @@ static void freezer_pre_destroy(struct cgroup *cgroup)
 	spin_unlock_irq(&freezer->lock);
 }
 
-static void freezer_destroy(struct cgroup *cgroup)
+static void freezer_css_free(struct cgroup *cgroup)
 {
 	kfree(cgroup_freezer(cgroup));
 }
@@ -477,10 +477,10 @@ static struct cftype files[] = {
 
 struct cgroup_subsys freezer_subsys = {
 	.name		= "freezer",
-	.create		= freezer_create,
-	.post_create	= freezer_post_create,
-	.pre_destroy	= freezer_pre_destroy,
-	.destroy	= freezer_destroy,
+	.css_alloc	= freezer_css_alloc,
+	.css_online	= freezer_css_online,
+	.css_offline	= freezer_css_offline,
+	.css_free	= freezer_css_free,
 	.subsys_id	= freezer_subsys_id,
 	.attach		= freezer_attach,
 	.fork		= freezer_fork,
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index f33c715..0693133 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1821,11 +1821,11 @@ static void cpuset_post_clone(struct cgroup *cgroup)
 }
 
 /*
- *	cpuset_create - create a cpuset
+ *	cpuset_css_alloc - allocate a cpuset css
  *	cont:	control group that the new cpuset will be part of
  */
 
-static struct cgroup_subsys_state *cpuset_create(struct cgroup *cont)
+static struct cgroup_subsys_state *cpuset_css_alloc(struct cgroup *cont)
 {
 	struct cpuset *cs;
 	struct cpuset *parent;
@@ -1864,7 +1864,7 @@ static struct cgroup_subsys_state *cpuset_create(struct cgroup *cont)
  * will call async_rebuild_sched_domains().
  */
 
-static void cpuset_destroy(struct cgroup *cont)
+static void cpuset_css_free(struct cgroup *cont)
 {
 	struct cpuset *cs = cgroup_cs(cont);
 
@@ -1878,8 +1878,8 @@ static void cpuset_destroy(struct cgroup *cont)
 
 struct cgroup_subsys cpuset_subsys = {
 	.name = "cpuset",
-	.create = cpuset_create,
-	.destroy = cpuset_destroy,
+	.css_alloc = cpuset_css_alloc,
+	.css_free = cpuset_css_free,
 	.can_attach = cpuset_can_attach,
 	.attach = cpuset_attach,
 	.post_clone = cpuset_post_clone,
diff --git a/kernel/events/core.c b/kernel/events/core.c
index dbccf83..f9ff549 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -7434,7 +7434,7 @@ unlock:
 device_initcall(perf_event_sysfs_init);
 
 #ifdef CONFIG_CGROUP_PERF
-static struct cgroup_subsys_state *perf_cgroup_create(struct cgroup *cont)
+static struct cgroup_subsys_state *perf_cgroup_css_alloc(struct cgroup *cont)
 {
 	struct perf_cgroup *jc;
 
@@ -7451,7 +7451,7 @@ static struct cgroup_subsys_state *perf_cgroup_create(struct cgroup *cont)
 	return &jc->css;
 }
 
-static void perf_cgroup_destroy(struct cgroup *cont)
+static void perf_cgroup_css_free(struct cgroup *cont)
 {
 	struct perf_cgroup *jc;
 	jc = container_of(cgroup_subsys_state(cont, perf_subsys_id),
@@ -7492,8 +7492,8 @@ static void perf_cgroup_exit(struct cgroup *cgrp, struct cgroup *old_cgrp,
 struct cgroup_subsys perf_subsys = {
 	.name		= "perf_event",
 	.subsys_id	= perf_subsys_id,
-	.create		= perf_cgroup_create,
-	.destroy	= perf_cgroup_destroy,
+	.css_alloc	= perf_cgroup_css_alloc,
+	.css_free	= perf_cgroup_css_free,
 	.exit		= perf_cgroup_exit,
 	.attach		= perf_cgroup_attach,
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 2d8927f..6f20c8f 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7468,7 +7468,7 @@ static inline struct task_group *cgroup_tg(struct cgroup *cgrp)
 			    struct task_group, css);
 }
 
-static struct cgroup_subsys_state *cpu_cgroup_create(struct cgroup *cgrp)
+static struct cgroup_subsys_state *cpu_cgroup_css_alloc(struct cgroup *cgrp)
 {
 	struct task_group *tg, *parent;
 
@@ -7485,7 +7485,7 @@ static struct cgroup_subsys_state *cpu_cgroup_create(struct cgroup *cgrp)
 	return &tg->css;
 }
 
-static void cpu_cgroup_destroy(struct cgroup *cgrp)
+static void cpu_cgroup_css_free(struct cgroup *cgrp)
 {
 	struct task_group *tg = cgroup_tg(cgrp);
 
@@ -7845,8 +7845,8 @@ static struct cftype cpu_files[] = {
 
 struct cgroup_subsys cpu_cgroup_subsys = {
 	.name		= "cpu",
-	.create		= cpu_cgroup_create,
-	.destroy	= cpu_cgroup_destroy,
+	.css_alloc	= cpu_cgroup_css_alloc,
+	.css_free	= cpu_cgroup_css_free,
 	.can_attach	= cpu_cgroup_can_attach,
 	.attach		= cpu_cgroup_attach,
 	.exit		= cpu_cgroup_exit,
@@ -7869,7 +7869,7 @@ struct cgroup_subsys cpu_cgroup_subsys = {
 struct cpuacct root_cpuacct;
 
 /* create a new cpu accounting group */
-static struct cgroup_subsys_state *cpuacct_create(struct cgroup *cgrp)
+static struct cgroup_subsys_state *cpuacct_css_alloc(struct cgroup *cgrp)
 {
 	struct cpuacct *ca;
 
@@ -7899,7 +7899,7 @@ out:
 }
 
 /* destroy an existing cpu accounting group */
-static void cpuacct_destroy(struct cgroup *cgrp)
+static void cpuacct_css_free(struct cgroup *cgrp)
 {
 	struct cpuacct *ca = cgroup_ca(cgrp);
 
@@ -8070,8 +8070,8 @@ void cpuacct_charge(struct task_struct *tsk, u64 cputime)
 
 struct cgroup_subsys cpuacct_subsys = {
 	.name = "cpuacct",
-	.create = cpuacct_create,
-	.destroy = cpuacct_destroy,
+	.css_alloc = cpuacct_css_alloc,
+	.css_free = cpuacct_css_free,
 	.subsys_id = cpuacct_subsys_id,
 	.base_cftypes = files,
 };
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 0d3a1a3..b5bde7a 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -77,7 +77,7 @@ static inline bool hugetlb_cgroup_have_usage(struct cgroup *cg)
 	return false;
 }
 
-static struct cgroup_subsys_state *hugetlb_cgroup_create(struct cgroup *cgroup)
+static struct cgroup_subsys_state *hugetlb_cgroup_css_alloc(struct cgroup *cgroup)
 {
 	int idx;
 	struct cgroup *parent_cgroup;
@@ -101,7 +101,7 @@ static struct cgroup_subsys_state *hugetlb_cgroup_create(struct cgroup *cgroup)
 	return &h_cgroup->css;
 }
 
-static void hugetlb_cgroup_destroy(struct cgroup *cgroup)
+static void hugetlb_cgroup_css_free(struct cgroup *cgroup)
 {
 	struct hugetlb_cgroup *h_cgroup;
 
@@ -155,7 +155,7 @@ out:
  * Force the hugetlb cgroup to empty the hugetlb resources by moving them to
  * the parent cgroup.
  */
-static void hugetlb_cgroup_pre_destroy(struct cgroup *cgroup)
+static void hugetlb_cgroup_css_offline(struct cgroup *cgroup)
 {
 	struct hstate *h;
 	struct page *page;
@@ -404,8 +404,8 @@ void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
 
 struct cgroup_subsys hugetlb_subsys = {
 	.name = "hugetlb",
-	.create     = hugetlb_cgroup_create,
-	.pre_destroy = hugetlb_cgroup_pre_destroy,
-	.destroy    = hugetlb_cgroup_destroy,
-	.subsys_id  = hugetlb_subsys_id,
+	.css_alloc	= hugetlb_cgroup_css_alloc,
+	.css_offline	= hugetlb_cgroup_css_offline,
+	.css_free	= hugetlb_cgroup_css_free,
+	.subsys_id	= hugetlb_subsys_id,
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 08adaaa..8b0b2b0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4922,7 +4922,7 @@ err_cleanup:
 }
 
 static struct cgroup_subsys_state * __ref
-mem_cgroup_create(struct cgroup *cont)
+mem_cgroup_css_alloc(struct cgroup *cont)
 {
 	struct mem_cgroup *memcg, *parent;
 	long error = -ENOMEM;
@@ -5003,14 +5003,14 @@ free_out:
 	return ERR_PTR(error);
 }
 
-static void mem_cgroup_pre_destroy(struct cgroup *cont)
+static void mem_cgroup_css_offline(struct cgroup *cont)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 
 	mem_cgroup_reparent_charges(memcg);
 }
 
-static void mem_cgroup_destroy(struct cgroup *cont)
+static void mem_cgroup_css_free(struct cgroup *cont)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 
@@ -5600,9 +5600,9 @@ static void mem_cgroup_move_task(struct cgroup *cont,
 struct cgroup_subsys mem_cgroup_subsys = {
 	.name = "memory",
 	.subsys_id = mem_cgroup_subsys_id,
-	.create = mem_cgroup_create,
-	.pre_destroy = mem_cgroup_pre_destroy,
-	.destroy = mem_cgroup_destroy,
+	.css_alloc = mem_cgroup_css_alloc,
+	.css_offline = mem_cgroup_css_offline,
+	.css_free = mem_cgroup_css_free,
 	.can_attach = mem_cgroup_can_attach,
 	.cancel_attach = mem_cgroup_cancel_attach,
 	.attach = mem_cgroup_move_task,
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 79285a3..f0b6b0d 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -108,7 +108,7 @@ static int write_update_netdev_table(struct net_device *dev)
 	return ret;
 }
 
-static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
+static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
 {
 	struct cgroup_netprio_state *cs;
 	int ret = -EINVAL;
@@ -132,7 +132,7 @@ out:
 	return ERR_PTR(ret);
 }
 
-static void cgrp_destroy(struct cgroup *cgrp)
+static void cgrp_css_free(struct cgroup *cgrp)
 {
 	struct cgroup_netprio_state *cs;
 	struct net_device *dev;
@@ -276,8 +276,8 @@ static struct cftype ss_files[] = {
 
 struct cgroup_subsys net_prio_subsys = {
 	.name		= "net_prio",
-	.create		= cgrp_create,
-	.destroy	= cgrp_destroy,
+	.css_alloc	= cgrp_css_alloc,
+	.css_free	= cgrp_css_free,
 	.attach		= net_prio_attach,
 	.subsys_id	= net_prio_subsys_id,
 	.base_cftypes	= ss_files,
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 2ecde22..8cdc18e 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -34,7 +34,7 @@ static inline struct cgroup_cls_state *task_cls_state(struct task_struct *p)
 			    struct cgroup_cls_state, css);
 }
 
-static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
+static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
 {
 	struct cgroup_cls_state *cs;
 
@@ -48,7 +48,7 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
 	return &cs->css;
 }
 
-static void cgrp_destroy(struct cgroup *cgrp)
+static void cgrp_css_free(struct cgroup *cgrp)
 {
 	kfree(cgrp_cls_state(cgrp));
 }
@@ -75,8 +75,8 @@ static struct cftype ss_files[] = {
 
 struct cgroup_subsys net_cls_subsys = {
 	.name		= "net_cls",
-	.create		= cgrp_create,
-	.destroy	= cgrp_destroy,
+	.css_alloc	= cgrp_css_alloc,
+	.css_free	= cgrp_css_free,
 	.subsys_id	= net_cls_subsys_id,
 	.base_cftypes	= ss_files,
 	.module		= THIS_MODULE,
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 78a16f5..19ecc8d 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -180,7 +180,7 @@ static void dev_exception_clean(struct dev_cgroup *dev_cgroup)
 /*
  * called from kernel/cgroup.c with cgroup_lock() held.
  */
-static struct cgroup_subsys_state *devcgroup_create(struct cgroup *cgroup)
+static struct cgroup_subsys_state *devcgroup_css_alloc(struct cgroup *cgroup)
 {
 	struct dev_cgroup *dev_cgroup, *parent_dev_cgroup;
 	struct cgroup *parent_cgroup;
@@ -210,7 +210,7 @@ static struct cgroup_subsys_state *devcgroup_create(struct cgroup *cgroup)
 	return &dev_cgroup->css;
 }
 
-static void devcgroup_destroy(struct cgroup *cgroup)
+static void devcgroup_css_free(struct cgroup *cgroup)
 {
 	struct dev_cgroup *dev_cgroup;
 
@@ -564,8 +564,8 @@ static struct cftype dev_cgroup_files[] = {
 struct cgroup_subsys devices_subsys = {
 	.name = "devices",
 	.can_attach = devcgroup_can_attach,
-	.create = devcgroup_create,
-	.destroy = devcgroup_destroy,
+	.css_alloc = devcgroup_css_alloc,
+	.css_free = devcgroup_css_free,
 	.subsys_id = devices_subsys_id,
 	.base_cftypes = dev_cgroup_files,
 
-- 
1.7.11.7
