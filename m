From: Dave Hansen <dave@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] ftrace: add function tracing to single thread
Date: Tue, 25 Nov 2008 16:53:59 -0800
Message-ID: <1227660839.12109.52.camel@nimitz>
References: <20081125223421.795046329@goodmis.org>
	 <20081125223456.976670734@goodmis.org>
	 <20081125144221.66eb99ad.akpm@linux-foundation.org>
	 <alpine.DEB.1.10.0811251800130.26424@gandalf.stny.rr.com>
	 <20081125153104.ecdceed4.akpm@linux-foundation.org>
	 <alpine.DEB.1.10.0811251909320.26424@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753075AbYKZAyV@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0811251909320.26424@gandalf.stny.rr.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, containers@lists.osdl.org, fweisbec@gmail.com, Ingo Molnar <mingo@elte.hu>, LKML <linux-kernel@vger.kernel.org>, srostedt@redhat.com, Eric Biederman <ebiederm@xmission.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>
List-Id: containers.vger.kernel.org

On Tue, 2008-11-25 at 19:11 -0500, Steven Rostedt wrote:
> > > > Steven Rostedt <rostedt@goodmis.org> wrote:
> > > > 
> > > > > This patch adds the ability to function trace a single thread.
> > > > > The file:
> > > > > 
> > > > >   /debugfs/tracing/set_ftrace_pid
> > > > > 
> > > > > contains the pid to trace.
> > > > 
> > > > What happens if the same pid exists in two or more pid namespaces?
> > > 
> > > I think we had this discussion before.
> > 
> > Oh.  What did we end up concluding?
> > 
> > > It tests current->pid, would that 
> > > be different among the name spaces?
> > 
> > I think those are non-unique.  containers@lists.osdl.org would have
> > better ideas..
> 
> Added list in CC.
> 
> I think the end result was, if this file can only be changed by root, then 
> we do not need to worry about namespaces. This file is a privileged file 
> that can only be modified by root.
> 
> If someday we decide to let non admin users touch this file, then we would
> need to care about this.  This file may actually be modified in the future 
> by users, so this may become an issue.

This really has very little to do with root vs non-root users.  In fact,
we're working towards having cases where we have many "root" users, even
those inside namespaces.  It is also quite possible for a normal root
user to fork into a new pid namespace.  In that case, root simply won't
be able to use this feature because something like:
	
	echo $$ /debugfs/tracing/set_ftrace_pid
	
just won't work.  Let's look at a bit of the code.

+static void ftrace_pid_func(unsigned long ip, unsigned long parent_ip)
+{
+       if (current->pid != ftrace_pid_trace)
+               return;
+
+       ftrace_pid_function(ip, parent_ip);
+}

One thing this doesn't deal with is pid wraparound.  Does that matter?

If you want to fix this a bit, instead of saving off the pid_t in
ftrace_pid_trace, you should save a 'struct pid'.  You can get the
'struct pid' for a particular task by doing a find_get_pid(pid_t).  You
can then compare that pid_t to current by doing a
pid_task(struct_pid_that_i_saved, PIDTYPE_PID).  That will also protect
against pid wraparound.

The find_get_pid() is handy because it will do the pid_t lookup in the
context of the current task's pid namespace, which is what you want, I
think.

-- Dave
