From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH] x86_86 support of checkpoint/restart (Re: Checkpoint
	/ Restart)
Date: Wed, 18 Mar 2009 02:56:03 -0400
Message-ID: <49C09B03.6040403@cs.columbia.edu>
References: <20090207001609.8168.14884.stgit@lahore.corp.google.com>	
	<1234202558.20090.201.camel@nimitz>	
	<e98e18940902101427i7459a7edke4fdd8404e2ef642@mail.gmail.com>
	<e98e18940902101934o6f93230ag7226da6013afd20@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <e98e18940902101934o6f93230ag7226da6013afd20-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


I was very confued byt he original post; there is no need for a special
signal (handling) for checkpoint.

To checkpoint, we first freeze (or stop) the processes, meaning that
they are kept with empty kernel stack before returning to user-mode.

We then rely on the fact that a process saves everything that it needs
before entering a syscall - so whatever is on the stack when it enters
the kernel must be preserved, the rest can be overwritten. Otherwise,
processes wouldn't survive context switches while in syscalls ...

Oren.

Nauman Rafique wrote:
> Actually looking at the code in entry_64.S again closely, external
> checkpointing should work with my patch too. The callee save registers
> -- rbx, rbp, r12, r13, r14, r15 -- are saved on the kernel stack
> before calling signal handling code (i.e. right before switching from
> kernel to user mode). This signal handling code would be called
> whenever we are trying to checkpoint a process with SIGSTOP or cgroup
> freezer. Thus these registers would be on the kernel stack of
> checkpointed process. And we don't need any user level signal handling
> for external checkpointing to work in x86_64. Sorry for causing
> confusion.
> 
> On Tue, Feb 10, 2009 at 2:27 PM, Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>> On Mon, Feb 9, 2009 at 10:02 AM, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>>> On Fri, 2009-02-06 at 16:17 -0800, Nauman Rafique wrote:
>>>> The patch sent by Masahiko assumes that all the user-space registers
>>>> are saved on
>>>> the kernel stack on a system call. This is not true for the majority
>>>> of the system calls. The callee saved registers (as defined by x86_64
>>>> ABI) - rbx, rbp, r12, r13, r14, r15 - are saved only in some special
>>>> cases. That means that these registers would not be available to
>>>> checkpoint code. Moreover, the restore code would have no space in
>>>> stack to restore those registers.
>>> According to this:
>>>
>>> http://msdn.microsoft.com/en-us/library/6t169e9c(VS.80).aspx
>>>
>>> Those registers all get clobbered on all function calls.  I assume that
>>> userspace also considers them to get clobbered on system calls as
>>> well.
>>>
>>> What are those special cases you are talking about?  Certain special
>>> cases for entering the kernel where we do save those registers?
>> There are the system calls the use the same stub that I have used to
>> save the full stack (and thus all the registers).
>>        sys_clone
>>        sys_fork
>>        sys_vfork
>>        sys_sigaltstack
>>        sys_iopl
>>
>>> Signal handling and ptrace single stepping are two places I would
>>> imagine we have to enter the kernel and preserve those registers.  Is
>>> that why you were suggesting overloading signal delivery?
>>>
>>> Thanks for pointing out the problem, though.  This one will be
>>> interesting. :)
>>>
>>> -- Dave
>>>
>>>
> 
