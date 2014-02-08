From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 6/8] cgroup: remove cgroup->name
Date: Sat,  8 Feb 2014 11:38:27 -0500
Message-ID: <1391877509-10855-7-git-send-email-tj__10474.318805109$1391877574$gmane$org@kernel.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup->name handling became quite complicated over time involving
dedicated struct cgroup_name for RCU protection.  Now that cgroup is
on kernfs, we can drop all of it and simply use kernfs_name/path() and
friends.  Replace cgroup->name and all related code with kernfs
name/path constructs.

* Reimplement cgroup_name() and cgroup_path() as thin wrappers on top
  of kernfs counterparts, which involves semantic changes.
  pr_cont_cgroup_name() and pr_cont_cgroup_path() added.

* cgroup->name handling dropped from cgroup_rename().

* All users of cgroup_name/path() updated to the new semantics.  Users
  which were formatting the string just to printk them are converted
  to use pr_cont_cgroup_name/path() instead, which simplifies things
  quite a bit.  As cgroup_name() no longer requires RCU read lock
  around it, RCU lockings which were protecting only cgroup_name() are
  removed.

v2: Comment above oom_info_lock updated as suggested by Michal.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
 block/blk-cgroup.h     |  12 ++--
 fs/kernfs/dir.c        |   1 +
 include/linux/cgroup.h |  55 +++++++++---------
 kernel/cgroup.c        | 148 ++++++++++++-------------------------------------
 kernel/cpuset.c        |  27 +++++----
 kernel/sched/debug.c   |   3 +-
 mm/memcontrol.c        |  68 ++++++-----------------
 7 files changed, 103 insertions(+), 211 deletions(-)

diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 453b528..15a8d64 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -241,12 +241,16 @@ static inline struct blkcg_gq *pd_to_blkg(struct blkg_policy_data *pd)
  */
 static inline int blkg_path(struct blkcg_gq *blkg, char *buf, int buflen)
 {
-	int ret;
+	char *p;
 
-	ret = cgroup_path(blkg->blkcg->css.cgroup, buf, buflen);
-	if (ret)
+	p = cgroup_path(blkg->blkcg->css.cgroup, buf, buflen);
+	if (!p) {
 		strncpy(buf, "<unavailable>", buflen);
-	return ret;
+		return -ENAMETOOLONG;
+	}
+
+	memmove(buf, p, buf + buflen - p);
+	return 0;
 }
 
 /**
diff --git a/fs/kernfs/dir.c b/fs/kernfs/dir.c
index a347792..939684e 100644
--- a/fs/kernfs/dir.c
+++ b/fs/kernfs/dir.c
@@ -112,6 +112,7 @@ char *kernfs_path(struct kernfs_node *kn, char *buf, size_t buflen)
 	spin_unlock_irqrestore(&kernfs_rename_lock, flags);
 	return p;
 }
+EXPORT_SYMBOL_GPL(kernfs_path);
 
 /**
  * pr_cont_kernfs_name - pr_cont name of a kernfs_node
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 3c0c7e4..8202abb 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -138,11 +138,6 @@ enum {
 	CGRP_SANE_BEHAVIOR,
 };
 
-struct cgroup_name {
-	struct rcu_head rcu_head;
-	char name[];
-};
-
 struct cgroup {
 	unsigned long flags;		/* "unsigned long" so bitops work */
 
@@ -177,19 +172,6 @@ struct cgroup {
 	 */
 	u64 serial_nr;
 
-	/*
-	 * This is a copy of dentry->d_name, and it's needed because
-	 * we can't use dentry->d_name in cgroup_path().
-	 *
-	 * You must acquire rcu_read_lock() to access cgrp->name, and
-	 * the only place that can change it is rename(), which is
-	 * protected by parent dir's i_mutex.
-	 *
-	 * Normally you should use cgroup_name() wrapper rather than
-	 * access it directly.
-	 */
-	struct cgroup_name __rcu *name;
-
 	/* Private pointers for each registered subsystem */
 	struct cgroup_subsys_state __rcu *subsys[CGROUP_SUBSYS_COUNT];
 
@@ -477,12 +459,6 @@ static inline bool cgroup_sane_behavior(const struct cgroup *cgrp)
 	return cgrp->root->flags & CGRP_ROOT_SANE_BEHAVIOR;
 }
 
-/* Caller should hold rcu_read_lock() */
-static inline const char *cgroup_name(const struct cgroup *cgrp)
-{
-	return rcu_dereference(cgrp->name)->name;
-}
-
 /* returns ino associated with a cgroup, 0 indicates unmounted root */
 static inline ino_t cgroup_ino(struct cgroup *cgrp)
 {
@@ -501,14 +477,39 @@ static inline struct cftype *seq_cft(struct seq_file *seq)
 
 struct cgroup_subsys_state *seq_css(struct seq_file *seq);
 
+/*
+ * Name / path handling functions.  All are thin wrappers around the kernfs
+ * counterparts and can be called under any context.
+ */
+
+static inline int cgroup_name(struct cgroup *cgrp, char *buf, size_t buflen)
+{
+	return kernfs_name(cgrp->kn, buf, buflen);
+}
+
+static inline char * __must_check cgroup_path(struct cgroup *cgrp, char *buf,
+					      size_t buflen)
+{
+	return kernfs_path(cgrp->kn, buf, buflen);
+}
+
+static inline void pr_cont_cgroup_name(struct cgroup *cgrp)
+{
+	pr_cont_kernfs_name(cgrp->kn);
+}
+
+static inline void pr_cont_cgroup_path(struct cgroup *cgrp)
+{
+	pr_cont_kernfs_path(cgrp->kn);
+}
+
+char *task_cgroup_path(struct task_struct *task, char *buf, size_t buflen);
+
 int cgroup_add_cftypes(struct cgroup_subsys *ss, struct cftype *cfts);
 int cgroup_rm_cftypes(struct cftype *cfts);
 
 bool cgroup_is_descendant(struct cgroup *cgrp, struct cgroup *ancestor);
 
-int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen);
-int task_cgroup_path(struct task_struct *task, char *buf, size_t buflen);
-
 int cgroup_task_count(const struct cgroup *cgrp);
 
 /*
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index da8aef0..a48f4ca 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -145,8 +145,6 @@ static int cgroup_root_count;
 /* hierarchy ID allocation and mapping, protected by cgroup_mutex */
 static DEFINE_IDR(cgroup_hierarchy_idr);
 
-static struct cgroup_name root_cgroup_name = { .name = "/" };
-
 /*
  * Assign a monotonically increasing serial number to cgroups.  It
  * guarantees cgroups with bigger numbers are newer than those with smaller
@@ -888,17 +886,6 @@ static int cgroup_populate_dir(struct cgroup *cgrp, unsigned long subsys_mask);
 static struct kernfs_syscall_ops cgroup_kf_syscall_ops;
 static const struct file_operations proc_cgroupstats_operations;
 
-static struct cgroup_name *cgroup_alloc_name(const char *name_str)
-{
-	struct cgroup_name *name;
-
-	name = kmalloc(sizeof(*name) + strlen(name_str) + 1, GFP_KERNEL);
-	if (!name)
-		return NULL;
-	strcpy(name->name, name_str);
-	return name;
-}
-
 static char *cgroup_file_name(struct cgroup *cgrp, const struct cftype *cft,
 			      char *buf)
 {
@@ -958,8 +945,6 @@ static void cgroup_free_fn(struct work_struct *work)
 	cgroup_pidlist_destroy_all(cgrp);
 
 	kernfs_put(cgrp->kn);
-
-	kfree(rcu_dereference_raw(cgrp->name));
 	kfree(cgrp);
 }
 
@@ -1375,7 +1360,6 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 	INIT_LIST_HEAD(&root->root_list);
 	root->number_of_cgroups = 1;
 	cgrp->root = root;
-	RCU_INIT_POINTER(cgrp->name, &root_cgroup_name);
 	init_cgroup_housekeeping(cgrp);
 	idr_init(&root->cgroup_idr);
 }
@@ -1596,57 +1580,6 @@ static struct file_system_type cgroup_fs_type = {
 static struct kobject *cgroup_kobj;
 
 /**
- * cgroup_path - generate the path of a cgroup
- * @cgrp: the cgroup in question
- * @buf: the buffer to write the path into
- * @buflen: the length of the buffer
- *
- * Writes path of cgroup into buf.  Returns 0 on success, -errno on error.
- *
- * We can't generate cgroup path using dentry->d_name, as accessing
- * dentry->name must be protected by irq-unsafe dentry->d_lock or parent
- * inode's i_mutex, while on the other hand cgroup_path() can be called
- * with some irq-safe spinlocks held.
- */
-int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
-{
-	int ret = -ENAMETOOLONG;
-	char *start;
-
-	if (!cgrp->parent) {
-		if (strlcpy(buf, "/", buflen) >= buflen)
-			return -ENAMETOOLONG;
-		return 0;
-	}
-
-	start = buf + buflen - 1;
-	*start = '\0';
-
-	rcu_read_lock();
-	do {
-		const char *name = cgroup_name(cgrp);
-		int len;
-
-		len = strlen(name);
-		if ((start -= len) < buf)
-			goto out;
-		memcpy(start, name, len);
-
-		if (--start < buf)
-			goto out;
-		*start = '/';
-
-		cgrp = cgrp->parent;
-	} while (cgrp->parent);
-	ret = 0;
-	memmove(buf, start, buf + buflen - start);
-out:
-	rcu_read_unlock();
-	return ret;
-}
-EXPORT_SYMBOL_GPL(cgroup_path);
-
-/**
  * task_cgroup_path - cgroup path of a task in the first cgroup hierarchy
  * @task: target task
  * @buf: the buffer to write the path into
@@ -1657,16 +1590,14 @@ EXPORT_SYMBOL_GPL(cgroup_path);
  * function grabs cgroup_mutex and shouldn't be used inside locks used by
  * cgroup controller callbacks.
  *
- * Returns 0 on success, fails with -%ENAMETOOLONG if @buflen is too short.
+ * Return value is the same as kernfs_path().
  */
-int task_cgroup_path(struct task_struct *task, char *buf, size_t buflen)
+char *task_cgroup_path(struct task_struct *task, char *buf, size_t buflen)
 {
 	struct cgroupfs_root *root;
 	struct cgroup *cgrp;
-	int hierarchy_id = 1, ret = 0;
-
-	if (buflen < 2)
-		return -ENAMETOOLONG;
+	int hierarchy_id = 1;
+	char *path = NULL;
 
 	mutex_lock(&cgroup_mutex);
 
@@ -1674,14 +1605,15 @@ int task_cgroup_path(struct task_struct *task, char *buf, size_t buflen)
 
 	if (root) {
 		cgrp = task_cgroup_from_root(task, root);
-		ret = cgroup_path(cgrp, buf, buflen);
+		path = cgroup_path(cgrp, buf, buflen);
 	} else {
 		/* if no hierarchy exists, everyone is in "/" */
-		memcpy(buf, "/", 2);
+		if (strlcpy(buf, "/", buflen) < buflen)
+			path = buf;
 	}
 
 	mutex_unlock(&cgroup_mutex);
-	return ret;
+	return path;
 }
 EXPORT_SYMBOL_GPL(task_cgroup_path);
 
@@ -2209,7 +2141,6 @@ static int cgroup_rename(struct kernfs_node *kn, struct kernfs_node *new_parent,
 			 const char *new_name_str)
 {
 	struct cgroup *cgrp = kn->priv;
-	struct cgroup_name *name, *old_name;
 	int ret;
 
 	if (kernfs_type(kn) != KERNFS_DIR)
@@ -2224,25 +2155,13 @@ static int cgroup_rename(struct kernfs_node *kn, struct kernfs_node *new_parent,
 	if (cgroup_sane_behavior(cgrp))
 		return -EPERM;
 
-	name = cgroup_alloc_name(new_name_str);
-	if (!name)
-		return -ENOMEM;
-
 	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 
 	ret = kernfs_rename(kn, new_parent, new_name_str);
-	if (!ret) {
-		old_name = rcu_dereference_protected(cgrp->name, true);
-		rcu_assign_pointer(cgrp->name, name);
-	} else {
-		old_name = name;
-	}
 
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgroup_tree_mutex);
-
-	kfree_rcu(old_name, rcu_head);
 	return ret;
 }
 
@@ -3717,14 +3636,13 @@ err_free:
 /**
  * cgroup_create - create a cgroup
  * @parent: cgroup that will be parent of the new cgroup
- * @name_str: name of the new cgroup
+ * @name: name of the new cgroup
  * @mode: mode to set on new cgroup
  */
-static long cgroup_create(struct cgroup *parent, const char *name_str,
+static long cgroup_create(struct cgroup *parent, const char *name,
 			  umode_t mode)
 {
 	struct cgroup *cgrp;
-	struct cgroup_name *name;
 	struct cgroupfs_root *root = parent->root;
 	int ssid, err;
 	struct cgroup_subsys *ss;
@@ -3735,13 +3653,6 @@ static long cgroup_create(struct cgroup *parent, const char *name_str,
 	if (!cgrp)
 		return -ENOMEM;
 
-	name = cgroup_alloc_name(name_str);
-	if (!name) {
-		err = -ENOMEM;
-		goto err_free_cgrp;
-	}
-	rcu_assign_pointer(cgrp->name, name);
-
 	/*
 	 * Temporarily set the pointer to NULL, so idr_find() won't return
 	 * a half-baked cgroup.
@@ -3749,7 +3660,7 @@ static long cgroup_create(struct cgroup *parent, const char *name_str,
 	cgrp->id = idr_alloc(&root->cgroup_idr, NULL, 1, 0, GFP_KERNEL);
 	if (cgrp->id < 0) {
 		err = -ENOMEM;
-		goto err_free_name;
+		goto err_free_cgrp;
 	}
 
 	mutex_lock(&cgroup_tree_mutex);
@@ -3779,7 +3690,7 @@ static long cgroup_create(struct cgroup *parent, const char *name_str,
 		set_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags);
 
 	/* create the directory */
-	kn = kernfs_create_dir(parent->kn, name->name, mode, cgrp);
+	kn = kernfs_create_dir(parent->kn, name, mode, cgrp);
 	if (IS_ERR(kn)) {
 		err = PTR_ERR(kn);
 		goto err_unlock;
@@ -3836,8 +3747,6 @@ err_unlock:
 err_unlock_tree:
 	mutex_unlock(&cgroup_tree_mutex);
 	idr_remove(&root->cgroup_idr, cgrp->id);
-err_free_name:
-	kfree(rcu_dereference_raw(cgrp->name));
 err_free_cgrp:
 	kfree(cgrp);
 	return err;
@@ -4302,12 +4211,12 @@ int proc_cgroup_show(struct seq_file *m, void *v)
 {
 	struct pid *pid;
 	struct task_struct *tsk;
-	char *buf;
+	char *buf, *path;
 	int retval;
 	struct cgroupfs_root *root;
 
 	retval = -ENOMEM;
-	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	buf = kmalloc(PATH_MAX, GFP_KERNEL);
 	if (!buf)
 		goto out;
 
@@ -4335,10 +4244,12 @@ int proc_cgroup_show(struct seq_file *m, void *v)
 				   root->name);
 		seq_putc(m, ':');
 		cgrp = task_cgroup_from_root(tsk, root);
-		retval = cgroup_path(cgrp, buf, PAGE_SIZE);
-		if (retval < 0)
+		path = cgroup_path(cgrp, buf, PATH_MAX);
+		if (!path) {
+			retval = -ENAMETOOLONG;
 			goto out_unlock;
-		seq_puts(m, buf);
+		}
+		seq_puts(m, path);
 		seq_putc(m, '\n');
 	}
 
@@ -4586,16 +4497,17 @@ static void cgroup_release_agent(struct work_struct *work)
 	while (!list_empty(&release_list)) {
 		char *argv[3], *envp[3];
 		int i;
-		char *pathbuf = NULL, *agentbuf = NULL;
+		char *pathbuf = NULL, *agentbuf = NULL, *path;
 		struct cgroup *cgrp = list_entry(release_list.next,
 						    struct cgroup,
 						    release_list);
 		list_del_init(&cgrp->release_list);
 		raw_spin_unlock(&release_list_lock);
-		pathbuf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		pathbuf = kmalloc(PATH_MAX, GFP_KERNEL);
 		if (!pathbuf)
 			goto continue_free;
-		if (cgroup_path(cgrp, pathbuf, PAGE_SIZE) < 0)
+		path = cgroup_path(cgrp, pathbuf, PATH_MAX);
+		if (!path)
 			goto continue_free;
 		agentbuf = kstrdup(cgrp->root->release_agent_path, GFP_KERNEL);
 		if (!agentbuf)
@@ -4603,7 +4515,7 @@ static void cgroup_release_agent(struct work_struct *work)
 
 		i = 0;
 		argv[i++] = agentbuf;
-		argv[i++] = pathbuf;
+		argv[i++] = path;
 		argv[i] = NULL;
 
 		i = 0;
@@ -4753,6 +4665,11 @@ static int current_css_set_cg_links_read(struct seq_file *seq, void *v)
 {
 	struct cgrp_cset_link *link;
 	struct css_set *cset;
+	char *name_buf;
+
+	name_buf = kmalloc(NAME_MAX + 1, GFP_KERNEL);
+	if (!name_buf)
+		return -ENOMEM;
 
 	read_lock(&css_set_lock);
 	rcu_read_lock();
@@ -4761,14 +4678,17 @@ static int current_css_set_cg_links_read(struct seq_file *seq, void *v)
 		struct cgroup *c = link->cgrp;
 		const char *name = "?";
 
-		if (c != cgroup_dummy_top)
-			name = cgroup_name(c);
+		if (c != cgroup_dummy_top) {
+			cgroup_name(c, name_buf, NAME_MAX + 1);
+			name = name_buf;
+		}
 
 		seq_printf(seq, "Root %d group %s\n",
 			   c->root->hierarchy_id, name);
 	}
 	rcu_read_unlock();
 	read_unlock(&css_set_lock);
+	kfree(name_buf);
 	return 0;
 }
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 2d018c7..e97a6e8 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2088,10 +2088,9 @@ static void remove_tasks_in_empty_cpuset(struct cpuset *cs)
 		parent = parent_cs(parent);
 
 	if (cgroup_transfer_tasks(parent->css.cgroup, cs->css.cgroup)) {
-		rcu_read_lock();
-		printk(KERN_ERR "cpuset: failed to transfer tasks out of empty cpuset %s\n",
-		       cgroup_name(cs->css.cgroup));
-		rcu_read_unlock();
+		printk(KERN_ERR "cpuset: failed to transfer tasks out of empty cpuset ");
+		pr_cont_cgroup_name(cs->css.cgroup);
+		pr_cont("\n");
 	}
 }
 
@@ -2619,19 +2618,17 @@ void cpuset_print_task_mems_allowed(struct task_struct *tsk)
 	 /* Statically allocated to prevent using excess stack. */
 	static char cpuset_nodelist[CPUSET_NODELIST_LEN];
 	static DEFINE_SPINLOCK(cpuset_buffer_lock);
-
 	struct cgroup *cgrp = task_cs(tsk)->css.cgroup;
 
-	rcu_read_lock();
 	spin_lock(&cpuset_buffer_lock);
 
 	nodelist_scnprintf(cpuset_nodelist, CPUSET_NODELIST_LEN,
 			   tsk->mems_allowed);
-	printk(KERN_INFO "%s cpuset=%s mems_allowed=%s\n",
-	       tsk->comm, cgroup_name(cgrp), cpuset_nodelist);
+	printk(KERN_INFO "%s cpuset=", tsk->comm);
+	pr_cont_cgroup_name(cgrp);
+	pr_cont(" mems_allowed=%s\n", cpuset_nodelist);
 
 	spin_unlock(&cpuset_buffer_lock);
-	rcu_read_unlock();
 }
 
 /*
@@ -2681,12 +2678,12 @@ int proc_cpuset_show(struct seq_file *m, void *unused_v)
 {
 	struct pid *pid;
 	struct task_struct *tsk;
-	char *buf;
+	char *buf, *p;
 	struct cgroup_subsys_state *css;
 	int retval;
 
 	retval = -ENOMEM;
-	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	buf = kmalloc(PATH_MAX, GFP_KERNEL);
 	if (!buf)
 		goto out;
 
@@ -2696,14 +2693,16 @@ int proc_cpuset_show(struct seq_file *m, void *unused_v)
 	if (!tsk)
 		goto out_free;
 
+	retval = -ENAMETOOLONG;
 	rcu_read_lock();
 	css = task_css(tsk, cpuset_cgrp_id);
-	retval = cgroup_path(css->cgroup, buf, PAGE_SIZE);
+	p = cgroup_path(css->cgroup, buf, PATH_MAX);
 	rcu_read_unlock();
-	if (retval < 0)
+	if (!p)
 		goto out_put_task;
-	seq_puts(m, buf);
+	seq_puts(m, p);
 	seq_putc(m, '\n');
+	retval = 0;
 out_put_task:
 	put_task_struct(tsk);
 out_free:
diff --git a/kernel/sched/debug.c b/kernel/sched/debug.c
index dd52e7f..30eee3b 100644
--- a/kernel/sched/debug.c
+++ b/kernel/sched/debug.c
@@ -111,8 +111,7 @@ static char *task_group_path(struct task_group *tg)
 	if (autogroup_path(tg, group_path, PATH_MAX))
 		return group_path;
 
-	cgroup_path(tg->css.cgroup, group_path, PATH_MAX);
-	return group_path;
+	return cgroup_path(tg->css.cgroup, group_path, PATH_MAX);
 }
 #endif
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 102ab48..c1c2549 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1683,15 +1683,8 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
  */
 void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
-	/*
-	 * protects memcg_name and makes sure that parallel ooms do not
-	 * interleave
-	 */
+	/* oom_info_lock ensures that parallel ooms do not interleave */
 	static DEFINE_SPINLOCK(oom_info_lock);
-	struct cgroup *task_cgrp;
-	struct cgroup *mem_cgrp;
-	static char memcg_name[PATH_MAX];
-	int ret;
 	struct mem_cgroup *iter;
 	unsigned int i;
 
@@ -1701,36 +1694,14 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 	spin_lock(&oom_info_lock);
 	rcu_read_lock();
 
-	mem_cgrp = memcg->css.cgroup;
-	task_cgrp = task_cgroup(p, memory_cgrp_id);
+	pr_info("Task in ");
+	pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
+	pr_info(" killed as a result of limit of ");
+	pr_cont_cgroup_path(memcg->css.cgroup);
+	pr_info("\n");
 
-	ret = cgroup_path(task_cgrp, memcg_name, PATH_MAX);
-	if (ret < 0) {
-		/*
-		 * Unfortunately, we are unable to convert to a useful name
-		 * But we'll still print out the usage information
-		 */
-		rcu_read_unlock();
-		goto done;
-	}
 	rcu_read_unlock();
 
-	pr_info("Task in %s killed", memcg_name);
-
-	rcu_read_lock();
-	ret = cgroup_path(mem_cgrp, memcg_name, PATH_MAX);
-	if (ret < 0) {
-		rcu_read_unlock();
-		goto done;
-	}
-	rcu_read_unlock();
-
-	/*
-	 * Continues from above, so we don't need an KERN_ level
-	 */
-	pr_cont(" as a result of limit of %s\n", memcg_name);
-done:
-
 	pr_info("memory: usage %llukB, limit %llukB, failcnt %llu\n",
 		res_counter_read_u64(&memcg->res, RES_USAGE) >> 10,
 		res_counter_read_u64(&memcg->res, RES_LIMIT) >> 10,
@@ -1745,13 +1716,8 @@ done:
 		res_counter_read_u64(&memcg->kmem, RES_FAILCNT));
 
 	for_each_mem_cgroup_tree(iter, memcg) {
-		pr_info("Memory cgroup stats");
-
-		rcu_read_lock();
-		ret = cgroup_path(iter->css.cgroup, memcg_name, PATH_MAX);
-		if (!ret)
-			pr_cont(" for %s", memcg_name);
-		rcu_read_unlock();
+		pr_info("Memory cgroup stats for ");
+		pr_cont_cgroup_path(iter->css.cgroup);
 		pr_cont(":");
 
 		for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
@@ -3401,7 +3367,7 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 						  struct kmem_cache *s)
 {
 	struct kmem_cache *new = NULL;
-	static char *tmp_name = NULL;
+	static char *tmp_path = NULL, *tmp_name = NULL;
 	static DEFINE_MUTEX(mutex);	/* protects tmp_name */
 
 	BUG_ON(!memcg_can_account_kmem(memcg));
@@ -3413,18 +3379,20 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	 * This static temporary buffer is used to prevent from
 	 * pointless shortliving allocation.
 	 */
-	if (!tmp_name) {
-		tmp_name = kmalloc(PATH_MAX, GFP_KERNEL);
+	if (!tmp_path || !tmp_name) {
+		if (!tmp_path)
+			tmp_path = kmalloc(PATH_MAX, GFP_KERNEL);
 		if (!tmp_name)
+			tmp_name = kmalloc(NAME_MAX + 1, GFP_KERNEL);
+		if (!tmp_path || !tmp_name)
 			goto out;
 	}
 
-	rcu_read_lock();
-	snprintf(tmp_name, PATH_MAX, "%s(%d:%s)", s->name,
-			 memcg_cache_id(memcg), cgroup_name(memcg->css.cgroup));
-	rcu_read_unlock();
+	cgroup_name(memcg->css.cgroup, tmp_name, NAME_MAX + 1);
+	snprintf(tmp_path, PATH_MAX, "%s(%d:%s)", s->name,
+		 memcg_cache_id(memcg), tmp_name);
 
-	new = kmem_cache_create_memcg(memcg, tmp_name, s->object_size, s->align,
+	new = kmem_cache_create_memcg(memcg, tmp_path, s->object_size, s->align,
 				      (s->flags & ~SLAB_PANIC), s->ctor, s);
 	if (new)
 		new->allocflags |= __GFP_KMEMCG;
-- 
1.8.5.3
