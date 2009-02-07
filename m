From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] x86_86 support of checkpoint/restart (Re: Checkpoint
	/ Restart)
Date: Fri, 06 Feb 2009 16:17:52 -0800
Message-ID: <20090207001609.8168.14884.stgit@lahore.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: m-takahashi-kvZsz0w9TrB8UrSeD/g0lQ@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org
List-Id: containers.vger.kernel.org

The patch sent by Masahiko assumes that all the user-space registers are saved on
the kernel stack on a system call. This is not true for the majority
of the system calls. The callee saved registers (as defined by x86_64
ABI) - rbx, rbp, r12, r13, r14, r15 - are saved only in some special
cases. That means that these registers would not be available to
checkpoint code. Moreover, the restore code would have no space in
stack to restore those registers.

This patch partially solves that problem, but using a stub around
checkpoint/restart system calls. This stub saves/restores those callee
saved registers to/from the kernel stack. This solves the problem in
the case of self checkpoint and restore.

In case of external checkpoint, there is no clean way to have access
to these callee saved registers. We freeze or SIGSTOP the process that
has to be checkpointed. The process could have entered the kernel
space via any arbitrary code path before it was stopped or
frozen. Thus the callee saved registers were not saved in pt_regs
(i.e. the bottom of the kernel mode stack). They would be saved at
some arbitrary place in the kernel mode stack. And when we want to
checkpoint that process, we cannot find those registers and save them
in the checkpoint.

Possible solutions to this external checkpointing problem include
saving/restoring all registers (not feasible as it would have
performance penalty for every code path), and overloading a signal for
achieving external checkpointing. Any ideas?
---

 arch/x86/include/asm/unistd_64.h |    4 ++--
 arch/x86/kernel/entry_64.S       |   10 ++++++++++
 arch/x86/mm/checkpoint.c         |    3 +--
 arch/x86/mm/restart.c            |    5 ++---
 4 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index fe7174d..76aa903 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -654,9 +654,9 @@ __SYSCALL(__NR_pipe2, sys_pipe2)
 #define __NR_inotify_init1			294
 __SYSCALL(__NR_inotify_init1, sys_inotify_init1)
 #define __NR_checkpoint				295
-__SYSCALL(__NR_checkpoint, sys_checkpoint)
+__SYSCALL(__NR_checkpoint, stub_checkpoint)
 #define __NR_restart				296
-__SYSCALL(__NR_restart, sys_restart)
+__SYSCALL(__NR_restart, stub_restart)
 
 
 #ifndef __NO_STUBS
diff --git a/arch/x86/kernel/entry_64.S b/arch/x86/kernel/entry_64.S
index b86f332..0369267 100644
--- a/arch/x86/kernel/entry_64.S
+++ b/arch/x86/kernel/entry_64.S
@@ -545,6 +545,14 @@ END(system_call)
 END(\label)
 	.endm
 
+	.macro FULLSTACKCALL label,func
+	.globl \label
+	\label:
+	leaq    \func(%rip),%rax
+	jmp     ptregscall_common
+	END(\label)
+	.endm
+	
 	CFI_STARTPROC
 
 	PTREGSCALL stub_clone, sys_clone, %r8
@@ -552,6 +560,8 @@ END(\label)
 	PTREGSCALL stub_vfork, sys_vfork, %rdi
 	PTREGSCALL stub_sigaltstack, sys_sigaltstack, %rdx
 	PTREGSCALL stub_iopl, sys_iopl, %rsi
+	FULLSTACKCALL stub_restart, sys_restart
+	FULLSTACKCALL stub_checkpoint, sys_checkpoint
 
 ENTRY(ptregscall_common)
 	popq %r11
diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index 2514f14..a26332d 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -75,10 +75,10 @@ static void cr_save_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
 	hh->ip = regs->ip;
 	hh->cs = regs->cs;
 	hh->flags = regs->flags;
+	hh->sp = regs->sp;
 	hh->ss = regs->ss;
 
 #ifdef CONFIG_X86_64
-	hh->sp = read_pda (oldrsp);
 	hh->r8 = regs->r8;
 	hh->r9 = regs->r9;
 	hh->r10 = regs->r10;
@@ -90,7 +90,6 @@ static void cr_save_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
 	hh->ds = thread->ds;
 	hh->es = thread->es;
 #else /* !CONFIG_X86_64 */
-	hh->sp = regs->sp;
 	hh->ds = regs->ds;
 	hh->es = regs->es;
 #endif /* CONFIG_X86_64 */
diff --git a/arch/x86/mm/restart.c b/arch/x86/mm/restart.c
index a10d63e..329f938 100644
--- a/arch/x86/mm/restart.c
+++ b/arch/x86/mm/restart.c
@@ -111,15 +111,14 @@ static int cr_load_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
 	regs->cs = hh->cs;
 	regs->flags = hh->flags;
 	regs->sp = hh->sp;
-	write_pda(oldrsp, hh->sp);
 	regs->ss = hh->ss;
 
-	thread->gs = hh->gs;
-	thread->fs = hh->fs;
 #ifdef CONFIG_X86_64
 	do_arch_prctl(t, ARCH_SET_FS, hh->fs);
 	do_arch_prctl(t, ARCH_SET_GS, hh->gs);
 #else
+	thread->gs = hh->gs;
+	thread->fs = hh->fs;
 	loadsegment(gs, hh->gs);
 	loadsegment(fs, hh->fs);
 #endif
