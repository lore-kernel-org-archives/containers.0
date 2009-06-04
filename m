From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 4/4] cgroup freezer: --- replacement patch 4/4 (b)
Date: Wed, 3 Jun 2009 20:12:19 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0906032011470.19096@takamine.ncl.cs.columbia.edu>
References: <cover.1244019829.git.matthltc@us.ibm.com>
	<89c3726813accffb7c51cd30ff93b79a4391f382.1244019829.git.matthltc@us.ibm.com>
	<20090603161840.GD7848@us.ibm.com>
	<Pine.LNX.4.64.0906031957110.19096@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0906031957110.19096-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

From 3c24531980764a71705492c2dfc2cc99366784f3 Mon Sep 17 00:00:00 2001
From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date: Wed, 3 Jun 2009 19:31:21 -0400
Subject: [PATCH] c/r: use CHECKPOINTING state for hierarchy's cgroup freezer

Set state of freezer cgroup of checkpointed task hierarchy to
"CHECKPOINTING" during a checkpoint, to ensure that tasks cannot
be thawed while at it.

get_container() grabs a reference to the root task's freezer cgroup.
Then in may_checkpoint_task() each it verifies that all tasks belong
to the same freezer group.

In particular, the root task is also tested, such that if the root
tasks changes its freezer cgroups before it moves to "CHECKPOINTING",
it will be notived and an error returned.

CONFIG_CHECKPOINT now depends on CONFIG_CGROUP_FREEZER

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/Kconfig               |    1 +
 checkpoint/checkpoint.c          |   33 ++++++++++++++++++++++++++-------
 checkpoint/sys.c                 |    3 +++
 include/linux/checkpoint_types.h |    1 +
 4 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
index 53ed6fa..a884674 100644
--- a/checkpoint/Kconfig
+++ b/checkpoint/Kconfig
@@ -9,6 +9,7 @@ config DEFERQUEUE
 config CHECKPOINT
 	bool "Enable checkpoint/restart (EXPERIMENTAL)"
 	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
+	depends on CGROUP_FREEZER
 	select DEFERQUEUE
 	help
 	  Application checkpoint/restart is the ability to save the
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 09af8b7..773657a 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -13,6 +13,7 @@
 
 #include <linux/version.h>
 #include <linux/sched.h>
+#include <linux/cgroup.h>
 #include <linux/freezer.h>
 #include <linux/ptrace.h>
 #include <linux/time.h>
@@ -267,6 +268,7 @@ static int checkpoint_all_tasks(struct ckpt_ctx *ctx)
 static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct task_struct *root = ctx->root_task;
+	struct cgroup_subsys_state *css;
 	struct nsproxy *nsproxy;
 	int ret = 0;
 
@@ -283,11 +285,16 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		return -EPERM;
 	}
 
-	/* verify that the task is frozen (unless self) */
-	if (t != current && !frozen(t)) {
-		__ckpt_write_err(ctx, "task %d (%s) is not frozen",
-				 task_pid_vnr(t), t->comm);
-		return -EBUSY;
+	/* verify that task belongs to same freezer cgroup as root */
+	if (t != current) {
+		css = get_task_cgroup_freezer(t);
+		if (css)
+			css_put(css);
+		if (css != ctx->root_freezer) {
+			__ckpt_write_err(ctx, "task %d (%s) not frozen (or wrong cgroup)",
+					 task_pid_vnr(t), t->comm);
+			return -EBUSY;
+		}
 	}
 
 	/* FIX: add support for ptraced tasks */
@@ -543,6 +550,14 @@ static int get_container(struct ckpt_ctx *ctx, pid_t pid)
 	ctx->root_nsproxy = nsproxy;
 	ctx->root_init = is_container_init(task);
 
+	/*
+	 * If task changes cgroup later, we detect when comparing
+	 * against @ctx->root_freezer in may_checkpoint_task().
+	 */
+	ctx->root_freezer = get_task_cgroup_freezer(task);
+	if (!ctx->root_freezer)
+		return -EAGAIN;
+
 	if (!(ctx->uflags & CHECKPOINT_SUBTREE) && !ctx->root_init)
 		return -EINVAL;  /* cleanup by ckpt_ctx_free() */
 
@@ -583,7 +598,10 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 
 	ret = init_checkpoint_ctx(ctx, pid);
 	if (ret < 0)
-		goto out;
+		return ret;
+	ret = cgroup_freezer_begin_checkpoint(ctx->root_freezer);
+	if (ret < 0)
+		return ret;
 	ret = build_tree(ctx);
 	if (ret < 0)
 		goto out;
@@ -626,6 +644,7 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	/* on success, return (unique) checkpoint identifier */
 	ctx->crid = atomic_inc_return(&ctx_count);
 	ret = ctx->crid;
- out:
+out:
+	cgroup_freezer_end_checkpoint(ctx->root_freezer);
 	return ret;
 }
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 5dba2f9..5cc6e65 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -14,6 +14,7 @@
 #include <linux/sched.h>
 #include <linux/nsproxy.h>
 #include <linux/kernel.h>
+#include <linux/cgroup.h>
 #include <linux/syscalls.h>
 #include <linux/fs.h>
 #include <linux/file.h>
@@ -214,6 +215,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 		put_nsproxy(ctx->root_nsproxy);
 	if (ctx->root_task)
 		put_task_struct(ctx->root_task);
+	if (ctx->root_freezer)
+		css_put(ctx->root_freezer);
 
 	kfree(ctx->pids_arr);
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 3c9c39d..01f6c6f 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -33,6 +33,7 @@ struct ckpt_ctx {
 	pid_t root_pid;		/* (container) root identifier */
 	struct task_struct *root_task;	/* (container) root task */
 	struct nsproxy *root_nsproxy;	/* (container) root nsproxy */
+	struct cgroup_subsys_state *root_freezer;  /* (container) freezer cgroup */
 
 	unsigned long kflags;	/* kerenl flags */
 	unsigned long uflags;	/* user flags */
-- 
1.6.0.4
