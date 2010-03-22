From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH 1/2] cgroups: read-write lock CLONE_THREAD
	forking per threadgroup
Date: Mon, 22 Mar 2010 11:22:47 +0100
Message-ID: <20100322102247.GA8363__46118.4156979018$1269253521$gmane$org@redhat.com>
References: <200908202114.n7KLEN5H026646@imap1.linux-foundation.org>
	<20090821102611.GA2611@redhat.com>
	<20090821104528.GA3487@redhat.com>
	<6599ad830908211637w6c9fd3a7tbe41bc106ada03d7@mail.gmail.com>
	<20090822130952.GA4240@redhat.com>
	<20100105185330.GA17545@redhat.com>
	<20100117204833.GA29596@unix38.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100117204833.GA29596-DC+BO+AtSRVCM1neWV3AGuCmf2DRS9x2@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On 01/17, Ben Blum wrote:
>
> On Tue, Jan 05, 2010 at 07:53:30PM +0100, Oleg Nesterov wrote:
> >
> > I don't understand how this can close the race with de_thread().
> > ...
>
> the race with the sighand is handled in the next patch, in attach_proc,
> not in this function.

OK. I didn't verify this, the patches don't apply to 2.6.32-rc, but this
doesn't matter. Please see below.

> > > +	/* now try to find a sighand */
> > > +	if (likely(tsk->sighand)) {
> > > +		sighand = tsk->sighand;
> > > +	} else {
> > > +		sighand = ERR_PTR(-ESRCH);
> > > +		/*
> > > +		 * tsk is exiting; try to find another thread in the group
> > > +		 * whose sighand pointer is still alive.
> > > +		 */
> > > +		list_for_each_entry_rcu(p, &tsk->thread_group, thread_group) {
> > > +			if (p->sighand) {
> > > +				sighand = tsk->sighand;
> >
> > can't understand this "else {}" code... We hold tasklist, if the group
> > leader is dead (->sighand == NULL), then the whole thread group is
> > dead.
> >
> > Even if we had another thread with ->sighand != NULL, what is the point
> > of "if (unlikely(!thread_group_leader(tsk)))" check then?
>
> doesn't the group leader stay on the threadgroup list even when it dies?
> sighand can be null if the group leader has exited, but other threads
> are still running.

No, leader->sighand != NULL until all threads have exited.


Ben, I'd suggest you to redo these patches even if they are correct.
->sighand is not the right place for the mutex/locking

	- it is per CLONE_SIGHAND, not per process

	- we have to avoid the nasty and hard-to-test races with exec

	- we have to play with sighand->count and I really dislike this.
	  this ->count is not just a reference counter, look at
	  unshare_sighand(). Yes, this is fake, but still.

Please use ->signal instead. By the lucky coincidence the lifetime rules
for (greatly misnamed) signal_struct were changed recently in -mm.

With the recent changes, it is always safe to use task->signal. It can't
be changed, can't go away, no need to bump the counter, no races, etc.

What do you think?

Oleg.
