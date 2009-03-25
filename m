From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/7] powerpc: provide APIs for validating and updating DABR
Date: Wed, 25 Mar 2009 18:02:43 -0500
Message-ID: <1238022166-13422-5-git-send-email-ntl@pobox.com>
References: <1238022166-13422-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1238022166-13422-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

A checkpointed task image may specify a value for the DABR (Data
Access Breakpoint Register).  The restart code needs to validate this
value before making any changes to the current task.

ptrace_set_debugreg encapsulates the bounds checking and platform
dependencies of programming the DABR.  Split this into "validate"
(debugreg_valid) and "update" (debugreg_update) functions, and make
them available for use outside of the ptrace code.

Also ptrace_set_debugreg has extern linkage, but no users outside of
ptrace.c.  Make it static.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 arch/powerpc/include/asm/ptrace.h |    7 +++
 arch/powerpc/kernel/ptrace.c      |   88 +++++++++++++++++++++++++------------
 2 files changed, 66 insertions(+), 29 deletions(-)

diff --git a/arch/powerpc/include/asm/ptrace.h b/arch/powerpc/include/asm/ptrace.h
index c9c678f..79bc816 100644
--- a/arch/powerpc/include/asm/ptrace.h
+++ b/arch/powerpc/include/asm/ptrace.h
@@ -81,6 +81,8 @@ struct pt_regs {
 
 #ifndef __ASSEMBLY__
 
+#include <linux/types.h>
+
 #define instruction_pointer(regs) ((regs)->nip)
 #define user_stack_pointer(regs) ((regs)->gpr[1])
 #define regs_return_value(regs) ((regs)->gpr[3])
@@ -138,6 +140,11 @@ do {									      \
 extern void user_enable_single_step(struct task_struct *);
 extern void user_disable_single_step(struct task_struct *);
 
+/* for reprogramming DABR/DAC during restart of a checkpointed task */
+extern bool debugreg_valid(unsigned long val, unsigned int index);
+extern void debugreg_update(struct task_struct *task, unsigned long val,
+			    unsigned int index);
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* __KERNEL__ */
diff --git a/arch/powerpc/kernel/ptrace.c b/arch/powerpc/kernel/ptrace.c
index 3635be6..0b6cf84 100644
--- a/arch/powerpc/kernel/ptrace.c
+++ b/arch/powerpc/kernel/ptrace.c
@@ -735,22 +735,25 @@ void user_disable_single_step(struct task_struct *task)
 	clear_tsk_thread_flag(task, TIF_SINGLESTEP);
 }
 
-int ptrace_set_debugreg(struct task_struct *task, unsigned long addr,
-			       unsigned long data)
+/**
+ * debugreg_valid() - validate the value to be written to a debug register
+ * @val:	The prospective contents of the register.
+ * @index:	Must be zero.
+ *
+ * Returns true if @val is an acceptable value for the register indicated by
+ * @index, false otherwise.
+ */
+bool debugreg_valid(unsigned long val, unsigned int index)
 {
-	/* For ppc64 we support one DABR and no IABR's at the moment (ppc64).
-	 *  For embedded processors we support one DAC and no IAC's at the
-	 *  moment.
-	 */
-	if (addr > 0)
-		return -EINVAL;
+	/* We support only one debug register for now */
+	if (index != 0)
+		return false;
 
 	/* The bottom 3 bits in dabr are flags */
-	if ((data & ~0x7UL) >= TASK_SIZE)
-		return -EIO;
+	if ((val & ~0x7UL) >= TASK_SIZE)
+		return false;
 
 #ifndef CONFIG_BOOKE
-
 	/* For processors using DABR (i.e. 970), the bottom 3 bits are flags.
 	 *  It was assumed, on previous implementations, that 3 bits were
 	 *  passed together with the data address, fitting the design of the
@@ -764,47 +767,74 @@ int ptrace_set_debugreg(struct task_struct *task, unsigned long addr,
 	 */
 
 	/* Ensure breakpoint translation bit is set */
-	if (data && !(data & DABR_TRANSLATION))
-		return -EIO;
-
-	/* Move contents to the DABR register */
-	task->thread.dabr = data;
-
-#endif
-#if defined(CONFIG_BOOKE)
-
+	if (val && !(val & DABR_TRANSLATION))
+		return false;
+#else
 	/* As described above, it was assumed 3 bits were passed with the data
 	 *  address, but we will assume only the mode bits will be passed
 	 *  as to not cause alignment restrictions for DAC-based processors.
 	 */
 
+	/* Read or Write bits must be set */
+	if (!(val & 0x3UL))
+		return -EINVAL;
+#endif
+	return true;
+}
+
+/**
+ * debugreg_update() - update a debug register associated with a task
+ * @task:	The task whose register state is to be modified.
+ * @val:	The value to be written to the debug register.
+ * @index:	Specifies the debug register.  Currently unused.
+ *
+ * Set a task's DABR/DAC to @val, which should be validated with
+ * debugreg_valid() beforehand.
+ */
+void debugreg_update(struct task_struct *task, unsigned long val,
+		     unsigned int index)
+{
+#ifndef CONFIG_BOOKE
+	task->thread.dabr = val;
+#else
 	/* DAC's hold the whole address without any mode flags */
-	task->thread.dabr = data & ~0x3UL;
+	task->thread.dabr = val & ~0x3UL;
 
 	if (task->thread.dabr == 0) {
 		task->thread.dbcr0 &= ~(DBSR_DAC1R | DBSR_DAC1W | DBCR0_IDM);
 		task->thread.regs->msr &= ~MSR_DE;
-		return 0;
 	}
 
-	/* Read or Write bits must be set */
-
-	if (!(data & 0x3UL))
-		return -EINVAL;
-
 	/* Set the Internal Debugging flag (IDM bit 1) for the DBCR0
 	   register */
 	task->thread.dbcr0 = DBCR0_IDM;
 
 	/* Check for write and read flags and set DBCR0
 	   accordingly */
-	if (data & 0x1UL)
+	if (val & 0x1UL)
 		task->thread.dbcr0 |= DBSR_DAC1R;
-	if (data & 0x2UL)
+	if (val & 0x2UL)
 		task->thread.dbcr0 |= DBSR_DAC1W;
 
 	task->thread.regs->msr |= MSR_DE;
 #endif
+}
+
+static int ptrace_set_debugreg(struct task_struct *task, unsigned long addr,
+			       unsigned long data)
+{
+	/* For ppc64 we support one DABR and no IABR's at the moment (ppc64).
+	 * For embedded processors we support one DAC and no IAC's at the
+	 * moment.
+	 */
+	if (addr > 0)
+		return -EINVAL;
+
+	if (!debugreg_valid(data, 0))
+		return -EIO;
+
+	debugreg_update(task, data, 0);
+
 	return 0;
 }
 
-- 
1.6.0.6
