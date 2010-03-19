From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH] user-ns: Nested pidns support (v2)
Date: Fri, 19 Mar 2010 16:41:31 -0500
Message-ID: <20100319214131.GA17964@us.ibm.com>
References: <20100319213955.GA17912@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100319213955.GA17912@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

[ this patch is against the userspace checkpoint/restart tools at
http://www.linux-cr.org/git/?p=user-cr.git;a=summary ]

Support restart of nested pid namespaces.  Parse the ckpt_vpid
array to decide the vpids to specify for each task's eclone().

Signed-off-by: Serge Hallyn <serue@us.ibm.com>
---
 include/linux/checkpoint.h     |    2 +-
 include/linux/checkpoint_hdr.h |   16 ++++
 restart.c                      |  158 ++++++++++++++++++++++++++++++++++++----
 3 files changed, 160 insertions(+), 16 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 53b8b2c..8d021b9 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -14,7 +14,7 @@
  *  distribution for more details.
  */
 
-#define CHECKPOINT_VERSION 5
+#define CHECKPOINT_VERSION 6
 
 /* checkpoint user flags */
 #define CHECKPOINT_SUBTREE 0x1
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index e8eaf23..caf16a6 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -111,6 +111,8 @@ enum {
 #define CKPT_HDR_GROUPINFO CKPT_HDR_GROUPINFO
 	CKPT_HDR_TASK_CREDS,
 #define CKPT_HDR_TASK_CREDS CKPT_HDR_TASK_CREDS
+	CKPT_HDR_VPIDS,
+#define CKPT_HDR_VPIDS CKPT_HDR_VPIDS
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -321,11 +323,25 @@ struct ckpt_hdr_tree {
 } __attribute__((aligned(8)));
 
 struct ckpt_pids {
+	/* these pids are in root_nsproxy's pid ns */
 	__s32 vpid;
 	__s32 vppid;
 	__s32 vtgid;
 	__s32 vpgid;
 	__s32 vsid;
+	__s32 rsid; /* real pid - in checkpointer's pid_ns */
+	__s32 depth; /* pidns depth */
+} __attribute__((aligned(8)));
+
+/* number of vpids */
+struct ckpt_hdr_vpids {
+	struct ckpt_hdr h;
+	__s32 nr_vpids;
+} __attribute__((aligned(8)));
+
+struct ckpt_vpid {
+	__s32 pid;
+	__s32 padding;
 } __attribute__((aligned(8)));
 
 /* pids */
diff --git a/restart.c b/restart.c
index 0c74bb6..32f36f8 100644
--- a/restart.c
+++ b/restart.c
@@ -244,6 +244,9 @@ struct task {
 
 	struct task *phantom;	/* pointer to place-holdler task (if any) */
 
+	int piddepth;
+	struct ckpt_vpid *vpids;
+
 	pid_t pid;		/* process IDs, our bread-&-butter */
 	pid_t ppid;
 	pid_t tgid;
@@ -272,6 +275,7 @@ struct ckpt_ctx {
 	int pipe_in;
 	int pipe_out;
 	int pids_nr;
+	int vpids_nr;
 
 	int pipe_child[2];	/* for children to report status */
 	int pipe_feed[2];	/* for feeder to provide input */
@@ -279,6 +283,7 @@ struct ckpt_ctx {
 
 	struct ckpt_pids *pids_arr;
 	struct ckpt_pids *copy_arr;
+	struct ckpt_vpid *vpids_arr;
 
 	struct task *tasks_arr;
 	int tasks_nr;
@@ -291,6 +296,7 @@ struct ckpt_ctx {
 	char header_arch[BUFSIZE];
 	char container[BUFSIZE];
 	char tree[BUFSIZE];
+	char vpids[BUFSIZE];
 	char buf[BUFSIZE];
 	struct app_restart_args *args;
 
@@ -316,6 +322,7 @@ static int ckpt_remount_devpts(struct ckpt_ctx *ctx);
 
 static int ckpt_build_tree(struct ckpt_ctx *ctx);
 static int ckpt_init_tree(struct ckpt_ctx *ctx);
+static int assign_vpids(struct ckpt_ctx *ctx);
 static int ckpt_set_creator(struct ckpt_ctx *ctx, struct task *task);
 static int ckpt_placeholder_task(struct ckpt_ctx *ctx, struct task *task);
 static int ckpt_propagate_session(struct ckpt_ctx *ctx, struct task *session);
@@ -339,6 +346,7 @@ static int ckpt_write_header(struct ckpt_ctx *ctx);
 static int ckpt_write_header_arch(struct ckpt_ctx *ctx);
 static int ckpt_write_container(struct ckpt_ctx *ctx);
 static int ckpt_write_tree(struct ckpt_ctx *ctx);
+static int ckpt_write_vpids(struct ckpt_ctx *ctx);
 
 static int _ckpt_read(int fd, void *buf, int count);
 static int ckpt_read(int fd, void *buf, int count);
@@ -350,6 +358,7 @@ static int ckpt_read_header(struct ckpt_ctx *ctx);
 static int ckpt_read_header_arch(struct ckpt_ctx *ctx);
 static int ckpt_read_container(struct ckpt_ctx *ctx);
 static int ckpt_read_tree(struct ckpt_ctx *ctx);
+static int ckpt_read_vpids(struct ckpt_ctx *ctx);
 
 static int hash_init(struct ckpt_ctx *ctx);
 static void hash_exit(struct ckpt_ctx *ctx);
@@ -883,6 +892,12 @@ int app_restart(struct app_restart_args *args)
 		exit(1);
 	}
 
+	ret = ckpt_read_vpids(&ctx);
+	if (ret < 0) {
+		ckpt_perror("read c/r tree");
+		exit(1);
+	}
+
 	/* build creator-child-relationship tree */
 	if (hash_init(&ctx) < 0)
 		exit(1);
@@ -891,6 +906,10 @@ int app_restart(struct app_restart_args *args)
 	if (ret < 0)
 		exit(1);
 
+	ret = assign_vpids(&ctx);
+	if (ret < 0)
+		exit(1);
+
 	ret = ckpt_fork_feeder(&ctx);
 	if (ret < 0)
 		exit(1);
@@ -1218,13 +1237,13 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 
 	return ret;
 }
-#else
+#else /* CLONE_NEWPID */
 static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 {
 	ckpt_err("logical error: ckpt_coordinator_pidns unexpected\n");
 	exit(1);
 }
-#endif
+#endif /* CLONE_NEWPID */
 
 static int ckpt_coordinator(struct ckpt_ctx *ctx)
 {
@@ -2050,8 +2069,8 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 	struct clone_args clone_args;
 	genstack stk;
 	unsigned long flags = SIGCHLD;
-	size_t nr_pids = 1;
 	pid_t pid = 0;
+	pid_t *pids = &pid;
 
 	ckpt_dbg("forking child vpid %d flags %#x\n", child->pid, child->flags);
 
@@ -2067,29 +2086,58 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 		flags |= CLONE_PARENT;
 	}
 
+	memset(&clone_args, 0, sizeof(clone_args));
+	clone_args.nr_pids = 1;
 	/* select pid if --pids, otherwise it's 0 */
-	if (ctx->args->pids)
-		pid = child->pid;
+	if (ctx->args->pids) {
+		int i, depth = child->piddepth + 1;
 
-#ifdef CLONE_NEWPID
-	/* but for new pidns, don't specify a pid */
- 	if (child->flags & TASK_NEWPID) {
-		flags |= CLONE_NEWPID;
-		pid = 0;
+		clone_args.nr_pids = depth;
+		pids = malloc(sizeof(pid_t) * depth);
+		if (!pids) {
+			perror("ckpt_fork_child pids malloc");
+			return -1;
+		}
+
+		pids[0] = child->pid;
+		for (i = 1; i <= child->piddepth; i++)
+			pids[i] = child->vpids[i-1].pid;
+
+#ifndef CLONE_NEWPID
+		if (child->piddepth > child->creator->piddepth) {
+			ckpt_err("nested pidns but CLONE_NEWPID undefined");
+			errno = -EINVAL;
+			return -1;
+		} else if (child->flags & TASK_NEWPID) {
+			ckpt_err("TASK_NEWPID set but CLONE_NEWPID undefined");
+			errno = -EINVAL;
+			return -1;
+		}
+#else /* CLONE_NEWPID */
+		if (child->piddepth > child->creator->piddepth) {
+			child->flags |= TASK_NEWPID;
+			flags |= CLONE_NEWPID;
+		} else if (child->flags & TASK_NEWPID) {
+			/* The TASK_NEWPID could have been set for root task */
+			pids[0] = 0;
+			flags |= CLONE_NEWPID;
+		}
+		if (flags & CLONE_NEWPID)
+			clone_args.nr_pids--;
+#endif /* CLONE_NEWPID */
 	}
-#endif
 
 	if (child->flags & (TASK_SIBLING | TASK_THREAD))
 		child->real_parent = getppid();
 	else
 		child->real_parent = _getpid();
 
-	memset(&clone_args, 0, sizeof(clone_args));
 	clone_args.child_stack = (unsigned long)genstack_base(stk);
 	clone_args.child_stack_size = genstack_size(stk);
-	clone_args.nr_pids = nr_pids;
 
-	pid = eclone(ckpt_fork_stub, child, flags, &clone_args, &pid);
+	pid = eclone(ckpt_fork_stub, child, flags, &clone_args, pids);
+	if (pids != &pid)
+		free(pids);
 	if (pid < 0) {
 		ckpt_perror("eclone");
 		genstack_release(stk);
@@ -2269,6 +2317,9 @@ static int ckpt_do_feeder(void *data)
 	if (ckpt_write_tree(ctx) < 0)
 		ckpt_abort(ctx, "write c/r tree");
 
+	if (ckpt_write_vpids(ctx) < 0)
+		ckpt_abort(ctx, "write vpids");
+
 	/* read rest -> write rest */
 	if (ctx->args->inspect)
 		ckpt_read_write_inspect(ctx);
@@ -2461,6 +2512,8 @@ static int ckpt_read_obj(struct ckpt_ctx *ctx,
 		errno = EINVAL;
 		return -1;
 	}
+	if (h->len == sizeof(*h))
+	return 0;
 	return ckpt_read(STDIN_FILENO, buf, h->len - sizeof(*h));
 }
 
@@ -2609,8 +2662,64 @@ static int ckpt_read_tree(struct ckpt_ctx *ctx)
 	}
 
 	ret = ckpt_read_obj_ptr(ctx, ctx->pids_arr, len, CKPT_HDR_BUFFER);
-	if (ret < 0)
+	if (ret < 0) {
 		free(ctx->pids_arr);
+		return ret;
+	}
+
+	return ret;
+}
+
+/* set the vpids pointers in all the tasks */
+static int assign_vpids(struct ckpt_ctx *ctx)
+{
+	int d, hidx, tidx;
+
+	for (hidx = 0, tidx = 0; tidx < ctx->pids_nr; tidx++) {
+		d = ctx->tasks_arr[tidx].piddepth = ctx->pids_arr[tidx].depth;
+		if (!d) {
+			ctx->tasks_arr[tidx].vpids = NULL;
+			continue;
+		}
+		ctx->tasks_arr[tidx].vpids = &ctx->vpids_arr[hidx];
+		hidx += ctx->pids_arr[tidx].depth;
+		if (hidx > ctx->vpids_nr)
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static int ckpt_read_vpids(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_vpids *h;
+	int len, ret;
+
+	h = (struct ckpt_hdr_vpids *) ctx->vpids;
+	ret = ckpt_read_obj_type(ctx, h, sizeof(*h), CKPT_HDR_VPIDS);
+	if (ret < 0)
+		return ret;
+
+	ckpt_dbg("number of vpids: %d\n", h->nr_vpids);
+
+	if (h->nr_vpids < 0) {
+		ckpt_err("invalid number of vpids %d", h->nr_vpids);
+		errno = EINVAL;
+		return -1;
+	}
+	ctx->vpids_nr = h->nr_vpids;
+	if (!ctx->vpids_nr)
+		return 0;
+
+	len = sizeof(struct ckpt_vpid) * ctx->vpids_nr;
+
+	ctx->vpids_arr = malloc(len);
+	if (!ctx->pids_arr)
+		return -1;
+
+	ret = ckpt_read_obj_ptr(ctx, ctx->vpids_arr, len, CKPT_HDR_BUFFER);
+	if (ret < 0)
+		free(ctx->vpids_arr);
 
 	return ret;
 }
@@ -2685,6 +2794,25 @@ static int ckpt_write_tree(struct ckpt_ctx *ctx)
 	return 0;
 }
 
+static int ckpt_write_vpids(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_vpids *h;
+	int len;
+
+	h = (struct ckpt_hdr_vpids *) ctx->vpids;
+	if (ckpt_write_obj(ctx, (struct ckpt_hdr *) h) < 0)
+		ckpt_abort(ctx, "write vpids hdr");
+
+	if (!ctx->vpids_nr)
+		return 0;
+	len = sizeof(struct ckpt_vpid) * ctx->vpids_nr;
+	if (ckpt_write_obj_ptr(ctx, ctx->vpids_arr, len, CKPT_HDR_BUFFER) < 0)
+		ckpt_abort(ctx, "write vpids");
+	ckpt_dbg("wrote %d bytes for %d vpids\n", len, ctx->vpids_nr);
+
+	return 0;
+}
+
 /*
  * a simple hash implementation
  */
-- 
1.7.0
