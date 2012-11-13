From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/17] cgroup: create directory before linking while creating
	a new cgroup
Date: Mon, 12 Nov 2012 19:01:31 -0800
Message-ID: <1352775704-9023-5-git-send-email-tj@kernel.org>
References: <1352775704-9023-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1352775704-9023-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

While creating a new cgroup, cgroup_create() links the newly allocated
cgroup into various places before trying to create its directory.
Because cgroup life-cycle is tied to the vfs objects, this makes it
impossible to use cgroup_rmdir() for rolling back creation - the
removal logic depends on having full vfs objects.

This patch moves directory creation above linking and collect linking
operations to one place.  This allows directory creation failure to
share error exit path with css allocation failures and any failure
sites afterwards (to be added later) can use cgroup_rmdir() logic to
undo creation.

It also removes the need to check whether cgroup->dentry is %NULL in
cgroup_path.  If a cgroup is visible, its dentry is guaranteed to be
visible too.

Note that this also makes the memory barriers around cgroup->dentry,
which currently is misleadingly using RCU operations, unnecessary.
This will be handled in the next patch.

While at it, locking BUG_ON() on i_mutex is converted to
lockdep_assert_held().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 32 +++++++++++++-------------------
 1 file changed, 13 insertions(+), 19 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b042673..40707cd 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1760,7 +1760,7 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 	struct dentry *dentry = rcu_dereference_check(cgrp->dentry,
 						      cgroup_lock_is_held());
 
-	if (!dentry || cgrp == dummytop) {
+	if (cgrp == dummytop) {
 		/*
 		 * Inactive subsystems have no dentry for their root
 		 * cgroup
@@ -4112,15 +4112,22 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		}
 	}
 
-	list_add_tail_rcu(&cgrp->sibling, &cgrp->parent->children);
-	root->number_of_cgroups++;
-
+	/*
+	 * Create directory.  cgroup_create_file() returns with the new
+	 * directory locked on success so that it can be populated without
+	 * dropping cgroup_mutex.
+	 */
 	err = cgroup_create_file(dentry, S_IFDIR | mode, sb);
 	if (err < 0)
-		goto err_remove;
+		goto err_destroy;
+	lockdep_assert_held(&dentry->d_inode->i_mutex);
 
+	/* allocation complete, commit to creation */
 	dentry->d_fsdata = cgrp;
 	rcu_assign_pointer(cgrp->dentry, dentry);
+	list_add_tail(&cgrp->allcg_node, &root->allcg_list);
+	list_add_tail_rcu(&cgrp->sibling, &cgrp->parent->children);
+	root->number_of_cgroups++;
 
 	for_each_subsys(root, ss) {
 		/* each css holds a ref to the cgroup's dentry */
@@ -4131,11 +4138,6 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 			ss->post_create(cgrp);
 	}
 
-	/* The cgroup directory was pre-locked for us */
-	BUG_ON(!mutex_is_locked(&cgrp->dentry->d_inode->i_mutex));
-
-	list_add_tail(&cgrp->allcg_node, &root->allcg_list);
-
 	err = cgroup_populate_dir(cgrp, true, root->subsys_mask);
 	/* If err < 0, we have a half-filled directory - oh well ;) */
 
@@ -4144,20 +4146,12 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 
 	return 0;
 
- err_remove:
-
-	list_del_rcu(&cgrp->sibling);
-	root->number_of_cgroups--;
-
- err_destroy:
-
+err_destroy:
 	for_each_subsys(root, ss) {
 		if (cgrp->subsys[ss->subsys_id])
 			ss->destroy(cgrp);
 	}
-
 	mutex_unlock(&cgroup_mutex);
-
 	/* Release the reference count that we took on the superblock */
 	deactivate_super(sb);
 err_free:
-- 
1.7.11.7
