From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc3][PATCH 15/36] c/r of restart-blocks
Date: Tue,  7 Apr 2009 08:27:23 -0400
Message-ID: <1239107264-21775-16-git-send-email-orenl@cs.columbia.edu>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239107264-21775-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
 arch/x86/mm/checkpoint.c       |    6 +-
 arch/x86/mm/restart.c          |   32 ++++++++++-
 checkpoint/checkpoint.c        |    1 +
 checkpoint/checkpoint_arch.h   |    2 +
 checkpoint/ckpt_task.c         |  120 ++++++++++++++++++++++++++++++++++++++++
 checkpoint/restart.c           |   12 ++--
 checkpoint/rstr_task.c         |  113 +++++++++++++++++++++++++++++++++++++-
 checkpoint/sys.c               |    2 +
 include/linux/checkpoint.h     |    4 +
 include/linux/checkpoint_hdr.h |   20 +++++++
 10 files changed, 300 insertions(+), 12 deletions(-)

diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index d13d7f4..64e6635 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -59,10 +59,10 @@ int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
 	 * not tied to the in-kernel representation.
 	 */
 	ret = cr_kwrite(ctx, thread->tls_array, sizeof(thread->tls_array));
+	if (ret < 0)
+		return ret;
 
-	/* IGNORE RESTART BLOCKS FOR NOW ... */
-
-	return ret;
+	return cr_write_restart_block(ctx, t);
 }
 
 #ifdef CONFIG_X86_64
diff --git a/arch/x86/mm/restart.c b/arch/x86/mm/restart.c
index fca5cd8..70a0609 100644
--- a/arch/x86/mm/restart.c
+++ b/arch/x86/mm/restart.c
@@ -11,6 +11,7 @@
 #include <asm/desc.h>
 #include <asm/i387.h>
 #include <asm/elf.h>
+#include <asm/syscall.h>
 
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
@@ -70,7 +71,7 @@ int cr_read_thread(struct cr_ctx *ctx)
 		kfree(desc);
 	}
 
-	ret = 0;
+	ret = cr_read_restart_block(ctx);
  out:
 	cr_hbuf_put(ctx, sizeof(*hh));
 	return ret;
@@ -194,6 +195,7 @@ int cr_read_cpu(struct cr_ctx *ctx)
 
 	if (hh->used_math)
 		ret = cr_read_cpu_fpu(ctx, t);
+
  out:
 	cr_hbuf_put(ctx, sizeof(*hh));
 	return ret;
@@ -287,3 +289,31 @@ int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
 	cr_hbuf_put(ctx, sizeof(*hh));
 	return ret;
 }
+
+int cr_retval_restart(struct cr_ctx *ctx)
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
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 3e26dd0..12b0d5b 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -20,6 +20,7 @@
 #include <linux/mount.h>
 #include <linux/utsname.h>
 #include <linux/magic.h>
+#include <linux/hrtimer.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
diff --git a/checkpoint/checkpoint_arch.h b/checkpoint/checkpoint_arch.h
index e43b7fe..0afe666 100644
--- a/checkpoint/checkpoint_arch.h
+++ b/checkpoint/checkpoint_arch.h
@@ -1,5 +1,7 @@
 #include <linux/checkpoint.h>
 
+extern int cr_retval_restart(struct cr_ctx *ctx);
+
 extern int cr_write_head_arch(struct cr_ctx *ctx);
 extern int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t);
diff --git a/checkpoint/ckpt_task.c b/checkpoint/ckpt_task.c
index b23bc87..5d17ade 100644
--- a/checkpoint/ckpt_task.c
+++ b/checkpoint/ckpt_task.c
@@ -9,6 +9,9 @@
  */
 
 #include <linux/sched.h>
+#include <linux/posix-timers.h>
+#include <linux/futex.h>
+#include <linux/poll.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -45,6 +48,123 @@ static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)
 	return cr_write_string(ctx, t->comm, TASK_COMM_LEN);
 }
 
+/* dump the task_struct of a given task */
+int cr_write_restart_block(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_restart_block *hh;
+	struct restart_block *restart_block;
+	long (*fn)(struct restart_block *);
+	s64 base, expire = 0;
+	int ret;
+
+	h.type = CR_HDR_RESTART_BLOCK;
+	h.len = sizeof(*hh);
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+	memset(hh, 0, sizeof(*hh));
+
+	base = ktime_to_ns(ctx->ktime_beg);
+	restart_block = &task_thread_info(t)->restart_block;
+	fn = restart_block->fn;
+
+	/* FIX: enumerate clockid_t so we're immune to changes */
+
+	if (fn == do_no_restart_syscall) {
+
+		hh->fn = CR_RESTART_BLOCK_NONE;
+		cr_debug("restart_block: non\n");
+
+	} else if (fn == hrtimer_nanosleep_restart) {
+
+		hh->fn = CR_RESTART_BLOCK_HRTIMER_NANOSLEEP;
+		hh->arg_0 = restart_block->nanosleep.index;
+		hh->arg_1 = (unsigned long) restart_block->nanosleep.rmtp;
+		expire = restart_block->nanosleep.expires;
+		cr_debug("restart_block: hrtimer expire %lld now %lld\n",
+			 expire, base);
+
+	} else if (fn == posix_cpu_nsleep_restart) {
+		struct timespec ts;
+
+		hh->fn = CR_RESTART_BLOCK_POSIX_CPU_NANOSLEEP;
+		hh->arg_0 = restart_block->arg0;
+		hh->arg_1 = restart_block->arg1;
+		ts.tv_sec = restart_block->arg2;
+		ts.tv_nsec = restart_block->arg3;
+		expire = timespec_to_ns(&ts);
+		cr_debug("restart_block: posix_cpu expire %lld now %lld\n",
+			 expire, base);
+
+#ifdef CONFIG_COMPAT
+	} else if (fn == compat_nanosleep_restart) {
+
+		hh->fn = CR_RESTART_BLOCK_NANOSLEEP;
+		hh->arg_0 = restart_block->nanosleep.index;
+		hh->arg_1 = (unsigned long) restart_block->nanosleep.rmtp;
+		hh->arg_2 = (unsigned long)
+			restart_block->nanosleep.compat_rmtp;
+		expire = restart_block->nanosleep.expires;
+		cr_debug("restart_block: compat expire %lld now %lld\n",
+			 expire, base);
+
+	} else if (fn == compat_clock_nanosleep_restart) {
+
+		hh->fn = CR_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP;
+		hh->arg_0 = restart_block->nanosleep.index;
+		hh->arg_1 = (unsigned long) restart_block->nanosleep.rmtp;
+		hh->arg_2 = (unsigned long)
+			restart_block->nanosleep.compat_rmtp;
+		expire = restart_block->nanosleep.expires;
+		cr_debug("restart_block: compat_clock expire %lld now %lld\n",
+			 expire, base);
+
+#endif
+	} else if (fn == futex_wait_restart) {
+
+		hh->fn = CR_RESTART_BLOCK_FUTEX;
+		hh->arg_0 = (unsigned long) restart_block->futex.uaddr;
+		hh->arg_1 = restart_block->futex.val;
+		hh->arg_2 = restart_block->futex.flags;
+		hh->arg_3 = restart_block->futex.bitset;
+		expire = restart_block->futex.time;
+		cr_debug("restart_block: futex expire %lld now %lld\n",
+			 expire, base);
+
+	} else if (fn == do_restart_poll) {
+		struct timespec ts;
+
+		hh->fn = CR_RESTART_BLOCK_POLL;
+		hh->arg_0 = (unsigned long) restart_block->poll.ufds;
+		hh->arg_1 = restart_block->poll.nfds;
+		hh->arg_2 = restart_block->poll.has_timeout;
+		ts.tv_sec = restart_block->poll.tv_sec;
+		ts.tv_nsec = restart_block->poll.tv_nsec;
+		expire = timespec_to_ns(&ts);
+		cr_debug("restart_block: poll expire %lld now %lld\n",
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
+		hh->arg_4 = (expire - base);
+
+	cr_debug("restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
+		 hh->arg_0, hh->arg_1, hh->arg_2, hh->arg_3, hh->arg_4);
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
+
 /* dump the entire state of a given task */
 int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 {
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 234cc92..daaaeec 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -264,18 +264,16 @@ int do_restart(struct cr_ctx *ctx, pid_t pid)
 
 	ret = cr_ctx_restart(ctx, pid);
 	if (ret < 0)
-		goto out;
+		return ret;
 	ret = cr_read_head(ctx);
 	if (ret < 0)
-		goto out;
+		return ret;
 	ret = cr_read_task(ctx);
 	if (ret < 0)
-		goto out;
+		return ret;
 	ret = cr_read_tail(ctx);
 	if (ret < 0)
-		goto out;
+		return ret;
 
-	/* on success, adjust the return value if needed [TODO] */
- out:
-	return ret;
+	return cr_retval_restart(ctx);
 }
diff --git a/checkpoint/rstr_task.c b/checkpoint/rstr_task.c
index 93c86ab..52206d8 100644
--- a/checkpoint/rstr_task.c
+++ b/checkpoint/rstr_task.c
@@ -9,6 +9,9 @@
  */
 
 #include <linux/sched.h>
+#include <linux/posix-timers.h>
+#include <linux/futex.h>
+#include <linux/poll.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -52,6 +55,115 @@ static int cr_read_task_struct(struct cr_ctx *ctx)
 	return ret;
 }
 
+int cr_read_restart_block(struct cr_ctx *ctx)
+{
+	struct cr_hdr_restart_block *hh;
+	struct restart_block restart_block;
+	struct timespec ts;
+	clockid_t clockid;
+	s64 expire;
+	int ret;
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_RESTART_BLOCK);
+	if (ret < 0)
+		goto out;
+
+	expire = ktime_to_ns(ctx->ktime_beg) + hh->arg_4;
+	restart_block.fn = NULL;
+
+	cr_debug("restart_block: expire %lld begin %lld\n",
+		 expire, ktime_to_ns(ctx->ktime_beg));
+	cr_debug("restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
+		 hh->arg_0, hh->arg_1, hh->arg_2, hh->arg_3, hh->arg_4);
+
+	switch (hh->fn) {
+	case CR_RESTART_BLOCK_NONE:
+		restart_block.fn = do_no_restart_syscall;
+		break;
+	case CR_RESTART_BLOCK_HRTIMER_NANOSLEEP:
+		clockid = hh->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = hrtimer_nanosleep_restart;
+		restart_block.nanosleep.index = clockid;
+		restart_block.nanosleep.rmtp =
+			(struct timespec __user *) (unsigned long) hh->arg_1;
+		restart_block.nanosleep.expires = expire;
+		break;
+	case CR_RESTART_BLOCK_POSIX_CPU_NANOSLEEP:
+		clockid = hh->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = posix_cpu_nsleep_restart;
+		restart_block.arg0 = clockid;
+		restart_block.arg1 = hh->arg_1;
+		ts = ns_to_timespec(expire);
+		restart_block.arg2 = ts.tv_sec;
+		restart_block.arg3 = ts.tv_nsec;
+		break;
+#ifdef CONFIG_COMPAT
+	case CR_RESTART_BLOCK_COMPAT_NANOSLEEP:
+		clockid = hh->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = compat_nanosleep_restart;
+		restart_block.nanosleep.index = clockid;
+		restart_block.nanosleep.rmtp =
+			(struct timespec __user *) (unsigned long) hh->arg_1;
+		restart_block.nanosleep.compat_rmtp =
+			(struct compat_timespec __user *)
+				(unsigned long) hh->arg_2;
+		resatrt_block.nanosleep.expires = expire;
+		break;
+	case CR_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP:
+		clockid = hh->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = compat_clock_nanosleep_restart;
+		restart_block.nanosleep.index = clockid;
+		restart_block.nanosleep.rmtp =
+			(struct timespec __user *) (unsigned long) hh->arg_1;
+		restart_block.nanosleep.compat_rmtp =
+			(struct compat_timespec __user *)
+				(unsigned long) hh->arg_2;
+		resatrt_block.nanosleep.expires = expire;
+		break;
+#endif
+	case CR_RESTART_BLOCK_FUTEX:
+		restart_block.fn = futex_wait_restart;
+		restart_block.futex.uaddr = (u32 *) (unsigned long) hh->arg_0;
+		restart_block.futex.val = hh->arg_1;
+		restart_block.futex.flags = hh->arg_2;
+		restart_block.futex.bitset = hh->arg_3;
+		restart_block.futex.time = expire;
+		break;
+	case CR_RESTART_BLOCK_POLL:
+		restart_block.fn = do_restart_poll;
+		restart_block.poll.ufds =
+			(struct pollfd __user *) (unsigned long) hh->arg_0;
+		restart_block.poll.nfds = hh->arg_1;
+		restart_block.poll.has_timeout = hh->arg_2;
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
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
 /* read the entire state of the current task */
 int cr_read_task(struct cr_ctx *ctx)
 {
@@ -76,6 +188,5 @@ int cr_read_task(struct cr_ctx *ctx)
 	ret = cr_read_cpu(ctx);
 	cr_debug("cpu: ret %d\n", ret);
  out:
-
 	return ret;
 }
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 8652c5c..863cb63 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -186,6 +186,7 @@ static struct cr_ctx *cr_ctx_alloc(int fd, unsigned long flags)
 		return ERR_PTR(-ENOMEM);
 
 	ctx->flags = flags;
+	ctx->ktime_beg = ktime_get();
 
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
@@ -203,6 +204,7 @@ static struct cr_ctx *cr_ctx_alloc(int fd, unsigned long flags)
 	if (cr_objhash_alloc(ctx) < 0)
 		goto err;
 
+
 	return ctx;
 
  err:
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 3a514fc..a94ce98 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -18,6 +18,8 @@
 struct cr_ctx {
 	int crid;		/* unique checkpoint id */
 
+	ktime_t ktime_beg;	/* checkpoint start time */
+
 	pid_t root_pid;		/* container identifier */
 	struct task_struct *root_task;	/* container root task */
 	struct nsproxy *root_nsproxy;	/* container root nsproxy */
@@ -87,10 +89,12 @@ extern struct file *cr_read_open_fname(struct cr_ctx *ctx,
 				       int flags, int mode);
 
 extern int cr_write_task(struct cr_ctx *ctx, struct task_struct *t);
+extern int cr_write_restart_block(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_write_fd_table(struct cr_ctx *ctx, struct task_struct *t);
 
 extern int cr_read_task(struct cr_ctx *ctx);
+extern int cr_read_restart_block(struct cr_ctx *ctx);
 extern int cr_read_mm(struct cr_ctx *ctx);
 extern int cr_read_fd_table(struct cr_ctx *ctx);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 30e649b..8821a30 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -45,6 +45,7 @@ enum {
 	CR_HDR_FNAME,
 
 	CR_HDR_TASK = 101,
+	CR_HDR_RESTART_BLOCK,
 	CR_HDR_THREAD,
 	CR_HDR_CPU,
 
@@ -97,6 +98,25 @@ struct cr_hdr_task {
 	__u32 task_comm_len;
 } __attribute__((aligned(8)));
 
+struct cr_hdr_restart_block {
+	__u64 fn;
+	__u64 arg_0;
+	__u64 arg_1;
+	__u64 arg_2;
+	__u64 arg_3;
+	__u64 arg_4;
+} __attribute__((aligned(8)));
+
+enum restart_block_type {
+	CR_RESTART_BLOCK_NONE = 1,
+	CR_RESTART_BLOCK_HRTIMER_NANOSLEEP,
+	CR_RESTART_BLOCK_POSIX_CPU_NANOSLEEP,
+	CR_RESTART_BLOCK_COMPAT_NANOSLEEP,
+	CR_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP,
+	CR_RESTART_BLOCK_POLL,
+	CR_RESTART_BLOCK_FUTEX
+};
+
 struct cr_hdr_mm {
 	__s32 objref;		/* identifier for shared objects */
 	__u32 map_count;
-- 
1.5.4.3
