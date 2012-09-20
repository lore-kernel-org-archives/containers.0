From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 2/3] cgroup, sched: let cpu serve the same files as cpuacct
Date: Thu, 20 Sep 2012 12:05:10 +0400
Message-ID: <505ACE36.80603@parallels.com>
References: <1348094625-4471-1-git-send-email-tj@kernel.org>
	<1348094625-4471-3-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348094625-4471-3-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay.sievers-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, mzxreary-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org, davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org
List-Id: containers.vger.kernel.org

On 09/20/2012 02:43 AM, Tejun Heo wrote:
> +
> +void task_group_charge(struct task_struct *tsk, u64 cputime)
> +{
> +	struct task_group *tg;
> +	int cpu = task_cpu(tsk);
> +
> +	rcu_read_lock();
> +
> +	tg = container_of(task_subsys_state(tsk, cpu_cgroup_subsys_id),
> +			  struct task_group, css);
> +
> +	for (; tg; tg = tg->parent) {
> +		u64 *cpuusage = per_cpu_ptr(tg->cpuusage, cpu);
> +		*cpuusage += cputime;
> +	}
> +
> +	rcu_read_unlock();
> +}
>  #endif /* CONFIG_CGROUP_SCHED */

The whole point of this merge is that this is not needed.
This information is already available from exec_clock for fair tasks.
for rt tasks, we have no exec clock, but do have a hierarchy walk a bit
below the current cpuacct charge, that can be used for that purpose.
