From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH RFC] powerpc: catch 32/64bit mix
Date: Wed, 25 Nov 2009 10:22:50 -0600
Message-ID: <20091125162250.GA9034@us.ibm.com>
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

The arch-specific restore_thread() and restore_cpu() are called after
restore_task_obj()s.  This means that when a 32-bit task calls
sys_restart() with a 64-bit image, we'll be reloading memory mappings
before those are called, and get a 'mysterious' -EINVAL for trying to
map libc into an area > TASK_SIZE.

This patch just adds a set of arch-specific flags to the cpu_hdr_task
struct.  s390 can use this to note TIF_31BIT, and powerpc uses it to
mark TIF_32BIT.

With this patch, a 32-bit task restarting a 64-bit image at least gets
a meaningful message in the user logfile and syslog:
	32-bit task trying to restart a 64-bit one

If we keep this patch, then we'll want to drop bitness_test from
restore_cpu() in powerpc, and maybe use that code instead of the code
I used.  We also may eventually want to actually switch the task
personality.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/powerpc/mm/checkpoint.c   |   30 ++++++++++++++++++++++++++++++
 arch/s390/mm/checkpoint.c      |   10 ++++++++++
 arch/x86/mm/checkpoint.c       |   10 ++++++++++
 checkpoint/process.c           |    6 ++++++
 include/linux/checkpoint.h     |    6 ++++++
 include/linux/checkpoint_hdr.h |    1 +
 6 files changed, 63 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/mm/checkpoint.c b/arch/powerpc/mm/checkpoint.c
index de18467..ec758d9 100644
--- a/arch/powerpc/mm/checkpoint.c
+++ b/arch/powerpc/mm/checkpoint.c
@@ -207,6 +207,13 @@ static void checkpoint_dabr(struct ckpt_hdr_cpu *cpu_hdr,
 	ckpt_cpu_feature_set(cpu_hdr, CKPT_USED_DEBUG);
 }
 
+/* called early to set TIF_32BIT etc */
+void checkpoint_arch_thread(struct ckpt_hdr_task *h, struct task_struct *t)
+{
+	if (test_tsk_thread_flag(t, TIF_32BIT))
+		h->arch_flags |= CKPT_ARCH_32BIT;
+}
+
 /* dump the thread_struct of a given task */
 int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
 {
@@ -264,6 +271,29 @@ int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
  * Restart
  */
 
+/*
+ * Called early to check/reset TIF_32BIT etc.
+ * Eventually we want to actually set the personality, but for now we
+ * should at least catch and tell the user what happened.
+ */
+int restore_arch_thread(struct ckpt_ctx *ctx, struct ckpt_hdr_task *h)
+{
+	int me = test_thread_flag(TIF_32BIT);
+	int ckpted = (!!(h->arch_flags & CKPT_ARCH_32BIT));
+
+	/* all's we if both are 32-bit or 64-bit */
+	if (!(me ^ ckpted))
+		return 0;
+
+	if (me)
+		ckpt_err(ctx, -EINVAL,
+			 "32-bit task trying to restart a 64-bit one\n");
+	else
+		ckpt_err(ctx, -EINVAL,
+			 "64-bit task trying to restart a 32-bit one\n");
+	return -EINVAL;
+}
+
 /* read the thread_struct into the current task */
 int restore_thread(struct ckpt_ctx *ctx)
 {
diff --git a/arch/s390/mm/checkpoint.c b/arch/s390/mm/checkpoint.c
index 40dd417..639df3f 100644
--- a/arch/s390/mm/checkpoint.c
+++ b/arch/s390/mm/checkpoint.c
@@ -81,6 +81,10 @@ static void s390_mm(int op, struct ckpt_hdr_mm_context *h,
 	CKPT_COPY(op, h->asce_limit, mm->context.asce_limit);
 }
 
+/* called early to set TIF_31BIT etc */
+void checkpoint_ach_thread(struct ckpt_hdr_task *h, struct task_struct *t)
+{ }
+
 int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	return 0;
@@ -141,6 +145,12 @@ int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
  * Restart
  */
 
+/* called early to check/reset TIF_31BIT etc */
+int restore_arch_thread(struct ckpt_ctx *ctx, struct ckpt_hdr_task *h)
+{
+	return 0;
+}
+
 int restore_thread(struct ckpt_ctx *ctx)
 {
 	return 0;
diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index 2752fdf..5a33dfd 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -165,6 +165,10 @@ static int may_checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
 	return 0;
 }
 
+/* called early to set TIF_32BIT etc */
+void checkpoint_arch_thread(struct ckpt_hdr_task *h, struct task_struct *t)
+{ }
+
 /* dump the thread_struct of a given task */
 int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
 {
@@ -399,6 +403,12 @@ int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
  * Restart
  */
 
+/* called early to check/reset TIF_32BIT etc */
+int restore_arch_thread(struct ckpt_ctx *ctx, struct ckpt_hdr_task *h)
+{
+	return 0;
+}
+
 /* read the thread_struct into the current task */
 int restore_thread(struct ckpt_ctx *ctx)
 {
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 4cce6f8..2ad79ee 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -138,6 +138,8 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 	h->exit_state = t->exit_state;
 	h->exit_code = t->exit_code;
 
+	checkpoint_arch_thread(h, t);
+
 	if (t->exit_state) {
 		/* zombie - skip remaining state */
 		BUG_ON(t->exit_state != EXIT_ZOMBIE);
@@ -504,6 +506,10 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
+	ret = restore_arch_thread(ctx, h);
+	if (ret)
+		return ret;
+
 	ret = -EINVAL;
 	if (h->state == TASK_DEAD) {
 		if (h->exit_state != EXIT_ZOMBIE)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 550f6e8..343a166 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -161,12 +161,18 @@ extern int restore_task(struct ckpt_ctx *ctx);
 extern int pre_restore_task(void);
 extern void post_restore_task(void);
 
+/* arch_thread flags */
+#define CKPT_ARCH_32BIT		0x01
+
 /* arch hooks */
+extern void checkpoint_arch_thread(struct ckpt_hdr_task *h,
+				   struct task_struct *t);
 extern int checkpoint_write_header_arch(struct ckpt_ctx *ctx);
 extern int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
 
+extern int restore_arch_thread(struct ckpt_ctx *ctx, struct ckpt_hdr_task *h);
 extern int restore_read_header_arch(struct ckpt_ctx *ctx);
 extern int restore_thread(struct ckpt_ctx *ctx);
 extern int restore_cpu(struct ckpt_ctx *ctx);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 667b7aa..14976b2 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -344,6 +344,7 @@ struct ckpt_hdr_task {
 	__u32 compat_robust_futex_list; /* a compat __user ptr */
 	__u32 robust_futex_head_len;
 	__u64 robust_futex_list; /* a __user ptr */
+	__u64 arch_flags;	 /* includes ARCH_32BIT */
 } __attribute__((aligned(8)));
 
 /* Posix capabilities */
-- 
1.6.2.3
