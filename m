From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/7] freezer: add missing mb's to freezer_count() and
	freezer_should_skip()
Date: Tue, 16 Oct 2012 15:28:41 -0700
Message-ID: <1350426526-14254-3-git-send-email-tj@kernel.org>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1350426526-14254-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: rjw-KKrjLPT3xs0@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

A task is considered frozen enough between freezer_do_not_count() and
freezer_count() and freezers use freezer_should_skip() to test this
condition.  This supposedly works because freezer_count() always calls
try_to_freezer() after clearing %PF_FREEZER_SKIP.

However, there currently is nothing which guarantees that
freezer_count() sees %true freezing() after clearing %PF_FREEZER_SKIP
when freezing is in progress, and vice-versa.  A task can escape the
freezing condition in effect by freezer_count() seeing !freezing() and
freezer_should_skip() seeing %PF_FREEZER_SKIP.

This patch adds smp_mb()'s to freezer_count() and
freezer_should_skip() such that either %true freezing() is visible to
freezer_count() or !PF_FREEZER_SKIP is visible to
freezer_should_skip().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 include/linux/freezer.h |   50 +++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 42 insertions(+), 8 deletions(-)

diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index d09af4b..ee89932 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -75,28 +75,62 @@ static inline bool cgroup_freezing(struct task_struct *task)
  */
 
 
-/* Tell the freezer not to count the current task as freezable. */
+/**
+ * freezer_do_not_count - tell freezer to ignore %current
+ *
+ * Tell freezers to ignore the current task when determining whether the
+ * target frozen state is reached.  IOW, the current task will be
+ * considered frozen enough by freezers.
+ *
+ * The caller shouldn't do anything which isn't allowed for a frozen task
+ * until freezer_cont() is called.  Usually, freezer[_do_not]_count() pair
+ * wrap a scheduling operation and nothing much else.
+ */
 static inline void freezer_do_not_count(void)
 {
 	current->flags |= PF_FREEZER_SKIP;
 }
 
-/*
- * Tell the freezer to count the current task as freezable again and try to
- * freeze it.
+/**
+ * freezer_count - tell freezer to stop ignoring %current
+ *
+ * Undo freezer_do_not_count().  It tells freezers that %current should be
+ * considered again and tries to freeze if freezing condition is already in
+ * effect.
  */
 static inline void freezer_count(void)
 {
 	current->flags &= ~PF_FREEZER_SKIP;
+	/*
+	 * If freezing is in progress, the following paired with smp_mb()
+	 * in freezer_should_skip() ensures that either we see %true
+	 * freezing() or freezer_should_skip() sees !PF_FREEZER_SKIP.
+	 */
+	smp_mb();
 	try_to_freeze();
 }
 
-/*
- * Check if the task should be counted as freezable by the freezer
+/**
+ * freezer_should_skip - whether to skip a task when determining frozen
+ *			 state is reached
+ * @p: task in quesion
+ *
+ * This function is used by freezers after establishing %true freezing() to
+ * test whether a task should be skipped when determining the target frozen
+ * state is reached.  IOW, if this function returns %true, @p is considered
+ * frozen enough.
  */
-static inline int freezer_should_skip(struct task_struct *p)
+static inline bool freezer_should_skip(struct task_struct *p)
 {
-	return !!(p->flags & PF_FREEZER_SKIP);
+	/*
+	 * The following smp_mb() paired with the one in freezer_count()
+	 * ensures that either freezer_count() sees %true freezing() or we
+	 * see cleared %PF_FREEZER_SKIP and return %false.  This makes it
+	 * impossible for a task to slip frozen state testing after
+	 * clearing %PF_FREEZER_SKIP.
+	 */
+	smp_mb();
+	return p->flags & PF_FREEZER_SKIP;
 }
 
 /*
-- 
1.7.7.3
