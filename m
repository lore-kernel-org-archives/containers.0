From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: External checkpoint patch
Date: Tue, 21 Oct 2008 19:07:21 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0810211857140.22085@takamine.ncl.cs.columbia.edu>
References: <1224612971.1848.193.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224612971.1848.193.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


> Oren,
> 
> Could you take a look over Cedric's external checkpoint patch?
> 
> http://git.kernel.org/?p=linux/kernel/git/daveh/linux-2.6-cr.git;a=commit;h=28ffabbc17d3641eee2a7eb66f714c266c400263
> 
> It seems pretty small to me.
> 
> --

I committed a couple of patches on top of ckpt-v7 that do this.
(the first one is actually a simple cleanup that is unrelated).

see:
http://git.ncl.cs.columbia.edu/?p=linux-cr-dev.git;a=shortlog;h=refs/heads/ckpt-v7
(or git://git.ncl.cs.columbia.edu/pub/git/linux-cr-dev.git ckpt-v7)

*  "Minor simplification of cr_ctx_alloc(), cr_ctx_free()"
*  "External checkpoint of a task other than ourself"

To checkpoint another task, you need to freeze that other task, or to
SIGSTOP it (if using a kernel without freezer cgroup).

Restart remains the same except the the original PID is not preserved
(because we haven't solved yet the fork-with-specific-pid issue).

In reality, you would create a new names space, and have the task running
in there call 'sys_restart()'.

Below are test1.c, ckpt.c (to checkpoint), and rstr.c (to restart), as
well as the two patches.

I tested it this way:
	$ ./test.1 &
	[1] 3493

	$ kill -STOP 3493
	$ ./ckpt 3493 > ckpt.image
	
	$ mv /tmp/cr-test.out /tmp/cr-test.out.orig
	$ cp /tmp/cr-test.out.orig /tmp/cr-test.out

	$ kill -CONT 3493

	$ ./rstr < ckpt.image
now compare the output of the two output files

Oren.

------------------------------------------------------------------------

#define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <math.h>
#include <asm/unistd.h>

#define OUTFILE  "/tmp/cr-test.out"

int main(int argc, char *argv[])
{
	FILE *file;
	float a;
	int i;

	close(0);
	close(1);
	close(2);

	unlink(OUTFILE);
	file = fopen(OUTFILE, "w+");
	if (!file) {
		perror("open");
		exit(1);
	}
	if (dup2(0,2) < 0) {
		perror("dup2");
		exit(1);
	}

	a = sqrt(2.53 * (getpid() / 1.21));

	fprintf(file, "hello, world (%.2f)!\n", a);
	fflush(file);

	for (i = 0; i < 1000; i++) {
		sleep(1);
		/* make the fpu work ->  a = a + i/10  */
		a = sqrt(a*a + 2*a*(i/10.0) + i*i/100.0);
		fprintf(file, "count %d (%.2f)!\n", i, a);
		fflush(file);
	}
		
	fprintf(file, "world, hello (%.2f) !\n", a);
	fflush(file);

	return 0;
}

------------------------------------------------------------------------

#define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <asm/unistd.h>
#include <sys/syscall.h>

int main(int argc, char *argv[])
{
	pid_t pid;
	int ret;

	if (argc != 2) {
		printf("usage: ckpt PID\n");
		exit(1);
	}

	pid = atoi(argv[1]);
	if (pid <= 0) {
		printf("invalid pid\n");
		exit(1);
	}

	ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, 0);

	if (ret < 0)
		perror("checkpoint");
	else
		printf("checkpoint id %d\n", ret);

	return (ret > 0 ? 0 : 1);
}

------------------------------------------------------------------------

#define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <asm/unistd.h>
#include <sys/syscall.h>

int main(int argc, char *argv[])
{
	pid_t pid = getpid();
	int ret;

	ret = syscall(__NR_restart, pid, STDIN_FILENO, 0);
	if (ret < 0)
		perror("restart");

	printf("should not reach here !\n");

	return 0;
}

------------------------------------------------------------------------

From 9e76d100bd81afdebda049797d3109102761fb4e Mon Sep 17 00:00:00 2001
From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date: Tue, 21 Oct 2008 16:04:36 -0400
Subject: [PATCH 1/2] Minor simplification of cr_ctx_alloc(), cr_ctx_free()

Decalre 'static' cr_ctx_alloc(), cr_ctx_free()
Common error path in cr_ctx_alloc()
Add comment for preempt_disable()/enable() in cr_write_cpu_fpu()
---
 arch/x86/mm/checkpoint.c |   10 ++++++----
 checkpoint/sys.c         |   35 ++++++++++++++++++-----------------
 2 files changed, 24 insertions(+), 21 deletions(-)

diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index 554dbff..9c2d949 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -154,7 +154,7 @@ void cr_write_cpu_fpu(struct cr_hdr_cpu *hh, struct task_struct *t)
 
 	/* i387 + MMU + SSE logic */
 
-	preempt_disable();
+	preempt_disable();	/* needed if t == current */
 
 	hh->used_math = tsk_used_math(t) ? 1 : 0;
 	if (hh->used_math) {
@@ -163,14 +163,16 @@ void cr_write_cpu_fpu(struct cr_hdr_cpu *hh, struct task_struct *t)
 		 * have been cleared when task was conexted-switched out...
 		 * except if we are in process context, in which case we do
 		 */
-		if (thread_info->status & TS_USEDFPU)
-			unlazy_fpu(current);
+		if (t == current) {
+			if (thread_info->status & TS_USEDFPU)
+				   unlazy_fpu(current);
+		}
 
 		hh->has_fxsr = cpu_has_fxsr;
 		memcpy(&hh->xstate, thread->xstate, sizeof(*thread->xstate));
 	}
 
-	preempt_enable();
+	preempt_enable();	/* needed if t == current */
 }
 
 #endif	/* CONFIG_X86_64 */
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index c1f2c8f..aa519ab 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -156,7 +156,7 @@ void cr_hbuf_put(struct cr_ctx *ctx, int n)
 /* unique checkpoint identifier (FIXME: should be per-container) */
 static atomic_t cr_ctx_count;
 
-void cr_ctx_free(struct cr_ctx *ctx)
+static void cr_ctx_free(struct cr_ctx *ctx)
 {
 	if (ctx->file)
 		fput(ctx->file);
@@ -172,30 +172,30 @@ void cr_ctx_free(struct cr_ctx *ctx)
 	kfree(ctx);
 }
 
-struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
+static struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
 {
 	struct cr_ctx *ctx;
+	int err;
 
 	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
 	if (!ctx)
 		return ERR_PTR(-ENOMEM);
 
+	ctx->flags = flags;
+	ctx->pid = pid;
+
+	err = -EBADF;
 	ctx->file = fget(fd);
-	if (!ctx->file) {
-		cr_ctx_free(ctx);
-		return ERR_PTR(-EBADF);
-	}
+	if (!ctx->file)
+		goto err;
 
+	err = -ENOMEM;
 	ctx->hbuf = kmalloc(CR_HBUF_TOTAL, GFP_KERNEL);
-	if (!ctx->hbuf) {
-		cr_ctx_free(ctx);
-		return ERR_PTR(-ENOMEM);
-	}
+	if (!ctx->hbuf)
+		goto err;
 
-	if (cr_objhash_alloc(ctx) < 0) {
-		cr_ctx_free(ctx);
-		return ERR_PTR(-ENOMEM);
-	}
+	if (cr_objhash_alloc(ctx) < 0)
+		goto err;
 
 	/*
 	 * assume checkpointer is in container's root vfs
@@ -206,12 +206,13 @@ struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
 
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 
-	ctx->pid = pid;
-	ctx->flags = flags;
-
 	ctx->crid = atomic_inc_return(&cr_ctx_count);
 
 	return ctx;
+
+ err:
+	cr_ctx_free(ctx);
+	return ERR_PTR(err);
 }
 
 /**
-- 
1.5.4.3

------------------------------------------------------------------------

From fedd1a8b05f40712d21c01e22437a2a3cdbae2e9 Mon Sep 17 00:00:00 2001
From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date: Tue, 21 Oct 2008 16:26:10 -0400
Subject: [PATCH 2/2] External checkpoint of a task other than ourself

sys_checkpoint() now looks up the target pid (in our namespace) and
checkpoints that corresponding task. That task should be the root of
a container.

sys_restart() remains the same, as the restart is always done in the
context of the restarting task.
---
 checkpoint/checkpoint.c    |    4 ++-
 checkpoint/sys.c           |   65 ++++++++++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint.h |    5 +++-
 3 files changed, 70 insertions(+), 4 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 87420dc..5ee6cbf 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -190,6 +190,8 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 {
 	int ret ;
 
+	/* TODO: verity that the task is frozen (unless self) */
+
 	if (t->state == TASK_DEAD) {
 		pr_warning("CR: task may not be in state TASK_DEAD\n");
 		return -EAGAIN;
@@ -227,7 +229,7 @@ int do_checkpoint(struct cr_ctx *ctx)
 	ret = cr_write_head(ctx);
 	if (ret < 0)
 		goto out;
-	ret = cr_write_task(ctx, current);
+	ret = cr_write_task(ctx, ctx->root_task);
 	if (ret < 0)
 		goto out;
 	ret = cr_write_tail(ctx);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index aa519ab..ce98295 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -9,6 +9,8 @@
  */
 
 #include <linux/sched.h>
+#include <linux/nsproxy.h>
+#include <linux/ptrace.h>
 #include <linux/kernel.h>
 #include <linux/fs.h>
 #include <linux/file.h>
@@ -153,6 +155,60 @@ void cr_hbuf_put(struct cr_ctx *ctx, int n)
  * restart operation, and persists until the operation is completed.
  */
 
+static void cr_ctx_put_container(struct cr_ctx *ctx)
+{
+	if (ctx->root_nsproxy)
+		put_nsproxy(ctx->root_nsproxy);
+	if (ctx->root_task)
+		put_task_struct(ctx->root_task);
+	ctx->root_pid = 0;
+}
+
+static int cr_ctx_get_container(pid_t pid, struct cr_ctx *ctx)
+{
+	struct task_struct *task = NULL;
+	struct nsproxy *nsproxy = NULL;
+	int err = -ESRCH;
+
+	read_lock(&tasklist_lock);
+	task = find_task_by_vpid(pid);
+	if (task)
+		get_task_struct(task);
+	read_unlock(&tasklist_lock);
+
+	if (!task)
+		goto out;
+
+	if (!ptrace_may_access(task, PTRACE_MODE_READ)) {
+		err = -EPERM;
+		goto out;
+	}
+	  
+	rcu_read_lock();
+	if (task_nsproxy(task)) {
+		nsproxy = task_nsproxy(task);
+		get_nsproxy(nsproxy);
+	}
+	rcu_read_unlock();
+
+	if (!nsproxy)
+		goto out;
+
+	/* TODO: verify that the task is the container's root */
+	/* TODO: verify that the container is frozen */
+
+	ctx->root_pid = pid;
+	ctx->root_task = task;
+	ctx->root_nsproxy = nsproxy;
+
+	return 0;
+
+ out:
+	if (task)
+		put_task_struct(task);
+	return err;
+}
+
 /* unique checkpoint identifier (FIXME: should be per-container) */
 static atomic_t cr_ctx_count;
 
@@ -169,6 +225,8 @@ static void cr_ctx_free(struct cr_ctx *ctx)
 	cr_pgarr_free(ctx);
 	cr_objhash_free(ctx);
 
+	cr_ctx_put_container(ctx);
+
 	kfree(ctx);
 }
 
@@ -182,13 +240,16 @@ static struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
 		return ERR_PTR(-ENOMEM);
 
 	ctx->flags = flags;
-	ctx->pid = pid;
 
 	err = -EBADF;
 	ctx->file = fget(fd);
 	if (!ctx->file)
 		goto err;
 
+	err = cr_ctx_get_container(pid, ctx);
+	if (err < 0)
+		goto err;
+
 	err = -ENOMEM;
 	ctx->hbuf = kmalloc(CR_HBUF_TOTAL, GFP_KERNEL);
 	if (!ctx->hbuf)
@@ -201,7 +262,7 @@ static struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
 	 * assume checkpointer is in container's root vfs
 	 * FIXME: this works for now, but will change with real containers
 	 */
-	ctx->vfsroot = &current->fs->root;
+	ctx->vfsroot = &ctx->root_task->fs->root;
 	path_get(ctx->vfsroot);
 
 	INIT_LIST_HEAD(&ctx->pgarr_list);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index b102346..b53663b 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -16,9 +16,12 @@
 #define CR_VERSION  2
 
 struct cr_ctx {
-	pid_t pid;		/* container identifier */
 	int crid;		/* unique checkpoint id */
 
+	pid_t root_pid;		/* container identifier */
+	struct task_struct *root_task;	/* container root task */
+	struct nsproxy *root_nsproxy;	/* container root nsproxy */
+
 	unsigned long flags;
 	unsigned long oflags;	/* restart: old flags */
 
-- 
1.5.4.3
