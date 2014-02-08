From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 03/13] cgroup: release cgroup_mutex over file removals
Date: Sat,  8 Feb 2014 11:15:17 -0500
Message-ID: <1391876127-7134-4-git-send-email-tj@kernel.org>
References: <1391876127-7134-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391876127-7134-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Now that cftypes and all tree modification operations are protected by
cgroup_tree_mutex, we can drop cgroup_mutex while deleting files and
directories.  Drop cgroup_mutex over removals.

This doesn't make any noticeable difference now but is to help kernfs
conversion.  In kernfs, removals are sync points which drain in-flight
operations as those operations would grab cgroup_mutex, trying to
delete under cgroup_mutex would deadlock.  This can be resolved by
just holding the outer cgroup_tree_mutex which nests outside both
kernfs active reference and cgroup_mutex.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e41987d..908ad96 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -974,7 +974,9 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	 * Nothing can fail from this point on.  Remove files for the
 	 * removed subsystems and rebind each subsystem.
 	 */
+	mutex_unlock(&cgroup_mutex);
 	cgroup_clear_dir(cgrp, removed_mask);
+	mutex_lock(&cgroup_mutex);
 
 	for_each_subsys(ss, i) {
 		unsigned long bit = 1UL << i;
@@ -2694,10 +2696,11 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 	u64 update_before;
 	int ret = 0;
 
+	mutex_unlock(&cgroup_mutex);
+
 	/* %NULL @cfts indicates abort and don't bother if @ss isn't attached */
 	if (!cfts || ss->root == &cgroup_dummy_root ||
 	    !atomic_inc_not_zero(&sb->s_active)) {
-		mutex_unlock(&cgroup_mutex);
 		mutex_unlock(&cgroup_tree_mutex);
 		return 0;
 	}
@@ -2721,18 +2724,15 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 		dput(prev);
 		prev = cgrp->dentry;
 
-		mutex_unlock(&cgroup_mutex);
 		mutex_unlock(&cgroup_tree_mutex);
 		mutex_lock(&inode->i_mutex);
 		mutex_lock(&cgroup_tree_mutex);
-		mutex_lock(&cgroup_mutex);
 		if (cgrp->serial_nr < update_before && !cgroup_is_dead(cgrp))
 			ret = cgroup_addrm_files(cgrp, cfts, is_add);
 		mutex_unlock(&inode->i_mutex);
 		if (ret)
 			break;
 	}
-	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgroup_tree_mutex);
 	dput(prev);
 	deactivate_super(sb);
@@ -4385,10 +4385,13 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	/*
 	 * Initiate massacre of all css's.  cgroup_destroy_css_killed()
 	 * will be invoked to perform the rest of destruction once the
-	 * percpu refs of all css's are confirmed to be killed.
+	 * percpu refs of all css's are confirmed to be killed.  This
+	 * involves removing the subsystem's files, drop cgroup_mutex.
 	 */
+	mutex_unlock(&cgroup_mutex);
 	for_each_css(css, ssid, cgrp)
 		kill_css(css);
+	mutex_lock(&cgroup_mutex);
 
 	/*
 	 * Mark @cgrp dead.  This prevents further task migration and child
@@ -4419,9 +4422,11 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	 * puts the base ref but we aren't quite done with @cgrp yet, so
 	 * hold onto it.
 	 */
+	mutex_unlock(&cgroup_mutex);
 	cgroup_addrm_files(cgrp, cgroup_base_files, false);
 	dget(d);
 	cgroup_d_remove_dir(d);
+	mutex_lock(&cgroup_mutex);
 
 	return 0;
 };
-- 
1.8.5.3
