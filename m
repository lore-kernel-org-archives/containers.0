From: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Subject: Re: Cgroups RT scheduling
Date: Fri, 11 Sep 2009 13:47:20 +0200
Message-ID: <1252669640.7126.29.camel@laptop>
References: <b6a2d2e20909090849m16a9f452h353d5a75ee61c625@mail.gmail.com>
	<20090911112352.GH4474@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090911112352.GH4474-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2009-09-11 at 16:53 +0530, Dhaval Giani wrote:
> [Adding peterz to the cc]
> 
> On Wed, Sep 09, 2009 at 04:49:52PM +0100, Rolando Martins wrote:
> > Hi,
> > 
> > I would like to confirm the following:
> > cpuset.sched_load_balance doesn't work with RT, right?

It does.

> > You cannot have tasks for sub-domain 2 to utilize bandwidth of
> > sub-domain 3, right?

Depends on what you do, for some contorted reason we have 2 cpu control
groups, cpusets and this other thing.

I'm still wanting to fold them into one, this confusion is in part
because of that train-wreck.

You can place a task in one cpuset cgroup and in another scheduler
cgroup - but yeah, that does interact funny with the load-balancer.

> > 
> >                               __1__
> >                              /        \
> >                             2         3
> >                       (50% rt)  (50% rt )
> > 
> > For my application domain;) it would be interesting to have
> > rt_runtime_ns as a min. of allocated rt and not a max.
> > Ex. If an application of domain 2 needs to go up to 100% and domain 3
> > is idle, then it would be cool to let it utilize the full bandwidth.
> > (we also could have a hard upper limit in each sub-domain, like
> > hard_up=0.8, i.e. even if we could get 100%, we will only utilize
> > 80%).

This doesn't sound a like a real-time application.

Variable bandwidth is useless for determinism.
