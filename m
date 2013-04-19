From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 09/10] cpuset: allow to keep tasks in empty cpusets
Date: Fri, 19 Apr 2013 13:58:21 -0700
Message-ID: <20130419205821.GA15543@mtj.dyndns.org>
References: <517137A7.4020605@huawei.com>
 <517138A4.3070209@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <517138A4.3070209-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

Hello,

On Fri, Apr 19, 2013 at 08:29:24PM +0800, Li Zefan wrote:
> +static void update_tasks_cpumask_hier(struct cpuset *root_cs,
> +				      bool update_root, struct ptr_heap *heap)
> +{
> +	struct cpuset *cp;
> +	struct cgroup *pos_cgrp;
> +
> +	if (update_root)
> +		update_tasks_cpumask(root_cs, heap);
> +
> +	rcu_read_lock();
> +	cpuset_for_each_descendant_pre(cp, pos_cgrp, root_cs) {
> +		/* skip the whole subtree if @cp have some CPU */
> +		if (!cpumask_empty(cp->cpus_allowed)) {
> +			pos_cgrp = cgroup_rightmost_descendant(pos_cgrp);
> +			continue;
> +		}
> +
> +		update_tasks_cpumask(cp, heap);
> +	}
> +	rcu_read_unlock();

I don't think we can call update_tasks_cpumask() under
rcu_read_lock().  It calls into set_cpus_allowed_ptr() which may
block, so you'll probably have to punt it to a work item like how
migration is being done.  Another approach would be converting cgroup
to use SRCU instead, which would lessen pain on other places too.  The
only problem there would be that srcu_read_lock() is a bit more
expensive than rcu_read_lock().  I'm not sure whether that'd show up
in some hot path or not.  Ideas?

Thanks.

-- 
tejun
