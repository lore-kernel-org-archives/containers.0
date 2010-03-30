From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] user-c/r: get rid of ckpt_hdr_vpids - can be inferred at
	restart
Date: Tue, 30 Mar 2010 02:32:14 -0400
Message-ID: <1269930734-6887-2-git-send-email-orenl@cs.columbia.edu>
References: <1269930734-6887-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1269930734-6887-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

And some cleanup of recent nested-pids work, and re-generate
user headers.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |    8 -----
 restart.c                      |   66 +++++++++++++++++----------------------
 2 files changed, 29 insertions(+), 45 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index f0e58c3..65d5256 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -111,8 +111,6 @@ enum {
 #define CKPT_HDR_GROUPINFO CKPT_HDR_GROUPINFO
 	CKPT_HDR_TASK_CREDS,
 #define CKPT_HDR_TASK_CREDS CKPT_HDR_TASK_CREDS
-	CKPT_HDR_VPIDS,
-#define CKPT_HDR_VPIDS CKPT_HDR_VPIDS
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -342,12 +340,6 @@ struct ckpt_pids {
 	__s32 depth; /* pid namespace depth relative to container init */
 } __attribute__((aligned(8)));
 
-/* number of vpids */
-struct ckpt_hdr_vpids {
-	struct ckpt_hdr h;
-	__s32 nr_vpids;
-} __attribute__((aligned(8)));
-
 /* pids */
 #define CKPT_PID_NULL -1
 
diff --git a/restart.c b/restart.c
index 608750e..537fe4a 100644
--- a/restart.c
+++ b/restart.c
@@ -2071,6 +2071,7 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 	unsigned long flags = SIGCHLD;
 	pid_t pid = 0;
 	pid_t *pids = &pid;
+	int i, j, depth;
 
 	ckpt_dbg("forking child vpid %d flags %#x\n", child->pid, child->flags);
 
@@ -2080,19 +2081,18 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 		return -1;
 	}
 
-	if (child->flags & TASK_THREAD) {
+	if (child->flags & TASK_THREAD)
 		flags |= CLONE_THREAD | CLONE_SIGHAND | CLONE_VM;
-	} else if (child->flags & TASK_SIBLING) {
+	else if (child->flags & TASK_SIBLING)
 		flags |= CLONE_PARENT;
-	}
 
 	memset(&clone_args, 0, sizeof(clone_args));
 	clone_args.nr_pids = 1;
 	/* select pid if --pids, otherwise it's 0 */
 	if (ctx->args->pids) {
-		int i, depth = child->piddepth + 1;
-
+		depth = child->piddepth + 1;
 		clone_args.nr_pids = depth;
+
 		pids = malloc(sizeof(pid_t) * depth);
 		if (!pids) {
 			perror("ckpt_fork_child pids malloc");
@@ -2101,9 +2101,9 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 
 		memset(pids, 0, sizeof(pid_t) * depth);
 		pids[0] = child->pid;
-		int j;
-		for (i = child->piddepth-1, j=0; i >= 0; i--, j++)
-			pids[j+1] = ctx->vpids_arr[child->vidx + j];
+
+		for (i = child->piddepth - 1, j = 0; i >= 0; i--, j++)
+			pids[j + 1] = ctx->vpids_arr[child->vidx + j];
 
 #ifndef CLONE_NEWPID
 		if (child->piddepth > child->creator->piddepth) {
@@ -2145,26 +2145,21 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 	clone_args.child_stack = (unsigned long)genstack_base(stk);
 	clone_args.child_stack_size = genstack_size(stk);
 
-	int who;
-
-	who = ((void *)child - (void *) &ctx->tasks_arr[0]) / sizeof(struct task);
 	ckpt_dbg("task %d forking with flags %lx numpids %d\n",
 		child->pid, flags, clone_args.nr_pids);
-	int i;
-	for (i=0; i<clone_args.nr_pids; i++)
+	for (i = 0; i < clone_args.nr_pids; i++)
 		ckpt_dbg("task %d pid[%d]=%d\n", child->pid, i, pids[i]);
+
 	pid = eclone(ckpt_fork_stub, child, flags, &clone_args, pids);
-	if (pids != &pid)
-		free(pids);
-	if (pid < 0) {
+	if (pid < 0)
 		ckpt_perror("eclone");
-		genstack_release(stk);
-		return -1;
-	}
 
-	if (!(child->flags & TASK_THREAD))
+	if (pid < 0 || !(child->flags & TASK_THREAD))
 		genstack_release(stk);
 
+	if (pids != &pid)
+		free(pids);
+
 	ckpt_dbg("forked child vpid %d (asked %d)\n", pid, child->pid);
 	return pid;
 }
@@ -2531,7 +2526,7 @@ static int ckpt_read_obj(struct ckpt_ctx *ctx,
 		return -1;
 	}
 	if (h->len == sizeof(*h))
-	return 0;
+		return 0;
 	return ckpt_read(STDIN_FILENO, buf, h->len - sizeof(*h));
 }
 
@@ -2721,26 +2716,28 @@ static int assign_vpids(struct ckpt_ctx *ctx)
 
 static int ckpt_read_vpids(struct ckpt_ctx *ctx)
 {
-	struct ckpt_hdr_vpids *h;
-	int len, ret;
+	int i, len, ret;
 
-	h = (struct ckpt_hdr_vpids *) ctx->vpids;
-	ret = ckpt_read_obj_type(ctx, h, sizeof(*h), CKPT_HDR_VPIDS);
-	if (ret < 0)
-		return ret;
+	for (i = 0; i < ctx->tasks_nr; i++)
+		ctx->vpids_nr += ctx->pids_arr[i].depth;
 
-	ckpt_dbg("number of vpids: %d\n", h->nr_vpids);
+	ckpt_dbg("number of vpids: %d\n", ctx->vpids_nr);
 
-	if (h->nr_vpids < 0) {
-		ckpt_err("invalid number of vpids %d", h->nr_vpids);
-		errno = EINVAL;
+	if (ctx->vpids_nr < 0) {
+		ckpt_err("Invalid number of vpids %d", ctx->vpids_nr);
+		errno = -EINVAL;
 		return -1;
 	}
-	ctx->vpids_nr = h->nr_vpids;
+
 	if (!ctx->vpids_nr)
 		return 0;
 
 	len = sizeof(__s32) * ctx->vpids_nr;
+	if (len < 0) {
+		ckpt_err("Length of vpids array overflowed");
+		errno = -EINVAL;
+		return -1;
+	}
 
 	ctx->vpids_arr = malloc(len);
 	if (!ctx->pids_arr)
@@ -2825,13 +2822,8 @@ static int ckpt_write_tree(struct ckpt_ctx *ctx)
 
 static int ckpt_write_vpids(struct ckpt_ctx *ctx)
 {
-	struct ckpt_hdr_vpids *h;
 	int len;
 
-	h = (struct ckpt_hdr_vpids *) ctx->vpids;
-	if (ckpt_write_obj(ctx, (struct ckpt_hdr *) h) < 0)
-		ckpt_abort(ctx, "write vpids hdr");
-
 	if (!ctx->vpids_nr)
 		return 0;
 	len = sizeof(__s32) * ctx->vpids_nr;
-- 
1.6.3.3
