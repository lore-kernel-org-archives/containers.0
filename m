From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: user-cr: Extra unshare() calls ?
Date: Thu, 11 Mar 2010 17:58:23 -0800
Message-ID: <20100312015823.GB6444@us.ibm.com>
References: <20100308201338.GA16446@us.ibm.com>
	<20100308205851.GB21490@us.ibm.com>
	<20100308211135.GB14607@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100308211135.GB14607-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu [sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| | Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
| | > 
| | > Came across this while testing LXC.
| | > 
| | > 
| | > 1. Does ckpt_remount_proc() need to unshare() ? Or can we have the
| | >    clone() that calls __ckpt_coordinator() clone with CLONE_NEWNS|CLONE_FS
| | >    instead ?
| | > 
| | >    The problem with the unshare() in ckpt_remount_proc() is that it
| | >    creates an extra level in cgroup hierarchy (see below) after restart.
| | >    So applications expecting the cgroup hierarchy before chckpoint will
| | >    be surprised.
| | > 
| | > 2. When --mount-pty (or --mntns) is specified, do we need to unshare() 
| | >    in the parent process ? Considering only the full-container restart
| | >    for now (ignore self-restart and subtree restart), can we just
| | >    specify (CLONE_NEWNS|CLONE_FS) at the time of creating the first
| | >    restarted process ?
| | 
| | And then move remounting of devpts into ckpt_remount_proc() called
| | from __ckpt_coordinator() as well?
| 
| Yes, I missed that in the hack.

Here is a more involved fix, but not sure if there is a more efficient
way to solve.

---
From 6813961bc1f357516685145279f9f8ce883c31a4 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Mon, 8 Mar 2010 12:03:46 -0800
Subject: [PATCH 1/1] Minimize unshare() calls

We currently have a few unshare() calls at different points in the
code. While these don't affect the restart application itself, the
excess calls create additional levels in the cgroup hierarchy, which
can surprise the administrator (or other users of the hierarchy
such as LXC.

Rather than several unshare() calls, can we instead specify the
appropriate clone_flags while creating the coordinator/root process
of the application tree ? When this root process is created it can
remount /proc, remount devpts, chroot() etc if necessary.

Note that for "new-container with init" and "subtree restart", the
first process is also the root of the application process tree.

In the case of "new-container without init", the coordinator process
which acts as the container-init can do the setup.

In case of self-restart, the main process itself can do the unshare.

This patch has been very gently tested :-) but wanted to get more feedback
on the direction and see if there is an easier way.
---
 restart.c |   78 ++++++++++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 62 insertions(+), 16 deletions(-)

diff --git a/restart.c b/restart.c
index 63e1881..87a30dc 100644
--- a/restart.c
+++ b/restart.c
@@ -127,6 +127,9 @@ struct task zero_task;
 #define TASK_SESSION	0x10	/* inherits creator's original sid */
 #define TASK_NEWPID	0x20	/* starts a new pid namespace */
 #define TASK_DEAD	0x40	/* dead task (dummy) */
+#define TASK_NEWROOT	0x80	/* task must chroot() */
+#define TASK_NEWPTS	0x100	/* remount devpts */
+#define TASK_NEWNS	0x200	/* unshare namespace/file-system */
 
 struct ckpt_ctx {
 	pid_t root_pid;
@@ -458,24 +461,24 @@ int app_restart(struct app_restart_args *args)
 	if (args->freezer && freezer_prepare(&ctx) < 0)
 		exit(1);
 
-	/* private mounts namespace ? */
-	if (args->mntns && unshare(CLONE_NEWNS | CLONE_FS) < 0) {
-		ckpt_perror("unshare");
-		exit(1);
-	}
+	/* self-restart ends here: */
+	if (args->self) {
+		/* private mounts namespace ? */
+		if (args->mntns && unshare(CLONE_NEWNS | CLONE_FS) < 0) {
+			ckpt_perror("unshare");
+			exit(1);
+		}
 
-	/* chroot ? */
-	if (args->root && chroot(args->root) < 0) {
-		ckpt_perror("chroot");
-		exit(1);
-	}
+		/* chroot ? */
+		if (args->root && chroot(args->root) < 0) {
+			ckpt_perror("chroot");
+			exit(1);
+		}
 
-	/* remount /dev/pts ? */
-	if (args->mnt_pty && ckpt_remount_devpts(&ctx) < 0)
-		exit(1);
+		/* remount /dev/pts ? */
+		if (args->mnt_pty && ckpt_remount_devpts(&ctx) < 0)
+			exit(1);
 
-	/* self-restart ends here: */
-	if (args->self) {
 		restart(getpid(), STDIN_FILENO, RESTART_TASKSELF, args->klogfd);
 		/* reach here if restart(2) failed ! */
 		ckpt_perror("restart");
@@ -520,10 +523,30 @@ int app_restart(struct app_restart_args *args)
 	if (ret < 0)
 		exit(1);
 
+	/*
+	 * Have the first child in the restarted process tree
+	 * setup devpts, root-dir and /proc if necessary, ...
+	 */
+	if (ctx.args->mnt_pty)
+		ctx.tasks_arr[0].flags |= TASK_NEWPTS;
+
+	if (ctx.args->mntns)
+		ctx.tasks_arr[0].flags |= TASK_NEWNS;
+
+	if (ctx.args->root)
+		ctx.tasks_arr[0].flags |= TASK_NEWROOT;
+
 	if (ctx.args->pidns && ctx.tasks_arr[0].pid != 1) {
 		ckpt_dbg("new pidns without init\n");
 		if (global_send_sigint == -1)
 			global_send_sigint = SIGINT;
+		/*
+		 * ...unless we have an explicit coordinator, in which case
+		 * the coordinator should set up the filesystems and
+		 * not the first process in the application process tree.
+		 */
+		ctx.tasks_arr[0].flags &= ~(TASK_NEWPTS | TASK_NEWROOT | \
+				TASK_NEWNS);
 		ret = ckpt_coordinator_pidns(&ctx);
 	} else if (ctx.args->pidns) {
 		ckpt_dbg("new pidns with init\n");
@@ -717,10 +740,12 @@ static int ckpt_probe_child(pid_t pid, char *str)
  */
 static int ckpt_remount_proc(struct ckpt_ctx *ctx)
 {
+#if 0
 	if (unshare(CLONE_NEWNS | CLONE_FS) < 0) {
 		ckpt_perror("unshare");
 		return -1;
 	}
+#endif
 	/* this is unlikely, but we don't want to fail */
 	if (umount2("/proc", MNT_DETACH) < 0) {
 		if (ckpt_cond_fail(ctx, CKPT_COND_MNTPROC)) {
@@ -743,9 +768,18 @@ static int __ckpt_coordinator(void *arg)
 {
 	struct ckpt_ctx *ctx = (struct ckpt_ctx *) arg;
 
+	/* chroot ? */
+	if (ctx->args->root && chroot(ctx->args->root) < 0) {
+		ckpt_perror("chroot");
+		exit(1);
+	}
+
 	if (ckpt_remount_proc(ctx) < 0)
 		return -1;
 
+	if (ctx->args->mnt_pty && ckpt_remount_devpts(ctx) < 0)
+		return -1;
+
 	if (!ctx->args->wait)
 		close(ctx->pipe_coord[0]);
 
@@ -778,6 +812,7 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	int copy, ret;
 	genstack stk;
 	void *sp;
+	unsigned long flags = SIGCHLD;
 
 	ckpt_dbg("forking coordinator in new pidns\n");
 
@@ -802,7 +837,9 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	copy = ctx->args->copy_status;
 	ctx->args->copy_status = 1;
 
-	coord_pid = clone(__ckpt_coordinator, sp, CLONE_NEWPID|SIGCHLD, ctx);
+	flags |= CLONE_NEWPID|CLONE_NEWNS;
+
+	coord_pid = clone(__ckpt_coordinator, sp, flags, ctx);
 	genstack_release(stk);
 	if (coord_pid < 0) {
 		ckpt_perror("clone coordinator");
@@ -1610,10 +1647,16 @@ int ckpt_fork_stub(void *data)
 	struct task *task = (struct task *) data;
 	struct ckpt_ctx *ctx = task->ctx;
 
+	if ((task->flags & TASK_NEWROOT) && chroot(ctx->args->root) < 0)
+		return -1;
+
 	/* tasks with new pid-ns need new /proc mount */
 	if ((task->flags & TASK_NEWPID) && ckpt_remount_proc(ctx) < 0)
 		return -1;
 
+	if ((task->flags & TASK_NEWPTS) && ckpt_remount_devpts(ctx) < 0)
+		return -1;
+
 	/*
 	 * In restart into a new pid namespace (--pidns), coordinator
 	 * is the container init, hence if it terminated permatutely
@@ -1691,6 +1734,9 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 		pid = 0;
 	}
 #endif
+	if (child->flags & TASK_NEWNS) {
+		flags |= CLONE_NEWNS;
+	}
 
 	if (child->flags & (TASK_SIBLING | TASK_THREAD))
 		child->real_parent = getppid();
-- 
1.6.6.1
