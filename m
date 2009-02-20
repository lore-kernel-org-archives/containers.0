From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 7/7][v8] SI_USER: Masquerade si_pid when crossing pid ns boundary
Date: Thu, 19 Feb 2009 17:16:03 -0800
Message-ID: <m1zlghrjqk.fsf@fess.ebiederm.org>
References: <20090219030207.GA18783@us.ibm.com>
	<20090219030743.GG18990@us.ibm.com> <m1y6w21k6d.fsf@fess.ebiederm.org>
	<20090219185159.GA374@redhat.com> <m1fxiayss9.fsf@fess.ebiederm.org>
	<20090219223137.GA10378@redhat.com> <m1fxiaxbb5.fsf@fess.ebiederm.org>
	<20090220002851.GA15255@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759389AbZBTBRv@vger.kernel.org>
In-Reply-To: <20090220002851.GA15255@redhat.com> (Oleg Nesterov's message of "Fri\, 20 Feb 2009 01\:28\:51 +0100")
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Andrew Morton <akpm@osdl.org>, roland@redhat.com, daniel@hozac.com, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Oleg Nesterov <oleg@redhat.com> writes:

> On 02/19, Eric W. Biederman wrote:
>>
>> Oleg Nesterov <oleg@redhat.com> writes:
>> 
>> > On 02/19, Eric W. Biederman wrote:
>> >>
>> >> Oleg Nesterov <oleg@redhat.com> writes:
>> >> >
>> >> > SI_FROMUSER() == T, unless we have more (hopefully not) in-kernel
>> >> > users which send SI_FROMUSER() signals, .si_pid must be valid?
>> >>
>> >> So the argument is that while things such as force_sig_info(SIGSEGV)
>> >> don't have a si_pid we don't care because from_ancestor_ns  == 0.
>> >>
>> >> Interesting.  Then I don't know if we have any kernel senders
>> >> that cross the namespace boundaries.
>> >>
>> >> That said I still object to this code.
>> >>
>> >> sys_kill(-pgrp, SIGUSR1)
>> >>   kill_something_info(SIGUSR1, &info, 0)
>> >>     __kill_pgrp_info(SIGUSR1, &info task_pgrp(current))
>> >>       group_send_sig_info(SIGUSR1, &info, tsk)
>> >>         __group_send_sig_info(SIGUSR1, &info, tsk)
>> >>           send_signal(SIGUSR1, &info, tsk, 1)
>> >>             __send_signal(SIGUSR1, &info, tsk, 1)
>> >>
>> >>
>> >> Process groups and sessions can have processes in multiple pid
>> >> namespaces, which is very useful for not messing up your controlling
>> >> terminal.
>> >>
>> >> In which case sys_kill cannot possibly set the si_pid value correct
>> >> and from_ancestor_ns is not enough either.
>> >
>> > (I know, I shouldn't reply today because I am already sleeping ;)
>> >
>> > Why? send_signal() should calculate the correct value of
>> > from_parent and pass it to __send_signal(). If it is true, then
>> > we clear .si_pid in the copied siginfo (which was already queued).
>> > We don't mangle the original siginfo.
>> >
>> > This happens for each process we send the signal.
>> >
>> > Or I misunderstood you?
>>
>> Suppose I have 3 processes in a process group in three separate pid
>> namespaces.
>>
>> Looking from the init pid namespace I have:
>>      pid pgrp ppid
>>       10 10    1
>>       11 10    10
>>       12 10    11
>>
>> Looking from the pid namespace of pid 11 I have:
>>      pid pgrp ppid
>>       0  0     0
>>       1  0     0
>>       2  0     1
>>
>> Looking from the pid namespace of pid 12 I have:
>>      pid pgrp ppid
>>       0  0     0
>>       0  0     0
>>       1  0     0
>>
>> So if the process with pid 12 in the initial pid namespace
>> sends to process group 0.
>
> But this is the different problem, it is not that we clear si_pid while
> we shouldn't, just the .si_pid passed from kill_something_info() is not
> right.
>
> Personally, I think we should not allow to send signals outside our
> namespace (except SIGCHLD on exit), this looks just wrong to me. And
> some time ago copy_process(CLONE_PID) did "setsid".

There are cases that happen, and it very much simplifies dealing with
tty's if we allow it.

Another case where we can send signals between namespaces is posix
message queues.  Implemented in ipc/mqueue.c.  In that case because it
is a unicast message we are generating the proper si_pid when we
generate the signal.

When programmers get lazy it is all to easy to have signals that are
useful and cross namespace boundaries.  In practice it is possible to
close those holes if don't want the confusion in your userspace
programs.  For the people who take advantage of the flexibility of
namespace to mix things together I don't think we can get away in the
kernel assuming weird things won't happen.

> Hmm... that was changed by your commit 5cd17569fd0eeca510735e63a6061291e3971bf6.
> And while I agree with this commit, I think that cinit should do sys_setsid()
> itself to detach itself from the parent namespace.

In general that should indeed happen.  There are specific cases where it is
advantageous not to call setsid().  It is all under control of the creator
of the pid namespace.

> Or. We can fix the case you described. We can move "si_pid = task_tgid_vnr()"
> from sys_kill/do_tkill/etc to send_signal(), it can calculate the correct
> .si_pid looking at sender/receiver namespaces.

I think that is where we need to go, to be safe and to be certain
weird things won't sneak up on us.  We already handle half of the logic in
send_signal anyway.  We might as well handle the other half.

Eric
