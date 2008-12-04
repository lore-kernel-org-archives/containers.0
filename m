From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 3/3] ftrace: add ability to only trace swapper tasks
Date: Thu, 04 Dec 2008 04:54:10 -0800
Message-ID: <m163m0umml.fsf@frodo.ebiederm.org>
References: <20081204052638.425740534@goodmis.org>
	<20081204052735.362609481@goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081204052735.362609481-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> (Steven Rostedt's message
	of "Thu, 04 Dec 2008 00:26:41 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Cc: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Steven Rostedt <srostedt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> writes:

> From: Steven Rostedt <srostedt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>
> Impact: New feature
>
> This patch lets the swapper tasks of all CPUS be filtered by the
> set_ftrace_pid file.
>
> If '0' is echoed into this file, then all the idle tasks (aka swapper)
> is flagged to be traced.  This affects all CPU idle tasks.

Ok.  Nits below.

> Signed-off-by: Steven Rostedt <srostedt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/trace/ftrace.c |   74 +++++++++++++++++++++++++++++++++++++++++-------
>  1 files changed, 63 insertions(+), 11 deletions(-)
>
> diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
> index 10b1d7c..eb57dc1 100644
> --- a/kernel/trace/ftrace.c
> +++ b/kernel/trace/ftrace.c
> @@ -49,6 +49,7 @@ static int last_ftrace_enabled;
>  
>  /* set when tracing only a pid */
>  struct pid *ftrace_pid_trace;
> +static struct pid * const ftrace_swapper_pid = (struct pid *)1;

The initializer should be spelled &init_struct_pid instead of (struct pid *)1;

Except for the special case of finding this unhashed pid, by making the
attach_pid(p, PIDTYPE_PID, pid) unconditional in copy_process, you can
make the rest of the special cases go away.

Eric

>  
>  /* Quick disabling of function tracer. */
>  int function_trace_stop;
> @@ -1678,7 +1679,9 @@ ftrace_pid_read(struct file *file, char __user *ubuf,
>  	char buf[64];
>  	int r;
>  
> -	if (ftrace_pid_trace)
> +	if (ftrace_pid_trace == ftrace_swapper_pid)
> +		r = sprintf(buf, "swapper tasks\n");
> +	else if (ftrace_pid_trace)
>  		r = sprintf(buf, "%u\n", pid_nr(ftrace_pid_trace));
>  	else
>  		r = sprintf(buf, "no pid\n");
> @@ -1686,19 +1689,43 @@ ftrace_pid_read(struct file *file, char __user *ubuf,
>  	return simple_read_from_buffer(ubuf, cnt, ppos, buf, r);
>  }
>  
> -static void clear_ftrace_pid_task(struct pid **pid)
> +static void clear_ftrace_swapper(void)
>  {
>  	struct task_struct *p;
> +	int cpu;
>  
> -	do_each_pid_task(*pid, PIDTYPE_PID, p) {
> +	get_online_cpus();
> +	for_each_online_cpu(cpu) {
> +		p = idle_task(cpu);
>  		clear_tsk_trace_trace(p);
> -	} while_each_pid_task(*pid, PIDTYPE_PID, p);
> -	put_pid(*pid);
> +	}
> +	put_online_cpus();
> +}
>  
> -	*pid = NULL;
> +static void set_ftrace_swapper(void)
> +{
> +	struct task_struct *p;
> +	int cpu;
> +
> +	get_online_cpus();
> +	for_each_online_cpu(cpu) {
> +		p = idle_task(cpu);
> +		set_tsk_trace_trace(p);
> +	}
> +	put_online_cpus();
>  }
>  
> -static void set_ftrace_pid_task(struct pid *pid)
> +static void clear_ftrace_pid(struct pid *pid)
> +{
> +	struct task_struct *p;
> +
> +	do_each_pid_task(pid, PIDTYPE_PID, p) {
> +		clear_tsk_trace_trace(p);
> +	} while_each_pid_task(pid, PIDTYPE_PID, p);
> +	put_pid(pid);
> +}
> +
> +static void set_ftrace_pid(struct pid *pid)
>  {
>  	struct task_struct *p;
>  
> @@ -1707,6 +1734,24 @@ static void set_ftrace_pid_task(struct pid *pid)
>  	} while_each_pid_task(pid, PIDTYPE_PID, p);
>  }
>  
> +static void clear_ftrace_pid_task(struct pid **pid)
> +{
> +	if (*pid == ftrace_swapper_pid)
> +		clear_ftrace_swapper();
> +	else
> +		clear_ftrace_pid(*pid);
> +
> +	*pid = NULL;
> +}
> +
> +static void set_ftrace_pid_task(struct pid *pid)
> +{
> +	if (pid == ftrace_swapper_pid)
> +		set_ftrace_swapper();
> +	else
> +		set_ftrace_pid(pid);
> +}
> +
>  static ssize_t
>  ftrace_pid_write(struct file *filp, const char __user *ubuf,
>  		   size_t cnt, loff_t *ppos)
> @@ -1737,11 +1782,18 @@ ftrace_pid_write(struct file *filp, const char __user
> *ubuf,
>  		clear_ftrace_pid_task(&ftrace_pid_trace);
>  
>  	} else {
> -		pid = find_get_pid(val);
> +		/* swapper task is special */
> +		if (!val) {
> +			pid = ftrace_swapper_pid;
> +			if (pid == ftrace_pid_trace)
> +				goto out;
> +		} else {
> +			pid = find_get_pid(val);
>  
> -		if (pid == ftrace_pid_trace) {
> -			put_pid(pid);
> -			goto out;
> +			if (pid == ftrace_pid_trace) {
> +				put_pid(pid);
> +				goto out;
> +			}
>  		}
>  
>  		if (ftrace_pid_trace)
> -- 
> 1.5.6.5
>
> -- 
