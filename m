From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/4] cgroup: fix locking in cgroup_cfts_commit()
Date: Tue, 28 Jan 2014 10:32:04 -0500
Message-ID: <1390923125-4369-4-git-send-email-tj@kernel.org>
References: <1390923125-4369-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390923125-4369-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_cfts_commit() walks the cgroup hierarchy that the target
subsystem is attached to and tries to apply the file changes.  Due to
the convolution with inode locking, it can't keep cgroup_mutex locked
while iterating.  It currently holds only RCU read lock around the
actual iteration and then pins the found cgroup using dget().

Unfortunately, this is incorrect.  Although the iteration does check
cgroup_is_dead() before invoking dget(), there's nothing which
prevents the dentry from going away inbetween.  Note that this is
different from the usual css iterations where css_tryget() is used to
pin the css - css_tryget() tests whether the css can be pinned and
fails if not.

The problem can be solved by simply holding cgroup_mutex instead of
RCU read lock around the iteration, which actually reduces LOC.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 kernel/cgroup.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2e9f12a..b0e030f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2763,10 +2763,7 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 	 */
 	update_before = cgroup_serial_nr_next;
 
-	mutex_unlock(&cgroup_mutex);
-
 	/* add/rm files for all cgroups created before */
-	rcu_read_lock();
 	css_for_each_descendant_pre(css, cgroup_css(root, ss)) {
 		struct cgroup *cgrp = css->cgroup;
 
@@ -2775,23 +2772,19 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 
 		inode = cgrp->dentry->d_inode;
 		dget(cgrp->dentry);
-		rcu_read_unlock();
-
 		dput(prev);
 		prev = cgrp->dentry;
 
+		mutex_unlock(&cgroup_mutex);
 		mutex_lock(&inode->i_mutex);
 		mutex_lock(&cgroup_mutex);
 		if (cgrp->serial_nr < update_before && !cgroup_is_dead(cgrp))
 			ret = cgroup_addrm_files(cgrp, cfts, is_add);
-		mutex_unlock(&cgroup_mutex);
 		mutex_unlock(&inode->i_mutex);
-
-		rcu_read_lock();
 		if (ret)
 			break;
 	}
-	rcu_read_unlock();
+	mutex_unlock(&cgroup_mutex);
 	dput(prev);
 	deactivate_super(sb);
 	return ret;
-- 
1.8.5.3
