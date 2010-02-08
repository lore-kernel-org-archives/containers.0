From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/6] [RFC] user-cr: restart: Replace children pointer with
	index
Date: Mon,  8 Feb 2010 13:57:19 -0800
Message-ID: <b5d1f44254f8d30988ef96d849e40353e255801b.1265665676.git.matthltc@us.ibm.com>
References: <1265666243-29046-1-git-send-email-matthltc@us.ibm.com>
	<ef85446244a744fd9c91cf06515f796ce833f01c.1265665676.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ef85446244a744fd9c91cf06515f796ce833f01c.1265665676.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Add an index field for each struct task. Replace children pointer with
an index in the ctx.tasks_arr[].

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 restart.c |   32 ++++++++++++++++++--------------
 1 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/restart.c b/restart.c
index d51a08f..411c513 100644
--- a/restart.c
+++ b/restart.c
@@ -202,9 +202,10 @@ struct hashent {
 struct task;
 
 struct task {
+	int index;
 	int flags;		/* state and (later) actions */
 
-	struct task *children;	/* pointers to first child, next and prev */
+	int children;	/* pointers to first child, next and prev */
 	struct task *next_sib;	/*   sibling, and the creator of a process */
 	struct task *prev_sib;
 	struct task *creator;
@@ -1237,6 +1238,7 @@ static int ckpt_setup_task(pid_t pid, pid_t ppid)
 		return 0;
 
 	task = &ctx.tasks_arr[ctx.tasks_nr++];
+	/* assert(task->index == (ctx.tasks_nr - 1)); */
 
 	task->flags = TASK_GHOST;
 
@@ -1245,7 +1247,7 @@ static int ckpt_setup_task(pid_t pid, pid_t ppid)
 	task->tgid = pid;
 	task->sid = ppid;
 
-	task->children = NULL;
+	task->children = -1;
 	task->next_sib = NULL;
 	task->prev_sib = NULL;
 	task->creator = NULL;
@@ -1359,6 +1361,7 @@ static int ckpt_init_tree(void)
 	/* populate with known tasks */
 	for (i = 0; i < pids_nr; i++) {
 		task = &ctx.tasks_arr[i];
+		task->index = i;
 
 		task->flags = 0;
 
@@ -1381,7 +1384,7 @@ static int ckpt_init_tree(void)
 		task->tgid = pids_arr[i].vtgid;
 		task->sid = pids_arr[i].vsid;
 
-		task->children = NULL;
+		task->children = -1;
 		task->next_sib = NULL;
 		task->prev_sib = NULL;
 		task->creator = NULL;
@@ -1613,8 +1616,8 @@ static int ckpt_set_creator(struct task *task)
 		}
 	}
 
-	if (creator->children) {
-		struct task *next = creator->children;
+	if (creator->children > -1) {
+		struct task *next = &ctx.tasks_arr[creator->children];
 
 		task->next_sib = next;
 		next->prev_sib = task;
@@ -1622,7 +1625,7 @@ static int ckpt_set_creator(struct task *task)
 
 	ckpt_dbg("pid %d: creator set to %d\n", task->pid, creator->pid);
 	task->creator = creator;
-	creator->children = task;
+	creator->children = task->index;
 
 	if (task->flags & TASK_SESSION)
 		if (ckpt_propagate_session(task) < 0)
@@ -1647,6 +1650,7 @@ static int ckpt_placeholder_task(struct task *task)
 	if (pid < 0)
 		return -1;
 
+	/* assert(holder->index == (ctx.tasks_nr - 1)); */
 	holder->flags = TASK_DEAD;
 
 	holder->pid = pid;
@@ -1654,7 +1658,7 @@ static int ckpt_placeholder_task(struct task *task)
 	holder->tgid = pid;
 	holder->sid = task->sid;
 
-	holder->children = NULL;
+	holder->children = -1;
 	holder->next_sib = NULL;
 	holder->prev_sib = NULL;
 	holder->creator = NULL;
@@ -1663,11 +1667,11 @@ static int ckpt_placeholder_task(struct task *task)
 	holder->rpid = -1;
 
 	holder->creator = session;
-	if (session->children) {
-		holder->next_sib = session->children;
-		session->children->prev_sib = holder;
+	if (session->children > -1) {
+		holder->next_sib = &ctx.tasks_arr[session->children];
+		ctx.tasks_arr[session->children].prev_sib = holder;
 	}
-	session->children = holder;
+	session->children = holder->index;/* = ctx.tasks_nr ?? */
 	session->phantom = holder;
 
 	/* reparent entry if necssary */
@@ -1676,7 +1680,7 @@ static int ckpt_placeholder_task(struct task *task)
 	if (task->prev_sib)
 		task->prev_sib->next_sib = task->next_sib;
 	if (task->creator)
-		task->creator->children = task->next_sib;
+		task->creator->children = task->next_sib->index;
 
 	task->creator = holder;
 	task->next_sib = NULL;
@@ -1758,7 +1762,7 @@ static int ckpt_make_tree(struct task *task)
 	       task->pid, _gettid(), getsid(0), getppid());
 
 	/* 1st pass: fork children that inherit our old session-id */
-	for (child = task->children; child; child = child->next_sib) {
+	for (child = &ctx.tasks_arr[task->children]; child; child = child->next_sib) {
 		if (child->flags & TASK_SESSION) {
 			ckpt_dbg("pid %d: fork child %d with session\n",
 			       task->pid, child->pid);
@@ -1779,7 +1783,7 @@ static int ckpt_make_tree(struct task *task)
 	}
 
 	/* 2st pass: fork children that inherit our new session-id */
-	for (child = task->children; child; child = child->next_sib) {
+	for (child = &ctx.tasks_arr[task->children]; child; child = child->next_sib) {
 		if (!(child->flags & TASK_SESSION)) {
 			ckpt_dbg("pid %d: fork child %d without session\n",
 			       task->pid, child->pid);
-- 
1.6.3.3
