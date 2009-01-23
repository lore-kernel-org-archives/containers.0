From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Fri, 23 Jan 2009 02:33:49 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0901230223500.15719@chino.kir.corp.google.com>
References: <200901211638.23101.knikanth@suse.de>
	<20090122101424.GA12317@ioremap.net>
	<alpine.DEB.2.00.0901220218120.2851@chino.kir.corp.google.com>
	<200901231515.37442.knikanth@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200901231515.37442.knikanth-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, =?UTF-8?Q?Arve_Hj=C3=B8nnev=C3=A5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 23 Jan 2009, Nikanth Karthikesan wrote:

> > Of course, because the oom killer must be aware that tasks in disjoint
> > cpusets are more likely than not to result in no memory freeing for
> > current's subsequent allocations.
> >
> 
> Yes, the problem is cpuset does not track the tasks which has allocated from 
> this node - who has either moved or changed it set of allowable nodes. And 
> because of that it does not limit oom killing to the tasks with in those tasks 
> and could kill some innocent tasks at times.
> 

Right, the logic to prefer tasks that share the same set of allowable 
nodes as the oom-triggering task is implemented in badness() and being in 
a completely disjoint cpuset does not specifically exclude a task from 
being chosen as the oom killer's victim.  That's because, as you said, it 
could have allocated memory elsewhere before changing cpusets or its set 
of allowable mems.

> As it is unable to take deterministic decision as memcg does, it plays with 
> badness value and only suggests but does not restricts within those tasks that 
> has to be killed.
> 
> This bug is present even without this patch.
> 

It's not a bug, it can actually help in a couple instances:

 - a much larger memory hogging task is identified in a disjoint cpuset
   and the liklihood it has allocated memory elsewhere either previously 
   or atomically, or

 - an administrator tunes the oom_adj value for such a task to describe 
   the above behavior even for smaller tasks and their liklihood to 
   allocate outside of their exclusive cpuset.

> This patch adds one more easier way for the administrator to over-ride.
> 

Yeah, I know.  But the problem with the approach is that it specifies an 
oom priority for both global unconstrained ooms and cpuset-constrained 
ooms.

It's quite possible with your patch to identify an aggregate of tasks that 
should be killed first whenever the system is completely out of memory.  
That's great, and solves your problem.  But that same system cannot 
correctly use cpusets that have the potential to ever oom because your 
patch completely overrides the victim priority and could needlessly kill 
tasks that will not lead to future memory freeing.

That's my objection to the proposal: it doesn't behave appropriately for 
both global unconstrained ooms and cpuset-constrained ooms at the same 
time.

I think if you look at the cgroup oom notifier patch I referred you to, 
you will find it trivial to implement a handler that can issue a SIGKILL 
for an aggregate of tasks and implement the functional equivalent of this 
patch in userspace where it belongs.  It's nearly impossible to code oom 
killer heuristics in the kernel that work for every possible workload and 
configuration without some unfortunate casualties.

> The current cpuset oom handling has to be fixed and the exact problem of 
> killing innocent processes exists even without the oom-controller.
> 

I think the heuristic could be tuned to penalize tasks in disjoint cpusets 
a little more, but its implementation as a factor of the badness score is 
actually very well placed.
