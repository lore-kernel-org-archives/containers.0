From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [Devel] [RFC PATCH 0/5] Resend -v2 - Use procfs to change
	a	syscall behavior
Date: Thu, 17 Jul 2008 18:42:56 -0400
Message-ID: <487FCAF0.70607@cs.columbia.edu>
References: <20080708112422.164370000@bull.net>	<20080709221028.GA4926@martell.zuzino.mipt.ru>
	<m1tzeyd0x3.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1tzeyd0x3.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org



Eric W. Biederman wrote:
> Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

I seem to not have received any of Alexey's emails... ?

> 
>> On Tue, Jul 08, 2008 at 01:24:22PM +0200, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org wrote:
>>> # echo "LONG1 XX" > /proc/self/task/<my_tid>/next_syscall_data
>> Same stuff.
>>
>> There is struct task_struct::did_exec , what about it?
>>
>> Also, patches are about de-serializing, how serializing from userspace looks
>> like?
>> You freezed group of processes, then what?
>>
>> How, for example, dump all VMAs correctly?
>> [prepares counter-example]
> 
> Alexey userspace vs a kernel space implementation is the wrong argument.
> 
> It is clearly established that the current user space interfaces are
> insufficient to do the job.  So we need to implement something in the kernel.
> 
> Further I have heard of no one suggesting running a single kernel on multiple
> machines.  Therefore there no one seems to be doing this entirely in the kernel
> and so we need a user space component.

I'm not sure I understand this argument ?

In a kernel implementation, the component will merely open a file descriptor
(to which the data will be streamed), freeze the container and invoke a
system call. In a userland implementation, the component will do most of
the work by continuously probing the kernel for information about the
processes that are being checkpointed.

So, of course we need a "component" - but what does that component do ?

> So the question should not be user space vs. kernel space but can we build clean
> interfaces for checkpoint/restart?  What will those interfaces be?

My question is why build a set of interfaces to export this and that from
the kernel to user space ?  if a kernel implementation (with minimal user
space support) is chosen, then information extraction (and restoration) is
straightforward and we don't get ourselves tied until the end of times to
API exported to userland.

The output of the module will be a binary (like a core dump) that can be
used by the same module to restart. User utilities will be available to
inspect the contents (for whatever reason - like a debugger can inspect a
core dump), and moreover to convert between old and new formats when moving
from older to newer kernels.

By doing so, we avoid many API issues - design, complexity, contents, and
the amount of interfaces to be added.

By doing so, we also gain much in terms of atomicity, possibility to add
optimizations and improve performance, as well as add features as we wish,
without the burden of commitments to userspace.

I think the kernel space vs. user space must be the first issue on our
table to solve, as it has a wide impact on the rest of the work.

Oren.

> 
> Although I think it is good that we are seeing more people play with this as
> that should mean that our pool of people for doing code review on the implementation
> should be reasonable.
> 
> Eric
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
