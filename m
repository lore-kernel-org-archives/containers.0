From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC][PATCH 3/3] Set si_pid to 0 for signals from ancestor
	namespace
Date: Fri, 14 Nov 2008 17:58:09 +0100
Message-ID: <20081114165809.GB7738@redhat.com>
References: <20081112064139.GA27806@us.ibm.com> <20081112064819.GC27806@us.ibm.com> <20081112163339.GD13269@redhat.com> <m1d4h0payv.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753406AbYKNP5l@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1d4h0payv.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Daniel Hokka Zakrisson <daniel@hozac.com>, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 11/12, Eric W. Biederman wrote:
>
> Oleg Nesterov <oleg@redhat.com> writes:
>
> > On 11/11, Sukadev Bhattiprolu wrote:
> >>
> >> +static void set_sigqueue_pid(struct sigqueue *q, struct task_struct *t,
> >> +                           struct pid *sender)
> >> +{
> >> +	struct pid_namespace *ns;
> >> +
> >> +	/* Set si_pid to the pid number of sender in the pid namespace of
> >> +	 * our destination task for all siginfo types that support it.
> >> +	 */
> >> +	switch(q->info.si_code & __SI_MASK) {
> >> +		/* siginfo without si_pid */
> >> +		case __SI_TIMER:
> >> +		case __SI_POLL:
> >> +		case __SI_FAULT:
> >> +			break;
> >> +			/* siginfo with si_pid */
> >> +		case __SI_KILL:
> >> +		case __SI_CHLD:
> >> +		case __SI_RT:
> >> +		case __SI_MESGQ:
> >> +		default:
> >> +			/* si_pid for SI_KERNEL is always 0 */
> >> +			if (q->info.si_code == SI_KERNEL || in_interrupt())
> >> +				break;
> >> +			/* Is current not the sending task? */
> >> +			if (!sender)
> >> +				sender = task_tgid(current);
> >> +			ns = task_active_pid_ns(t);
> >> +			q->info.si_pid = pid_nr_ns(sender, ns);
> >> +			break;
> >> +	}
> >> +}
> >
> > Why, why? Just: if from parent ns - clear .si_pid. No?
>
> We need the switch to know if we are a member of a union that supports
> si_pid.

Please look at http://marc.info/?l=linux-kernel&m=122634217518183

If SIG_FROM_USER is set, we know that .si_pid is "valid".

Yes, yes, yes. sys_rt_sigqueueinfo() is a problem, but in that
case we can't trust .si_code anyway.

> The in_interrupt thing is there simply because current is not
> useable from an interrrupt context, and there are some
> signals that get sent from an interrupt context.

Yes sure. But I don't think this check is enough, see other
emails. And this check is not needed once we have SIG_FROM_USER.

> Oh.  As for the chunk that is:
> ns = task_active_pid_ns(t)
> q->info.si_pid = pid_nr_ns(sender, ns);
>
> If we are sending from a child to a parent namespace.

The notify_parent() case is fine, afaics (again I assume the "patch"
above which sets SIG_FROM_USER).

> The name of the
> child changes.  There is some place F_SETSIG? sigfd?  where we have
> something that resembles the full general case of processes being able
> to send a signal to any other process.

Yes, this needs attention too.

Oleg.
