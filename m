From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/3] ftrace: add function tracing to single thread
Date: Tue, 25 Nov 2008 20:01:34 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0811251956570.26424@gandalf.stny.rr.com>
References: <20081125223421.795046329@goodmis.org>  <20081125223456.976670734@goodmis.org>  <20081125144221.66eb99ad.akpm@linux-foundation.org>  <alpine.DEB.1.10.0811251800130.26424@gandalf.stny.rr.com>  <20081125153104.ecdceed4.akpm@linux-foundation.org>
 <alpine.DEB.1.10.0811251909320.26424@gandalf.stny.rr.com> <1227660839.12109.52.camel@nimitz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753032AbYKZBBs@vger.kernel.org>
In-Reply-To: <1227660839.12109.52.camel@nimitz>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, containers@lists.osdl.org, fweisbec@gmail.com, Ingo Molnar <mingo@elte.hu>, LKML <linux-kernel@vger.kernel.org>, srostedt@redhat.com, Eric Biederman <ebiederm@xmission.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>
List-Id: containers.vger.kernel.org


On Tue, 25 Nov 2008, Dave Hansen wrote:
> > 
> > I think the end result was, if this file can only be changed by root, then 
> > we do not need to worry about namespaces. This file is a privileged file 
> > that can only be modified by root.
> > 
> > If someday we decide to let non admin users touch this file, then we would
> > need to care about this.  This file may actually be modified in the future 
> > by users, so this may become an issue.
> 
> This really has very little to do with root vs non-root users.  In fact,
> we're working towards having cases where we have many "root" users, even
> those inside namespaces.  It is also quite possible for a normal root
> user to fork into a new pid namespace.  In that case, root simply won't
> be able to use this feature because something like:
> 	
> 	echo $$ /debugfs/tracing/set_ftrace_pid
> 	
> just won't work.  Let's look at a bit of the code.
> 
> +static void ftrace_pid_func(unsigned long ip, unsigned long parent_ip)
> +{
> +       if (current->pid != ftrace_pid_trace)
> +               return;
> +
> +       ftrace_pid_function(ip, parent_ip);
> +}
> 
> One thing this doesn't deal with is pid wraparound.  Does that matter?

Should not.  This is just a way to trace a particular process. Currently 
it traces all processes. If we wrap, then we trace the process with the 
new pid. This should not be an issue.

> 
> If you want to fix this a bit, instead of saving off the pid_t in
> ftrace_pid_trace, you should save a 'struct pid'.  You can get the
> 'struct pid' for a particular task by doing a find_get_pid(pid_t).  You
> can then compare that pid_t to current by doing a
> pid_task(struct_pid_that_i_saved, PIDTYPE_PID).  That will also protect
> against pid wraparound.
> 
> The find_get_pid() is handy because it will do the pid_t lookup in the
> context of the current task's pid namespace, which is what you want, I
> think.

Nope, we can not call that in this context. ftrace_pid_func is called 
directly from mcount, without any protection.

struct pid *find_get_pid(pid_t nr)
{
	struct pid *pid;

	rcu_read_lock();
	pid = get_pid(find_vpid(nr));
	rcu_read_unlock();

	return pid;
}
EXPORT_SYMBOL_GPL(find_get_pid);

This means find_get_pid will call mcount which will call ftrace_pid_func, 
and back again. This can also happen with rcu_read_{un}lock() and 
get_pid() and find_vpid().

We can not do anything special here.

-- Steve
