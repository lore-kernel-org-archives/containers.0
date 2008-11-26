From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/5] ftrace: add function tracing to single thread
Date: Tue, 25 Nov 2008 22:42:49 -0800
Message-ID: <m1hc5vasye.fsf@frodo.ebiederm.org>
References: <20081126051622.134970943@goodmis.org>
	<20081126051709.571204072@goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753008AbYKZGqV@vger.kernel.org>
In-Reply-To: <20081126051709.571204072@goodmis.org> (Steven Rostedt's message
	of "Wed, 26 Nov 2008 00:16:23 -0500")
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

Steven Rostedt <rostedt@goodmis.org> writes:

> From: Steven Rostedt <srostedt@redhat.com>
>
> Impact: feature to function trace a single thread
>
> This patch adds the ability to function trace a single thread.
> The file:
>
>   /debugfs/tracing/set_ftrace_pid
>
> contains the pid to trace. Valid pids are any positive integer.

Please look below.  Using find_get_pid causes this to use the
same logic as the rest of the kernel on what a valid pid is.
i.e. 0 is not a valid pid.

I believe I have sketched in what is needed to use the struct
pid api properly.  Certainly enough for you to get the jist
of the idea.

> Writing any negative number to this file will disable the pid
> tracing and the function tracer will go back to tracing all of
> threads.
>
> This feature works with both static and dynamic function tracing.
>
> Signed-off-by: Steven Rostedt <srostedt@redhat.com>
> ---
>  Documentation/ftrace.txt |   79 +++++++++++++++++
>  kernel/trace/ftrace.c    |  209 ++++++++++++++++++++++++++++++++++++++++------
>  2 files changed, 262 insertions(+), 26 deletions(-)
>
> diff --git a/Documentation/ftrace.txt b/Documentation/ftrace.txt
> index 35a78bc..de05042 100644
> --- a/Documentation/ftrace.txt
> +++ b/Documentation/ftrace.txt
> @@ -127,6 +127,8 @@ of ftrace. Here is a list of some of the key files:
>  		be traced. If a function exists in both set_ftrace_filter
>  		and set_ftrace_notrace,	the function will _not_ be traced.
>  
> +  set_ftrace_pid: Have the function tracer only trace a single thread.
> +
>    available_filter_functions: This lists the functions that ftrace
>  		has processed and can trace. These are the function
>  		names that you can pass to "set_ftrace_filter" or
> @@ -1073,6 +1075,83 @@ For simple one time traces, the above is sufficent. For
> anything else,
>  a search through /proc/mounts may be needed to find where the debugfs
>  file-system is mounted.
>  
> +
> +Single thread tracing
> +---------------------
> +
> +By writing into /debug/tracing/set_ftrace_pid you can trace a
> +single thread. For example:
> +
> +# cat /debug/tracing/set_ftrace_pid
> +no pid
> +# echo 3111 > /debug/tracing/set_ftrace_pid
> +# cat /debug/tracing/set_ftrace_pid
> +3111
> +# echo function > /debug/tracing/current_tracer
> +# cat /debug/tracing/trace | head
> + # tracer: function
> + #
> + #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
> + #              | |       |          |         |
> +     yum-updatesd-3111  [003]  1637.254676: finish_task_switch <-thread_return
> + yum-updatesd-3111 [003] 1637.254681: hrtimer_cancel <-schedule_hrtimeout_range
> + yum-updatesd-3111 [003] 1637.254682: hrtimer_try_to_cancel <-hrtimer_cancel
> + yum-updatesd-3111 [003] 1637.254683: lock_hrtimer_base <-hrtimer_try_to_cancel
> +     yum-updatesd-3111  [003]  1637.254685: fget_light <-do_sys_poll
> +     yum-updatesd-3111  [003]  1637.254686: pipe_poll <-do_sys_poll
> +# echo -1 > /debug/tracing/set_ftrace_pid
> +# cat /debug/tracing/trace |head
> + # tracer: function
> + #
> + #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
> + #              | |       |          |         |
> + ##### CPU 3 buffer started ####
> +     yum-updatesd-3111  [003]  1701.957688: free_poll_entry <-poll_freewait
> + yum-updatesd-3111 [003] 1701.957689: remove_wait_queue <-free_poll_entry
> +     yum-updatesd-3111  [003]  1701.957691: fput <-free_poll_entry
> +     yum-updatesd-3111  [003]  1701.957692: audit_syscall_exit <-sysret_audit
> +     yum-updatesd-3111  [003]  1701.957693: path_put <-audit_syscall_exit
> +
> +If you want to trace a function when executing, you could use
> +something like this simple program:
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <sys/types.h>
> +#include <sys/stat.h>
> +#include <fcntl.h>
> +#include <unistd.h>
> +
> +int main (int argc, char **argv)
> +{
> +        if (argc < 1)
> +                exit(-1);
> +
> +        if (fork() > 0) {
> +                int fd, ffd;
> +                char line[64];
> +                int s;
> +
> +                ffd = open("/debug/tracing/current_tracer", O_WRONLY);
> +                if (ffd < 0)
> +                        exit(-1);
> +                write(ffd, "nop", 3);
> +
> +                fd = open("/debug/tracing/set_ftrace_pid", O_WRONLY);
> +                s = sprintf(line, "%d\n", getpid());
> +                write(fd, line, s);
> +
> +                write(ffd, "function", 8);
> +
> +                close(fd);
> +                close(ffd);
> +
> +                execvp(argv[1], argv+1);
> +        }
> +
> +        return 0;
> +}
> +
>  dynamic ftrace
>  --------------
>  
> diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
> index 7e2d3b9..00d98c6 100644
> --- a/kernel/trace/ftrace.c
> +++ b/kernel/trace/ftrace.c
> @@ -47,6 +47,9 @@
>  int ftrace_enabled __read_mostly;
>  static int last_ftrace_enabled;
>  
> +/* ftrace_pid_trace >= 0 will only trace threads with this pid */
> +static int ftrace_pid_trace = -1;

Why not?
static struct pid *ftrace_pid_trace = NULL;
> +
>  /* Quick disabling of function tracer. */
>  int function_trace_stop;
>  
> @@ -61,6 +64,7 @@ static int ftrace_disabled __read_mostly;
>  
>  static DEFINE_SPINLOCK(ftrace_lock);
>  static DEFINE_MUTEX(ftrace_sysctl_lock);
> +static DEFINE_MUTEX(ftrace_start_lock);
>  
>  static struct ftrace_ops ftrace_list_end __read_mostly =
>  {
> @@ -70,6 +74,7 @@ static struct ftrace_ops ftrace_list_end __read_mostly =
>  static struct ftrace_ops *ftrace_list __read_mostly = &ftrace_list_end;
>  ftrace_func_t ftrace_trace_function __read_mostly = ftrace_stub;
>  ftrace_func_t __ftrace_trace_function __read_mostly = ftrace_stub;
> +ftrace_func_t ftrace_pid_function __read_mostly = ftrace_stub;
>  
>  static void ftrace_list_func(unsigned long ip, unsigned long parent_ip)
>  {
> @@ -86,6 +91,21 @@ static void ftrace_list_func(unsigned long ip, unsigned long
> parent_ip)
>  	};
>  }
>  
> +static void ftrace_pid_func(unsigned long ip, unsigned long parent_ip)
> +{
> +	if (current->pid != ftrace_pid_trace)
> +		return;

And why not?
        if (task_pid(current) != ftrace_pid_trace)
        	return;

Racy or not.  This is only comparing a different field in struct task_struct.
So there should be not real difference.
> +
> +	ftrace_pid_function(ip, parent_ip);
> +}
> +
> +static void set_ftrace_pid_function(ftrace_func_t func)
> +{
> +	/* do not set ftrace_pid_function to itself! */
> +	if (func != ftrace_pid_func)
> +		ftrace_pid_function = func;
> +}
> +
>  /**
>   * clear_ftrace_function - reset the ftrace function
>   *
> @@ -96,6 +116,7 @@ void clear_ftrace_function(void)
>  {
>  	ftrace_trace_function = ftrace_stub;
>  	__ftrace_trace_function = ftrace_stub;
> +	ftrace_pid_function = ftrace_stub;
>  }
>  
>  #ifndef CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST
> @@ -128,20 +149,26 @@ static int __register_ftrace_function(struct ftrace_ops
> *ops)
>  	ftrace_list = ops;
>  
>  	if (ftrace_enabled) {
> +		ftrace_func_t func;
> +
> +		if (ops->next == &ftrace_list_end)
> +			func = ops->func;
> +		else
> +			func = ftrace_list_func;
> +
> +		if (ftrace_pid_trace >= 0) {
And why not:
		if (ftrace_pid_trace) {
> +			set_ftrace_pid_function(func);
> +			func = ftrace_pid_func;
> +		}
> +
>  		/*
>  		 * For one func, simply call it directly.
>  		 * For more than one func, call the chain.
>  		 */
>  #ifdef CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST
> -		if (ops->next == &ftrace_list_end)
> -			ftrace_trace_function = ops->func;
> -		else
> -			ftrace_trace_function = ftrace_list_func;
> +		ftrace_trace_function = func;
>  #else
> -		if (ops->next == &ftrace_list_end)
> -			__ftrace_trace_function = ops->func;
> -		else
> -			__ftrace_trace_function = ftrace_list_func;
> +		__ftrace_trace_function = func;
>  		ftrace_trace_function = ftrace_test_stop_func;
>  #endif
>  	}
> @@ -182,8 +209,19 @@ static int __unregister_ftrace_function(struct ftrace_ops
> *ops)
>  
>  	if (ftrace_enabled) {
>  		/* If we only have one func left, then call that directly */
> -		if (ftrace_list->next == &ftrace_list_end)
> -			ftrace_trace_function = ftrace_list->func;
> +		if (ftrace_list->next == &ftrace_list_end) {
> +			ftrace_func_t func = ftrace_list->func;
> +
> +			if (ftrace_pid_trace >= 0) {
And why not:
			if (ftrace_pid_trace) {
> +				set_ftrace_pid_function(func);
> +				func = ftrace_pid_func;
> +			}
> +#ifdef CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST
> +			ftrace_trace_function = func;
> +#else
> +			__ftrace_trace_function = func;
> +#endif
> +		}
>  	}
>  
>   out:
> @@ -192,6 +230,38 @@ static int __unregister_ftrace_function(struct ftrace_ops
> *ops)
>  	return ret;
>  }
>  
> +static void ftrace_update_pid_func(void)
> +{
> +	ftrace_func_t func;
> +
> +	/* should not be called from interrupt context */
> +	spin_lock(&ftrace_lock);
> +
> +	if (ftrace_trace_function == ftrace_stub)
> +		goto out;
> +
> +	func = ftrace_trace_function;
> +
> +	if (ftrace_pid_trace >= 0) {
And why not:
	if (ftrace_pid_trace) {
> +		set_ftrace_pid_function(func);
> +		func = ftrace_pid_func;
> +	} else {
> +		if (func != ftrace_pid_func)
> +			goto out;
> +
> +		set_ftrace_pid_function(func);
> +	}
> +
> +#ifdef CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST
> +	ftrace_trace_function = func;
> +#else
> +	__ftrace_trace_function = func;
> +#endif
> +
> + out:
> +	spin_unlock(&ftrace_lock);
> +}
> +
>  #ifdef CONFIG_DYNAMIC_FTRACE
>  #ifndef CONFIG_FTRACE_MCOUNT_RECORD
>  # error Dynamic ftrace depends on MCOUNT_RECORD
> @@ -545,7 +615,19 @@ static void ftrace_run_update_code(int command)
>  
>  static ftrace_func_t saved_ftrace_func;
>  static int ftrace_start_up;
> -static DEFINE_MUTEX(ftrace_start_lock);
> +
> +static void ftrace_startup_enable(int command)
> +{
> +	if (saved_ftrace_func != ftrace_trace_function) {
> +		saved_ftrace_func = ftrace_trace_function;
> +		command |= FTRACE_UPDATE_TRACE_FUNC;
> +	}
> +
> +	if (!command || !ftrace_enabled)
> +		return;
> +
> +	ftrace_run_update_code(command);
> +}
>  
>  static void ftrace_startup(void)
>  {
> @@ -558,16 +640,8 @@ static void ftrace_startup(void)
>  	ftrace_start_up++;
>  	command |= FTRACE_ENABLE_CALLS;
>  
> -	if (saved_ftrace_func != ftrace_trace_function) {
> -		saved_ftrace_func = ftrace_trace_function;
> -		command |= FTRACE_UPDATE_TRACE_FUNC;
> -	}
> -
> -	if (!command || !ftrace_enabled)
> -		goto out;
> +	ftrace_startup_enable(command);
>  
> -	ftrace_run_update_code(command);
> - out:
>  	mutex_unlock(&ftrace_start_lock);
>  }
>  
> @@ -1262,13 +1336,10 @@ static struct file_operations ftrace_notrace_fops = {
>  	.release = ftrace_notrace_release,
>  };
>  
> -static __init int ftrace_init_debugfs(void)
> +static __init int ftrace_init_dyn_debugfs(struct dentry *d_tracer)
>  {
> -	struct dentry *d_tracer;
>  	struct dentry *entry;
>  
> -	d_tracer = tracing_init_dentry();
> -
>  	entry = debugfs_create_file("available_filter_functions", 0444,
>  				    d_tracer, NULL, &ftrace_avail_fops);
>  	if (!entry)
> @@ -1295,8 +1366,6 @@ static __init int ftrace_init_debugfs(void)
>  	return 0;
>  }
>  
> -fs_initcall(ftrace_init_debugfs);
> -
>  static int ftrace_convert_nops(struct module *mod,
>  			       unsigned long *start,
>  			       unsigned long *end)
> @@ -1382,12 +1451,100 @@ static int __init ftrace_nodyn_init(void)
>  }
>  device_initcall(ftrace_nodyn_init);
>  
> +static inline int ftrace_init_dyn_debugfs(struct dentry *d_tracer) { return 0;
> }
> +static inline void ftrace_startup_enable(int command) { }
>  # define ftrace_startup()		do { } while (0)
>  # define ftrace_shutdown()		do { } while (0)
>  # define ftrace_startup_sysctl()	do { } while (0)
>  # define ftrace_shutdown_sysctl()	do { } while (0)
>  #endif /* CONFIG_DYNAMIC_FTRACE */
>  
> +static ssize_t
> +ftrace_pid_read(struct file *file, char __user *ubuf,
> +		       size_t cnt, loff_t *ppos)
> +{
> +	char buf[64];
> +	int r;
> +
> +	if (ftrace_pid_trace >= 0)
> +		r = sprintf(buf, "%u\n", ftrace_pid_trace);
And why not:
    	if (ftrace_pid_trace)
		r = sprintf(buf, "%u\n", pid_vmr(ftrace_pid_trace))
> +	else
> +		r = sprintf(buf, "no pid\n");
> +
> +	return simple_read_from_buffer(ubuf, cnt, ppos, buf, r);
> +}
> +
> +static ssize_t
> +ftrace_pid_write(struct file *filp, const char __user *ubuf,
> +		   size_t cnt, loff_t *ppos)
> +{
> +	char buf[64];
> +	long val;
> +	int ret;
> +
> +	if (cnt >= sizeof(buf))
> +		return -EINVAL;
> +
> +	if (copy_from_user(&buf, ubuf, cnt))
> +		return -EFAULT;
> +
> +	buf[cnt] = 0;
> +
> +	ret = strict_strtol(buf, 10, &val);
> +	if (ret < 0)
> +		return ret;

Why not?
	pid = find_get_pid(ret);
        mutex_lock(&ftrace_start_lock);
        if (pid == ftrace_pid_trace)
		goto out;

        struct pid *tmp;
        tmp = ftrace_pid_trace;
        ftrace_pid_trace = pid;
        pid = tmp;        

	/* update the function call */
	ftrace_update_pid_func();
	ftrace_startup_enable(0);
out:
	mutex_unlock(&ftrace_start_lock);
        put_pid(pid);

> +
> +	mutex_lock(&ftrace_start_lock);
> +	if (ret < 0) {
> +		/* disable pid tracing */
> +		if (ftrace_pid_trace < 0)
> +			goto out;
> +		ftrace_pid_trace = -1;
> +
> +	} else {
> +
> +		if (ftrace_pid_trace == val)
> +			goto out;
> +
> +		ftrace_pid_trace = val;
> +	}
> +
> +	/* update the function call */
> +	ftrace_update_pid_func();
> +	ftrace_startup_enable(0);
> +
> + out:
> +	mutex_unlock(&ftrace_start_lock);
> +
> +	return cnt;
> +}
> +
> +static struct file_operations ftrace_pid_fops = {
> +	.read = ftrace_pid_read,
> +	.write = ftrace_pid_write,
> +};
> +
> +static __init int ftrace_init_debugfs(void)
> +{
> +	struct dentry *d_tracer;
> +	struct dentry *entry;
> +
> +	d_tracer = tracing_init_dentry();
> +	if (!d_tracer)
> +		return 0;
> +
> +	ftrace_init_dyn_debugfs(d_tracer);
> +
> +	entry = debugfs_create_file("set_ftrace_pid", 0644, d_tracer,
> +				    NULL, &ftrace_pid_fops);
> +	if (!entry)
> +		pr_warning("Could not create debugfs "
> +			   "'set_ftrace_pid' entry\n");
> +	return 0;
> +}
> +
> +fs_initcall(ftrace_init_debugfs);
> +
>  /**
>   * ftrace_kill - kill ftrace
>   *
> -- 
> 1.5.6.5
>
> -- 
