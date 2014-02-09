From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 01/16] cgroup: disallow xattr,
	release_agent and name if sane_behavior
Date: Sun,  9 Feb 2014 08:52:29 -0500
Message-ID: <1391953964-22088-2-git-send-email-tj@kernel.org>
References: <1391953964-22088-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391953964-22088-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Disallow more mount options if sane_behavior.  Note that xattr used to
generate warning.

While at it, simplify option check in cgroup_mount() and update
sane_behavior comment in cgroup.h.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  6 +++---
 kernel/cgroup.c        | 14 ++++----------
 2 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 5f2c629..fa415a8 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -225,8 +225,8 @@ enum {
 	 *
 	 * The followings are the behaviors currently affected this flag.
 	 *
-	 * - Mount options "noprefix" and "clone_children" are disallowed.
-	 *   Also, cgroupfs file cgroup.clone_children is not created.
+	 * - Mount options "noprefix", "xattr", "clone_children",
+	 *   "release_agent" and "name" are disallowed.
 	 *
 	 * - When mounting an existing superblock, mount options should
 	 *   match.
@@ -244,7 +244,7 @@ enum {
 	 * - "release_agent" and "notify_on_release" are removed.
 	 *   Replacement notification mechanism will be implemented.
 	 *
-	 * - "xattr" mount option is deprecated.  kernfs always enables it.
+	 * - "cgroup.clone_children" is removed.
 	 *
 	 * - cpuset: tasks will be kept in empty cpusets when hotplug happens
 	 *   and take masks of ancestors with non-empty cpus/mems, instead of
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 4c53e90..47160ce 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1224,18 +1224,12 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 	if (opts->flags & CGRP_ROOT_SANE_BEHAVIOR) {
 		pr_warning("cgroup: sane_behavior: this is still under development and its behaviors will change, proceed at your own risk\n");
 
-		if (opts->flags & CGRP_ROOT_NOPREFIX) {
-			pr_err("cgroup: sane_behavior: noprefix is not allowed\n");
+		if ((opts->flags & (CGRP_ROOT_NOPREFIX | CGRP_ROOT_XATTR)) ||
+		    opts->cpuset_clone_children || opts->release_agent ||
+		    opts->name) {
+			pr_err("cgroup: sane_behavior: noprefix, xattr, clone_children, release_agent and name are not allowed\n");
 			return -EINVAL;
 		}
-
-		if (opts->cpuset_clone_children) {
-			pr_err("cgroup: sane_behavior: clone_children is not allowed\n");
-			return -EINVAL;
-		}
-
-		if (opts->flags & CGRP_ROOT_XATTR)
-			pr_warning("cgroup: sane_behavior: xattr is always available, flag unnecessary\n");
 	}
 
 	/*
-- 
1.8.5.3
