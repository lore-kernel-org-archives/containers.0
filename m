From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] ftrace: add function tracing to single thread
Date: Tue, 25 Nov 2008 21:29:46 -0800
Message-ID: <20081125212946.66dd5f76.akpm@linux-foundation.org>
References: <20081126051622.134970943@goodmis.org>
	<20081126051709.571204072@goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753195AbYKZFa4@vger.kernel.org>
In-Reply-To: <20081126051709.571204072@goodmis.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

On Wed, 26 Nov 2008 00:16:23 -0500 Steven Rostedt <rostedt@goodmis.org> wrote:

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
> Writing any negative number to this file will disable the pid
> tracing and the function tracer will go back to tracing all of
> threads.
> 
> This feature works with both static and dynamic function tracing.
> 
> ...
>
> --- a/kernel/trace/ftrace.c
> +++ b/kernel/trace/ftrace.c
> @@ -47,6 +47,9 @@
>  int ftrace_enabled __read_mostly;
>  static int last_ftrace_enabled;
>  
> +/* ftrace_pid_trace >= 0 will only trace threads with this pid */
> +static int ftrace_pid_trace = -1;
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
> @@ -86,6 +91,21 @@ static void ftrace_list_func(unsigned long ip, unsigned long parent_ip)
>  	};
>  }
>  
> +static void ftrace_pid_func(unsigned long ip, unsigned long parent_ip)
> +{
> +	if (current->pid != ftrace_pid_trace)
> +		return;

What happened with this?

It would reeeeely help if the changelog was updated to cover such
frequently-occurring controversies as this.

> +#ifdef CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST
> +	ftrace_trace_function = func;
> +#else
> +	__ftrace_trace_function = func;
> +#endif

Pulling this assignment out into a helper fuction would clean things
up.  It happens at least twice.

>
> ...
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

ftrace_pid_trace is signed, and we print it as unsigned.  Can this be
improved?

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

Might be able to use strncpy_from_user() here?

> +	ret = strict_strtol(buf, 10, &val);
> +	if (ret < 0)
> +		return ret;
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

const, please.

> +	.read = ftrace_pid_read,
> +	.write = ftrace_pid_write,
> +};
> +
