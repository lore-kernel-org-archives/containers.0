From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/14] cgroup: move cgroup->subsys[] assignment to online_css()
Date: Thu,  8 Aug 2013 16:13:45 -0400
Message-ID: <1375992831-4650-9-git-send-email-tj@kernel.org>
References: <1375992831-4650-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375992831-4650-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Currently, css (cgroup_subsys_state) lifetime is tied to that of the
associated cgroup.  With the planned unified hierarchy, css's will be
dynamically created and destroyed within the lifetime of a cgroup.  To
enable such usages, css's will be individually RCU protected instead
of being tied to the cgroup.

In preparation, this patch moves cgroup->subsys[] assignment from
init_css() to online_css().  As this means that a newly initialized
css should be remembered separately and that cgroup_css() returns NULL
between init and online, cgroup_create() is updated so that it stores
newly created css's in a local array css_ar[] and
cgroup_init/load_subsys() are updated to use local variable @css
instead of using cgroup_css().  This change also slightly simplifies
error path of cgroup_create().

While this patch changes when cgroup->subsys[] is initialized, this
change isn't visible to subsystems or userland.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2a93bae..06ba664 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4321,7 +4321,6 @@ static void init_css(struct cgroup_subsys_state *css, struct cgroup_subsys *ss,
 		css->flags |= CSS_ROOT;
 
 	BUG_ON(cgroup_css(cgrp, ss->subsys_id));
-	rcu_assign_pointer(cgrp->subsys[ss->subsys_id], css);
 }
 
 /* invoke ->css_online() on a new CSS and mark it online if successful */
@@ -4334,8 +4333,10 @@ static int online_css(struct cgroup_subsys_state *css)
 
 	if (ss->css_online)
 		ret = ss->css_online(css);
-	if (!ret)
+	if (!ret) {
 		css->flags |= CSS_ONLINE;
+		rcu_assign_pointer(css->cgroup->subsys[ss->subsys_id], css);
+	}
 	return ret;
 }
 
@@ -4366,6 +4367,7 @@ static void offline_css(struct cgroup_subsys_state *css)
 static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 			     umode_t mode)
 {
+	struct cgroup_subsys_state *css_ar[CGROUP_SUBSYS_COUNT] = { };
 	struct cgroup *cgrp;
 	struct cgroup_name *name;
 	struct cgroupfs_root *root = parent->root;
@@ -4433,12 +4435,11 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 			err = PTR_ERR(css);
 			goto err_free_all;
 		}
+		css_ar[ss->subsys_id] = css;
 
 		err = percpu_ref_init(&css->refcnt, css_release);
-		if (err) {
-			ss->css_free(css);
+		if (err)
 			goto err_free_all;
-		}
 
 		init_css(css, ss, cgrp);
 
@@ -4469,7 +4470,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	dget(parent->dentry);
 
 	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
+		struct cgroup_subsys_state *css = css_ar[ss->subsys_id];
 
 		/* each css holds a ref to the cgroup and the parent css */
 		dget(dentry);
@@ -4507,7 +4508,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 
 err_free_all:
 	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
+		struct cgroup_subsys_state *css = css_ar[ss->subsys_id];
 
 		if (css) {
 			percpu_ref_cancel_init(&css->refcnt);
@@ -4789,7 +4790,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	 * need to invoke fork callbacks here. */
 	BUG_ON(!list_empty(&init_task.tasks));
 
-	BUG_ON(online_css(cgroup_css(cgroup_dummy_top, ss->subsys_id)));
+	BUG_ON(online_css(css));
 
 	mutex_unlock(&cgroup_mutex);
 
@@ -4893,7 +4894,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	}
 	write_unlock(&css_set_lock);
 
-	ret = online_css(cgroup_css(cgroup_dummy_top, ss->subsys_id));
+	ret = online_css(css);
 	if (ret)
 		goto err_unload;
 
-- 
1.8.3.1
