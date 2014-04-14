From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 05/12] cgroup: reorganize css_task_iter
Date: Mon, 14 Apr 2014 17:37:03 -0400
Message-ID: <1397511430-2673-6-git-send-email-tj@kernel.org>
References: <1397511430-2673-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1397511430-2673-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

This patch reorganizes css_task_iter so that adding effective css
support is easier.

* s/->cset_link/->cset_pos/ and s/->task/->task_pos/ for consistency

* ->origin_css is used to determine whether the iteration reached the
  last css_set.  Replace it with explicit ->cset_head so that
  css_advance_task_iter() doesn't have to know the termination
  condition directly.

* css_task_iter_next() currently assumes that it's walking list of
  cgrp_cset_link and reaches into the current cset through the current
  link to determine the termination conditions for task walking.  As
  this won't always be true for effective css walking, add
  ->tasks_head and ->mg_tasks_head and use them to control task
  walking so that css_task_iter_next() doesn't have to know how
  css_sets are being walked.

This patch doesn't make any behavior changes.  The iteration logic
stays unchanged after the patch.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  9 ++++++---
 kernel/cgroup.c        | 33 +++++++++++++++++----------------
 2 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 33a0043..bee3905 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -842,9 +842,12 @@ css_next_descendant_post(struct cgroup_subsys_state *pos,
 
 /* A css_task_iter should be treated as an opaque object */
 struct css_task_iter {
-	struct cgroup_subsys_state	*origin_css;
-	struct list_head		*cset_link;
-	struct list_head		*task;
+	struct list_head		*cset_pos;
+	struct list_head		*cset_head;
+
+	struct list_head		*task_pos;
+	struct list_head		*tasks_head;
+	struct list_head		*mg_tasks_head;
 };
 
 void css_task_iter_start(struct cgroup_subsys_state *css,
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f525578..bcf390f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2861,27 +2861,30 @@ css_next_descendant_post(struct cgroup_subsys_state *pos,
  */
 static void css_advance_task_iter(struct css_task_iter *it)
 {
-	struct list_head *l = it->cset_link;
+	struct list_head *l = it->cset_pos;
 	struct cgrp_cset_link *link;
 	struct css_set *cset;
 
 	/* Advance to the next non-empty css_set */
 	do {
 		l = l->next;
-		if (l == &it->origin_css->cgroup->cset_links) {
-			it->cset_link = NULL;
+		if (l == it->cset_head) {
+			it->cset_pos = NULL;
 			return;
 		}
 		link = list_entry(l, struct cgrp_cset_link, cset_link);
 		cset = link->cset;
 	} while (list_empty(&cset->tasks) && list_empty(&cset->mg_tasks));
 
-	it->cset_link = l;
+	it->cset_pos = l;
 
 	if (!list_empty(&cset->tasks))
-		it->task = cset->tasks.next;
+		it->task_pos = cset->tasks.next;
 	else
-		it->task = cset->mg_tasks.next;
+		it->task_pos = cset->mg_tasks.next;
+
+	it->tasks_head = &cset->tasks;
+	it->mg_tasks_head = &cset->mg_tasks;
 }
 
 /**
@@ -2907,8 +2910,8 @@ void css_task_iter_start(struct cgroup_subsys_state *css,
 
 	down_read(&css_set_rwsem);
 
-	it->origin_css = css;
-	it->cset_link = &css->cgroup->cset_links;
+	it->cset_pos = &css->cgroup->cset_links;
+	it->cset_head = it->cset_pos;
 
 	css_advance_task_iter(it);
 }
@@ -2924,12 +2927,10 @@ void css_task_iter_start(struct cgroup_subsys_state *css,
 struct task_struct *css_task_iter_next(struct css_task_iter *it)
 {
 	struct task_struct *res;
-	struct list_head *l = it->task;
-	struct cgrp_cset_link *link = list_entry(it->cset_link,
-					struct cgrp_cset_link, cset_link);
+	struct list_head *l = it->task_pos;
 
 	/* If the iterator cg is NULL, we have no tasks */
-	if (!it->cset_link)
+	if (!it->cset_pos)
 		return NULL;
 	res = list_entry(l, struct task_struct, cg_list);
 
@@ -2940,13 +2941,13 @@ struct task_struct *css_task_iter_next(struct css_task_iter *it)
 	 */
 	l = l->next;
 
-	if (l == &link->cset->tasks)
-		l = link->cset->mg_tasks.next;
+	if (l == it->tasks_head)
+		l = it->mg_tasks_head->next;
 
-	if (l == &link->cset->mg_tasks)
+	if (l == it->mg_tasks_head)
 		css_advance_task_iter(it);
 	else
-		it->task = l;
+		it->task_pos = l;
 
 	return res;
 }
-- 
1.9.0
