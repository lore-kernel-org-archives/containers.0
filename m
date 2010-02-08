From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 6/6] [RFC] user-cr: restart: Replace creator pointer with index
Date: Mon,  8 Feb 2010 13:57:23 -0800
Message-ID: <0124965b9f22dd851f4c038ada48b9fce8e4c847.1265665676.git.matthltc@us.ibm.com>
References: <1265666243-29046-1-git-send-email-matthltc@us.ibm.com>
	<ef85446244a744fd9c91cf06515f796ce833f01c.1265665676.git.matthltc@us.ibm.com>
	<b5d1f44254f8d30988ef96d849e40353e255801b.1265665676.git.matthltc@us.ibm.com>
	<b2b2ddd05d451916901fbc6776951a8bf64c6dbd.1265665676.git.matthltc@us.ibm.com>
	<4cd2b19f8c0272f678c8cc4f00f83d67f66e5ee5.1265665676.git.matthltc@us.ibm.com>
	<5a6ac0fff4a0a9921bb4fac2b2017d4efa9fc5ae.1265665676.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5a6ac0fff4a0a9921bb4fac2b2017d4efa9fc5ae.1265665676.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Replace the creator field with an index. Since walking the tree table
creator entries can reach the "zero task" we need to replace zero_task
as well.

Place a "zero task" in the tasks_arr rather than keep it as a global.
This completes the transition from using pointers to connect table
entries to using indices.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 restart.c |   50 ++++++++++++++++++++++++++++----------------------
 1 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/restart.c b/restart.c
index e89bf42..61c30a3 100644
--- a/restart.c
+++ b/restart.c
@@ -208,7 +208,7 @@ struct task {
 	int children;	/* pointers to first child, next and prev */
 	int next_sib;	/*   sibling, and the creator of a process */
 	int prev_sib;
-	struct task *creator;
+	int creator;
 
 	int phantom;	/* index of place-holdler task (if any) */
 
@@ -223,9 +223,6 @@ struct task {
 	pid_t real_parent;	/* pid of task's real parent */
 };
 
-/* zero_task represents creator of root_task (all pids 0) */
-struct task zero_task;
-
 #define TASK_ROOT	0x1	/* root task */
 #define TASK_GHOST	0x2	/* dead task (pid used as sid/pgid) */
 #define TASK_THREAD	0x4	/* thread (non leader) */
@@ -249,7 +246,7 @@ struct ckpt_ctx {
 
 	struct task *tasks_arr;
 	int tasks_nr;
-	int tasks_max;
+	int tasks_max; /* also == index of the "zero task" in the task table */
 	int tasks_pid;
 
 	struct hashent **hash_arr;
@@ -1174,7 +1171,7 @@ static int ckpt_build_tree(void)
 	 * placeholder tasks (each session id may have at most one)
 	 */
 	ctx.tasks_max = ctx.pids_nr * 4;
-	ctx.tasks_arr = malloc(sizeof(*ctx.tasks_arr) * ctx.tasks_max);
+	ctx.tasks_arr = malloc(sizeof(*ctx.tasks_arr) * (ctx.tasks_max + 1));
 	if (!ctx.tasks_arr) {
 		perror("malloc tasks array");
 		return -1;
@@ -1190,7 +1187,7 @@ static int ckpt_build_tree(void)
 	/* assign a creator to each task */
 	for (i = 0; i < ctx.tasks_nr; i++) {
 		task = &ctx.tasks_arr[i];
-		if (task->creator)
+		if (task->creator > -1)
 			continue;
 		if (ckpt_set_creator(task) < 0) {
 			free(ctx.tasks_arr);
@@ -1205,7 +1202,7 @@ static int ckpt_build_tree(void)
 		task = &ctx.tasks_arr[i];
 		ckpt_dbg("\t[%d] pid %d ppid %d sid %d creator %d",
 			 i, task->pid, task->ppid, task->sid,
-			 task->creator->pid);
+			 ctx.tasks_arr[task->creator].pid);
 		if (task->next_sib > -1)
 			ckpt_dbg_cont(" next %d", ctx.tasks_arr[task->next_sib].pid);
 		if (task->prev_sib > -1)
@@ -1250,8 +1247,8 @@ static int ckpt_setup_task(pid_t pid, pid_t ppid)
 	task->children = -1;
 	task->next_sib = -1;
 	task->prev_sib = -1;
-	task->creator = NULL;
 	task->phantom = -1;
+	task->creator = -1;
 
 	task->rpid = -1;
 
@@ -1358,6 +1355,13 @@ static int ckpt_init_tree(void)
 	if (root_sid == root_pid)
 		root_sid = -1;
 
+	/* Make the dummy "zero" task the last task in the array. */
+	task = &ctx.tasks_arr[ctx.tasks_max];
+	memset(task, sizeof(*task), 0);
+	task->index = ctx.tasks_max;
+	/* unused, but set to "nothing" just in case: */
+	task->prev_sib = task->next_sib = task->phantom = task->creator = -1;
+
 	/* populate with known tasks */
 	for (i = 0; i < pids_nr; i++) {
 		task = &ctx.tasks_arr[i];
@@ -1387,8 +1391,8 @@ static int ckpt_init_tree(void)
 		task->children = -1;
 		task->next_sib = -1;
 		task->prev_sib = -1;
-		task->creator = NULL;
 		task->phantom = -1;
+		task->creator = -1;
 
 		task->rpid = -1;
 
@@ -1464,9 +1468,11 @@ static int ckpt_init_tree(void)
 		}
 	}
 
+	/* "zero_task" represents creator of root_task (all pids 0) */
+
 	/* mark root task(s), and set its "creator" to be zero_task */
 	ckpt_init_task()->flags |= TASK_ROOT;
-	ckpt_init_task()->creator = &zero_task;
+	ckpt_init_task()->creator = ctx.tasks_max;
 
 	ckpt_dbg("total tasks (including ghosts): %d\n", ctx.tasks_nr);
 	return 0;
@@ -1587,7 +1593,7 @@ static int ckpt_set_creator(struct task *task)
 		creator = &ctx.tasks_arr[session->phantom];
 	} else {
 		/* first make sure we know the session's creator */
-		if (!session->creator) {
+		if (session->creator < 0) {
 			/* (non-session-leader) recursive: session's creator */
 			ckpt_dbg("pid %d: recursive session creator %d\n",
 			       task->pid, task->sid);
@@ -1595,7 +1601,7 @@ static int ckpt_set_creator(struct task *task)
 				return -1;
 		}
 		/* then use it to decide what to do */
-		if (session->creator->pid == task->ppid) {
+		if (ctx.tasks_arr[session->creator].pid == task->ppid) {
 			/* init must not be sibling creator (CLONE_PARENT) */
 			if (session == ckpt_init_task()) {
 				ckpt_err("pid %d: sibling session prohibited"
@@ -1624,7 +1630,7 @@ static int ckpt_set_creator(struct task *task)
 	}
 
 	ckpt_dbg("pid %d: creator set to %d\n", task->pid, creator->pid);
-	task->creator = creator;
+	task->creator = creator->index;
 	creator->children = task->index;
 
 	if (task->flags & TASK_SESSION)
@@ -1661,12 +1667,12 @@ static int ckpt_placeholder_task(struct task *task)
 	holder->children = -1;
 	holder->next_sib = -1;
 	holder->prev_sib = -1;
-	holder->creator = NULL;
 	holder->phantom = -1;
+	holder->creator = -1;
 
 	holder->rpid = -1;
 
-	holder->creator = session;
+	holder->creator = session->index;
 	if (session->children > -1) {
 		holder->next_sib = session->children;
 		ctx.tasks_arr[session->children].prev_sib = holder->index;
@@ -1679,10 +1685,10 @@ static int ckpt_placeholder_task(struct task *task)
 		ctx.tasks_arr[task->next_sib].prev_sib = task->prev_sib;
 	if (task->prev_sib > -1)
 		ctx.tasks_arr[task->prev_sib].next_sib = task->next_sib;
-	if (task->creator)
-		task->creator->children = task->next_sib;
+	if (task->creator > -1)
+		ctx.tasks_arr[task->creator].children = task->next_sib;
 
-	task->creator = holder;
+	task->creator = holder->index;
 	task->next_sib = -1;
 	task->prev_sib = -1;
 
@@ -1699,7 +1705,7 @@ static int ckpt_propagate_session(struct task *task)
 		ckpt_dbg("pid %d: set session\n", task->pid);
 		task->flags |= TASK_SESSION;
 
-		creator = task->creator;
+		creator = &ctx.tasks_arr[task->creator];
 		if (creator->pid == 1) {
 			if (ckpt_placeholder_task(task) < 0)
 				return -1;
@@ -1708,14 +1714,14 @@ static int ckpt_propagate_session(struct task *task)
 		ckpt_dbg("pid %d: moving up to %d\n", task->pid, creator->pid);
 		task = creator;
 
-		if(!task->creator) {
+		if(task->creator < 0) {
 			if (ckpt_set_creator(task) < 0)
 				return -1;
 		}
 	} while (task->sid != sid &&
 		 task != ckpt_init_task() &&
 		 !(task->flags & TASK_SESSION) &&
-		 task->creator != session);
+		 task->creator != session->index);
 
 	return 0;
 }
-- 
1.6.3.3
