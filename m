From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/3] ftrace: add ability to only trace swapper tasks
Date: Thu, 04 Dec 2008 13:43:24 -0800
Message-ID: <m1vdtzr4zn.fsf@frodo.ebiederm.org>
References: <20081204052638.425740534@goodmis.org>
	<20081204052735.362609481@goodmis.org>
	<20081204001803.598063f5.akpm@linux-foundation.org>
	<20081204091023.GJ32594@elte.hu> <m1vdu0t7tz.fsf@frodo.ebiederm.org>
	<alpine.DEB.1.10.0812040946060.5240@gandalf.stny.rr.com>
	<m11vwnu10b.fsf@frodo.ebiederm.org>
	<alpine.DEB.1.10.0812041551590.32726@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757999AbYLDVqf@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0812041551590.32726@gandalf.stny.rr.com> (Steven
	Rostedt's message of "Thu, 4 Dec 2008 15:57:48 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

Steven Rostedt <rostedt@goodmis.org> writes:

> On Thu, 4 Dec 2008, Eric W. Biederman wrote:
>> >> >
>> >> >> > +static struct pid * const ftrace_swapper_pid = (struct pid *)1;
>> >> >> 
>> >> >> eh?
>> >> >
>> >> > all side-effects of getting rid of the integer based PID namespace and 
>> >> > replacing them with struct pid pointers.
>> >> 
>> >> Thanks for asking Andrew it looks like an unnecessary side effect.
>> >
>> > Well, it was necessary without hacking fork.c ;-)
>> 
>> The (struct pid *)1 has always been unnecessary.
>
> Well, I could set it to the &init_struct_pid as you said, but it will not 
> change any of the code below it. So it does not matter what 
> ftrace_swapper_pid is set to, as long as it is not set to something that 
> can be a legitimate pid struct for something not the swapper task.
>
> It will only matter when we fix the fork code.

Well that and if someone dereferences.  

>> As for fork.  It would be nice to remove most of the special cases
>> for the idle thread.  At least the counts are significant.  The rest
>> is pretty much a don't care at this point.
>
> Well, the swapper task should still have a pid of zero. That is probably 
> important.

Right.  I simply meant most of the
if (likely(p->pid)) conditional except for the counts is pretty much a don't
care.  Keeping the idle tasks off of the process list and out of the counts
is useful.

For this particular case what problem did you see with calling attach_pid
with PIDTYPE_PID on init_struct_pid?

Eric
