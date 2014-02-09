From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/16] cgroup: reimplement cgroup_transfer_tasks() without
	using css_scan_tasks()
Date: Sun,  9 Feb 2014 08:52:34 -0500
Message-ID: <1391953964-22088-7-git-send-email-tj@kernel.org>
References: <1391953964-22088-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391953964-22088-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Reimplement cgroup_transfer_tasks() so that it repeatedly fetches the
first task in the cgroup and then tranfers it.  This achieves the same
result without using css_scan_tasks() which is scheduled to be
removed.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 31 ++++++++++++++++++++-----------
 1 file changed, 20 insertions(+), 11 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 96a3a85..a5f965c 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2849,15 +2849,6 @@ int css_scan_tasks(struct cgroup_subsys_state *css,
 	return 0;
 }
 
-static void cgroup_transfer_one_task(struct task_struct *task, void *data)
-{
-	struct cgroup *new_cgroup = data;
-
-	mutex_lock(&cgroup_mutex);
-	cgroup_attach_task(new_cgroup, task, false);
-	mutex_unlock(&cgroup_mutex);
-}
-
 /**
  * cgroup_trasnsfer_tasks - move tasks from one cgroup to another
  * @to: cgroup to which the tasks will be moved
@@ -2865,8 +2856,26 @@ static void cgroup_transfer_one_task(struct task_struct *task, void *data)
  */
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from)
 {
-	return css_scan_tasks(&from->dummy_css, NULL, cgroup_transfer_one_task,
-			      to, NULL);
+	struct css_task_iter it;
+	struct task_struct *task;
+	int ret = 0;
+
+	do {
+		css_task_iter_start(&from->dummy_css, &it);
+		task = css_task_iter_next(&it);
+		if (task)
+			get_task_struct(task);
+		css_task_iter_end(&it);
+
+		if (task) {
+			mutex_lock(&cgroup_mutex);
+			ret = cgroup_attach_task(to, task, false);
+			mutex_unlock(&cgroup_mutex);
+			put_task_struct(task);
+		}
+	} while (task && !ret);
+
+	return ret;
 }
 
 /*
-- 
1.8.5.3
