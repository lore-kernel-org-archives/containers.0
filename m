From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 05/13][user-cr]: restart: Use ckpt_perror()
Date: Wed, 3 Mar 2010 23:47:39 -0800
Message-ID: <20100304074739.GF29320@us.ibm.com>
References: <20100304074354.GA29320@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100304074354.GA29320-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Mon, 1 Mar 2010 20:18:31 -0800
Subject: [PATCH 05/13][user-cr]: restart: Use ckpt_perror()

Remove the implicit dependency on 'stderr' and redirect messages to
global_uerrfd. This would simplify implementing command line options
for these file descriptors and also enable implementing the restart
functionality as a library interface

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |   92 ++++++++++++++++++++++++++++++++----------------------------
 1 files changed, 49 insertions(+), 43 deletions(-)

diff --git a/restart.c b/restart.c
index c4c2158..eda864d 100644
--- a/restart.c
+++ b/restart.c
@@ -123,6 +123,12 @@ static inline void ckpt_msg(int fd, char *format, ...)
 	va_end(ap);
 }
 
+#define ckpt_perror(s) 							\
+	do {								\
+		ckpt_msg(global_uerrfd, s);				\
+		ckpt_msg(global_uerrfd, ": %s\n", strerror(errno));	\
+	} while (0)
+
 #ifdef CHECKPOINT_DEBUG
 #define ckpt_dbg(_format, _args...)					\
 	do {								\
@@ -649,7 +655,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
 	if (klogfile) {
 		args->klogfd = open(klogfile, O_RDWR | O_CREAT | O_EXCL, 0644);
 		if (args->klogfd < 0) {
-			perror("open log file");
+			ckpt_perror("open log file");
 			exit(1);
 		}
 	}
@@ -701,7 +707,7 @@ static void sigchld_handler(int sig)
 		} else if (errno == ECHILD) {
 			break;
 		} else {
-			perror("WEIRD !! child collection failed");
+			ckpt_perror("WEIRD !! child collection failed");
 			exit(1);
 		}
 	}
@@ -741,7 +747,7 @@ static int freezer_prepare(struct ckpt_ctx *ctx)
 
 	freezer = malloc(strlen(ctx->args->freezer) + 32);
 	if (!freezer) {
-		perror("malloc freezer buf");
+		ckpt_perror("malloc freezer buf");
 		return -1;
 	}
 
@@ -749,13 +755,13 @@ static int freezer_prepare(struct ckpt_ctx *ctx)
 
 	fd = open(freezer, O_WRONLY, 0);
 	if (fd < 0) {
-		perror("freezer path");
+		ckpt_perror("freezer path");
 		free(freezer);
 		exit(1);
 	}
 	ret = write(fd, FREEZER_THAWED, sizeof(FREEZER_THAWED)); 
 	if (ret != sizeof(FREEZER_THAWED)) {
-		perror("thawing freezer");
+		ckpt_perror("thawing freezer");
 		free(freezer);
 		exit(1);
 	}
@@ -774,14 +780,14 @@ static int freezer_register(struct ckpt_ctx *ctx, pid_t pid)
 
 	fd = open(ctx->freezer, O_WRONLY, 0);
 	if (fd < 0) {
-		perror("freezer path");
+		ckpt_perror("freezer path");
 		return -1;
 	}
 
 	n = sprintf(pidstr, "%d", pid);
 	ret = write(fd, pidstr, n);
 	if (ret != n) {
-		perror("adding pid %d to freezer");
+		ckpt_perror("adding pid %d to freezer");
 		ret = -1;
 	} else {
 		ret = 0;
@@ -815,7 +821,7 @@ int main(int argc, char *argv[])
 	if (args.input) {
 		args.infd = open(args.input, O_RDONLY, 0);
 		if (args.infd < 0) {
-			perror("open input file");
+			ckpt_perror("open input file");
 			exit(1);
 		}
 	}
@@ -823,7 +829,7 @@ int main(int argc, char *argv[])
 	/* input file descriptor (default: stdin) */
 	if (args.infd >= 0) {
 		if (dup2(args.infd, STDIN_FILENO) < 0) {
-			perror("dup2 input file");
+			ckpt_perror("dup2 input file");
 			exit(1);
 		}
 		if (args.infd != STDIN_FILENO)
@@ -840,13 +846,13 @@ int main(int argc, char *argv[])
 
 	/* private mounts namespace ? */
 	if (args.mntns && unshare(CLONE_NEWNS | CLONE_FS) < 0) {
-		perror("unshare");
+		ckpt_perror("unshare");
 		exit(1);
 	}
 
 	/* chroot ? */
 	if (args.root && chroot(args.root) < 0) {
-		perror("chroot");
+		ckpt_perror("chroot");
 		exit(1);
 	}
 
@@ -858,7 +864,7 @@ int main(int argc, char *argv[])
 	if (args.self) {
 		restart(getpid(), STDIN_FILENO, RESTART_TASKSELF, args.klogfd);
 		/* reach here if restart(2) failed ! */
-		perror("restart");
+		ckpt_perror("restart");
 		exit(1);
 	}
 
@@ -866,25 +872,25 @@ int main(int argc, char *argv[])
 
 	ret = ckpt_read_header(&ctx);
 	if (ret < 0) {
-		perror("read c/r header");
+		ckpt_perror("read c/r header");
 		exit(1);
 	}
 		
 	ret = ckpt_read_header_arch(&ctx);
 	if (ret < 0) {
-		perror("read c/r header arch");
+		ckpt_perror("read c/r header arch");
 		exit(1);
 	}
 
 	ret = ckpt_read_container(&ctx);
 	if (ret < 0) {
-		perror("read c/r container section");
+		ckpt_perror("read c/r container section");
 		exit(1);
 	}
 
 	ret = ckpt_read_tree(&ctx);
 	if (ret < 0) {
-		perror("read c/r tree");
+		ckpt_perror("read c/r tree");
 		exit(1);
 	}
 
@@ -978,7 +984,7 @@ static int ckpt_collect_child(struct ckpt_ctx *ctx)
 	if (global_child_collected) {
 		status = global_child_status;
 	} else if (pid < 0) {
-		perror("WEIRD: collect child task");
+		ckpt_perror("WEIRD: collect child task");
 		exit(1);
 	}
 
@@ -991,7 +997,7 @@ static int ckpt_remount_devpts(struct ckpt_ctx *ctx)
 
 	/* make sure /dev/ptmx is a link else we'll just break */
 	if (lstat("/dev/ptmx", &ptystat) < 0) {
-		perror("stat /dev/ptmx");
+		ckpt_perror("stat /dev/ptmx");
 		return -1;
 	}
 	if ((ptystat.st_mode & S_IFMT) != S_IFLNK) {
@@ -1002,7 +1008,7 @@ static int ckpt_remount_devpts(struct ckpt_ctx *ctx)
 	/* this is unlikely, but maybe we don't want to fail */
 	if (umount2("/dev/pts", MNT_DETACH) < 0) {
 		if (ckpt_cond_fail(ctx, CKPT_COND_MNTPTY)) {
-			perror("umount -l /dev/pts");
+			ckpt_perror("umount -l /dev/pts");
 			return -1;
 		}
 		if (ckpt_cond_warn(ctx, CKPT_COND_MNTPTY))
@@ -1010,7 +1016,7 @@ static int ckpt_remount_devpts(struct ckpt_ctx *ctx)
 	}
 	if (mount("pts", "/dev/pts", "devpts", 0,
 		  "ptmxmode=666,newinstance") < 0) {
-		perror("mount -t devpts -o newinstance");
+		ckpt_perror("mount -t devpts -o newinstance");
 		return -1;
 	}
 
@@ -1092,20 +1098,20 @@ static int ckpt_probe_child(pid_t pid, char *str)
 static int ckpt_remount_proc(struct ckpt_ctx *ctx)
 {
 	if (unshare(CLONE_NEWNS | CLONE_FS) < 0) {
-		perror("unshare");
+		ckpt_perror("unshare");
 		return -1;
 	}
 	/* this is unlikely, but we don't want to fail */
 	if (umount2("/proc", MNT_DETACH) < 0) {
 		if (ckpt_cond_fail(ctx, CKPT_COND_MNTPROC)) {
-			perror("umount -l /proc");
+			ckpt_perror("umount -l /proc");
 			return -1;
 		}
 		if (ckpt_cond_warn(ctx, CKPT_COND_MNTPROC))
 			ckpt_err("[warn] failed to un-mount old /proc\n");
 	}
 	if (mount("proc", "/proc", "proc", 0, NULL) < 0) {
-		perror("mount -t proc");
+		ckpt_perror("mount -t proc");
 		return -1;
 	}
 
@@ -1135,7 +1141,7 @@ static int ckpt_coordinator_status(struct ckpt_ctx *ctx)
 
 	ret = read(ctx->pipe_coord[0], &status, sizeof(status));
 	if (ret < 0)
-		perror("read coordinator status");
+		ckpt_perror("read coordinator status");
 	else if (ret == 0) {
 		/* coordinator failed to report */
 		ckpt_dbg("Coordinator failed to report status.");
@@ -1162,13 +1168,13 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	 * root-task's return value).
 	 */
 	if (pipe(ctx->pipe_coord) < 0) {
-		perror("pipe");
+		ckpt_perror("pipe");
 		return -1;
 	}
 
 	stk = genstack_alloc(PTHREAD_STACK_MIN);
 	if (!stk) {
-		perror("coordinator genstack_alloc");
+		ckpt_perror("coordinator genstack_alloc");
 		return -1;
 	}
 	sp = genstack_sp(stk);
@@ -1179,7 +1185,7 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	coord_pid = clone(__ckpt_coordinator, sp, CLONE_NEWPID|SIGCHLD, ctx);
 	genstack_release(stk);
 	if (coord_pid < 0) {
-		perror("clone coordinator");
+		ckpt_perror("clone coordinator");
 		return coord_pid;
 	}
 	global_child_pid = coord_pid;
@@ -1244,7 +1250,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 	ret = restart(root_pid, STDIN_FILENO, flags, ctx->args->klogfd);
 
 	if (ret < 0) {
-		perror("restart failed");
+		ckpt_perror("restart failed");
 		ckpt_verbose("Failed\n");
 		ckpt_dbg("restart failed ?\n");
 		exit(1);
@@ -1258,7 +1264,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 	if (ctx->args->pidns && ctx->tasks_arr[0].pid != 1) {
 		/* Report success/failure to the parent */
 		if (write(ctx->pipe_coord[1], &ret, sizeof(ret)) < 0) {
-			perror("failed to report status");
+			ckpt_perror("failed to report status");
 			exit(1);
 		}
 
@@ -1314,7 +1320,7 @@ static int ckpt_build_tree(struct ckpt_ctx *ctx)
 	ctx->tasks_max = ctx->pids_nr * 4;
 	ctx->tasks_arr = malloc(sizeof(*ctx->tasks_arr) * ctx->tasks_max);
 	if (!ctx->tasks_arr) {
-		perror("malloc tasks array");
+		ckpt_perror("malloc tasks array");
 		return -1;
 	}
 
@@ -1915,7 +1921,7 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 	if (task->pid == task->sid) {
 		ret = setsid();
 		if (ret < 0 && task != ckpt_init_task(ctx)) {
-			perror("setsid");
+			ckpt_perror("setsid");
 			return -1;
 		}
 	}
@@ -1948,7 +1954,7 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 	swap.new = _gettid();
 	ret = write(ctx->pipe_out, &swap, sizeof(swap));
 	if (ret != sizeof(swap)) {
-		perror("write swap");
+		ckpt_perror("write swap");
 		return -1;
 	}
 	close(ctx->pipe_out);
@@ -1975,7 +1981,7 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 	ckpt_dbg("about to call sys_restart(), flags %#lx\n", flags);
 	ret = restart(0, STDIN_FILENO, flags, CHECKPOINT_FD_NONE);
 	if (ret < 0)
-		perror("task restore failed");
+		ckpt_perror("task restore failed");
 	return ret;
 }
 
@@ -2007,7 +2013,7 @@ int ckpt_fork_stub(void *data)
 	 */
 	if (!ctx->args->pidns) {
 		if (prctl(PR_SET_PDEATHSIG, SIGKILL, 0, 0, 0) < 0) {
-			perror("prctl");
+			ckpt_perror("prctl");
 			return -1;
 		}
 		if (getppid() != task->real_parent) {
@@ -2044,7 +2050,7 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 
 	stk = genstack_alloc(PTHREAD_STACK_MIN);
 	if (!stk) {
-		perror("ckpt_fork_child genstack_alloc");
+		ckpt_perror("ckpt_fork_child genstack_alloc");
 		return -1;
 	}
 
@@ -2078,7 +2084,7 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 
 	pid = eclone(ckpt_fork_stub, child, flags, &clone_args, &pid);
 	if (pid < 0) {
-		perror("eclone");
+		ckpt_perror("eclone");
 		genstack_release(stk);
 		return -1;
 	}
@@ -2105,12 +2111,12 @@ static int ckpt_fork_feeder(struct ckpt_ctx *ctx)
 	pid_t pid;
 
 	if (pipe(ctx->pipe_feed)) {
-		perror("pipe");
+		ckpt_perror("pipe");
 		exit(1);
 	}
 
 	if (pipe(ctx->pipe_child) < 0) {
-		perror("pipe");
+		ckpt_perror("pipe");
 		exit(1);
 	}
 
@@ -2122,14 +2128,14 @@ static int ckpt_fork_feeder(struct ckpt_ctx *ctx)
 
 	stk = genstack_alloc(PTHREAD_STACK_MIN);
 	if (!stk) {
-		perror("ckpt_fork_feeder genstack_alloc");
+		ckpt_perror("ckpt_fork_feeder genstack_alloc");
 		return -1;
 	}
 
 	pid = clone(ckpt_do_feeder, genstack_sp(stk),
 		    CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, ctx);
 	if (pid < 0) {
-		perror("feeder thread");
+		ckpt_perror("feeder thread");
 		return -1;
 	}
 
@@ -2148,7 +2154,7 @@ static int ckpt_fork_feeder(struct ckpt_ctx *ctx)
 
 static void ckpt_abort(struct ckpt_ctx *ctx, char *str)
 {
-	perror(str);
+	ckpt_perror(str);
 	kill(-(ctx->root_pid), SIGKILL);
 	exit(1);
 }
@@ -2685,7 +2691,7 @@ static int hash_init(struct ckpt_ctx *ctx)
 
 	ctx->hash_arr = malloc(sizeof(*hash) * HASH_BUCKETS);
 	if (!ctx->hash_arr) {
-		perror("malloc hash table");
+		ckpt_perror("malloc hash table");
 		return -1;
 	}
 	memset(ctx->hash_arr, 0, sizeof(*hash) * HASH_BUCKETS);
@@ -2725,7 +2731,7 @@ static int hash_insert(struct ckpt_ctx *ctx, long key, void *data)
 
 	hash = malloc(sizeof(*hash));
 	if (!hash) {
-		perror("malloc hash");
+		ckpt_perror("malloc hash");
 		return -1;
 	}
 	hash->key = key;
-- 
1.6.0.4
