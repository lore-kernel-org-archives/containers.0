From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 11/14] cgroup: decouple cgroup_subsys_state destruction from
	cgroup destruction
Date: Thu,  8 Aug 2013 16:13:48 -0400
Message-ID: <1375992831-4650-12-git-send-email-tj@kernel.org>
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
associated cgroup.  css's are created when the associated cgroup is
created and destroyed when it gets destroyed.  Also, individual css's
aren't RCU protected but the whole cgroup is.  With the planned
unified hierarchy, css's will need to be dynamically created and
destroyed within the lifetime of a cgroup.

To enable such usages, this patch decouples css destruction from
cgroup destruction - offline_css() invocation and the final css_put()
are moved from cgroup_destroy_css_killed() to css_killed_work_fn().
Now each css is individually offlined and put as its reference count
is killed instead of waiting for all css's attached to the cgroup to
finish refcnt killing and then proceeding to offlining and putting
them together.

While this changes the order of destruction operations, the changes
shouldn't be noticeable to cgroup subsystems or userland.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  2 +-
 kernel/cgroup.c        | 52 +++++++++++++++++++++++---------------------------
 2 files changed, 25 insertions(+), 29 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 80dca87..71e77e7 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -82,7 +82,7 @@ struct cgroup_subsys_state {
 	/* ID for this css, if possible */
 	struct css_id __rcu *id;
 
-	/* Used to put @cgroup->dentry on the last css_put() */
+	/* percpu_ref killing and putting dentry on the last css_put() */
 	struct work_struct destroy_work;
 };
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 484af35..da2c8e3 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4355,6 +4355,7 @@ static void offline_css(struct cgroup_subsys_state *css)
 		ss->css_offline(css);
 
 	css->flags &= ~CSS_ONLINE;
+	css->cgroup->nr_css--;
 }
 
 /*
@@ -4555,14 +4556,29 @@ static void css_killed_work_fn(struct work_struct *work)
 	mutex_lock(&cgroup_mutex);
 
 	/*
+	 * css_tryget() is guaranteed to fail now.  Tell subsystems to
+	 * initate destruction.
+	 */
+	offline_css(css);
+
+	/*
 	 * If @cgrp is marked dead, it's waiting for refs of all css's to
 	 * be disabled before proceeding to the second phase of cgroup
 	 * destruction.  If we are the last one, kick it off.
 	 */
-	if (!--cgrp->nr_css && cgroup_is_dead(cgrp))
+	if (!cgrp->nr_css && cgroup_is_dead(cgrp))
 		cgroup_destroy_css_killed(cgrp);
 
 	mutex_unlock(&cgroup_mutex);
+
+	/*
+	 * Put the css refs from kill_css().  Each css holds an extra
+	 * reference to the cgroup's dentry and cgroup removal proceeds
+	 * regardless of css refs.  On the last put of each css, whenever
+	 * that may be, the extra dentry ref is put so that dentry
+	 * destruction happens only after all css's are released.
+	 */
+	css_put(css);
 }
 
 /* css kill confirmation processing requires process context, bounce */
@@ -4629,11 +4645,10 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	 * as killed on all CPUs on return.
 	 *
 	 * Use percpu_ref_kill_and_confirm() to get notifications as each
-	 * css is confirmed to be seen as killed on all CPUs.  The
-	 * notification callback keeps track of the number of css's to be
-	 * killed and invokes cgroup_destroy_css_killed() to perform the
-	 * rest of destruction once the percpu refs of all css's are
-	 * confirmed to be killed.
+	 * css is confirmed to be seen as killed on all CPUs.
+	 * cgroup_destroy_css_killed() will be invoked to perform the rest
+	 * of destruction once the percpu refs of all css's are confirmed
+	 * to be killed.
 	 */
 	for_each_root_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
@@ -4700,36 +4715,17 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
  * @work: cgroup->destroy_free_work
  *
  * This function is invoked from a work item for a cgroup which is being
- * destroyed after the percpu refcnts of all css's are guaranteed to be
- * seen as killed on all CPUs, and performs the rest of destruction.  This
- * is the second step of destruction described in the comment above
- * cgroup_destroy_locked().
+ * destroyed after all css's are offlined and performs the rest of
+ * destruction.  This is the second step of destruction described in the
+ * comment above cgroup_destroy_locked().
  */
 static void cgroup_destroy_css_killed(struct cgroup *cgrp)
 {
 	struct cgroup *parent = cgrp->parent;
 	struct dentry *d = cgrp->dentry;
-	struct cgroup_subsys *ss;
 
 	lockdep_assert_held(&cgroup_mutex);
 
-	/*
-	 * css_tryget() is guaranteed to fail now.  Tell subsystems to
-	 * initate destruction.
-	 */
-	for_each_root_subsys(cgrp->root, ss)
-		offline_css(cgroup_css(cgrp, ss->subsys_id));
-
-	/*
-	 * Put the css refs from cgroup_destroy_locked().  Each css holds
-	 * an extra reference to the cgroup's dentry and cgroup removal
-	 * proceeds regardless of css refs.  On the last put of each css,
-	 * whenever that may be, the extra dentry ref is put so that dentry
-	 * destruction happens only after all css's are released.
-	 */
-	for_each_root_subsys(cgrp->root, ss)
-		css_put(cgroup_css(cgrp, ss->subsys_id));
-
 	/* delete this cgroup from parent->children */
 	list_del_rcu(&cgrp->sibling);
 
-- 
1.8.3.1
