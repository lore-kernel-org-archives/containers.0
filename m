From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 2/2] c/r: x86-64: checkpoint/restart implementation
Date: Sun,  6 Dec 2009 15:31:09 -0500
Message-ID: <1260131469-2917-4-git-send-email-orenl@cs.columbia.edu>
References: <1260131469-2917-1-git-send-email-orenl@cs.columbia.edu>
	<1260131469-2917-2-git-send-email-orenl@cs.columbia.edu>
	<1260131469-2917-3-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1260131469-2917-3-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Support for checkpoint and restart for X86_32 architecture.
Partly based on Alexey's work.

 Checkpoint          Restart
 (app/arch)         (app/arch)
--------------------------------
  64/x86-64	->  64/x86-64	  works
  32/x86-64	->  32/x86-64	  ?
  32/x86-64	->  32/x86-32	  ?
  32/x86-32	->  32/x86-64	  ?

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 arch/x86/Kconfig                      |    2 +-
 arch/x86/include/asm/checkpoint_hdr.h |    6 +
 arch/x86/include/asm/syscalls.h       |    6 +
 arch/x86/include/asm/unistd_64.h      |    4 +
 arch/x86/kernel/Makefile              |    2 +
 arch/x86/kernel/checkpoint_64.c       |  251 +++++++++++++++++++++++++++++++++
 arch/x86/kernel/entry_64.S            |    5 +
 include/linux/checkpoint_hdr.h        |    2 +
 8 files changed, 277 insertions(+), 1 deletions(-)
 create mode 100644 arch/x86/kernel/checkpoint_64.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 69d6077..f6260f5 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -88,7 +88,7 @@ config HAVE_LATENCYTOP_SUPPORT
 
 config CHECKPOINT_SUPPORT
 	bool
-	default y if X86_32
+	default y
 
 config MMU
 	def_bool y
diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index 65511ca..0033bfe 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -36,6 +36,10 @@
 #include <asm/processor.h>
 #endif
 
+#ifdef CONFIG_X86_64
+#define CKPT_ARCH_ID	CKPT_ARCH_X86_64
+#endif
+
 #ifdef CONFIG_X86_32
 #define CKPT_ARCH_ID	CKPT_ARCH_X86_32
 #endif
@@ -135,6 +139,8 @@ struct ckpt_hdr_cpu {
 #define CKPT_X86_SEG_NULL	0
 #define CKPT_X86_SEG_USER32_CS	1
 #define CKPT_X86_SEG_USER32_DS	2
+#define CKPT_X86_SEG_USER64_CS	3
+#define CKPT_X86_SEG_USER64_DS	4
 #define CKPT_X86_SEG_TLS	0x4000	/* 0100 0000 0000 00xx */
 #define CKPT_X86_SEG_LDT	0x8000	/* 100x xxxx xxxx xxxx */
 
diff --git a/arch/x86/include/asm/syscalls.h b/arch/x86/include/asm/syscalls.h
index 1079447..063cdd0 100644
--- a/arch/x86/include/asm/syscalls.h
+++ b/arch/x86/include/asm/syscalls.h
@@ -88,6 +88,12 @@ asmlinkage long sys_execve(char __user *, char __user * __user *,
 			   struct pt_regs *);
 long sys_arch_prctl(int, unsigned long);
 
+/* kernel/checkpoint_64.c */
+#ifdef CONFIG_CHECKPOINT
+asmlinkage long sys_restart(pid_t pid, int fd, unsigned long flags, int logfd,
+			    struct pt_regs *regs);
+#endif
+
 /* kernel/signal.c */
 asmlinkage long sys_sigaltstack(const stack_t __user *, stack_t __user *,
 				struct pt_regs *);
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index d2ffc89..c360707 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -663,6 +663,10 @@ __SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
 __SYSCALL(__NR_perf_event_open, sys_perf_event_open)
 #define __NR_eclone                   		299
 __SYSCALL(__NR_eclone, stub_eclone)
+#define __NR_checkpoint                   	300
+__SYSCALL(__NR_checkpoint, sys_checkpoint)
+#define __NR_restart                   		301
+__SYSCALL(__NR_restart, stub_restart)
 
 
 #ifndef __NO_STUBS
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 2821fd6..ded0ee2 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -138,4 +138,6 @@ ifeq ($(CONFIG_X86_64),y)
 
 	obj-$(CONFIG_PCI_MMCONFIG)	+= mmconf-fam10h_64.o
 	obj-y				+= vsmp_64.o
+
+	obj-$(CONFIG_CHECKPOINT)	+= checkpoint_64.o
 endif
diff --git a/arch/x86/kernel/checkpoint_64.c b/arch/x86/kernel/checkpoint_64.c
new file mode 100644
index 0000000..3901a53
--- /dev/null
+++ b/arch/x86/kernel/checkpoint_64.c
@@ -0,0 +1,251 @@
+/*
+ *  Checkpoint/restart - architecture specific support for x86_64
+ *
+ *  Copyright (C) 2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
+#include <asm/desc.h>
+#include <asm/i387.h>
+#include <asm/elf.h>
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/*
+ * sys_restart needs to access and modify the pt_regs structure to
+ * restore the original state from the time of the checkpoint.
+ */
+asmlinkage long sys_restart(pid_t pid, int fd, unsigned long flags, int logfd,
+			    struct pt_regs *regs)
+{
+	return do_sys_restart(pid, fd, flags, logfd);
+}
+
+/* helpers to encode/decode/validate segments */
+
+int check_segment(__u16 seg)
+{
+	int ret = 0;
+
+	switch (seg) {
+	case CKPT_X86_SEG_NULL:
+	case CKPT_X86_SEG_USER64_CS:
+	case CKPT_X86_SEG_USER64_DS:
+#ifdef CONFIG_COMPAT
+	case CKPT_X86_SEG_USER32_CS:
+	case CKPT_X86_SEG_USER32_DS:
+#endif
+		return 1;
+	}
+	if (seg & CKPT_X86_SEG_TLS) {
+		seg &= ~CKPT_X86_SEG_TLS;
+		if (seg <= GDT_ENTRY_TLS_MAX - GDT_ENTRY_TLS_MIN)
+			ret = 1;
+	} else if (seg & CKPT_X86_SEG_LDT) {
+		seg &= ~CKPT_X86_SEG_LDT;
+		if (seg <= 0x1fff)
+			ret = 1;
+	}
+	return ret;
+}
+
+__u16 encode_segment(unsigned short seg)
+{
+	if (seg == 0)
+		return CKPT_X86_SEG_NULL;
+	BUG_ON((seg & 3) != 3);
+
+	if (seg == __USER_CS)
+		return CKPT_X86_SEG_USER64_CS;
+	if (seg == __USER_DS)
+		return CKPT_X86_SEG_USER64_DS;
+#ifdef CONFIG_COMPAT
+	if (seg == __USER32_CS)
+		return CKPT_X86_SEG_USER32_CS;
+	if (seg == __USER32_DS)
+		return CKPT_X86_SEG_USER32_DS;
+#endif
+
+	if (seg & 4)
+		return CKPT_X86_SEG_LDT | (seg >> 3);
+
+	seg >>= 3;
+	if (GDT_ENTRY_TLS_MIN <= seg && seg <= GDT_ENTRY_TLS_MAX)
+		return CKPT_X86_SEG_TLS | (seg - GDT_ENTRY_TLS_MIN);
+
+	printk(KERN_ERR "c/r: (decode) bad segment %#hx\n", seg);
+	BUG();
+}
+
+unsigned short decode_segment(__u16 seg)
+{
+	if (seg == CKPT_X86_SEG_NULL)
+		return 0;
+
+	if (seg == CKPT_X86_SEG_USER64_CS)
+		return __USER_CS;
+	if (seg == CKPT_X86_SEG_USER64_DS)
+		return __USER_DS;
+#ifdef CONFIG_COMPAT
+	if (seg == CKPT_X86_SEG_USER32_CS)
+		return __USER32_CS;
+	if (seg == CKPT_X86_SEG_USER32_DS)
+		return __USER32_DS;
+#endif
+
+	if (seg & CKPT_X86_SEG_TLS) {
+		seg &= ~CKPT_X86_SEG_TLS;
+		return ((GDT_ENTRY_TLS_MIN + seg) << 3) | 3;
+	}
+	if (seg & CKPT_X86_SEG_LDT) {
+		seg &= ~CKPT_X86_SEG_LDT;
+		return (seg << 3) | 7;
+	}
+	BUG();
+}
+
+void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct pt_regs *regs = task_pt_regs(t);
+	unsigned long _ds, _es, _fs, _gs;
+
+	h->r15 = regs->r15;
+	h->r14 = regs->r14;
+	h->r13 = regs->r13;
+	h->r12 = regs->r12;
+	h->r11 = regs->r11;
+	h->r10 = regs->r10;
+	h->r9 = regs->r9;
+	h->r8 = regs->r8;
+
+	h->bp = regs->bp;
+	h->bx = regs->bx;
+	h->ax = regs->ax;
+	h->cx = regs->cx;
+	h->dx = regs->dx;
+	h->si = regs->si;
+	h->di = regs->di;
+	h->orig_ax = regs->orig_ax;
+	h->ip = regs->ip;
+
+	h->flags = regs->flags;
+	h->sp = regs->sp;
+
+	/*
+	 * for checkpoint in process context (from within a container)
+	 * DS, ES, FS, GS registers should be saved from the hardware;
+	 * otherwise they are already saved on the thread structure
+	 */
+
+	h->cs = encode_segment(regs->cs);
+	h->ss = encode_segment(regs->ss);
+
+	if (t == current) {
+		savesegment(ds, _ds);
+		savesegment(es, _es);
+		savesegment(fs, _fs);
+		savesegment(gs, _gs);
+	} else {
+		_ds = t->thread.ds;
+		_es = t->thread.es;
+		_fs = t->thread.fsindex;
+		_gs = t->thread.gsindex;
+	}
+	h->ds = encode_segment(_ds);
+	h->es = encode_segment(_es);
+	h->fsindex = encode_segment(_fs);
+	h->gsindex = encode_segment(_gs);
+
+	if (!test_tsk_thread_flag(t, TIF_IA32)) {
+		h->fs = t->thread.fs;
+		h->gs = t->thread.gs;
+	}
+
+	/*
+	 * for checkpoint in process context (from within a container),
+	 * the actual syscall is taking place at this very moment; so
+	 * we (optimistically) subtitute the future return value (0) of
+	 * this syscall into the orig_eax, so that upon restart it will
+	 * succeed (or it will endlessly retry checkpoint...)
+	 */
+	if (t == current) {
+		BUG_ON(h->orig_ax < 0);
+		h->ax = 0;
+	}
+}
+
+int load_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
+{
+	struct thread_struct *thread = &t->thread;
+	struct pt_regs *regs = task_pt_regs(t);
+
+	if (h->cs == CKPT_X86_SEG_NULL)
+		return -EINVAL;
+	if (!check_segment(h->cs) || !check_segment(h->ds) ||
+	    !check_segment(h->es) || !check_segment(h->ss) ||
+	    !check_segment(h->fsindex) || !check_segment(h->gsindex))
+		return -EINVAL;
+
+#ifdef CONFIG_COMPAT
+	if (test_tsk_thread_flag(t, TIF_IA32) &&
+	    (!check_segment(h->fs) || !check_segment(h->gs)))
+		return -EINVAL;
+#endif
+
+	regs->r15 = h->r15;
+	regs->r14 = h->r14;
+	regs->r13 = h->r13;
+	regs->r12 = h->r12;
+	regs->r11 = h->r11;
+	regs->r10 = h->r10;
+	regs->r9 = h->r9;
+	regs->r8 = h->r8;
+
+	regs->bp = h->bp;
+	regs->bx = h->bx;
+	regs->ax = h->ax;
+	regs->cx = h->cx;
+	regs->dx = h->dx;
+	regs->si = h->si;
+	regs->di = h->di;
+	regs->orig_ax = h->orig_ax;
+	regs->ip = h->ip;
+
+	regs->sp = h->sp;
+	thread->usersp = h->sp;
+
+	preempt_disable();
+
+	regs->cs = decode_segment(h->cs);
+	regs->ss = decode_segment(h->ss);
+	thread->ds = decode_segment(h->ds);
+	thread->es = decode_segment(h->es);
+	thread->fsindex = decode_segment(h->fsindex);
+	thread->gsindex = decode_segment(h->gsindex);
+
+#ifdef CONFIG_COMPAT
+	if (!test_tsk_thread_flag(t, TIF_IA32)) {
+		thread->fs = h->fs;
+		thread->gs = h->gs;
+	}
+#endif
+
+	/* XXX - unsure is this really needed ... */
+	loadsegment(fs, thread->fsindex);
+        if (thread->fs)
+		wrmsrl(MSR_FS_BASE, thread->fs);
+	load_gs_index(thread->gsindex);
+        if (thread->gs)
+		wrmsrl(MSR_KERNEL_GS_BASE, thread->gs);
+
+	preempt_enable();
+
+	return 0;
+}
diff --git a/arch/x86/kernel/entry_64.S b/arch/x86/kernel/entry_64.S
index 6d60cd1..e692193 100644
--- a/arch/x86/kernel/entry_64.S
+++ b/arch/x86/kernel/entry_64.S
@@ -699,6 +699,11 @@ END(\label)
 	PTREGSCALL stub_sigaltstack, sys_sigaltstack, %rdx
 	PTREGSCALL stub_iopl, sys_iopl, %rsi
 	PTREGSCALL stub_eclone, sys_eclone, %r8
+#ifdef CONFIG_CHECKPOINT
+	PTREGSCALL stub_restart, sys_restart, %r8
+#else
+	PTREGSCALL stub_restart, sys_ni_syscall, %r8
+#endif
 
 ENTRY(ptregscall_common)
 	DEFAULT_FRAME 1 8	/* offset 8: return address */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 4e57d37..6468fa9 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -195,6 +195,8 @@ enum {
 #define CKPT_ARCH_PPC32 CKPT_ARCH_PPC32
 	CKPT_ARCH_PPC64,
 #define CKPT_ARCH_PPC64 CKPT_ARCH_PPC64
+	CKPT_ARCH_X86_64,
+#define CKPT_ARCH_X86_64 CKPT_ARCH_X86_64
 };
 
 /* shared objrects (objref) */
-- 
1.6.3.3
