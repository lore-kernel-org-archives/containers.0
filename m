From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH pm-freezer 3/4] freezer: check freezing() before
	leaving FROZEN state
Date: Mon, 29 Aug 2011 19:12:28 +0200
Message-ID: <20110829171228.GA11339__12947.8462659337$1314638349$gmane$org@redhat.com>
References: <20110829140418.GB18871@mtj.dyndns.org>
	<20110829140509.GC18871@mtj.dyndns.org>
	<20110829140549.GD18871@mtj.dyndns.org>
	<20110829163533.GB9973@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110829163533.GB9973-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/29, Oleg Nesterov wrote:
>
> On 08/29, Tejun Heo wrote:
> >
> > --- work.orig/kernel/freezer.c
> > +++ work/kernel/freezer.c
> > @@ -60,6 +60,7 @@ bool __refrigerator(bool check_kthr_stop
> >  	 */
> >  	spin_lock_irq(&freezer_lock);
> >  	current->flags |= PF_FROZEN;
> > +refreeze:
> >  	spin_unlock_irq(&freezer_lock);
> >
> >  	save = current->state;
> > @@ -78,8 +79,10 @@ bool __refrigerator(bool check_kthr_stop
> >  		schedule();
> >  	}
> >
> > -	/* leave FROZEN */
> > +	/* leave FROZEN after checking freezing() holding freezer_lock */
> >  	spin_lock_irq(&freezer_lock);
> > +	if (freezing(current))
> > +		goto refreeze;
>
> Looks like, you should move "save = current->state" up then.

Hmm. And afaics there is another problem. This can "livelock" if
check_kthr_stop && kthread_should_stop().

May be we should consolidate the freezer_lock's sections, something
like below?

Hmm. But I got lost a bit. Why do we need freezer_lock to set/clear
PF_FROZEN ? OK, the code below takes freezer_lock for freezing().
Is there any other reason?

Oleg.

bool __refrigerator(bool check_kthr_stop)
{
	/* Hmm, should we be allowed to suspend when there are realtime
	   processes around? */
	bool was_frozen = false;
	long save;

	save = current->state;
	pr_debug("%s entered refrigerator\n", current->comm);

	for (;;) {
		set_current_state(TASK_UNINTERRUPTIBLE);

		spin_lock_irq(&freezer_lock);
		current->flags |= PF_FROZEN;
		if (!freezing(current) ||
		    (check_kthr_stop && kthread_should_stop()))
			current->flags &= ~PF_FROZEN;
		spin_unlock_irq(&freezer_lock);

		if (!current->flags & PF_FROZEN)
			break;

		was_frozen = true;
		schedule();
	}

	spin_lock_irq(&current->sighand->siglock);
	recalc_sigpending(); /* We sent fake signal, clean it up */
	spin_unlock_irq(&current->sighand->siglock);

	pr_debug("%s left refrigerator\n", current->comm);
	/*
	 * Restore saved task state before returning.  The mb'd version
	 * needs to be used; otherwise, it might silently break
	 * synchronization which depends on ordered task state change.
	 */
	set_current_state(save);

	return was_frozen;
}
