From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 6/7] cgroup: implement for_each_css()
Date: Fri,  6 Dec 2013 15:27:51 -0500
Message-ID: <1386361672-27791-7-git-send-email-tj__16614.8355966017$1386361727$gmane$org@kernel.org>
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

There are enough places where css's of a cgroup are iterated, which
currently uses for_each_root_subsys() + explicit cgroup_css().  This
patch implements for_each_css() and replaces the above combination
with it.

This patch doesn't introduce any behavior changes.

v2: Updated to apply cleanly on top of v2 of "cgroup: fix css leaks on
    online_css() failure"

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c | 57 +++++++++++++++++++++++++++++++--------------------------
 1 file changed, 31 insertions(+), 26 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index d12c29f..329fde8 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -243,6 +243,21 @@ static int notify_on_release(const struct cgroup *cgrp)
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
@@ -1942,8 +1957,8 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
 			      bool threadgroup)
 {
 	int retval, i, group_size;
-	struct cgroup_subsys *ss, *failed_ss = NULL;
 	struct cgroupfs_root *root = cgrp->root;
+	struct cgroup_subsys_state *css, *failed_css = NULL;
 	/* threadgroup list cursor and array */
 	struct task_struct *leader = tsk;
 	struct task_and_cgroup *tc;
@@ -2016,13 +2031,11 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
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
@@ -2058,12 +2071,9 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
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
@@ -2080,13 +2090,11 @@ out_put_css_set_refs:
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
@@ -4375,9 +4383,10 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	__releases(&cgroup_mutex) __acquires(&cgroup_mutex)
 {
 	struct dentry *d = cgrp->dentry;
-	struct cgroup_subsys *ss;
+	struct cgroup_subsys_state *css;
 	struct cgroup *child;
 	bool empty;
+	int ssid;
 
 	lockdep_assert_held(&d->d_inode->i_mutex);
 	lockdep_assert_held(&cgroup_mutex);
@@ -4413,12 +4422,8 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
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
-- 
1.8.4.2
