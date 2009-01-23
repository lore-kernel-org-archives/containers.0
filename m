From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Fri, 23 Jan 2009 12:44:59 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0901231230370.14231__16442.1564586975$1232743836$gmane$org@chino.kir.corp.google.com>
References: <200901211638.23101.knikanth@suse.de>
	<200901231515.37442.knikanth@suse.de>
	<alpine.DEB.2.00.0901230223500.15719@chino.kir.corp.google.com>
	<200901232026.16778.knikanth@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200901232026.16778.knikanth-l3A5Bk7waGM@public.gmane.org>
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

> In other instances, It can actually also kill some innocent tasks unless the 
> administrator tunes oom_adj, say something like kvm which would have a huge 
> memory accounted, but might be from a different node altogether. Killing a 
> single vm is killing all of the processes in that OS ;)  Don't you think this 
> has to be fixed^Wimproved?
> 

As previously stated, I think the heuristic to penalize tasks for not 
having an intersection with the set of allowable nodes of the oom 
triggering task could be made slightly more severe.  That's irrelevant to 
your patch, though.

> > That's my objection to the proposal: it doesn't behave appropriately for
> > both global unconstrained ooms and cpuset-constrained ooms at the same
> > time.
> >
> 
> So you are against specifying order when it is a cpuset-constrained oom. Here 
> is a revised version of the patch which adds oom.cpuset_constraint, when set 
> to 1 would disable the ordering imposed by this controller for cpuset 
> constrained ooms! Will this work for you?
> 

No, I don't think it's appropriate to add special exemptions for specific 
subsystems to what should be a generic cgroup.  I think it is much more 
powerful to defer these decisions to userspace so each cgroup can attach 
its own handler and implement the necessary decision-making that the 
kernel could never perfectly handle for all possible workloads.

It is trivial to implement the equivalent of this particular change as a 
userspace handler to SIGKILL all tasks in a specific cgroup when the 
cgroup oom handler is woken up at the time of oom.  Additionally, it could 
also respond in other ways such as adding a node to a cpuset, killing a 
less important cgroup, elevate a memory controller limit, send a signal to 
your application to release memory, etc.

We also talked about a cgroup /dev/mem_notify device file that you can 
poll() and learn of low memory situations so that appropriate action can 
be taken even in lowmem situations as opposed to simply oom conditions.

These types of policy decisions belong in userspace.
