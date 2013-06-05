From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 08/10] cpuset: allow to keep tasks in empty cpusets
Date: Wed, 5 Jun 2013 13:51:46 -0700
Message-ID: <20130605205146.GI10693@mtj.dyndns.org>
References: <51AF0183.8070602@huawei.com>
 <51AF020B.3030701@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51AF020B.3030701-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

On Wed, Jun 05, 2013 at 05:16:59PM +0800, Li Zefan wrote:
> @@ -2092,11 +2183,13 @@ static void cpuset_propagate_hotplug_workfn(struct work_struct *work)
>  	mutex_unlock(&cpuset_mutex);
>  
>  	/*
> -	 * If @cs became empty, move tasks to the nearest ancestor with
> -	 * execution resources.  This is full cgroup operation which will
> +	 * If sane_behavior flag is set, we'll keep tasks in empty cpusets.
> +	 *
> +	 * Otherwise move tasks to the nearest ancestor with execution
> +	 *  resources.  This is full cgroup operation which will
>  	 * also call back into cpuset.  Should be done outside any lock.
>  	 */
> -	if (is_empty)
> +	if (!sane && is_empty)
>  		remove_tasks_in_empty_cpuset(cs);
>  
>  	/* the following may free @cs, should be the last operation */
> @@ -2171,6 +2264,7 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
>  		cpumask_copy(top_cpuset.cpus_allowed, &new_cpus);
>  		mutex_unlock(&callback_mutex);
>  		/* we don't mess with cpumasks of tasks in top_cpuset */
> +		update_tasks_cpumask_hier(&top_cpuset, false, NULL);
>  	}

I'm a little confused by the order of operation.  We now have two
different hierarchical walks for hotplug propagation, right?  I
suppose the above one is added because we now also need to update the
mask when cpus are being brought online?

I wonder whether it'd be possible to merge the two paths.  My
suspicion is that we probably don't need propagate_hotplug_work
anymore now that we can drop RCU read lock while doing the pre-order
walk.  What do you think?

Thanks.

-- 
tejun
