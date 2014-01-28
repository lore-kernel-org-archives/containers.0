From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/8] cgroup: relocate cgroup_rm_cftypes()
Date: Tue, 28 Jan 2014 18:59:39 -0500
Message-ID: <1390953585-16554-3-git-send-email-tj@kernel.org>
References: <1390953585-16554-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390953585-16554-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

cftype handling is about to be revamped.  Relocate cgroup_rm_cftypes()
above cgroup_add_cftypes() in preparation.  This is pure relocation.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 70 ++++++++++++++++++++++++++++-----------------------------
 1 file changed, 35 insertions(+), 35 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 056bd7d..16eaf82 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2400,6 +2400,41 @@ static int cgroup_init_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
 }
 
 /**
+ * cgroup_rm_cftypes - remove an array of cftypes from a subsystem
+ * @cfts: zero-length name terminated array of cftypes
+ *
+ * Unregister @cfts.  Files described by @cfts are removed from all
+ * existing cgroups and all future cgroups won't have them either.  This
+ * function can be called anytime whether @cfts' subsys is attached or not.
+ *
+ * Returns 0 on successful unregistration, -ENOENT if @cfts is not
+ * registered.
+ */
+int cgroup_rm_cftypes(struct cftype *cfts)
+{
+	struct cftype *found = NULL;
+	struct cftype_set *set;
+
+	if (!cfts || !cfts[0].ss)
+		return -ENOENT;
+
+	cgroup_cfts_prepare();
+
+	list_for_each_entry(set, &cfts[0].ss->cftsets, node) {
+		if (set->cfts == cfts) {
+			list_del(&set->node);
+			kfree(set);
+			found = cfts;
+			break;
+		}
+	}
+
+	cgroup_cfts_commit(found, false);
+	cgroup_exit_cftypes(cfts);
+	return found ? 0 : -ENOENT;
+}
+
+/**
  * cgroup_add_cftypes - add an array of cftypes to a subsystem
  * @ss: target cgroup subsystem
  * @cfts: zero-length name terminated array of cftypes
@@ -2437,41 +2472,6 @@ int cgroup_add_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
 EXPORT_SYMBOL_GPL(cgroup_add_cftypes);
 
 /**
- * cgroup_rm_cftypes - remove an array of cftypes from a subsystem
- * @cfts: zero-length name terminated array of cftypes
- *
- * Unregister @cfts.  Files described by @cfts are removed from all
- * existing cgroups and all future cgroups won't have them either.  This
- * function can be called anytime whether @cfts' subsys is attached or not.
- *
- * Returns 0 on successful unregistration, -ENOENT if @cfts is not
- * registered.
- */
-int cgroup_rm_cftypes(struct cftype *cfts)
-{
-	struct cftype *found = NULL;
-	struct cftype_set *set;
-
-	if (!cfts || !cfts[0].ss)
-		return -ENOENT;
-
-	cgroup_cfts_prepare();
-
-	list_for_each_entry(set, &cfts[0].ss->cftsets, node) {
-		if (set->cfts == cfts) {
-			list_del(&set->node);
-			kfree(set);
-			found = cfts;
-			break;
-		}
-	}
-
-	cgroup_cfts_commit(found, false);
-	cgroup_exit_cftypes(cfts);
-	return found ? 0 : -ENOENT;
-}
-
-/**
  * cgroup_task_count - count the number of tasks in a cgroup.
  * @cgrp: the cgroup in question
  *
-- 
1.8.5.3
