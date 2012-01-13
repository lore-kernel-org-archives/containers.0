From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Q: cgroup: Questions about possible issues in cgroup locking
Date: Fri, 13 Jan 2012 16:20:10 +0100
Message-ID: <20120113152010.GA19215@redhat.com>
References: <20111221192413.GF13529@google.com>
	<20111221200422.GJ17668@somewhere>
	<20111222153004.GA30522@redhat.com>
	<20120104193614.GF9511@google.com>
	<20120106152356.GA23995@redhat.com>
	<20120106182535.GJ9511@google.com>
	<20120111160730.GA24556@redhat.com>
	<20120112003102.GB9511@google.com>
	<20120112170728.GA25717@redhat.com>
	<20120112175725.GD9511@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120112175725.GD9511-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 01/12, Mandeep Singh Baines wrote:
>
> Oleg Nesterov (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org) wrote:
> >
> > Still can't understand... Lets look at this trivial example again.
> >
> > We start from the main thread M, it is ->group_leader. There is
> > another thread T in this thread group. We are doing
> >
> > 	OLD = M;
> >
> > 	t = M;
> > 	do {
> > 		do_smth(t);
> > 	}
> > 	while (t->group_leader == OLD && ((t = next_thread(t)) != M);
> >
> > The first iteration does do_smth(M).
> >
> > T calls de_thread() and, in particular, it does M->group_leader = T
> > (see "leader->group_leader = tsk" in de_thread).
> >
> > after that t->group_leader == OLD fails. t == M, its group_leader == T.
> > do_smth(T) won't be called.
> >
> > No?
> >
>
> I think we can handle this by removing the assignment. So in de_thread():
>
> -		leader->group_leader = tsk;

Ah, so that was you plan. I was confused by the 3rd argument, why
it is needed?

Yes, I thought about this too. Suppose we remove this assignment,
then we can simply do

	#define while_each_thread(g, t) \
		while (t->group_leader == g->group_leader && (t = next_thread(t)) != g)

with the same effect. (to remind, currently I ignore the barriers/etc).

But this can _only_ help if we start at the group leader!

May be we should enforce this rule (for the lockless case), I dunno...
In that case I'd prefer to add the new while_each_thread_rcu() helper.
But! in this case we do not need to change de_thread(), we can simply do

	#define while_each_thread_rcu(t) \
		while (({ t = next_thread(t); !thread_group_leader(t); }))

The definition above was one of the possibilities I considered, but
I wasn't able to convince myself this is the best option.

See? Or do you think I missed something?

Just in case... note that while_each_thread_rcu() doesn't use 'g'
at all. May be it makes sense to keep the old "t != g &&", but this
is minor.

Oleg.
