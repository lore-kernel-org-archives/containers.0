From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was	Vpid:)
Date: Thu, 16 Jun 2011 08:22:13 -0700
Message-ID: <m1fwn9by3e.fsf@fess.ebiederm.org>
References: <20110615145527.4016.70157.stgit@bahia.local>
	<20110615190302.GA16440@redhat.com>
	<1308223158.8230.66.camel@bahia.local> <4DF9F657.7030605@fr.ibm.com>
	<20110616130613.GC19312@redhat.com> <4DFA126D.9060102@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DFA126D.9060102@fr.ibm.com> (Cedric Le Goater's message of
	"Thu, 16 Jun 2011 16:25:49 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Cedric Le Goater <clg@fr.ibm.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Greg Kurz <gkurz@fr.ibm.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

Cedric Le Goater <clg@fr.ibm.com> writes:

> On 06/16/2011 03:06 PM, Oleg Nesterov wrote:
>> On 06/16, Cedric Le Goater wrote:
>>>
>>> We have a case where a task in a parent pid namespace needs to kill
>>> another task in a sub pid namespace only knowing its internal pid.
>>> the latter has been communicated to the parent task through a file or
>>> a unix socket.
>> 
>> OK, thanks, this partly answers my question... But if they communicate
>> anyway, it is not clear why the signal is needed.
>
> Well, user space always finds ways to challenge the kernel.
>
> Our case is related to HPC. The batch manager runs jobs inside lxc 
> containers (using namespaces) and signals are sent to the application 
> for different reasons. First, to cleanly exit but also for other more 
> specific actions related to the cluster interconnects. 

In that case I really recommend unix domain sockets.  You likely
won't need a kernel upgrade to make use of those and their pid
translation ability.

>>> a new kill syscall could be the solution:
>>>
>>>     int pidns_kill(pid_t init_pid, pid_t some_pid);
>>>
>>> where 'init_pid' identifies the namespace and 'some_pid' identifies
>>> a task in this namespace. this is very specific but why not.
>> 
>> Yes, I also thought about this. Should be trivial.
>> 
>> Or int sys_tell_me_its_pid(pid_t init_pid, pid_t some_pid).
>
> why not. it's even better because more general.

If we get as far as a new system call (and I don't think any of this
needs a new system call) we really should use a namespace file
descriptor to identify the pid namespace not a pid.

>> Just in case.... This is hack, yes, but in fact you do not need the
>> kernel changes to send a signal inside the namespace. You could
>> ptrace sub_init, and execute the necessary code "inside" the namespace.
>
> hmm, I look at that.

Looking at the ptrace interactions are definitely worthwhile.

I remember there were a few very weird things with pids when ptracing
a process in another pid namespace.  It may be that ActivePid is enough
to allow the tracer to figure out the confusing information it is
getting.

I would be surprised if using ptrace to send signals is how you
want to do things.  It works, and it is a great argument from
a security perspective on allowing things that we already allow.
Using ptrace to run system calls was cumbersome and not easily
portable across architectures last time I looked.

Eric
