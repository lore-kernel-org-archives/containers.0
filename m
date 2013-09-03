From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 8/9] cgroup: implement for_each_css()
Date: Tue, 3 Sep 2013 16:54:26 -0400
Message-ID: <20130903205426.GG27092@mtj.dyndns.org>
References: <1377723829-22814-1-git-send-email-tj@kernel.org>
	<1377723829-22814-9-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1377723829-22814-9-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

There are enough places where css's of a cgroup are iterated, which
currently uses for_each_root_subsys() + explicit cgroup_css().  This
patch implements for_each_css() and replaces the above combination
with it.

This patch doesn't introduce any behavior changes.

v2: Updated to apply cleanly on top of v2 of "cgroup: fix css leaks on
    online_css() failure"

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c |   57 ++++++++++++++++++++++++++++++--------------------------
 1 file changed, 31 insertions(+), 26 deletions(-)

--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -297,6 +297,21 @@ static int notify_on_release(const struc
 }
 
 /**
+ * for_each_css - iterate all css's of a cgroup
+ * @css: the iteration cursor
+ * @ssid: the index of the subsystem, CGROUP_SUBSYS_COUNT after reaching the end
+ * @cgrp: the target cgroup to iterate css's of
+ *
+ * Should be called under cgroup_mutex.
+ */
+#define for_each_css(css, ssid, cgrp)					\
+	for ((ssid) = 0; (ssid) < CGROUP_SUBSYS_COUNT; (ssid)++)	\
+		if (!((css) = rcu_dereference_check(			\
+				(cgrp)->subsys[(ssid)],			\
+				lockdep_is_held(&cgroup_mutex)))) { }	\
+		else
+
+/**
  * for_each_subsys - iterate all loaded cgroup subsystems
  * @ss: the iteration cursor
  * @ssid: the index of @ss, CGROUP_SUBSYS_COUNT after reaching the end
@@ -2013,8 +2028,8 @@ static int cgroup_attach_task(struct cgr
 			      bool threadgroup)
 {
 	int retval, i, group_size;
-	struct cgroup_subsys *ss, *failed_ss = NULL;
 	struct cgroupfs_root *root = cgrp->root;
+	struct cgroup_subsys_state *css, *failed_css = NULL;
 	/* threadgroup list cursor and array */
 	struct task_struct *leader = tsk;
 	struct task_and_cgroup *tc;
@@ -2087,13 +2102,11 @@ static int cgroup_attach_task(struct cgr
 	/*
 	 * step 1: check that we can legitimately attach to the cgroup.
 	 */
-	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss);
-
-		if (ss->can_attach) {
-			retval = ss->can_attach(css, &tset);
+	for_each_css(css, i, cgrp) {
+		if (css->ss->can_attach) {
+			retval = css->ss->can_attach(css, &tset);
 			if (retval) {
-				failed_ss = ss;
+				failed_css = css;
 				goto out_cancel_attach;
 			}
 		}
@@ -2129,12 +2142,9 @@ static int cgroup_attach_task(struct cgr
 	/*
 	 * step 4: do subsystem attach callbacks.
 	 */
-	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss);
-
-		if (ss->attach)
-			ss->attach(css, &tset);
-	}
+	for_each_css(css, i, cgrp)
+		if (css->ss->attach)
+			css->ss->attach(css, &tset);
 
 	/*
 	 * step 5: success! and cleanup
@@ -2151,13 +2161,11 @@ out_put_css_set_refs:
 	}
 out_cancel_attach:
 	if (retval) {
-		for_each_root_subsys(root, ss) {
-			struct cgroup_subsys_state *css = cgroup_css(cgrp, ss);
-
-			if (ss == failed_ss)
+		for_each_css(css, i, cgrp) {
+			if (css == failed_css)
 				break;
-			if (ss->cancel_attach)
-				ss->cancel_attach(css, &tset);
+			if (css->ss->cancel_attach)
+				css->ss->cancel_attach(css, &tset);
 		}
 	}
 out_free_group_list:
@@ -4700,8 +4708,9 @@ static int cgroup_destroy_locked(struct
 {
 	struct dentry *d = cgrp->dentry;
 	struct cgroup_event *event, *tmp;
-	struct cgroup_subsys *ss;
+	struct cgroup_subsys_state *css;
 	bool empty;
+	int ssid;
 
 	lockdep_assert_held(&d->d_inode->i_mutex);
 	lockdep_assert_held(&cgroup_mutex);
@@ -4721,12 +4730,8 @@ static int cgroup_destroy_locked(struct
 	 * will be invoked to perform the rest of destruction once the
 	 * percpu refs of all css's are confirmed to be killed.
 	 */
-	for_each_root_subsys(cgrp->root, ss) {
-		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss);
-
-		if (css)
-			kill_css(css);
-	}
+	for_each_css(css, ssid, cgrp)
+		kill_css(css);
 
 	/*
 	 * Mark @cgrp dead.  This prevents further task migration and child
