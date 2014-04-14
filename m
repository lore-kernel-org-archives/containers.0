From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/12] cgroup: allow cgroup creation and suppress automatic
	css creation in the unified hierarchy
Date: Mon, 14 Apr 2014 17:37:06 -0400
Message-ID: <1397511430-2673-9-git-send-email-tj@kernel.org>
References: <1397511430-2673-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1397511430-2673-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Now that effective css handling has been added and iterators updated
accordingly, it's safe to allow cgroup creation in the default
hierarchy.  Unblock cgroup creation in the default hierarchy.

As the default hierarchy will implement explicit enabling and
disabling of controllers on each cgroup, suppress automatic css
enabling on cgroup creation.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3de3951..02c99a3 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1115,8 +1115,10 @@ static int rebind_subsystems(struct cgroup_root *dst_root,
 		src_root->subsys_mask &= ~(1 << ssid);
 		src_root->cgrp.child_subsys_mask &= ~(1 << ssid);
 
+		/* default hierarchy doesn't enable controllers by default */
 		dst_root->subsys_mask |= 1 << ssid;
-		dst_root->cgrp.child_subsys_mask |= 1 << ssid;
+		if (dst_root != &cgrp_dfl_root)
+			dst_root->cgrp.child_subsys_mask |= 1 << ssid;
 
 		if (ss->bind)
 			ss->bind(css);
@@ -3790,13 +3792,6 @@ static long cgroup_create(struct cgroup *parent, const char *name,
 	struct cgroup_subsys *ss;
 	struct kernfs_node *kn;
 
-	/*
-	 * XXX: The default hierarchy isn't fully implemented yet.  Block
-	 * !root cgroup creation on it for now.
-	 */
-	if (root == &cgrp_dfl_root)
-		return -EINVAL;
-
 	/* allocate the cgroup and its ID, 0 is reserved for the root */
 	cgrp = kzalloc(sizeof(*cgrp), GFP_KERNEL);
 	if (!cgrp)
@@ -3882,7 +3877,12 @@ static long cgroup_create(struct cgroup *parent, const char *name,
 		}
 	}
 
-	cgrp->child_subsys_mask = parent->child_subsys_mask;
+	/*
+	 * On the default hierarchy, a child doesn't automatically inherit
+	 * child_subsys_mask from the parent.  Each is configured manually.
+	 */
+	if (!cgroup_on_dfl(cgrp))
+		cgrp->child_subsys_mask = parent->child_subsys_mask;
 
 	kernfs_activate(kn);
 
-- 
1.9.0
