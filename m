From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/3] ftrace: add ability to only trace swapper tasks
Date: Fri, 05 Dec 2008 08:35:26 -0800
Message-ID: <m1zljapokx.fsf@frodo.ebiederm.org>
References: <20081204052638.425740534@goodmis.org>
	<20081204052735.362609481@goodmis.org>
	<20081204001803.598063f5.akpm@linux-foundation.org>
	<20081204091023.GJ32594@elte.hu> <m1vdu0t7tz.fsf@frodo.ebiederm.org>
	<alpine.DEB.1.10.0812040946060.5240@gandalf.stny.rr.com>
	<m11vwnu10b.fsf@frodo.ebiederm.org>
	<alpine.DEB.1.10.0812041551590.32726@gandalf.stny.rr.com>
	<m1vdtzr4zn.fsf@frodo.ebiederm.org>
	<alpine.DEB.1.10.0812041653270.32726@gandalf.stny.rr.com>
	<m1r64nqd6v.fsf@frodo.ebiederm.org>
	<alpine.DEB.1.10.0812050715570.26316@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755751AbYLEQgm@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0812050715570.26316@gandalf.stny.rr.com> (Steven
	Rostedt's message of "Fri, 5 Dec 2008 07:23:07 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

Steven Rostedt <rostedt@goodmis.org> writes:

> Other pids get allocated per task. In the beginning of copy_process we 
> have:
>
>         if (pid != &init_struct_pid) {
>                 retval = -ENOMEM;
>                 pid = alloc_pid(task_active_pid_ns(p));
>
> Where alloc_pid allocates a pid structure. But this is only done if it is
> not a swapper task.

For PIDTYPE_PID.  For sessions and process groups we don't always allocate them,
and attach_pid is fine.

There is a bit of oddness in the pid freeing case, in using an unhashed pid,
so cpu hotunplug might be a problem.  But you certainly shouldn't be running
into this.

>> > When doing the code you suggested, I end up with only marking the last 
>> > idle task to be created.
>> 
>> Odd. It is all a linked list through the task structures.
>> I'm guessing the initialization isn't quite right.
>> 
>> Weird.  
>
> Do I need to change the loop to do_each_pid_thread?

> I'll try that later today.

I don't think so.  I'm pretty certain we aren't passing the necessary
clone flags to make that case work for idle threads, and in fact we aren't
even cloning from the idle task when we create additional idle threads
so I don't see how do_each_pid_thread could work better.

That said do_each_pid_thread appears to be a proper superset of
do_each_pid_task so it should not be harmful.

I am all for figuring out how to remove this special case if we can.

Eric
