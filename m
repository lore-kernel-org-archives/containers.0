From: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/3] cgroup: clean up obsolete comment for
	parse_cgroupfs_options()
Date: Thu, 17 Apr 2014 23:29:15 +0800
Message-ID: <1397748555-6647-1-git-send-email-nasa4836@gmail.com>
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

Commit 1d5be6b287c8efc87(cgroup: move module ref handling into
rebind_subsystems()) makes parse_cgroupfs_options() no longer
takes refcounts on subsystems.

And unified hierachy makes parse_cgroupfs_options not need to
call with cgroup_mutex held to protect the cgroup_subsys[].

So this patch cleanups these comment and BUG_ON().

Signed-off-by: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 kernel/cgroup.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2412cb7..b261798 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1222,10 +1222,7 @@ struct cgroup_sb_opts {
 };
 
 /*
- * Convert a hierarchy specifier into a bitmask of subsystems and
- * flags. Call with cgroup_mutex held to protect the cgroup_subsys[]
- * array. This function takes refcounts on subsystems to be used, unless it
- * returns error, in which case no refcounts are taken.
+ * Convert a hierarchy specifier into a bitmask of subsystems and flags.
  */
 static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 {
@@ -1235,8 +1232,6 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 	struct cgroup_subsys *ss;
 	int i;
 
-	BUG_ON(!mutex_is_locked(&cgroup_mutex));
-
 #ifdef CONFIG_CPUSETS
 	mask = ~(1UL << cpuset_cgrp_id);
 #endif
-- 
1.9.0.GIT
