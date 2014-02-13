From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/7] cgroup: separate out cset_group_from_root() from
	task_cgroup_from_root()
Date: Thu, 13 Feb 2014 15:28:49 -0500
Message-ID: <1392323333-18907-4-git-send-email-tj@kernel.org>
References: <1392323333-18907-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1392323333-18907-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

This will be used by the planned migration path update.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 539758c..cc35a20 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -758,25 +758,15 @@ static void cgroup_destroy_root(struct cgroupfs_root *root)
 	cgroup_free_root(root);
 }
 
-/*
- * Return the cgroup for "task" from the given hierarchy. Must be
- * called with cgroup_mutex and css_set_rwsem held.
- */
-static struct cgroup *task_cgroup_from_root(struct task_struct *task,
+/* look up cgroup associated with given css_set on the specified hierarchy */
+static struct cgroup *cset_cgroup_from_root(struct css_set *cset,
 					    struct cgroupfs_root *root)
 {
-	struct css_set *cset;
 	struct cgroup *res = NULL;
 
 	lockdep_assert_held(&cgroup_mutex);
 	lockdep_assert_held(&css_set_rwsem);
 
-	/*
-	 * No need to lock the task - since we hold cgroup_mutex the
-	 * task can't change groups, so the only thing that can happen
-	 * is that it exits and its css is set back to init_css_set.
-	 */
-	cset = task_css_set(task);
 	if (cset == &init_css_set) {
 		res = &root->top_cgroup;
 	} else {
@@ -797,6 +787,21 @@ static struct cgroup *task_cgroup_from_root(struct task_struct *task,
 }
 
 /*
+ * Return the cgroup for "task" from the given hierarchy. Must be
+ * called with cgroup_mutex and css_set_rwsem held.
+ */
+static struct cgroup *task_cgroup_from_root(struct task_struct *task,
+					    struct cgroupfs_root *root)
+{
+	/*
+	 * No need to lock the task - since we hold cgroup_mutex the
+	 * task can't change groups, so the only thing that can happen
+	 * is that it exits and its css is set back to init_css_set.
+	 */
+	return cset_cgroup_from_root(task_css_set(task), root);
+}
+
+/*
  * There is one global cgroup mutex. We also require taking
  * task_lock() when dereferencing a task's cgroup subsys pointers.
  * See "The task_lock() exception", at the end of this comment.
-- 
1.8.5.3
