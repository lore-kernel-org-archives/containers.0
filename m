From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cgroup: avoid creating degenerate allcg_list
Date: Wed, 28 Nov 2012 10:26:32 -0800
Message-ID: <1354127192-22153-1-git-send-email-gthelen@google.com>
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
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Before this patch init_cgroup_root() created a degenerate list by
first inserting a element into allcg_list and then initializing the
inserted list element.  The initialization reset the element's
prev/next fields forming a degenerate list where allcg_list pointed to
element, but element pointed to itself.  This problem was introduced
in 2243076ad128 "cgroup: initialize cgrp->allcg_node in
init_cgroup_housekeeping()".  CONFIG_DEBUG_LIST reported a list_add
corruption in cgroup_mkdir() running next-20121127 (ce2931a).

This patch fixes the problem by performing element initialization
before insertion.

Signed-off-by: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 01d5342..ece60d4 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1394,6 +1394,7 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 {
 	struct cgroup *cgrp = &root->top_cgroup;
 
+	init_cgroup_housekeeping(cgrp);
 	INIT_LIST_HEAD(&root->subsys_list);
 	INIT_LIST_HEAD(&root->root_list);
 	INIT_LIST_HEAD(&root->allcg_list);
@@ -1401,7 +1402,6 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 	cgrp->root = root;
 	cgrp->top_cgroup = cgrp;
 	list_add_tail(&cgrp->allcg_node, &root->allcg_list);
-	init_cgroup_housekeeping(cgrp);
 }
 
 static bool init_root_id(struct cgroupfs_root *root)
-- 
1.7.7.3
