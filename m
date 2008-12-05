From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/3] ftrace: add ability to only trace swapper tasks
Date: Thu, 04 Dec 2008 23:43:52 -0800
Message-ID: <m1r64nqd6v.fsf@frodo.ebiederm.org>
References: <20081204052638.425740534@goodmis.org>
	<20081204052735.362609481@goodmis.org>
	<20081204001803.598063f5.akpm@linux-foundation.org>
	<20081204091023.GJ32594@elte.hu> <m1vdu0t7tz.fsf@frodo.ebiederm.org>
	<alpine.DEB.1.10.0812040946060.5240@gandalf.stny.rr.com>
	<m11vwnu10b.fsf@frodo.ebiederm.org>
	<alpine.DEB.1.10.0812041551590.32726@gandalf.stny.rr.com>
	<m1vdtzr4zn.fsf@frodo.ebiederm.org>
	<alpine.DEB.1.10.0812041653270.32726@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753461AbYLEHqm@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0812041653270.32726@gandalf.stny.rr.com> (Steven
	Rostedt's message of "Thu, 4 Dec 2008 16:56:28 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

Steven Rostedt <rostedt@goodmis.org> writes:

> On Thu, 4 Dec 2008, Eric W. Biederman wrote:
>> 
>> Right.  I simply meant most of the
>> if (likely(p->pid)) conditional except for the counts is pretty much a don't
>> care.  Keeping the idle tasks off of the process list and out of the counts
>> is useful.
>> 
>> For this particular case what problem did you see with calling attach_pid
>> with PIDTYPE_PID on init_struct_pid?
>
> On boot up, the CPU 0 idle task is attached to init_struct_pid, and not 
> the others. If you do a "attach_pid" on the next idle task that is created, 
> it will become the attched process, bumping off CPU 0's idle task from the 
> init_struct_pid.

It should form a linked list.  For other pid types we don't have a problem.

> When doing the code you suggested, I end up with only marking the last 
> idle task to be created.

Odd. It is all a linked list through the task structures.
I'm guessing the initialization isn't quite right.

Weird.  

Eric
