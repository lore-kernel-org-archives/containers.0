From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFD] Merge task counter into memcg
Date: Wed, 18 Apr 2012 11:12:34 +0200
Message-ID: <20120418091231.GA26594__41298.9654498689$1334740376$gmane$org@somewhere>
References: <20120412153055.GL1787@cmpxchg.org>
	<20120412163825.GB13069@google.com>
	<20120412172309.GM1787@cmpxchg.org>
	<20120412174155.GC13069@google.com> <4F878480.60505@jp.fujitsu.com>
	<20120417154117.GE32402@google.com>
	<4F8D9FC4.3080800@parallels.com> <4F8E646B.1020807@jp.fujitsu.com>
	<CAFTL4hw3C4s6VS07pJzdBawv0ugKJJa+Vnb-Q_9FrWEq4=ka9Q@mail.gmail.com>
	<4F8E7E76.3020202@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F8E7E76.3020202-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Apr 18, 2012 at 05:42:30PM +0900, KAMEZAWA Hiroyuki wrote:
> (2012/04/18 16:53), Frederic Weisbecker wrote:
> 
> > 2012/4/18 KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>:
> >> (2012/04/18 1:52), Glauber Costa wrote:
> >>
> >>>
> >>>>> In short, I don't think it's better to have task-counting and fd-counting in memcg.
> >>>>> It's kmem, but it's more than that, I think.
> >>>>> Please provide subsys like ulimit.
> >>>>
> >>>> So, you think that while kmem would be enough to prevent fork-bombs,
> >>>> it would still make sense to limit in more traditional ways
> >>>> (ie. ulimit style object limits).  Hmmm....
> >>>>
> >>>
> >>> I personally think this is namespaces business, not cgroups.
> >>> If you have a process namespace, an interface that works to limit the
> >>> number of processes should keep working given the constraints you are
> >>> given.
> >>>
> >>> What doesn't make sense, is to create a *new* interface to limit
> >>> something that doesn't really need to be limited, just because you
> >>> limited a similar resource before.
> >>>
> >>
> >>
> >> Ok, limitiing forkbomb is unnecessary. ulimit+namespace should work.
> >> What we need is user-id namespace, isn't it ? If we have that, ulimit
> >> works enough fine, no overheads.
> > 
> > I have considered using NR_PROC rlimit on top of user namespaces to
> > fight forkbombs inside a container.
> > ie: one user namespace per container with its own rlimit.
> > 
> > But it doesn't work because we can have multiuser apps running in a
> > single container.
> > 
> 
> Ok, then, requirements is different from ulimit. ok, please forget my words.
> 
> My concern for using 'kmem' is that size of object can be changed, and set up
> may be more complicated than limiting 'number' of tasks.
> It's very architecture dependent....But hmm... 

Sure. But I believe the user can easily cope with that. One just need
to create a cgroup, move a task there and look at the accounted kmem.kernel_stack
to get the size used by one task.

That's less intuitive for the user than a task counter of course. But that
may be more generally useful than just forkbomb protection. At least I hope
because I haven't heard about other possible usecases.

> 
> If slab accounting can handle task_struct accounting, all you wants can be
> done by it (maybe). And implementation can be duplicated.
> (But another aspect of the problem will be speed of development..)
> 
> One idea is (I'm not sure good or bad)...having following control files.
> 
>  - memory.kmem.task_struct.limit_in_bytes
>  - memory.kmem.task_struct.usage_in_bytes
>  - memory.kmem.task_struct.size_in_bytes   # size of task struct.

I'm fine either way. Counting task_struct memory usage is also a way
to count the tasks for me. But is it going to be more generally useful
than counting kernel stack?

> 
> At 1st, implement this by accounting task struct(or some) directly.
> Later, if we can, replace the implementation with slab(kmem) cgroup..
> and unify interfaces.....a long way to go.
> 
> 2nd idea is
> 
>  - memory.object.task.limit_in_number	# limit the number of tasks.
>  - memory.object.task.usage_in_number   # usage
> 
> 
> If I'm a user, I prefer #2.

People seem to object on defining the number of task as a relevant unit of resource.
It's indeed a semantic resource on top of the more lower level one memory resource
(could be CPU as well).

And if it can be mapped back to memory resource, it might be more generally
useful to limit at that level.

At least I hope...

> 
> Hmm, 
>    global kmem limiting           -> done by bytes.
>    special kernel object limiting -> done by the number of objects.
> 
> is...complicated ?
> 
> Thanks,
> -Kame
> 
