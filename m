From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 2/2] Notify container-init parent a 'reboot' occured
Date: Sat, 13 Aug 2011 16:41:00 +0200
Message-ID: <4E468CFC.8050901__12461.3076834523$1313246618$gmane$org@free.fr>
References: <1313094241-3674-1-git-send-email-daniel.lezcano@free.fr>
	<1313094241-3674-3-git-send-email-daniel.lezcano@free.fr>
	<20110813001959.GB5777@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110813001959.GB5777-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/13/2011 02:19 AM, Matt Helsley wrote:
> On Thu, Aug 11, 2011 at 10:24:01PM +0200, Daniel Lezcano wrote:
>> When the reboot syscall is called and the pid namespace where the calling
>> process belongs to is not from the init pidns, we send a SIGCHLD with CLD_REBOOTED
>> to the parent of this pid namespace.
> Shouldn't we honor the exit_signal set via clone() here rather than
> hardcode SIGCHLD? More below...

Hmm,  I don't think so, that does not really make sense.

[ ... ]

>> +void do_notify_parent_cldreboot(struct task_struct *tsk, int why, char *buffer)
>> +{
>> +	struct siginfo info = { };
>> +	struct task_struct *parent;
>> +	struct sighand_struct *sighand;
>> +	unsigned long flags;
>> +
>> +	if (tsk->ptrace)
>> +		parent = tsk->parent;
>> +	else {
>> +		tsk = tsk->group_leader;
>> +		parent = tsk->real_parent;
>> +	}
>> +
>> +	info.si_signo = SIGCHLD;
> should this be:
>
> info.si_signo = tsk->exit_signal == -1 ? SIGCHLD : tsk->exit_signal;


No, because this code is always called for SIGHLD.
The userspace will receive this signal with CLD_REBOOT if it sets the
SA_CLDREBOOT flag option which is not set by default.

>> +	info.si_errno = 0;
>> +	info.si_status = why;
>> +
>> +	rcu_read_lock();
>> +	info.si_pid = task_pid_nr_ns(tsk, parent->nsproxy->pid_ns);
>> +	info.si_uid = __task_cred(tsk)->uid;
>> +	rcu_read_unlock();
>> +
>> +	info.si_utime = cputime_to_clock_t(tsk->utime);
>> +	info.si_stime = cputime_to_clock_t(tsk->stime);
>> +
>> +	info.si_code = CLD_REBOOTED;
>> +
>> +	sighand = parent->sighand;
>> +	spin_lock_irqsave(&sighand->siglock, flags);
>> +	if (sighand->action[SIGCHLD-1].sa.sa_handler != SIG_IGN &&
>> +	    sighand->action[SIGCHLD-1].sa.sa_flags & SA_CLDREBOOT)
>> +		__group_send_sig_info(SIGCHLD, &info, parent);
> (with corresponding changes above...)
>
>> +	/*
>> +	 * Even if SIGCHLD is not generated, we must wake up wait4 calls.
>> +	 */
