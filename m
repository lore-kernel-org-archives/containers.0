From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [RFC] [PATCH 1/2] cgroups: read-write lock CLONE_THREAD
	forking per threadgroup
Date: Sun, 17 Jan 2010 15:48:33 -0500
Message-ID: <20100117204833.GA29596@unix38.andrew.cmu.edu>
References: <200908202114.n7KLEN5H026646@imap1.linux-foundation.org>
	<20090821102611.GA2611@redhat.com>
	<20090821104528.GA3487@redhat.com>
	<6599ad830908211637w6c9fd3a7tbe41bc106ada03d7@mail.gmail.com>
	<20090822130952.GA4240@redhat.com>
	<20100105185330.GA17545@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100105185330.GA17545-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jan 05, 2010 at 07:53:30PM +0100, Oleg Nesterov wrote:
> On 01/03, Ben Blum wrote:
> >
> > Adds functionality to read/write lock CLONE_THREAD fork()ing per-threadgroup
> 
> I didn't actually read this series, but at first glance it still has
> problems...
> 
> > +struct sighand_struct *threadgroup_fork_lock(struct task_struct *tsk)
> 
> static?

sure, though in the end this is perhaps not the best place for the
function anyway. in fact, this function only does half of the job, so
a good amount of refactoring might be in order.

> 
> > +{
> > +	struct sighand_struct *sighand;
> > +	struct task_struct *p;
> > +
> > +	/* tasklist lock protects sighand_struct's disappearance in exit(). */
> > +	read_lock(&tasklist_lock);
> > +
> > +	/* make sure the threadgroup's state is sane before we proceed */
> > +	if (unlikely(!thread_group_leader(tsk))) {
> > +		/* a race with de_thread() stripped us of our leadership */
> > +		read_unlock(&tasklist_lock);
> > +		return ERR_PTR(-EAGAIN);
> 
> I don't understand how this can close the race with de_thread().
> 
> Suppose this tsk is the new leader, after de_thread() changed ->group_leader
> and dropped tasklist_lock.
> 
> threadgroup_fork_lock() bumps sighand->count
> 
> de_thread() continues, notices oldsighand->count != 1 and switches
> to the new ->sighand.
> 
> After that tsk can spawn other threads, but cgroup_fork() will use
> newsighand->threadgroup_fork_lock while cgroup_attach_proc() relies
> on oldsighand->threadgroup_fork_lock.

the race with the sighand is handled in the next patch, in attach_proc,
not in this function. this check is just to make sure that the list is
safe to iterate over, since de_thread changing group leadership could
ruin that. so in the end, there are two places where EAGAIN can happen -
one here, and one later (in the second patch).

> 
> > +	/* now try to find a sighand */
> > +	if (likely(tsk->sighand)) {
> > +		sighand = tsk->sighand;
> > +	} else {
> > +		sighand = ERR_PTR(-ESRCH);
> > +		/*
> > +		 * tsk is exiting; try to find another thread in the group
> > +		 * whose sighand pointer is still alive.
> > +		 */
> > +		list_for_each_entry_rcu(p, &tsk->thread_group, thread_group) {
> > +			if (p->sighand) {
> > +				sighand = tsk->sighand;
> 
> can't understand this "else {}" code... We hold tasklist, if the group
> leader is dead (->sighand == NULL), then the whole thread group is
> dead.
> 
> Even if we had another thread with ->sighand != NULL, what is the point
> of "if (unlikely(!thread_group_leader(tsk)))" check then?

doesn't the group leader stay on the threadgroup list even when it dies?
sighand can be null if the group leader has exited, but other threads
are still running.

> 
> Oleg.
> 

hope that makes more sense. I'd like to have the code between these two
patches refactored, but first want to make sure it's correct.

-- bblum
