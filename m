From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 3/3] ftrace: add ability to only trace swapper tasks
Date: Thu, 4 Dec 2008 10:47:27 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0812041045490.19693@gandalf.stny.rr.com>
References: <20081204052638.425740534@goodmis.org> <20081204052735.362609481@goodmis.org> <20081204001803.598063f5.akpm@linux-foundation.org> <20081204091023.GJ32594@elte.hu> <m1vdu0t7tz.fsf@frodo.ebiederm.org> <20081204153626.GB18293@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755062AbYLDPrm@vger.kernel.org>
In-Reply-To: <20081204153626.GB18293@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org


On Thu, 4 Dec 2008, Ingo Molnar wrote:
> > >
> > >> > +static struct pid * const ftrace_swapper_pid = (struct pid *)1;
> > >> 
> > >> eh?
> > >
> > > all side-effects of getting rid of the integer based PID namespace 
> > > and replacing them with struct pid pointers.
> > 
> > Thanks for asking Andrew it looks like an unnecessary side effect.
> 
> Will wait for how the end result looks like ;-)

I'm waiting on a fix for fork.c. I already wrote the code in ftrace when 
the fork code is fixed. It does clean it up nicely. But I do not know all 
the intricacies of the struct pid code to do the fork code correctly.

-- Steve
