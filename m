From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 8/9] cgroup: move number_of_cgroups test out of
	rebind_subsystems() into cgroup_remount()
Date: Fri, 28 Jun 2013 16:45:44 -0700
Message-ID: <1372463145-4245-9-git-send-email-tj__10656.6217531965$1372463217$gmane$org@kernel.org>
References: <1372463145-4245-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1372463145-4245-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

rebind_subsystems() currently fails if the hierarchy has any !root
cgroups; however, on the planned unified hierarchy,
rebind_subsystems() will be used while populated.  Move the test to
cgroup_remount(), which is the only place the test is necessary
anyway.

As it's impossible for the other two callers of rebind_subsystems() to
have populated hierarchy, this doesn't make any behavior changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 51632b4..17c8985 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1013,13 +1013,6 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 		if (test_bit(i, &added_mask) && ss->root != &cgroup_dummy_root)
 			return -EBUSY;
 
-	/* Currently we don't handle adding/removing subsystems when
-	 * any child cgroups exist. This is theoretically supportable
-	 * but involves complex error handling, so it's being left until
-	 * later */
-	if (root->number_of_cgroups > 1)
-		return -EBUSY;
-
 	ret = cgroup_populate_dir(cgrp, added_mask);
 	if (ret)
 		return ret;
@@ -1365,6 +1358,12 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 		goto out_unlock;
 	}
 
+	/* remounting is not allowed for populated hierarchies */
+	if (root->number_of_cgroups > 1) {
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
 	ret = rebind_subsystems(root, added_mask, removed_mask);
 	if (ret)
 		goto out_unlock;
-- 
1.8.3.1
