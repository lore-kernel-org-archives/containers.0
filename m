From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Q: cgroup: Questions about possible issues in cgroup locking
Date: Wed, 11 Jan 2012 17:07:30 +0100
Message-ID: <20120111160730.GA24556@redhat.com>
References: <20111221130848.GA19679@redhat.com>
	<20111221175632.GF17668@somewhere>
	<20111221190102.GE13529@google.com>
	<20111221190817.GI17668@somewhere>
	<20111221192413.GF13529@google.com>
	<20111221200422.GJ17668@somewhere>
	<20111222153004.GA30522@redhat.com>
	<20120104193614.GF9511@google.com>
	<20120106152356.GA23995@redhat.com>
	<20120106182535.GJ9511@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120106182535.GJ9511-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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

On 01/06, Mandeep Singh Baines wrote:
>
> Oleg Nesterov (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org) wrote:
> >
> > > > in particular, http://marc.info/?l=linux-kernel&m=127714242731448
> > > > I think this should work, but then we should do something with the
> > > > users like zap_threads().
> > > >
> > >
> > > With that patch, won't you potentially miss the exec thread if an exec
> > > occurs while you're iterating over the list? Is that OK?
> >
> > Of course it is not OK ;) Note the "we should do something with" above.
> >
>
> So requirements should be something like this:

(I assume, you mean the lockless case)

> * Any task alive for the duration of the iteration MUST be visited
> * No task should be visited more than once
> * Any task born or exiting after starting the iteration MAY be skipped
> * You can start at any task in the thread group

Well yes, but it is not easy to exactly define what after/before
means in this case.

> Would something like this work:
>
> #define while_each_thread(g, t, o) \
> 	while (t->group_leader == o && (t = next_thread(t)) != g)
>
> Where o should have the value of g->group_leader.

I don't understand how this helps... and how this can work even
ignoring the barriers.

OK, we have the main thream M and the sub-thread T, we are doing

	do {
		do_something(t);
	} while_each_thread(M, t, M);

why we can't miss T if it does exec?

Oleg.
