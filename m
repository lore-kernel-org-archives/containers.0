From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Tue, 27 Jan 2009 15:50:16 +0530
Message-ID: <200901271550.16902.knikanth__492.044309112494$1233051890$gmane$org@suse.de>
References: <200901211638.23101.knikanth@suse.de>
	<200901232026.16778.knikanth@suse.de>
	<alpine.DEB.2.00.0901231230370.14231@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.0901231230370.14231-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve =?iso-8859-1?q?Hj=F8nnev=E5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Saturday 24 January 2009 02:14:59 David Rientjes wrote:
> On Fri, 23 Jan 2009, Nikanth Karthikesan wrote:
> > In other instances, It can actually also kill some innocent tasks unless
> > the administrator tunes oom_adj, say something like kvm which would have
> > a huge memory accounted, but might be from a different node altogether.
> > Killing a single vm is killing all of the processes in that OS ;)  Don't
> > you think this has to be fixed^Wimproved?
>
> As previously stated, I think the heuristic to penalize tasks for not
> having an intersection with the set of allowable nodes of the oom
> triggering task could be made slightly more severe.  That's irrelevant to
> your patch, though.
>

But the heuristic makes it non-deterministic, unlike memcg case. And this 
mandates special handling for cpuset constrained OOM conditions in this patch.

> > > That's my objection to the proposal: it doesn't behave appropriately
> > > for both global unconstrained ooms and cpuset-constrained ooms at the
> > > same time.
> >
> > So you are against specifying order when it is a cpuset-constrained oom.
> > Here is a revised version of the patch which adds oom.cpuset_constraint,
> > when set to 1 would disable the ordering imposed by this controller for
> > cpuset constrained ooms! Will this work for you?
>
> No, I don't think it's appropriate to add special exemptions for specific
> subsystems to what should be a generic cgroup.  I think it is much more
> powerful to defer these decisions to userspace so each cgroup can attach
> its own handler and implement the necessary decision-making that the
> kernel could never perfectly handle for all possible workloads.
>
> It is trivial to implement the equivalent of this particular change as a
> userspace handler to SIGKILL all tasks in a specific cgroup when the
> cgroup oom handler is woken up at the time of oom.  Additionally, it could
> also respond in other ways such as adding a node to a cpuset, killing a
> less important cgroup, elevate a memory controller limit, send a signal to
> your application to release memory, etc.
>
> We also talked about a cgroup /dev/mem_notify device file that you can
> poll() and learn of low memory situations so that appropriate action can
> be taken even in lowmem situations as opposed to simply oom conditions.
>

Userspace also needs to handle the cpuset constrained _almost-oom_'s 
specially? I wonder how easily userspace can handle that.

> These types of policy decisions belong in userspace.

Yes, policy decisions will be made in user-space using this oom-controller. 
This is just a framework/means to enforce policies. We do not make any 
decisions inside the kernel.

But yes, the badness calculation by the oom killer implements some kind of 
policy inside the kernel, but I guess it can stay, as this oom-controller lets 
user policy over-ride kernel policy. ;-)

Thanks
Nikanth
