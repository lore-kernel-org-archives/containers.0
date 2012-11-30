From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 2/2] cgroup: remove subsystem files when remounting cgroup
Date: Sat, 1 Dec 2012 00:21:29 +0800
Message-ID: <1354292489-18434-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1354292489-18434-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1354292489-18434-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_clear_directroy is called by cgroup_d_remove_dir
and cgroup_remount.

when we call cgroup_remount to remount the cgroup,the subsystem
may be unlinked from cgroupfs_root->subsys_list in rebind_subsystem,this
subsystem's files will not be removed in cgroup_clear_directroy.
And the system will panic when we try to access these files.

this patch fix it.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   86 ++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 54 insertions(+), 32 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e5233b7..90429d5 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -982,10 +982,14 @@ static void cgroup_clear_directory(struct dentry *dir, bool base_files,
 				   unsigned long subsys_mask)
 {
 	struct cgroup *cgrp = __d_cgrp(dir);
-	struct cgroup_subsys *ss;
+	int i;
 
-	for_each_subsys(cgrp->root, ss) {
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cftype_set *set;
+		struct cgroup_subsys *ss = subsys[i];
+
+		if (ss == NULL)
+			continue;
 		if (!test_bit(ss->subsys_id, &subsys_mask))
 			continue;
 		list_for_each_entry(set, &ss->cftsets, node)
@@ -1160,6 +1164,40 @@ static int cgroup_show_options(struct seq_file *seq, struct dentry *dentry)
 	return 0;
 }
 
+static int cgroup_get_module_refcounts(unsigned long subsys_mask)
+{
+	int i;
+	bool module_pin_failed = false;
+
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+		unsigned long bit = 1UL << i;
+
+		if (!(bit & subsys_mask))
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
+		for (i--; i >= 0; i--) {
+			/* drop refcounts only on the ones we took */
+			unsigned long bit = 1UL << i;
+
+			if (!(bit & subsys_mask))
+				continue;
+			module_put(subsys[i]->module);
+		}
+		return -ENOENT;
+	}
+	return 0;
+}
+
 struct cgroup_sb_opts {
 	unsigned long subsys_mask;
 	unsigned long flags;
@@ -1185,7 +1223,6 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 	bool all_ss = false, one_ss = false;
 	unsigned long mask = (unsigned long)-1;
 	int i;
-	bool module_pin_failed = false;
 
 	BUG_ON(!mutex_is_locked(&cgroup_mutex));
 
@@ -1324,34 +1361,8 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 	 * take duplicate reference counts on a subsystem that's already used,
 	 * but rebind_subsystems handles this case.
 	 */
-	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		unsigned long bit = 1UL << i;
 
-		if (!(bit & opts->subsys_mask))
-			continue;
-		if (!try_module_get(subsys[i]->module)) {
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
-			module_put(subsys[i]->module);
-		}
-		return -ENOENT;
-	}
-
-	return 0;
+	return cgroup_get_module_refcounts(opts->subsys_mask);
 }
 
 static void drop_parsed_module_refcounts(unsigned long subsys_mask)
@@ -1392,23 +1403,34 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	removed_mask = root->subsys_mask & ~opts.subsys_mask;
 
 	/* Don't allow flags or name to change at remount */
+	ret = -EINVAL;
 	if (opts.flags != root->flags ||
 	    (opts.name && strcmp(opts.name, root->name))) {
-		ret = -EINVAL;
 		drop_parsed_module_refcounts(opts.subsys_mask);
 		goto out_unlock;
 	}
 
-	ret = rebind_subsystems(root, opts.subsys_mask);
+	/*
+	 * Add the reference of these removed subsystem,we
+	 * need use subsystems to remove their cgroup files.
+	 */
+	ret = cgroup_get_module_refcounts(removed_mask);
 	if (ret) {
 		drop_parsed_module_refcounts(opts.subsys_mask);
 		goto out_unlock;
 	}
 
+	ret = rebind_subsystems(root, opts.subsys_mask);
+	if (ret) {
+		drop_parsed_module_refcounts(opts.subsys_mask | removed_mask);
+		goto out_unlock;
+	}
+
 	/* clear out any existing files and repopulate subsystem files */
 	cgroup_clear_directory(cgrp->dentry, false, removed_mask);
 	/* re-populate subsystem files */
 	cgroup_populate_dir(cgrp, false, added_mask);
+	drop_parsed_module_refcounts(removed_mask);
 
 	if (opts.release_agent)
 		strcpy(root->release_agent_path, opts.release_agent);
-- 
1.7.7.6
