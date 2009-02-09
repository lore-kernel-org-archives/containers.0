From: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] x86_86 support of checkpoint/restart (Re: Checkpoint
	/ Restart)
Date: Mon, 09 Feb 2009 11:25:23 -0800
Message-ID: <49908323.3090606@google.com>
References: <20090207001609.8168.14884.stgit@lahore.corp.google.com>
	<f4192e520902090953x43a98134hfaa8443d586a32a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <f4192e520902090953x43a98134hfaa8443d586a32a6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jim Winget <winget-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Jim Winget wrote:
> Any way to use a delayed checkpoint signal (perhaps somewhat
> non-deterministic, e.g. "do it now" really means "do it pretty soon") that
> is only taken on return to user space thus allowing a deterministic
> solution?

Ya, I'm thinking that a 'checkpoint' signal would be advisory, with the 
SIG_DFL action performing the checkpoint itself.

Considering that we'd need to cleanly get access to all registers, the 
checkpoint itself needs to be a well defined path from 
userland->kernelland.  I'm wondering if sys_checkpoint could be this 
well-defined path using the PTREGSCALL stub macro.

For tasks that aren't checkpoint-aware, SIG_DFL could possibly be done 
by having the vsyscall page/vdso implement the userland sighandler that 
calls sys_checkpoint.

What this means though is that we won't be able to freeze or SIGSTOP 
tasks before checkpoint.  Both of these paths can be entered via a 
variety of kernel entry points and unless we start dumping the full 
ptregs on each entry point, we'll never be able to reliably get access 
to all registers.

sys_checkpoint itself would have to have it's own method to quiesce all 
the tasks (basically wait for all tasks to enter sys_checkpoint so that 
a multi-task checkpoint is self-consistent).  The nice thing about a 
signal too is that userland can block it and ignore it in a 
deterministic way.  The failure logic for ignored or blocked-for-a-long 
time can be pushed back down to userland.

This is all a dramatic shift from the current way things are done, so 
we'd be best getting a better feel for our options though..

> Jim
> 
> On Fri, Feb 6, 2009 at 4:17 PM, Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> 
>> The patch sent by Masahiko assumes that all the user-space registers are
>> saved on
>> the kernel stack on a system call. This is not true for the majority
>> of the system calls. The callee saved registers (as defined by x86_64
>> ABI) - rbx, rbp, r12, r13, r14, r15 - are saved only in some special
>> cases. That means that these registers would not be available to
>> checkpoint code. Moreover, the restore code would have no space in
>> stack to restore those registers.
>>
>> This patch partially solves that problem, but using a stub around
>> checkpoint/restart system calls. This stub saves/restores those callee
>> saved registers to/from the kernel stack. This solves the problem in
>> the case of self checkpoint and restore.
>>
>> In case of external checkpoint, there is no clean way to have access
>> to these callee saved registers. We freeze or SIGSTOP the process that
>> has to be checkpointed. The process could have entered the kernel
>> space via any arbitrary code path before it was stopped or
>> frozen. Thus the callee saved registers were not saved in pt_regs
>> (i.e. the bottom of the kernel mode stack). They would be saved at
>> some arbitrary place in the kernel mode stack. And when we want to
>> checkpoint that process, we cannot find those registers and save them
>> in the checkpoint.
>>
>> Possible solutions to this external checkpointing problem include
>> saving/restoring all registers (not feasible as it would have
>> performance penalty for every code path), and overloading a signal for
>> achieving external checkpointing. Any ideas?
>> ---
>>
>>  arch/x86/include/asm/unistd_64.h |    4 ++--
>>  arch/x86/kernel/entry_64.S       |   10 ++++++++++
>>  arch/x86/mm/checkpoint.c         |    3 +--
>>  arch/x86/mm/restart.c            |    5 ++---
>>  4 files changed, 15 insertions(+), 7 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/unistd_64.h
>> b/arch/x86/include/asm/unistd_64.h
>> index fe7174d..76aa903 100644
>> --- a/arch/x86/include/asm/unistd_64.h
>> +++ b/arch/x86/include/asm/unistd_64.h
>> @@ -654,9 +654,9 @@ __SYSCALL(__NR_pipe2, sys_pipe2)
>>  #define __NR_inotify_init1                     294
>>  __SYSCALL(__NR_inotify_init1, sys_inotify_init1)
>>  #define __NR_checkpoint                                295
>> -__SYSCALL(__NR_checkpoint, sys_checkpoint)
>> +__SYSCALL(__NR_checkpoint, stub_checkpoint)
>>  #define __NR_restart                           296
>> -__SYSCALL(__NR_restart, sys_restart)
>> +__SYSCALL(__NR_restart, stub_restart)
>>
>>
>>  #ifndef __NO_STUBS
>> diff --git a/arch/x86/kernel/entry_64.S b/arch/x86/kernel/entry_64.S
>> index b86f332..0369267 100644
>> --- a/arch/x86/kernel/entry_64.S
>> +++ b/arch/x86/kernel/entry_64.S
>> @@ -545,6 +545,14 @@ END(system_call)
>>  END(\label)
>>        .endm
>>
>> +       .macro FULLSTACKCALL label,func
>> +       .globl \label
>> +       \label:
>> +       leaq    \func(%rip),%rax
>> +       jmp     ptregscall_common
>> +       END(\label)
>> +       .endm
>> +
>>        CFI_STARTPROC
>>
>>        PTREGSCALL stub_clone, sys_clone, %r8
>> @@ -552,6 +560,8 @@ END(\label)
>>        PTREGSCALL stub_vfork, sys_vfork, %rdi
>>        PTREGSCALL stub_sigaltstack, sys_sigaltstack, %rdx
>>        PTREGSCALL stub_iopl, sys_iopl, %rsi
>> +       FULLSTACKCALL stub_restart, sys_restart
>> +       FULLSTACKCALL stub_checkpoint, sys_checkpoint
>>
>>  ENTRY(ptregscall_common)
>>        popq %r11
>> diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
>> index 2514f14..a26332d 100644
>> --- a/arch/x86/mm/checkpoint.c
>> +++ b/arch/x86/mm/checkpoint.c
>> @@ -75,10 +75,10 @@ static void cr_save_cpu_regs(struct cr_hdr_cpu *hh,
>> struct task_struct *t)
>>        hh->ip = regs->ip;
>>        hh->cs = regs->cs;
>>        hh->flags = regs->flags;
>> +       hh->sp = regs->sp;
>>        hh->ss = regs->ss;
>>
>>  #ifdef CONFIG_X86_64
>> -       hh->sp = read_pda (oldrsp);
>>        hh->r8 = regs->r8;
>>        hh->r9 = regs->r9;
>>        hh->r10 = regs->r10;
>> @@ -90,7 +90,6 @@ static void cr_save_cpu_regs(struct cr_hdr_cpu *hh,
>> struct task_struct *t)
>>        hh->ds = thread->ds;
>>        hh->es = thread->es;
>>  #else /* !CONFIG_X86_64 */
>> -       hh->sp = regs->sp;
>>        hh->ds = regs->ds;
>>        hh->es = regs->es;
>>  #endif /* CONFIG_X86_64 */
>> diff --git a/arch/x86/mm/restart.c b/arch/x86/mm/restart.c
>> index a10d63e..329f938 100644
>> --- a/arch/x86/mm/restart.c
>> +++ b/arch/x86/mm/restart.c
>> @@ -111,15 +111,14 @@ static int cr_load_cpu_regs(struct cr_hdr_cpu *hh,
>> struct task_struct *t)
>>        regs->cs = hh->cs;
>>        regs->flags = hh->flags;
>>        regs->sp = hh->sp;
>> -       write_pda(oldrsp, hh->sp);
>>        regs->ss = hh->ss;
>>
>> -       thread->gs = hh->gs;
>> -       thread->fs = hh->fs;
>>  #ifdef CONFIG_X86_64
>>        do_arch_prctl(t, ARCH_SET_FS, hh->fs);
>>        do_arch_prctl(t, ARCH_SET_GS, hh->gs);
>>  #else
>> +       thread->gs = hh->gs;
>> +       thread->fs = hh->fs;
>>        loadsegment(gs, hh->gs);
>>        loadsegment(fs, hh->fs);
>>  #endif
>>
>>
>> --~--~---------~--~----~------------~-------~--~----~
>> You received this message because you are subscribed to the Google Groups
>> "kernel-live-migration" group.
>> To post to this group, send email to kernel-live-migration-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
>> To unsubscribe from this group, send email to
>> kernel-live-migration+unsubscribe-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org<kernel-live-migration%2Bunsubscribe-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>> For more options, visit this group at
>> http://groups.google.com/a/google.com/group/kernel-live-migration?hl=en
>> -~----------~----~----~----~------~----~------~--~---
>>
>>
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
