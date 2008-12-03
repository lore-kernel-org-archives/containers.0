From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/3] ftrace: use task struct trace flag to filter on pid
Date: Wed, 03 Dec 2008 14:34:27 -0800
Message-ID: <m18wqw3n2k.fsf@frodo.ebiederm.org>
References: <20081203203656.776893226@goodmis.org>
	<20081203203829.158592001@goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755950AbYLCWgh@vger.kernel.org>
In-Reply-To: <20081203203829.158592001@goodmis.org> (Steven Rostedt's message
	of "Wed, 03 Dec 2008 15:36:58 -0500")
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

Steven Rostedt <rostedt@goodmis.org> writes:

> From: Steven Rostedt <srostedt@redhat.com>
>
> Impact: clean up
>
> Use the new task struct trace flags to determine if a process should be
> traced or not.

Looks reasonable.

> Note: this moves the searching of the pid to the slow path of setting
> the pid field. This needs to be converted to the pid name space.
>
> Signed-off-by: Steven Rostedt <srostedt@redhat.com>
> ---
>  kernel/trace/ftrace.c |   28 +++++++++++++++++++++++++---
>  1 files changed, 25 insertions(+), 3 deletions(-)
>
> diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
> index b17a303..c5049f5 100644
> --- a/kernel/trace/ftrace.c
> +++ b/kernel/trace/ftrace.c
> @@ -47,7 +47,7 @@
>  int ftrace_enabled __read_mostly;
>  static int last_ftrace_enabled;
>  
> -/* ftrace_pid_trace >= 0 will only trace threads with this pid */
> +/* set when tracing only a pid */
>  static int ftrace_pid_trace = -1;
>  
>  /* Quick disabling of function tracer. */
> @@ -90,7 +90,7 @@ static void ftrace_list_func(unsigned long ip, unsigned long
> parent_ip)
>  
>  static void ftrace_pid_func(unsigned long ip, unsigned long parent_ip)
>  {
> -	if (current->pid != ftrace_pid_trace)
> +	if (!test_tsk_trace_trace(current))
>  		return;
>  
>  	ftrace_pid_function(ip, parent_ip);
> @@ -1714,11 +1714,33 @@ ftrace_pid_write(struct file *filp, const char __user
> *ubuf,
>  		ftrace_pid_trace = -1;
>  
>  	} else {
> +		struct task_struct *p;
> +		int found = 0;
>  
>  		if (ftrace_pid_trace == val)
>  			goto out;
>  
> -		ftrace_pid_trace = val;
> +		/*
> +		 * Find the task that matches this pid.
> +		 * TODO: use pid namespaces instead.
> +		 */
> +		rcu_read_lock();
> +		for_each_process(p) {
> +			if (p->pid == val) {
> +				found = 1;
> +				set_tsk_trace_trace(p);
> +			} else if (test_tsk_trace_trace(p))
> +				clear_tsk_trace_trace(p);
> +		}
> +		rcu_read_unlock();

Yes.  This function you have just implemented inline is called find_pid.
It uses a hash lookup instead of an expensive walk trough all of the processes
in the system.  So the code becomes something like:


                do_each_pid_task(ftrace_pid_trace, PIDTYPE_PID, task) {
			clear_tsk_trace_tace(p);
                } while_each_pid_task(pid, PIDTYPE_PID, task);
                put_pid(ftrace_pid_trace);

                ftrace_pid_trace = find_get_vpid(val);
                do_each_pid_task(ftrace_pid_trace, PIDTYPE_PID, task) {
                	set_tsk_trace_tace(p);
                } while_each_pid_task(ftrace_pid_trace, PIDTYPE_PID, task);

                if (!ftrace_pid_trace)
                	goto out;

The loops encompass both the test for validity, and handle the weird exec
case where the pid moves from one task to another.

Eric
