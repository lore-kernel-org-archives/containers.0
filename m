From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/6] [RFC] user-cr: restart: Replace next_sib pointer with an
	index
Date: Mon,  8 Feb 2010 13:57:20 -0800
Message-ID: <b2b2ddd05d451916901fbc6776951a8bf64c6dbd.1265665676.git.matthltc@us.ibm.com>
References: <1265666243-29046-1-git-send-email-matthltc@us.ibm.com>
	<ef85446244a744fd9c91cf06515f796ce833f01c.1265665676.git.matthltc@us.ibm.com>
	<b5d1f44254f8d30988ef96d849e40353e255801b.1265665676.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <b5d1f44254f8d30988ef96d849e40353e255801b.1265665676.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

The more complicated portions of this patch will go away once all of the
task pointers in the ctx.tasks_arr[] are replaced with indices.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 restart.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/restart.c b/restart.c
index 411c513..d1c2292 100644
--- a/restart.c
+++ b/restart.c
@@ -206,7 +206,7 @@ struct task {
 	int flags;		/* state and (later) actions */
 
 	int children;	/* pointers to first child, next and prev */
-	struct task *next_sib;	/*   sibling, and the creator of a process */
+	int next_sib;	/*   sibling, and the creator of a process */
 	struct task *prev_sib;
 	struct task *creator;
 
@@ -1206,8 +1206,8 @@ static int ckpt_build_tree(void)
 		ckpt_dbg("\t[%d] pid %d ppid %d sid %d creator %d",
 			 i, task->pid, task->ppid, task->sid,
 			 task->creator->pid);
-		if (task->next_sib)
-			ckpt_dbg_cont(" next %d", task->next_sib->pid);
+		if (task->next_sib > -1)
+			ckpt_dbg_cont(" next %d", ctx.tasks_arr[task->next_sib].pid);
 		if (task->prev_sib)
 			ckpt_dbg_cont(" prev %d", task->prev_sib->pid);
 		if (task->phantom)
@@ -1248,7 +1248,7 @@ static int ckpt_setup_task(pid_t pid, pid_t ppid)
 	task->sid = ppid;
 
 	task->children = -1;
-	task->next_sib = NULL;
+	task->next_sib = -1;
 	task->prev_sib = NULL;
 	task->creator = NULL;
 	task->phantom = NULL;
@@ -1385,7 +1385,7 @@ static int ckpt_init_tree(void)
 		task->sid = pids_arr[i].vsid;
 
 		task->children = -1;
-		task->next_sib = NULL;
+		task->next_sib = -1;
 		task->prev_sib = NULL;
 		task->creator = NULL;
 		task->phantom = NULL;
@@ -1619,7 +1619,7 @@ static int ckpt_set_creator(struct task *task)
 	if (creator->children > -1) {
 		struct task *next = &ctx.tasks_arr[creator->children];
 
-		task->next_sib = next;
+		task->next_sib = next->index;
 		next->prev_sib = task;
 	}
 
@@ -1659,7 +1659,7 @@ static int ckpt_placeholder_task(struct task *task)
 	holder->sid = task->sid;
 
 	holder->children = -1;
-	holder->next_sib = NULL;
+	holder->next_sib = -1;
 	holder->prev_sib = NULL;
 	holder->creator = NULL;
 	holder->phantom = NULL;
@@ -1668,22 +1668,22 @@ static int ckpt_placeholder_task(struct task *task)
 
 	holder->creator = session;
 	if (session->children > -1) {
-		holder->next_sib = &ctx.tasks_arr[session->children];
+		holder->next_sib = session->children;
 		ctx.tasks_arr[session->children].prev_sib = holder;
 	}
 	session->children = holder->index;/* = ctx.tasks_nr ?? */
 	session->phantom = holder;
 
 	/* reparent entry if necssary */
-	if (task->next_sib)
-		task->next_sib->prev_sib = task->prev_sib;
+	if (task->next_sib > -1)
+		ctx.tasks_arr[task->next_sib].prev_sib = task->prev_sib;
 	if (task->prev_sib)
 		task->prev_sib->next_sib = task->next_sib;
 	if (task->creator)
-		task->creator->children = task->next_sib->index;
+		task->creator->children = task->next_sib;
 
 	task->creator = holder;
-	task->next_sib = NULL;
+	task->next_sib = -1;
 	task->prev_sib = NULL;
 
 	return 0;
@@ -1762,7 +1762,7 @@ static int ckpt_make_tree(struct task *task)
 	       task->pid, _gettid(), getsid(0), getppid());
 
 	/* 1st pass: fork children that inherit our old session-id */
-	for (child = &ctx.tasks_arr[task->children]; child; child = child->next_sib) {
+	for (child = &ctx.tasks_arr[task->children]; child && ((child >= &ctx.tasks_arr[0]) && (child <= &ctx.tasks_arr[ctx.tasks_nr - 1])); child = &ctx.tasks_arr[child->next_sib]) {
 		if (child->flags & TASK_SESSION) {
 			ckpt_dbg("pid %d: fork child %d with session\n",
 			       task->pid, child->pid);
@@ -1783,7 +1783,7 @@ static int ckpt_make_tree(struct task *task)
 	}
 
 	/* 2st pass: fork children that inherit our new session-id */
-	for (child = &ctx.tasks_arr[task->children]; child; child = child->next_sib) {
+	for (child = &ctx.tasks_arr[task->children]; child && ((child >= &ctx.tasks_arr[0]) && (child <= &ctx.tasks_arr[ctx.tasks_nr - 1])); child = &ctx.tasks_arr[child->next_sib]) {
 		if (!(child->flags & TASK_SESSION)) {
 			ckpt_dbg("pid %d: fork child %d without session\n",
 			       task->pid, child->pid);
-- 
1.6.3.3
