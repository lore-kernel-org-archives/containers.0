From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 3/3] ftrace: add ability to only trace swapper tasks
Date: Thu, 4 Dec 2008 15:57:48 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0812041551590.32726@gandalf.stny.rr.com>
References: <20081204052638.425740534@goodmis.org> <20081204052735.362609481@goodmis.org> <20081204001803.598063f5.akpm@linux-foundation.org> <20081204091023.GJ32594@elte.hu> <m1vdu0t7tz.fsf@frodo.ebiederm.org> <alpine.DEB.1.10.0812040946060.5240@gandalf.stny.rr.com>
 <m11vwnu10b.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757996AbYLDU6F@vger.kernel.org>
In-Reply-To: <m11vwnu10b.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org


On Thu, 4 Dec 2008, Eric W. Biederman wrote:
> >> >
> >> >> > +static struct pid * const ftrace_swapper_pid = (struct pid *)1;
> >> >> 
> >> >> eh?
> >> >
> >> > all side-effects of getting rid of the integer based PID namespace and 
> >> > replacing them with struct pid pointers.
> >> 
> >> Thanks for asking Andrew it looks like an unnecessary side effect.
> >
> > Well, it was necessary without hacking fork.c ;-)
> 
> The (struct pid *)1 has always been unnecessary.

Well, I could set it to the &init_struct_pid as you said, but it will not 
change any of the code below it. So it does not matter what 
ftrace_swapper_pid is set to, as long as it is not set to something that 
can be a legitimate pid struct for something not the swapper task.

It will only matter when we fix the fork code.

> 
> As for fork.  It would be nice to remove most of the special cases
> for the idle thread.  At least the counts are significant.  The rest
> is pretty much a don't care at this point.

Well, the swapper task should still have a pid of zero. That is probably 
important.

-- Steve
