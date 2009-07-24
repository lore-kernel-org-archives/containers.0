From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/6] Makes procs file writable to move all threads by
	tgid at once
Date: Fri, 24 Jul 2009 14:06:57 -0700
Message-ID: <20090724210657.GL5878__7379.84332158721$1248469753$gmane$org@count0.beaverton.ibm.com>
References: <20090724032033.2463.79256.stgit@hastromil.mtv.corp.google.com>
	<20090724032200.2463.82408.stgit@hastromil.mtv.corp.google.com>
	<20090724155041.GF5878@count0.beaverton.ibm.com>
	<6599ad830907240901w4fc02097k83d0c1012708e6ee@mail.gmail.com>
	<20090724172320.GH5878@count0.beaverton.ibm.com>
	<6599ad830907241047w9a9fff9q4dc68f26a9544398@mail.gmail.com>
	<2f86c2480907241353l63818dfehb20c9d4918a3f069@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2f86c2480907241353l63818dfehb20c9d4918a3f069-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jul 24, 2009 at 01:53:53PM -0700, Benjamin Blum wrote:
> On Fri, Jul 24, 2009 at 1:47 PM, Paul Menage<menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> > On Fri, Jul 24, 2009 at 10:23 AM, Matt Helsley<matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> >>
> >> Well, I imagine holding tasklist_lock is worse than cgroup_mutex in some
> >> ways since it's used even more widely. Makes sense not to use it here..
> >
> > Just to clarify - the new "procs" code doesn't use cgroup_mutex for
> > its critical section, it uses a new cgroup_fork_mutex, which is only
> > taken for write during cgroup_proc_attach() (after all setup has been
> > done, to ensure that no new threads are created while we're updating
> > all the existing threads). So in general there'll be zero contention
> > on this lock - the cost will be the cache misses due to the rwlock
> > bouncing between the different CPUs that are taking it in read mode.
> 
> Right. The different options so far are:
> 
> Global rwsem: only needs one lock, but prevents all forking when a
> write is in progress. It should be quick enough, if it's just "iterate
> down the threadgroup list in O(n)". In the good case, fork() slows
> down by a cache miss when taking the lock in read mode.

I noticed your point about only one process contending for write on
the new semaphore since cgroup_mutex is also held on the write side.
However won't there be cacheline bouncing as lots of readers contend not
for the read side of the lock itself but the cacheline needed to take it?

> Threadgroup-local rwsem: Needs adding a field to task_struct. Only
> forks within the same threadgroup would block on a write to the procs
> file, and the zero-contention case is the same as before.

This seems like it would be better.

> Using tasklist_lock: Currently, the call to cgroup_fork() (which
> starts the race) is very far above where tasklist_lock is taken in
> fork, so taking tasklist_lock earlier is very infeasible. Could
> cgroup_fork() be moved downwards to inside it, and if so, how much
> restructuring would be needed? Even if so, this still adds stuff that
> is being done (unnecessarily) while holding a global mutex.

Yup.

> > What happened to the big-reader lock concept from 2.4.x? That would be
> > applicable here - minimizing the overhead on the critical path when
> > the write operation is expected to be very rare.

Supplanted by RCU perhaps? *shrug*

Cheers,
	-Matt Helsley
