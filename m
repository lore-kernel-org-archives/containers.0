From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET] block: implement blkcg hierarchy support in cfq
Date: Mon, 17 Dec 2012 11:52:28 -0500
Message-ID: <20121217165228.GB7235__38439.1975509518$1355763182$gmane$org@redhat.com>
References: <1355524885-22719-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1355524885-22719-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, Peter Zijlstra <pzijlstr-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Dec 14, 2012 at 02:41:13PM -0800, Tejun Heo wrote:
> Hello,
> 
> cfq-iosched is currently utterly broken in how it handles cgroup
> hierarchy.  It ignores the hierarchy structure and just treats every
> blkcgs equally.  This is simply broken.  This breakage makes blkcg
> behave very differently from other properly-hierarchical controllers
> and makes it impossible to give any uniform interpretation to the
> hierarchy, which in turn makes it impossible to implement unified
> hierarchy.
> 
> Given the relative simplicity of cfqg scheduling, implementing proper
> hierarchy support isn't that difficult.  All that's necessary is
> determining how much fraction each cfqg on the service tree has claim
> to considering the hierarchy.  The calculation can be done by
> maintaining the sum of active weights at each level and compounding
> the ratios from the cfqg in question to root.  The overhead isn't
> significant.  Tree traversals happen only when cfqgs are added or
> removed from the service tree and they are from the cfqg being
> modified to the root.
> 
> There are some design choices which are worth mentioning.
> 
> * Internal (non-leaf) cfqgs w/ tasks treat the tasks as a single unit
>   competeting against the children cfqgs.  New config knobs -
>   blkio.leaf_weight[_device] - are added to configure the weight of

[ CC peterz ]

Hi Tejun,

I am wondering if blkio.task_group_weight[_device] will more sense. It
is easier to think in terms of hidden task group of a cfqg instead of
whether it is a leaf node or not.

>   these tasks.  Another way to look at it is that each cfqg has a
>   hidden leaf child node attached to it which hosts all tasks and
>   leaf_weight controls the weight of that hidden node.
> 
>   Treating cfqqs and cfqgs as equals doesn't make much sense to me and
>   is hairy - we need to establish ioprio to weight mapping and the
>   weights fluctuate as processes fork and exit.

So weights of task (io_context) or blkcg weights don't fluctuate with
task fork/exit. It is just the weight on service tree, which fluctuates.

> This becomes hairier
>   when considering multiple controllers, Such mappings can't be
>   established consistently across different controllers and the
>   weights are given out differently - ie. blkcg give weights out to
>   io_contexts while cpu to tasks, which may share io_contexts.  It's
>   difficult to make sense of what's going on.

We already have that issue, isn't it. Cpu does task scheduling and
CFQ does io_context scheduling. (Nobody seems to be complaining though).

> 
>   The goal is to bring cpu, currently the only other controller which
>   implements weight based resource allocation, to similar behavior.

I think we first need to have some kind of buy-in from cpu controller
guys that yes in long term they will change it. Otherwise we don't want
to be stuck in a situation where cpu and blkio behave entirely
differently.

In fact we need to revisit this idea that what makes more sense. To
me treating task and group at same level is not necessarily bad as
it gives more flexibility. And leave it to user to create another
subgroup and launch all the tasks there if they want to emulate the
behavior of a hidden sub-group.

If you look at it systemd already puts services in separate group. They
always wanted to put user sessions also in a separate group. So
effectively hierarhcy looks as follows (for cpu controller).

			  root
		        / | \  \ 
		      T1 T2 usr system

So T1 and T2 here basically a kernel threds (All users sessions and
services have been moved out to respective cgroups).

I think I am fine with not limiting kernel threads into a subgroup of
their own. In fact I think there was a patch where we could not move
kernel threads out of root cgroup. If that makes sense, then it does
not make sense to limit kernel threads to a subgroup of their own
by default (it is equivalent to moving these threads to a cgroup of
their own).

So though I don't mind the notion of this hidden cgroups but given
the fact that we have implemented things other way and left it to
user space to manage it based on their needs, I am not sure what's
that fundamental reason that we should change that assumption now.

And even if we decide to do it, we need to have other controllers
on board (especially cpu).

I think we will have similar issues with others components too. In blkio
throttling support, we will have to put some kind of throttling limits
on internal group too. I guess one can raise similar concerns for memory
controller too where there are no internal limits on child task of a
cgroup but there are limits on child group.

			parent (mem.limit_in_bytes = 200)
			  /   |   \
			 T1  T2   child-grp (mem.limit_in_bytes = 100)
					|
					T3

Now there are no  guarantees that T3 will get its share of 100 bytes of
memory allocation as T1 and T2 might have already exhausted the quota
of 200 bytes of parent.

So should we create an internal group there too to limit the share of
T1 and T2. I thought if somebody wants it, then it is best to leave it
to user space then kernel enforcing that. 

Thanks
Vivek
