From: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Subject: Re: v2.6.26-rc7/cgroups: circular locking dependency
Date: Mon, 23 Jun 2008 07:02:23 -0500
Message-ID: <20080623070223.eaa8e130.pj__19543.803871102$1214222833$gmane$org@sgi.com>
References: <20080621173859.GA6846@damson.getinternet.no>
	<2f11576a0806220834m3572ee80i72229cb9a1613558@mail.gmail.com>
	<1214149823.3223.313.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1214149823.3223.313.camel-N9Ixq/CQ5vKdTX5a5knrm8zTDFooKrT+cvkQGrU6aU0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Cc: kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org, vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, maxk-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

CC'd Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>.

I believe that we had the locking relation between what had been
cgroup_lock (global cgroup lock which can be held over large stretches
of non-performance critical code) and callback_mutex (global cpuset
specific lock which is held over shorter stretches of more performance
critical code - though still not on really hot code paths.)  One can
nest callback_mutex inside cgroup_lock, but not vice versa.

The callback_mutex guarded some CPU masks and Node masks, which might
be multi-word and hence don't change atomically.  Any low level code
that needs to read these these cpuset CPU and Node masks, needs to
hold callback_mutex briefly, to keep that mask from changing while
being read.

There is even a comment in kernel/cpuset.c, explaining how an ABBA
deadlock must be avoided when calling rebuild_sched_domains():

/*
 * rebuild_sched_domains()
 *
 * ...
 *
 * Call with cgroup_mutex held.  May take callback_mutex during
 * call due to the kfifo_alloc() and kmalloc() calls.  May nest
 * a call to the get_online_cpus()/put_online_cpus() pair.
 * Must not be called holding callback_mutex, because we must not
 * call get_online_cpus() while holding callback_mutex.  Elsewhere
 * the kernel nests callback_mutex inside get_online_cpus() calls.
 * So the reverse nesting would risk an ABBA deadlock.

This went into the kernel sometime around 2.6.18.

Then in October and November of 2007, Gautham R Shenoy submitted
"Refcount Based Cpu Hotplug" (http://lkml.org/lkml/2007/11/15/239)

This added cpu_hotplug.lock, which at first glance seems to fit into
the locking hierarchy about where callback_mutex did before, such as
being invocable from rebuild_sched_domains().

However ... the kernel/cpuset.c comments were not updated to describe
the intended locking hierarchy as it relates to cpu_hotplug.lock, and
it looks as if cpu_hotplug.lock can also be taken while invoking the
hotplug callbacks, such as the one here that is handling a CPU down
event for cpusets.

Gautham ... you there?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> 1.940.382.4214
