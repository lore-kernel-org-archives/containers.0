From: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/3] cgroup: replace pr_warning with preferred pr_warn
Date: Thu, 17 Apr 2014 23:28:54 +0800
Message-ID: <1397748534-6490-1-git-send-email-nasa4836@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

As suggested by scripts/checkpatch.pl, substitude all pr_warning()
with pr_warn.

No functional change.

Signed-off-by: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 kernel/cgroup.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 38a9cd0..2b436e2 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1126,9 +1126,9 @@ static int rebind_subsystems(struct cgroup_root *dst_root,
 		 * Just warn about it and continue.
 		 */
 		if (cgrp_dfl_root_visible) {
-			pr_warning("cgroup: failed to create files (%d) while rebinding 0x%lx to default root\n",
+			pr_warn("cgroup: failed to create files (%d) while rebinding 0x%lx to default root\n",
 				   ret, ss_mask);
-			pr_warning("cgroup: you may retry by moving them to a different hierarchy and unbinding\n");
+			pr_warn("cgroup: you may retry by moving them to a different hierarchy and unbinding\n");
 		}
 	}
 
@@ -1326,7 +1326,7 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 	/* Consistency checks */
 
 	if (opts->flags & CGRP_ROOT_SANE_BEHAVIOR) {
-		pr_warning("cgroup: sane_behavior: this is still under development and its behaviors will change, proceed at your own risk\n");
+		pr_warn("cgroup: sane_behavior: this is still under development and its behaviors will change, proceed at your own risk\n");
 
 		if ((opts->flags & (CGRP_ROOT_NOPREFIX | CGRP_ROOT_XATTR)) ||
 		    opts->cpuset_clone_children || opts->release_agent ||
@@ -1390,7 +1390,7 @@ static int cgroup_remount(struct kernfs_root *kf_root, int *flags, char *data)
 		goto out_unlock;
 
 	if (opts.subsys_mask != root->subsys_mask || opts.release_agent)
-		pr_warning("cgroup: option changes via remount are deprecated (pid=%d comm=%s)\n",
+		pr_warn("cgroup: option changes via remount are deprecated (pid=%d comm=%s)\n",
 			   task_tgid_nr(current), current->comm);
 
 	added_mask = opts.subsys_mask & ~root->subsys_mask;
@@ -1672,7 +1672,7 @@ retry:
 				ret = -EINVAL;
 				goto out_unlock;
 			} else {
-				pr_warning("cgroup: new mount options do not match the existing superblock, will be ignored\n");
+				pr_warn("cgroup: new mount options do not match the existing superblock, will be ignored\n");
 			}
 		}
 
@@ -4171,10 +4171,10 @@ static int create_css(struct cgroup *cgrp, struct cgroup_subsys *ss)
 
 	if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
 	    parent->parent) {
-		pr_warning("cgroup: %s (%d) created nested cgroup for controller \"%s\" which has incomplete hierarchy support. Nested cgroups may change behavior in the future.\n",
+		pr_warn("cgroup: %s (%d) created nested cgroup for controller \"%s\" which has incomplete hierarchy support. Nested cgroups may change behavior in the future.\n",
 			   current->comm, current->pid, ss->name);
 		if (!strcmp(ss->name, "memory"))
-			pr_warning("cgroup: \"memory\" requires setting use_hierarchy to 1 on the root.\n");
+			pr_warn("cgroup: \"memory\" requires setting use_hierarchy to 1 on the root.\n");
 		ss->warned_broken_hierarchy = true;
 	}
 
-- 
1.9.0.GIT
