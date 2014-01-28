From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/8] cgroup: warn if "xattr" is specified with "sane_behavior"
Date: Tue, 28 Jan 2014 18:59:38 -0500
Message-ID: <1390953585-16554-2-git-send-email-tj@kernel.org>
References: <1390953585-16554-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390953585-16554-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Mount option "xattr" is no longer necessary as it's enabled by default
on kernfs.  Warn if "xattr" is specified with "sane_behavior" so that
the option can be removed in the future.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 2 ++
 kernel/cgroup.c        | 3 +++
 2 files changed, 5 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index b6c2652..6fe238e 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -262,6 +262,8 @@ enum {
 	 * - "release_agent" and "notify_on_release" are removed.
 	 *   Replacement notification mechanism will be implemented.
 	 *
+	 * - "xattr" mount option is deprecated.  kernfs always enables it.
+	 *
 	 * - cpuset: tasks will be kept in empty cpusets when hotplug happens
 	 *   and take masks of ancestors with non-empty cpus/mems, instead of
 	 *   being moved to an ancestor.
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e60a5e3..056bd7d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1265,6 +1265,9 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 			pr_err("cgroup: sane_behavior: clone_children is not allowed\n");
 			return -EINVAL;
 		}
+
+		if (opts->flags & CGRP_ROOT_XATTR)
+			pr_warning("cgroup: sane_behavior: xattr is always available, flag unnecessary\n");
 	}
 
 	/*
-- 
1.8.5.3
