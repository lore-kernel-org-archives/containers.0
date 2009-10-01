From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH-user-cr] restart: handle root task with sid != pid
Date: Wed, 30 Sep 2009 21:36:16 -0400
Message-ID: <1254360976-29521-1-git-send-email-orenl@librato.com>
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
List-Id: containers.vger.kernel.org

The case where root_sid != root_pid is handles explicitly. It can only
happen when the checkpoint was of a subtree (in container, root_sid is
either root_pid or 0).  This means that root_sid was inherited from an
ancestor of that subtree. So we make root_task here also inherit its
sid from its ancestor (whatever the 'restart' process had).

We do it by forcing it to be 0. We also need to force all references
to it from other processes, via sid and pgid, to 0. For that, we keep
the root_sid to compare against (see one-line comment below).

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |   33 ++++++++++++++++++++++++++++++---
 1 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/restart.c b/restart.c
index deca6f7..07ffdc3 100644
--- a/restart.c
+++ b/restart.c
@@ -1046,7 +1046,6 @@ static int ckpt_setup_task(struct ckpt_ctx *ctx, pid_t pid, pid_t ppid)
 
 	task->flags = TASK_GHOST;
 
-	/* */
 	task->pid = pid;
 	task->ppid = ppid;
 	task->tgid = pid;
@@ -1078,12 +1077,26 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 	struct task *task;
 	pid_t root_sid;
 	pid_t root_pid;
-	pid_t root_pgid;
 	int i;
 
 	root_pid = pids_arr[0].vpid;
 	root_sid = pids_arr[0].vsid;
-	root_pgid = pids_arr[0].vpgid;
+
+	/*
+	 * The case where root_sid != root_pid is special. It must be
+	 * from a subtree checkpoint (in container, root_sid is either
+	 * root_pid or 0).
+	 * This means that root_sid was inherited from an ancestor of
+	 * that subtree. So we make root_task here also inherit its
+	 * sid from its ancestor (whatever the 'restart' process had).
+	 *
+	 * We do it by forcing it to be 0. We also need to force all
+	 * references to it from other processes, via sid and pgid, to
+	 * 0. For that, we keep the root_sid to compare against (see
+	 * one-line comment below).
+	 */
+	if (root_sid == root_pid)
+		root_sid = 0;
 
 	/* populate with known tasks */
 	for (i = 0; i < pids_nr; i++) {
@@ -1091,6 +1104,12 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 
 		task->flags = 0;
 
+		/* zero references to root_sid (root_sid != root_pid) */
+		if (pids_arr[i].vsid == root_sid)
+			pids_arr[i].vsid = 0;
+		if (pids_arr[i].vpgid == root_sid)
+			pids_arr[i].vpgid = 0;
+
 		task->pid = pids_arr[i].vpid;
 		task->ppid = pids_arr[i].vppid;
 		task->tgid = pids_arr[i].vtgid;
@@ -1134,6 +1153,14 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 			return -1;
 
 		/*
+		 * An sid == 0 means that the session was inherited an
+		 * ancestor of root_task, and more specifically, via
+		 * root_task itself: make root_task our parent.
+		 */
+		if (sid == 0)
+			sid = root_pid;
+
+		/*
 		 * If a pid belongs to a dead thread group leader, we
 		 * need to add it with the same sid as current (and
 		 * other) threads.
-- 
1.6.0.4
