From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 2/2] cr: s390: fill in the read/write routines
Date: Wed, 14 Jan 2009 23:06:16 -0600
Message-ID: <20090115050616.GB10517@us.ibm.com>
References: <20090115050523.GA10415@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090115050523.GA10415-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
List-Id: containers.vger.kernel.org

This gets a simple checkpoint/restart working on an s390x.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/include/asm/checkpoint_hdr.h |   35 +++++++++-
 arch/s390/mm/checkpoint.c              |  110 +++++++++++++++++++++++++++++---
 2 files changed, 132 insertions(+), 13 deletions(-)

diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
index 81ca76f..2be5ced 100644
--- a/arch/s390/include/asm/checkpoint_hdr.h
+++ b/arch/s390/include/asm/checkpoint_hdr.h
@@ -34,19 +34,46 @@
 #endif
 
 struct cr_hdr_head_arch {
-	__u16 unimplemented;
+	__u64 unimplemented;
 };
 
 struct cr_hdr_thread {
-	__s16 unimplemented;
+	/* restart blocks */
+	__u64 unimplemented;
 };
 
+/*
+ * Notes
+ * NUM_GPRS defined in <asm/ptrace.h> to be 16
+ * NUM_FPRS defined in <asm/ptrace.h> to be 16
+ * NUM_APRS defined in <asm/ptrace.h> to be 16
+ */
 struct cr_hdr_cpu {
-	__u64 unimplemented;
+	psw_t psw;
+	unsigned long args[1];
+	s390_fp_regs fp_regs;
+	unsigned long gprs[NUM_GPRS];
+	unsigned long orig_gpr2;
+	unsigned short svcnr;
+	unsigned short ilc;
+	unsigned int acrs[NUM_ACRS];
+	unsigned long ksp;
+	unsigned long prot_addr;
+	unsigned int trap_no;
+	per_struct per_info;
+	unsigned long ieee_instruction_pointer;
+	unsigned long pfault_wait;
 };
 
 struct cr_hdr_mm_context {
-	__s16 unimplemented;
+#if 0
+	unsigned long asce_bits;
+	unsigned long asce_limit;
+	int noexec;
+	int has_pgste;
+	int alloc_pgste;
+#endif
+	unsigned long vdso_base;
 };
 
 #endif /* __ASM_S390_CKPT_HDR__H */
diff --git a/arch/s390/mm/checkpoint.c b/arch/s390/mm/checkpoint.c
index 7f7e0b1..b2d7841 100644
--- a/arch/s390/mm/checkpoint.c
+++ b/arch/s390/mm/checkpoint.c
@@ -35,6 +35,29 @@ int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
+static void cr_save_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
+
+	memcpy(&hh->psw, &regs->psw, sizeof(psw_t));
+	hh->args[0] = regs->args[0];
+	hh->svcnr = regs->svcnr;
+	hh->ilc = regs->ilc;
+	memcpy(hh->gprs, regs->gprs, NUM_GPRS*sizeof(unsigned long));
+	hh->orig_gpr2 = regs->orig_gpr2;
+
+	memcpy(&hh->fp_regs, &thread->fp_regs, sizeof(s390_fp_regs));
+	memcpy(hh->acrs, thread->acrs, NUM_ACRS * sizeof(unsigned int));
+	hh->ksp = thread->ksp;
+	printk(KERN_NOTICE "%s: saving ksp as %lx\n", __func__, hh->ksp);
+	hh->prot_addr = thread->prot_addr;
+	hh->trap_no = thread->trap_no;
+	memcpy(&hh->per_info, &thread->per_info, sizeof(per_struct));
+	hh->ieee_instruction_pointer = thread->ieee_instruction_pointer;
+	hh->pfault_wait = thread->pfault_wait;
+}
+
 /* dump the cpu state and registers of a given task */
 int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
 {
@@ -46,7 +69,7 @@ int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
 	h.len = sizeof(*hh);
 	h.parent = task_pid_vnr(t);
 
-	hh->unimplemented = 0xdeadbeef;
+	cr_save_cpu_regs(hh, t);
 
 	ret = cr_write_obj(ctx, &h, hh);
 	cr_hbuf_put(ctx, sizeof(*hh));
@@ -87,16 +110,22 @@ int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
 	h.len = sizeof(*hh);
 	h.parent = parent;
 
-	hh->unimplemented = 0xbeef;
+#if 1
+	hh->vdso_base = mm->context.vdso_base;
+#else
+	hh->asce_bits = mm->context.asce_bits;
+	hh->asce_limit = mm->context.asce_limit;
+	hh->noexec = mm->context.noexec;
+	hh->has_pgste = mm->context.has_pgste;
+	hh->alloc_pgste = mm->context.alloc_pgste;
+#endif
 
 	ret = cr_write_obj(ctx, &h, hh);
 	cr_hbuf_put(ctx, sizeof(*hh));
 
-	WARN_ON_ONCE(ret < 0);
 	if (ret < 0)
 		goto out;
 
-	/* FIXME: NFI. */
 	ret = 0;
 out:
 	return ret;
@@ -107,14 +136,64 @@ out:
 /* read the thread_struct into the current task */
 int cr_read_thread(struct cr_ctx *ctx)
 {
-	WARN_ON_ONCE(true);
-	return -ENOSYS;
+	struct cr_hdr_thread *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int parent, ret;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_THREAD);
+	if (parent < 0) {
+		ret = parent;
+		goto out;
+	}
+
+	if (hh->unimplemented != 0xbeef) {
+		printk(KERN_NOTICE "Error: cr file corrupted\n");
+		ret = -EINVAL;
+		goto out;
+	}
+	ret = 0;
+
+out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return 0;
 }
 
 int cr_read_cpu(struct cr_ctx *ctx)
 {
-	WARN_ON_ONCE(true);
-	return -ENOSYS;
+	struct cr_hdr_cpu *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct thread_struct *thread = &current->thread;
+	struct pt_regs *regs = task_pt_regs(current);
+	int parent, ret;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_CPU);
+	if  (parent < 0) {
+		ret = parent;
+		goto out;
+	}
+	ret = 0;
+
+	//memcpy(&regs->psw, &hh->psw, sizeof(psw_t));
+	regs->psw.addr &= ~PSW_ADDR_INSN;
+	regs->psw.addr |= hh->psw.addr & PSW_ADDR_INSN;
+	regs->args[0] = hh->args[0];
+	regs->svcnr = hh->svcnr;
+	regs->ilc = hh->ilc;
+	memcpy(regs->gprs, hh->gprs, NUM_GPRS*sizeof(unsigned long));
+	regs->orig_gpr2 = hh->orig_gpr2;
+
+	memcpy(&thread->fp_regs, &hh->fp_regs, sizeof(s390_fp_regs));
+	memcpy(thread->acrs, hh->acrs, NUM_ACRS * sizeof(unsigned int));
+	printk(KERN_NOTICE "%s: orig task's ksp was %lx\n", __func__, thread->ksp);
+	thread->ksp = hh->ksp;
+	printk(KERN_NOTICE "%s: restoring ksp as %lx\n", __func__, hh->ksp);
+	thread->prot_addr = hh->prot_addr;
+	thread->trap_no = hh->trap_no;
+	memcpy(&thread->per_info, &hh->per_info, sizeof(per_struct));
+	thread->ieee_instruction_pointer = hh->ieee_instruction_pointer;
+	thread->pfault_wait = hh->pfault_wait;
+
+out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
 }
 
 int cr_read_head_arch(struct cr_ctx *ctx)
@@ -128,6 +207,11 @@ int cr_read_head_arch(struct cr_ctx *ctx)
 		goto out;
 	} else if (parent != 0)
 		goto out;
+
+	if (hh->unimplemented != 0xbeef) {
+		printk(KERN_NOTICE "%s: checkpoint file corrupt\n", __func__);
+		ret = -EINVAL;
+	}
 out:
 	cr_hbuf_put(ctx, sizeof(*hh));
 	return ret;
@@ -146,7 +230,15 @@ int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int rparent)
 	if (parent != rparent)
 		goto out;
 
-	WARN_ON_ONCE(hh->unimplemented != (__s16)0xbeef);
+#if 0
+	mm->context.asce_bits = hh->asce_bits;
+	mm->context.asce_limit = hh->asce_limit;
+	mm->context.noexec = hh->noexec;
+	mm->context.has_pgste = hh->has_pgste;
+	mm->context.alloc_pgste = hh->alloc_pgste;
+#endif
+	mm->context.vdso_base = hh->vdso_base;
+	ret = 0;
 out:
 	cr_hbuf_put(ctx, sizeof(*hh));
 	return ret;
-- 
1.6.1
