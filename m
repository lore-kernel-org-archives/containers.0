From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Q: cgroup: Questions about possible issues in cgroup locking
Date: Fri, 23 Mar 2012 18:51:57 +0100
Message-ID: <20120323175157.GA20675__23488.686027895$1332525588$gmane$org@redhat.com>
References: <20120112003102.GB9511@google.com>
	<20120112170728.GA25717@redhat.com>
	<20120112175725.GD9511@google.com>
	<20120113152010.GA19215@redhat.com>
	<20120113182750.GD18166@google.com>
	<20120114173648.GA32543@redhat.com>
	<20120118231742.GS18166@google.com>
	<20120119154522.GA14058@redhat.com>
	<20120320193414.GA21277@redhat.com>
	<20120321185955.GK27051@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120321185955.GK27051-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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

On 03/21, Mandeep Singh Baines wrote:
>
> Oleg Nesterov (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org) wrote:
> > +/*
> > + * rcu-safe, but should start at ->group_leader.
> > + * thread_group_leader(g) protects against the race with exec which
> > + * removes the leader from list.
> > + * smp_rmb() pairs with implicit mb() implied by unlock + lock in
> > + * de_thread()->release_task() path.
> > + */
> > +#define while_each_thread_rcu(g, t)				\
> > +	while ((t = next_thread(t)) != g &&			\
> > +		({ smp_rmb(); thread_group_leader(g); }))
> > +
>
> Couldn't you miss the exec_thread if:
>
> t = exec_thread && !thread_group_leader(g)

Yes, we already discussed this, iirc.

I was going to write that this is fine, but then I changed my mind.
Indeed, it is not good while_each_thread_rcu() can miss the new leader.

> Could we change do_prlimit()? Especially since its slow path.

But do_prlimit() is correct. It sees the unhashed task under tasklist,
task->group_leader should be correct.

> I really like you're earlier solution (ignoring barrier):
>
> #define while_each_thread(g, t) \
> 	while (t->group_leader == g->group_leader && (t = next_thread(t)) != g)

The problem is "ignoring barrier and races".

OK, I'll try to think again.

Oleg.
