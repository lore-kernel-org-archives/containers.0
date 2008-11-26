From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] ftrace: add thread comm to function graph tracer
Date: Tue, 25 Nov 2008 21:37:48 -0800
Message-ID: <20081125213748.2cd86b2b.akpm@linux-foundation.org>
References: <20081126051622.134970943@goodmis.org>
	<20081126051710.149585354@goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753347AbYKZFia@vger.kernel.org>
In-Reply-To: <20081126051710.149585354@goodmis.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

On Wed, 26 Nov 2008 00:16:26 -0500 Steven Rostedt <rostedt@goodmis.org> wrote:

> From: Steven Rostedt <rostedt@goodmis.org>
> 
> Impact: enhancement to function graph tracer
> 
> Export the trace_find_cmdline so the function graph tracer can
> use it to print the comms of the threads.
> 
> -static char *trace_find_cmdline(int pid)
> +char *trace_find_cmdline(int pid)
>
> ...
>
>  static int verif_pid(struct trace_seq *s, pid_t pid)
>  {
> +	char *comm;
> +
>  	if (last_pid != -1 && last_pid == pid)
>  		return 1;
>  
>  	last_pid = pid;
> -	return trace_seq_printf(s, "\n------------8<---------- thread %d"
> +	comm = trace_find_cmdline(pid);
> +
> +	return trace_seq_printf(s, "\n------------8<---------- thread %s-%d"
>  				    " ------------8<----------\n\n",
> -				  pid);
> +				    comm, pid);
>  }

This code gets its int's and pid_t's all mixed up.  It's a bit cosmetic, but
nice to get it right for readability's sake.
