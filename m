From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 12/14] cgroup: factor out kill_css()
Date: Thu,  8 Aug 2013 16:13:49 -0400
Message-ID: <1375992831-4650-13-git-send-email-tj__10037.0639739142$1375992947$gmane$org@kernel.org>
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

Factor out css ref killing from cgroup_destroy_locked() into
kill_css().  We're gonna add more to the path and the factored out
function will eventually be called from other places too.

While at it, replace open coded percpu_ref_get() with css_get() for
consistency.  This shouldn't cause any functional difference as the
function is not used for root cgroups.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 58 ++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 35 insertions(+), 23 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index da2c8e3..da5f5c2 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4592,6 +4592,36 @@ static void css_killed_ref_fn(struct percpu_ref *ref)
 }
 
 /**
+ * kill_css - destroy a css
+ * @css: css to destroy
+ *
+ * This function initiates destruction of @css by putting its base
+ * reference.  ->css_offline() will be invoked asynchronously once
+ * css_tryget() is guaranteed to fail and when the reference count reaches
+ * zero, @css will be released.
+ */
+static void kill_css(struct cgroup_subsys_state *css)
+{
+	/*
+	 * Killing would put the base ref, but we need to keep it alive
+	 * until after ->css_offline().
+	 */
+	css_get(css);
+
+	/*
+	 * cgroup core guarantees that, by the time ->css_offline() is
+	 * invoked, no new css reference will be given out via
+	 * css_tryget().  We can't simply call percpu_ref_kill() and
+	 * proceed to offlining css's because percpu_ref_kill() doesn't
+	 * guarantee that the ref is seen as killed on all CPUs on return.
+	 *
+	 * Use percpu_ref_kill_and_confirm() to get notifications as each
+	 * css is confirmed to be seen as killed on all CPUs.
+	 */
+	percpu_ref_kill_and_confirm(&css->refcnt, css_killed_ref_fn);
+}
+
+/**
  * cgroup_destroy_locked - the first stage of cgroup destruction
  * @cgrp: cgroup to be destroyed
  *
@@ -4637,30 +4667,12 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 		return -EBUSY;
 
 	/*
-	 * Block new css_tryget() by killing css refcnts.  cgroup core
-	 * guarantees that, by the time ->css_offline() is invoked, no new
-	 * css reference will be given out via css_tryget().  We can't
-	 * simply call percpu_ref_kill() and proceed to offlining css's
-	 * because percpu_ref_kill() doesn't guarantee that the ref is seen
-	 * as killed on all CPUs on return.
-	 *
-	 * Use percpu_ref_kill_and_confirm() to get notifications as each
-	 * css is confirmed to be seen as killed on all CPUs.
-	 * cgroup_destroy_css_killed() will be invoked to perform the rest
-	 * of destruction once the percpu refs of all css's are confirmed
-	 * to be killed.
+	 * Initiate massacre of all css's.  cgroup_destroy_css_killed()
+	 * will be invoked to perform the rest of destruction once the
+	 * percpu refs of all css's are confirmed to be killed.
 	 */
-	for_each_root_subsys(cgrp->root, ss) {
-		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
-
-		/*
-		 * Killing would put the base ref, but we need to keep it
-		 * alive until after ->css_offline.
-		 */
-		percpu_ref_get(&css->refcnt);
-
-		percpu_ref_kill_and_confirm(&css->refcnt, css_killed_ref_fn);
-	}
+	for_each_root_subsys(cgrp->root, ss)
+		kill_css(cgroup_css(cgrp, ss->subsys_id));
 
 	/*
 	 * Mark @cgrp dead.  This prevents further task migration and child
-- 
1.8.3.1
