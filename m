From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 7/7] cgroup: update cgroup_transfer_tasks() to either succeed
	or fail
Date: Thu, 13 Feb 2014 15:28:53 -0500
Message-ID: <1392323333-18907-8-git-send-email-tj@kernel.org>
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

cgroup_transfer_tasks() can currently fail in the middle due to memory
allocation failure.  When that happens, the function just aborts and
returns error code and there's no way to tell how many actually got
migrated at the point of failure and or to revert the partial
migration.

Update it to use cgroup_migrate{_add_src|prepare_dst|migrate|finish}()
so that the function either succeeds or fails as a whole as long as
->can_attach() doesn't fail.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 28 +++++++++++++++++++++++-----
 1 file changed, 23 insertions(+), 5 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e373520..1d52885 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2807,10 +2807,28 @@ void css_task_iter_end(struct css_task_iter *it)
  */
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from)
 {
+	LIST_HEAD(preloaded_csets);
+	struct cgrp_cset_link *link;
 	struct css_task_iter it;
 	struct task_struct *task;
-	int ret = 0;
+	int ret;
+
+	mutex_lock(&cgroup_mutex);
+
+	/* all tasks in @from are being moved, all csets are source */
+	down_read(&css_set_rwsem);
+	list_for_each_entry(link, &from->cset_links, cset_link)
+		cgroup_migrate_add_src(link->cset, to, &preloaded_csets);
+	up_read(&css_set_rwsem);
 
+	ret = cgroup_migrate_prepare_dst(to, &preloaded_csets);
+	if (ret)
+		goto out_err;
+
+	/*
+	 * Migrate tasks one-by-one until @form is empty.  This fails iff
+	 * ->can_attach() fails.
+	 */
 	do {
 		css_task_iter_start(&from->dummy_css, &it);
 		task = css_task_iter_next(&it);
@@ -2819,13 +2837,13 @@ int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from)
 		css_task_iter_end(&it);
 
 		if (task) {
-			mutex_lock(&cgroup_mutex);
-			ret = cgroup_attach_task(to, task, false);
-			mutex_unlock(&cgroup_mutex);
+			ret = cgroup_migrate(to, task, false);
 			put_task_struct(task);
 		}
 	} while (task && !ret);
-
+out_err:
+	cgroup_migrate_finish(&preloaded_csets);
+	mutex_unlock(&cgroup_mutex);
 	return ret;
 }
 
-- 
1.8.5.3
