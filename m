From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 25/38] C/R: x86_64 xstate
Date: Fri, 22 May 2009 08:55:19 +0400
Message-ID: <1242968132-1044-25-git-send-email-adobriyan__38300.8245066323$1242969467$gmane$org@gmail.com>
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

Again, checks aren't enough on all counts.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/kstate-image.h  |    3 ++
 kernel/kstate/kstate-x86_64.c |   44 ++++++++++++++++++++++++++++++++++++----
 2 files changed, 42 insertions(+), 5 deletions(-)

diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index 7c54711..d956d05 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -151,6 +151,9 @@ struct kstate_image_task_struct_x86_64 {
 	__u64		dr7;
 
 	__u64		tls_array[3];
+
+	__u8		len_xstate;
+	/* __u8 xstate[len_xstate]; */
 } __packed;
 
 struct kstate_image_mm_struct {
diff --git a/kernel/kstate/kstate-x86_64.c b/kernel/kstate/kstate-x86_64.c
index 83ed1b5..e18cca1 100644
--- a/kernel/kstate/kstate-x86_64.c
+++ b/kernel/kstate/kstate-x86_64.c
@@ -1,5 +1,6 @@
 /* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
 #include <linux/sched.h>
+#include <asm/i387.h>
 
 #include <linux/kstate.h>
 #include <linux/kstate-image.h>
@@ -74,10 +75,14 @@ static int check_tls(struct desc_struct *desc)
 static int check_image_task_struct_x86_64(struct kstate_image_task_struct *tsk_i)
 {
 	struct kstate_image_task_struct_x86_64 *i = (void *)(tsk_i + 1);
+	unsigned int len_xstate;
 	int rv;
 
 	if (tsk_i->hdr.obj_len < sizeof(*tsk_i) + sizeof(*i))
 		return -EINVAL;
+	len_xstate = i->len_xstate;
+	if (tsk_i->hdr.obj_len - sizeof(*tsk_i) - sizeof(*i) < len_xstate)
+		return -EINVAL;
 
 	rv = check_rflags(i->rflags);
 	if (rv < 0)
@@ -129,6 +134,11 @@ static int check_image_task_struct_x86_64(struct kstate_image_task_struct *tsk_i
 			return rv;
 	}
 
+	if (len_xstate > 0 && len_xstate != xstate_size) {
+		WARN(1, "xstate size mismatch %u:%u\n", len_xstate, xstate_size);
+		return -EINVAL;
+	}
+
 	return 0;
 }
 
@@ -141,7 +151,12 @@ int kstate_arch_check_image_task_struct(struct kstate_image_task_struct *i)
 
 unsigned int kstate_arch_len_task_struct(struct task_struct *tsk)
 {
-	return sizeof(struct kstate_image_task_struct_x86_64);
+	unsigned int len;
+
+	len = sizeof(struct kstate_image_task_struct_x86_64);
+	if (tsk->thread.xstate)
+		len += xstate_size;
+	return len;
 }
 
 int kstate_arch_check_task_struct(struct task_struct *tsk)
@@ -154,10 +169,6 @@ int kstate_arch_check_task_struct(struct task_struct *tsk)
 		return -EINVAL;
 	}
 #endif
-	if (tsk->thread.xstate) {
-		WARN_ON(1);
-		return -EINVAL;
-	}
 	rb = &task_thread_info(tsk)->restart_block;
 	if (rb->fn != current_thread_info()->restart_block.fn) {
 		WARN(1, "rb->fn = %pF\n", rb->fn);
@@ -261,6 +272,12 @@ static int dump_task_struct_x86_64(struct kstate_context *ctx, struct task_struc
 	BUILD_BUG_ON(sizeof(tsk->thread.tls_array) != 3 * 8);
 	memcpy(i->tls_array, tsk->thread.tls_array, sizeof(i->tls_array));
 
+	i->len_xstate = 0;
+	if (tsk->thread.xstate) {
+		i->len_xstate = xstate_size;
+		memcpy(i + 1, tsk->thread.xstate, xstate_size);
+	}
+
 	return 0;
 }
 
@@ -269,9 +286,20 @@ int kstate_arch_dump_task_struct(struct kstate_context *ctx, struct task_struct
 	return dump_task_struct_x86_64(ctx, tsk, arch_i);
 }
 
+static int restore_xstate(struct task_struct *tsk, void *xstate, unsigned int len)
+{
+	int rv;
+
+	rv = init_fpu(tsk);
+	if (rv == 0)
+		memcpy(tsk->thread.xstate, xstate, len);
+	return rv;
+}
+
 static int restore_task_struct_x86_64(struct task_struct *tsk, struct kstate_image_task_struct_x86_64 *i)
 {
 	struct pt_regs *regs = task_pt_regs(tsk);
+	int rv;
 
 	tsk->thread.sp = (unsigned long)regs;
 	tsk->thread.sp0 = (unsigned long)(regs + 1);
@@ -319,6 +347,12 @@ static int restore_task_struct_x86_64(struct task_struct *tsk, struct kstate_ima
 
 	memcpy(tsk->thread.tls_array, i->tls_array, sizeof(i->tls_array));
 
+	if (i->len_xstate) {
+		rv = restore_xstate(tsk, i + 1, i->len_xstate);
+		if (rv < 0)
+			return rv;
+	}
+
 	set_tsk_thread_flag(tsk, TIF_FORK);
 	return 0;
 }
-- 
1.5.6.5
