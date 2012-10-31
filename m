From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/8] cgroup: deactivate CSS's and mark cgroup dead before
	invoking ->pre_destroy()
Date: Wed, 31 Oct 2012 12:44:06 -0700
Message-ID: <1351712650-23709-5-git-send-email-tj__38479.3223035105$1351712716$gmane$org@kernel.org>
References: <1351712650-23709-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351712650-23709-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Because ->pre_destroy() could fail and can't be called under
cgroup_mutex, cgroup destruction did something very ugly.

  1. Grab cgroup_mutex and verify it can be destroyed; fail otherwise.

  2. Release cgroup_mutex and call ->pre_destroy().

  3. Re-grab cgroup_mutex and verify it can still be destroyed; fail
     otherwise.

  4. Continue destroying.

In addition to being ugly, it has been always broken in various ways.
For example, memcg ->pre_destroy() expects the cgroup to be inactive
after it's done but tasks can be attached and detached between #2 and
#3 and the conditions that memcg verified in ->pre_destroy() might no
longer hold by the time control reaches #3.

Now that ->pre_destroy() is no longer allowed to fail.  We can switch
to the following.

  1. Grab cgroup_mutex and verify it can be destroyed; fail otherwise.

  2. Deactivate CSS's and mark the cgroup removed thus preventing any
     further operations which can invalidate the verification from #1.

  3. Release cgroup_mutex and call ->pre_destroy().

  4. Re-grab cgroup_mutex and continue destroying.

After this change, controllers can safely assume that ->pre_destroy()
will only be called only once for a given cgroup and, once
->pre_destroy() is called, the cgroup will stay dormant till it's
destroyed.

This removes the only reason ->pre_destroy() can fail - new task being
attached or child cgroup being created inbetween.  Error out path is
removed and ->pre_destroy() invocation is open coded in
cgroup_rmdir().

v2: cgroup_call_pre_destroy() removal moved to this patch per Michal.
    Commit message updated per Glauber.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
---
 kernel/cgroup.c | 65 +++++++++++++++++----------------------------------------
 1 file changed, 19 insertions(+), 46 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f22e3cd..66204a6 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -851,27 +851,6 @@ static struct inode *cgroup_new_inode(umode_t mode, struct super_block *sb)
 	return inode;
 }
 
-/*
- * Call subsys's pre_destroy handler.
- * This is called before css refcnt check.
- */
-static int cgroup_call_pre_destroy(struct cgroup *cgrp)
-{
-	struct cgroup_subsys *ss;
-	int ret = 0;
-
-	for_each_subsys(cgrp->root, ss) {
-		if (!ss->pre_destroy)
-			continue;
-
-		ret = ss->pre_destroy(cgrp);
-		if (WARN_ON_ONCE(ret))
-			break;
-	}
-
-	return ret;
-}
-
 static void cgroup_diput(struct dentry *dentry, struct inode *inode)
 {
 	/* is dentry a directory ? if so, kfree() associated cgroup */
@@ -4078,19 +4057,6 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 	DEFINE_WAIT(wait);
 	struct cgroup_event *event, *tmp;
 	struct cgroup_subsys *ss;
-	int ret;
-
-	/* the vfs holds both inode->i_mutex already */
-	mutex_lock(&cgroup_mutex);
-	if (atomic_read(&cgrp->count) != 0) {
-		mutex_unlock(&cgroup_mutex);
-		return -EBUSY;
-	}
-	if (!list_empty(&cgrp->children)) {
-		mutex_unlock(&cgroup_mutex);
-		return -EBUSY;
-	}
-	mutex_unlock(&cgroup_mutex);
 
 	/*
 	 * In general, subsystem has no css->refcnt after pre_destroy(). But
@@ -4103,16 +4069,7 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 	 */
 	set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
 
-	/*
-	 * Call pre_destroy handlers of subsys. Notify subsystems
-	 * that rmdir() request comes.
-	 */
-	ret = cgroup_call_pre_destroy(cgrp);
-	if (ret) {
-		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
-		return ret;
-	}
-
+	/* the vfs holds both inode->i_mutex already */
 	mutex_lock(&cgroup_mutex);
 	parent = cgrp->parent;
 	if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
@@ -4122,13 +4079,30 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 	}
 	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
 
-	/* block new css_tryget() by deactivating refcnt */
+	/*
+	 * Block new css_tryget() by deactivating refcnt and mark @cgrp
+	 * removed.  This makes future css_tryget() and child creation
+	 * attempts fail thus maintaining the removal conditions verified
+	 * above.
+	 */
 	for_each_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
 
 		WARN_ON(atomic_read(&css->refcnt) < 0);
 		atomic_add(CSS_DEACT_BIAS, &css->refcnt);
 	}
+	set_bit(CGRP_REMOVED, &cgrp->flags);
+
+	/*
+	 * Tell subsystems to initate destruction.  pre_destroy() should be
+	 * called with cgroup_mutex unlocked.  See 3fa59dfbc3 ("cgroup: fix
+	 * potential deadlock in pre_destroy") for details.
+	 */
+	mutex_unlock(&cgroup_mutex);
+	for_each_subsys(cgrp->root, ss)
+		if (ss->pre_destroy)
+			WARN_ON_ONCE(ss->pre_destroy(cgrp));
+	mutex_lock(&cgroup_mutex);
 
 	/*
 	 * Put all the base refs.  Each css holds an extra reference to the
@@ -4144,7 +4118,6 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 	clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
 
 	raw_spin_lock(&release_list_lock);
-	set_bit(CGRP_REMOVED, &cgrp->flags);
 	if (!list_empty(&cgrp->release_list))
 		list_del_init(&cgrp->release_list);
 	raw_spin_unlock(&release_list_lock);
-- 
1.7.11.7
