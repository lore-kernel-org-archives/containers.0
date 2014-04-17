From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] cgroup: Use more current logging style
Date: Thu, 17 Apr 2014 11:05:55 -0700
Message-ID: <1397757955.3104.11.camel__38295.8634560511$1397758433$gmane$org@joe-AO725>
References: <1397748555-6647-1-git-send-email-nasa4836@gmail.com>
	<20140417153800.GO15326@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140417153800.GO15326-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Use pr_fmt and remove embedded prefixes.
Realign modified multi-line statements to open parenthesis.
Convert embedded function name to "%s: ", __func__

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---

On Thu, 2014-04-17 at 11:38 -0400, Tejun Heo wrote:
> Rolled 1-3 to the pending patchset.
 
Perhaps something like this on top of the modified patches
after being applied to -next.

There was 1 trivial patch conflict on the Jianyu's patch 3/3

 kernel/cgroup.c | 32 +++++++++++++++++---------------
 1 file changed, 17 insertions(+), 15 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 21a656e..5e6f193 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -26,6 +26,8 @@
  *  distribution for more details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/cgroup.h>
 #include <linux/cred.h>
 #include <linux/ctype.h>
@@ -1017,9 +1019,9 @@ static int rebind_subsystems(struct cgroup_root *dst_root,
 		 * Just warn about it and continue.
 		 */
 		if (cgrp_dfl_root_visible) {
-			pr_warn("cgroup: failed to create files (%d) while rebinding 0x%lx to default root\n",
-				   ret, ss_mask);
-			pr_warn("cgroup: you may retry by moving them to a different hierarchy and unbinding\n");
+			pr_warn("failed to create files (%d) while rebinding 0x%lx to default root\n",
+				ret, ss_mask);
+			pr_warn("you may retry by moving them to a different hierarchy and unbinding\n");
 		}
 	}
 
@@ -1210,12 +1212,12 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 	/* Consistency checks */
 
 	if (opts->flags & CGRP_ROOT_SANE_BEHAVIOR) {
-		pr_warn("cgroup: sane_behavior: this is still under development and its behaviors will change, proceed at your own risk\n");
+		pr_warn("sane_behavior: this is still under development and its behaviors will change, proceed at your own risk\n");
 
 		if ((opts->flags & (CGRP_ROOT_NOPREFIX | CGRP_ROOT_XATTR)) ||
 		    opts->cpuset_clone_children || opts->release_agent ||
 		    opts->name) {
-			pr_err("cgroup: sane_behavior: noprefix, xattr, clone_children, release_agent and name are not allowed\n");
+			pr_err("sane_behavior: noprefix, xattr, clone_children, release_agent and name are not allowed\n");
 			return -EINVAL;
 		}
 	} else {
@@ -1261,7 +1263,7 @@ static int cgroup_remount(struct kernfs_root *kf_root, int *flags, char *data)
 	unsigned long added_mask, removed_mask;
 
 	if (root->flags & CGRP_ROOT_SANE_BEHAVIOR) {
-		pr_err("cgroup: sane_behavior: remount is not allowed\n");
+		pr_err("sane_behavior: remount is not allowed\n");
 		return -EINVAL;
 	}
 
@@ -1274,7 +1276,7 @@ static int cgroup_remount(struct kernfs_root *kf_root, int *flags, char *data)
 		goto out_unlock;
 
 	if (opts.subsys_mask != root->cgrp.subsys_mask || opts.release_agent)
-		pr_warn("cgroup: option changes via remount are deprecated (pid=%d comm=%s)\n",
+		pr_warn("option changes via remount are deprecated (pid=%d comm=%s)\n",
 			task_tgid_nr(current), current->comm);
 
 	added_mask = opts.subsys_mask & ~root->cgrp.subsys_mask;
@@ -1283,7 +1285,7 @@ static int cgroup_remount(struct kernfs_root *kf_root, int *flags, char *data)
 	/* Don't allow flags or name to change at remount */
 	if (((opts.flags ^ root->flags) & CGRP_ROOT_OPTION_MASK) ||
 	    (opts.name && strcmp(opts.name, root->name))) {
-		pr_err("cgroup: option or name mismatch, new: 0x%lx \"%s\", old: 0x%lx \"%s\"\n",
+		pr_err("option or name mismatch, new: 0x%lx \"%s\", old: 0x%lx \"%s\"\n",
 		       opts.flags & CGRP_ROOT_OPTION_MASK, opts.name ?: "",
 		       root->flags & CGRP_ROOT_OPTION_MASK, root->name);
 		ret = -EINVAL;
@@ -1544,11 +1546,11 @@ retry:
 
 		if ((root->flags ^ opts.flags) & CGRP_ROOT_OPTION_MASK) {
 			if ((root->flags | opts.flags) & CGRP_ROOT_SANE_BEHAVIOR) {
-				pr_err("cgroup: sane_behavior: new mount options should match the existing superblock\n");
+				pr_err("sane_behavior: new mount options should match the existing superblock\n");
 				ret = -EINVAL;
 				goto out_unlock;
 			} else {
-				pr_warn("cgroup: new mount options do not match the existing superblock, will be ignored\n");
+				pr_warn("new mount options do not match the existing superblock, will be ignored\n");
 			}
 		}
 
@@ -2415,8 +2417,8 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
 		if (is_add) {
 			ret = cgroup_add_file(cgrp, cft);
 			if (ret) {
-				pr_warn("cgroup_addrm_files: failed to add %s, err=%d\n",
-					cft->name, ret);
+				pr_warn("%s: failed to add %s, err=%d\n",
+					__func__, cft->name, ret);
 				return ret;
 			}
 		} else {
@@ -3666,10 +3668,10 @@ static int create_css(struct cgroup *cgrp, struct cgroup_subsys *ss)
 
 	if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
 	    parent->parent) {
-		pr_warn("cgroup: %s (%d) created nested cgroup for controller \"%s\" which has incomplete hierarchy support. Nested cgroups may change behavior in the future.\n",
-			   current->comm, current->pid, ss->name);
+		pr_warn("%s (%d) created nested cgroup for controller \"%s\" which has incomplete hierarchy support. Nested cgroups may change behavior in the future.\n",
+			current->comm, current->pid, ss->name);
 		if (!strcmp(ss->name, "memory"))
-			pr_warn("cgroup: \"memory\" requires setting use_hierarchy to 1 on the root.\n");
+			pr_warn("\"memory\" requires setting use_hierarchy to 1 on the root\n");
 		ss->warned_broken_hierarchy = true;
 	}
