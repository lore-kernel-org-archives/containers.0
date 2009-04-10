From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 12/30] cr: i386 xstate support
Date: Fri, 10 Apr 2009 06:36:10 +0400
Message-ID: <20090410023610.GM27788__44104.6945438304$1239331724$gmane$org@x200.localdomain>
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

 include/linux/cr.h    |    3 +++
 kernel/cr/cr-x86_32.c |   49 ++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 45 insertions(+), 7 deletions(-)

--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -96,6 +96,9 @@ struct cr_image_arch_x86_32 {
 	__u32		cr_dr7;
 
 	__u64		cr_tls_array[3];
+
+	__u32		cr_len_xstate;
+	/* __u8	cr_xstate[cr_len_xstate]; */
 } __packed;
 
 struct cr_image_mm_struct {
--- a/kernel/cr/cr-x86_32.c
+++ b/kernel/cr/cr-x86_32.c
@@ -1,5 +1,6 @@
 /* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
 #include <linux/sched.h>
+#include <asm/i387.h>
 
 #include <linux/cr.h>
 #include "cr.h"
@@ -23,22 +24,30 @@ __u32 cr_task_struct_arch(struct task_struct *tsk)
 
 int cr_arch_check_image_task_struct(struct cr_image_task_struct *i)
 {
+	struct cr_image_arch_x86_32 *arch_i = (struct cr_image_arch_x86_32 *)(i + 1);
+	unsigned int len_xstate = arch_i->cr_len_xstate;
+
 	if (i->cr_tsk_arch != CR_ARCH_X86_32)
 		return -EINVAL;
+	if (len_xstate > 0 && len_xstate != xstate_size) {
+		WARN(1, "xstate size mismatch %u:%u, tsk '%s'\n", len_xstate, xstate_size, i->cr_comm);
+		return -EINVAL;
+	}
 	return 0;
 }
 
 unsigned int cr_arch_len_task_struct(struct task_struct *tsk)
 {
-	return sizeof(struct cr_image_arch_x86_32);
+	unsigned int len;
+
+	len = sizeof(struct cr_image_arch_x86_32);
+	if (tsk->thread.xstate)
+		len += xstate_size;
+	return len;
 }
 
 int cr_arch_check_task_struct(struct task_struct *tsk)
 {
-	if (tsk->thread.xstate) {
-		WARN_ON(1);
-		return -EINVAL;
-	}
 	if (tsk->thread.vm86_info) {
 		WARN_ON(1);
 		return -EINVAL;
@@ -97,6 +106,26 @@ static u16 decode_segment(__u16 reg)
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
 int cr_arch_dump_task_struct(struct cr_context *ctx, struct task_struct *tsk)
 {
 	struct cr_image_arch_x86_32 *i;
@@ -137,9 +166,15 @@ int cr_arch_dump_task_struct(struct cr_context *ctx, struct task_struct *tsk)
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
 
 asmlinkage void ret_from_fork(void);
@@ -179,7 +214,7 @@ static int cr_restore_task_struct_x86_32(struct task_struct *tsk, struct cr_imag
 
 	memcpy(tsk->thread.tls_array, i->cr_tls_array, 3 * 8);
 
-	return 0;
+	return cr_restore_xstate(tsk, i + 1, i->cr_len_xstate);
 }
 
 int cr_arch_restore_task_struct(struct task_struct *tsk, struct cr_image_task_struct *i)
