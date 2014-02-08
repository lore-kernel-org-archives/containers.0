From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 8/8] cgroup: remove cgroupfs_root->refcnt
Date: Sat,  8 Feb 2014 11:38:29 -0500
Message-ID: <1391877509-10855-9-git-send-email-tj__12196.2326732048$1391877593$gmane$org@kernel.org>
References: <1391877509-10855-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391877509-10855-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Currently, cgroupfs_root and its ->top_cgroup are separated reference
counted and the latter's is ignored.  There's no reason to do this
separately.  This patch removes cgroupfs_root->refcnt and destroys
cgroupfs_root when the top_cgroup is released.

* cgroup_put() updated to ignore cgroup_is_dead() test for top
  cgroups.  cgroup_free_fn() updated to handle root destruction when
  releasing a top cgroup.

* As root destruction is now bounced through cgroup destruction, it is
  asynchronous.  Update cgroup_mount() so that it waits for pending
  release which is currently implemented using msleep().  Converting
  this to proper wait_queue isn't hard but likely unnecessary.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  4 +--
 kernel/cgroup.c        | 86 ++++++++++++++++++++++----------------------------
 2 files changed, 39 insertions(+), 51 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index b14abaf..6756c23 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -280,12 +280,10 @@ struct cgroupfs_root {
 	/* The bitmask of subsystems attached to this hierarchy */
 	unsigned long subsys_mask;
 
-	atomic_t refcnt;
-
 	/* Unique id for this hierarchy. */
 	int hierarchy_id;
 
-	/* The root cgroup for this hierarchy */
+	/* The root cgroup.  Root is destroyed on its release. */
 	struct cgroup top_cgroup;
 
 	/* Number of cgroups in the hierarchy, used only for /proc/cgroups */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 13a8d2a..4c53e90 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -53,6 +53,7 @@
 #include <linux/vmalloc.h> /* TODO: replace with more sophisticated array */
 #include <linux/flex_array.h> /* used in cgroup_attach_task */
 #include <linux/kthread.h>
+#include <linux/delay.h>
 
 #include <linux/atomic.h>
 
@@ -728,37 +729,16 @@ static void cgroup_free_root(struct cgroupfs_root *root)
 	}
 }
 
-static void cgroup_get_root(struct cgroupfs_root *root)
-{
-	/*
-	 * The caller must ensure that @root is alive, which can be
-	 * achieved by holding a ref on one of the member cgroups or
-	 * following a registered reference to @root while holding
-	 * cgroup_tree_mutex.
-	 */
-	WARN_ON_ONCE(atomic_read(&root->refcnt) <= 0);
-	atomic_inc(&root->refcnt);
-}
-
-static void cgroup_put_root(struct cgroupfs_root *root)
+static void cgroup_destroy_root(struct cgroupfs_root *root)
 {
 	struct cgroup *cgrp = &root->top_cgroup;
 	struct cgrp_cset_link *link, *tmp_link;
 	int ret;
 
-	/*
-	 * @root's refcnt reaching zero and its deregistration should be
-	 * atomic w.r.t. cgroup_tree_mutex.  This ensures that
-	 * cgroup_get_root() is safe to invoke if @root is registered.
-	 */
 	mutex_lock(&cgroup_tree_mutex);
-	if (!atomic_dec_and_test(&root->refcnt)) {
-		mutex_unlock(&cgroup_tree_mutex);
-		return;
-	}
 	mutex_lock(&cgroup_mutex);
 
-	BUG_ON(atomic_read(&root->nr_cgrps) != 1);
+	BUG_ON(atomic_read(&root->nr_cgrps));
 	BUG_ON(!list_empty(&cgrp->children));
 
 	/* Rebind all subsystems back to the default hierarchy */
@@ -929,21 +909,24 @@ static void cgroup_free_fn(struct work_struct *work)
 	struct cgroup *cgrp = container_of(work, struct cgroup, destroy_work);
 
 	atomic_dec(&cgrp->root->nr_cgrps);
-
-	/*
-	 * We get a ref to the parent, and put the ref when this cgroup is
-	 * being freed, so it's guaranteed that the parent won't be
-	 * destroyed before its children.
-	 */
-	cgroup_put(cgrp->parent);
-
-	/* put the root reference that we took when we created the cgroup */
-	cgroup_put_root(cgrp->root);
-
 	cgroup_pidlist_destroy_all(cgrp);
 
-	kernfs_put(cgrp->kn);
-	kfree(cgrp);
+	if (cgrp->parent) {
+		/*
+		 * We get a ref to the parent, and put the ref when this
+		 * cgroup is being freed, so it's guaranteed that the
+		 * parent won't be destroyed before its children.
+		 */
+		cgroup_put(cgrp->parent);
+		kernfs_put(cgrp->kn);
+		kfree(cgrp);
+	} else {
+		/*
+		 * This is top cgroup's refcnt reaching zero, which
+		 * indicates that the root should be released.
+		 */
+		cgroup_destroy_root(cgrp->root);
+	}
 }
 
 static void cgroup_free_rcu(struct rcu_head *head)
@@ -965,7 +948,7 @@ static void cgroup_put(struct cgroup *cgrp)
 {
 	if (!atomic_dec_and_test(&cgrp->refcnt))
 		return;
-	if (WARN_ON_ONCE(!cgroup_is_dead(cgrp)))
+	if (WARN_ON_ONCE(cgrp->parent && !cgroup_is_dead(cgrp)))
 		return;
 
 	/*
@@ -1354,7 +1337,6 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 {
 	struct cgroup *cgrp = &root->top_cgroup;
 
-	atomic_set(&root->refcnt, 1);
 	INIT_LIST_HEAD(&root->root_list);
 	atomic_set(&root->nr_cgrps, 1);
 	cgrp->root = root;
@@ -1483,7 +1465,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	struct cgroup_sb_opts opts;
 	struct dentry *dentry;
 	int ret;
-
+retry:
 	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 
@@ -1529,7 +1511,21 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 			}
 		}
 
-		cgroup_get_root(root);
+		/*
+		 * A root's lifetime is governed by its top cgroup.  Zero
+		 * ref indicate that the root is being destroyed.  Wait for
+		 * destruction to complete so that the subsystems are free.
+		 * We can use wait_queue for the wait but this path is
+		 * super cold.  Let's just sleep for a bit and retry.
+		 */
+		if (!atomic_inc_not_zero(&root->top_cgroup.refcnt)) {
+			mutex_unlock(&cgroup_mutex);
+			mutex_unlock(&cgroup_tree_mutex);
+			msleep(10);
+			goto retry;
+		}
+
+		ret = 0;
 		goto out_unlock;
 	}
 
@@ -1556,7 +1552,7 @@ out_unlock:
 
 	dentry = kernfs_mount(fs_type, flags, root->kf_root);
 	if (IS_ERR(dentry))
-		cgroup_put_root(root);
+		cgroup_put(&root->top_cgroup);
 	return dentry;
 }
 
@@ -1565,7 +1561,7 @@ static void cgroup_kill_sb(struct super_block *sb)
 	struct kernfs_root *kf_root = kernfs_root_from_sb(sb);
 	struct cgroupfs_root *root = cgroup_root_from_kf(kf_root);
 
-	cgroup_put_root(root);
+	cgroup_put(&root->top_cgroup);
 	kernfs_kill_sb(sb);
 }
 
@@ -3706,12 +3702,6 @@ static long cgroup_create(struct cgroup *parent, const char *name,
 	/* allocation complete, commit to creation */
 	list_add_tail_rcu(&cgrp->sibling, &cgrp->parent->children);
 	atomic_inc(&root->nr_cgrps);
-
-	/*
-	 * Grab a reference on the root and parent so that they don't get
-	 * deleted while there are child cgroups.
-	 */
-	cgroup_get_root(root);
 	cgroup_get(parent);
 
 	/*
-- 
1.8.5.3
