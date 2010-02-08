From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 5/6] [RFC] user-cr: restart: Replace phantom pointer with index
Date: Mon,  8 Feb 2010 13:57:22 -0800
Message-ID: <5a6ac0fff4a0a9921bb4fac2b2017d4efa9fc5ae.1265665676.git.matthltc@us.ibm.com>
References: <1265666243-29046-1-git-send-email-matthltc@us.ibm.com>
	<ef85446244a744fd9c91cf06515f796ce833f01c.1265665676.git.matthltc@us.ibm.com>
	<b5d1f44254f8d30988ef96d849e40353e255801b.1265665676.git.matthltc@us.ibm.com>
	<b2b2ddd05d451916901fbc6776951a8bf64c6dbd.1265665676.git.matthltc@us.ibm.com>
	<4cd2b19f8c0272f678c8cc4f00f83d67f66e5ee5.1265665676.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4cd2b19f8c0272f678c8cc4f00f83d67f66e5ee5.1265665676.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <ef85446244a744fd9c91cf06515f796ce833f01c.1265665676.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <ef85446244a744fd9c91cf06515f796ce833f01c.1265665676.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 restart.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/restart.c b/restart.c
index b0e87f0..e89bf42 100644
--- a/restart.c
+++ b/restart.c
@@ -210,7 +210,7 @@ struct task {
 	int prev_sib;
 	struct task *creator;
 
-	struct task *phantom;	/* pointer to place-holdler task (if any) */
+	int phantom;	/* index of place-holdler task (if any) */
 
 	pid_t pid;		/* process IDs, our bread-&-butter */
 	pid_t ppid;
@@ -1210,8 +1210,8 @@ static int ckpt_build_tree(void)
 			ckpt_dbg_cont(" next %d", ctx.tasks_arr[task->next_sib].pid);
 		if (task->prev_sib > -1)
 			ckpt_dbg_cont(" prev %d", ctx.tasks_arr[task->prev_sib].pid);
-		if (task->phantom)
-			ckpt_dbg_cont(" placeholder %d", task->phantom->pid);
+		if (task->phantom > -1)
+			ckpt_dbg_cont(" placeholder %d", ctx.tasks_arr[task->phantom].pid);
 		ckpt_dbg_cont(" %c%c%c%c%c%c",
 		       (task->flags & TASK_THREAD) ? 'T' : ' ',
 		       (task->flags & TASK_SIBLING) ? 'P' : ' ',
@@ -1251,7 +1251,7 @@ static int ckpt_setup_task(pid_t pid, pid_t ppid)
 	task->next_sib = -1;
 	task->prev_sib = -1;
 	task->creator = NULL;
-	task->phantom = NULL;
+	task->phantom = -1;
 
 	task->rpid = -1;
 
@@ -1388,7 +1388,7 @@ static int ckpt_init_tree(void)
 		task->next_sib = -1;
 		task->prev_sib = -1;
 		task->creator = NULL;
-		task->phantom = NULL;
+		task->phantom = -1;
 
 		task->rpid = -1;
 
@@ -1581,10 +1581,10 @@ static int ckpt_set_creator(struct task *task)
 	} else if (task->ppid == 1) {
 		/* (non-session-leader) orphan: creator is dummy */
 		ckpt_dbg("pid %d: orphan session %d\n", task->pid, task->sid);
-		if (!session->phantom)
+		if (session->phantom < 0)
 			if (ckpt_placeholder_task(task) < 0)
 				return -1;
-		creator = session->phantom;
+		creator = &ctx.tasks_arr[session->phantom];
 	} else {
 		/* first make sure we know the session's creator */
 		if (!session->creator) {
@@ -1662,7 +1662,7 @@ static int ckpt_placeholder_task(struct task *task)
 	holder->next_sib = -1;
 	holder->prev_sib = -1;
 	holder->creator = NULL;
-	holder->phantom = NULL;
+	holder->phantom = -1;
 
 	holder->rpid = -1;
 
@@ -1671,8 +1671,8 @@ static int ckpt_placeholder_task(struct task *task)
 		holder->next_sib = session->children;
 		ctx.tasks_arr[session->children].prev_sib = holder->index;
 	}
-	session->children = holder->index;/* = ctx.tasks_nr ?? */
-	session->phantom = holder;
+	session->children = holder->index;/* = ctx.tasks_nr */
+	session->phantom = holder->index;
 
 	/* reparent entry if necssary */
 	if (task->next_sib > -1)
-- 
1.6.3.3
