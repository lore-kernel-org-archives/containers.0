From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: Q: cgroup: Questions about possible issues in cgroup locking
Date: Wed, 18 Jan 2012 15:17:43 -0800
Message-ID: <20120118231742.GS18166__2383.26519397578$1326928689$gmane$org@google.com>
References: <20120104193614.GF9511@google.com>
	<20120106152356.GA23995@redhat.com>
	<20120106182535.GJ9511@google.com>
	<20120111160730.GA24556@redhat.com>
	<20120112003102.GB9511@google.com>
	<20120112170728.GA25717@redhat.com>
	<20120112175725.GD9511@google.com>
	<20120113152010.GA19215@redhat.com>
	<20120113182750.GD18166@google.com>
	<20120114173648.GA32543@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120114173648.GA32543-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
> On 01/13, Mandeep Singh Baines wrote:
> >
> > Oleg Nesterov (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org) wrote:
> >
> > > Yes, I thought about this too. Suppose we remove this assignment,
> > > then we can simply do
> > >
> > > 	#define while_each_thread(g, t) \
> > > 		while (t->group_leader == g->group_leader && (t = next_thread(t)) != g)
> > >
> > > with the same effect. (to remind, currently I ignore the barriers/etc).
> > >
> >
> > Nice! I think this works.
> >
> > > But this can _only_ help if we start at the group leader!
> >
> > But I don't think this solution requires we start at the group leader.
> >
> > My thinking:
> >
> > Case 1: g is the exec thread
> > ...
> > Case 2: g is the group leader
> > ...
> > Case 3: g is some other thread
> >
> > In this case, g MUST be current
> 
> Why? This is not true.

Here is my thinking:

The terminating condition, t != g, assumes that you can get back to
g. If g is unhashed, there is no guarantee you'll ever get back to it.
Holding a reference does not prevent unhashing.

for_each_process avoids unhashing by starting and ending at init_task
(which can never be unhashed).

As you pointed out a while back, this doesn't work for:

do_each_thread(g, t){
  do_something(t);
} while_each_thread(g, t)

because g can be unhashed.

However, you should be able to use while_each_thread if you are current.
Being current would prevent 'g' from being unhashed. I can think of no
other way of preventing 'g' from being unhashed. So I suspect that,
other than, do_each_thread/while_each_thread, all other callers
of while_each_thread() are starting at current. Otherwise, how do
you guarantee that it terminates.

I see at least one example, coredump_wait() that uses while_each_thread
starting at current. I didn't find any cases where while_each_thread
starts anywhere other than current or group_leader.

> But I guess this doesn't matter, I think I am
> starting to understand why our discussion was a bit confusing.
> 
> The problem is _not_ exec/de_thread by itself. The problem is that
> while_each_thread(g, t) can race with removing 'g' from the list.
> IOW, list_for_each_rcu-like things assume that the head of the list
> is "stable" but this is not true.
> 
> And note that de_thread() does not matter in this sense, only
> __unhash_process()->list_del_rcu(&p->thread_group) does matter.
> 
> Now. If 'g' is the group leader, we should only worry about exec,
> otherwise it can't disappear before other threads.
> 
> But if it is not the group leader, it can simply exit and
> while_each_thread(g, t) can never stop by the same reason.
> 

I think we are on the same page. Your explanation is consistent with
my understanding.

Some other thoughts:

I suspect that other than do_each_thread()/while_each_thread() or
for_each_thread()/while_each_thread() where 'g' is the group_leader,
'g' MUST be current. So the only cases to consider are:

1) g is the group_leader: only exec is important for the reasons
   you specify (it can't disappear before other threads)
2) g is current: no worries. it can't disappear

> And we can't detect this case. OK, OK, we can, let me remind
> about http://marc.info/?l=linux-kernel&m=127714242731448 and the
> whole discussion. But this makes while_each_thread() more complex
> and this doesn't fork for zap_threads-like users which must not
> miss the "interesing" threads.
> 

This URL is blacked out today.

> Finally. If we restrict the lockless while_each_thread() so that
> is starts at the group leader, then we can rely on de_thread()
> which changes the leadership and try to detect this case.
> 
> See?
> 
> > > May be we should enforce this rule (for the lockless case), I dunno...
> > > In that case I'd prefer to add the new while_each_thread_rcu() helper.
> > > But! in this case we do not need to change de_thread(), we can simply do
> > >
> > > 	#define while_each_thread_rcu(t) \
> > > 		while (({ t = next_thread(t); !thread_group_leader(t); }))
> > >
> >
> > Won't this terminate just before visiting the exec thread?
> 
> Sure. But this is fine for zap_threads() or current_is_single_threaded(),
> the execing thread already has another ->mm. Just we shouldn't hang
> forever if we race with exec (we start at the group leader).
> 
> And I hope this is fine in general (to remind, in the lockless case).
> If we race with exec we see either the old or the new leader with the
> same pid/signal/etc (at least).
> 
> Hmm. On a second thought, perhaps I thought to much about zap_threads(),
> perhaps it would be better to find all threads we can...
> 
> I dunno. But I am starting to like the ->group_leader more. Hmm, and
> with thread_group_leader() check we should ensure we do not visit the
> old leader twice.
> 

Ah. Yes. You could potentially visit the old group_leader twice if you
have exec'ed and have already visited the exec thread. You'd visit the
old group_leader again  because thread_group_leader(t) would no longer be
true for the old group_leader. Worse yet, you'd visit it again and just
keep on going.

> Thanks Mandeep.
> 
> I'll try to recheck my thinking once again, what do you think? Anything
> else we could miss?
> 

Yeah, the ->group_leader solution seems the most promising. It seems
correct (ignoring barriers) and should work for all supported cases:

1) when g is group_leader
2) when g is current

Regards,
Mandeep

> Oleg.
> 
