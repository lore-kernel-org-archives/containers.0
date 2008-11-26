From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/5] ftrace: add function tracing to single thread
Date: Wed, 26 Nov 2008 11:54:54 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0811261151070.26743@gandalf.stny.rr.com>
References: <20081126051622.134970943@goodmis.org> <20081126051709.571204072@goodmis.org> <m1hc5vasye.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754206AbYKZQzK@vger.kernel.org>
In-Reply-To: <m1hc5vasye.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org


On Tue, 25 Nov 2008, Eric W. Biederman wrote:

> Steven Rostedt <rostedt@goodmis.org> writes:
> 
> > From: Steven Rostedt <srostedt@redhat.com>
> >
> > Impact: feature to function trace a single thread
> >
> > This patch adds the ability to function trace a single thread.
> > The file:
> >
> >   /debugfs/tracing/set_ftrace_pid
> >
> > contains the pid to trace. Valid pids are any positive integer.
> 
> Please look below.  Using find_get_pid causes this to use the
> same logic as the rest of the kernel on what a valid pid is.
> i.e. 0 is not a valid pid.

0 is not? What happens if I want to trace what the swapper task is doing?
I want the ability to trace kernel threads as well.

> 
> I believe I have sketched in what is needed to use the struct
> pid api properly.  Certainly enough for you to get the jist
> of the idea.
> 
> > Writing any negative number to this file will disable the pid
> > tracing and the function tracer will go back to tracing all of
> > threads.
> >
> > This feature works with both static and dynamic function tracing.
> >
> > Signed-off-by: Steven Rostedt <srostedt@redhat.com>
> > ---
> >  Documentation/ftrace.txt |   79 +++++++++++++++++
> >  kernel/trace/ftrace.c    |  209 ++++++++++++++++++++++++++++++++++++++++------
> >  2 files changed, 262 insertions(+), 26 deletions(-)
> >
> > diff --git a/Documentation/ftrace.txt b/Documentation/ftrace.txt
> > index 35a78bc..de05042 100644
> > --- a/Documentation/ftrace.txt
> > +++ b/Documentation/ftrace.txt
> > @@ -127,6 +127,8 @@ of ftrace. Here is a list of some of the key files:
> >  		be traced. If a function exists in both set_ftrace_filter
> >  		and set_ftrace_notrace,	the function will _not_ be traced.
> >  
> > +  set_ftrace_pid: Have the function tracer only trace a single thread.
> > +
> >    available_filter_functions: This lists the functions that ftrace
> >  		has processed and can trace. These are the function
> >  		names that you can pass to "set_ftrace_filter" or
> > @@ -1073,6 +1075,83 @@ For simple one time traces, the above is sufficent. For
> > anything else,
> >  a search through /proc/mounts may be needed to find where the debugfs
> >  file-system is mounted.
> >  
> > +
> > +Single thread tracing
> > +---------------------
> > +
> > +By writing into /debug/tracing/set_ftrace_pid you can trace a
> > +single thread. For example:
> > +
> > +# cat /debug/tracing/set_ftrace_pid
> > +no pid
> > +# echo 3111 > /debug/tracing/set_ftrace_pid
> > +# cat /debug/tracing/set_ftrace_pid
> > +3111
> > +# echo function > /debug/tracing/current_tracer
> > +# cat /debug/tracing/trace | head
> > + # tracer: function
> > + #
> > + #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
> > + #              | |       |          |         |
> > +     yum-updatesd-3111  [003]  1637.254676: finish_task_switch <-thread_return
> > + yum-updatesd-3111 [003] 1637.254681: hrtimer_cancel <-schedule_hrtimeout_range
> > + yum-updatesd-3111 [003] 1637.254682: hrtimer_try_to_cancel <-hrtimer_cancel
> > + yum-updatesd-3111 [003] 1637.254683: lock_hrtimer_base <-hrtimer_try_to_cancel
> > +     yum-updatesd-3111  [003]  1637.254685: fget_light <-do_sys_poll
> > +     yum-updatesd-3111  [003]  1637.254686: pipe_poll <-do_sys_poll
> > +# echo -1 > /debug/tracing/set_ftrace_pid
> > +# cat /debug/tracing/trace |head
> > + # tracer: function
> > + #
> > + #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
> > + #              | |       |          |         |
> > + ##### CPU 3 buffer started ####
> > +     yum-updatesd-3111  [003]  1701.957688: free_poll_entry <-poll_freewait
> > + yum-updatesd-3111 [003] 1701.957689: remove_wait_queue <-free_poll_entry
> > +     yum-updatesd-3111  [003]  1701.957691: fput <-free_poll_entry
> > +     yum-updatesd-3111  [003]  1701.957692: audit_syscall_exit <-sysret_audit
> > +     yum-updatesd-3111  [003]  1701.957693: path_put <-audit_syscall_exit
> > +
> > +If you want to trace a function when executing, you could use
> > +something like this simple program:
> > +
> > +#include <stdio.h>
> > +#include <stdlib.h>
> > +#include <sys/types.h>
> > +#include <sys/stat.h>
> > +#include <fcntl.h>
> > +#include <unistd.h>
> > +
> > +int main (int argc, char **argv)
> > +{
> > +        if (argc < 1)
> > +                exit(-1);
> > +
> > +        if (fork() > 0) {
> > +                int fd, ffd;
> > +                char line[64];
> > +                int s;
> > +
> > +                ffd = open("/debug/tracing/current_tracer", O_WRONLY);
> > +                if (ffd < 0)
> > +                        exit(-1);
> > +                write(ffd, "nop", 3);
> > +
> > +                fd = open("/debug/tracing/set_ftrace_pid", O_WRONLY);
> > +                s = sprintf(line, "%d\n", getpid());
> > +                write(fd, line, s);
> > +
> > +                write(ffd, "function", 8);
> > +
> > +                close(fd);
> > +                close(ffd);
> > +
> > +                execvp(argv[1], argv+1);
> > +        }
> > +
> > +        return 0;
> > +}
> > +
> >  dynamic ftrace
> >  --------------
> >  
> > diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
> > index 7e2d3b9..00d98c6 100644
> > --- a/kernel/trace/ftrace.c
> > +++ b/kernel/trace/ftrace.c
> > @@ -47,6 +47,9 @@
> >  int ftrace_enabled __read_mostly;
> >  static int last_ftrace_enabled;
> >  
> > +/* ftrace_pid_trace >= 0 will only trace threads with this pid */
> > +static int ftrace_pid_trace = -1;
> 
> Why not?
> static struct pid *ftrace_pid_trace = NULL;
> > +
> >  /* Quick disabling of function tracer. */
> >  int function_trace_stop;
> >  
> > @@ -61,6 +64,7 @@ static int ftrace_disabled __read_mostly;
> >  
> >  static DEFINE_SPINLOCK(ftrace_lock);
> >  static DEFINE_MUTEX(ftrace_sysctl_lock);
> > +static DEFINE_MUTEX(ftrace_start_lock);
> >  
> >  static struct ftrace_ops ftrace_list_end __read_mostly =
> >  {
> > @@ -70,6 +74,7 @@ static struct ftrace_ops ftrace_list_end __read_mostly =
> >  static struct ftrace_ops *ftrace_list __read_mostly = &ftrace_list_end;
> >  ftrace_func_t ftrace_trace_function __read_mostly = ftrace_stub;
> >  ftrace_func_t __ftrace_trace_function __read_mostly = ftrace_stub;
> > +ftrace_func_t ftrace_pid_function __read_mostly = ftrace_stub;
> >  
> >  static void ftrace_list_func(unsigned long ip, unsigned long parent_ip)
> >  {
> > @@ -86,6 +91,21 @@ static void ftrace_list_func(unsigned long ip, unsigned long
> > parent_ip)
> >  	};
> >  }
> >  
> > +static void ftrace_pid_func(unsigned long ip, unsigned long parent_ip)
> > +{
> > +	if (current->pid != ftrace_pid_trace)
> > +		return;
> 
> And why not?
>         if (task_pid(current) != ftrace_pid_trace)
>         	return;
> 
> Racy or not.  This is only comparing a different field in struct task_struct.
> So there should be not real difference.

There's no race here. Do kernel threads have their own unique "task_pid"s?

I understand where you are going with this, and I have no issue with it. 
As long as I can also pick kernel threads to trace including the idle 
thread.

Thanks,

-- Steve
