From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was Vpid:)
Date: Thu, 16 Jun 2011 08:07:17 -0700
Message-ID: <m1y611bysa.fsf@fess.ebiederm.org>
References: <20110615145527.4016.70157.stgit@bahia.local>
	<20110615190302.GA16440@redhat.com>
	<1308223158.8230.66.camel@bahia.local> <4DF9F657.7030605@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DF9F657.7030605@fr.ibm.com> (Cedric Le Goater's message of
	"Thu, 16 Jun 2011 14:25:59 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Cedric Le Goater <clg@fr.ibm.com>
Cc: Greg Kurz <gkurz@fr.ibm.com>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

Cedric Le Goater <clg@fr.ibm.com> writes:

> On 06/16/2011 01:19 PM, Greg Kurz wrote:
>> On Wed, 2011-06-15 at 21:03 +0200, Oleg Nesterov wrote:
>>> Forgot to ask,
>>>
>>> On 06/15, Greg Kurz wrote:
>>>>
>>>> The need arises in the LXC community when one wants to send a signal from
>>>> the host (aka. init_pid_ns context) to a container process for which one
>>>> only knows the pid inside the container.
>>>
>>> I am just curious, why do you need this?
>>>
>> 
>> Because some LXC users run partially isolated containers (AKA.
>> application containers started with the lxc-execute command). Some of
>> the user code runs outside the container and some inside. Since
>> lxc-execute uses CLONE_NEWPID, it's difficult for the external code to
>> relate a pid generated inside the container with a task. There are
>> regular requests on lxc-users@ about this.
>
> It's simply not possible. There's no support for it.
>
> We have a case where a task in a parent pid namespace needs to kill 
> another task in a sub pid namespace only knowing its internal pid.
> the latter has been communicated to the parent task through a file or 
> a unix socket.

If you are using a unix domain sockets you can get them to translate
the pid for you, with SCM_CREDS.  Unix domain sockets have to do that
or it is a security problem.

> This 'ActivePid' information in /proc is not sufficient to identity 
> the task, you also need the list of the tasks which are living in 
> the pid namespace.
>
>
> We could have used the setns syscall and attach a kill command to 
> a pid namespace. But, this is borderline as you might ended up 
> killing all the tasks in the namespace you've attached to. Anyhow, 
> setns doesn't support pid namespaces yet and it feels safer to send 
> the signal for outside.
>
> a new kill syscall could be the solution:
>
>     int pidns_kill(pid_t init_pid, pid_t some_pid);
>
> where 'init_pid' identifies the namespace and 'some_pid' identifies
> a task in this namespace. this is very specific but why not.

Ugh.  

So I took a quick look at things and while setns support is tricky
from a technical perspective for pid namespaces, supporting the
namespace files is not.

We can plan on having pid, mnt, and user namespace namespace proc files
in 3.1.  Along with the small changes needed to have inode numbers on
the namespace files that are useful for comparing namespaces for
equality.   I will see about getting those patches out for review
shortly.

> Finally, we thought that the 'ActivePid' information was interesting 
> enough to be exposed in /proc and was solving the case we're facing 
> rather easily with some framework (cgroups) in user space.

The pid number by which a process knows itself doesn't seem
unreasonable.  I'm not totally 

After having a second look at the code in proc we already have
a reference to the struct pid we want to print.  So simply
printing
pid->numbers[pid->level].nr
seems reasonable, and race free.

Alternatively that could be written.
pid_nr_ns(pid, ns_of_pid(pid));

Eric
