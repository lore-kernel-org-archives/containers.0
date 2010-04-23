From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [PATCH] cgroup: Check task_lock in task_subsys_state()
Date: Thu, 22 Apr 2010 20:00:52 -0700
Message-ID: <20100423030052.GC32490@count0.beaverton.ibm.com>
References: <4BD10788.8060006@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BD10788.8060006@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Lai JIangshan <laijs@cn.fujitsu.com>, Paul Menage <menage@google.com>, Matt Helsley <matthltc@us.ibm.com>, Cedric Le Goater <clg@vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Fri, Apr 23, 2010 at 10:35:52AM +0800, Li Zefan wrote:
> task_subsys_state() is safe under task_lock(). See
> Documentation/cgroups/cgroups.txt for locking rule.
> 
> This fixes an RCU warning when resume from suspend. The
> warning comes from freezer cgroup in cgroup_freezing_or_frozen().
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Acked-by: Matt Helsley <matthltc@us.ibm.com>

> ---
> 
> I'm not sure which is preferable - access ->alloc_lock directly
> like this patch or add task_lock_is_held() in sched.h
> 
> ---
>  include/linux/cgroup.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index b8ad1ea..8f78073 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -530,6 +530,7 @@ static inline struct cgroup_subsys_state *task_subsys_state(
>  {
>  	return rcu_dereference_check(task->cgroups->subsys[subsys_id],
>  				     rcu_read_lock_held() ||
> +				     lockdep_is_held(&task->alloc_lock) ||
>  				     cgroup_lock_is_held());
>  }
> 
> -- 
> 1.6.3
