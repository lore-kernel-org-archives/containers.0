From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/7] cgroup: combine css handling loops in cgroup_create()
Date: Fri,  6 Dec 2013 15:27:49 -0500
Message-ID: <1386361672-27791-5-git-send-email-tj@kernel.org>
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

Now that css operations in cgroup_create() are back-to-back, there
isn't much point in allocating css's in one loop and onlining them in
another.  Merge the two loops so that a css is allocated and onlined
on each iteration.

css_ar[] is no longer necessary and replaced with a single pointer.
This also simplifies the error handling path.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c | 25 +++++++------------------
 1 file changed, 7 insertions(+), 18 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 30a2670..39e2295 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4084,7 +4084,7 @@ static void offline_css(struct cgroup_subsys_state *css)
 static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 			     umode_t mode)
 {
-	struct cgroup_subsys_state *css_ar[CGROUP_SUBSYS_COUNT] = { };
+	struct cgroup_subsys_state *css = NULL;
 	struct cgroup *cgrp;
 	struct cgroup_name *name;
 	struct cgroupfs_root *root = parent->root;
@@ -4173,26 +4173,20 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	if (err)
 		goto err_destroy;
 
+	/* let's create and online css's */
 	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css;
-
 		css = ss->css_alloc(cgroup_css(parent, ss));
 		if (IS_ERR(css)) {
 			err = PTR_ERR(css);
+			css = NULL;
 			goto err_destroy;
 		}
-		css_ar[ss->subsys_id] = css;
 
 		err = percpu_ref_init(&css->refcnt, css_release);
 		if (err)
 			goto err_destroy;
 
 		init_css(css, ss, cgrp);
-	}
-
-	/* creation succeeded, notify subsystems */
-	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css = css_ar[ss->subsys_id];
 
 		err = cgroup_populate_dir(cgrp, 1 << ss->subsys_id);
 		if (err)
@@ -4202,12 +4196,11 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		if (err)
 			goto err_destroy;
 
-		/* each css holds a ref to the cgroup's dentry and parent css */
 		dget(dentry);
 		css_get(css->parent);
 
 		/* mark it consumed for error path */
-		css_ar[ss->subsys_id] = NULL;
+		css = NULL;
 
 		if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
 		    parent->parent) {
@@ -4237,13 +4230,9 @@ err_free_cgrp:
 	return err;
 
 err_destroy:
-	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css = css_ar[ss->subsys_id];
-
-		if (css) {
-			percpu_ref_cancel_init(&css->refcnt);
-			ss->css_free(css);
-		}
+	if (css) {
+		percpu_ref_cancel_init(&css->refcnt);
+		css->ss->css_free(css);
 	}
 	cgroup_destroy_locked(cgrp);
 	mutex_unlock(&cgroup_mutex);
-- 
1.8.4.2
