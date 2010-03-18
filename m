From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH] user-cr: Handle nested pid namespaces
Date: Thu, 18 Mar 2010 15:22:00 -0500
Message-ID: <20100318202200.GA31767@us.ibm.com>
References: <20100318201946.GA31313@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100318201946.GA31313@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

[ Patch against https://www.linux-cr.org/redmine/tab/show/user-cr ]

Make userspace use eclone to recreate all original checkpointed
pids in nested pid namespaces.

Yup, the kernel doesn't actually care about the vpids in all
the child pid namespaces, they're actually just for us.  We
parse them to decide how to tell eclone to recreate the full
hierarchical pid and pidns trees.

Changelog:
	Mar 18: bump checkpoing image format version #

Signed-off-by: Serge Hallyn <serue@us.ibm.com>
---
 include/linux/checkpoint.h     |    2 +-
 include/linux/checkpoint_hdr.h |   17 ++-
 restart.c                      |  289 ++++++++++++++++++++++++----------------
 3 files changed, 184 insertions(+), 124 deletions(-)

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
index e8eaf23..cbd6ab2 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -111,6 +111,8 @@ enum {
 #define CKPT_HDR_GROUPINFO CKPT_HDR_GROUPINFO
 	CKPT_HDR_TASK_CREDS,
 #define CKPT_HDR_TASK_CREDS CKPT_HDR_TASK_CREDS
+	CKPT_HDR_PID,
+#define CKPT_HDR_PID CKPT_HDR_PID
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -320,12 +322,15 @@ struct ckpt_hdr_tree {
 	__s32 nr_tasks;
 } __attribute__((aligned(8)));
 
-struct ckpt_pids {
-	__s32 vpid;
-	__s32 vppid;
-	__s32 vtgid;
-	__s32 vpgid;
-	__s32 vsid;
+struct ckpt_hdr_pids {
+	struct ckpt_hdr h;
+	__s32 rpid;
+	__s32 pid;
+	__s32 ppid;
+	__s32 tgid;
+	__s32 pgid;
+	__s32 sid;
+	__s32 vpids[0];
 } __attribute__((aligned(8)));
 
 /* pids */
diff --git a/restart.c b/restart.c
index 0c74bb6..d0fe224 100644
--- a/restart.c
+++ b/restart.c
@@ -244,10 +244,12 @@ struct task {
 
 	struct task *phantom;	/* pointer to place-holdler task (if any) */
 
+	int piddepth;
 	pid_t pid;		/* process IDs, our bread-&-butter */
 	pid_t ppid;
 	pid_t tgid;
 	pid_t sid;
+	__s32 *vpids;
 	
 	pid_t rpid;		/* [restart without vpids] actual (real) pid */
 
@@ -267,6 +269,16 @@ struct task zero_task;
 #define TASK_NEWPID	0x20	/* starts a new pid namespace */
 #define TASK_DEAD	0x40	/* dead task (dummy) */
 
+struct uckpt_pid {
+	int depth;
+	__s32 rpid;
+	__s32 pid;
+	__s32 ppid;
+	__s32 tgid;
+	__s32 pgid;
+	__s32 sid;
+	__s32 vpids[0];
+};
 struct ckpt_ctx {
 	pid_t root_pid;
 	int pipe_in;
@@ -277,8 +289,7 @@ struct ckpt_ctx {
 	int pipe_feed[2];	/* for feeder to provide input */
 	int pipe_coord[2];	/* for coord to report status (if needed) */
 
-	struct ckpt_pids *pids_arr;
-	struct ckpt_pids *copy_arr;
+	struct uckpt_pid **orig_pids;
 
 	struct task *tasks_arr;
 	int tasks_nr;
@@ -1465,14 +1476,14 @@ static int ckpt_zero_pid(struct ckpt_ctx *ctx)
 	pid = ckpt_alloc_pid(ctx);
 	if (pid < 0)
 		return -1;
-	if (ckpt_setup_task(ctx, pid, ctx->pids_arr[0].vpid) < 0)
+	if (ckpt_setup_task(ctx, pid, ctx->orig_pids[0]->pid) < 0)
 		return -1;
 	return pid;
 }
 
 static int ckpt_init_tree(struct ckpt_ctx *ctx)
 {
-	struct ckpt_pids *pids_arr = ctx->pids_arr;
+	struct uckpt_pid **orig_pids = ctx->orig_pids;
 	int pids_nr = ctx->pids_nr;
 	struct task *task;
 	pid_t root_pid;
@@ -1480,8 +1491,8 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 	pid_t zero_pid = 0;
 	int i;
 
-	root_pid = pids_arr[0].vpid;
-	root_sid = pids_arr[0].vsid;
+	root_pid = orig_pids[0]->pid;
+	root_sid = orig_pids[0]->sid;
 
 	/*
 	 * The case where root_sid != root_pid is special. It must be
@@ -1515,24 +1526,26 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 
 		task->flags = 0;
 
-		if (!ckpt_valid_pid(ctx, pids_arr[i].vpid, "pid", i))
+		if (!ckpt_valid_pid(ctx, orig_pids[i]->pid, "pid", i))
 			return -1;
-		else if (!ckpt_valid_pid(ctx, pids_arr[i].vtgid, "tgid", i))
+		else if (!ckpt_valid_pid(ctx, orig_pids[i]->tgid, "tgid", i))
 			return -1;
-		else if (!ckpt_valid_pid(ctx, pids_arr[i].vsid, "sid", i))
+		else if (!ckpt_valid_pid(ctx, orig_pids[i]->sid, "sid", i))
 			return -1;
-		else if (!ckpt_valid_pid(ctx, pids_arr[i].vpgid, "pgid", i))
+		else if (!ckpt_valid_pid(ctx, orig_pids[i]->pgid, "pgid", i))
 			return -1;
 
-		if (pids_arr[i].vsid == root_sid)
-			pids_arr[i].vsid = 0;
-		if (pids_arr[i].vpgid == root_sid)
-			pids_arr[i].vpgid = 0;
+		if (orig_pids[i]->sid == root_sid)
+			orig_pids[i]->sid = 0;
+		if (orig_pids[i]->pgid == root_sid)
+			orig_pids[i]->pgid = 0;
 
-		task->pid = pids_arr[i].vpid;
-		task->ppid = pids_arr[i].vppid;
-		task->tgid = pids_arr[i].vtgid;
-		task->sid = pids_arr[i].vsid;
+		task->piddepth = orig_pids[i]->depth;
+		task->pid = orig_pids[i]->pid;
+		task->ppid = orig_pids[i]->ppid;
+		task->tgid = orig_pids[i]->tgid;
+		task->sid = orig_pids[i]->sid;
+		task->vpids = orig_pids[i]->vpids;
 
 		task->children = NULL;
 		task->next_sib = NULL;
@@ -1553,10 +1566,10 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 	for (i = 0; i < pids_nr; i++) {
 		pid_t sid;
 
-		sid = pids_arr[i].vsid;
+		sid = orig_pids[i]->sid;
 
-		/* Remember if we find any vsid/vpgid - see below */
-		if (pids_arr[i].vsid == 0 || pids_arr[i].vpgid == 0)
+		/* Remember if we find any sid/pgid - see below */
+		if (orig_pids[i]->sid == 0 || orig_pids[i]->pgid == 0)
 			zero_pid = 1;
 		/*
 		 * An unaccounted-for sid belongs to a task that was a
@@ -1579,7 +1592,7 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 		 * need to add it with the same sid as current (and
 		 * other) threads.
 		 */
-		if (ckpt_setup_task(ctx, pids_arr[i].vtgid, sid) < 0)
+		if (ckpt_setup_task(ctx, orig_pids[i]->tgid, sid) < 0)
 			return -1;
 
 		/*
@@ -1590,7 +1603,7 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 		 * same sid as us: all tasks with same pgrp must have
 		 * their sid matching.
 		 */
-		if (ckpt_setup_task(ctx, pids_arr[i].vpgid, sid) < 0)
+		if (ckpt_setup_task(ctx, orig_pids[i]->pgid, sid) < 0)
 			return -1;
 	}
 
@@ -1604,13 +1617,13 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 		if (zero_pid < 0)
 			return -1;
 		for (i = 0; i < pids_nr; i++) {
-			if (pids_arr[i].vsid == 0) {
-				pids_arr[i].vsid = zero_pid;
-				pids_arr[i].vppid = zero_pid;
+			if (orig_pids[i]->sid == 0) {
+				orig_pids[i]->sid = zero_pid;
+				orig_pids[i]->ppid = zero_pid;
 			}
-			if (pids_arr[i].vpgid == 0) {
-				pids_arr[i].vpgid = zero_pid;
-				pids_arr[i].vppid = zero_pid;
+			if (orig_pids[i]->pgid == 0) {
+				orig_pids[i]->pgid = zero_pid;
+				orig_pids[i]->ppid = zero_pid;
 			}
 		}
 	}
@@ -2050,8 +2063,8 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 	struct clone_args clone_args;
 	genstack stk;
 	unsigned long flags = SIGCHLD;
-	size_t nr_pids = 1;
 	pid_t pid = 0;
+	pid_t *pids = &pid;
 
 	ckpt_dbg("forking child vpid %d flags %#x\n", child->pid, child->flags);
 
@@ -2067,29 +2080,46 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
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
+			pids[i] = child->vpids[i-1];
+
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
@@ -2298,7 +2328,7 @@ static int ckpt_do_feeder(void *data)
 static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
 {
 	struct pid_swap swap;
-	int n, m, len, ret;
+	int n, m, ret;
 	pid_t coord_sid;
 
 	coord_sid = getsid(0);
@@ -2313,22 +2343,7 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
 	 *    but correct should be: [][][B][][A][]...
 	 */
 
-	len = sizeof(struct ckpt_pids) * ctx->pids_nr;
-
-#ifdef CHECKPOINT_DEBUG
-	ckpt_dbg("====== PIDS ARRAY\n");
-	for (m = 0; m < ctx->pids_nr; m++) {
-		struct ckpt_pids *p;
-		p = &ctx->pids_arr[m];
-		ckpt_dbg("[%d] pid %d ppid %d sid %d pgid %d\n",
-			 m, p->vpid, p->vppid, p->vsid, p->vpgid);
-	}
-	ckpt_dbg("............\n");
-#endif
-
-	memcpy(ctx->copy_arr, ctx->pids_arr, len);
-
-	/* read in 'pid_swap' data and adjust ctx->pids_arr */
+	/* read in 'pid_swap' data and adjust ctx->orig_pids */
 	for (n = 0; n < ctx->tasks_nr; n++) {
 		/* get pid info from next task */
 		ret = read(ctx->pipe_in, &swap, sizeof(swap));
@@ -2341,31 +2356,16 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
 
 		ckpt_dbg("c/r swap old %d new %d\n", swap.old, swap.new);
 		for (m = 0; m < ctx->pids_nr; m++) {
-			if (ctx->pids_arr[m].vpid == swap.old)
-				ctx->copy_arr[m].vpid = swap.new;
-			if (ctx->pids_arr[m].vtgid == swap.old)
-				ctx->copy_arr[m].vtgid = swap.new;
-			if (ctx->pids_arr[m].vsid == swap.old)
-				ctx->copy_arr[m].vsid = swap.new;
-			if (ctx->pids_arr[m].vpgid == swap.old)
-				ctx->copy_arr[m].vpgid = swap.new;
-		}
-	}
-
-	memcpy(ctx->pids_arr, ctx->copy_arr, len);
-
-#ifdef CHECKPOINT_DEBUG
-	if (!ctx->args->pids) {
-		ckpt_dbg("====== PIDS ARRAY (swaped)\n");
-		for (m = 0; m < ctx->pids_nr; m++) {
-			struct ckpt_pids *p;
-			p = &ctx->pids_arr[m];
-			ckpt_dbg("[%d] pid %d ppid %d sid %d pgid %d\n",
-				 m, p->vpid, p->vppid, p->vsid, p->vpgid);
+			if (ctx->orig_pids[m]->pid == swap.old)
+				ctx->orig_pids[m]->pid = swap.new;
+			if (ctx->orig_pids[m]->tgid == swap.old)
+				ctx->orig_pids[m]->tgid = swap.new;
+			if (ctx->orig_pids[m]->sid == swap.old)
+				ctx->orig_pids[m]->sid = swap.new;
+			if (ctx->orig_pids[m]->pgid == swap.old)
+				ctx->orig_pids[m]->pgid = swap.new;
 		}
-		ckpt_dbg("............\n");
 	}
-#endif
 
 	close(ctx->pipe_in);
 	return 0;
@@ -2479,21 +2479,6 @@ static int ckpt_read_obj_type(struct ckpt_ctx *ctx, void *buf, int n, int type)
 	return 0;
 }
 
-static int ckpt_read_obj_ptr(struct ckpt_ctx *ctx, void *buf, int n, int type)
-{
-	struct ckpt_hdr h;
-	int ret;
-
-	ret = ckpt_read_obj(ctx, &h, buf, n + sizeof(h));
-	if (ret < 0)
-		return ret;
-	if (h.type != type) {
-		errno = EINVAL;
-		return -1;
-	}
-	return 0;
-}
-
 static int ckpt_read_obj_buffer(struct ckpt_ctx *ctx, void *buf, int n)
 {
 	return ckpt_read_obj_type(ctx, buf, BUFSIZE, CKPT_HDR_BUFFER);
@@ -2575,10 +2560,64 @@ static int ckpt_read_container(struct ckpt_ctx *ctx)
 	return ckpt_read_obj_type(ctx, ptr, 200, CKPT_HDR_LSM_INFO);
 }
 
+#define MAX_PID_SZ 999999
+static int ckpt_read_pids(struct ckpt_ctx *ctx)
+{
+	struct uckpt_pid *p;
+	struct ckpt_hdr_pids *h;
+	int ret, i, numpids, size;
+	char *buf;
+
+	size = sizeof(struct ckpt_hdr_pids **) * ctx->pids_nr;
+
+	ctx->orig_pids = malloc(size);
+	if (!ctx->orig_pids)
+		return -1;
+
+	buf = malloc(MAX_PID_SZ);
+	if (!buf)
+		return -ENOMEM;
+	h = (struct ckpt_hdr_pids *) buf;
+
+	for (i=0; i<ctx->pids_nr; i++) {
+		int j;
+		__s32 *vpid;
+
+		ret = ckpt_read_obj_type(ctx, h, MAX_PID_SZ, CKPT_HDR_PID);
+		if (ret < 0)
+			goto out;
+		numpids = h->h.len - sizeof(struct ckpt_hdr_pids);
+		numpids /= sizeof(__s32);
+		size = sizeof(struct uckpt_pid) + numpids * sizeof(__s32);
+		p = malloc(size);
+		if (!p) {
+			ret = -ENOMEM;
+			goto out;
+		}
+		ctx->orig_pids[i] = p;
+		p->rpid = h->rpid;
+		p->depth = numpids;
+		p->pid = h->pid;
+		p->ppid = h->ppid;
+		p->tgid = h->tgid;
+		p->pgid = h->pgid;
+		p->sid = h->sid;
+		vpid = h->vpids;
+		for (j=0; j<numpids; j++)
+			p->vpids[j] = vpid[j];
+	}
+
+	ret = 0;
+
+out:
+	free(buf);
+	return ret;
+}
+
 static int ckpt_read_tree(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_tree *h;
-	int len, ret;
+	int ret;
 
 	h = (struct ckpt_hdr_tree *) ctx->tree;
 	ret = ckpt_read_obj_type(ctx, h, sizeof(*h), CKPT_HDR_TREE);
@@ -2598,21 +2637,7 @@ static int ckpt_read_tree(struct ckpt_ctx *ctx)
 
 	ctx->pids_nr = h->nr_tasks;
 
-	len = sizeof(struct ckpt_pids) * ctx->pids_nr;
-
-	ctx->pids_arr = malloc(len);
-	ctx->copy_arr = malloc(len);
-	if (!ctx->pids_arr || !ctx->copy_arr) {
-		if (ctx->pids_arr)
-			free(ctx->pids_arr);
-		return -1;
-	}
-
-	ret = ckpt_read_obj_ptr(ctx, ctx->pids_arr, len, CKPT_HDR_BUFFER);
-	if (ret < 0)
-		free(ctx->pids_arr);
-
-	return ret;
+	return ckpt_read_pids(ctx);
 }
 
 static int ckpt_write_header(struct ckpt_ctx *ctx)
@@ -2669,20 +2694,50 @@ static int ckpt_write_container(struct ckpt_ctx *ctx)
 	return ckpt_write_obj(ctx, (struct ckpt_hdr *) ptr);
 }
 
+static int write_out_a_pid(struct ckpt_ctx *ctx, int i)
+{
+	struct ckpt_hdr_pids *h;
+	struct uckpt_pid *p = ctx->orig_pids[i];
+	int ret, size;
+	__s32 *pids;
+
+	size = p->depth * sizeof(__s32);
+	size += sizeof(*h);
+	h = malloc(size);
+	if (!h)
+		return -ENOMEM;
+	h->h.len = size;
+	h->h.type = CKPT_HDR_PID;
+	h->pid = p->pid;
+	h->rpid = p->rpid;
+	h->ppid = p->ppid;
+	h->tgid = p->tgid;
+	h->pgid = p->pgid;
+	h->sid = p->sid;
+	pids = h->vpids;
+	for (i=0; i < p->depth; i++)
+		pids[i] = p->vpids[i];
+	ret = ckpt_write_obj(ctx, &h->h);
+	free(h);
+	return ret;
+}
+
 static int ckpt_write_tree(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_tree *h;
-	int len;
+	int i, ret = 0;
 
 	h = (struct ckpt_hdr_tree *) ctx->tree;
 	if (ckpt_write_obj(ctx, (struct ckpt_hdr *) h) < 0)
 		ckpt_abort(ctx, "write tree");
 
-	len = sizeof(struct ckpt_pids) * ctx->pids_nr;
-	if (ckpt_write_obj_ptr(ctx, ctx->pids_arr, len, CKPT_HDR_BUFFER) < 0)
-		ckpt_abort(ctx, "write pids");
+	for (i = 0; i < ctx->pids_nr; i++) {
+		ret = write_out_a_pid(ctx, i);
+		if (ret < 0)
+			ckpt_abort(ctx, "write pids");
+	}
 
-	return 0;
+	return ret;
 }
 
 /*
-- 
1.7.0
