From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/3] checkpoint/powerpc: save and restore nvgprs for
	checkpoint/restart
Date: Fri,  4 Dec 2009 20:48:26 -0600
Message-ID: <1259981307-24936-3-git-send-email-ntl@pobox.com>
References: <1259981307-24936-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1259981307-24936-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On system call entry, powerpc explicitly saves and restores the full
user register state for only a few "special" system calls (fork,
clone, etc).  The checkpoint and restart syscalls need this treatment
too.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 arch/powerpc/include/asm/systbl.h |    4 ++--
 arch/powerpc/kernel/entry_32.S    |   23 +++++++++++++++++++++++
 arch/powerpc/kernel/entry_64.S    |   16 ++++++++++++++++
 3 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index c374cb7..76924b3 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -327,5 +327,5 @@ COMPAT_SYS_SPU(preadv)
 COMPAT_SYS_SPU(pwritev)
 COMPAT_SYS(rt_tgsigqueueinfo)
 PPC_SYS(eclone)
-SYSCALL(checkpoint)
-SYSCALL(restart)
+PPC_SYS(checkpoint)
+PPC_SYS(restart)
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
index febdca1..6b50a8c 100644
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
-- 
1.6.0.6
