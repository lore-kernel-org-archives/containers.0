From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 18/54] c/r of restart-blocks
Date: Tue, 28 Apr 2009 19:23:48 -0400
Message-ID: <1240961064-13991-19-git-send-email-orenl@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240961064-13991-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

(Paraphrasing what's said this message:
http://lists.openwall.net/linux-kernel/2007/12/05/64)

Restart blocks are callbacks used cause a system call to be restarted
with the arguments specified in the system call restart block. It is
useful for system call that are not idempotent, i.e. the argument(s)
might be a relative timeout, where some adjustments are required when
restarting the system call. It relies on the system call itself to set
up its restart point and the argument save area.  They are rare: an
actual signal would turn that it an EINTR. The only case that should
ever trigger this is some kernel action that interrupts the system
call, but does not actually result in any user-visible state changes -
like freeze and thaw.

So restart blocks are about time remaining for the system call to
sleep/wait. Generally in c/r, there are two possible time models that
we can follow: absolute, relative. Here, I chose to save the relative
timeout, measured from the beginning of the checkpoint. The time when
the checkpoint (and restart) begin is also saved. This information is
sufficient to restart in either model (absolute or negative).

Which model to use should eventually be a per application choice (and
possible configurable via cradvise() or some sort). For now, we adopt
the relative model, namely, at restart the timeout is set relative to
the beginning of the restart.

To checkpoint, we check if a task has a valid restart block, and if so
we save the *remaining* time that is has to wait/sleep, and the type
of the restart block.

To restart, we fill in the data required at the proper place in the
thread information. If the system call return an error (which is
possibly an -ERESTARTSYS eg), we not only use that error as our own
return value, but also arrange for the task to execute the signal
handler (by faking a signal). The handler, in turn, already has the
code to handle these restart request gracefully.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 arch/x86/mm/checkpoint.c         |    8 +-
 checkpoint/checkpoint.c          |    1 +
 checkpoint/process.c             |  219 ++++++++++++++++++++++++++++++++++++++
 checkpoint/restart.c             |   35 ++++++-
 checkpoint/sys.c                 |    2 +
 include/linux/checkpoint.h       |    4 +
 include/linux/checkpoint_hdr.h   |   22 ++++
 include/linux/checkpoint_types.h |    3 +
 8 files changed, 288 insertions(+), 6 deletions(-)

diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index a475a30..bd9449b 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -64,10 +64,10 @@ int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
 	 * not tied to the in-kernel representation.
 	 */
 	ret = ckpt_kwrite(ctx, thread->tls_array, sizeof(thread->tls_array));
+	if (ret < 0)
+		return ret;
 
-	/* IGNORE RESTART BLOCKS FOR NOW ... */
-
-	return ret;
+	return checkpoint_restart_block(ctx, t);
 }
 
 #ifdef CONFIG_X86_64
@@ -327,7 +327,7 @@ int restore_thread(struct ckpt_ctx *ctx)
 		kfree(desc);
 	}
 
-	ret = 0;
+	ret = restore_restart_block(ctx);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index b741557..07901c1 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -24,6 +24,7 @@
 #include <linux/mount.h>
 #include <linux/utsname.h>
 #include <linux/magic.h>
+#include <linux/hrtimer.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index a0e8163..d5ee6fd 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -12,6 +12,9 @@
 #define CKPT_DFLAG  CKPT_DSYS
 
 #include <linux/sched.h>
+#include <linux/posix-timers.h>
+#include <linux/futex.h>
+#include <linux/poll.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -48,6 +51,117 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ckpt_write_string(ctx, t->comm, TASK_COMM_LEN);
 }
 
+/* dump the task_struct of a given task */
+int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_restart_block *h;
+	struct restart_block *restart_block;
+	long (*fn)(struct restart_block *);
+	s64 base, expire = 0;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_RESTART_BLOCK);
+	if (!h)
+		return -ENOMEM;
+
+	base = ktime_to_ns(ctx->ktime_begin);
+	restart_block = &task_thread_info(t)->restart_block;
+	fn = restart_block->fn;
+
+	/* FIX: enumerate clockid_t so we're immune to changes */
+
+	if (fn == do_no_restart_syscall) {
+
+		h->fn = CKPT_RESTART_BLOCK_NONE;
+		ckpt_debug("restart_block: non\n");
+
+	} else if (fn == hrtimer_nanosleep_restart) {
+
+		h->fn = CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP;
+		h->arg_0 = restart_block->nanosleep.index;
+		h->arg_1 = (unsigned long) restart_block->nanosleep.rmtp;
+		expire = restart_block->nanosleep.expires;
+		ckpt_debug("restart_block: hrtimer expire %lld now %lld\n",
+			 expire, base);
+
+	} else if (fn == posix_cpu_nsleep_restart) {
+		struct timespec ts;
+
+		h->fn = CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP;
+		h->arg_0 = restart_block->arg0;
+		h->arg_1 = restart_block->arg1;
+		ts.tv_sec = restart_block->arg2;
+		ts.tv_nsec = restart_block->arg3;
+		expire = timespec_to_ns(&ts);
+		ckpt_debug("restart_block: posix_cpu expire %lld now %lld\n",
+			 expire, base);
+
+#ifdef CONFIG_COMPAT
+	} else if (fn == compat_nanosleep_restart) {
+
+		h->fn = CKPT_RESTART_BLOCK_NANOSLEEP;
+		h->arg_0 = restart_block->nanosleep.index;
+		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
+		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
+		expire = restart_block->nanosleep.expires;
+		ckpt_debug("restart_block: compat expire %lld now %lld\n",
+			 expire, base);
+
+	} else if (fn == compat_clock_nanosleep_restart) {
+
+		h->fn = CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP;
+		h->arg_0 = restart_block->nanosleep.index;
+		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
+		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
+		expire = restart_block->nanosleep.expires;
+		ckpt_debug("restart_block: compat_clock expire %lld now %lld\n",
+			 expire, base);
+
+#endif
+	} else if (fn == futex_wait_restart) {
+
+		h->fn = CKPT_RESTART_BLOCK_FUTEX;
+		h->arg_0 = (unsigned long) restart_block->futex.uaddr;
+		h->arg_1 = restart_block->futex.val;
+		h->arg_2 = restart_block->futex.flags;
+		h->arg_3 = restart_block->futex.bitset;
+		expire = restart_block->futex.time;
+		ckpt_debug("restart_block: futex expire %lld now %lld\n",
+			 expire, base);
+
+	} else if (fn == do_restart_poll) {
+		struct timespec ts;
+
+		h->fn = CKPT_RESTART_BLOCK_POLL;
+		h->arg_0 = (unsigned long) restart_block->poll.ufds;
+		h->arg_1 = restart_block->poll.nfds;
+		h->arg_2 = restart_block->poll.has_timeout;
+		ts.tv_sec = restart_block->poll.tv_sec;
+		ts.tv_nsec = restart_block->poll.tv_nsec;
+		expire = timespec_to_ns(&ts);
+		ckpt_debug("restart_block: poll expire %lld now %lld\n",
+			 expire, base);
+
+	} else {
+
+		BUG();
+
+	}
+
+	/* common to all restart blocks: */
+	if (base < expire)
+		h->arg_4 = (expire - base);
+
+	ckpt_debug("restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
+		 h->arg_0, h->arg_1, h->arg_2, h->arg_3, h->arg_4);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	ckpt_debug("restart_block ret %d\n", ret);
+	return ret;
+}
+
 /* dump the entire state of a given task */
 int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 {
@@ -103,6 +217,111 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+int restore_restart_block(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_restart_block *h;
+	struct restart_block restart_block;
+	struct timespec ts;
+	clockid_t clockid;
+	s64 expire;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_RESTART_BLOCK);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	expire = ktime_to_ns(ctx->ktime_begin) + h->arg_4;
+	restart_block.fn = NULL;
+
+	ckpt_debug("restart_block: expire %lld begin %lld\n",
+		 expire, ktime_to_ns(ctx->ktime_begin));
+	ckpt_debug("restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
+		 h->arg_0, h->arg_1, h->arg_2, h->arg_3, h->arg_4);
+
+	switch (h->fn) {
+	case CKPT_RESTART_BLOCK_NONE:
+		restart_block.fn = do_no_restart_syscall;
+		break;
+	case CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP:
+		clockid = h->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = hrtimer_nanosleep_restart;
+		restart_block.nanosleep.index = clockid;
+		restart_block.nanosleep.rmtp =
+			(struct timespec __user *) (unsigned long) h->arg_1;
+		restart_block.nanosleep.expires = expire;
+		break;
+	case CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP:
+		clockid = h->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = posix_cpu_nsleep_restart;
+		restart_block.arg0 = clockid;
+		restart_block.arg1 = h->arg_1;
+		ts = ns_to_timespec(expire);
+		restart_block.arg2 = ts.tv_sec;
+		restart_block.arg3 = ts.tv_nsec;
+		break;
+#ifdef CONFIG_COMPAT
+	case CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP:
+		clockid = h->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = compat_nanosleep_restart;
+		restart_block.nanosleep.index = clockid;
+		restart_block.nanosleep.rmtp =
+			(struct timespec __user *) (unsigned long) h->arg_1;
+		restart_block.nanosleep.compat_rmtp =
+			(struct compat_timespec __user *)
+				(unsigned long) h->arg_2;
+		resatrt_block.nanosleep.expires = expire;
+		break;
+	case CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP:
+		clockid = h->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = compat_clock_nanosleep_restart;
+		restart_block.nanosleep.index = clockid;
+		restart_block.nanosleep.rmtp =
+			(struct timespec __user *) (unsigned long) h->arg_1;
+		restart_block.nanosleep.compat_rmtp =
+			(struct compat_timespec __user *)
+				(unsigned long) h->arg_2;
+		resatrt_block.nanosleep.expires = expire;
+		break;
+#endif
+	case CKPT_RESTART_BLOCK_FUTEX:
+		restart_block.fn = futex_wait_restart;
+		restart_block.futex.uaddr = (u32 *) (unsigned long) h->arg_0;
+		restart_block.futex.val = h->arg_1;
+		restart_block.futex.flags = h->arg_2;
+		restart_block.futex.bitset = h->arg_3;
+		restart_block.futex.time = expire;
+		break;
+	case CKPT_RESTART_BLOCK_POLL:
+		restart_block.fn = do_restart_poll;
+		restart_block.poll.ufds =
+			(struct pollfd __user *) (unsigned long) h->arg_0;
+		restart_block.poll.nfds = h->arg_1;
+		restart_block.poll.has_timeout = h->arg_2;
+		ts = ns_to_timespec(expire);
+		restart_block.poll.tv_sec = ts.tv_sec;
+		restart_block.poll.tv_nsec = ts.tv_nsec;
+		break;
+	default:
+		break;
+	}
+
+	if (restart_block.fn)
+		task_thread_info(current)->restart_block = restart_block;
+	else
+		ret = -EINVAL;
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
 /* read the entire state of the current task */
 int restore_task(struct ckpt_ctx *ctx)
 {
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 637de90..cf11b5a 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -16,6 +16,8 @@
 #include <linux/file.h>
 #include <linux/magic.h>
 #include <linux/utsname.h>
+#include <asm/syscall.h>
+#include <linux/elf.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -339,6 +341,34 @@ static int ctx_restart(struct ckpt_ctx *ctx, pid_t pid)
 	return 0;
 }
 
+static int restore_retval(void)
+{
+	struct pt_regs *regs = task_pt_regs(current);
+	int ret = 0;
+
+	/*
+	 * The retval should be either zero if the checkpointed task
+	 * had been in user-space when frozen, or the retval from the
+	 * syscall that had been interrupted then.
+	 *
+	 * In the latter, if the syscall succeeded (perhaps partially)
+	 * then the retval is non-negative. If it failed, the error
+	 * may be one of -ERESTART... gang, interpreted in the signal
+	 * handling code. In restart it must happen, too.
+	 *
+	 * To force execution of the signal handler now, too, we fake
+	 * a signal to ourselves (a la freeze/thaw) when ret < 0.
+	 */
+
+	/* were we from a system call?  if so, get old error/retval */
+	if (syscall_get_nr(current, regs) >= 0)
+		ret = syscall_get_error(current, regs);
+	/* old error ?  if so, make sure signal handling kicks in */
+	if (ret < 0)
+		set_tsk_thread_flag(current, TIF_SIGPENDING);
+	return ret;
+}
+
 int do_restart(struct ckpt_ctx *ctx, pid_t pid)
 {
 	int ret;
@@ -353,7 +383,8 @@ int do_restart(struct ckpt_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		return ret;
 	ret = restore_read_tail(ctx);
+	if (ret < 0)
+		return ret;
 
-	/* on success, adjust the return value if needed [TODO] */
-	return ret;
+	return restore_retval();
 }
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 0b7245a..6ba0446 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -224,6 +224,7 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long flags)
 		return ERR_PTR(-ENOMEM);
 
 	ctx->flags = flags;
+	ctx->ktime_begin = ktime_get();
 
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
@@ -241,6 +242,7 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long flags)
 	if (ckpt_obj_hash_alloc(ctx) < 0)
 		goto err;
 
+
 	return ctx;
  err:
 	ckpt_ctx_free(ctx);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index dcc3840..8964a12 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -58,6 +58,10 @@ extern int do_restart(struct ckpt_ctx *ctx, pid_t pid);
 extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_task(struct ckpt_ctx *ctx);
 
+extern int checkpoint_restart_block(struct ckpt_ctx *ctx,
+				    struct task_struct *t);
+extern int restore_restart_block(struct ckpt_ctx *ctx);
+
 /* memory */
 extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 0045c22..84403f2 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -48,6 +48,7 @@ enum {
 	CKPT_HDR_OBJREF,
 
 	CKPT_HDR_TASK = 101,
+	CKPT_HDR_RESTART_BLOCK,
 	CKPT_HDR_THREAD,
 	CKPT_HDR_CPU,
 
@@ -122,6 +123,27 @@ struct ckpt_hdr_task {
 	__u32 task_comm_len;
 } __attribute__((aligned(8)));
 
+/* (thread) restart blocks */
+struct ckpt_hdr_restart_block {
+	struct ckpt_hdr h;
+	__u64 fn;
+	__u64 arg_0;
+	__u64 arg_1;
+	__u64 arg_2;
+	__u64 arg_3;
+	__u64 arg_4;
+} __attribute__((aligned(8)));
+
+enum restart_block_type {
+	CKPT_RESTART_BLOCK_NONE = 1,
+	CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP,
+	CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP,
+	CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP,
+	CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP,
+	CKPT_RESTART_BLOCK_POLL,
+	CKPT_RESTART_BLOCK_FUTEX
+};
+
 /* memory layout */
 struct ckpt_hdr_mm {
 	struct ckpt_hdr h;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index d98ba71..f59f749 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -15,12 +15,15 @@ struct ckpt_ctx;
 #include <linux/list.h>
 #include <linux/path.h>
 #include <linux/fs.h>
+#include <linux/ktime.h>
 
 #define CKPT_VERSION  1
 
 struct ckpt_ctx {
 	int crid;		/* unique checkpoint id */
 
+	ktime_t ktime_begin;	/* checkpoint start time */
+
 	pid_t root_pid;		/* container identifier */
 	struct task_struct *root_task;	/* container root task */
 	struct nsproxy *root_nsproxy;	/* container root nsproxy */
-- 
1.5.4.3
