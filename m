From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [PATCH v4 3/4] cgroups: subsystem module unloading
Date: Thu, 31 Dec 2009 00:14:23 -0500
Message-ID: <20091231051423.GD714__7573.17104512385$1262236518$gmane$org@andrew.cmu.edu>
References: <20091231051050.GA714@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: attachment; filename="cgroups-subsys-unloading.patch"
In-Reply-To: <20091231051050.GA714-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org
List-Id: containers.vger.kernel.org

Provides support for unloading modular subsystems.

From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

This patch adds a new function cgroup_unload_subsys which is to be used for
removing a loaded subsystem during module deletion. Reference counting of the
subsystems' modules is moved from once (at load time) to once per attached
hierarchy (in parse_cgroupfs_options and rebind_subsystems) (i.e., 0 or 1).

Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Acked-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---

 Documentation/cgroups/cgroups.txt |    5 +
 include/linux/cgroup.h            |    4 +
 kernel/cgroup.c                   |  164 +++++++++++++++++++++++++++++++------
 3 files changed, 145 insertions(+), 28 deletions(-)


diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 6ffcf81..7527bac 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -489,8 +489,9 @@ Each subsystem should:
 - define a cgroup_subsys object called <name>_subsys
 
 If a subsystem can be compiled as a module, it should also have in its
-module initcall a call to cgroup_load_subsys(&its_subsys_struct). It
-should also set its_subsys.module = THIS_MODULE in its .c file.
+module initcall a call to cgroup_load_subsys(), and in its exitcall a
+call to cgroup_unload_subsys(). It should also set its_subsys.module =
+THIS_MODULE in its .c file.
 
 Each subsystem may export the following methods. The only mandatory
 methods are create/destroy. Any others that are null are presumed to
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 9461aed..9be4c22 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -37,6 +37,7 @@ extern void cgroup_exit(struct task_struct *p, int run_callbacks);
 extern int cgroupstats_build(struct cgroupstats *stats,
 				struct dentry *dentry);
 extern int cgroup_load_subsys(struct cgroup_subsys *ss);
+extern void cgroup_unload_subsys(struct cgroup_subsys *ss);
 
 extern const struct file_operations proc_cgroup_operations;
 
@@ -264,7 +265,8 @@ struct css_set {
 	/*
 	 * Set of subsystem states, one for each subsystem. This array
 	 * is immutable after creation apart from the init_css_set
-	 * during subsystem registration (at boot time).
+	 * during subsystem registration (at boot time) and modular subsystem
+	 * loading/unloading.
 	 */
 	struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT];
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index d7ca4cf..cc2e1f6 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -878,7 +878,9 @@ void cgroup_release_and_wakeup_rmdir(struct cgroup_subsys_state *css)
 }
 
 /*
- * Call with cgroup_mutex held.
+ * Call with cgroup_mutex held. Drops reference counts on modules, including
+ * any duplicate ones that parse_cgroupfs_options took. If this function
+ * returns an error, no reference counts are touched.
  */
 static int rebind_subsystems(struct cgroupfs_root *root,
 			      unsigned long final_bits)
@@ -934,6 +936,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			if (ss->bind)
 				ss->bind(ss, cgrp);
 			mutex_unlock(&ss->hierarchy_mutex);
+			/* refcount was already taken, and we're keeping it */
 		} else if (bit & removed_bits) {
 			/* We're removing this subsystem */
 			BUG_ON(ss == NULL);
@@ -947,10 +950,18 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			subsys[i]->root = &rootnode;
 			list_move(&ss->sibling, &rootnode.subsys_list);
 			mutex_unlock(&ss->hierarchy_mutex);
+			/* subsystem is now free - drop reference on module */
+			module_put(ss->module);
 		} else if (bit & final_bits) {
 			/* Subsystem state should already exist */
 			BUG_ON(ss == NULL);
 			BUG_ON(!cgrp->subsys[i]);
+			/*
+			 * a refcount was taken, but we already had one, so
+			 * drop the extra reference.
+			 */
+			module_put(ss->module);
+			BUG_ON(ss->module && !module_refcount(ss->module));
 		} else {
 			/* Subsystem state shouldn't exist */
 			BUG_ON(cgrp->subsys[i]);
@@ -994,13 +1005,16 @@ struct cgroup_sb_opts {
 
 /*
  * Convert a hierarchy specifier into a bitmask of subsystems and flags. Call
- * with cgroup_mutex held to protect the subsys[] array.
+ * with cgroup_mutex held to protect the subsys[] array. This function takes
+ * refcounts on subsystems to be used, unless it returns error, in which case
+ * no refcounts are taken.
  */
-static int parse_cgroupfs_options(char *data,
-				     struct cgroup_sb_opts *opts)
+static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 {
 	char *token, *o = data ?: "all";
 	unsigned long mask = (unsigned long)-1;
+	int i;
+	bool module_pin_failed = false;
 
 	BUG_ON(!mutex_is_locked(&cgroup_mutex));
 
@@ -1015,7 +1029,6 @@ static int parse_cgroupfs_options(char *data,
 			return -EINVAL;
 		if (!strcmp(token, "all")) {
 			/* Add all non-disabled subsystems */
-			int i;
 			opts->subsys_bits = 0;
 			for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 				struct cgroup_subsys *ss = subsys[i];
@@ -1038,7 +1051,6 @@ static int parse_cgroupfs_options(char *data,
 			if (!opts->release_agent)
 				return -ENOMEM;
 		} else if (!strncmp(token, "name=", 5)) {
-			int i;
 			const char *name = token + 5;
 			/* Can't specify an empty name */
 			if (!strlen(name))
@@ -1062,7 +1074,6 @@ static int parse_cgroupfs_options(char *data,
 				return -ENOMEM;
 		} else {
 			struct cgroup_subsys *ss;
-			int i;
 			for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 				ss = subsys[i];
 				if (ss == NULL)
@@ -1101,9 +1112,54 @@ static int parse_cgroupfs_options(char *data,
 	if (!opts->subsys_bits && !opts->name)
 		return -EINVAL;
 
+	/*
+	 * Grab references on all the modules we'll need, so the subsystems
+	 * don't dance around before rebind_subsystems attaches them. This may
+	 * take duplicate reference counts on a subsystem that's already used,
+	 * but rebind_subsystems handles this case.
+	 */
+	for (i = CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++) {
+		unsigned long bit = 1UL << i;
+
+		if (!(bit & opts->subsys_bits))
+			continue;
+		if (!try_module_get(subsys[i]->module)) {
+			module_pin_failed = true;
+			break;
+		}
+	}
+	if (module_pin_failed) {
+		/*
+		 * oops, one of the modules was going away. this means that we
+		 * raced with a module_delete call, and to the user this is
+		 * essentially a "subsystem doesn't exist" case.
+		 */
+		for (i--; i >= CGROUP_BUILTIN_SUBSYS_COUNT; i--) {
+			/* drop refcounts only on the ones we took */
+			unsigned long bit = 1UL << i;
+
+			if (!(bit & opts->subsys_bits))
+				continue;
+			module_put(subsys[i]->module);
+		}
+		return -ENOENT;
+	}
+
 	return 0;
 }
 
+static void drop_parsed_module_refcounts(unsigned long subsys_bits)
+{
+	int i;
+	for (i = CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++) {
+		unsigned long bit = 1UL << i;
+
+		if (!(bit & subsys_bits))
+			continue;
+		module_put(subsys[i]->module);
+	}
+}
+
 static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 {
 	int ret = 0;
@@ -1120,21 +1176,19 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	if (ret)
 		goto out_unlock;
 
-	/* Don't allow flags to change at remount */
-	if (opts.flags != root->flags) {
-		ret = -EINVAL;
-		goto out_unlock;
-	}
-
-	/* Don't allow name to change at remount */
-	if (opts.name && strcmp(opts.name, root->name)) {
+	/* Don't allow flags or name to change at remount */
+	if (opts.flags != root->flags ||
+	    (opts.name && strcmp(opts.name, root->name))) {
 		ret = -EINVAL;
+		drop_parsed_module_refcounts(opts.subsys_bits);
 		goto out_unlock;
 	}
 
 	ret = rebind_subsystems(root, opts.subsys_bits);
-	if (ret)
+	if (ret) {
+		drop_parsed_module_refcounts(opts.subsys_bits);
 		goto out_unlock;
+	}
 
 	/* (re)populate subsystem files */
 	cgroup_populate_dir(cgrp);
@@ -1333,7 +1387,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 	new_root = cgroup_root_from_opts(&opts);
 	if (IS_ERR(new_root)) {
 		ret = PTR_ERR(new_root);
-		goto out_err;
+		goto drop_modules;
 	}
 	opts.new_root = new_root;
 
@@ -1342,7 +1396,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 	if (IS_ERR(sb)) {
 		ret = PTR_ERR(sb);
 		cgroup_drop_root(opts.new_root);
-		goto out_err;
+		goto drop_modules;
 	}
 
 	root = sb->s_fs_info;
@@ -1398,6 +1452,11 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 			free_cg_links(&tmp_cg_links);
 			goto drop_new_super;
 		}
+		/*
+		 * There must be no failure case after here, since rebinding
+		 * takes care of subsystems' refcounts, which are explicitly
+		 * dropped in the failure exit path.
+		 */
 
 		/* EBUSY should be the only error here */
 		BUG_ON(ret);
@@ -1436,6 +1495,8 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 		 * any) is not needed
 		 */
 		cgroup_drop_root(opts.new_root);
+		/* no subsys rebinding, so refcounts don't change */
+		drop_parsed_module_refcounts(opts.subsys_bits);
 	}
 
 	simple_set_mnt(mnt, sb);
@@ -1445,6 +1506,8 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 
  drop_new_super:
 	deactivate_locked_super(sb);
+ drop_modules:
+	drop_parsed_module_refcounts(opts.subsys_bits);
  out_err:
 	kfree(opts.release_agent);
 	kfree(opts.name);
@@ -3366,13 +3429,6 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	lockdep_set_class(&ss->hierarchy_mutex, &ss->subsys_key);
 	ss->active = 1;
 
-	/*
-	 * pin the subsystem's module so it doesn't go away. this shouldn't
-	 * fail, since the module's initcall calls us.
-	 * TODO: with module unloading, move this elsewhere
-	 */
-	BUG_ON(!try_module_get(ss->module));
-
 	/* success! */
 	mutex_unlock(&cgroup_mutex);
 	return 0;
@@ -3380,6 +3436,64 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 EXPORT_SYMBOL_GPL(cgroup_load_subsys);
 
 /**
+ * cgroup_unload_subsys: unload a modular subsystem
+ * @ss: the subsystem to unload
+ *
+ * This function should be called in a modular subsystem's exitcall. When this
+ * function is invoked, the refcount on the subsystem's module will be 0, so
+ * the subsystem will not be attached to any hierarchy.
+ */
+void cgroup_unload_subsys(struct cgroup_subsys *ss)
+{
+	struct cg_cgroup_link *link;
+	struct hlist_head *hhead;
+
+	BUG_ON(ss->module == NULL);
+
+	/*
+	 * we shouldn't be called if the subsystem is in use, and the use of
+	 * try_module_get in parse_cgroupfs_options should ensure that it
+	 * doesn't start being used while we're killing it off.
+	 */
+	BUG_ON(ss->root != &rootnode);
+
+	mutex_lock(&cgroup_mutex);
+	/* deassign the subsys_id */
+	BUG_ON(ss->subsys_id < CGROUP_BUILTIN_SUBSYS_COUNT);
+	subsys[ss->subsys_id] = NULL;
+
+	/* remove subsystem from rootnode's list of subsystems */
+	list_del(&ss->sibling);
+
+	/*
+	 * disentangle the css from all css_sets attached to the dummytop. as
+	 * in loading, we need to pay our respects to the hashtable gods.
+	 */
+	write_lock(&css_set_lock);
+	list_for_each_entry(link, &dummytop->css_sets, cgrp_link_list) {
+		struct css_set *cg = link->cg;
+
+		hlist_del(&cg->hlist);
+		BUG_ON(!cg->subsys[ss->subsys_id]);
+		cg->subsys[ss->subsys_id] = NULL;
+		hhead = css_set_hash(cg->subsys);
+		hlist_add_head(&cg->hlist, hhead);
+	}
+	write_unlock(&css_set_lock);
+
+	/*
+	 * remove subsystem's css from the dummytop and free it - need to free
+	 * before marking as null because ss->destroy needs the cgrp->subsys
+	 * pointer to find their state.
+	 */
+	ss->destroy(ss, dummytop);
+	dummytop->subsys[ss->subsys_id] = NULL;
+
+	mutex_unlock(&cgroup_mutex);
+}
+EXPORT_SYMBOL_GPL(cgroup_unload_subsys);
+
+/**
  * cgroup_init_early - cgroup initialization at system boot
  *
  * Initialize cgroups at system boot, and initialize any
