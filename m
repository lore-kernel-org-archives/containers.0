From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 087/100] powerpc: wire up checkpoint and restart syscalls
Date: Sat,  1 May 2010 10:16:09 -0400
Message-ID: <1272723382-19470-88-git-send-email-orenl__1797.26226856491$1272729222$gmane$org@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Changelog [v21]:
 - Fix build break with CONFIG_CHECKPOINT=n
Changelog [v19]:
 - Checkpoint/powerpc: fix up checkpoint syscall, tidy restart

Cc: linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/powerpc/include/asm/systbl.h |    2 ++
 arch/powerpc/include/asm/unistd.h |    4 +++-
 arch/powerpc/kernel/checkpoint.c  |   18 ++++++++++++++++++
 arch/powerpc/kernel/entry_32.S    |   23 +++++++++++++++++++++++
 arch/powerpc/kernel/entry_64.S    |   16 ++++++++++++++++
 arch/powerpc/kernel/process.c     |    1 +
 6 files changed, 63 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index f94fc43..b5afba3 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -327,3 +327,5 @@ COMPAT_SYS_SPU(preadv)
 COMPAT_SYS_SPU(pwritev)
 COMPAT_SYS(rt_tgsigqueueinfo)
 PPC_SYS(eclone)
+PPC_SYS(checkpoint)
+PPC_SYS(restart)
diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index 4cdbd5c..54f6ecb 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -346,10 +346,12 @@
 #define __NR_pwritev		321
 #define __NR_rt_tgsigqueueinfo	322
 #define __NR_eclone		323
+#define __NR_checkpoint		324
+#define __NR_restart		325
 
 #ifdef __KERNEL__
 
-#define __NR_syscalls		324
+#define __NR_syscalls		326
 
 #define __NR__exit __NR_exit
 #define NR_syscalls	__NR_syscalls
diff --git a/arch/powerpc/kernel/checkpoint.c b/arch/powerpc/kernel/checkpoint.c
index 492c604..9aeab89 100644
--- a/arch/powerpc/kernel/checkpoint.c
+++ b/arch/powerpc/kernel/checkpoint.c
@@ -530,3 +530,21 @@ int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
 {
 	return 0;
 }
+
+int sys_checkpoint(unsigned long pid, unsigned long fd, unsigned long flags,
+		   unsigned long logfd, unsigned long p5, unsigned long p6,
+		   struct pt_regs *regs)
+{
+	CHECK_FULL_REGS(regs);
+
+	return do_sys_checkpoint(pid, fd, flags, logfd);
+}
+
+int sys_restart(unsigned long pid, unsigned long fd, unsigned long flags,
+		unsigned long logfd, unsigned long p5, unsigned long p6,
+		struct pt_regs *regs)
+{
+	CHECK_FULL_REGS(regs);
+
+	return do_sys_restart(pid, fd, flags, logfd);
+}
diff --git a/arch/powerpc/kernel/entry_32.S b/arch/powerpc/kernel/entry_32.S
index 579f1da..853814b 100644
--- a/arch/powerpc/kernel/entry_32.S
+++ b/arch/powerpc/kernel/entry_32.S
@@ -594,6 +594,29 @@ ppc_eclone:
 	stw	r0,_TRAP(r1)		/* register set saved */
 	b	sys_eclone
 
+/* To handle self-checkpoint we must save nvpgprs */
+	.globl	ppc_checkpoint
+ppc_checkpoint:
+	SAVE_NVGPRS(r1)
+	lwz	r0,_TRAP(r1)
+	rlwinm	r0,r0,0,0,30		/* clear LSB to indicate full */
+	stw	r0,_TRAP(r1)		/* register set saved */
+	b	sys_checkpoint
+
+/* The full register set must be restored upon return from restart.
+ * Save nvgprs unconditionally so the caller's state is
+ * restored correctly in case of error.
+ */
+	.globl	ppc_restart
+ppc_restart:
+	SAVE_NVGPRS(r1)
+	lwz	r0,_TRAP(r1)
+	rlwinm	r0,r0,0,0,30		/* clear LSB to indicate full */
+	stw	r0,_TRAP(r1)		/* register set saved */
+	bl	sys_restart
+	REST_NVGPRS(r1)
+	b ret_from_syscall
+
 	.globl	ppc_swapcontext
 ppc_swapcontext:
 	SAVE_NVGPRS(r1)
diff --git a/arch/powerpc/kernel/entry_64.S b/arch/powerpc/kernel/entry_64.S
index b763340..228f592 100644
--- a/arch/powerpc/kernel/entry_64.S
+++ b/arch/powerpc/kernel/entry_64.S
@@ -349,6 +349,22 @@ _GLOBAL(ppc_eclone)
 	bl	.sys_eclone
 	b	syscall_exit
 
+/* To handle self-checkpoint we must save nvpgprs */
+_GLOBAL(ppc_checkpoint)
+	bl	.save_nvgprs
+	bl	.sys_checkpoint
+	b	syscall_exit
+
+/* The full register set must be restored upon return from restart.
+ * Save nvgprs unconditionally so the caller's state is
+ * restored correctly in case of error.
+ */
+_GLOBAL(ppc_restart)
+	bl	.save_nvgprs
+	bl	.sys_restart
+	REST_NVGPRS(r1)
+	b	syscall_exit
+
 _GLOBAL(ppc32_swapcontext)
 	bl	.save_nvgprs
 	bl	.compat_sys_swapcontext
diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
index b183287..1664586 100644
--- a/arch/powerpc/kernel/process.c
+++ b/arch/powerpc/kernel/process.c
@@ -30,6 +30,7 @@
 #include <linux/init_task.h>
 #include <linux/module.h>
 #include <linux/kallsyms.h>
+#include <linux/checkpoint.h>
 #include <linux/mqueue.h>
 #include <linux/hardirq.h>
 #include <linux/utsname.h>
-- 
1.6.3.3
