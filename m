From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] cr: remap vdso at original address
Date: Wed, 25 Mar 2009 09:31:16 -0500
Message-ID: <20090325143116.GA14040@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Well, here is my current attempt at properly handling vdso for
the x86 and s390 c/r code.  I was going to test with gettimeofday,
but x86 doesn't use vdso for that, and I'm still recompiling glibc
on s390 to exploit vdso for it.  So what I can tell so far is that
CONFIG_COMPAT_VDSO=n is now save on x86 - the kernel vdso segment
is re-mapped from the kernel into the checkpointed location, so
the fact that the task was started with a random vdso base doesn't
matter.

Once I get a proper testcase, I intend to show that checkpointing
a testcase which does gettimeofday(), waiting 10 seconds, and
then restarting it, will end up with bad __vdso_gettimeofday()
results without this patch, and good ones with it.

-serge

From f79593f4b17bef93b067584c6222fa9e510ab5a7 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 24 Mar 2009 15:07:40 -0400
Subject: [PATCH 1/1] cr: remap vdso at original address

Remap the vdso at the original address in the case of sys_restart.

sys_checkpoint does not save away the vdso vma.  This is done
in the arch-independent code

sys_restart uses arch_setup_additional_pages() to request mapping
vdso at the original (checkpointed) location.  This is being
done in the arch-dependent code.

arch_setup_additional_pages() no longer takes the bprm argument,
which was not used.  Instead it takes a unsigned long reqaddr,
which is a requested address.  If 0, then we assume the usual
calculation for vdso base is performed.  Otherwise, we ask for
the vdso to be installed at the original location (reqaddr), and
return -EINVAL if that was not possible.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/powerpc/include/asm/elf.h     |    3 +--
 arch/powerpc/kernel/vdso.c         |    8 +++++++-
 arch/s390/include/asm/elf.h        |    2 +-
 arch/s390/kernel/vdso.c            |    8 +++++++-
 arch/s390/mm/checkpoint.c          |    1 +
 arch/s390/mm/restart.c             |    9 ++++++++-
 arch/sh/include/asm/elf.h          |    3 +--
 arch/sh/kernel/vsyscall/vsyscall.c |    5 ++++-
 arch/x86/include/asm/elf.h         |    5 ++---
 arch/x86/mm/restart.c              |   14 ++++++++++++--
 arch/x86/vdso/vdso32-setup.c       |    8 ++++++--
 arch/x86/vdso/vma.c                |   11 +++++++++--
 checkpoint/ckpt_mem.c              |   10 ++++++++++
 fs/binfmt_elf.c                    |    2 +-
 14 files changed, 70 insertions(+), 19 deletions(-)

diff --git a/arch/powerpc/include/asm/elf.h b/arch/powerpc/include/asm/elf.h
index cd46f02..133e108 100644
--- a/arch/powerpc/include/asm/elf.h
+++ b/arch/powerpc/include/asm/elf.h
@@ -266,8 +266,7 @@ extern int ucache_bsize;
 /* vDSO has arch_setup_additional_pages */
 #define ARCH_HAS_SETUP_ADDITIONAL_PAGES
 struct linux_binprm;
-extern int arch_setup_additional_pages(struct linux_binprm *bprm,
-				       int uses_interp);
+extern int arch_setup_additional_pages(int uses_interp, unsigned long reqaddr);
 #define VDSO_AUX_ENT(a,b) NEW_AUX_ENT(a,b);
 
 #endif /* __KERNEL__ */
diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index ad06d5c..e91310c 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -184,7 +184,7 @@ static void dump_vdso_pages(struct vm_area_struct * vma)
  * This is called from binfmt_elf, we create the special vma for the
  * vDSO and insert it into the mm struct tree
  */
-int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
+int arch_setup_additional_pages(int uses_interp, unsigned long reqaddr)
 {
 	struct mm_struct *mm = current->mm;
 	struct page **vdso_pagelist;
@@ -210,6 +210,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	vdso_pages = vdso32_pages;
 	vdso_base = VDSO32_MBASE;
 #endif
+	if (reqaddr)
+		vdso_base = req_addr;
 
 	current->mm->context.vdso_base = 0;
 
@@ -233,6 +235,10 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		rc = vdso_base;
 		goto fail_mmapsem;
 	}
+	if (reqaddr && reqaddr != vdso_base) {
+		rc = -EINVAL;
+		goto fail_mmapsem;
+	}
 
 	/*
 	 * our vma flags don't have VM_WRITE so by default, the process isn't
diff --git a/arch/s390/include/asm/elf.h b/arch/s390/include/asm/elf.h
index 74d0bbb..49aaab8 100644
--- a/arch/s390/include/asm/elf.h
+++ b/arch/s390/include/asm/elf.h
@@ -205,6 +205,6 @@ do {									    \
 struct linux_binprm;
 
 #define ARCH_HAS_SETUP_ADDITIONAL_PAGES 1
-int arch_setup_additional_pages(struct linux_binprm *, int);
+int arch_setup_additional_pages(int, unsigned long);
 
 #endif
diff --git a/arch/s390/kernel/vdso.c b/arch/s390/kernel/vdso.c
index 690e178..e50ac7f 100644
--- a/arch/s390/kernel/vdso.c
+++ b/arch/s390/kernel/vdso.c
@@ -184,7 +184,7 @@ static void vdso_init_cr5(void)
  * This is called from binfmt_elf, we create the special vma for the
  * vDSO and insert it into the mm struct tree
  */
-int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
+int arch_setup_additional_pages(int uses_interp, unsigned long reqaddr)
 {
 	struct mm_struct *mm = current->mm;
 	struct page **vdso_pagelist;
@@ -214,6 +214,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	vdso_pagelist = vdso32_pagelist;
 	vdso_pages = vdso32_pages;
 #endif
+	if (reqaddr)
+		vdso_base = reqaddr;
 
 	/*
 	 * vDSO has a problem and was disabled, just don't "enable" it for
@@ -236,6 +238,10 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		rc = vdso_base;
 		goto out_up;
 	}
+	if (reqaddr && vdso_base != reqaddr) {
+		rc = -EINVAL;
+		goto out_up;
+	}
 
 	/*
 	 * our vma flags don't have VM_WRITE so by default, the process
diff --git a/arch/s390/mm/checkpoint.c b/arch/s390/mm/checkpoint.c
index c4e3719..1c79418 100644
--- a/arch/s390/mm/checkpoint.c
+++ b/arch/s390/mm/checkpoint.c
@@ -63,6 +63,7 @@ void cr_s390_mm(int op, struct cr_hdr_mm_context *hh, struct mm_struct *mm)
 	CR_COPY(op, hh->alloc_pgste, mm->context.alloc_pgste);
 	CR_COPY(op, hh->asce_bits, mm->context.asce_bits);
 	CR_COPY(op, hh->asce_limit, mm->context.asce_limit);
+	CR_COPY(op, hh->vdso_base, mm->context.vdso_base);
 }
 
 int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
diff --git a/arch/s390/mm/restart.c b/arch/s390/mm/restart.c
index 6892a2a..401f862 100644
--- a/arch/s390/mm/restart.c
+++ b/arch/s390/mm/restart.c
@@ -13,6 +13,7 @@
 #include <linux/kernel.h>
 #include <asm/system.h>
 #include <asm/pgtable.h>
+#include <asm/elf.h>
 
 #include "checkpoint_s390.h"
 
@@ -71,7 +72,13 @@ int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
 	}
 
 	cr_s390_mm(CR_RST, hh, mm);
-	ret = 0;
+	if (mm->context.vdso_base) {
+		ret = arch_setup_additional_pages(1, mm->context.vdso_base);
+		printk(KERN_NOTICE "%s: resetting vdso to %lx ret %d\n",
+				__func__, mm->context.vdso_base, ret);
+	}
+	else
+		ret = 0;
  out:
 	cr_hbuf_put(ctx, sizeof(*hh));
 	return ret;
diff --git a/arch/sh/include/asm/elf.h b/arch/sh/include/asm/elf.h
index ccb1d93..de173dc 100644
--- a/arch/sh/include/asm/elf.h
+++ b/arch/sh/include/asm/elf.h
@@ -201,8 +201,7 @@ do {									\
 /* vDSO has arch_setup_additional_pages */
 #define ARCH_HAS_SETUP_ADDITIONAL_PAGES
 struct linux_binprm;
-extern int arch_setup_additional_pages(struct linux_binprm *bprm,
-				       int uses_interp);
+extern int arch_setup_additional_pages(int uses_interp, unsigned long reqaddr);
 
 extern unsigned int vdso_enabled;
 extern void __kernel_vsyscall;
diff --git a/arch/sh/kernel/vsyscall/vsyscall.c b/arch/sh/kernel/vsyscall/vsyscall.c
index 3f7e415..232b415 100644
--- a/arch/sh/kernel/vsyscall/vsyscall.c
+++ b/arch/sh/kernel/vsyscall/vsyscall.c
@@ -59,12 +59,15 @@ int __init vsyscall_init(void)
 }
 
 /* Setup a VMA at program startup for the vsyscall page */
-int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
+int arch_setup_additional_pages(int uses_interp, unsigned long reqaddr)
 {
 	struct mm_struct *mm = current->mm;
 	unsigned long addr;
 	int ret;
 
+	if (reqaddr) /* no restart support for sh yet */
+		return -EINVAL;
+
 	down_write(&mm->mmap_sem);
 	addr = get_unmapped_area(NULL, 0, PAGE_SIZE, 0, 0);
 	if (IS_ERR_VALUE(addr)) {
diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index f51a3dd..cb16bf6 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -324,10 +324,9 @@ do {									\
 struct linux_binprm;
 
 #define ARCH_HAS_SETUP_ADDITIONAL_PAGES 1
-extern int arch_setup_additional_pages(struct linux_binprm *bprm,
-				       int uses_interp);
+extern int arch_setup_additional_pages( int uses_interp, unsigned long reqaddr);
 
-extern int syscall32_setup_pages(struct linux_binprm *, int exstack);
+extern int syscall32_setup_pages(int exstack, unsigned long reqaddr);
 #define compat_arch_setup_additional_pages	syscall32_setup_pages
 
 extern unsigned long arch_randomize_brk(struct mm_struct *mm);
diff --git a/arch/x86/mm/restart.c b/arch/x86/mm/restart.c
index c76d2b2..f5eedf6 100644
--- a/arch/x86/mm/restart.c
+++ b/arch/x86/mm/restart.c
@@ -14,6 +14,8 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
+#include <asm/elf.h>
+
 /* read the thread_struct into the current task */
 int cr_read_thread(struct cr_ctx *ctx)
 {
@@ -240,8 +242,16 @@ int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
 		 hh->nldt, (unsigned long) hh->vdso, mm->context.vdso);
 
 	ret = -EINVAL;
-	if (hh->vdso != (unsigned long) mm->context.vdso)
-		goto out;
+	printk(KERN_NOTICE "%s: setting vdso from %p to %lx\n",
+		__func__, mm->context.vdso, (unsigned long)hh->vdso);
+	mm->context.vdso = (void *) hh->vdso;
+	if (hh->vdso) {
+		ret = arch_setup_additional_pages(1, hh->vdso);
+		printk(KERN_NOTICE "%s: setting vdso to %p, ret %d\n",
+			__func__, mm->context.vdso, ret);
+		if (ret)
+			goto out;
+	}
 	if (hh->ldt_entry_size != LDT_ENTRY_SIZE)
 		goto out;
 
diff --git a/arch/x86/vdso/vdso32-setup.c b/arch/x86/vdso/vdso32-setup.c
index 1241f11..7d4e99b 100644
--- a/arch/x86/vdso/vdso32-setup.c
+++ b/arch/x86/vdso/vdso32-setup.c
@@ -310,7 +310,7 @@ int __init sysenter_setup(void)
 }
 
 /* Setup a VMA at program startup for the vsyscall page */
-int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
+int arch_setup_additional_pages(int uses_interp, unsigned long reqaddr)
 {
 	struct mm_struct *mm = current->mm;
 	unsigned long addr;
@@ -331,11 +331,15 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	if (compat)
 		addr = VDSO_HIGH_BASE;
 	else {
-		addr = get_unmapped_area(NULL, 0, PAGE_SIZE, 0, 0);
+		addr = get_unmapped_area(NULL, reqaddr, PAGE_SIZE, 0, 0);
 		if (IS_ERR_VALUE(addr)) {
 			ret = addr;
 			goto up_fail;
 		}
+		if (reqaddr && addr != reqaddr) {
+			ret = -EINVAL;
+			goto up_fail;
+		}
 	}
 
 	if (compat_uses_vma || !compat) {
diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
index 9c98cc6..098b077 100644
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -98,7 +98,7 @@ static unsigned long vdso_addr(unsigned long start, unsigned len)
 
 /* Setup a VMA at program startup for the vsyscall page.
    Not called for compat tasks */
-int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
+int arch_setup_additional_pages(int uses_interp, unsigned long reqaddr)
 {
 	struct mm_struct *mm = current->mm;
 	unsigned long addr;
@@ -108,12 +108,19 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		return 0;
 
 	down_write(&mm->mmap_sem);
-	addr = vdso_addr(mm->start_stack, vdso_size);
+	if (reqaddr)
+		addr = reqaddr;
+	else
+		addr = vdso_addr(mm->start_stack, vdso_size);
 	addr = get_unmapped_area(NULL, addr, vdso_size, 0, 0);
 	if (IS_ERR_VALUE(addr)) {
 		ret = addr;
 		goto up_fail;
 	}
+	if (reqaddr && addr != reqaddr) {
+		ret = -EINVAL;
+		goto up_fail;
+	}
 
 	ret = install_special_mapping(mm, addr, vdso_size,
 				      VM_READ|VM_EXEC|
diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
index b1b50b5..e58b348 100644
--- a/checkpoint/ckpt_mem.c
+++ b/checkpoint/ckpt_mem.c
@@ -741,6 +741,13 @@ int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
 
 	hh->map_count = mm->map_count;
 
+	/* there's got to be a better way to do this */
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		const char *name = arch_vma_name(vma);
+		if (name && strcmp(name, "[vdso]")==0)
+			hh->map_count--;
+	}
+
 	/* FIX: need also mm->flags */
 
 	ret = cr_write_obj(ctx, &h, hh);
@@ -750,6 +757,9 @@ int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
 
 	/* write the vma's */
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		const char *name = arch_vma_name(vma);
+		if (name && strcmp(name, "[vdso]")==0)
+			continue;
 		ret = cr_write_vma(ctx, vma);
 		if (ret < 0)
 			goto out;
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 33b7235..02168b5 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -961,7 +961,7 @@ static int load_elf_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 	set_binfmt(&elf_format);
 
 #ifdef ARCH_HAS_SETUP_ADDITIONAL_PAGES
-	retval = arch_setup_additional_pages(bprm, !!elf_interpreter);
+	retval = arch_setup_additional_pages(!!elf_interpreter, 0);
 	if (retval < 0) {
 		send_sig(SIGKILL, current, 0);
 		goto out;
-- 
1.6.1
