From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: Q: cgroup: Questions about possible issues in cgroup locking
Date: Wed, 4 Jan 2012 11:36:14 -0800
Message-ID: <20120104193614.GF9511__11186.3577775241$1325705808$gmane$org@google.com>
References: <20111221034334.GD17668@somewhere>
	<20111221130848.GA19679@redhat.com>
	<20111221175632.GF17668@somewhere>
	<20111221190102.GE13529@google.com>
	<20111221190817.GI17668@somewhere>
	<20111221192413.GF13529@google.com>
	<20111221200422.GJ17668@somewhere>
	<20111222153004.GA30522@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111222153004.GA30522-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org) wrote:
> On 12/21, Frederic Weisbecker wrote:
> >
> > On Wed, Dec 21, 2011 at 11:24:13AM -0800, Mandeep Singh Baines wrote:
> > >
> > > If you call exec from a thread other than g, g is now unlinked. So
> > > "t != g" will always be true. If you then pthread_create, you now
> > > have two threads so "t != __prev" will also always be true. So
> > > you now have an infinite loop.
> >
> > Oh you're right.
> >
> > But then we can't use t != t->group_leader because that assumes while_each_thread()
> > started on the leader.
> 
> Yes, this can't work.
> 
> Besides, we need more burriers to rely on the ->group_leader check.
> 
> See http://marc.info/?t=127688987300002
> 

I went through the thread. Were there any other concerns other than
requiring that you start with the group_leader and the barrier?

You could modify zap_other_threads to start with the group leader by
skipping p:

if (p == t)
   continue;

> in particular, http://marc.info/?l=linux-kernel&m=127714242731448
> I think this should work, but then we should do something with the
> users like zap_threads().
> 

With that patch, won't you potentially miss the exec thread if an exec
occurs while you're iterating over the list? Is that OK?

Regards,
Mandeep

> Oleg.
> 
