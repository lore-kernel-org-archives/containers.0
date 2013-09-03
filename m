From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 1/9] cgroup: fix css leaks on online_css() failure
Date: Tue, 3 Sep 2013 16:51:54 -0400
Message-ID: <20130903205154.GF27092@mtj.dyndns.org>
References: <1377723829-22814-1-git-send-email-tj@kernel.org>
	<1377723829-22814-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1377723829-22814-2-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Okay, re-sequencing the for_each_css patch turns out to be a lot more
headache than expected.  Let's just fix it up in this patch proper.
It's a standalone bug fix anyway.  The change only affects the
for_each_css() patch later.  Will post an updated version of that
patch too soon.

Thanks.
----- 8< -----
ae7f164a09 ("cgroup: move cgroup->subsys[] assignment to
online_css()") moved cgroup->subsys[] assignements later in
cgroup_create() but didn't update error handling path accordingly
leaking later css's after an online_css() failure.

This patch moves reference bumping inside online_css() loop, clears
css_ar[] as css's are brought online successfully, and updates
err_destroy path so that either a css is fully online and destroyed by
cgroup_destroy_locked() or the error path frees it.  This creates a
duplicate css free logic in the error path but it will be cleaned up
soon.

v2: Li pointed out that cgroup_destroy_locked() would do NULL-deref if
    invoked with a cgroup which doesn't have all css's populated.
    Update cgroup_destroy_locked() so that it skips NULL css's.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c |   31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4489,14 +4489,6 @@ static long cgroup_create(struct cgroup
 	list_add_tail_rcu(&cgrp->sibling, &cgrp->parent->children);
 	root->number_of_cgroups++;
 
-	/* each css holds a ref to the cgroup's dentry and the parent css */
-	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css = css_ar[ss->subsys_id];
-
-		dget(dentry);
-		css_get(css->parent);
-	}
-
 	/* hold a ref to the parent's dentry */
 	dget(parent->dentry);
 
@@ -4508,6 +4500,13 @@ static long cgroup_create(struct cgroup
 		if (err)
 			goto err_destroy;
 
+		/* each css holds a ref to the cgroup's dentry and parent css */
+		dget(dentry);
+		css_get(css->parent);
+
+		/* mark it consumed for error path */
+		css_ar[ss->subsys_id] = NULL;
+
 		if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
 		    parent->parent) {
 			pr_warning("cgroup: %s (%d) created nested cgroup for controller \"%s\" which has incomplete hierarchy support. Nested cgroups may change behavior in the future.\n",
@@ -4554,6 +4553,14 @@ err_free_cgrp:
 	return err;
 
 err_destroy:
+	for_each_root_subsys(root, ss) {
+		struct cgroup_subsys_state *css = css_ar[ss->subsys_id];
+
+		if (css) {
+			percpu_ref_cancel_init(&css->refcnt);
+			ss->css_free(css);
+		}
+	}
 	cgroup_destroy_locked(cgrp);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&dentry->d_inode->i_mutex);
@@ -4698,8 +4705,12 @@ static int cgroup_destroy_locked(struct
 	 * will be invoked to perform the rest of destruction once the
 	 * percpu refs of all css's are confirmed to be killed.
 	 */
-	for_each_root_subsys(cgrp->root, ss)
-		kill_css(cgroup_css(cgrp, ss));
+	for_each_root_subsys(cgrp->root, ss) {
+		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss);
+
+		if (css)
+			kill_css(css);
+	}
 
 	/*
 	 * Mark @cgrp dead.  This prevents further task migration and child
