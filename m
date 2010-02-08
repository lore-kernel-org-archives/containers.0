From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/6] [RFC] user-cr: restart: Replace prev_sib pointer with
	index
Date: Mon,  8 Feb 2010 13:57:21 -0800
Message-ID: <4cd2b19f8c0272f678c8cc4f00f83d67f66e5ee5.1265665676.git.matthltc@us.ibm.com>
References: <1265666243-29046-1-git-send-email-matthltc@us.ibm.com>
	<ef85446244a744fd9c91cf06515f796ce833f01c.1265665676.git.matthltc@us.ibm.com>
	<b5d1f44254f8d30988ef96d849e40353e255801b.1265665676.git.matthltc@us.ibm.com>
	<b2b2ddd05d451916901fbc6776951a8bf64c6dbd.1265665676.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <b2b2ddd05d451916901fbc6776951a8bf64c6dbd.1265665676.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
 restart.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/restart.c b/restart.c
index d1c2292..b0e87f0 100644
--- a/restart.c
+++ b/restart.c
@@ -207,7 +207,7 @@ struct task {
 
 	int children;	/* pointers to first child, next and prev */
 	int next_sib;	/*   sibling, and the creator of a process */
-	struct task *prev_sib;
+	int prev_sib;
 	struct task *creator;
 
 	struct task *phantom;	/* pointer to place-holdler task (if any) */
@@ -1208,8 +1208,8 @@ static int ckpt_build_tree(void)
 			 task->creator->pid);
 		if (task->next_sib > -1)
 			ckpt_dbg_cont(" next %d", ctx.tasks_arr[task->next_sib].pid);
-		if (task->prev_sib)
-			ckpt_dbg_cont(" prev %d", task->prev_sib->pid);
+		if (task->prev_sib > -1)
+			ckpt_dbg_cont(" prev %d", ctx.tasks_arr[task->prev_sib].pid);
 		if (task->phantom)
 			ckpt_dbg_cont(" placeholder %d", task->phantom->pid);
 		ckpt_dbg_cont(" %c%c%c%c%c%c",
@@ -1249,7 +1249,7 @@ static int ckpt_setup_task(pid_t pid, pid_t ppid)
 
 	task->children = -1;
 	task->next_sib = -1;
-	task->prev_sib = NULL;
+	task->prev_sib = -1;
 	task->creator = NULL;
 	task->phantom = NULL;
 
@@ -1386,7 +1386,7 @@ static int ckpt_init_tree(void)
 
 		task->children = -1;
 		task->next_sib = -1;
-		task->prev_sib = NULL;
+		task->prev_sib = -1;
 		task->creator = NULL;
 		task->phantom = NULL;
 
@@ -1620,7 +1620,7 @@ static int ckpt_set_creator(struct task *task)
 		struct task *next = &ctx.tasks_arr[creator->children];
 
 		task->next_sib = next->index;
-		next->prev_sib = task;
+		next->prev_sib = task->index;
 	}
 
 	ckpt_dbg("pid %d: creator set to %d\n", task->pid, creator->pid);
@@ -1660,7 +1660,7 @@ static int ckpt_placeholder_task(struct task *task)
 
 	holder->children = -1;
 	holder->next_sib = -1;
-	holder->prev_sib = NULL;
+	holder->prev_sib = -1;
 	holder->creator = NULL;
 	holder->phantom = NULL;
 
@@ -1669,7 +1669,7 @@ static int ckpt_placeholder_task(struct task *task)
 	holder->creator = session;
 	if (session->children > -1) {
 		holder->next_sib = session->children;
-		ctx.tasks_arr[session->children].prev_sib = holder;
+		ctx.tasks_arr[session->children].prev_sib = holder->index;
 	}
 	session->children = holder->index;/* = ctx.tasks_nr ?? */
 	session->phantom = holder;
@@ -1677,14 +1677,14 @@ static int ckpt_placeholder_task(struct task *task)
 	/* reparent entry if necssary */
 	if (task->next_sib > -1)
 		ctx.tasks_arr[task->next_sib].prev_sib = task->prev_sib;
-	if (task->prev_sib)
-		task->prev_sib->next_sib = task->next_sib;
+	if (task->prev_sib > -1)
+		ctx.tasks_arr[task->prev_sib].next_sib = task->next_sib;
 	if (task->creator)
 		task->creator->children = task->next_sib;
 
 	task->creator = holder;
 	task->next_sib = -1;
-	task->prev_sib = NULL;
+	task->prev_sib = -1;
 
 	return 0;
 }
-- 
1.6.3.3
