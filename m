From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 21/38] C/R: i386 debug registers
Date: Fri, 22 May 2009 08:55:15 +0400
Message-ID: <1242968132-1044-21-git-send-email-adobriyan__26150.3743743107$1242970764$gmane$org@gmail.com>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1242968132-1044-1-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Make extensive checks to not allow restoration of breakpoints
inside kernel code.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 arch/x86/include/asm/ptrace.h |    5 +++++
 arch/x86/kernel/ptrace.c      |    8 ++++----
 include/linux/kstate-image.h  |    7 +++++++
 kernel/kstate/kstate-x86_32.c |   26 ++++++++++++++++++++++----
 4 files changed, 38 insertions(+), 8 deletions(-)

diff --git a/arch/x86/include/asm/ptrace.h b/arch/x86/include/asm/ptrace.h
index 624f133..2b40c3c 100644
--- a/arch/x86/include/asm/ptrace.h
+++ b/arch/x86/include/asm/ptrace.h
@@ -243,6 +243,11 @@ extern void x86_ptrace_fork(struct task_struct *child,
 #define arch_ptrace_untrace(tsk) x86_ptrace_untrace(tsk)
 #define arch_ptrace_fork(child, flags) x86_ptrace_fork(child, flags)
 
+extern int ptrace_check_debugreg(int _32bit,
+				 unsigned long dr0, unsigned long dr1,
+				 unsigned long dr2, unsigned long dr3,
+				 unsigned long dr6, unsigned long dr7);
+
 #endif /* __KERNEL__ */
 
 #endif /* !__ASSEMBLY__ */
diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index afd2b7d..23941a7 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -465,10 +465,10 @@ static unsigned long ptrace_get_debugreg(struct task_struct *child, int n)
 	return 0;
 }
 
-static int ptrace_check_debugreg(int _32bit,
-				 unsigned long dr0, unsigned long dr1,
-				 unsigned long dr2, unsigned long dr3,
-				 unsigned long dr6, unsigned long dr7)
+int ptrace_check_debugreg(int _32bit,
+			  unsigned long dr0, unsigned long dr1,
+			  unsigned long dr2, unsigned long dr3,
+			  unsigned long dr6, unsigned long dr7)
 {
 	/* Breakpoint type: 00: --x, 01: -w-, 10: undefined, 11: rw- */
 	unsigned int rw[4];
diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index 8df5c4a..6f11b4d 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -97,6 +97,13 @@ struct kstate_image_task_struct_i386 {
 	__u16		gs;
 	__u16		ss;
 
+	__u32		dr0;
+	__u32		dr1;
+	__u32		dr2;
+	__u32		dr3;
+	__u32		dr6;
+	__u32		dr7;
+
 	__u64		tls_array[3];
 } __packed;
 
diff --git a/kernel/kstate/kstate-x86_32.c b/kernel/kstate/kstate-x86_32.c
index 809242c..c738e16 100644
--- a/kernel/kstate/kstate-x86_32.c
+++ b/kernel/kstate/kstate-x86_32.c
@@ -106,6 +106,10 @@ int kstate_arch_check_image_task_struct(struct kstate_image_task_struct *tsk_i)
 	if (rv < 0)
 		return rv;
 
+	rv = ptrace_check_debugreg(1, i->dr0, i->dr1, i->dr2, i->dr3, i->dr6, i->dr7);
+	if (rv < 0)
+		return rv;
+
 	if (i->tls_array[0]) {
 		rv = check_tls((struct desc_struct *)&i->tls_array[0]);
 		if (rv < 0)
@@ -138,10 +142,6 @@ int kstate_arch_check_task_struct(struct task_struct *tsk)
 		WARN_ON(1);
 		return -EINVAL;
 	}
-	if (test_tsk_thread_flag(tsk, TIF_DEBUG)) {
-		WARN_ON(1);
-		return -EINVAL;
-	}
 	rb = &task_thread_info(tsk)->restart_block;
 	if (rb->fn != current_thread_info()->restart_block.fn) {
 		WARN(1, "rb->fn = %pF\n", rb->fn);
@@ -226,6 +226,13 @@ int kstate_arch_dump_task_struct(struct kstate_context *ctx, struct task_struct
 	i->gs = encode_segment(tsk->thread.gs);
 	i->ss = encode_segment(regs->ss);
 
+	i->dr0 = tsk->thread.debugreg0;
+	i->dr1 = tsk->thread.debugreg1;
+	i->dr2 = tsk->thread.debugreg2;
+	i->dr3 = tsk->thread.debugreg3;
+	i->dr6 = tsk->thread.debugreg6;
+	i->dr7 = tsk->thread.debugreg7;
+
 	BUILD_BUG_ON(sizeof(tsk->thread.tls_array[0]) != 8);
 	BUILD_BUG_ON(sizeof(tsk->thread.tls_array) != 3 * 8);
 	memcpy(i->tls_array, tsk->thread.tls_array, sizeof(i->tls_array));
@@ -261,6 +268,17 @@ static int restore_task_struct_i386(struct task_struct *tsk, struct kstate_image
 	tsk->thread.gs = decode_segment(i->gs);
 	regs->ss = decode_segment(i->ss);
 
+	tsk->thread.debugreg0 = i->dr0;
+	tsk->thread.debugreg1 = i->dr1;
+	tsk->thread.debugreg2 = i->dr2;
+	tsk->thread.debugreg3 = i->dr3;
+	tsk->thread.debugreg6 = i->dr6;
+	tsk->thread.debugreg7 = i->dr7;
+	if (i->dr7)
+		set_tsk_thread_flag(tsk, TIF_DEBUG);
+	else
+		clear_tsk_thread_flag(tsk, TIF_DEBUG);
+
 	memcpy(tsk->thread.tls_array, i->tls_array, 3 * 8);
 
 	return 0;
-- 
1.5.6.5
