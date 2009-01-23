From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Fri, 23 Jan 2009 15:15:36 +0530
Message-ID: <200901231515.37442.knikanth__8525.63101002506$1232704333$gmane$org@suse.de>
References: <200901211638.23101.knikanth@suse.de>
	<20090122101424.GA12317@ioremap.net>
	<alpine.DEB.2.00.0901220218120.2851@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.0901220218120.2851-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve =?iso-8859-1?q?Hj=F8nnev=E5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thursday 22 January 2009 15:57:19 David Rientjes wrote:
> On Thu, 22 Jan 2009, Evgeniy Polyakov wrote:
> > > In an exclusive cpuset, a task's memory is restricted to a set of mems
> > > that the administrator has designated.  If it is oom, the kernel must
> > > free memory on those nodes or the next allocation will again trigger an
> > > oom (leading to a needlessly killed task that was in a disjoint
> > > cpuset).
> > >
> > > Really.
> >
> > The whole point of oom-killer is to kill the most appropriate task to
> > free the memory. And while task is selected system-wide and some
> > tunables are added to tweak the behaviour local to some subsystems, this
> > cpuset feature is hardcoded into the selection algorithm.
>
> Of course, because the oom killer must be aware that tasks in disjoint
> cpusets are more likely than not to result in no memory freeing for
> current's subsequent allocations.
>

Yes, the problem is cpuset does not track the tasks which has allocated from 
this node - who has either moved or changed it set of allowable nodes. And 
because of that it does not limit oom killing to the tasks with in those tasks 
and could kill some innocent tasks at times.

As it is unable to take deterministic decision as memcg does, it plays with 
badness value and only suggests but does not restricts within those tasks that 
has to be killed.

This bug is present even without this patch.

> > And when some tunable starts doing own calculation, behaviour of this
> > hardcoded feature changes.
>
> Yes, it is possible to elevate oom_adj scores to override the cpuset
> preference.  That's actually intended since it is now possible for the
> administrator to specify that, against the belief of the kernel, that
> killing a task will free memory in these cpuset-constrained ooms.  That's
> probably because it has either been moved to a different cpuset or its set
> of allowable nodes is dynamic.
>

This patch adds one more easier way for the administrator to over-ride.

> > > Then the scope of this new cgroup is restricted to not being used with
> > > cpusets that could oom.
> >
> > These are perpendicular tasks - cpusets limit one area of the oom
> > handling, cgroup order - another. Some people needs cpusets, others want
> > cgroups. cpusets are not something exceptional so that only they have to
> > be taken into account when doing system-wide operation like OOM
> > condition handling.
>
> A cpuset is a cgroup.  If I am using cpusets, this patch fails to
> adequately allow me to describe my oom preferences for both
> cpuset-constrained ooms and global unconstrained ooms, which is a major
> drawback.
>

The current cpuset oom handling has to be fixed and the exact problem of 
killing innocent processes exists even without the oom-controller.

Thanks
Nikanth
