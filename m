From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 1/4] io controller: documentation
Date: Fri, 7 Nov 2008 09:27:15 -0500
Message-ID: <20081107142715.GD21884__27047.0494092026$1226068185$gmane$org@redhat.com>
References: <20081106153022.215696930@redhat.com>
	<20081106153135.743458085@redhat.com>
	<20081107113209.a6011c67.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081107113209.a6011c67.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Nov 07, 2008 at 11:32:09AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 06 Nov 2008 10:30:23 -0500
> vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org wrote:
> > +ISSUES
> > +======
> > +- IO controller can buffer the bios if suffcient tokens were not available
> > +  at the time of bio submission. Once the tokens are available, these bios
> > +  are dispatched to elevator/lower layers in first come first serve manner.
> > +  And this has potential to break CFQ where a RT tasks should be able to
> > +  dispatch the bio first or a high priority task should be able to release
> > +  more bio as compared to low priority task in same cgroup.
> > +
> > +  Not sure how to fix it. May be we need to maintain another rb-tree and
> > +  keep track of RT tasks and tasks priorities and dispatch accordingly. This
> > +  is equivalent of duplicating lots of CFQ logic and not sure how would it
> > +  impact AS behaviour.
> > 
> Why you don't isolate RT tasks into other cgroup ?
>    /cgroup/bio-cgroup/group_for_usual/...usual tasks.
>                      /group_for_RT/ ...RT tasks. you can use high-speed path.
> 
> How about adding RT flag to bio-cgroup and skip buffering at bio-cgroup if RT
> flag is set ? I think handling an usual process and RT process in "a" cgroup
> just makes the code complex.
> 
> Looking into a cpu-scheduler, which is the first module handling RT, it has
> some tweaks to handle RT in the system.
>  - special RT scheduler.
>  - isolated RT domain
>  - maximum execution time allowed to RT
>  ....
> 
> Maybe handling RT in following way is usual way...(if we do something in this layer)
> 
>   - Allow RT-bio-cgroup to skip limit check.
>   - But RT-bio-cgroup calculates io-throuput, execution time, statistics...
>   - When RT tasks in RT-bio-cgroup does excessive I/O which starves the whole system
>     too long, raise safeguard-limitter. and tell users Warning or kill it.
> 
> Hmm ?

Hi Kame,

Looking at CFQ, there are two issues.

- RT tasks (and RT priorities with in that)
- Best Effort class tasks (and priorities with in that).

To make sure we don't break underlying CFQ elevator, we need to take care of 
both the things in higher level scheduler. This will mean practically we
will end up copying code from CFQ in higher level scheduler.

Even if I do that (Keep track of RT tasks and Best effort class tasks and 
their proirities and do dispatch accordingly), I am not sure will it have
any negative impact when a user is using AS IO scheduler on the leaf node.

That forces me to think that if we can let go the idea of doing
proportionate bandwidth allocation at higher level logical device and just
do it for leaf nodes, then we can drop the idea of two level scheduler and
try to bring unification among four IO schedulers such that with least 
code copying they can also support proportional weight policies.

Thanks
Vivek
