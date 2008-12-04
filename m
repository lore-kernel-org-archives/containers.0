From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 3/3] ftrace: add ability to only trace swapper tasks
Date: Thu, 4 Dec 2008 09:57:40 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0812040953470.5240@gandalf.stny.rr.com>
References: <20081204052638.425740534@goodmis.org> <20081204052735.362609481@goodmis.org> <m163m0umml.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758277AbYLDO5y@vger.kernel.org>
In-Reply-To: <m163m0umml.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>, Oleg Nesterov <oleg@tv-sign.ru>
List-Id: containers.vger.kernel.org


On Thu, 4 Dec 2008, Eric W. Biederman wrote:

> Steven Rostedt <rostedt@goodmis.org> writes:
> >
> > diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
> > index 10b1d7c..eb57dc1 100644
> > --- a/kernel/trace/ftrace.c
> > +++ b/kernel/trace/ftrace.c
> > @@ -49,6 +49,7 @@ static int last_ftrace_enabled;
> >  
> >  /* set when tracing only a pid */
> >  struct pid *ftrace_pid_trace;
> > +static struct pid * const ftrace_swapper_pid = (struct pid *)1;
> 
> The initializer should be spelled &init_struct_pid instead of (struct pid *)1;
> 
> Except for the special case of finding this unhashed pid, by making the
> attach_pid(p, PIDTYPE_PID, pid) unconditional in copy_process, you can
> make the rest of the special cases go away.

Not that easy. It turns out that all idle tasks share the init_struct_pid, 
and if you add the attach_pid() outside the if statement, you only change 
the owner of the init_struct_pid to the last CPU to come on line.

I tried to allocate the pid, but by doing that it seems that the alloc_pid 
code will assign a number other than 0.  The changes needed to fork.c to 
make this work is quickly going beyond a trivial fix, where I do not want 
to become a pid container developer in order to implement it.

-- Steve
