From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/6] [RFC] user-cr: restart: Make context global
Date: Mon,  8 Feb 2010 13:57:18 -0800
Message-ID: <ef85446244a744fd9c91cf06515f796ce833f01c.1265665676.git.matthltc@us.ibm.com>
References: <1265666243-29046-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1265666243-29046-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Make ctx a global variable rather than passing it as parameters and
through the task->ctx data structure.

This will enable an exec wrapper which will allow restarting 32 or
64-bit applications from checkpoint images pass to a 32 or 64-bit
restart binary.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 restart.c |  644 ++++++++++++++++++++++++++++++-------------------------------
 1 files changed, 316 insertions(+), 328 deletions(-)

diff --git a/restart.c b/restart.c
index f3d33de..d51a08f 100644
--- a/restart.c
+++ b/restart.c
@@ -200,7 +200,6 @@ struct hashent {
 };
 
 struct task;
-struct ckpt_ctx;
 
 struct task {
 	int flags;		/* state and (later) actions */
@@ -219,7 +218,6 @@ struct task {
 	
 	pid_t rpid;		/* [restart without vpids] actual (real) pid */
 
-	struct ckpt_ctx *ctx;	/* points back to the c/r context */
 
 	pid_t real_parent;	/* pid of task's real parent */
 };
@@ -265,6 +263,8 @@ struct ckpt_ctx {
 	char *freezer;
 };
 
+static struct ckpt_ctx ctx;
+
 int global_debug;
 int global_verbose;
 pid_t global_child_pid;
@@ -273,47 +273,46 @@ int global_child_collected;
 int global_send_sigint = -1;
 int global_sent_sigint;
 
-static int ckpt_build_tree(struct ckpt_ctx *ctx);
-static int ckpt_init_tree(struct ckpt_ctx *ctx);
-static int ckpt_set_creator(struct ckpt_ctx *ctx, struct task *task);
-static int ckpt_placeholder_task(struct ckpt_ctx *ctx, struct task *task);
-static int ckpt_propagate_session(struct ckpt_ctx *ctx, struct task *session);
+static int ckpt_build_tree(void);
+static int ckpt_init_tree(void);
+static int ckpt_set_creator(struct task *task);
+static int ckpt_placeholder_task(struct task *task);
+static int ckpt_propagate_session(struct task *session);
 
-static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx);
-static int ckpt_coordinator(struct ckpt_ctx *ctx);
+static int ckpt_coordinator_pidns(void);
+static int ckpt_coordinator(void);
 
-static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task);
-static int ckpt_collect_child(struct ckpt_ctx *ctx);
-static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child);
-static int ckpt_adjust_pids(struct ckpt_ctx *ctx);
+static int ckpt_make_tree(struct task *task);
+static int ckpt_collect_child(void);
+static pid_t ckpt_fork_child(struct task *child);
+static int ckpt_adjust_pids(void);
 
-static void ckpt_abort(struct ckpt_ctx *ctx, char *str);
-static int ckpt_do_feeder(void *data);
-static int ckpt_fork_feeder(struct ckpt_ctx *ctx);
+static void ckpt_abort(char *str);
+static int ckpt_do_feeder(void *ignored_arg);
+static int ckpt_fork_feeder(void);
 
 static int ckpt_write(int fd, void *buf, int count);
-static int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h);
+static int ckpt_write_obj(struct ckpt_hdr *h);
 
-static int ckpt_write_header(struct ckpt_ctx *ctx);
-static int ckpt_write_header_arch(struct ckpt_ctx *ctx);
-static int ckpt_write_container(struct ckpt_ctx *ctx);
-static int ckpt_write_tree(struct ckpt_ctx *ctx);
+static int ckpt_write_header(void);
+static int ckpt_write_header_arch(void);
+static int ckpt_write_container(void);
+static int ckpt_write_tree(void);
 
 static int _ckpt_read(int fd, void *buf, int count);
 static int ckpt_read(int fd, void *buf, int count);
-static int ckpt_read_obj(struct ckpt_ctx *ctx,
-			 struct ckpt_hdr *h, void *buf, int n);
-static int ckpt_read_obj_type(struct ckpt_ctx *ctx, void *b, int n, int type);
+static int ckpt_read_obj(struct ckpt_hdr *h, void *buf, int n);
+static int ckpt_read_obj_type(void *b, int n, int type);
 
-static int ckpt_read_header(struct ckpt_ctx *ctx);
-static int ckpt_read_header_arch(struct ckpt_ctx *ctx);
-static int ckpt_read_container(struct ckpt_ctx *ctx);
-static int ckpt_read_tree(struct ckpt_ctx *ctx);
+static int ckpt_read_header(void);
+static int ckpt_read_header_arch(void);
+static int ckpt_read_container(void);
+static int ckpt_read_tree(void);
 
-static int hash_init(struct ckpt_ctx *ctx);
-static void hash_exit(struct ckpt_ctx *ctx);
-static int hash_insert(struct ckpt_ctx *ctx, long key, void *data);
-static void *hash_lookup(struct ckpt_ctx *ctx, long key);
+static int hash_init(void);
+static void hash_exit(void);
+static int hash_insert(long key, void *data);
+static void *hash_lookup(long key);
 
 static inline pid_t _gettid(void)
 {
@@ -393,14 +392,14 @@ static long cond_to_mask(const char *cond)
 	exit(1);
 }
 
-static inline int ckpt_cond_warn(struct ckpt_ctx *ctx, long mask)
+static inline int ckpt_cond_warn(long mask)
 {
-	return (ctx->args->warn & mask);
+	return (ctx.args->warn & mask);
 }
 		
-static inline int ckpt_cond_fail(struct ckpt_ctx *ctx, long mask)
+static inline int ckpt_cond_fail(long mask)
 {
-	return (ctx->args->fail & mask);
+	return (ctx.args->fail & mask);
 }
 
 static void parse_args(struct args *args, int argc, char *argv[])
@@ -663,20 +662,20 @@ static void sigint_handler(int sig)
 	}
 }
 
-static int freezer_prepare(struct ckpt_ctx *ctx)
+static int freezer_prepare(void)
 {
 	char *freezer;
 	int fd, ret;
 
 #define FREEZER_THAWED  "THAWED"
 
-	freezer = malloc(strlen(ctx->args->freezer) + 32);
+	freezer = malloc(strlen(ctx.args->freezer) + 32);
 	if (!freezer) {
 		perror("malloc freezer buf");
 		return -1;
 	}
 
-	sprintf(freezer, "%s/freezer.state", ctx->args->freezer);
+	sprintf(freezer, "%s/freezer.state", ctx.args->freezer);
 
 	fd = open(freezer, O_WRONLY, 0);
 	if (fd < 0) {
@@ -691,19 +690,19 @@ static int freezer_prepare(struct ckpt_ctx *ctx)
 		exit(1);
 	}
 
-	sprintf(freezer, "%s/tasks", ctx->args->freezer);
-	ctx->freezer = freezer;
+	sprintf(freezer, "%s/tasks", ctx.args->freezer);
+	ctx.freezer = freezer;
 	close(fd);
 	return 0;
 }
 
-static int freezer_register(struct ckpt_ctx *ctx, pid_t pid)
+static int freezer_register(pid_t pid)
 {
 	char pidstr[16];
 	int fd, n, ret;
 
 
-	fd = open(ctx->freezer, O_WRONLY, 0);
+	fd = open(ctx.freezer, O_WRONLY, 0);
 	if (fd < 0) {
 		perror("freezer path");
 		return -1;
@@ -724,12 +723,10 @@ static int freezer_register(struct ckpt_ctx *ctx, pid_t pid)
 
 int main(int argc, char *argv[])
 {
-	struct ckpt_ctx ctx;
 	struct args args;
 	int ret;
 
 	memset(&ctx, 0, sizeof(ctx));
-
 	parse_args(&args, argc, argv);
 	ctx.args = &args;
 
@@ -767,7 +764,7 @@ int main(int argc, char *argv[])
 		args.logfd = CHECKPOINT_FD_NONE;
 
 	/* freezer preparation */
-	if (args.freezer && freezer_prepare(&ctx) < 0)
+	if (args.freezer && freezer_prepare() < 0)
 		exit(1);
 
 	/* private mounts namespace ? */
@@ -792,39 +789,39 @@ int main(int argc, char *argv[])
 
 	setpgrp();
 
-	ret = ckpt_read_header(&ctx);
+	ret = ckpt_read_header();
 	if (ret < 0) {
 		perror("read c/r header");
 		exit(1);
 	}
 		
-	ret = ckpt_read_header_arch(&ctx);
+	ret = ckpt_read_header_arch();
 	if (ret < 0) {
 		perror("read c/r header arch");
 		exit(1);
 	}
 
-	ret = ckpt_read_container(&ctx);
+	ret = ckpt_read_container();
 	if (ret < 0) {
 		perror("read c/r container section");
 		exit(1);
 	}
 
-	ret = ckpt_read_tree(&ctx);
+	ret = ckpt_read_tree();
 	if (ret < 0) {
 		perror("read c/r tree");
 		exit(1);
 	}
 
 	/* build creator-child-relationship tree */
-	if (hash_init(&ctx) < 0)
+	if (hash_init() < 0)
 		exit(1);
-	ret = ckpt_build_tree(&ctx);
-	hash_exit(&ctx);
+	ret = ckpt_build_tree();
+	hash_exit();
 	if (ret < 0)
 		exit(1);
 
-	ret = ckpt_fork_feeder(&ctx);
+	ret = ckpt_fork_feeder();
 	if (ret < 0)
 		exit(1);
 
@@ -832,18 +829,18 @@ int main(int argc, char *argv[])
 		ckpt_dbg("new pidns without init\n");
 		if (global_send_sigint == -1)
 			global_send_sigint = SIGINT;
-		ret = ckpt_coordinator_pidns(&ctx);
+		ret = ckpt_coordinator_pidns();
 	} else if (ctx.args->pidns) {
 		ckpt_dbg("new pidns with init\n");
 		ctx.tasks_arr[0].flags |= TASK_NEWPID;
 		if (global_send_sigint == -1)
 			global_send_sigint = SIGKILL;
-		ret = ckpt_coordinator(&ctx);
+		ret = ckpt_coordinator();
 	} else {
 		ckpt_dbg("subtree (existing pidns)\n");
 		if (global_send_sigint == -1)
 			global_send_sigint = SIGINT;
-		ret = ckpt_coordinator(&ctx);
+		ret = ckpt_coordinator();
 	}
 
 	return ret;
@@ -882,10 +879,10 @@ static int ckpt_parse_status(int status, int mimic, int verbose)
 	return 0;
 }
 
-static int ckpt_collect_child(struct ckpt_ctx *ctx)
+static int ckpt_collect_child(void)
 {
-	int mimic = ctx->args->copy_status;
-	int verbose = ctx->args->show_status;
+	int mimic = ctx.args->copy_status;
+	int verbose = ctx.args->show_status;
 	int status;
 	pid_t pid;
 
@@ -943,7 +940,7 @@ static int ckpt_close_files(void)
 	return 0;
 }
 
-static int ckpt_pretend_reaper(struct ckpt_ctx *ctx)
+static int ckpt_pretend_reaper(void)
 {
 	int status;
 	pid_t pid;
@@ -982,24 +979,22 @@ static int ckpt_probe_child(pid_t pid, char *str)
 }
 
 #ifdef CLONE_NEWPID
-static int __ckpt_coordinator(void *arg)
+static int __ckpt_coordinator(void *ignored_arg)
 {
-	struct ckpt_ctx *ctx = (struct ckpt_ctx *) arg;
-
-	if (!ctx->args->wait)
-		close(ctx->pipe_coord[0]);
+	if (!ctx.args->wait)
+		close(ctx.pipe_coord[0]);
 
-	return ckpt_coordinator(ctx);
+	return ckpt_coordinator();
 }
 
-static int ckpt_coordinator_status(struct ckpt_ctx *ctx)
+static int ckpt_coordinator_status(void)
 {
 	int status = -1;
 	int ret;
 
-	close(ctx->pipe_coord[1]);
+	close(ctx.pipe_coord[1]);
 
-	ret = read(ctx->pipe_coord[0], &status, sizeof(status));
+	ret = read(ctx.pipe_coord[0], &status, sizeof(status));
 	if (ret < 0)
 		perror("read coordinator status");
 	else if (ret == 0) {
@@ -1008,11 +1003,11 @@ static int ckpt_coordinator_status(struct ckpt_ctx *ctx)
 	} else
 		status = 0;
 
-	close(ctx->pipe_coord[0]);
+	close(ctx.pipe_coord[0]);
 	return status;
 }
 
-static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
+static int ckpt_coordinator_pidns(void)
 {
 	pid_t coord_pid;
 	int copy, ret;
@@ -1027,7 +1022,7 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	 * of --wait --copy-status it is already used to report the
 	 * root-task's return value).
 	 */
-	if (pipe(ctx->pipe_coord) < 0) {
+	if (pipe(ctx.pipe_coord) < 0) {
 		perror("pipe");
 		return -1;
 	}
@@ -1039,10 +1034,10 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	}
 	sp = genstack_sp(stk);
 
-	copy = ctx->args->copy_status;
-	ctx->args->copy_status = 1;
+	copy = ctx.args->copy_status;
+	ctx.args->copy_status = 1;
 
-	coord_pid = clone(__ckpt_coordinator, sp, CLONE_NEWPID|SIGCHLD, ctx);
+	coord_pid = clone(__ckpt_coordinator, sp, CLONE_NEWPID|SIGCHLD, NULL);
 	genstack_release(stk);
 	if (coord_pid < 0) {
 		perror("clone coordinator");
@@ -1062,30 +1057,30 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	if (ckpt_probe_child(coord_pid, "coordinator") < 0)
 		return -1;
 
-	ctx->args->copy_status = copy;
+	ctx.args->copy_status = copy;
 
-	ret = ckpt_coordinator_status(ctx);
+	ret = ckpt_coordinator_status();
 
-	if (ret == 0 && ctx->args->wait)
-		ret = ckpt_collect_child(ctx);
+	if (ret == 0 && ctx.args->wait)
+		ret = ckpt_collect_child();
 
 	return ret;
 }
 #else
-static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
+static int ckpt_coordinator_pidns(void)
 {
 	printf("logical error: ckpt_coordinator_pidns unexpected\n");
 	exit(1);
 }
 #endif
 
-static int ckpt_coordinator(struct ckpt_ctx *ctx)
+static int ckpt_coordinator(void)
 {
 	unsigned long flags = 0;
 	pid_t root_pid;
 	int ret;
 
-	root_pid = ckpt_fork_child(ctx, &ctx->tasks_arr[0]);
+	root_pid = ckpt_fork_child(&ctx.tasks_arr[0]);
 	if (root_pid < 0)
 		exit(1);
 	global_child_pid = root_pid;
@@ -1102,12 +1097,12 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 	if (ckpt_probe_child(root_pid, "root task") < 0)
 		exit(1);
 
-	if (ctx->args->freezer)
+	if (ctx.args->freezer)
 		flags |= RESTART_FROZEN;
-	if (ctx->args->keep_lsm)
+	if (ctx.args->keep_lsm)
 		flags |= RESTART_KEEP_LSM;
 
-	ret = restart(root_pid, STDIN_FILENO, flags, ctx->args->logfd);
+	ret = restart(root_pid, STDIN_FILENO, flags, ctx.args->logfd);
 
 	if (ret < 0) {
 		perror("restart failed");
@@ -1121,9 +1116,9 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 
 	ret = 0;
 
-	if (ctx->args->pidns && ctx->tasks_arr[0].pid != 1) {
+	if (ctx.args->pidns && ctx.tasks_arr[0].pid != 1) {
 		/* Report success/failure to the parent */
-		if (write(ctx->pipe_coord[1], &ret, sizeof(ret)) < 0) {
+		if (write(ctx.pipe_coord[1], &ret, sizeof(ret)) < 0) {
 			perror("failed to report status");
 			exit(1);
 		}
@@ -1144,9 +1139,9 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 		 * around and be reaper until all tasks are gone.
 		 * Otherwise, container will die as soon as we exit.
 		 */
-		ret = ckpt_pretend_reaper(ctx);
-	} else if (ctx->args->wait) {
-		ret = ckpt_collect_child(ctx);
+		ret = ckpt_pretend_reaper();
+	} else if (ctx.args->wait) {
+		ret = ckpt_collect_child();
 	}
 
 	if (ret < 0)
@@ -1157,16 +1152,16 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 	return ret;
 }
 
-static inline struct task *ckpt_init_task(struct ckpt_ctx *ctx)
+static inline struct task *ckpt_init_task(void)
 {
-	return (&ctx->tasks_arr[0]);
+	return (&ctx.tasks_arr[0]);
 }
 
 /*
  * ckpt_build_tree - build the task tree data structure which provides
  * the "instructions" to re-create the task tree
  */
-static int ckpt_build_tree(struct ckpt_ctx *ctx)
+static int ckpt_build_tree(void)
 {
 	struct task *task;
 	int i;
@@ -1177,36 +1172,36 @@ static int ckpt_build_tree(struct ckpt_ctx *ctx)
 	 * most two: session and process group IDs), as well as for
 	 * placeholder tasks (each session id may have at most one)
 	 */
-	ctx->tasks_max = ctx->pids_nr * 4;
-	ctx->tasks_arr = malloc(sizeof(*ctx->tasks_arr) * ctx->tasks_max);
-	if (!ctx->tasks_arr) {
+	ctx.tasks_max = ctx.pids_nr * 4;
+	ctx.tasks_arr = malloc(sizeof(*ctx.tasks_arr) * ctx.tasks_max);
+	if (!ctx.tasks_arr) {
 		perror("malloc tasks array");
 		return -1;
 	}
 
 	/* initialize tree */
-	if (ckpt_init_tree(ctx) < 0) {
-		free(ctx->tasks_arr);
-		ctx->tasks_arr = NULL;
+	if (ckpt_init_tree() < 0) {
+		free(ctx.tasks_arr);
+		ctx.tasks_arr = NULL;
 		return -1;
 	}
 
 	/* assign a creator to each task */
-	for (i = 0; i < ctx->tasks_nr; i++) {
-		task = &ctx->tasks_arr[i];
+	for (i = 0; i < ctx.tasks_nr; i++) {
+		task = &ctx.tasks_arr[i];
 		if (task->creator)
 			continue;
-		if (ckpt_set_creator(ctx, task) < 0) {
-			free(ctx->tasks_arr);
-			ctx->tasks_arr = NULL;
+		if (ckpt_set_creator(task) < 0) {
+			free(ctx.tasks_arr);
+			ctx.tasks_arr = NULL;
 			return -1;
 		}
 	}
 
 #ifdef CHECKPOINT_DEBUG
 	ckpt_dbg("====== TASKS\n");
-	for (i = 0; i < ctx->tasks_nr; i++) {
-		task = &ctx->tasks_arr[i];
+	for (i = 0; i < ctx.tasks_nr; i++) {
+		task = &ctx.tasks_arr[i];
 		ckpt_dbg("\t[%d] pid %d ppid %d sid %d creator %d",
 			 i, task->pid, task->ppid, task->sid,
 			 task->creator->pid);
@@ -1231,17 +1226,17 @@ static int ckpt_build_tree(struct ckpt_ctx *ctx)
 	return 0;
 }		
 
-static int ckpt_setup_task(struct ckpt_ctx *ctx, pid_t pid, pid_t ppid)
+static int ckpt_setup_task(pid_t pid, pid_t ppid)
 {
 	struct task *task;
 
 	if (pid == 0)  /* ignore if outside namespace */
 		return 0;
 
-	if (hash_lookup(ctx, pid))  /* already handled */
+	if (hash_lookup(pid))  /* already handled */
 		return 0;
 
-	task = &ctx->tasks_arr[ctx->tasks_nr++];
+	task = &ctx.tasks_arr[ctx.tasks_nr++];
 
 	task->flags = TASK_GHOST;
 
@@ -1257,30 +1252,29 @@ static int ckpt_setup_task(struct ckpt_ctx *ctx, pid_t pid, pid_t ppid)
 	task->phantom = NULL;
 
 	task->rpid = -1;
-	task->ctx = ctx;
 
-	if (hash_insert(ctx, pid, task) < 0)
+	if (hash_insert(pid, task) < 0)
 		return -1;
 
 	/* remember the max pid seen */
-	if (task->pid > ctx->tasks_pid)
-		ctx->tasks_pid = task->pid;
+	if (task->pid > ctx.tasks_pid)
+		ctx.tasks_pid = task->pid;
 
 	return 0;
 }
 
-static int ckpt_valid_pid(struct ckpt_ctx *ctx, pid_t pid, char *which, int i)
+static int ckpt_valid_pid(pid_t pid, char *which, int i)
 {
 	if (pid < 0) {
 		ckpt_err("Invalid %s %d (for task#%d)\n", which, pid, i);
 		return 0;
 	}
-	if (!ctx->args->pidns && pid == 0) {
-		if (ckpt_cond_fail(ctx, CKPT_COND_PIDZERO)) {
+	if (!ctx.args->pidns && pid == 0) {
+		if (ckpt_cond_fail(CKPT_COND_PIDZERO)) {
 			ckpt_err("[err] task # %d with %s zero"
 				 " (requires --pidns)\n", i + 1, which);
 			return 0;
-		} else if (ckpt_cond_warn(ctx, CKPT_COND_PIDZERO)) {
+		} else if (ckpt_cond_warn(CKPT_COND_PIDZERO)) {
 			ckpt_err("[warn] task # %d with %s zero"
 				 " (consider --pidns)\n", i + 1, which);
 		}
@@ -1288,7 +1282,7 @@ static int ckpt_valid_pid(struct ckpt_ctx *ctx, pid_t pid, char *which, int i)
 	return 1;
 }
 
-static int ckpt_alloc_pid(struct ckpt_ctx *ctx)
+static int ckpt_alloc_pid(void)
 {
 	int n = 0;
 
@@ -1297,36 +1291,36 @@ static int ckpt_alloc_pid(struct ckpt_ctx *ctx)
 	 * (this will become inefficient if pid-space is exhausted)
 	 */
 	do {
-		if (ctx->tasks_pid == INT_MAX)
-			ctx->tasks_pid = 2;
+		if (ctx.tasks_pid == INT_MAX)
+			ctx.tasks_pid = 2;
 		else
-			ctx->tasks_pid++;
+			ctx.tasks_pid++;
 
 		if (n++ == INT_MAX) {	/* ohhh... */
 			ckpt_err("pid namsepace exhausted");
 			return -1;
 		}
-	} while (hash_lookup(ctx, ctx->tasks_pid));
+	} while (hash_lookup(ctx.tasks_pid));
 
-	return ctx->tasks_pid;
+	return ctx.tasks_pid;
 }
 
-static int ckpt_zero_pid(struct ckpt_ctx *ctx)
+static int ckpt_zero_pid(void)
 {
 	pid_t pid;
 
-	pid = ckpt_alloc_pid(ctx);
+	pid = ckpt_alloc_pid();
 	if (pid < 0)
 		return -1;
-	if (ckpt_setup_task(ctx, pid, ctx->pids_arr[0].vpid) < 0)
+	if (ckpt_setup_task(pid, ctx.pids_arr[0].vpid) < 0)
 		return -1;
 	return pid;
 }
 
-static int ckpt_init_tree(struct ckpt_ctx *ctx)
+static int ckpt_init_tree(void)
 {
-	struct ckpt_pids *pids_arr = ctx->pids_arr;
-	int pids_nr = ctx->pids_nr;
+	struct ckpt_pids *pids_arr = ctx.pids_arr;
+	int pids_nr = ctx.pids_nr;
 	struct task *task;
 	pid_t root_pid;
 	pid_t root_sid;
@@ -1364,17 +1358,17 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 
 	/* populate with known tasks */
 	for (i = 0; i < pids_nr; i++) {
-		task = &ctx->tasks_arr[i];
+		task = &ctx.tasks_arr[i];
 
 		task->flags = 0;
 
-		if (!ckpt_valid_pid(ctx, pids_arr[i].vpid, "pid", i))
+		if (!ckpt_valid_pid(pids_arr[i].vpid, "pid", i))
 			return -1;
-		else if (!ckpt_valid_pid(ctx, pids_arr[i].vtgid, "tgid", i))
+		else if (!ckpt_valid_pid(pids_arr[i].vtgid, "tgid", i))
 			return -1;
-		else if (!ckpt_valid_pid(ctx, pids_arr[i].vsid, "sid", i))
+		else if (!ckpt_valid_pid(pids_arr[i].vsid, "sid", i))
 			return -1;
-		else if (!ckpt_valid_pid(ctx, pids_arr[i].vpgid, "pgid", i))
+		else if (!ckpt_valid_pid(pids_arr[i].vpgid, "pgid", i))
 			return -1;
 
 		if (pids_arr[i].vsid == root_sid)
@@ -1394,13 +1388,12 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 		task->phantom = NULL;
 
 		task->rpid = -1;
-		task->ctx = ctx;
 
-		if (hash_insert(ctx, task->pid, task) < 0)
+		if (hash_insert(task->pid, task) < 0)
 			return -1;
 	}
 
-	ctx->tasks_nr = pids_nr;
+	ctx.tasks_nr = pids_nr;
 
 	/* add pids unaccounted for (no tasks) */
 	for (i = 0; i < pids_nr; i++) {
@@ -1416,7 +1409,7 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 		 * session leader and died. We can safe set its parent
 		 * (and creator) to be the root task.
 		 */
-		if (ckpt_setup_task(ctx, sid, root_pid) < 0)
+		if (ckpt_setup_task(sid, root_pid) < 0)
 			return -1;
 
 		/*
@@ -1432,7 +1425,7 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 		 * need to add it with the same sid as current (and
 		 * other) threads.
 		 */
-		if (ckpt_setup_task(ctx, pids_arr[i].vtgid, sid) < 0)
+		if (ckpt_setup_task(pids_arr[i].vtgid, sid) < 0)
 			return -1;
 
 		/*
@@ -1443,7 +1436,7 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 		 * same sid as us: all tasks with same pgrp must have
 		 * their sid matching.
 		 */
-		if (ckpt_setup_task(ctx, pids_arr[i].vpgid, sid) < 0)
+		if (ckpt_setup_task(pids_arr[i].vpgid, sid) < 0)
 			return -1;
 	}
 
@@ -1452,8 +1445,8 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 	 * were any, we invent a new ghost-zero task and substitute
 	 * its pid for those any sid/pgid.
 	 */
-	if (zero_pid && !ctx->args->pidns) {
-		zero_pid = ckpt_zero_pid(ctx);
+	if (zero_pid && !ctx.args->pidns) {
+		zero_pid = ckpt_zero_pid();
 		if (zero_pid < 0)
 			return -1;
 		for (i = 0; i < pids_nr; i++) {
@@ -1469,10 +1462,10 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 	}
 
 	/* mark root task(s), and set its "creator" to be zero_task */
-	ckpt_init_task(ctx)->flags |= TASK_ROOT;
-	ckpt_init_task(ctx)->creator = &zero_task;
+	ckpt_init_task()->flags |= TASK_ROOT;
+	ckpt_init_task()->creator = &zero_task;
 
-	ckpt_dbg("total tasks (including ghosts): %d\n", ctx->tasks_nr);
+	ckpt_dbg("total tasks (including ghosts): %d\n", ctx.tasks_nr);
 	return 0;
 }
 
@@ -1541,25 +1534,25 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
  * leader.  This is done using a placeholder in a manner similar to
  * how we handle orphans that are not session leaders.
  */
-static int ckpt_set_creator(struct ckpt_ctx *ctx, struct task *task)
+static int ckpt_set_creator(struct task *task)
 {
-	struct task *session = hash_lookup(ctx, task->sid);
-	struct task *parent = hash_lookup(ctx, task->ppid);
+	struct task *session = hash_lookup(task->sid);
+	struct task *parent = hash_lookup(task->ppid);
 	struct task *creator;
 
-	if (task == ckpt_init_task(ctx)) {
-		ckpt_err("pid %d: logical error\n", ckpt_init_task(ctx)->pid);
+	if (task == ckpt_init_task()) {
+		ckpt_err("pid %d: logical error\n", ckpt_init_task()->pid);
 		return -1;
 	}
 
 	/* sid == 0 must have been inherited from outside the container */
 	if (task->sid == 0)
-		session = ckpt_init_task(ctx);
+		session = ckpt_init_task();
 
 	if (task->tgid != task->pid) {
 		/* thread: creator is thread-group-leader */
 		ckpt_dbg("pid %d: thread tgid %d\n", task->pid, task->tgid);
-		creator = hash_lookup(ctx, task->tgid);
+		creator = hash_lookup(task->tgid);
 		if (!creator) {
 			/* oops... thread group leader MIA */
 			ckpt_err("pid %d: no leader %d\n", task->pid, task->tgid);
@@ -1586,7 +1579,7 @@ static int ckpt_set_creator(struct ckpt_ctx *ctx, struct task *task)
 		/* (non-session-leader) orphan: creator is dummy */
 		ckpt_dbg("pid %d: orphan session %d\n", task->pid, task->sid);
 		if (!session->phantom)
-			if (ckpt_placeholder_task(ctx, task) < 0)
+			if (ckpt_placeholder_task(task) < 0)
 				return -1;
 		creator = session->phantom;
 	} else {
@@ -1595,13 +1588,13 @@ static int ckpt_set_creator(struct ckpt_ctx *ctx, struct task *task)
 			/* (non-session-leader) recursive: session's creator */
 			ckpt_dbg("pid %d: recursive session creator %d\n",
 			       task->pid, task->sid);
-			if (ckpt_set_creator(ctx, session) < 0)
+			if (ckpt_set_creator(session) < 0)
 				return -1;
 		}
 		/* then use it to decide what to do */
 		if (session->creator->pid == task->ppid) {
 			/* init must not be sibling creator (CLONE_PARENT) */
-			if (session == ckpt_init_task(ctx)) {
+			if (session == ckpt_init_task()) {
 				ckpt_err("pid %d: sibling session prohibited"
 				       " with init as creator\n", task->pid);
 				return -1;
@@ -1632,32 +1625,32 @@ static int ckpt_set_creator(struct ckpt_ctx *ctx, struct task *task)
 	creator->children = task;
 
 	if (task->flags & TASK_SESSION)
-		if (ckpt_propagate_session(ctx, task) < 0)
+		if (ckpt_propagate_session(task) < 0)
 			return -1;
 
 	return 0;
 }
 
-static int ckpt_placeholder_task(struct ckpt_ctx *ctx, struct task *task)
+static int ckpt_placeholder_task(struct task *task)
 {
-	struct task *session = hash_lookup(ctx, task->sid);
-	struct task *holder = &ctx->tasks_arr[ctx->tasks_nr++];
+	struct task *session = hash_lookup(task->sid);
+	struct task *holder = &ctx.tasks_arr[ctx.tasks_nr++];
 	pid_t pid;
 
-	if (ctx->tasks_nr > ctx->tasks_max) {
+	if (ctx.tasks_nr > ctx.tasks_max) {
 		/* shouldn't happen, beacuse we prepared enough */
 		ckpt_err("out of space in task table !");
 		return -1;
 	}
 
-	pid = ckpt_alloc_pid(ctx);
+	pid = ckpt_alloc_pid();
 	if (pid < 0)
 		return -1;
 
 	holder->flags = TASK_DEAD;
 
 	holder->pid = pid;
-	holder->ppid = ckpt_init_task(ctx)->pid;
+	holder->ppid = ckpt_init_task()->pid;
 	holder->tgid = pid;
 	holder->sid = task->sid;
 
@@ -1668,7 +1661,6 @@ static int ckpt_placeholder_task(struct ckpt_ctx *ctx, struct task *task)
 	holder->phantom = NULL;
 
 	holder->rpid = -1;
-	holder->ctx = ctx;
 
 	holder->creator = session;
 	if (session->children) {
@@ -1693,9 +1685,9 @@ static int ckpt_placeholder_task(struct ckpt_ctx *ctx, struct task *task)
 	return 0;
 }
 
-static int ckpt_propagate_session(struct ckpt_ctx *ctx, struct task *task)
+static int ckpt_propagate_session(struct task *task)
 {
-	struct task *session = hash_lookup(ctx, task->sid);
+	struct task *session = hash_lookup(task->sid);
 	struct task *creator;
 	pid_t sid = task->sid;
 
@@ -1705,7 +1697,7 @@ static int ckpt_propagate_session(struct ckpt_ctx *ctx, struct task *task)
 
 		creator = task->creator;
 		if (creator->pid == 1) {
-			if (ckpt_placeholder_task(ctx, task) < 0)
+			if (ckpt_placeholder_task(task) < 0)
 				return -1;
 		}
 
@@ -1713,11 +1705,11 @@ static int ckpt_propagate_session(struct ckpt_ctx *ctx, struct task *task)
 		task = creator;
 
 		if(!task->creator) {
-			if (ckpt_set_creator(ctx, task) < 0)
+			if (ckpt_set_creator(task) < 0)
 				return -1;
 		}
 	} while (task->sid != sid &&
-		 task != ckpt_init_task(ctx) &&
+		 task != ckpt_init_task() &&
 		 !(task->flags & TASK_SESSION) &&
 		 task->creator != session);
 
@@ -1754,7 +1746,7 @@ static int ckpt_propagate_session(struct ckpt_ctx *ctx, struct task *task)
  * anyway; both use flag RESTART_GHOST for sys_restart(), which will
  * result in a call to do_exit().
  */
-static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
+static int ckpt_make_tree(struct task *task)
 {
 	struct task *child;
 	struct pid_swap swap;
@@ -1770,7 +1762,7 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 		if (child->flags & TASK_SESSION) {
 			ckpt_dbg("pid %d: fork child %d with session\n",
 			       task->pid, child->pid);
-			newpid = ckpt_fork_child(ctx, child);
+			newpid = ckpt_fork_child(child);
 			if (newpid < 0)
 				return -1;
 			child->rpid = newpid;
@@ -1780,7 +1772,7 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 	/* change session id, if necessary */
 	if (task->pid == task->sid) {
 		ret = setsid();
-		if (ret < 0 && task != ckpt_init_task(ctx)) {
+		if (ret < 0 && task != ckpt_init_task()) {
 			perror("setsid");
 			return -1;
 		}
@@ -1791,7 +1783,7 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 		if (!(child->flags & TASK_SESSION)) {
 			ckpt_dbg("pid %d: fork child %d without session\n",
 			       task->pid, child->pid);
-			newpid = ckpt_fork_child(ctx, child);
+			newpid = ckpt_fork_child(child);
 			if (newpid < 0)
 				return -1;
 			child->rpid = newpid;
@@ -1812,12 +1804,12 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 	/* communicate via pipe that all is well */
 	swap.old = task->pid;
 	swap.new = _gettid();
-	ret = write(ctx->pipe_out, &swap, sizeof(swap));
+	ret = write(ctx.pipe_out, &swap, sizeof(swap));
 	if (ret != sizeof(swap)) {
 		perror("write swap");
 		return -1;
 	}
-	close(ctx->pipe_out);
+	close(ctx.pipe_out);
 
 	/*
 	 * At this point restart may have already begun in the kernel.
@@ -1848,7 +1840,6 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 int ckpt_fork_stub(void *data)
 {
 	struct task *task = (struct task *) data;
-	struct ckpt_ctx *ctx = task->ctx;
 
 	/*
 	 * In restart into a new pid namespace (--pidns), coordinator
@@ -1867,7 +1858,7 @@ int ckpt_fork_stub(void *data)
 	 * Thus, if a the parent of this task dies before this prctl()
 	 * call, it suffices to test getppid() == task->parent_pid.
 	 */
-	if (!ctx->args->pidns) {
+	if (!ctx.args->pidns) {
 		if (prctl(PR_SET_PDEATHSIG, SIGKILL, 0, 0, 0) < 0) {
 			perror("prctl");
 			return -1;
@@ -1880,21 +1871,21 @@ int ckpt_fork_stub(void *data)
 	}
 
 	/* if user requested freeze at end - add ourself to cgroup */
-	if (ctx->args->freezer && freezer_register(ctx, _getpid())) {
+	if (ctx.args->freezer && freezer_register(_getpid())) {
 		ckpt_err("[%d]: failed add to freezer cgroup\n", _getpid());
 		return -1;
 	}
 
 	/* root has some extra work */
 	if (task->flags & TASK_ROOT) {
-		ctx->root_pid = _getpid();
+		ctx.root_pid = _getpid();
 		ckpt_dbg("root task pid %d\n", _getpid());
 	}
 
-	return ckpt_make_tree(ctx, task);
+	return ckpt_make_tree(task);
 }
 
-static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
+static pid_t ckpt_fork_child(struct task *child)
 {
 	struct clone_args clone_args;
 	genstack stk;
@@ -1917,7 +1908,7 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 	}
 
 	/* select pid if --pids, otherwise it's 0 */
-	if (ctx->args->pids)
+	if (ctx.args->pids)
 		pid = child->pid;
 
 #ifdef CLONE_NEWPID
@@ -1961,17 +1952,17 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
  * only for '--no-pids', but now also ensures that all restarting
  * tasks are created by the time coordinator calls restart(2).
  */
-static int ckpt_fork_feeder(struct ckpt_ctx *ctx)
+static int ckpt_fork_feeder(void)
 {
 	genstack stk;
 	pid_t pid;
 
-	if (pipe(ctx->pipe_feed)) {
+	if (pipe(ctx.pipe_feed)) {
 		perror("pipe");
 		exit(1);
 	}
 
-	if (pipe(ctx->pipe_child) < 0) {
+	if (pipe(ctx.pipe_child) < 0) {
 		perror("pipe");
 		exit(1);
 	}
@@ -1989,52 +1980,52 @@ static int ckpt_fork_feeder(struct ckpt_ctx *ctx)
 	}
 
 	pid = clone(ckpt_do_feeder, genstack_sp(stk),
-		    CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, ctx);
+		    CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL);
 	if (pid < 0) {
 		perror("feeder thread");
 		return -1;
 	}
 
 	/* children pipe */
-	close(ctx->pipe_child[0]);
-	ctx->pipe_out = ctx->pipe_child[1];
+	close(ctx.pipe_child[0]);
+	ctx.pipe_out = ctx.pipe_child[1];
 	/* feeder pipe */
-	close(ctx->pipe_feed[1]);
-	if (ctx->pipe_feed[0] != STDIN_FILENO) {
-		dup2(ctx->pipe_feed[0], STDIN_FILENO);
-		close(ctx->pipe_feed[0]);
+	close(ctx.pipe_feed[1]);
+	if (ctx.pipe_feed[0] != STDIN_FILENO) {
+		dup2(ctx.pipe_feed[0], STDIN_FILENO);
+		close(ctx.pipe_feed[0]);
 	}
 
 	return 0;
 }
 
-static void ckpt_abort(struct ckpt_ctx *ctx, char *str)
+static void ckpt_abort(char *str)
 {
 	perror(str);
-	kill(-(ctx->root_pid), SIGKILL);
+	kill(-(ctx.root_pid), SIGKILL);
 	exit(1);
 }
 
 /* read/write image data as is, blindly */
-static void ckpt_read_write_blind(struct ckpt_ctx *ctx)
+static void ckpt_read_write_blind(void)
 {
 	int ret;
 
 	while (1) {
-		ret = read(STDIN_FILENO, ctx->buf, BUFSIZE);
+		ret = read(STDIN_FILENO, ctx.buf, BUFSIZE);
 		ckpt_dbg("c/r read input %d\n", ret);
 		if (ret == 0)
 			break;
 		if (ret < 0)
-			ckpt_abort(ctx, "read input");
-		ret = ckpt_write(STDOUT_FILENO, ctx->buf, ret);
+			ckpt_abort("read input");
+		ret = ckpt_write(STDOUT_FILENO, ctx.buf, ret);
 		if (ret < 0)
-			ckpt_abort(ctx, "write output");
+			ckpt_abort("write output");
 	}
 }
 
 /* read/write image data while inspecting it */
-static void ckpt_read_write_inspect(struct ckpt_ctx *ctx)
+static void ckpt_read_write_inspect(void)
 {
 	struct ckpt_hdr h;
 	int len, ret;
@@ -2045,41 +2036,41 @@ ckpt_dbg("ret %d len %d type %d\n", ret, h.len, h.type);
 		if (ret == 0)
 			break;
 		if (ret < 0)
-			ckpt_abort(ctx, "read input");
+			ckpt_abort("read input");
 		if (h.len < sizeof(h)) {
 			errno = EINVAL;
-			ckpt_abort(ctx, "invalid record");
+			ckpt_abort("invalid record");
 		}
 
 		ret = ckpt_write(STDOUT_FILENO, &h, sizeof(h));
 		if (ret < 0)
-			ckpt_abort(ctx, "write output");
+			ckpt_abort("write output");
 
 		h.len -= sizeof(h);
 		if (h.type == CKPT_HDR_ERROR) {
 			len = (h.len > BUFSIZE ? BUFSIZE : h.len);
-			ret = read(STDIN_FILENO, ctx->buf, len);
+			ret = read(STDIN_FILENO, ctx.buf, len);
 			if (ret < 0)
-				ckpt_abort(ctx, "error record");
+				ckpt_abort("error record");
 			errno = EIO;
-			ctx->buf[len - 1] = '\0';
-			ckpt_abort(ctx, &ctx->buf[1]);
+			ctx.buf[len - 1] = '\0';
+			ckpt_abort(&ctx.buf[1]);
 		}
 		ckpt_dbg("c/r read input %d\n", h.len);
 
 		while (h.len) {
 			len = (h.len > BUFSIZE ? BUFSIZE : h.len);
-			ret = read(STDIN_FILENO, ctx->buf, len);
+			ret = read(STDIN_FILENO, ctx.buf, len);
 			if (ret == 0)
-				ckpt_abort(ctx, "short record");
+				ckpt_abort("short record");
 			if (ret < 0)
-				ckpt_abort(ctx, "read input");
+				ckpt_abort("read input");
 
 			h.len -= ret;
-			ret = ckpt_write(STDOUT_FILENO, ctx->buf, ret);
+			ret = ckpt_write(STDOUT_FILENO, ctx.buf, ret);
 ckpt_dbg("write len %d (%d)\n", len, ret);
 			if (ret < 0)
-				ckpt_abort(ctx, "write output");
+				ckpt_abort("write output");
 		}
 	}
 }
@@ -2089,40 +2080,38 @@ ckpt_dbg("write len %d (%d)\n", len, ret);
  * In '--no-pids' mode, transform the pids array (struct ckpt_pids)
  * on the fly and feed the result to the "init" task of the restart
  */
-static int ckpt_do_feeder(void *data)
+static int ckpt_do_feeder(void *ignored_arg)
 {
-	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
-
 	/* children pipe */
-	close(ctx->pipe_child[1]);
-	ctx->pipe_in = ctx->pipe_child[0];
+	close(ctx.pipe_child[1]);
+	ctx.pipe_in = ctx.pipe_child[0];
 	/* feeder pipe */
-	close(ctx->pipe_feed[0]);
-	if (ctx->pipe_feed[1] != STDOUT_FILENO) {
-		dup2(ctx->pipe_feed[1], STDOUT_FILENO);
-		close(ctx->pipe_feed[1]);
+	close(ctx.pipe_feed[0]);
+	if (ctx.pipe_feed[1] != STDOUT_FILENO) {
+		dup2(ctx.pipe_feed[1], STDOUT_FILENO);
+		close(ctx.pipe_feed[1]);
 	}
 
-	if (ckpt_adjust_pids(ctx) < 0)
-		ckpt_abort(ctx, "collect pids");
+	if (ckpt_adjust_pids() < 0)
+		ckpt_abort("collect pids");
 
-	if (ckpt_write_header(ctx) < 0)
-		ckpt_abort(ctx, "write c/r header");
+	if (ckpt_write_header() < 0)
+		ckpt_abort("write c/r header");
 
-	if (ckpt_write_header_arch(ctx) < 0)
-		ckpt_abort(ctx, "write c/r header arch");
+	if (ckpt_write_header_arch() < 0)
+		ckpt_abort("write c/r header arch");
 
-	if (ckpt_write_container(ctx) < 0)
-		ckpt_abort(ctx, "write container section");
+	if (ckpt_write_container() < 0)
+		ckpt_abort("write container section");
 
-	if (ckpt_write_tree(ctx) < 0)
-		ckpt_abort(ctx, "write c/r tree");
+	if (ckpt_write_tree() < 0)
+		ckpt_abort("write c/r tree");
 
 	/* read rest -> write rest */
-	if (ctx->args->inspect)
-		ckpt_read_write_inspect(ctx);
+	if (ctx.args->inspect)
+		ckpt_read_write_inspect();
 	else
-		ckpt_read_write_blind(ctx);
+		ckpt_read_write_blind();
 
 	/* All is well: feeder thread is done.  However, we must
 	 * invoke the exit system call directly. Otherwise, upon
@@ -2144,7 +2133,7 @@ static int ckpt_do_feeder(void *data)
  * a 'struct pid_swap' indicating old- and new-pid. Then modify the
  * the pids array accordingly.
  */
-static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
+static int ckpt_adjust_pids(void)
 {
 	struct pid_swap swap;
 	int n, m, len, ret;
@@ -2162,53 +2151,53 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
 	 *    but correct should be: [][][B][][A][]...
 	 */
 
-	len = sizeof(struct ckpt_pids) * ctx->pids_nr;
+	len = sizeof(struct ckpt_pids) * ctx.pids_nr;
 
 #ifdef CHECKPOINT_DEBUG
 	ckpt_dbg("====== PIDS ARRAY\n");
-	for (m = 0; m < ctx->pids_nr; m++) {
+	for (m = 0; m < ctx.pids_nr; m++) {
 		struct ckpt_pids *p;
-		p = &ctx->pids_arr[m];
+		p = &ctx.pids_arr[m];
 		ckpt_dbg("[%d] pid %d ppid %d sid %d pgid %d\n",
 			 m, p->vpid, p->vppid, p->vsid, p->vpgid);
 	}
 	ckpt_dbg("............\n");
 #endif
 
-	memcpy(ctx->copy_arr, ctx->pids_arr, len);
+	memcpy(ctx.copy_arr, ctx.pids_arr, len);
 
-	/* read in 'pid_swap' data and adjust ctx->pids_arr */
-	for (n = 0; n < ctx->tasks_nr; n++) {
+	/* read in 'pid_swap' data and adjust ctx.pids_arr */
+	for (n = 0; n < ctx.tasks_nr; n++) {
 		/* get pid info from next task */
-		ret = read(ctx->pipe_in, &swap, sizeof(swap));
+		ret = read(ctx.pipe_in, &swap, sizeof(swap));
 		if (ret < 0)
-			ckpt_abort(ctx, "read pipe");
+			ckpt_abort("read pipe");
 
 		/* swapping isn't needed with '--pids' */
-		if (ctx->args->pids)
+		if (ctx.args->pids)
 			continue;
 
 		ckpt_dbg("c/r swap old %d new %d\n", swap.old, swap.new);
-		for (m = 0; m < ctx->pids_nr; m++) {
-			if (ctx->pids_arr[m].vpid == swap.old)
-				ctx->copy_arr[m].vpid = swap.new;
-			if (ctx->pids_arr[m].vtgid == swap.old)
-				ctx->copy_arr[m].vtgid = swap.new;
-			if (ctx->pids_arr[m].vsid == swap.old)
-				ctx->copy_arr[m].vsid = swap.new;
-			if (ctx->pids_arr[m].vpgid == swap.old)
-				ctx->copy_arr[m].vpgid = swap.new;
+		for (m = 0; m < ctx.pids_nr; m++) {
+			if (ctx.pids_arr[m].vpid == swap.old)
+				ctx.copy_arr[m].vpid = swap.new;
+			if (ctx.pids_arr[m].vtgid == swap.old)
+				ctx.copy_arr[m].vtgid = swap.new;
+			if (ctx.pids_arr[m].vsid == swap.old)
+				ctx.copy_arr[m].vsid = swap.new;
+			if (ctx.pids_arr[m].vpgid == swap.old)
+				ctx.copy_arr[m].vpgid = swap.new;
 		}
 	}
 
-	memcpy(ctx->pids_arr, ctx->copy_arr, len);
+	memcpy(ctx.pids_arr, ctx.copy_arr, len);
 
 #ifdef CHECKPOINT_DEBUG
-	if (!ctx->args->pids) {
+	if (!ctx.args->pids) {
 		ckpt_dbg("====== PIDS ARRAY (swaped)\n");
-		for (m = 0; m < ctx->pids_nr; m++) {
+		for (m = 0; m < ctx.pids_nr; m++) {
 			struct ckpt_pids *p;
-			p = &ctx->pids_arr[m];
+			p = &ctx.pids_arr[m];
 			ckpt_dbg("[%d] pid %d ppid %d sid %d pgid %d\n",
 				 m, p->vpid, p->vppid, p->vsid, p->vpgid);
 		}
@@ -2216,7 +2205,7 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
 	}
 #endif
 
-	close(ctx->pipe_in);
+	close(ctx.pipe_in);
 	return 0;
 }
 
@@ -2242,12 +2231,12 @@ static int ckpt_write(int fd, void *buf, int count)
 	return 0;
 }
 
-int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
+int ckpt_write_obj(struct ckpt_hdr *h)
 {
 	return ckpt_write(STDOUT_FILENO, h, h->len);
 }
 
-int ckpt_write_obj_ptr(struct ckpt_ctx *ctx, void *buf, int n, int type)
+int ckpt_write_obj_ptr(void *buf, int n, int type)
 {
 	struct ckpt_hdr h;
 	int ret;
@@ -2298,8 +2287,7 @@ static int ckpt_read(int fd, void *buf, int count)
 	return (ret < 0 ? ret : 0);
 }
 
-static int ckpt_read_obj(struct ckpt_ctx *ctx,
-			 struct ckpt_hdr *h, void *buf, int n)
+static int ckpt_read_obj(struct ckpt_hdr *h, void *buf, int n)
 {
 	int ret;
 
@@ -2313,12 +2301,12 @@ static int ckpt_read_obj(struct ckpt_ctx *ctx,
 	return ckpt_read(STDIN_FILENO, buf, h->len - sizeof(*h));
 }
 
-static int ckpt_read_obj_type(struct ckpt_ctx *ctx, void *buf, int n, int type)
+static int ckpt_read_obj_type(void *buf, int n, int type)
 {
 	struct ckpt_hdr *h = (struct ckpt_hdr *) buf;
 	int ret;
 
-	ret = ckpt_read_obj(ctx, h, (void *) (h + 1), n);
+	ret = ckpt_read_obj(h, (void *) (h + 1), n);
 	if (ret < 0)
 		return ret;
 	if (h->type != type) {
@@ -2328,12 +2316,12 @@ static int ckpt_read_obj_type(struct ckpt_ctx *ctx, void *buf, int n, int type)
 	return 0;
 }
 
-static int ckpt_read_obj_ptr(struct ckpt_ctx *ctx, void *buf, int n, int type)
+static int ckpt_read_obj_ptr(void *buf, int n, int type)
 {
 	struct ckpt_hdr h;
 	int ret;
 
-	ret = ckpt_read_obj(ctx, &h, buf, n + sizeof(h));
+	ret = ckpt_read_obj(&h, buf, n + sizeof(h));
 	if (ret < 0)
 		return ret;
 	if (h.type != type) {
@@ -2343,23 +2331,23 @@ static int ckpt_read_obj_ptr(struct ckpt_ctx *ctx, void *buf, int n, int type)
 	return 0;
 }
 
-static int ckpt_read_obj_buffer(struct ckpt_ctx *ctx, void *buf, int n)
+static int ckpt_read_obj_buffer(void *buf, int n)
 {
-	return ckpt_read_obj_type(ctx, buf, BUFSIZE, CKPT_HDR_BUFFER);
+	return ckpt_read_obj_type(buf, BUFSIZE, CKPT_HDR_BUFFER);
 }
 
 /*
  * read/write the checkpoint image: similar to in-kernel code
  */
 
-static int ckpt_read_header(struct ckpt_ctx *ctx)
+static int ckpt_read_header(void)
 {
 	struct ckpt_hdr_header *h;
 	char *ptr;
 	int ret;
 
-	h = (struct ckpt_hdr_header *) ctx->header;
-	ret = ckpt_read_obj_type(ctx, h, sizeof(*h), CKPT_HDR_HEADER);
+	h = (struct ckpt_hdr_header *) ctx.header;
+	ret = ckpt_read_obj_type(h, sizeof(*h), CKPT_HDR_HEADER);
 	if (ret < 0)
 		return ret;
 
@@ -2373,15 +2361,15 @@ static int ckpt_read_header(struct ckpt_ctx *ctx)
 	ptr = (char *) h;
 
 	ptr += ((struct ckpt_hdr *) ptr)->len;
-	ret = ckpt_read_obj_buffer(ctx, ptr, h->constants.uts_release_len);
+	ret = ckpt_read_obj_buffer(ptr, h->constants.uts_release_len);
 	if (ret < 0)
 		return ret;
 	ptr += ((struct ckpt_hdr *) ptr)->len;
-	ret = ckpt_read_obj_buffer(ctx, ptr, h->constants.uts_version_len);
+	ret = ckpt_read_obj_buffer(ptr, h->constants.uts_version_len);
 	if (ret < 0)
 		return ret;
 	ptr += ((struct ckpt_hdr *) ptr)->len;
-	ret = ckpt_read_obj_buffer(ctx, ptr, h->constants.uts_machine_len);
+	ret = ckpt_read_obj_buffer(ptr, h->constants.uts_machine_len);
 	if (ret < 0)
 		return ret;
 
@@ -2390,47 +2378,47 @@ static int ckpt_read_header(struct ckpt_ctx *ctx)
 	return 0;
 }
 
-static int ckpt_read_header_arch(struct ckpt_ctx *ctx)
+static int ckpt_read_header_arch(void)
 {
 	struct ckpt_hdr_header_arch *h;
 	int ret;
 
-	h = (struct ckpt_hdr_header_arch *) ctx->header_arch;
-	ret = ckpt_read_obj_type(ctx, h, sizeof(*h), CKPT_HDR_HEADER_ARCH);
+	h = (struct ckpt_hdr_header_arch *) ctx.header_arch;
+	ret = ckpt_read_obj_type(h, sizeof(*h), CKPT_HDR_HEADER_ARCH);
 	if (ret < 0)
 		return ret;
 
 	return 0;
 }
 
-static int ckpt_read_container(struct ckpt_ctx *ctx)
+static int ckpt_read_container(void)
 {
 	struct ckpt_hdr_container *h;
 	char *ptr;
 	int ret;
 
-	h = (struct ckpt_hdr_container *) ctx->container;
-	ret = ckpt_read_obj_type(ctx, h, sizeof(*h), CKPT_HDR_CONTAINER);
+	h = (struct ckpt_hdr_container *) ctx.container;
+	ret = ckpt_read_obj_type(h, sizeof(*h), CKPT_HDR_CONTAINER);
 	if (ret < 0)
 		return ret;
 
 	ptr = (char *) h;
 	ptr += ((struct ckpt_hdr *) ptr)->len;
-	ret = ckpt_read_obj_buffer(ctx, ptr, CHECKPOINT_LSM_NAME_MAX + 1);
+	ret = ckpt_read_obj_buffer(ptr, CHECKPOINT_LSM_NAME_MAX + 1);
 	if (ret < 0)
 		return ret;
 
 	ptr += ((struct ckpt_hdr *) ptr)->len;
-	return ckpt_read_obj_type(ctx, ptr, 200, CKPT_HDR_LSM_INFO);
+	return ckpt_read_obj_type(ptr, 200, CKPT_HDR_LSM_INFO);
 }
 
-static int ckpt_read_tree(struct ckpt_ctx *ctx)
+static int ckpt_read_tree(void)
 {
 	struct ckpt_hdr_tree *h;
 	int len, ret;
 
-	h = (struct ckpt_hdr_tree *) ctx->tree;
-	ret = ckpt_read_obj_type(ctx, h, sizeof(*h), CKPT_HDR_TREE);
+	h = (struct ckpt_hdr_tree *) ctx.tree;
+	ret = ckpt_read_obj_type(h, sizeof(*h), CKPT_HDR_TREE);
 	if (ret < 0)
 		return ret;
 
@@ -2443,93 +2431,93 @@ static int ckpt_read_tree(struct ckpt_ctx *ctx)
 	}
 
 	/* get a working a copy of header */
-	memcpy(ctx->buf, ctx->tree, BUFSIZE);
+	memcpy(ctx.buf, ctx.tree, BUFSIZE);
 
-	ctx->pids_nr = h->nr_tasks;
+	ctx.pids_nr = h->nr_tasks;
 
-	len = sizeof(struct ckpt_pids) * ctx->pids_nr;
+	len = sizeof(struct ckpt_pids) * ctx.pids_nr;
 
-	ctx->pids_arr = malloc(len);
-	ctx->copy_arr = malloc(len);
-	if (!ctx->pids_arr || !ctx->copy_arr) {
-		if (ctx->pids_arr)
-			free(ctx->pids_arr);
+	ctx.pids_arr = malloc(len);
+	ctx.copy_arr = malloc(len);
+	if (!ctx.pids_arr || !ctx.copy_arr) {
+		if (ctx.pids_arr)
+			free(ctx.pids_arr);
 		return -1;
 	}
 
-	ret = ckpt_read_obj_ptr(ctx, ctx->pids_arr, len, CKPT_HDR_BUFFER);
+	ret = ckpt_read_obj_ptr(ctx.pids_arr, len, CKPT_HDR_BUFFER);
 	if (ret < 0)
-		free(ctx->pids_arr);
+		free(ctx.pids_arr);
 
 	return ret;
 }
 
-static int ckpt_write_header(struct ckpt_ctx *ctx)
+static int ckpt_write_header(void)
 {
 	char *ptr;
 	int ret;
 
-	ptr = (char *) ctx->header;
-	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+	ptr = (char *) ctx.header;
+	ret = ckpt_write_obj((struct ckpt_hdr *) ptr);
 	if (ret < 0)
 		return ret;
 
 	ptr += ((struct ckpt_hdr *) ptr)->len;
-	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+	ret = ckpt_write_obj((struct ckpt_hdr *) ptr);
 	if (ret < 0)
 		return ret;
 	ptr += ((struct ckpt_hdr *) ptr)->len;
-	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+	ret = ckpt_write_obj((struct ckpt_hdr *) ptr);
 	if (ret < 0)
 		return ret;
 	ptr += ((struct ckpt_hdr *) ptr)->len;
-	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+	ret = ckpt_write_obj((struct ckpt_hdr *) ptr);
 
 	return ret;
 }
 
-static int ckpt_write_header_arch(struct ckpt_ctx *ctx)
+static int ckpt_write_header_arch(void)
 {
 	struct ckpt_hdr_header_arch *h;
 
-	h = (struct ckpt_hdr_header_arch *) ctx->header_arch;
-	return ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	h = (struct ckpt_hdr_header_arch *) ctx.header_arch;
+	return ckpt_write_obj((struct ckpt_hdr *) h);
 }
 
-static int ckpt_write_container(struct ckpt_ctx *ctx)
+static int ckpt_write_container(void)
 {
 	char *ptr;
 	int ret;
 
-	ptr = (char *) ctx->container;
+	ptr = (char *) ctx.container;
 	/* write the container info section */
-	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+	ret = ckpt_write_obj((struct ckpt_hdr *) ptr);
 	if (ret < 0)
 		return ret;
 
 	/* write the lsm name buffer */
 	ptr += ((struct ckpt_hdr *) ptr)->len;
-	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+	ret = ckpt_write_obj((struct ckpt_hdr *) ptr);
 	if (ret < 0)
 		return ret;
 
 	/* write the lsm policy section */
 	ptr += ((struct ckpt_hdr *) ptr)->len;
-	return ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
+	return ckpt_write_obj((struct ckpt_hdr *) ptr);
 }
 
-static int ckpt_write_tree(struct ckpt_ctx *ctx)
+static int ckpt_write_tree(void)
 {
 	struct ckpt_hdr_tree *h;
 	int len;
 
-	h = (struct ckpt_hdr_tree *) ctx->tree;
-	if (ckpt_write_obj(ctx, (struct ckpt_hdr *) h) < 0)
-		ckpt_abort(ctx, "write tree");
+	h = (struct ckpt_hdr_tree *) ctx.tree;
+	if (ckpt_write_obj((struct ckpt_hdr *) h) < 0)
+		ckpt_abort("write tree");
 
-	len = sizeof(struct ckpt_pids) * ctx->pids_nr;
-	if (ckpt_write_obj_ptr(ctx, ctx->pids_arr, len, CKPT_HDR_BUFFER) < 0)
-		ckpt_abort(ctx, "write pids");
+	len = sizeof(struct ckpt_pids) * ctx.pids_nr;
+	if (ckpt_write_obj_ptr(ctx.pids_arr, len, CKPT_HDR_BUFFER) < 0)
+		ckpt_abort("write pids");
 
 	return 0;
 }
@@ -2541,32 +2529,32 @@ static int ckpt_write_tree(struct ckpt_ctx *ctx)
 #define HASH_BITS	11
 #define HASH_BUCKETS	(2 << (HASH_BITS - 1))
 
-static int hash_init(struct ckpt_ctx *ctx)
+static int hash_init(void)
 {
 	struct hashent **hash;
 
-	ctx->hash_arr = malloc(sizeof(*hash) * HASH_BUCKETS);
-	if (!ctx->hash_arr) {
+	ctx.hash_arr = malloc(sizeof(*hash) * HASH_BUCKETS);
+	if (!ctx.hash_arr) {
 		perror("malloc hash table");
 		return -1;
 	}
-	memset(ctx->hash_arr, 0, sizeof(*hash) * HASH_BUCKETS);
+	memset(ctx.hash_arr, 0, sizeof(*hash) * HASH_BUCKETS);
 	return 0;
 }
 
-static void hash_exit(struct ckpt_ctx *ctx)
+static void hash_exit(void)
 {
 	struct hashent *hash, *next;
 	int i;
 
 	for (i = 0; i < HASH_BUCKETS; i++) {
-		for (hash = ctx->hash_arr[i]; hash; hash = next) {
+		for (hash = ctx.hash_arr[i]; hash; hash = next) {
 			next = hash->next;
 			free(hash);
 		}
 	}
 
-	free(ctx->hash_arr);
+	free(ctx.hash_arr);
 }
 
 /* see linux kernel's include/linux/hash.h */
@@ -2580,7 +2568,7 @@ static inline int hash_func(long key)
 	return (hash >> (sizeof(key)*8 - HASH_BITS));
 }
 
-static int hash_insert(struct ckpt_ctx *ctx, long key, void *data)
+static int hash_insert(long key, void *data)
 {
 	struct hashent *hash;
 	int bucket;
@@ -2594,19 +2582,19 @@ static int hash_insert(struct ckpt_ctx *ctx, long key, void *data)
 	hash->data = data;
 
 	bucket = hash_func(key);
-	hash->next = ctx->hash_arr[bucket];
-	ctx->hash_arr[bucket] = hash;
+	hash->next = ctx.hash_arr[bucket];
+	ctx.hash_arr[bucket] = hash;
 
 	return 0;
 }
 
-static void *hash_lookup(struct ckpt_ctx *ctx, long key)
+static void *hash_lookup(long key)
 {
 	struct hashent *hash;
 	int bucket;
 
 	bucket = hash_func(key);
-	for (hash = ctx->hash_arr[bucket]; hash; hash = hash->next) {
+	for (hash = ctx.hash_arr[bucket]; hash; hash = hash->next) {
 		if (hash->key == key)
 			return hash->data;
 	}
-- 
1.6.3.3
