From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Question : memrlimit cgroup's task_move (2.6.26-rc5-mm3)
Date: Thu, 19 Jun 2008 08:43:43 +0530
Message-ID: <4859CEE7.9030505@linux.vnet.ibm.com>
References: <20080619121435.f868c110.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080619121435.f868c110.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> I used memrlimit cgroup at the first time.
> 
> May I ask a question about memrlimit cgroup ?
> 
> In following 
> ==
> static void memrlimit_cgroup_move_task(struct cgroup_subsys *ss,
>                                         struct cgroup *cgrp,
>                                         struct cgroup *old_cgrp,
>                                         struct task_struct *p)
> {
>         struct mm_struct *mm;
>         struct memrlimit_cgroup *memrcg, *old_memrcg;
> 
> <snip>
>         if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
>                 goto out;
>         res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
> ==
> This is a callback for task_attach(). and this never fails.
> 
> What happens when the moved task, which move-of-charge fails, exits ?
> 

Good question - I am working on this, some of the logic should move to
can_attach(). I'll try and experiment with it and send out a fix.

> ==
> % mkdir /dev/cgroup/memrlimit/group_01
> % mkdir /dev/cgroup/memrlimit/group_02
> % echo 1G > /dev/cgroup/memrlimit/group_01/memrlimit.limit_in_bytes
> % echo 0 >  /dev/cgroup/memrlimit/group_02/memrlimit.limit_in_bytes
> % echo $$ > /dev/cgroup/memrlimit/group_01/tasks
> % echo $$ > /dev/cgroup/memrlimit/group_02/tasks
> % exit
> == you'll see WARNING ==
> 
> I think the charge of the new group goes to minus. right ?
> (and old group's charge never goes down.)
> I don't think this is "no problem".
> 
> What kind of patch is necessary to fix this ?
> task_attach() should be able to fail in future ?
> 
> I'm sorry if I misunderstand something or this is already in TODO list.
> 

It's already on the TODO list. Thanks for keeping me reminded about it.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
