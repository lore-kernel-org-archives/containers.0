From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/7] cgroup: reorder operations in cgroup_create()
Date: Fri,  6 Dec 2013 15:27:48 -0500
Message-ID: <1386361672-27791-4-git-send-email-tj@kernel.org>
References: <1386361672-27791-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1386361672-27791-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: vdavydov-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

cgroup_create() currently does the followings.

1. alloc cgroup
2. alloc css's
3. create the directory and commit to cgroup creation
4. online css's
5. create cgroup and css files

The sequence performs allocations before other operations but it
doesn't buy anything because each of the above steps may fail and
should be unrollable.  Reorganize the sequence such that cgroup
operations are done before css operations.

1. alloc cgroup
2. create the directory and files and commit to cgroup creation
3. alloc css's
4. create files for and online css's

This simplifies the code a bit and enables further simplification and
separating out css creation from cgroup creation which is necessary
for the planned unified hierarchy where css's will be created and
destroyed dynamically across the lifetime of a cgroup.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c | 70 +++++++++++++++++++++++++++------------------------------
 1 file changed, 33 insertions(+), 37 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 4a7fb40..30a2670 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4144,23 +4144,6 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	if (test_bit(CGRP_CPUSET_CLONE_CHILDREN, &parent->flags))
 		set_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags);
 
-	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css;
-
-		css = ss->css_alloc(cgroup_css(parent, ss));
-		if (IS_ERR(css)) {
-			err = PTR_ERR(css);
-			goto err_free_all;
-		}
-		css_ar[ss->subsys_id] = css;
-
-		err = percpu_ref_init(&css->refcnt, css_release);
-		if (err)
-			goto err_free_all;
-
-		init_css(css, ss, cgrp);
-	}
-
 	/*
 	 * Create directory.  cgroup_create_file() returns with the new
 	 * directory locked on success so that it can be populated without
@@ -4168,7 +4151,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	 */
 	err = cgroup_create_file(dentry, S_IFDIR | mode, sb);
 	if (err < 0)
-		goto err_free_all;
+		goto err_unlock;
 	lockdep_assert_held(&dentry->d_inode->i_mutex);
 
 	cgrp->serial_nr = cgroup_serial_nr_next++;
@@ -4180,10 +4163,41 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	/* hold a ref to the parent's dentry */
 	dget(parent->dentry);
 
+	/*
+	 * @cgrp is now fully operational.  If something fails after this
+	 * point, it'll be released via the normal destruction path.
+	 */
+	idr_replace(&root->cgroup_idr, cgrp, cgrp->id);
+
+	err = cgroup_addrm_files(cgrp, cgroup_base_files, true);
+	if (err)
+		goto err_destroy;
+
+	for_each_root_subsys(root, ss) {
+		struct cgroup_subsys_state *css;
+
+		css = ss->css_alloc(cgroup_css(parent, ss));
+		if (IS_ERR(css)) {
+			err = PTR_ERR(css);
+			goto err_destroy;
+		}
+		css_ar[ss->subsys_id] = css;
+
+		err = percpu_ref_init(&css->refcnt, css_release);
+		if (err)
+			goto err_destroy;
+
+		init_css(css, ss, cgrp);
+	}
+
 	/* creation succeeded, notify subsystems */
 	for_each_root_subsys(root, ss) {
 		struct cgroup_subsys_state *css = css_ar[ss->subsys_id];
 
+		err = cgroup_populate_dir(cgrp, 1 << ss->subsys_id);
+		if (err)
+			goto err_destroy;
+
 		err = online_css(css);
 		if (err)
 			goto err_destroy;
@@ -4205,30 +4219,12 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		}
 	}
 
-	idr_replace(&root->cgroup_idr, cgrp, cgrp->id);
-
-	err = cgroup_addrm_files(cgrp, cgroup_base_files, true);
-	if (err)
-		goto err_destroy;
-
-	err = cgroup_populate_dir(cgrp, root->subsys_mask);
-	if (err)
-		goto err_destroy;
-
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 
 	return 0;
 
-err_free_all:
-	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css = css_ar[ss->subsys_id];
-
-		if (css) {
-			percpu_ref_cancel_init(&css->refcnt);
-			ss->css_free(css);
-		}
-	}
+err_unlock:
 	mutex_unlock(&cgroup_mutex);
 	/* Release the reference count that we took on the superblock */
 	deactivate_super(sb);
-- 
1.8.4.2
