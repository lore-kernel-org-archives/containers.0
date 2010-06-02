From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH 2/2] cgroups: make procs file writable
Date: Wed, 2 Jun 2010 23:38:33 +0200
Message-ID: <20100602213832.GB31949__9671.70095905221$1275514842$gmane$org@redhat.com>
References: <20100530013303.GC762@ghc01.ghc.andrew.cmu.edu>
	<20100531175242.GA14691@redhat.com>
	<20100531180446.GA16249@redhat.com>
	<AANLkTimcrX0TjzDMNJdubR92pAO4IPATbVpyvvVt0qIV@mail.gmail.com>
	<20100602140659.GA5324@redhat.com>
	<AANLkTin-T6ij3xf0ceGoCamwcoayxyf0GdAKY6yXDMVl@mail.gmail.com>
	<20100602202048.GB28663@redhat.com>
	<AANLkTimrJFiidM8BlUNvmzfapUAv8369R9PYnTscasEf@mail.gmail.com>
	<20100602205855.GA30039@redhat.com>
	<AANLkTimfHlapl7mbRyAazWW5q5Wzs23n6i9wIhVtSv6r@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimfHlapl7mbRyAazWW5q5Wzs23n6i9wIhVtSv6r-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On 06/02, Paul Menage wrote:
>
> On Wed, Jun 2, 2010 at 1:58 PM, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >> The "it" that you're proposing to remove is in fact the code that
> >> handles those races.
> >
> > In that case I confused, and I thought we already agreed that
> > the PF_EXITING check in attach_task_by_pid() is not strictly needed
> > for correctness.
>
> Not quite - something is required for correctness, and the PF_EXITING
> check provides that correctness, with a very small window (between
> setting PF_EXITING and calling cgroup_exit) where we might arguably
> have been able to move the thread but decline to do so because it's
> simpler not to do so and no-one cares. That's the optimization that I
> meant - the data structures are slightly simpler since there's no way
> to tell when a task has passed cgroup_exit(), and instead we just see
> if they've passed PF_EXITING.
>
> >
> > Once again, the task can call do_exit() and set PF_EXITING right
> > after the check.
>
> Yes, the important part is that they haven't set it *before* the check
> in attach_task_by_pid(). If they have set it before that, then they
> could be anywhere in the exit path after PF_EXITING, and we decline to
> move them since it's possible that they've already passed
> cgroup_exit(). If the exiting task has not yet set PF_EXITING, then it
> can't possibly get into the critical section in cgroup_exit() since
> attach_task_by_pid() holds task->alloc_lock.

It doesn't ? At least in Linus's tree.

cgroup_attach_task() does, and this time PF_EXITING is understandable.

Oleg.
