From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Date: Tue, 10 Jun 2008 16:35:50 +0900
Message-ID: <20080610163550.65c97f6a.nishimura@mxp.nes.nec.co.jp>
References: <20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080606105235.3c94daaf.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi, Kamezawa-san.

Sorry for late reply.

On Fri, 6 Jun 2008 10:52:35 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> Move Usage at Task Move (just an experimantal for discussion)
> I tested this but don't think bug-free.
> 
> In current memcg, when task moves to a new cg, the usage remains in the old cg.
> This is considered to be not good.
> 
I agree.

> This is a trial to move "usage" from old cg to new cg at task move.
> Finally, you'll see the problems we have to handle are failure and rollback.
> 
> This one's Basic algorithm is
> 
>      0. can_attach() is called.
>      1. count movable pages by scanning page table. isolate all pages from LRU.
>      2. try to create enough room in new memory cgroup
>      3. start moving page accouing
>      4. putback pages to LRU.
>      5. can_attach() for other cgroups are called.
> 
You isolate pages and move charges of them by can_attach(),
but it means that pages that are allocated between page isolation
and moving tsk->cgroups remains charged to old group, right?

I think it would be better if possible to move charges by attach()
as cpuset migrates pages by cpuset_attach().
But one of the problem of it is that attch() does not return
any value, so there is no way to notify failure...

> A case study.
> 
>   group_A -> limit=1G, task_X's usage= 800M.
>   group_B -> limit=1G, usage=500M.
> 
> For moving task_X from group_A to group_B.
>   - group_B  should be reclaimed or have enough room.
> 
> While moving task_X from group_A to group_B.
>   - group_B's memory usage can be changed
>   - group_A's memory usage can be changed
> 
>   We accounts the resouce based on pages. Then, we can't move all resource
>   usage at once.
> 
>   If group_B has no more room when we've moved 700M of task_X to group_B,
>   we have to move 700M of task_X back to group_A. So I implemented roll-back.
>   But other process may use up group_A's available resource at that point.
>   
>   For avoiding that, preserve 800M in group_B before moving task_X means that
>   task_X can occupy 1600M of resource at moving. (So I don't do in this patch.)
> 
>   This patch uses Best-Effort rollback. Failure in rollback is ignored and
>   the usage is just leaked.
> 
If implement rollback in kernel, I think it must not fail to prevent
leak of usage.
How about using "charge_force" for rollbak?

Or, instead of implementing rollback in kernel,
how about making user(or middle ware?) re-echo pid to rollbak
on failure?

> Roll-back can happen when
>     (a) in phase 3. cannot move a page to new cgroup because of limit.
>     (b) in phase 5. other cgourp subsys returns error in can_attach().
> 
Isn't rollbak needed on failure between can_attach and attach(e.g. failure
on find_css_set, ...)?

> +int mem_cgroup_recharge_task(struct mem_cgroup *newcg,
> +				struct task_struct *task)
> +{
(snip)
> +	/* create enough room before move */
> +	necessary = info.count * PAGE_SIZE;
> +
> +	do {
> +		spin_lock(&newcg->res.lock);
> +		if (newcg->res.limit > necessary)
> +			rc = -ENOMEM;
I think it should be (newcg->res.limit < necessary).


Thanks,
Daisuke Nishimura.
