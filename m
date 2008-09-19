From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH -mm] memrlimit: fix task_lock() recursive locking (v2)
Date: Thu, 18 Sep 2008 20:28:25 -0700
Message-ID: <48D31C59.7050404__3317.33898860893$1221795109$gmane$org@linux.vnet.ibm.com>
References: <48D2CD1D.9040202@gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48D2CD1D.9040202-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrea Righi wrote:

> Since we hold task_lock(), we know that p->mm cannot change and we don't have
> to worry about incrementing mm_users. So, just use p->mm directly and
> check that we've not picked a kernel thread.
> 
> Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  kernel/cgroup.c      |    3 ++-
>  mm/memrlimitcgroup.c |   10 ++++------
>  2 files changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 678a680..03cc925 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2757,7 +2757,8 @@ void cgroup_fork_callbacks(struct task_struct *child)
>   * invoke this routine, since it assigns the mm->owner the first time
>   * and does not change it.
>   *
> - * The callbacks are invoked with mmap_sem held in read mode.
> + * The callbacks are invoked with task_lock held and mmap_sem held in read
> + * mode.
>   */
>  void cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new)
>  {
> diff --git a/mm/memrlimitcgroup.c b/mm/memrlimitcgroup.c
> index 8ee74f6..b3d20f5 100644
> --- a/mm/memrlimitcgroup.c
> +++ b/mm/memrlimitcgroup.c
> @@ -238,7 +238,7 @@ out:
>  }
> 
>  /*
> - * This callback is called with mmap_sem held
> + * This callback is called with mmap_sem and task_lock held
>   */
>  static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  						struct cgroup *old_cgrp,
> @@ -246,9 +246,9 @@ static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  						struct task_struct *p)
>  {
>  	struct memrlimit_cgroup *memrcg, *old_memrcg;
> -	struct mm_struct *mm = get_task_mm(p);
> +	struct mm_struct *mm = p->mm;
> 
> -	BUG_ON(!mm);
> +	BUG_ON(!mm || (p->flags & PF_KTHREAD));
> 
>  	/*
>  	 * If we don't have a new cgroup, we just uncharge from the old one.
> @@ -258,7 +258,7 @@ static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  		memrcg = memrlimit_cgroup_from_cgrp(cgrp);
>  		if (res_counter_charge(&memrcg->as_res,
>  				mm->total_vm << PAGE_SHIFT))
> -			goto out;
> +			return;
>  	}
> 
>  	if (old_cgrp) {
> @@ -266,8 +266,6 @@ static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  		res_counter_uncharge(&old_memrcg->as_res,
>  				mm->total_vm << PAGE_SHIFT);
>  	}
> -out:
> -	mmput(mm);
>  }

Seems reasonable

Acked-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

-- 
	Balbir
