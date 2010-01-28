From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] fix 31-bit s390 checkpoint/restart wrappers
Date: Thu, 28 Jan 2010 12:11:38 -0600
Message-ID: <20100128181138.GA18197@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch makes it possible to compile with CONFIG_COMPAT=y.  It
also refuses checkpoint of a 31-bit task, or restart from a 31-bit
task.  That's just a temporary restriction as there won't be time
to get 31-bit support for v19.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/kernel/checkpoint.c     |    9 +++++++++
 arch/s390/kernel/compat_wrapper.S |   12 +++++++-----
 arch/s390/kernel/process.c        |   12 ++++++++++++
 arch/s390/kernel/syscalls.S       |    2 +-
 4 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/arch/s390/kernel/checkpoint.c b/arch/s390/kernel/checkpoint.c
index 40dd417..8ec12c6 100644
--- a/arch/s390/kernel/checkpoint.c
+++ b/arch/s390/kernel/checkpoint.c
@@ -83,6 +83,11 @@ static void s390_mm(int op, struct ckpt_hdr_mm_context *h,
 
 int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
 {
+	/* we will eventually support this, as we do on x86-64 */
+	if (test_tsk_thread_flag(t, TIF_31BIT)) {
+		ckpt_err(ctx, -EINVAL, "checkpoint of 31-bit task\n");
+		return -EINVAL;
+	}
 	return 0;
 }
 
@@ -143,6 +148,10 @@ int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
 
 int restore_thread(struct ckpt_ctx *ctx)
 {
+	if (test_tsk_thread_flag(current, TIF_31BIT)) {
+		ckpt_err(ctx, -EINVAL, "restart from 31-bit task\n");
+		return -EINVAL;
+	}
 	return 0;
 }
 
diff --git a/arch/s390/kernel/compat_wrapper.S b/arch/s390/kernel/compat_wrapper.S
index 8d0ba6a..bb38630 100644
--- a/arch/s390/kernel/compat_wrapper.S
+++ b/arch/s390/kernel/compat_wrapper.S
@@ -1869,11 +1869,13 @@ sys_checkpoint_wrapper:
 	lgfr	%r2,%r2			# pid_t
 	lgfr	%r3,%r3			# int
 	llgfr	%r4,%r4			# unsigned long
-	jg	compat_sys_checkpoint
+	lgfr	%r5,%r5			# int
+	jg	sys_checkpoint
 
-	.globl sys_restore_wrapper
-sys_restore_wrapper:
-	lgfr	%r2,%r2			# int
+	.globl sys_restart_wrapper
+sys_restart_wrapper:
+	lgfr	%r2,%r2			# pid_t
 	lgfr	%r3,%r3			# int
 	llgfr	%r4,%r4			# unsigned long
-	jg	compat_sys_restore
+	lgfr	%r5,%r5			# int
+	jg	sys_restart
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index a7cb6bc..61b469f 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -258,6 +258,18 @@ SYSCALL_DEFINE4(restart, pid_t, pid, int, fd, unsigned long, flags,
 {
 	return do_sys_restart(pid, fd, flags, logfd);
 }
+#else
+SYSCALL_DEFINE4(checkpoint, pid_t, pid, int, fd, unsigned long, flags,
+		int, logfd)
+{
+	return -ENOSYS;
+}
+
+SYSCALL_DEFINE4(restart, pid_t, pid, int, fd, unsigned long, flags,
+		int, logfd)
+{
+	return -ENOSYS;
+}
 #endif
 
 SYSCALL_DEFINE4(eclone, unsigned int, flags_low, struct clone_args __user *,
diff --git a/arch/s390/kernel/syscalls.S b/arch/s390/kernel/syscalls.S
index ff222e1..a29f9e1 100644
--- a/arch/s390/kernel/syscalls.S
+++ b/arch/s390/kernel/syscalls.S
@@ -342,4 +342,4 @@ SYSCALL(sys_rt_tgsigqueueinfo,sys_rt_tgsigqueueinfo,compat_sys_rt_tgsigqueueinfo
 SYSCALL(sys_perf_event_open,sys_perf_event_open,sys_perf_event_open_wrapper)
 SYSCALL(sys_eclone,sys_eclone,sys_eclone_wrapper)
 SYSCALL(sys_checkpoint,sys_checkpoint,sys_checkpoint_wrapper)
-SYSCALL(sys_restart,sys_restart,sys_restore_wrapper)
+SYSCALL(sys_restart,sys_restart,sys_restart_wrapper)
-- 
1.6.1
