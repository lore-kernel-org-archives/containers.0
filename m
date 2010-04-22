From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/5] sched: Fix an RCU warning in print_task()
Date: Thu, 22 Apr 2010 12:20:04 +0200
Message-ID: <1271931604.1776.337.camel@laptop>
References: <4BD016F4.8060108@cn.fujitsu.com>
	 <4BD01740.7050805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BD01740.7050805@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

On Thu, 2010-04-22 at 17:30 +0800, Li Zefan wrote:
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

Well, that's not strictly true, but yes in this case it appears to be a
genuine race, since only tasklist_lock is held and that doesn't protect
us from the task changing groups (and thus the current group from going
away on us).

You can also pin a cgroup by holding whatever locks are held in the
->attach method. But the RCU annotation doesn't know (nor reasonably can
know about that).

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
