From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/11] cgroup: relocate setting of CGRP_DEAD
Date: Thu, 13 Mar 2014 15:50:04 -0400
Message-ID: <1394740213-17626-3-git-send-email-tj@kernel.org>
References: <1394740213-17626-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1394740213-17626-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

In cgroup_destroy_locked(), move setting of CGRP_DEAD above
invocations of kill_css().  This doesn't make any visible behavior
difference now but will be used to inhibit manipulating controller
enable states of a dying cgroup on the unified hierarchy.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ca19735..7bf1459 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3868,6 +3868,15 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 		return -EBUSY;
 
 	/*
+	 * Mark @cgrp dead.  This prevents further task migration and child
+	 * creation by disabling cgroup_lock_live_group().  Note that
+	 * CGRP_DEAD assertion is depended upon by css_next_child() to
+	 * resume iteration after dropping RCU read lock.  See
+	 * css_next_child() for details.
+	 */
+	set_bit(CGRP_DEAD, &cgrp->flags);
+
+	/*
 	 * Initiate massacre of all css's.  cgroup_destroy_css_killed()
 	 * will be invoked to perform the rest of destruction once the
 	 * percpu refs of all css's are confirmed to be killed.  This
@@ -3878,15 +3887,6 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 		kill_css(css);
 	mutex_lock(&cgroup_mutex);
 
-	/*
-	 * Mark @cgrp dead.  This prevents further task migration and child
-	 * creation by disabling cgroup_lock_live_group().  Note that
-	 * CGRP_DEAD assertion is depended upon by css_next_child() to
-	 * resume iteration after dropping RCU read lock.  See
-	 * css_next_child() for details.
-	 */
-	set_bit(CGRP_DEAD, &cgrp->flags);
-
 	/* CGRP_DEAD is set, remove from ->release_list for the last time */
 	raw_spin_lock(&release_list_lock);
 	if (!list_empty(&cgrp->release_list))
-- 
1.8.5.3
