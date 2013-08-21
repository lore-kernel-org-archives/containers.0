From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 09/11] cpuset: enable onlined cpu/node in effective masks
Date: Wed, 21 Aug 2013 10:11:26 -0400
Message-ID: <20130821141126.GI19286__409.65706944025$1377094301$gmane$org@mtj.dyndns.org>
References: <52148F52.0@huawei.com>
 <52148FE1.3080806@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52148FE1.3080806-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Li.

On Wed, Aug 21, 2013 at 06:01:05PM +0800, Li Zefan wrote:
> Firstly offline cpu1:
> 
>   # echo 0-1 > cpuset.cpus
>   # echo 0 > /sys/devices/system/cpu/cpu1/online
>   # cat cpuset.cpus
>   0-1
>   # cat cpuset.effective_cpus
>   0
> 
> Then online it:
> 
>   # echo 1 > /sys/devices/system/cpu/cpu1/online
>   # cat cpuset.cpus
>   0-1
>   # cat cpuset.effective_cpus
>   0-1
> 
> And cpuset will bring it back to the effective mask.
> 
> This is a behavior change for sane_behavior.

It'd be great if the patch description also explains "how".

> +static void hotplug_update_tasks_insane(struct cpuset *cs,
> +					struct cpumask *off_cpus,
> +					nodemask_t *off_mems)
> +{
> +	bool is_empty;
> +
> +	cpumask_andnot(off_cpus, cs->real_cpus_allowed,
> +		       top_cpuset.real_cpus_allowed);
> +	nodes_andnot(*off_mems, cs->real_mems_allowed,
> +		     top_cpuset.real_mems_allowed);
> +
> +	mutex_lock(&callback_mutex);
> +	cpumask_andnot(cs->cpus_allowed, cs->cpus_allowed, off_cpus);
> +	cpumask_andnot(cs->real_cpus_allowed, cs->real_cpus_allowed, off_cpus);
> +	nodes_andnot(cs->mems_allowed, cs->mems_allowed, *off_mems);
> +	nodes_andnot(cs->real_mems_allowed, cs->real_mems_allowed, *off_mems);
> +	mutex_unlock(&callback_mutex);
> +
> +	/*
> +	 * Don't call update_tasks_cpumask() if the cpuset becomes empty,
> +	 * as the tasks will be migrated to an ancestor.
> +	 */
> +	if (!cpumask_empty(off_cpus) && !cpumask_empty(cs->cpus_allowed))
> +		update_tasks_cpumask(cs, NULL);
> +
> +	if (!nodes_empty(*off_mems) && !cpumask_empty(cs->cpus_allowed))
> +		update_tasks_nodemask(cs, NULL);
> +
> +	is_empty = cpumask_empty(cs->cpus_allowed) ||
> +		   nodes_empty(cs->mems_allowed);
> +
> +	mutex_unlock(&cpuset_mutex);
> +	/*
> +	 * Move tasks to the nearest ancestor with execution resources,
> +	 * This is full cgroup operation which will also call back into
> +	 * cpuset. Should be don outside any lock.
> +	 */
> +	if (is_empty)
> +		remove_tasks_in_empty_cpuset(cs);
> +	mutex_lock(&cpuset_mutex);
> +}

Maybe the patch would be easier to follow if factoring out the above
was in a separate patch?

Thanks.

-- 
tejun
