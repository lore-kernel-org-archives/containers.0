From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Tue, 27 Jan 2009 02:53:00 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0901270244380.23757@chino.kir.corp.google.com>
References: <200901211638.23101.knikanth@suse.de>
	<200901232026.16778.knikanth@suse.de>
	<alpine.DEB.2.00.0901231230370.14231@chino.kir.corp.google.com>
	<200901271550.16902.knikanth@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200901271550.16902.knikanth-l3A5Bk7waGM@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, =?UTF-8?Q?Arve_Hj=C3=B8nnev=C3=A5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 27 Jan 2009, Nikanth Karthikesan wrote:

> > As previously stated, I think the heuristic to penalize tasks for not
> > having an intersection with the set of allowable nodes of the oom
> > triggering task could be made slightly more severe.  That's irrelevant to
> > your patch, though.
> >
> 
> But the heuristic makes it non-deterministic, unlike memcg case. And this 
> mandates special handling for cpuset constrained OOM conditions in this patch.
> 

Dividing a badness score by 8 if a task's set of allowable nodes do not 
insect with the oom triggering task's set does not make an otherwise 
deterministic algorithm non-deterministic.

I don't understand what you're arguing for here.  Are you suggesting that 
we should not prefer tasks that intersect the set of allowable nodes?  
That makes no sense if the goal is to allow for future memory freeing.

> > We also talked about a cgroup /dev/mem_notify device file that you can
> > poll() and learn of low memory situations so that appropriate action can
> > be taken even in lowmem situations as opposed to simply oom conditions.
> >
> 
> Userspace also needs to handle the cpuset constrained _almost-oom_'s 
> specially? I wonder how easily userspace can handle that.
> 

It handles it very well, cpusets are a client of cgroups and the 
/dev/mem_notify extension would be as well.  So to handle lowmem 
notifications for your cpuset, you would mount both cgroup subsystems at 
the same time and then poll() on the mem_notify file.  It would be 
responsible for the aggregate of tasks that the cgroup represents.

If lowmem notifications are implemented in the reclaim path, this is much 
easier for cpusets than for the memory controller, actually, since we 
already collect per-node ZVC information.

> > These types of policy decisions belong in userspace.
> 
> Yes, policy decisions will be made in user-space using this oom-controller. 
> This is just a framework/means to enforce policies. We do not make any 
> decisions inside the kernel.
> 
> But yes, the badness calculation by the oom killer implements some kind of 
> policy inside the kernel, but I guess it can stay, as this oom-controller lets 
> user policy over-ride kernel policy. ;-)
> 

The goal should not be to override the kernel's choice, because that 
decision depends heavily on the type of oom and the state of the machine 
at the time.  Appropriate changes to the oom killer's heuristics are 
always welcome; in my opinion, we should probably penalize tasks that do 
not intersect the triggering task's set of allowable nodes more than we 
currently do.

I think you'll find that your goals can be accomplished with a mem_notify 
cgroup and that it is a much more powerful interface so that your 
userspace policy can be better informed, especially if it is aware of 
lowmem situations where oom conditions are imminent.
