From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 0.5/12] cgroup: cgroup_apply_cftypes() shouldn't skip the
	default hierarhcy
Date: Tue, 15 Apr 2014 18:05:04 -0400
Message-ID: <20140415220504.GA13099__18576.3936526657$1397599521$gmane$org@mtj.dyndns.org>
References: <1395974461-12735-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1395974461-12735-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From c7596b2f33e9f7a57cef6909c30fec268e921c3b Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Tue, 15 Apr 2014 18:02:12 -0400

cgroup_apply_cftypes() skip creating or removing files if the
subsystem is attached to the default hierarchy, which led to missing
files in the root of the default hierarchy.

Skipping made sense when the default hierarchy was dummy; however, now
that the default hierarchy is full functional and planned to be used
as the unified hierarchy, it shouldn't be skipped over.

Reported-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 9fcdaa7..fbcc710 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2436,10 +2436,6 @@ static int cgroup_apply_cftypes(struct cftype *cfts, bool is_add)
 
 	lockdep_assert_held(&cgroup_tree_mutex);
 
-	/* don't bother if @ss isn't attached */
-	if (ss->root == &cgrp_dfl_root)
-		return 0;
-
 	/* add/rm files for all cgroups created before */
 	css_for_each_descendant_pre(css, cgroup_css(root, ss)) {
 		struct cgroup *cgrp = css->cgroup;
-- 
1.9.0
