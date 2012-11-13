From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 15/17] cgroup: update cgroup_create() failure path
Date: Mon, 12 Nov 2012 19:01:42 -0800
Message-ID: <1352775704-9023-16-git-send-email-tj@kernel.org>
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

cgroup_create() was ignoring failure of cgroupfs files.  Update it
such that, if file creation fails, it rolls back by calling
cgroup_destroy_locked() and returns failure.

Note that error out goto labels are renamed.  The labels are a bit
confusing but will become better w/ later cgroup operation renames.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 8ad5e76..63d83d0 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4107,7 +4107,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	 */
 	if (!cgroup_lock_live_group(parent)) {
 		err = -ENODEV;
-		goto err_free;
+		goto err_free_cgrp;
 	}
 
 	/* Grab a reference on the superblock so the hierarchy doesn't
@@ -4135,13 +4135,13 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		css = ss->create(cgrp);
 		if (IS_ERR(css)) {
 			err = PTR_ERR(css);
-			goto err_destroy;
+			goto err_free_all;
 		}
 		init_cgroup_css(css, ss, cgrp);
 		if (ss->use_id) {
 			err = alloc_css_id(ss, parent, cgrp);
 			if (err)
-				goto err_destroy;
+				goto err_free_all;
 		}
 		/* At error, ->destroy() callback has to free assigned ID. */
 		if (clone_children(parent) && ss->post_clone)
@@ -4164,7 +4164,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	 */
 	err = cgroup_create_file(dentry, S_IFDIR | mode, sb);
 	if (err < 0)
-		goto err_destroy;
+		goto err_free_all;
 	lockdep_assert_held(&dentry->d_inode->i_mutex);
 
 	/* allocation complete, commit to creation */
@@ -4183,14 +4183,15 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	}
 
 	err = cgroup_populate_dir(cgrp, true, root->subsys_mask);
-	/* If err < 0, we have a half-filled directory - oh well ;) */
+	if (err)
+		goto err_destroy;
 
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 
 	return 0;
 
-err_destroy:
+err_free_all:
 	for_each_subsys(root, ss) {
 		if (cgrp->subsys[ss->subsys_id])
 			ss->destroy(cgrp);
@@ -4198,9 +4199,15 @@ err_destroy:
 	mutex_unlock(&cgroup_mutex);
 	/* Release the reference count that we took on the superblock */
 	deactivate_super(sb);
-err_free:
+err_free_cgrp:
 	kfree(cgrp);
 	return err;
+
+err_destroy:
+	cgroup_destroy_locked(cgrp);
+	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&dentry->d_inode->i_mutex);
+	return err;
 }
 
 static int cgroup_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
-- 
1.7.11.7
