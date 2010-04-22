From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/5] sched: Fix an RCU warning in print_task()
Date: Thu, 22 Apr 2010 12:56:14 -0700
Message-ID: <20100422195614.GK2524@linux.vnet.ibm.com>
References: <4BD016F4.8060108@cn.fujitsu.com>
 <4BD01740.7050805@cn.fujitsu.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BD01740.7050805@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 22, 2010 at 05:30:40PM +0800, Li Zefan wrote:
> With CONFIG_PROVE_RCU=y, a warning can be triggered:
> 
>   $ cat /proc/sched_debug
> 
> ...
> kernel/cgroup.c:1649 invoked rcu_dereference_check() without protection!
> ...
> 
> Both cgroup_path() and task_group() should be called with either
> rcu_read_lock or cgroup_mutex held.

Queued for 2.6.34, thank you!

							Thanx, Paul

> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> ---
>  kernel/sched_debug.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/kernel/sched_debug.c b/kernel/sched_debug.c
> index 9cf1baf..87a330a 100644
> --- a/kernel/sched_debug.c
> +++ b/kernel/sched_debug.c
> @@ -114,7 +114,9 @@ print_task(struct seq_file *m, struct rq *rq, struct task_struct *p)
>  	{
>  		char path[64];
> 
> +		rcu_read_lock();
>  		cgroup_path(task_group(p)->css.cgroup, path, sizeof(path));
> +		rcu_read_unlock();
>  		SEQ_printf(m, " %s", path);
>  	}
>  #endif
> -- 
> 1.6.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
