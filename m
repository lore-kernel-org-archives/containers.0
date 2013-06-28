From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 9/9] blkcg: make blkcg_policy_register() correctly handle
	cgroup_add_cftypes() failures
Date: Fri, 28 Jun 2013 16:45:45 -0700
Message-ID: <1372463145-4245-10-git-send-email-tj__14171.1556505927$1372463224$gmane$org@kernel.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Jens.

How should this one be routed?  It can go through either block or
cgroup tree.

Thanks!

------------------------- 8< -------------------------
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: blkcg: make blkcg_policy_register() correctly handle cgroup_add_cftypes() failures

blkcg_policy_register() currently triggers WARN when
cgroup_add_cftypes() fails and proceeds, which is a rather crappy way
to handle errors.  It was written that way as cgroup_add_cftypes()
itself didn't handle errors correctly.  Now that cgroup_add_cftypes()
correctly handles errors in itself, let's handle its failure properly.

Remove the WARN_ON() and cancel and fail policy registration on
cgroup_add_cftypes() failure.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
---
 block/blk-cgroup.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index e8918ff..b27a9d2 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -1127,10 +1127,13 @@ int blkcg_policy_register(struct blkcg_policy *pol)
 	pol->plid = i;
 	blkcg_policy[i] = pol;
 
-	/* everything is in place, add intf files for the new policy */
-	if (pol->cftypes)
-		WARN_ON(cgroup_add_cftypes(&blkio_subsys, pol->cftypes));
+	/* try to add intf files for the new policy */
 	ret = 0;
+	if (pol->cftypes) {
+		ret = cgroup_add_cftypes(&blkio_subsys, pol->cftypes);
+		if (ret)
+			blkcg_policy[i] = NULL;
+	}
 out_unlock:
 	mutex_unlock(&blkcg_pol_mutex);
 	return ret;
-- 
1.8.3.1
