From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 1/2] c/r: fix task tree traversal for threads
Date: Sun, 11 Jul 2010 22:05:21 -0400
Message-ID: <1278900322-15287-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch fixes the logic of walk_task_subtree() to correctly account
for all threads (and not only threads of the tree root).

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Tested-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/checkpoint/sys.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
index 5e6994e..171c867 100644
--- a/kernel/checkpoint/sys.c
+++ b/kernel/checkpoint/sys.c
@@ -565,7 +565,10 @@ EXPORT_SYMBOL(do_ckpt_msg);
  *
  * The function will start with @root, and iterate through all the
  * descendants, including threads, in a DFS manner. Children of a task
- * are traversed before proceeding to the next thread of that task.
+ * are traversed before proceeding to the next thread of that task,
+ * and threads of a task are traversed before proceeding to the next
+ * sibling of that task. (Threads of the root task are included, but
+ * siblings of the root task are skipped).
  *
  * For each task, the callback @func will be called providing the task
  * pointer and the @data. The callback is invoked while holding the
@@ -580,10 +583,8 @@ int walk_task_subtree(struct task_struct *root,
 		      int (*func)(struct task_struct *, void *),
 		      void *data)
 {
-
-	struct task_struct *leader = root;
-	struct task_struct *parent = NULL;
 	struct task_struct *task = root;
+	struct task_struct *parent = NULL;
 	int total = 0;
 	int ret;
 
@@ -604,7 +605,13 @@ int walk_task_subtree(struct task_struct *root,
 			continue;
 		}
 
+		/* by definition, skip siblings of root */
 		while (task != root) {
+			/* if not last thread - proceed with thread */
+			task = next_thread(task);
+			if (!thread_group_leader(task))
+				break;
+
 			/* if has sibling - proceed with sibling */
 			if (!list_is_last(&task->sibling, &parent->children)) {
 				task = list_entry(task->sibling.next,
@@ -617,12 +624,9 @@ int walk_task_subtree(struct task_struct *root,
 			parent = parent->real_parent;
 		}
 
-		if (task == root) {
-			/* in case root task is multi-threaded */
-			root = task = next_thread(task);
-			if (root == leader)
-				break;
-		}
+		/* if we arrive at root again -- done */
+		if (task == root)
+			break;
 	}
 	read_unlock(&tasklist_lock);
 
-- 
1.7.0.4
