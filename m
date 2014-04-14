From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/12] cgroup: update subsystem rebind restrictions
Date: Mon, 14 Apr 2014 17:37:08 -0400
Message-ID: <1397511430-2673-11-git-send-email-tj@kernel.org>
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

Because the default root couldn't have any non-root csses attached to
it, rebinding away from it was always allowed; however, the default
hierarchy will soon host the unified hierarchy and have non-root csses
so the rebind restrictions need to be updated accordingly.

Instead of special casing rebinding from the default hierarchy and
then checking whether the source hierarchy has children cgroups, which
implies non-root csses for !dfl hierarchies, simply check whether the
source hierarchy has non-root csses for the subsystem using
css_next_child().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b4cd1fe..888e037 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1051,16 +1051,12 @@ static int rebind_subsystems(struct cgroup_root *dst_root,
 		if (!(ss_mask & (1 << ssid)))
 			continue;
 
-		/* if @ss is on the dummy_root, we can always move it */
-		if (ss->root == &cgrp_dfl_root)
-			continue;
-
-		/* if @ss has non-root cgroups attached to it, can't move */
-		if (!list_empty(&ss->root->cgrp.children))
+		/* if @ss has non-root csses attached to it, can't move */
+		if (css_next_child(NULL, cgroup_css(&ss->root->cgrp, ss)))
 			return -EBUSY;
 
 		/* can't move between two non-dummy roots either */
-		if (dst_root != &cgrp_dfl_root)
+		if (ss->root != &cgrp_dfl_root && dst_root != &cgrp_dfl_root)
 			return -EBUSY;
 	}
 
-- 
1.9.0
