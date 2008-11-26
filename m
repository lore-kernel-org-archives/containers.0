From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/5] ftrace: add function tracing to single thread
Date: Wed, 26 Nov 2008 11:43:00 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0811261137050.26743@gandalf.stny.rr.com>
References: <20081126051622.134970943@goodmis.org> <20081126051709.571204072@goodmis.org> <20081125212946.66dd5f76.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753927AbYKZQnU@vger.kernel.org>
In-Reply-To: <20081125212946.66dd5f76.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org


On Tue, 25 Nov 2008, Andrew Morton wrote:
> On Wed, 26 Nov 2008 00:16:23 -0500 Steven Rostedt <rostedt@goodmis.org> wrote:
> >  
> > +static void ftrace_pid_func(unsigned long ip, unsigned long parent_ip)
> > +{
> > +	if (current->pid != ftrace_pid_trace)
> > +		return;
> 
> What happened with this?
> 
> It would reeeeely help if the changelog was updated to cover such
> frequently-occurring controversies as this.

I just posted this again because Ingo did not pull it the first time.
This patch did not change (nor did the change log) from my first
posting, except that I rebased it on top of tip.

I would like to add new patches to solve this controversy. This way
I can focus on the approach without cluttering up the patch itself.
Also, this way works for the cases I currently care about, and should not 
break any other case. That is, the side effect of not selecting the right
pid is that we either trace a process we do not want to trace, or we
do not trace a process we want to trace. Nothing that will bring down
the system ;-)

> 
> > +#ifdef CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST
> > +	ftrace_trace_function = func;
> > +#else
> > +	__ftrace_trace_function = func;
> > +#endif
> 
> Pulling this assignment out into a helper fuction would clean things
> up.  It happens at least twice.

Yes, I agree. I want to get this over to my PPC box where it does not
have the "CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST" set. This way I can test 
all cases. And yes, I want to make a wrapper function for that too.

> 
> >
> > ...
> >
> > +static ssize_t
> > +ftrace_pid_read(struct file *file, char __user *ubuf,
> > +		       size_t cnt, loff_t *ppos)
> > +{
> > +	char buf[64];
> > +	int r;
> > +
> > +	if (ftrace_pid_trace >= 0)
> > +		r = sprintf(buf, "%u\n", ftrace_pid_trace);
> 
> ftrace_pid_trace is signed, and we print it as unsigned.  Can this be
> improved?

We only print it if it is greater than or equal to 0. Does this matter?
It needs to be signed, because we print "no pid" when negative.

> 
> > +	else
> > +		r = sprintf(buf, "no pid\n");
> > +
> > +	return simple_read_from_buffer(ubuf, cnt, ppos, buf, r);
> > +}
> > +
> > +static ssize_t
> > +ftrace_pid_write(struct file *filp, const char __user *ubuf,
> > +		   size_t cnt, loff_t *ppos)
> > +{
> > +	char buf[64];
> > +	long val;
> > +	int ret;
> > +
> > +	if (cnt >= sizeof(buf))
> > +		return -EINVAL;
> > +
> > +	if (copy_from_user(&buf, ubuf, cnt))
> > +		return -EFAULT;
> > +
> > +	buf[cnt] = 0;
> 
> Might be able to use strncpy_from_user() here?

We are reading a number. But we might later add a string. The amount to be
read has a limit. Should I switch?

> 
> > +	ret = strict_strtol(buf, 10, &val);
> > +	if (ret < 0)
> > +		return ret;
> > +
> > +	mutex_lock(&ftrace_start_lock);
> > +	if (ret < 0) {
> > +		/* disable pid tracing */
> > +		if (ftrace_pid_trace < 0)
> > +			goto out;
> > +		ftrace_pid_trace = -1;
> > +
> > +	} else {
> > +
> > +		if (ftrace_pid_trace == val)
> > +			goto out;
> > +
> > +		ftrace_pid_trace = val;
> > +	}
> > +
> > +	/* update the function call */
> > +	ftrace_update_pid_func();
> > +	ftrace_startup_enable(0);
> > +
> > + out:
> > +	mutex_unlock(&ftrace_start_lock);
> > +
> > +	return cnt;
> > +}
> > +
> > +static struct file_operations ftrace_pid_fops = {
> 
> const, please.

Ouch, I cut and pasted. I need to fix all of them.

Thanks,

-- Steve

> 
> > +	.read = ftrace_pid_read,
> > +	.write = ftrace_pid_write,
> > +};
> > +
> 
> 
> 
