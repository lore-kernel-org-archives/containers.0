From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] memcontrol: rcu_read_lock() to protect mm_match_cgroup()
Date: Fri, 21 Nov 2008 19:32:10 +0900
Message-ID: <20081121193210.d7760fd6.kamezawa.hiroyu__41476.4032619589$1227263721$gmane$org@jp.fujitsu.com>
References: <49267627.80103@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49267627.80103-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 21 Nov 2008 16:49:43 +0800
Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:

> 
> mm_match_cgroup() calls cgroup_subsys_state().
> 
> we must use rcu_read_lock() to protect cgroup_subsys_state().
> 
Thanks,
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

> Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 1fbe14d..ce89ff0 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -47,8 +47,15 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
>  
>  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
>  
> -#define mm_match_cgroup(mm, cgroup)	\
> -	((cgroup) == mem_cgroup_from_task((mm)->owner))
> +static inline
> +int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
> +{
> +	struct mem_cgroup *mem;
> +	rcu_read_lock();
> +	mem = mem_cgroup_from_task((mm)->owner);
> +	rcu_read_unlock();
> +	return cgroup == mem;
> +}
>  
>  extern int
>  mem_cgroup_prepare_migration(struct page *page, struct page *newpage);
> 
> 
