From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 03/10] cgroup: implement cgroup_add_cftypes() and friends
Date: Fri, 16 Mar 2012 16:35:56 -0700
Message-ID: <1331940963-15756-4-git-send-email-tj@kernel.org>
References: <1331940963-15756-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1331940963-15756-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, cgroup directories are populated by subsys->populate()
callback explicitly creating files on each cgroup creation.  This
level of flexibility isn't needed or desirable.  It provides largely
unused flexibility which call for abuses while severely limiting what
the core layer can do through the lack of structure and conventions.

Per each cgroup file type, the only distinction that cgroup users is
making is whether a cgroup is root or not, which can easily be
expressed with flags.

This patch introduces cgroup_add_cftypes() and its wrapper macros -
CGROUP_SUBSYS_CFTYPES[_COND]().  These deal with cftypes instead of
individual files - controllers indicate that certain types of files
exist for certain subsystem.  Newly added CFTYPE_*_ON_ROOT flags
indicate whether a cftype should be excluded or created only on the
root cgroup.

cgroup_add_cftypes() can be called any time whether the target
subsystem is currently attached or not.  cgroup core will create files
on the existing cgroups as necessary.  CGROUP_SUBSYS_CFTYPES[_COND]()
are convenience macros controllers so that cftypes can be declared to
belong to certain cgroup.  The COND variant is useful for cases where
certain files are dependent on boot time parameter.

Further patches will convert the existing users and remove the file
based interface.  Note that this interface allows dynamic addition of
files to an active controller.  This will be used for sub-controller
modularity and unified hierarchy in the longer term.

This patch implements the new mechanism but doesn't apply it to any
user.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |   38 +++++++++++++-
 kernel/cgroup.c        |  128 +++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 163 insertions(+), 3 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 908f26f..a78a6a8 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -192,6 +192,7 @@ struct cgroup {
 	struct list_head css_sets;
 
 	struct list_head allcg_node;	/* cgroupfs_root->allcg_list */
+	struct list_head cft_q_node;	/* used during cftype add/rm */
 
 	/*
 	 * Linked list running through all cgroups that can
@@ -277,11 +278,17 @@ struct cgroup_map_cb {
  *	- the 'cftype' of the file is file->f_dentry->d_fsdata
  */
 
-#define MAX_CFTYPE_NAME 64
+/* cftype->flags */
+#define CFTYPE_ONLY_ON_ROOT	(1U << 0)	/* only create on root cg */
+#define CFTYPE_NOT_ON_ROOT	(1U << 1)	/* don't create onp root cg */
+
+#define MAX_CFTYPE_NAME		64
+
 struct cftype {
 	/*
 	 * By convention, the name should begin with the name of the
-	 * subsystem, followed by a period
+	 * subsystem, followed by a period.  Zero length string indicates
+	 * end of cftype array.
 	 */
 	char name[MAX_CFTYPE_NAME];
 	int private;
@@ -297,6 +304,9 @@ struct cftype {
 	 */
 	size_t max_write_len;
 
+	/* CFTYPE_* flags */
+	unsigned int flags;
+
 	int (*open)(struct inode *inode, struct file *file);
 	ssize_t (*read)(struct cgroup *cgrp, struct cftype *cft,
 			struct file *file,
@@ -375,6 +385,25 @@ struct cftype {
 			struct eventfd_ctx *eventfd);
 };
 
+/*
+ * Declare cftype array @cfts for cgroup subsys @ss if @cond is %true.
+ * Useful if the files are dependent on boot time parameter.
+ */
+#define CGROUP_SUBSYS_CFTYPES_COND(ss, cfts, cond)			\
+	static int __init __cgroup_cfts_init_##ss_##cfts(void)		\
+	{								\
+		if ((cond))						\
+			WARN_ON(cgroup_add_cftypes(&ss, cfts));		\
+		return 0;						\
+	}								\
+	fs_initcall(__cgroup_cfts_init_##ss_##cfts);
+
+/*
+ * Declare cftype array @cfts for cgroup subsys @ss.
+ */
+#define CGROUP_SUBSYS_CFTYPES(ss, cfts)					\
+	CGROUP_SUBSYS_CFTYPES_COND(ss, cfts, true)
+
 struct cgroup_scanner {
 	struct cgroup *cg;
 	int (*test_task)(struct task_struct *p, struct cgroup_scanner *scan);
@@ -400,6 +429,8 @@ int cgroup_add_files(struct cgroup *cgrp,
 			const struct cftype cft[],
 			int count);
 
+int cgroup_add_cftypes(struct cgroup_subsys *ss, const struct cftype *cfts);
+
 int cgroup_is_removed(const struct cgroup *cgrp);
 
 int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen);
@@ -467,6 +498,9 @@ struct cgroup_subsys {
 	void (*post_clone)(struct cgroup *cgrp);
 	void (*bind)(struct cgroup *root);
 
+	/* list of cftype_sets */
+	struct list_head cftsets;
+
 	int subsys_id;
 	int active;
 	int disabled;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index fceee52..2b1a209 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -148,6 +148,16 @@ struct cgroupfs_root {
 static struct cgroupfs_root rootnode;
 
 /*
+ * cftype_sets describe cftypes belonging to a subsystem and are chained at
+ * cgroup_subsys->cftsets.  Each cftset points to an array of cftypes
+ * terminated by zero length name.
+ */
+struct cftype_set {
+	struct list_head		node;	/* chained at subsys->cftsets */
+	const struct cftype		*cfts;
+};
+
+/*
  * CSS ID -- ID per subsys's Cgroup Subsys State(CSS). used only when
  * cgroup_subsys->use_id != 0.
  */
@@ -2627,8 +2637,14 @@ int cgroup_add_file(struct cgroup *cgrp,
 	struct dentry *dentry;
 	int error;
 	umode_t mode;
-
 	char name[MAX_CGROUP_TYPE_NAMELEN + MAX_CFTYPE_NAME + 2] = { 0 };
+
+	/* does @cft->flags tell us to skip creation on @cgrp? */
+	if ((cft->flags & CFTYPE_NOT_ON_ROOT) && !cgrp->parent)
+		return 0;
+	if ((cft->flags & CFTYPE_ONLY_ON_ROOT) && cgrp->parent)
+		return 0;
+
 	if (subsys && !test_bit(ROOT_NOPREFIX, &cgrp->root->flags)) {
 		strcpy(name, subsys->name);
 		strcat(name, ".");
@@ -2664,6 +2680,97 @@ int cgroup_add_files(struct cgroup *cgrp,
 }
 EXPORT_SYMBOL_GPL(cgroup_add_files);
 
+static DEFINE_MUTEX(cgroup_cft_mutex);
+
+static void cgroup_cfts_prepare(void)
+	__acquires(&cgroup_cft_mutex) __acquires(&cgroup_mutex)
+{
+	/*
+	 * Thanks to the entanglement with vfs inode locking, we can't walk
+	 * the existing cgroups under cgroup_mutex and create files.
+	 * Instead, we increment reference on all cgroups and build list of
+	 * them using @cgrp->cft_q_node.  Grab cgroup_cft_mutex to ensure
+	 * exclusive access to the field.
+	 */
+	mutex_lock(&cgroup_cft_mutex);
+	mutex_lock(&cgroup_mutex);
+}
+
+static void cgroup_cfts_commit(struct cgroup_subsys *ss,
+			       const struct cftype *cfts)
+	__releases(&cgroup_mutex) __releases(&cgroup_cft_mutex)
+{
+	LIST_HEAD(pending);
+	struct cgroup *cgrp, *n;
+	int count = 0;
+
+	while (cfts[count].name[0] != '\0')
+		count++;
+
+	/* %NULL @cfts indicates abort and don't bother if @ss isn't attached */
+	if (cfts && ss->root != &rootnode) {
+		list_for_each_entry(cgrp, &ss->root->allcg_list, allcg_node) {
+			dget(cgrp->dentry);
+			list_add_tail(&cgrp->cft_q_node, &pending);
+		}
+	}
+
+	mutex_unlock(&cgroup_mutex);
+
+	/*
+	 * All new cgroups will see @cfts update on @ss->cftsets.  Add/rm
+	 * files for all cgroups which were created before.
+	 */
+	list_for_each_entry_safe(cgrp, n, &pending, cft_q_node) {
+		struct inode *inode = cgrp->dentry->d_inode;
+
+		mutex_lock(&inode->i_mutex);
+		mutex_lock(&cgroup_mutex);
+		if (!cgroup_is_removed(cgrp))
+			cgroup_add_files(cgrp, ss, cfts, count);
+		mutex_unlock(&cgroup_mutex);
+		mutex_unlock(&inode->i_mutex);
+
+		list_del_init(&cgrp->cft_q_node);
+		dput(cgrp->dentry);
+	}
+
+	mutex_unlock(&cgroup_cft_mutex);
+}
+
+/**
+ * cgroup_add_cftypes - add an array of cftypes to a subsystem
+ * @ss: target cgroup subsystem
+ * @cfts: zero-length name terminated array of cftypes
+ *
+ * Register @cfts to @ss.  Files described by @cfts are created for all
+ * existing cgroups to which @ss is attached and all future cgroups will
+ * have them too.  This function can be called anytime after
+ * subsys_initcall whether @ss is attached or not.
+ *
+ * Returns 0 on successful registration, -errno on failure.  Note that this
+ * function currently returns 0 as long as @cfts registration is successful
+ * even if some file creation attempts on existing cgroups fail.
+ */
+int cgroup_add_cftypes(struct cgroup_subsys *ss, const struct cftype *cfts)
+{
+	struct cftype_set *set;
+
+	set = kzalloc(sizeof(*set), GFP_KERNEL);
+	if (!set)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&set->node);
+	set->cfts = cfts;
+
+	cgroup_cfts_prepare();
+	list_add_tail(&set->node, &ss->cftsets);
+	cgroup_cfts_commit(ss, cfts);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(cgroup_add_cftypes);
+
 /**
  * cgroup_task_count - count the number of tasks in a cgroup.
  * @cgrp: the cgroup in question
@@ -3664,10 +3771,25 @@ static int cgroup_populate_dir(struct cgroup *cgrp)
 			return err;
 	}
 
+	/* process cftsets of each subsystem */
 	for_each_subsys(cgrp->root, ss) {
+		struct cftype_set *set;
+
 		if (ss->populate && (err = ss->populate(ss, cgrp)) < 0)
 			return err;
+
+		list_for_each_entry(set, &ss->cftsets, node) {
+			const struct cftype *cft;
+
+			for (cft = set->cfts; cft->name[0] != '\0'; cft++) {
+				err = cgroup_add_file(cgrp, ss, cft);
+				if (err)
+					pr_warning("cgroup_populate_dir: failed to create %s, err=%d\n",
+						   cft->name, err);
+			}
+		}
 	}
+
 	/* This cgroup is ready now */
 	for_each_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
@@ -4044,6 +4166,8 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 
 	printk(KERN_INFO "Initializing cgroup subsys %s\n", ss->name);
 
+	INIT_LIST_HEAD(&ss->cftsets);
+
 	/* Create the top cgroup state for this subsystem */
 	list_add(&ss->sibling, &rootnode.subsys_list);
 	ss->root = &rootnode;
@@ -4113,6 +4237,8 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 		return 0;
 	}
 
+	INIT_LIST_HEAD(&ss->cftsets);
+
 	/*
 	 * need to register a subsys id before anything else - for example,
 	 * init_cgroup_css needs it.
-- 
1.7.7.3
