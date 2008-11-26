From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] ftrace: add thread comm to function graph tracer
Date: Wed, 26 Nov 2008 10:04:50 -0800
Message-ID: <20081126100450.24b99063.akpm@linux-foundation.org>
References: <20081126051622.134970943@goodmis.org>
	<20081126051710.149585354@goodmis.org>
	<20081125213748.2cd86b2b.akpm@linux-foundation.org>
	<alpine.DEB.1.10.0811261147250.26743@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754857AbYKZSFc@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0811261147250.26743@gandalf.stny.rr.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

On Wed, 26 Nov 2008 11:48:44 -0500 (EST) Steven Rostedt <rostedt@goodmis.org> wrote:

> 
> On Tue, 25 Nov 2008, Andrew Morton wrote:
> 
> > On Wed, 26 Nov 2008 00:16:26 -0500 Steven Rostedt <rostedt@goodmis.org> wrote:
> > 
> > > From: Steven Rostedt <rostedt@goodmis.org>
> > > 
> > > Impact: enhancement to function graph tracer
> > > 
> > > Export the trace_find_cmdline so the function graph tracer can
> > > use it to print the comms of the threads.
> > > 
> > > -static char *trace_find_cmdline(int pid)
> > > +char *trace_find_cmdline(int pid)
> > >
> > > ...
> > >
> > >  static int verif_pid(struct trace_seq *s, pid_t pid)
> > >  {
> > > +	char *comm;
> > > +
> > >  	if (last_pid != -1 && last_pid == pid)
> > >  		return 1;
> > >  
> > >  	last_pid = pid;
> > > -	return trace_seq_printf(s, "\n------------8<---------- thread %d"
> > > +	comm = trace_find_cmdline(pid);
> > > +
> > > +	return trace_seq_printf(s, "\n------------8<---------- thread %s-%d"
> > >  				    " ------------8<----------\n\n",
> > > -				  pid);
> > > +				    comm, pid);
> > >  }
> > 
> > This code gets its int's and pid_t's all mixed up.  It's a bit cosmetic, but
> > nice to get it right for readability's sake.
> 
> Hmm, I think I would like to keep all pids as ints. Perhaps because we do 
> not have namespaces here ;-)
> 
> I'm totally confused by what to do. I'll have to think about it.

Well.  Any variable which contains a process ID should have type pid_t.

It gets more complicated in places where these values are passed to and
from userspace (including via printk!).  It would be defensive (but
unnecessary) to cast the pid_t's to and from known-size types at the
kernel boundaries.
