From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 7/9] cgroup: factor out cgroup_subsys_state creation into
	create_css()
Date: Wed, 28 Aug 2013 17:03:47 -0400
Message-ID: <1377723829-22814-8-git-send-email-tj__34920.6519466408$1377723897$gmane$org@kernel.org>
References: <1377723829-22814-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1377723829-22814-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Now that all opertations to create a css (cgroup_subsys_state) are
collected into a single loop in cgroup_create(), it's easy to factor
it out into its own function.  Factor out css creation into
create_css().  This makes the code easier to follow and will enable
decoupling css creation from cgroup creation which is necessary for
the planned unified hierarchy.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 107 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 63 insertions(+), 44 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 20cd24b..cd53b49 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4385,6 +4385,68 @@ static void offline_css(struct cgroup_subsys_state *css)
 	RCU_INIT_POINTER(css->cgroup->subsys[ss->subsys_id], css);
 }
 
+/**
+ * create_css - create a cgroup_subsys_state
+ * @cgrp: the cgroup new css will be associated with
+ * @ss: the subsys of new css
+ *
+ * Create a new css associated with @cgrp - @ss pair.  On success, the new
+ * css is online and installed in @cgrp with all interface files created.
+ * Returns 0 on success, -errno on failure.
+ */
+static int create_css(struct cgroup *cgrp, struct cgroup_subsys *ss)
+{
+	struct cgroup *parent = cgrp->parent;
+	struct cgroup_subsys_state *css;
+	int err;
+
+	lockdep_assert_held(&cgrp->dentry->d_inode->i_mutex);
+	lockdep_assert_held(&cgroup_mutex);
+
+	css = ss->css_alloc(cgroup_css(parent, ss));
+	if (IS_ERR(css))
+		return PTR_ERR(css);
+
+	err = percpu_ref_init(&css->refcnt, css_release);
+	if (err)
+		goto err_free;
+
+	init_css(css, ss, cgrp);
+
+	if (ss->use_id) {
+		err = alloc_css_id(css);
+		if (err)
+			goto err_free;
+	}
+
+	err = cgroup_populate_dir(cgrp, 1 << ss->subsys_id);
+	if (err)
+		goto err_free;
+
+	err = online_css(css);
+	if (err)
+		goto err_free;
+
+	dget(cgrp->dentry);
+	css_get(css->parent);
+
+	if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
+	    parent->parent) {
+		pr_warning("cgroup: %s (%d) created nested cgroup for controller \"%s\" which has incomplete hierarchy support. Nested cgroups may change behavior in the future.\n",
+			   current->comm, current->pid, ss->name);
+		if (!strcmp(ss->name, "memory"))
+			pr_warning("cgroup: \"memory\" requires setting use_hierarchy to 1 on the root.\n");
+		ss->warned_broken_hierarchy = true;
+	}
+
+	return 0;
+
+err_free:
+	percpu_ref_cancel_init(&css->refcnt);
+	ss->css_free(css);
+	return err;
+}
+
 /*
  * cgroup_create - create a cgroup
  * @parent: cgroup that will be parent of the new cgroup
@@ -4396,7 +4458,6 @@ static void offline_css(struct cgroup_subsys_state *css)
 static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 			     umode_t mode)
 {
-	struct cgroup_subsys_state *css = NULL;
 	struct cgroup *cgrp;
 	struct cgroup_name *name;
 	struct cgroupfs_root *root = parent->root;
@@ -4487,47 +4548,9 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 
 	/* let's create and online css's */
 	for_each_root_subsys(root, ss) {
-		css = ss->css_alloc(cgroup_css(parent, ss));
-		if (IS_ERR(css)) {
-			err = PTR_ERR(css);
-			css = NULL;
-			goto err_destroy;
-		}
-
-		err = percpu_ref_init(&css->refcnt, css_release);
-		if (err)
-			goto err_destroy;
-
-		init_css(css, ss, cgrp);
-
-		if (ss->use_id) {
-			err = alloc_css_id(css);
-			if (err)
-				goto err_destroy;
-		}
-
-		err = cgroup_populate_dir(cgrp, 1 << ss->subsys_id);
-		if (err)
-			goto err_destroy;
-
-		err = online_css(css);
+		err = create_css(cgrp, ss);
 		if (err)
 			goto err_destroy;
-
-		dget(dentry);
-		css_get(css->parent);
-
-		/* mark it consumed for error path */
-		css = NULL;
-
-		if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
-		    parent->parent) {
-			pr_warning("cgroup: %s (%d) created nested cgroup for controller \"%s\" which has incomplete hierarchy support. Nested cgroups may change behavior in the future.\n",
-				   current->comm, current->pid, ss->name);
-			if (!strcmp(ss->name, "memory"))
-				pr_warning("cgroup: \"memory\" requires setting use_hierarchy to 1 on the root.\n");
-			ss->warned_broken_hierarchy = true;
-		}
 	}
 
 	mutex_unlock(&cgroup_mutex);
@@ -4548,10 +4571,6 @@ err_free_cgrp:
 	return err;
 
 err_destroy:
-	if (css) {
-		percpu_ref_cancel_init(&css->refcnt);
-		css->ss->css_free(css);
-	}
 	cgroup_destroy_locked(cgrp);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&dentry->d_inode->i_mutex);
-- 
1.8.3.1
