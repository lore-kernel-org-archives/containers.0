From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 12/17] cgroup: introduce CSS_ONLINE flag and on/offline_css()
	helpers
Date: Mon, 12 Nov 2012 19:01:39 -0800
Message-ID: <1352775704-9023-13-git-send-email-tj__11299.1538168446$1352775806$gmane$org@kernel.org>
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

New helpers on/offline_css() respectively wrap ->post_create() and
->pre_destroy() invocations.  online_css() sets CSS_ONLINE after
->post_create() is complete and offline_css() invokes ->pre_destroy()
iff CSS_ONLINE is set and clears it while also handling the temporary
dropping of cgroup_mutex.

This patch doesn't introduce any behavior change at the moment but
will be used to improve cgroup_create() failure path and allow
->post_create() to fail.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  1 +
 kernel/cgroup.c        | 65 ++++++++++++++++++++++++++++++++------------------
 2 files changed, 43 insertions(+), 23 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index e9f07ef..c487315 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -82,6 +82,7 @@ struct cgroup_subsys_state {
 /* bits in struct cgroup_subsys_state flags field */
 enum {
 	CSS_ROOT	= (1 << 0), /* this CSS is the root of the subsystem */
+	CSS_ONLINE	= (1 << 1), /* between ->post_create() and ->pre_destroy() */
 };
 
 /* Caller must verify that the css is not for root cgroup */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index afc47d6..c3087f5 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4035,6 +4035,42 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 	INIT_WORK(&css->dput_work, css_dput_fn);
 }
 
+/* invoke ->post_create() on a new CSS and mark it online */
+static void online_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	lockdep_assert_held(&cgroup_mutex);
+
+	if (ss->post_create)
+		ss->post_create(cgrp);
+	cgrp->subsys[ss->subsys_id]->flags |= CSS_ONLINE;
+}
+
+/* if the CSS is online, invoke ->pre_destory() on it and mark it offline */
+static void offline_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
+	__releases(&cgroup_mutex) __acquires(&cgroup_mutex)
+{
+	struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+
+	lockdep_assert_held(&cgroup_mutex);
+
+	if (!(css->flags & CSS_ONLINE))
+		return;
+
+	/*
+	 * pre_destroy() should be called with cgroup_mutex unlocked.  See
+	 * 3fa59dfbc3 ("cgroup: fix potential deadlock in pre_destroy") for
+	 * details.  This temporary unlocking should go away once
+	 * cgroup_mutex is unexported from controllers.
+	 */
+	if (ss->pre_destroy) {
+		mutex_unlock(&cgroup_mutex);
+		ss->pre_destroy(cgrp);
+		mutex_lock(&cgroup_mutex);
+	}
+
+	cgrp->subsys[ss->subsys_id]->flags &= ~CSS_ONLINE;
+}
+
 /*
  * cgroup_create - create a cgroup
  * @parent: cgroup that will be parent of the new cgroup
@@ -4137,8 +4173,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		dget(dentry);
 
 		/* creation succeeded, notify subsystems */
-		if (ss->post_create)
-			ss->post_create(cgrp);
+		online_css(ss, cgrp);
 	}
 
 	err = cgroup_populate_dir(cgrp, true, root->subsys_mask);
@@ -4240,18 +4275,9 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	}
 	set_bit(CGRP_REMOVED, &cgrp->flags);
 
-	/*
-	 * Tell subsystems to initate destruction.  pre_destroy() should be
-	 * called with cgroup_mutex unlocked.  See 3fa59dfbc3 ("cgroup: fix
-	 * potential deadlock in pre_destroy") for details.  This temporary
-	 * unlocking should go away once cgroup_mutex is unexported from
-	 * controllers.
-	 */
-	mutex_unlock(&cgroup_mutex);
+	/* tell subsystems to initate destruction */
 	for_each_subsys(cgrp->root, ss)
-		if (ss->pre_destroy)
-			ss->pre_destroy(cgrp);
-	mutex_lock(&cgroup_mutex);
+		offline_css(ss, cgrp);
 
 	/*
 	 * Put all the base refs.  Each css holds an extra reference to the
@@ -4354,9 +4380,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	BUG_ON(!list_empty(&init_task.tasks));
 
 	ss->active = 1;
-
-	if (ss->post_create)
-		ss->post_create(dummytop);
+	online_css(ss, dummytop);
 
 	mutex_unlock(&cgroup_mutex);
 
@@ -4469,9 +4493,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	write_unlock(&css_set_lock);
 
 	ss->active = 1;
-
-	if (ss->post_create)
-		ss->post_create(dummytop);
+	online_css(ss, dummytop);
 
 	/* success! */
 	mutex_unlock(&cgroup_mutex);
@@ -4501,12 +4523,9 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	 */
 	BUG_ON(ss->root != &rootnode);
 
-	/* ->pre_destroy() should be called outside cgroup_mutex for now */
-	if (ss->pre_destroy)
-		ss->pre_destroy(dummytop);
-
 	mutex_lock(&cgroup_mutex);
 
+	offline_css(ss, dummytop);
 	ss->active = 0;
 
 	if (ss->use_id) {
-- 
1.7.11.7
