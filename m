From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/3] ftrace: add function tracing to single thread
Date: Wed, 26 Nov 2008 11:36:42 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0811261117580.26743@gandalf.stny.rr.com>
References: <20081125223421.795046329@goodmis.org> <20081125223456.976670734@goodmis.org> <20081125144221.66eb99ad.akpm@linux-foundation.org> <alpine.DEB.1.10.0811251800130.26424@gandalf.stny.rr.com> <20081125153104.ecdceed4.akpm@linux-foundation.org>
 <alpine.DEB.1.10.0811251909320.26424@gandalf.stny.rr.com> <1227660839.12109.52.camel@nimitz> <alpine.DEB.1.10.0811251956570.26424@gandalf.stny.rr.com> <m1myfncbc0.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754382AbYKZQg7@vger.kernel.org>
In-Reply-To: <m1myfncbc0.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.osdl.org, fweisbec@gmail.com, Ingo Molnar <mingo@elte.hu>, LKML <linux-kernel@vger.kernel.org>, srostedt@redhat.com, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>
List-Id: containers.vger.kernel.org


On Tue, 25 Nov 2008, Eric W. Biederman wrote:

> Steven Rostedt <rostedt@goodmis.org> writes:
> 
> > On Tue, 25 Nov 2008, Dave Hansen wrote:
> >> > 
> >> > I think the end result was, if this file can only be changed by root, then 
> >> > we do not need to worry about namespaces. This file is a privileged file 
> >> > that can only be modified by root.
> >> > 
> >> > If someday we decide to let non admin users touch this file, then we would
> >> > need to care about this.  This file may actually be modified in the future 
> >> > by users, so this may become an issue.
> >> 
> >> This really has very little to do with root vs non-root users.  In fact,
> >> we're working towards having cases where we have many "root" users, even
> >> those inside namespaces.  It is also quite possible for a normal root
> >> user to fork into a new pid namespace.  In that case, root simply won't
> >> be able to use this feature because something like:
> >> 	
> >> 	echo $$ /debugfs/tracing/set_ftrace_pid
> >> 	
> >> just won't work.  Let's look at a bit of the code.
> >> 
> >> +static void ftrace_pid_func(unsigned long ip, unsigned long parent_ip)
> >> +{
> >> +       if (current->pid != ftrace_pid_trace)
> >> +               return;
> >> +
> >> +       ftrace_pid_function(ip, parent_ip);
> >> +}
> >> 
> >> One thing this doesn't deal with is pid wraparound.  Does that matter?
> >
> > Should not.  This is just a way to trace a particular process. Currently 
> > it traces all processes. If we wrap, then we trace the process with the 
> > new pid. This should not be an issue.
> 
> So.  Using raw pid numbers in the kernel is bad form.  The internal
> representation should be struct pid pointers as much as we can make
> them.
> 
> I would 100% prefer it if ftrace_pid_func was written in terms of struct
> pid.  That does guarantee you don't have pid wrap around issues.
> It almost makes it clear 
> 
> +static void ftrace_pid_func(unsigned long ip, unsigned long parent_ip)
> +{
> +	if (task_pid(current) == ftrace_pid_trace)
> +               return;
> +
> +       ftrace_pid_function(ip, parent_ip);
> +}
> 
> We don't need locks to access the pid of current.

That version does not bother me. I'm not worried about locks as much as
I am about recursion. If that "task_pid()" ever became a function that is
traced by mcount, then it will end up in a recursive loop, and will crash 
the system.

> 
> 
> >> If you want to fix this a bit, instead of saving off the pid_t in
> >> ftrace_pid_trace, you should save a 'struct pid'.  You can get the
> >> 'struct pid' for a particular task by doing a find_get_pid(pid_t).  You
> >> can then compare that pid_t to current by doing a
> >> pid_task(struct_pid_that_i_saved, PIDTYPE_PID).  That will also protect
> >> against pid wraparound.
> >> 
> >> The find_get_pid() is handy because it will do the pid_t lookup in the
> >> context of the current task's pid namespace, which is what you want, I
> >> think.
> >
> > Nope, we can not call that in this context. ftrace_pid_func is called 
> > directly from mcount, without any protection.
> 
> Of course you can't.  But at the same time find_get_pid() is always
> supposed to be called on the user space pid ingress path.
> 
> > struct pid *find_get_pid(pid_t nr)
> > {
> > 	struct pid *pid;
> >
> > 	rcu_read_lock();
> > 	pid = get_pid(find_vpid(nr));
> > 	rcu_read_unlock();
> >
> > 	return pid;
> > }
> > EXPORT_SYMBOL_GPL(find_get_pid);
> >
> > This means find_get_pid will call mcount which will call ftrace_pid_func, 
> > and back again. This can also happen with rcu_read_{un}lock() and 
> > get_pid() and find_vpid().
> >
> > We can not do anything special here.
> 
> I don't see the whole path.  But here is the deal.
> 1) Using struct pid and the proper find_get_pid() means that a user with
>    the proper capabilities/permissions who happens to be running in a pid
>    namespace can call this and it will just work.
> 
> 2) The current best practices in the current are to:
>    - call find_get_pid() when you capture a user space pid.
>    - call put_pid() when you are done with it.
> 
>    Perhaps that is just:
>    put_pid(ftrace_pid_trace);
>    ftrace_pid_trace = find_get_pid(user_provided_pid_value);

This may be fine.

> 
> 3) If you ultimately want to support the full gamut:
>    thread/process/process group/session.  You will need
>    to use struct pid pointer comparisons.
> 
> 4) When I looked at the place you were concerned about races 
>    a) you were concerned about the wrong race.
>    b) I don't see a race.
>    c) You were filtering for the tid of a linux task not
>       the tgid of a process.  So the code didn't seem to
>       be doing what you thought it was doing.
> 
> 5) I keep thinking current->pid should be removed some day.
> 
> So let's do this properly if we can.  This is a privileged operation
> so we don't need to support people without the proper capabilities
> doing this.  Or multiple comparisons or anything silly like that.  But
> doing this with struct pid comparisons seems cleaner and more maintainable.  And that
> really should matter.

Just so you understand what I'm concerned about:

$ objdump -dr kernel/pid.o
[...]
0000025f <find_get_pid>:
 25f:   55                      push   %ebp
 260:   89 e5                   mov    %esp,%ebp
 262:   53                      push   %ebx
 263:   e8 fc ff ff ff          call   264 <find_get_pid+0x5>
                        264: R_386_PC32 mcount
 268:   89 c3                   mov    %eax,%ebx
 26a:   b8 01 00 00 00          mov    $0x1,%eax


looking in arch/x86/kernel/entry_32.S:

ENTRY(mcount)
        cmpl $0, function_trace_stop
        jne  ftrace_stub

        cmpl $ftrace_stub, ftrace_trace_function
        jnz trace
[...]
trace:
        pushl %eax
        pushl %ecx
        pushl %edx
        movl 0xc(%esp), %eax
        movl 0x4(%ebp), %edx
        subl $MCOUNT_INSN_SIZE, %eax

        call *ftrace_trace_function



looking in kerne/trace/ftrace.c:

                        if (ftrace_pid_trace >= 0) {
                                set_ftrace_pid_function(func);
                                func = ftrace_pid_func;
                        }
                        ftrace_trace_function = func;

And we then have

static void ftrace_pid_func(unsigned long ip, unsigned long parent_ip)
{
        if (current->pid != ftrace_pid_trace)
                return;

        ftrace_pid_function(ip, parent_ip);
}


Now by having ftrace_pid_func call find_get_pid, we have the function flow 
of...


 schedule() /* any traced function */
  --> mcount
        --> *ftrace_trace_function == ftrace_pid_func
          ftrace_pid_func
               --> find_get_pid
                    --> mcount
                         --> *ftrace_trace_function == ftrace_pid_func
                             ftrace_pid_func
                                  --> find_get_pid
                                       [ ad infinitum ]


The comparison must be very careful not to call anything that will also 
trace. I can add code to catch this recursion, but this is overhead I do 
not want to add. Remember, this is called on every function call.

If we do the work at the time we set ftrace_pid_trace and we can do simple 
pointer comparisons in the ftrace_pid_func, I will be happy with that. I'm 
still learning about this pid namespace, so I'll probably screw it up a 
few more times ;-)

-- Steve
