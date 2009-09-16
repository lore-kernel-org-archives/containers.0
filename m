From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 9/9] powerpc: clone_with_pids implementation
Date: Wed, 16 Sep 2009 03:56:58 -0500
Message-ID: <1253091418-14807-10-git-send-email-ntl@pobox.com>
References: <1253091418-14807-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253091418-14807-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Mostly copy-paste from existing clone code.

(may want to hold off applying this until the ongoing clone_with_pids
discussion is resolved.)

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 arch/powerpc/include/asm/syscalls.h |    4 ++++
 arch/powerpc/include/asm/systbl.h   |    1 +
 arch/powerpc/include/asm/unistd.h   |    3 ++-
 arch/powerpc/kernel/entry_32.S      |    8 ++++++++
 arch/powerpc/kernel/entry_64.S      |    5 +++++
 arch/powerpc/kernel/process.c       |   18 ++++++++++++++++++
 6 files changed, 38 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/asm/syscalls.h b/arch/powerpc/include/asm/syscalls.h
index eb8eb40..25dfe8b 100644
--- a/arch/powerpc/include/asm/syscalls.h
+++ b/arch/powerpc/include/asm/syscalls.h
@@ -24,6 +24,10 @@ asmlinkage int sys_execve(unsigned long a0, unsigned long a1,
 asmlinkage int sys_clone(unsigned long clone_flags, unsigned long usp,
 		int __user *parent_tidp, void __user *child_threadptr,
 		int __user *child_tidp, int p6, struct pt_regs *regs);
+asmlinkage int sys_clone_with_pids(unsigned long clone_flags,
+		unsigned long usp, int __user *parent_tidp,
+		void __user *child_threadptr, int __user *child_tidp,
+		void __user *upid_setp, struct pt_regs *regs);
 asmlinkage int sys_fork(unsigned long p1, unsigned long p2,
 		unsigned long p3, unsigned long p4, unsigned long p5,
 		unsigned long p6, struct pt_regs *regs);
diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index 3d44cf3..e3c0b96 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -328,3 +328,4 @@ COMPAT_SYS_SPU(pwritev)
 COMPAT_SYS(rt_tgsigqueueinfo)
 SYSCALL(checkpoint)
 SYSCALL(restart)
+PPC_SYS(clone_with_pids)
diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index ef41ebb..c54db8b 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -347,10 +347,11 @@
 #define __NR_rt_tgsigqueueinfo	322
 #define __NR_checkpoint		323
 #define __NR_restart		324
+#define __NR_clone_with_pids	325
 
 #ifdef __KERNEL__
 
-#define __NR_syscalls		325
+#define __NR_syscalls		326
 
 #define __NR__exit __NR_exit
 #define NR_syscalls	__NR_syscalls
diff --git a/arch/powerpc/kernel/entry_32.S b/arch/powerpc/kernel/entry_32.S
index 3cadba6..081dd36 100644
--- a/arch/powerpc/kernel/entry_32.S
+++ b/arch/powerpc/kernel/entry_32.S
@@ -586,6 +586,14 @@ ppc_clone:
 	stw	r0,_TRAP(r1)		/* register set saved */
 	b	sys_clone
 
+	.globl	ppc_clone_with_pids
+ppc_clone_with_pids:
+	SAVE_NVGPRS(r1)
+	lwz	r0,_TRAP(r1)
+	rlwinm	r0,r0,0,0,30		/* clear LSB to indicate full */
+	stw	r0,_TRAP(r1)		/* register set saved */
+	b	sys_clone_with_pids
+
 	.globl	ppc_swapcontext
 ppc_swapcontext:
 	SAVE_NVGPRS(r1)
diff --git a/arch/powerpc/kernel/entry_64.S b/arch/powerpc/kernel/entry_64.S
index 43e0734..39fa316 100644
--- a/arch/powerpc/kernel/entry_64.S
+++ b/arch/powerpc/kernel/entry_64.S
@@ -320,6 +320,11 @@ _GLOBAL(ppc_clone)
 	bl	.sys_clone
 	b	syscall_exit
 
+_GLOBAL(ppc_clone_with_pids)
+	bl	.save_nvgprs
+	bl	.sys_clone_with_pids
+	b	syscall_exit
+
 _GLOBAL(ppc32_swapcontext)
 	bl	.save_nvgprs
 	bl	.compat_sys_swapcontext
diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
index 892a9f2..5ac4470 100644
--- a/arch/powerpc/kernel/process.c
+++ b/arch/powerpc/kernel/process.c
@@ -898,6 +898,24 @@ int sys_clone(unsigned long clone_flags, unsigned long usp,
  	return do_fork(clone_flags, usp, regs, 0, parent_tidp, child_tidp);
 }
 
+int sys_clone_with_pids(unsigned long clone_flags, unsigned long usp,
+	      int __user *parent_tidp, void __user *child_threadptr,
+	      int __user *child_tidp, void __user *upid_setp,
+	      struct pt_regs *regs)
+{
+	CHECK_FULL_REGS(regs);
+	if (usp == 0)
+		usp = regs->gpr[1];
+#ifdef CONFIG_PPC64
+	if (test_thread_flag(TIF_32BIT)) {
+		parent_tidp = TRUNC_PTR(parent_tidp);
+		child_tidp = TRUNC_PTR(child_tidp);
+	}
+#endif
+ 	return do_fork_with_pids(clone_flags, usp, regs, 0,
+				 parent_tidp, child_tidp, upid_setp);
+}
+
 int sys_fork(unsigned long p1, unsigned long p2, unsigned long p3,
 	     unsigned long p4, unsigned long p5, unsigned long p6,
 	     struct pt_regs *regs)
-- 
1.6.0.6
