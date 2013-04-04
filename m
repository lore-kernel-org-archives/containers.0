From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/5] cgroup: relocate cgroup_lock_live_group() and
	cgroup_attach_task_all()
Date: Thu,  4 Apr 2013 16:36:26 -0700
Message-ID: <1365118589-10619-3-git-send-email-tj@kernel.org>
References: <1365118589-10619-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1365118589-10619-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

cgroup_lock_live_group() and cgroup_attach_task() are scheduled to be
made static.  Relocate the former and cgroup_attach_task_all() so that
we don't need forward declarations.

This patch is pure relocation.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 84 ++++++++++++++++++++++++++++-----------------------------
 1 file changed, 42 insertions(+), 42 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 147d7cc..ae76170 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -329,6 +329,24 @@ static inline struct cftype *__d_cft(struct dentry *dentry)
 	return __d_cfe(dentry)->type;
 }
 
+/**
+ * cgroup_lock_live_group - take cgroup_mutex and check that cgrp is alive.
+ * @cgrp: the cgroup to be checked for liveness
+ *
+ * On success, returns true; the lock should be later released with
+ * cgroup_unlock(). On failure returns false with no lock held.
+ */
+bool cgroup_lock_live_group(struct cgroup *cgrp)
+{
+	mutex_lock(&cgroup_mutex);
+	if (cgroup_is_removed(cgrp)) {
+		mutex_unlock(&cgroup_mutex);
+		return false;
+	}
+	return true;
+}
+EXPORT_SYMBOL_GPL(cgroup_lock_live_group);
+
 /* the list of cgroups eligible for automatic release. Protected by
  * release_list_lock */
 static LIST_HEAD(release_list);
@@ -1944,30 +1962,6 @@ static void cgroup_task_migrate(struct cgroup *oldcgrp,
 }
 
 /**
- * cgroup_attach_task_all - attach task 'tsk' to all cgroups of task 'from'
- * @from: attach to all cgroups of a given task
- * @tsk: the task to be attached
- */
-int cgroup_attach_task_all(struct task_struct *from, struct task_struct *tsk)
-{
-	struct cgroupfs_root *root;
-	int retval = 0;
-
-	cgroup_lock();
-	for_each_active_root(root) {
-		struct cgroup *from_cg = task_cgroup_from_root(from, root);
-
-		retval = cgroup_attach_task(from_cg, tsk, false);
-		if (retval)
-			break;
-	}
-	cgroup_unlock();
-
-	return retval;
-}
-EXPORT_SYMBOL_GPL(cgroup_attach_task_all);
-
-/**
  * cgroup_attach_task - attach a task or a whole threadgroup to a cgroup
  * @cgrp: the cgroup to attach to
  * @tsk: the task or the leader of the threadgroup to be attached
@@ -2204,6 +2198,30 @@ out_unlock_cgroup:
 	return ret;
 }
 
+/**
+ * cgroup_attach_task_all - attach task 'tsk' to all cgroups of task 'from'
+ * @from: attach to all cgroups of a given task
+ * @tsk: the task to be attached
+ */
+int cgroup_attach_task_all(struct task_struct *from, struct task_struct *tsk)
+{
+	struct cgroupfs_root *root;
+	int retval = 0;
+
+	cgroup_lock();
+	for_each_active_root(root) {
+		struct cgroup *from_cg = task_cgroup_from_root(from, root);
+
+		retval = cgroup_attach_task(from_cg, tsk, false);
+		if (retval)
+			break;
+	}
+	cgroup_unlock();
+
+	return retval;
+}
+EXPORT_SYMBOL_GPL(cgroup_attach_task_all);
+
 static int cgroup_tasks_write(struct cgroup *cgrp, struct cftype *cft, u64 pid)
 {
 	return attach_task_by_pid(cgrp, pid, false);
@@ -2214,24 +2232,6 @@ static int cgroup_procs_write(struct cgroup *cgrp, struct cftype *cft, u64 tgid)
 	return attach_task_by_pid(cgrp, tgid, true);
 }
 
-/**
- * cgroup_lock_live_group - take cgroup_mutex and check that cgrp is alive.
- * @cgrp: the cgroup to be checked for liveness
- *
- * On success, returns true; the lock should be later released with
- * cgroup_unlock(). On failure returns false with no lock held.
- */
-bool cgroup_lock_live_group(struct cgroup *cgrp)
-{
-	mutex_lock(&cgroup_mutex);
-	if (cgroup_is_removed(cgrp)) {
-		mutex_unlock(&cgroup_mutex);
-		return false;
-	}
-	return true;
-}
-EXPORT_SYMBOL_GPL(cgroup_lock_live_group);
-
 static int cgroup_release_agent_write(struct cgroup *cgrp, struct cftype *cft,
 				      const char *buffer)
 {
-- 
1.8.1.4
