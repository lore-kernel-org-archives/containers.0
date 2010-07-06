From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 11/11][v15]: Document sys_eclone
Date: Tue, 06 Jul 2010 11:12:10 -0400
Message-ID: <4C3347CA.8060703@cs.columbia.edu>
References: <1278189164-28408-1-git-send-email-sukadev@linux.vnet.ibm.com>	<1278189164-28408-12-git-send-email-sukadev@linux.vnet.ibm.com>	<AANLkTinM1jqG-9Mgbzft8bALGri7ZpzU9ZcPbMTe4fvW@mail.gmail.com>	<20100704233951.GK3338@count0.beaverton.ibm.com>	<4C315D2D.6000107@cs.columbia.edu>
	<AANLkTinr_2u-_0S2UvMDc7hOE_JOVIOjGtVo9Tzuk21E@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTinr_2u-_0S2UvMDc7hOE_JOVIOjGtVo9Tzuk21E-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Albert Cahalan <acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Albert Cahalan wrote:
> On Mon, Jul 5, 2010 at 12:18 AM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:
>> Matt Helsley wrote:
>>> On Sat, Jul 03, 2010 at 07:41:30PM -0400, Albert Cahalan wrote:
>>>> On Sat, Jul 3, 2010 at 4:32 PM, Sukadev Bhattiprolu
>>>> <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> 
>> It follows that trying to set pid's in pid-namespaces _below_ you
>> simply doesn't make sense (beyond the CLONE_NEWPID case).
> 
> I may have some wrong ideas about how process restart works,
> but I'd thought it would normally be done from above or from PID 1
> in the same pid namespace.
> 
>> Finally, there have been objections before to allow pid-selection
>> by non-privileged process.
> 
> Eh, I dearly hope that privileged processes are generally not
> even addressable (never mind creatable or accessable) from
> inside anything other than the top-level pid namespace.
> 
> Well, at least nothing should get more privilege than PID 1.
> This would include having UID values that PID 1 can switch
> to and having capability sets that PID 1 can switch to, and
> any other (SE Linux, AppArmor, etc.) things too.
> 
> Restarting a privileged process with a less privileged PID 1
> should result in privilege loss, and ought to require some sort of
> "--force" option to ensure the person accepts possible breakage.
> 
>>>>> +static int do_clone(int (*child_fn)(void *), void *child_arg,
>>>>> +               unsigned int flags_low, int nr_pids, pid_t *pids_list)
>>>> There needs to be a way to pass child_fn and child_arg
>>>> via the kernel. Besides being required for kernel-managed
>>>> stacks, it's normally a saner interface. Stack setup would
>>>> be much like the stack setup for signal handlers. Imagine
>>> I'm inclined to say this is a bad idea.
>>>
>>> I didn't think we had "kernel-managed stacks" in mainline. The most we
>>> have, to my knowledge, is the sigaltstack support and kernel threads.
>>>
>>> I don't see how being able to pass in child_fn and child_arg to the
>>> kernel improves the sanity of the interface. If anything it will make
>>> eclone even more exotic -- now at the end of the syscall we'll
>>> need to mess with the registers/stack of the child much like when we're
>>> invoking a signal handler. That just adds more arch-specific code than is
>>> necessary.
>>>
>>> Userspace wrappers are perfectly capable of invoking the child function
>>> and passing the arguments. Furthermore, passing those arguments requires
>>> expanding the argument structure or putting even greater pressure on
>>> registers (which, as you pointed out below, is an issue for vfork).
> 
> BSD's rfork_thread has, among other things, these two arguments:
> 
> int (*func)(void *arg)
> void *arg
> 
>>>> using this for a vfork-like interface that didn't have painful
>>>> interactions with the compiler.
>> Pardon my ignorance - what sort of painful interactions ?
> 
> The child returns from vfork, via the same return address that
> the parent will later use. (on the stack for many architectures)
> The child then calls a function which might not have the same
> stack layout as vfork, scrambling whatever may be on the stack
> that the parent will be using to return from vfork. The parent may
> then end up using a return address that has been corrupted.
> To make this work, gcc actually recognizes vfork and has
> special handling for it.

I assumed that this is taken care of by libc rather than the
compiler, like it is done for clone(2).

Oren.
