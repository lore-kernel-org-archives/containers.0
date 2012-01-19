From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Q: cgroup: Questions about possible issues in cgroup locking
Date: Thu, 19 Jan 2012 16:45:22 +0100
Message-ID: <20120119154522.GA14058__2711.33578285134$1326988316$gmane$org@redhat.com>
References: <20120106152356.GA23995@redhat.com>
	<20120106182535.GJ9511@google.com>
	<20120111160730.GA24556@redhat.com>
	<20120112003102.GB9511@google.com>
	<20120112170728.GA25717@redhat.com>
	<20120112175725.GD9511@google.com>
	<20120113152010.GA19215@redhat.com>
	<20120113182750.GD18166@google.com>
	<20120114173648.GA32543@redhat.com>
	<20120118231742.GS18166@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120118231742.GS18166-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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

On 01/18, Mandeep Singh Baines wrote:
>
> Oleg Nesterov (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org) wrote:
> > On 01/13, Mandeep Singh Baines wrote:
> > >
> > > Case 3: g is some other thread
> > >
> > > In this case, g MUST be current
> >
> > Why? This is not true.
>
> Here is my thinking:
>
> The terminating condition, t != g, assumes that you can get back to
> g. If g is unhashed, there is no guarantee you'll ever get back to it.
> Holding a reference does not prevent unhashing.
>
> for_each_process avoids unhashing by starting and ending at init_task
> (which can never be unhashed).

Yes,

> As you pointed out a while back, this doesn't work for:
>
> do_each_thread(g, t){
>   do_something(t);
> } while_each_thread(g, t)
>
> because g can be unhashed.
>
> However, you should be able to use while_each_thread if you are current.
> Being current would prevent 'g' from being unhashed.

Ah, I misunderstood you. Yes, sure.

> other than, do_each_thread/while_each_thread, all other callers
> of while_each_thread() are starting at current. Otherwise, how do
> you guarantee that it terminates.

Hm, still can't understand...

> I see at least one example, coredump_wait() that uses while_each_thread
> starting at current. I didn't find any cases where while_each_thread
> starts anywhere other than current or group_leader.

Probably you meant zap_threads/zap_process, not coredump_wait?

zap_process() is fine, we hold ->siglock. But zap_threads does _not_
start at current, may be you misread the g == tsk->group_leader check
in the main for_each_process() loop ? But most probably we simply
misunderstand each other a bit, see below.

However it starts at ->group_leader, so it won't suffer if we restrict
the lockless while_each_thread_rcu().

> > But I guess this doesn't matter, I think I am
> > starting to understand why our discussion was a bit confusing.
> >
> > The problem is _not_ exec/de_thread by itself. The problem is that
> > while_each_thread(g, t) can race with removing 'g' from the list.
> > IOW, list_for_each_rcu-like things assume that the head of the list
> > is "stable" but this is not true.
> >
> > And note that de_thread() does not matter in this sense, only
> > __unhash_process()->list_del_rcu(&p->thread_group) does matter.
> >
> > Now. If 'g' is the group leader, we should only worry about exec,
> > otherwise it can't disappear before other threads.
> >
> > But if it is not the group leader, it can simply exit and
> > while_each_thread(g, t) can never stop by the same reason.
> >
>
> I think we are on the same page. Your explanation is consistent with
> my understanding.
>
> Some other thoughts:
>
> I suspect that other than do_each_thread()/while_each_thread() or
> for_each_thread()/while_each_thread() where 'g' is the group_leader,
> 'g' MUST be current. So the only cases to consider are:

I didn't try to grep, but I do not know any example of the lockless
while_each_thread() which starts at current.

I guess this is the source of confusion.

> > I'll try to recheck my thinking once again, what do you think? Anything
> > else we could miss?
>
> Yeah, the ->group_leader solution seems the most promising. It seems
> correct (ignoring barriers) and should work for all supported cases:
>
> 1) when g is group_leader
> 2) when g is current

OK, thanks.

I'll try to investigate if we can remove

	leader->group_leader = tsk;

from de_thread(). In fact I already thought about this change a long
ago without any connection to while_each_thread(). This assignment
looks "assymetrical" compared to other threads we kill. But we did
have a reason (reasons?). Hopefully, the only really important reason
was already removed by 087806b1.

Oleg.
