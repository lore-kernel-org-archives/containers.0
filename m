From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 16/17] cgroup: allow ->post_create() to fail
Date: Mon, 12 Nov 2012 19:01:43 -0800
Message-ID: <1352775704-9023-17-git-send-email-tj__38370.2122526758$1352775830$gmane$org@kernel.org>
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

There could be cases where controllers want to do initialization
operations which may fail from ->post_create().  This patch makes
->post_create() return -errno to indicate failure and online_css()
relay such failures.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
---
 include/linux/cgroup.h  |  2 +-
 kernel/cgroup.c         | 29 +++++++++++++++++++----------
 kernel/cgroup_freezer.c |  4 +++-
 3 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index c487315..fb79d7a 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -437,7 +437,7 @@ int cgroup_taskset_size(struct cgroup_taskset *tset);
 
 struct cgroup_subsys {
 	struct cgroup_subsys_state *(*create)(struct cgroup *cgrp);
-	void (*post_create)(struct cgroup *cgrp);
+	int (*post_create)(struct cgroup *cgrp);
 	void (*pre_destroy)(struct cgroup *cgrp);
 	void (*destroy)(struct cgroup *cgrp);
 	int (*can_attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 63d83d0..de97cf2 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4041,14 +4041,18 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 	INIT_WORK(&css->dput_work, css_dput_fn);
 }
 
-/* invoke ->post_create() on a new CSS and mark it online */
-static void online_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
+/* invoke ->post_create() on a new CSS and mark it online if successful */
+static int online_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
 {
+	int ret = 0;
+
 	lockdep_assert_held(&cgroup_mutex);
 
 	if (ss->post_create)
-		ss->post_create(cgrp);
-	cgrp->subsys[ss->subsys_id]->flags |= CSS_ONLINE;
+		ret = ss->post_create(cgrp);
+	if (!ret)
+		cgrp->subsys[ss->subsys_id]->flags |= CSS_ONLINE;
+	return ret;
 }
 
 /* if the CSS is online, invoke ->pre_destory() on it and mark it offline */
@@ -4174,12 +4178,15 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	list_add_tail_rcu(&cgrp->sibling, &cgrp->parent->children);
 	root->number_of_cgroups++;
 
-	for_each_subsys(root, ss) {
-		/* each css holds a ref to the cgroup's dentry */
+	/* each css holds a ref to the cgroup's dentry */
+	for_each_subsys(root, ss)
 		dget(dentry);
 
-		/* creation succeeded, notify subsystems */
-		online_css(ss, cgrp);
+	/* creation succeeded, notify subsystems */
+	for_each_subsys(root, ss) {
+		err = online_css(ss, cgrp);
+		if (err)
+			goto err_destroy;
 	}
 
 	err = cgroup_populate_dir(cgrp, true, root->subsys_mask);
@@ -4393,7 +4400,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	BUG_ON(!list_empty(&init_task.tasks));
 
 	ss->active = 1;
-	online_css(ss, dummytop);
+	BUG_ON(online_css(ss, dummytop));
 
 	mutex_unlock(&cgroup_mutex);
 
@@ -4500,7 +4507,9 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	write_unlock(&css_set_lock);
 
 	ss->active = 1;
-	online_css(ss, dummytop);
+	ret = online_css(ss, dummytop);
+	if (ret)
+		goto err_unload;
 
 	/* success! */
 	mutex_unlock(&cgroup_mutex);
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 670a4af..ee8bb67 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -112,7 +112,7 @@ static struct cgroup_subsys_state *freezer_create(struct cgroup *cgroup)
  * parent's freezing state while holding both parent's and our
  * freezer->lock.
  */
-static void freezer_post_create(struct cgroup *cgroup)
+static int freezer_post_create(struct cgroup *cgroup)
 {
 	struct freezer *freezer = cgroup_freezer(cgroup);
 	struct freezer *parent = parent_freezer(freezer);
@@ -136,6 +136,8 @@ static void freezer_post_create(struct cgroup *cgroup)
 	spin_unlock(&freezer->lock);
 	if (parent)
 		spin_unlock_irq(&parent->lock);
+
+	return 0;
 }
 
 /**
-- 
1.7.11.7
