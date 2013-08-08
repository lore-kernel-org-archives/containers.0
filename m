From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 13/14] cgroup: move subsys file removal to kill_css()
Date: Thu,  8 Aug 2013 16:13:50 -0400
Message-ID: <1375992831-4650-14-git-send-email-tj__34600.1625330702$1375992965$gmane$org@kernel.org>
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

With the planned unified hierarchy, individual css's will be created
and destroyed dynamically across the lifetime of a cgroup.  To enable
such usages, css destruction is being decoupled from cgroup
destruction.  This patch moves subsys file removal from
cgroup_destroy_locked() to kill_css().

While this changes the order of destruction operations, the changes
shouldn't be noticeable to cgroup subsystems or userland.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index da5f5c2..d99ec53 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4595,13 +4595,15 @@ static void css_killed_ref_fn(struct percpu_ref *ref)
  * kill_css - destroy a css
  * @css: css to destroy
  *
- * This function initiates destruction of @css by putting its base
- * reference.  ->css_offline() will be invoked asynchronously once
- * css_tryget() is guaranteed to fail and when the reference count reaches
- * zero, @css will be released.
+ * This function initiates destruction of @css by removing cgroup interface
+ * files and putting its base reference.  ->css_offline() will be invoked
+ * asynchronously once css_tryget() is guaranteed to fail and when the
+ * reference count reaches zero, @css will be released.
  */
 static void kill_css(struct cgroup_subsys_state *css)
 {
+	cgroup_clear_dir(css->cgroup, 1 << css->ss->subsys_id);
+
 	/*
 	 * Killing would put the base ref, but we need to keep it alive
 	 * until after ->css_offline().
@@ -4699,10 +4701,10 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 		cgroup_destroy_css_killed(cgrp);
 
 	/*
-	 * Clear and remove @cgrp directory.  The removal puts the base ref
-	 * but we aren't quite done with @cgrp yet, so hold onto it.
+	 * Clear the base files and remove @cgrp directory.  The removal
+	 * puts the base ref but we aren't quite done with @cgrp yet, so
+	 * hold onto it.
 	 */
-	cgroup_clear_dir(cgrp, cgrp->root->subsys_mask);
 	cgroup_addrm_files(cgrp, cgroup_base_files, false);
 	dget(d);
 	cgroup_d_remove_dir(d);
-- 
1.8.3.1
