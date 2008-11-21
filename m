From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cpuset: rcu_read_lock() to protect task_cs()
Date: Fri, 21 Nov 2008 10:36:37 -0800
Message-ID: <6599ad830811211036k419ff716h6068d532c9942d73__13126.1891140186$1227292817$gmane$org@mail.gmail.com>
References: <49267621.2070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49267621.2070706-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Nov 21, 2008 at 12:49 AM, Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
> task_cs() calls cgroup_subsys_state().

You mean it calls task_subsys_state().

>
> we must use rcu_read_lock() to protect cgroup_subsys_state().
>
> it's correct that top_cpuset is never freed, but cgroup_subsys_state()
> accesses css_set, this css_set maybe freed when task_cs() called.

It would be nice to have an RCU debug mode where rcu_dereference()
does a WARN() if it's invoked not under rcu_read_lock().

>
> we use use rcu_read_lock() to protect it.
>
> Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 3e00526..e0e087e 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -363,14 +363,9 @@ void cpuset_update_task_memory_state(void)
>        struct task_struct *tsk = current;
>        struct cpuset *cs;
>
> -       if (task_cs(tsk) == &top_cpuset) {
> -               /* Don't need rcu for top_cpuset.  It's never freed. */
> -               my_cpusets_mem_gen = top_cpuset.mems_generation;
> -       } else {
> -               rcu_read_lock();
> -               my_cpusets_mem_gen = task_cs(tsk)->mems_generation;
> -               rcu_read_unlock();
> -       }
> +       rcu_read_lock();
> +       my_cpusets_mem_gen = task_cs(tsk)->mems_generation;
> +       rcu_read_unlock();

Yes, I guess this old cpusets assumption is no longer valid in cgroups.

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks

Paul
