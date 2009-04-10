From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 15/30] cr: x86_64 xstate support
Date: Fri, 10 Apr 2009 06:37:05 +0400
Message-ID: <20090410023705.GP27788__38569.8117585436$1239331974$gmane$org@x200.localdomain>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/linux/cr.h    |    3 ++
 kernel/cr/cr-x86_64.c |   72 ++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 67 insertions(+), 8 deletions(-)

--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -140,6 +140,9 @@ struct cr_image_arch_x86_64 {
 	__u64		cr_dr7;
 
 	__u64		cr_tls_array[3];
+
+	__u32		cr_len_xstate;
+	/* __u8	cr_xstate[cr_len_xstate]; */
 } __packed;
 
 struct cr_image_mm_struct {
--- a/kernel/cr/cr-x86_64.c
+++ b/kernel/cr/cr-x86_64.c
@@ -32,11 +32,27 @@ __u32 cr_task_struct_arch(struct task_struct *tsk)
 
 int cr_arch_check_image_task_struct(struct cr_image_task_struct *i)
 {
-	if (i->cr_tsk_arch == CR_ARCH_X86_64)
+	if (i->cr_tsk_arch == CR_ARCH_X86_64) {
+		struct cr_image_arch_x86_64 *arch_i = (struct cr_image_arch_x86_64 *)(i + 1);
+		unsigned int len_xstate = arch_i->cr_len_xstate;
+
+		if (len_xstate > 0 && len_xstate != xstate_size) {
+			WARN(1, "xstate size mismatch %u:%u, tsk '%s'\n", len_xstate, xstate_size, i->cr_comm);
+			return -EINVAL;
+		}
 		return 0;
+	}
 #ifdef CONFIG_COMPAT
-	if (i->cr_tsk_arch == CR_ARCH_X86_32)
+	if (i->cr_tsk_arch == CR_ARCH_X86_32) {
+		struct cr_image_arch_x86_32 *arch_i = (struct cr_image_arch_x86_32 *)(i + 1);
+		unsigned int len_xstate = arch_i->cr_len_xstate;
+
+		if (len_xstate > 0 && len_xstate != xstate_size) {
+			WARN(1, "xstate size mismatch %u:%u, tsk '%s'\n", len_xstate, xstate_size, i->cr_comm);
+			return -EINVAL;
+		}
 		return 0;
+	}
 #endif
 	return -EINVAL;
 }
@@ -50,15 +66,13 @@ unsigned int cr_arch_len_task_struct(struct task_struct *tsk)
 	if (test_tsk_thread_flag(tsk, TIF_IA32))
 		len = sizeof(struct cr_image_arch_x86_32);
 #endif
+	if (tsk->thread.xstate)
+		len += xstate_size;
 	return len;
 }
 
 int cr_arch_check_task_struct(struct task_struct *tsk)
 {
-	if (tsk->thread.xstate) {
-		WARN_ON(1);
-		return -EINVAL;
-	}
 	if (tsk->thread.io_bitmap_ptr) {
 		WARN_ON(1);
 		return -EINVAL;
@@ -125,6 +139,26 @@ static u16 decode_segment(__u16 reg)
 	BUG();
 }
 
+static int cr_dump_xstate(struct cr_context *ctx, struct task_struct *tsk)
+{
+	if (tsk->thread.xstate)
+		return cr_write(ctx, tsk->thread.xstate, xstate_size);
+	return 0;
+}
+
+static int cr_restore_xstate(struct task_struct *tsk, void *xstate, unsigned int len)
+{
+	int rv;
+
+	if (len == 0)
+		return 0;
+
+	rv = init_fpu(tsk);
+	if (rv == 0)
+		memcpy(tsk->thread.xstate, xstate, len);
+	return rv;
+}
+
 #ifdef CONFIG_COMPAT
 static int cr_dump_task_struct_x86_32(struct cr_context *ctx, struct task_struct *tsk)
 {
@@ -166,9 +200,15 @@ static int cr_dump_task_struct_x86_32(struct cr_context *ctx, struct task_struct
 	BUILD_BUG_ON(sizeof(tsk->thread.tls_array) != 3 * 8);
 	memcpy(i->cr_tls_array, tsk->thread.tls_array, sizeof(i->cr_tls_array));
 
+	i->cr_len_xstate = 0;
+	if (tsk->thread.xstate)
+		i->cr_len_xstate = xstate_size;
+
 	rv = cr_write(ctx, i, sizeof(*i));
 	kfree(i);
-	return rv;
+	if (rv < 0)
+		return rv;
+	return cr_dump_xstate(ctx, tsk);
 }
 #endif
 
@@ -218,9 +258,15 @@ static int cr_dump_task_struct_x86_64(struct cr_context *ctx, struct task_struct
 	i->cr_dr6 = tsk->thread.debugreg6;
 	i->cr_dr7 = tsk->thread.debugreg7;
 
+	i->cr_len_xstate = 0;
+	if (tsk->thread.xstate)
+		i->cr_len_xstate = xstate_size;
+
 	rv = cr_write(ctx, i, sizeof(*i));
 	kfree(i);
-	return rv;
+	if (rv < 0)
+		return rv;
+	return cr_dump_xstate(ctx, tsk);
 }
 
 int cr_arch_dump_task_struct(struct cr_context *ctx, struct task_struct *tsk)
@@ -236,6 +282,7 @@ int cr_arch_dump_task_struct(struct cr_context *ctx, struct task_struct *tsk)
 static int cr_restore_task_struct_x86_32(struct task_struct *tsk, struct cr_image_arch_x86_32 *i)
 {
 	struct pt_regs *regs = task_pt_regs(tsk);
+	int rv;
 
 	tsk->thread.sp = (unsigned long)regs;
 	tsk->thread.sp0 = (unsigned long)(regs + 1);
@@ -271,6 +318,10 @@ static int cr_restore_task_struct_x86_32(struct task_struct *tsk, struct cr_imag
 
 	memcpy(tsk->thread.tls_array, i->cr_tls_array, 3 * 8);
 
+	rv = cr_restore_xstate(tsk, i + 1, i->cr_len_xstate);
+	if (rv < 0)
+		return rv;
+
 	set_tsk_thread_flag(tsk, TIF_FORK);
 	set_tsk_thread_flag(tsk, TIF_IA32);
 	return 0;
@@ -280,6 +331,7 @@ static int cr_restore_task_struct_x86_32(struct task_struct *tsk, struct cr_imag
 static int cr_restore_task_struct_x86_64(struct task_struct *tsk, struct cr_image_arch_x86_64 *i)
 {
 	struct pt_regs *regs = task_pt_regs(tsk);
+	int rv;
 
 	tsk->thread.sp = (unsigned long)regs;
 	tsk->thread.sp0 = (unsigned long)(regs + 1);
@@ -321,6 +373,10 @@ static int cr_restore_task_struct_x86_64(struct task_struct *tsk, struct cr_imag
 	tsk->thread.debugreg6 = i->cr_dr6;
 	tsk->thread.debugreg7 = i->cr_dr7;
 
+	rv = cr_restore_xstate(tsk, i + 1, i->cr_len_xstate);
+	if (rv < 0)
+		return rv;
+
 	set_tsk_thread_flag(tsk, TIF_FORK);
 	return 0;
 }
