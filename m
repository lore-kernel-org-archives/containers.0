From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 1/4] x86-32 and ia32 eclone, checkpoint, restart fixes
Date: Mon, 25 Jan 2010 19:48:12 -0600
Message-ID: <1264470494-14049-2-git-send-email-serue@us.ibm.com>
References: <1264470494-14049-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1264470494-14049-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Eclone on x86-32 should use esi for 4th arg (upids), not
edi, which is 5th arg.  This will require a corresponding fix
to user-cr, but (a) it's correct and (b) it's required so that
IA32_ARG_FIXUP can put upids in the right register for
process_64.c:sys_eclone().  IA32_ARG_FIXUP will (of course) put
edi into r8, the 5th arg.

Add the ptregs_syscall stubs for eclone, checkpoint, and restart
for 32-bit api on x86-64.

With this patch (and proper user-cr), checkpoint and eclone work
on x86-32, x86-64, and in 32-bit mode on x86-64.  (restart has not
yet been tested)

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/ia32/ia32entry.S    |   11 +++++++++++
 arch/x86/kernel/process_32.c |    2 +-
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index 581b056..67bf4dc 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -477,6 +477,14 @@ quiet_ni_syscall:
 	PTREGSCALL stub32_clone, sys32_clone, %rdx
 	PTREGSCALL stub32_vfork, sys_vfork, %rdi
 	PTREGSCALL stub32_iopl, sys_iopl, %rsi
+	PTREGSCALL stub32_eclone, sys_eclone, %r8
+#ifdef CONFIG_CHECKPOINT
+	PTREGSCALL stub32_checkpoint, sys_checkpoint, %r8
+	PTREGSCALL stub32_restart, sys_restart, %r8
+#else
+	PTREGSCALL stub32_checkpoint, sys_ni_syscall, %r8
+	PTREGSCALL stub32_restart, sys_ni_syscall, %r8
+#endif
 
 ENTRY(ia32_ptregs_common)
 	popq %r11
@@ -841,4 +849,7 @@ ia32_sys_call_table:
 	.quad compat_sys_pwritev
 	.quad compat_sys_rt_tgsigqueueinfo	/* 335 */
 	.quad sys_perf_event_open
+	.quad stub32_eclone
+	.quad stub32_checkpoint
+	.quad stub32_restart
 ia32_syscall_end:
diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index ed8b53c..2416b62 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -455,7 +455,7 @@ int sys_eclone(struct pt_regs *regs)
 	flags_low = regs->bx;
 	uca = (struct clone_args __user *)regs->cx;
 	args_size = regs->dx;
-	pids = (pid_t __user *)regs->di;
+	pids = (pid_t __user *)regs->si;
 
 	return do_eclone_common(regs, flags_low, uca, args_size, pids);
 }
-- 
1.6.0.6
