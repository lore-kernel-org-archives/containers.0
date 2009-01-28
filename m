From: "Masahiko Takahashi" <m-takahashi-kvZsz0w9TrB8UrSeD/g0lQ@public.gmane.org>
Subject: [RFC][PATCH] x86_86 support of checkpoint/restart (Re: Checkpoint /
	Restart)
Date: Wed, 28 Jan 2009 11:10:35 +0900 (JST)
Message-ID: <090128111035.M0106630@noir.ex.jp.nec.com>
References: <EF0F4DD0-96C2-47CF-A247-19002A3BD53B@uni-duesseldorf.de>
	<20090127155947.GB10039@us.ibm.com>
Reply-To: m-takahashi-kvZsz0w9TrB8UrSeD/g0lQ@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Tue, 27 Jan 2009 09:59:47 -0600".
	<20090127155947.GB10039-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

I'm now working on porting to x86_64 with help from Nauman Rafique.
Here is the preliminary patch. If there is someone who is interested
in x86_64 support, please join.

This patch is to support x86_64 on Oren's checkpoint/restart patchset
(v12 on December 29th). His patchset is well implemented, so the x86_64
patch is only handling architecture specific registers. (Maybe I'm
missing something important...)

I've tested this patch with his test suite (self.c and rstr.c) but I'm
not confident especially in handling segment registers (%fs/%gs).

This patch doesn't support external checkpointing, nor 32bit binary
checkpoint/restart on 64bit Linux.

I would appreciate any comments and feedback.


Thanks,

Masahiko.


In article <20090127155947.GB10039-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:

> Quoting Ralph-Gordon Paul (Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org):
> > Hello,
> >
> > i'm searching for the right Mailing List for Linux checkpoint / restart.
> >
> > I'm working for the XtreemOS Project (http://www.xtreemos.eu). We want
> > to include the linux native checkpoint / restart, but it seems to not
> > work. I tested it with the delivered test applications, but they don't
> > work. The restart application (rstr) throws a segmentation fault. I
> > tried both tests from the documentation, checkpointing self and
> > checkpoint from another process. My Architecture is a Pentium D.
> >
> > Sorry if this is the wrong Mailing List, i couldn't find the right
> > place (forum or mailing list).
> >
> > Thanks for Help,
>
> Hi,
>
> Yup, this is the right list - well either this or lkml.
>
> IIUC you're saying you tested this on a 64-bit x86.  That is
> in fact not yet supported.  With Oren's patchset, you can
> only use x86_32.  (With the patch I sent last week, you could
> also do s390x.)  Support for x86_64 shouldn't take much work -
> I think Dave was going to see about such a port, and Oren
> may have one at the ready, but you could also do it yourself
> if you're so inclined.



Against Oren's patchset v12.

ToDo;
1. support external checkpoint (Nauman Rafique is working now)
2. support 32bit binary checkpoint/restart on 64bit Linux


Signed-off-by: Masahiko Takahashi <m-takahashi-kvZsz0w9TrB8UrSeD/g0lQ@public.gmane.org>
---
 arch/x86/include/asm/unistd_64.h |    4 +++
 arch/x86/mm/checkpoint.c         |   47 ++++++++++++++++++++++++++++++-------
 arch/x86/mm/restart.c            |   29 +++++++++++++++++------
 checkpoint/Kconfig               |    2 +-
 4 files changed, 64 insertions(+), 18 deletions(-)

diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index d2e415e..fe7174d 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -653,6 +653,10 @@ __SYSCALL(__NR_dup3, sys_dup3)
 __SYSCALL(__NR_pipe2, sys_pipe2)
 #define __NR_inotify_init1			294
 __SYSCALL(__NR_inotify_init1, sys_inotify_init1)
+#define __NR_checkpoint				295
+__SYSCALL(__NR_checkpoint, sys_checkpoint)
+#define __NR_restart				296
+__SYSCALL(__NR_restart, sys_restart)
 
 
 #ifndef __NO_STUBS
diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index 50bde9a..28fb08a 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -10,6 +10,7 @@
 
 #include <asm/desc.h>
 #include <asm/i387.h>
+#include <asm/prctl.h>
 
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
@@ -62,12 +63,6 @@ int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
-#ifdef CONFIG_X86_64
-
-#error "CONFIG_X86_64 unsupported yet."
-
-#else	/* !CONFIG_X86_64 */
-
 static void cr_save_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
 {
 	struct thread_struct *thread = &t->thread;
@@ -84,17 +79,52 @@ static void cr_save_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
 	hh->ip = regs->ip;
 	hh->cs = regs->cs;
 	hh->flags = regs->flags;
-	hh->sp = regs->sp;
 	hh->ss = regs->ss;
 
+#ifdef CONFIG_X86_64
+	hh->sp = read_pda (oldrsp);
+	hh->r8 = regs->r8;
+	hh->r9 = regs->r9;
+	hh->r10 = regs->r10;
+	hh->r11 = regs->r11;
+	hh->r12 = regs->r12;
+	hh->r13 = regs->r13;
+	hh->r14 = regs->r14;
+	hh->r15 = regs->r15;
+	hh->ds = thread->ds;
+	hh->es = thread->es;
+#else /* !CONFIG_X86_64 */
+	hh->sp = regs->sp;
 	hh->ds = regs->ds;
 	hh->es = regs->es;
+#endif /* CONFIG_X86_64 */
 
 	/*
 	 * for checkpoint in process context (from within a container)
 	 * the GS and FS registers should be saved from the hardware;
 	 * otherwise they are already sabed on the thread structure
 	 */
+#ifdef CONFIG_X86_64
+	if (thread->fsindex == FS_TLS_SEL)
+		hh->fs = get_desc_base(&thread->tls_array[FS_TLS]);
+	else if (t == current)
+		rdmsrl(MSR_FS_BASE, hh->fs);
+	else
+		hh->fs = thread->fs;
+
+	if (thread->gsindex == GS_TLS_SEL)
+		hh->gs = get_desc_base(&thread->tls_array[GS_TLS]);
+	else if (t == current) {
+		unsigned gsindex;
+
+		savesegment(gs, gsindex);
+		if (gsindex)
+			rdmsrl(MSR_KERNEL_GS_BASE, hh->gs);
+		else
+			hh->gs = thread->gs;
+	} else
+		hh->gs = thread->gs;
+#else /* !CONFIG_X86_64 */
 	if (t == current) {
 		savesegment(gs, hh->gs);
 		savesegment(fs, hh->fs);
@@ -102,6 +132,7 @@ static void cr_save_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
 		hh->gs = thread->gs;
 		hh->fs = thread->fs;
 	}
+#endif /* CONFIG_X86_64 */
 
 	/*
 	 * for checkpoint in process context (from within a container),
@@ -184,8 +215,6 @@ static int cr_write_cpu_fpu(struct cr_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
-#endif	/* CONFIG_X86_64 */
-
 /* dump the cpu state and registers of a given task */
 int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
 {
diff --git a/arch/x86/mm/restart.c b/arch/x86/mm/restart.c
index a682a1d..032ffd1 100644
--- a/arch/x86/mm/restart.c
+++ b/arch/x86/mm/restart.c
@@ -10,6 +10,8 @@
 
 #include <asm/desc.h>
 #include <asm/i387.h>
+#include <asm/prctl.h>
+#include <asm/proto.h>
 
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
@@ -77,12 +79,6 @@ int cr_read_thread(struct cr_ctx *ctx)
 	return ret;
 }
 
-#ifdef CONFIG_X86_64
-
-#error "CONFIG_X86_64 unsupported yet."
-
-#else	/* !CONFIG_X86_64 */
-
 static int cr_load_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
 {
 	struct thread_struct *thread = &t->thread;
@@ -95,19 +91,38 @@ static int cr_load_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
 	regs->di = hh->di;
 	regs->bp = hh->bp;
 	regs->ax = hh->ax;
+#ifdef CONFIG_X86_64
+	regs->r8 = hh->r8;
+	regs->r9 = hh->r9;
+	regs->r10 = hh->r10;
+	regs->r11 = hh->r11;
+	regs->r12 = hh->r12;
+	regs->r13 = hh->r13;
+	regs->r14 = hh->r14;
+	regs->r15 = hh->r15;
+	thread->ds = hh->ds;
+	thread->es = hh->es;
+#else
 	regs->ds = hh->ds;
 	regs->es = hh->es;
+#endif /* CONFIG_X86_64 */
 	regs->orig_ax = hh->orig_ax;
 	regs->ip = hh->ip;
 	regs->cs = hh->cs;
 	regs->flags = hh->flags;
 	regs->sp = hh->sp;
+	write_pda(oldrsp, hh->sp);
 	regs->ss = hh->ss;
 
 	thread->gs = hh->gs;
 	thread->fs = hh->fs;
+#ifdef CONFIG_X86_64
+	do_arch_prctl(t, ARCH_SET_FS, hh->fs);
+	do_arch_prctl(t, ARCH_SET_GS, hh->gs);
+#else
 	loadsegment(gs, hh->gs);
 	loadsegment(fs, hh->fs);
+#endif
 
 	return 0;
 }
@@ -166,8 +181,6 @@ static int cr_read_cpu_fpu(struct cr_ctx *ctx, struct task_struct *t)
 	return 0;
 }
 
-#endif	/* CONFIG_X86_64 */
-
 /* read the cpu state and registers for the current task */
 int cr_read_cpu(struct cr_ctx *ctx)
 {
diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
index ffaa635..bc7f09f 100644
--- a/checkpoint/Kconfig
+++ b/checkpoint/Kconfig
@@ -1,7 +1,7 @@
 config CHECKPOINT_RESTART
 	prompt "Enable checkpoint/restart (EXPERIMENTAL)"
 	def_bool n
-	depends on X86_32 && EXPERIMENTAL
+	depends on X86 && EXPERIMENTAL
 	help
 	  Application checkpoint/restart is the ability to save the
 	  state of a running application so that it can later resume
-- 
1.5.2.5
