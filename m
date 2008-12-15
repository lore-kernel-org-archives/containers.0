From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] pid: improved namespaced iteration over processes list
Date: Mon, 15 Dec 2008 10:32:54 -0800
Message-ID: <1229365974.17206.190.camel@nimitz>
References: <1229359793-4029-1-git-send-email-gomuthuk@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1229359793-4029-1-git-send-email-gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gowrishankar M <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Balbir <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2008-12-15 at 22:19 +0530, Gowrishankar M wrote:
> Below patch addresses a common solution for any place where a process
> should be checked if it is associated to caller namespace. At present,
> we use 'task_pid_vnr(t) > 0' to further proceed with task 't' in current
> namespace.
> 
> To avoid applying this check in every code related to PID namespace,
> this patch reworks on iterative macros;for_each_process and do_each_thread.
> 
> This patch can also reduce latency time on process list lookup inside the
> container, as we walk along pidmap, instead of every process in system.
> 
> Signed-off-by: Gowrishankar M <gowrishankar.m-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/sched.h |    8 +++++---
>  kernel/pid.c          |   17 +++++++++++++++++
>  2 files changed, 22 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 2e46189..8d3b520 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1917,17 +1917,19 @@ static inline unsigned long wait_task_inactive(struct task_struct *p,
>  }
>  #endif
> 
> -#define next_task(p)	list_entry(rcu_dereference((p)->tasks.next), struct task_struct, tasks)
> +#include <linux/nsproxy.h>
> +#define next_task(p)	pid_task(find_ge_tgid(task_pid_vnr(p) + 1, p->nsproxy->pid_ns), PIDTYPE_PID)
> +#define ns_init_task	(current->nsproxy->pid_ns == &init_pid_ns ? next_task((&init_task)) : find_task_by_vpid(1))

Can you turn these into static inlines so that they're a bit more
readable?

>  #define for_each_process(p) \
> -	for (p = &init_task ; (p = next_task(p)) != &init_task ; )
> +	for (p = ns_init_task ; p != NULL ; p = next_task(p))
> 
>  /*
>   * Careful: do_each_thread/while_each_thread is a double loop so
>   *          'break' will not work as expected - use goto instead.
>   */
>  #define do_each_thread(g, t) \
> -	for (g = t = &init_task ; (g = t = next_task(g)) != &init_task ; ) do
> +	for (g = t = ns_init_task ; g  != NULL ; (g = t = next_task(g))) do

I have to wonder whether we should be changing this globally or adding a
new do_each_ns_thread() or something.  Are you worried this will cause
some collateral damage?

> +struct pid *find_ge_tgid(int nr,  struct pid_namespace *ns)
> +{
> +	struct pid* pid;
> +	struct task_struct* task;
> +
> +retry:
> +	pid = find_ge_pid(nr, ns);
> +	if (pid) {
> +		task = pid_task(pid, PIDTYPE_PID);
> +		if (!task || !has_group_leader_pid(task)) {
> +			nr += 1;
> +			goto retry;
> +		}
> +	}
> +	return pid;
> +}

I might have written that loop a bit differently.  Does this work?  Is
it any more clear?

	while (pid = find_ge_pid(nr, ns) {
		task = pid_task(pid, PIDTYPE_PID);
		if (task && has_group_leader_pid(task))
			break;
		nr++;
	}


-- Dave
