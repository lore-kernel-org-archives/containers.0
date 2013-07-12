From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 cgroup 1/2] cgroup: move module ref handling into
	rebind_subsystems()
Date: Fri, 12 Jul 2013 13:38:17 -0700
Message-ID: <20130712203817.GI23680@mtj.dyndns.org>
References: <20130629041231.GA31353@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130629041231.GA31353-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Module ref handling in cgroup is rather weird.
parse_cgroupfs_options() grabs all the modules for the specified
subsystems.  A module ref is kept if the specified subsystem is newly
bound to the hierarchy.  If not, or the operation fails, the refs are
dropped.  This scatters module ref handling across multiple functions
making it difficult to track.  It also make the function nasty to use
for dynamic subsystem binding which is necessary for the planned
unified hierarchy.

There's nothing which requires the subsystem modules to be pinned
between parse_cgroupfs_options() and rebind_subsystems() in both mount
and remount paths.  parse_cgroupfs_options() can just parse and
rebind_subsystems() can handle pinning the subsystems that it wants to
bind, which is a natural part of its task - binding - anyway.

Move module ref handling into rebind_subsystems() which makes the code
a lot simpler - modules are gotten iff it's gonna be bound and put iff
unbound or binding fails.

v2: Li pointed out that if a controller module is unloaded between
    parsing and binding, rebind_subsystems() won't notice the missing
    controller as it only iterates through existing controllers.  Fix
    it by updating rebind_subsystems() to compare @added_mask to
    @pinned and fail with -ENOENT if they don't match.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
Turns out rebind_subsystems() already has @pinned so detecting cases
where the module went missing is trivial.

Thanks.

 kernel/cgroup.c |   93 ++++++++++++++++----------------------------------------
 1 file changed, 28 insertions(+), 65 deletions(-)

--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1003,6 +1003,7 @@ static int rebind_subsystems(struct cgro
 {
 	struct cgroup *cgrp = &root->top_cgroup;
 	struct cgroup_subsys *ss;
+	unsigned long pinned = 0;
 	int i, ret;
 
 	BUG_ON(!mutex_is_locked(&cgroup_mutex));
@@ -1010,20 +1011,32 @@ static int rebind_subsystems(struct cgro
 
 	/* Check that any added subsystems are currently free */
 	for_each_subsys(ss, i) {
-		unsigned long bit = 1UL << i;
-
-		if (!(bit & added_mask))
+		if (!(added_mask & (1 << i)))
 			continue;
 
+		/* is the subsystem mounted elsewhere? */
 		if (ss->root != &cgroup_dummy_root) {
-			/* Subsystem isn't free */
-			return -EBUSY;
+			ret = -EBUSY;
+			goto out_put;
+		}
+
+		/* pin the module */
+		if (!try_module_get(ss->module)) {
+			ret = -ENOENT;
+			goto out_put;
 		}
+		pinned |= 1 << i;
+	}
+
+	/* subsys could be missing if unloaded between parsing and here */
+	if (added_mask != pinned) {
+		ret = -ENOENT;
+		goto out_put;
 	}
 
 	ret = cgroup_populate_dir(cgrp, added_mask);
 	if (ret)
-		return ret;
+		goto out_put;
 
 	/*
 	 * Nothing can fail from this point on.  Remove files for the
@@ -1067,11 +1080,6 @@ static int rebind_subsystems(struct cgro
 		} else if (bit & root->subsys_mask) {
 			/* Subsystem state should already exist */
 			BUG_ON(!cgrp->subsys[i]);
-			/*
-			 * a refcount was taken, but we already had one, so
-			 * drop the extra reference.
-			 */
-			module_put(ss->module);
 #ifdef CONFIG_MODULE_UNLOAD
 			BUG_ON(ss->module && !module_refcount(ss->module));
 #endif
@@ -1088,6 +1096,12 @@ static int rebind_subsystems(struct cgro
 	root->flags |= CGRP_ROOT_SUBSYS_BOUND;
 
 	return 0;
+
+out_put:
+	for_each_subsys(ss, i)
+		if (pinned & (1 << i))
+			module_put(ss->module);
+	return ret;
 }
 
 static int cgroup_show_options(struct seq_file *seq, struct dentry *dentry)
@@ -1138,7 +1152,6 @@ static int parse_cgroupfs_options(char *
 	char *token, *o = data;
 	bool all_ss = false, one_ss = false;
 	unsigned long mask = (unsigned long)-1;
-	bool module_pin_failed = false;
 	struct cgroup_subsys *ss;
 	int i;
 
@@ -1281,52 +1294,9 @@ static int parse_cgroupfs_options(char *
 	if (!opts->subsys_mask && !opts->name)
 		return -EINVAL;
 
-	/*
-	 * Grab references on all the modules we'll need, so the subsystems
-	 * don't dance around before rebind_subsystems attaches them. This may
-	 * take duplicate reference counts on a subsystem that's already used,
-	 * but rebind_subsystems handles this case.
-	 */
-	for_each_subsys(ss, i) {
-		if (!(opts->subsys_mask & (1UL << i)))
-			continue;
-		if (!try_module_get(cgroup_subsys[i]->module)) {
-			module_pin_failed = true;
-			break;
-		}
-	}
-	if (module_pin_failed) {
-		/*
-		 * oops, one of the modules was going away. this means that we
-		 * raced with a module_delete call, and to the user this is
-		 * essentially a "subsystem doesn't exist" case.
-		 */
-		for (i--; i >= 0; i--) {
-			/* drop refcounts only on the ones we took */
-			unsigned long bit = 1UL << i;
-
-			if (!(bit & opts->subsys_mask))
-				continue;
-			module_put(cgroup_subsys[i]->module);
-		}
-		return -ENOENT;
-	}
-
 	return 0;
 }
 
-static void drop_parsed_module_refcounts(unsigned long subsys_mask)
-{
-	struct cgroup_subsys *ss;
-	int i;
-
-	mutex_lock(&cgroup_mutex);
-	for_each_subsys(ss, i)
-		if (subsys_mask & (1UL << i))
-			module_put(cgroup_subsys[i]->module);
-	mutex_unlock(&cgroup_mutex);
-}
-
 static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 {
 	int ret = 0;
@@ -1384,8 +1354,6 @@ static int cgroup_remount(struct super_b
 	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
-	if (ret)
-		drop_parsed_module_refcounts(opts.subsys_mask);
 	return ret;
 }
 
@@ -1591,7 +1559,7 @@ static struct dentry *cgroup_mount(struc
 	new_root = cgroup_root_from_opts(&opts);
 	if (IS_ERR(new_root)) {
 		ret = PTR_ERR(new_root);
-		goto drop_modules;
+		goto out_err;
 	}
 	opts.new_root = new_root;
 
@@ -1600,7 +1568,7 @@ static struct dentry *cgroup_mount(struc
 	if (IS_ERR(sb)) {
 		ret = PTR_ERR(sb);
 		cgroup_free_root(opts.new_root);
-		goto drop_modules;
+		goto out_err;
 	}
 
 	root = sb->s_fs_info;
@@ -1708,9 +1676,6 @@ static struct dentry *cgroup_mount(struc
 				pr_warning("cgroup: new mount options do not match the existing superblock, will be ignored\n");
 			}
 		}
-
-		/* no subsys rebinding, so refcounts don't change */
-		drop_parsed_module_refcounts(opts.subsys_mask);
 	}
 
 	kfree(opts.release_agent);
@@ -1728,8 +1693,6 @@ static struct dentry *cgroup_mount(struc
 	mutex_unlock(&inode->i_mutex);
  drop_new_super:
 	deactivate_locked_super(sb);
- drop_modules:
-	drop_parsed_module_refcounts(opts.subsys_mask);
  out_err:
 	kfree(opts.release_agent);
 	kfree(opts.name);
@@ -4837,7 +4800,7 @@ void cgroup_unload_subsys(struct cgroup_
 
 	/*
 	 * we shouldn't be called if the subsystem is in use, and the use of
-	 * try_module_get in parse_cgroupfs_options should ensure that it
+	 * try_module_get() in rebind_subsystems() should ensure that it
 	 * doesn't start being used while we're killing it off.
 	 */
 	BUG_ON(ss->root != &cgroup_dummy_root);
