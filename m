From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH cgroup/for-3.11] cgroup: reserve ID 0 for dummy_root and 1
	for unified hierarchy
Date: Sat, 22 Jun 2013 09:30:41 -0700
Message-ID: <20130622163041.GA15261@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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

Before 1a57423166 ("cgroup: make hierarchy_id use cyclic idr"),
hierarchy IDs were allocated from 0.  As the dummy hierarchy was
always the one first initialized, it got assigned 0 and all other
hierarchies from 1.  The patch accidentally changed the minimum
useable ID to 2.

Let's restore ID 0 for dummy_root and while at it reserve 1 for
unified hierarchy.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 kernel/cgroup.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1421,14 +1421,15 @@ static void init_cgroup_root(struct cgro
 	init_cgroup_housekeeping(cgrp);
 }
 
-static int cgroup_init_root_id(struct cgroupfs_root *root)
+static int cgroup_init_root_id(struct cgroupfs_root *root, int start, int end)
 {
 	int id;
 
 	lockdep_assert_held(&cgroup_mutex);
 	lockdep_assert_held(&cgroup_root_mutex);
 
-	id = idr_alloc_cyclic(&cgroup_hierarchy_idr, root, 2, 0, GFP_KERNEL);
+	id = idr_alloc_cyclic(&cgroup_hierarchy_idr, root, start, end,
+			      GFP_KERNEL);
 	if (id < 0)
 		return id;
 
@@ -1631,7 +1632,8 @@ static struct dentry *cgroup_mount(struc
 		if (ret)
 			goto unlock_drop;
 
-		ret = cgroup_init_root_id(root);
+		/* ID 0 is reserved for dummy root, 1 for unified hierarchy */
+		ret = cgroup_init_root_id(root, 2, 0);
 		if (ret)
 			goto unlock_drop;
 
@@ -4899,7 +4901,7 @@ int __init cgroup_init(void)
 	mutex_lock(&cgroup_mutex);
 	mutex_lock(&cgroup_root_mutex);
 
-	BUG_ON(cgroup_init_root_id(&cgroup_dummy_root));
+	BUG_ON(cgroup_init_root_id(&cgroup_dummy_root, 0, 1));
 
 	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
