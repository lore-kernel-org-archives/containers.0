From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 9/9] cgroup: don't guarantee cgroup.procs is sorted if
	sane_behavior
Date: Sun, 24 Nov 2013 17:11:36 -0500
Message-ID: <1385331096-7918-10-git-send-email-tj__21551.8121528023$1385331176$gmane$org@kernel.org>
References: <1385331096-7918-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1385331096-7918-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

For some reason, tasks and cgroup.procs guarantee that the result is
sorted.  This is the only reason this whole pidlist logic is necessary
instead of just iterating through sorted member tasks.  We can't do
anything about the existing interface but at least ensure that such
expectation doesn't exist for the new interface so that pidlist logic
may be removed in the distant future.

This patch scrambles the sort order if sane_behavior so that the
output is usually not sorted in the new interface.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  3 +++
 kernel/cgroup.c        | 51 +++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 49 insertions(+), 5 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 5207c28..50d8cc3 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -275,6 +275,9 @@ enum {
 	 * - "tasks" is removed.  Everything should be at process
 	 *   granularity.  Use "cgroup.procs" instead.
 	 *
+	 * - "cgroup.procs" is not sorted.  pids will be unique unless they
+	 *   got recycled inbetween reads.
+	 *
 	 * - "release_agent" and "notify_on_release" are removed.
 	 *   Replacement notification mechanism will be implemented.
 	 *
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5c8cf0b..b848b4f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3562,11 +3562,49 @@ after:
 	return dest;
 }
 
+/*
+ * The two pid files - task and cgroup.procs - guaranteed that the result
+ * is sorted, which forced this whole pidlist fiasco.  As pid order is
+ * different per namespace, each namespace needs differently sorted list,
+ * making it impossible to use, for example, single rbtree of member tasks
+ * sorted by task pointer.  As pidlists can be fairly large, allocating one
+ * per open file is dangerous, so cgroup had to implement shared pool of
+ * pidlists keyed by cgroup and namespace.
+ *
+ * All this extra complexity was caused by the original implementation
+ * committing to an entirely unnecessary property.  In the long term, we
+ * want to do away with it.  Explicitly scramble sort order if
+ * sane_behavior so that no such expectation exists in the new interface.
+ *
+ * Scrambling is done by swapping every two consecutive bits, which is
+ * non-identity one-to-one mapping which disturbs sort order sufficiently.
+ */
+static pid_t pid_fry(pid_t pid)
+{
+	unsigned a = pid & 0x55555555;
+	unsigned b = pid & 0xAAAAAAAA;
+
+	return (a << 1) | (b >> 1);
+}
+
+static pid_t cgroup_pid_fry(struct cgroup *cgrp, pid_t pid)
+{
+	if (cgroup_sane_behavior(cgrp))
+		return pid_fry(pid);
+	else
+		return pid;
+}
+
 static int cmppid(const void *a, const void *b)
 {
 	return *(pid_t *)a - *(pid_t *)b;
 }
 
+static int fried_cmppid(const void *a, const void *b)
+{
+	return pid_fry(*(pid_t *)a) - pid_fry(*(pid_t *)b);
+}
+
 static struct cgroup_pidlist *cgroup_pidlist_find(struct cgroup *cgrp,
 						  enum cgroup_filetype type)
 {
@@ -3654,7 +3692,10 @@ static int pidlist_array_load(struct cgroup *cgrp, enum cgroup_filetype type,
 	css_task_iter_end(&it);
 	length = n;
 	/* now sort & (if procs) strip out duplicates */
-	sort(array, length, sizeof(pid_t), cmppid, NULL);
+	if (cgroup_sane_behavior(cgrp))
+		sort(array, length, sizeof(pid_t), fried_cmppid, NULL);
+	else
+		sort(array, length, sizeof(pid_t), cmppid, NULL);
 	if (type == CGROUP_FILE_PROCS)
 		length = pidlist_uniq(array, length);
 
@@ -3775,10 +3816,10 @@ static void *cgroup_pidlist_start(struct seq_file *s, loff_t *pos)
 
 		while (index < end) {
 			int mid = (index + end) / 2;
-			if (l->list[mid] == pid) {
+			if (cgroup_pid_fry(cgrp, l->list[mid]) == pid) {
 				index = mid;
 				break;
-			} else if (l->list[mid] <= pid)
+			} else if (cgroup_pid_fry(cgrp, l->list[mid]) <= pid)
 				index = mid + 1;
 			else
 				end = mid;
@@ -3789,7 +3830,7 @@ static void *cgroup_pidlist_start(struct seq_file *s, loff_t *pos)
 		return NULL;
 	/* Update the abstract position to be the actual pid that we found */
 	iter = l->list + index;
-	*pos = *iter;
+	*pos = cgroup_pid_fry(cgrp, *iter);
 	return iter;
 }
 
@@ -3818,7 +3859,7 @@ static void *cgroup_pidlist_next(struct seq_file *s, void *v, loff_t *pos)
 	if (p >= end) {
 		return NULL;
 	} else {
-		*pos = *p;
+		*pos = cgroup_pid_fry(of->cgrp, *p);
 		return p;
 	}
 }
-- 
1.8.4.2
