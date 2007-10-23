From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/2] CFS CGroup: Report usage
Date: Tue, 23 Oct 2007 08:47:09 +0530
Message-ID: <471D67B5.1020802__41161.1738069498$1193109571$gmane$org@linux.vnet.ibm.com>
References: <471D4523.4040509@google.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <471D4523.4040509-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> Report CPU usage in CFS Cgroup directories
> 
> Adds a cpu.usage file to the CFS cgroup that reports CPU usage in
> milliseconds for that cgroup's tasks
> 
> This replaces the "example CPU Accounting CGroup subsystem" that
> was merged into mainline last week.
> 
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> ---
> kernel/sched.c |   32 +++++++++++++++++++++++++++-----
> 1 file changed, 27 insertions(+), 5 deletions(-)
> 
> Index: container-2.6.23-mm1/kernel/sched.c
> ===================================================================
> --- container-2.6.23-mm1.orig/kernel/sched.c
> +++ container-2.6.23-mm1/kernel/sched.c
> @@ -7005,15 +7005,37 @@ static u64 cpu_shares_read_uint(struct c
>     return (u64) tg->shares;
> }
> 
> -static struct cftype cpu_shares = {
> -    .name = "shares",
> -    .read_uint = cpu_shares_read_uint,
> -    .write_uint = cpu_shares_write_uint,
> +static u64 cpu_usage_read(struct cgroup *cgrp, struct cftype *cft)
> +{
> +    struct task_group *tg = cgroup_tg(cgrp);
> +    int i;
> +    u64 res = 0;
> +    for_each_possible_cpu(i) {
> +        unsigned long flags;
> +        spin_lock_irqsave(&tg->cfs_rq[i]->rq->lock, flags);
> +        res += tg->se[i]->sum_exec_runtime;
> +        spin_unlock_irqrestore(&tg->cfs_rq[i]->rq->lock, flags);
> +    }
> +    /* Convert from ns to ms */
> +    do_div(res, 1000000);
> +    return res;
> +}
> +

I think we also need the notion of load, like we have in cpu_acct.c
Don't we need to do a css_get() on the cgrp to ensure that the cgroup
does not go away if it's empty and someone does an rmdir on it?


> +static struct cftype cpu_files[] = {
> +    {
> +        .name = "shares",
> +        .read_uint = cpu_shares_read_uint,
> +        .write_uint = cpu_shares_write_uint,
> +    },
> +    {
> +        .name = "usage",
> +        .read_uint = cpu_usage_read,
> +    },
> };
> 
> static int cpu_cgroup_populate(struct cgroup_subsys *ss, struct cgroup
> *cont)
> {
> -    return cgroup_add_file(cont, ss, &cpu_shares);
> +    return cgroup_add_files(cont, ss, cpu_files, ARRAY_SIZE(cpu_files));
> }
> 
> struct cgroup_subsys cpu_cgroup_subsys = {


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
