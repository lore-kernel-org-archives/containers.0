From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.7] cgroup: mark subsystems with broken
	hierarchy support and whine if cgroups are nested for them
Date: Thu, 13 Sep 2012 20:46:53 +0200
Message-ID: <20120913184653.GA22529@dhcp22.suse.cz>
References: <20120913183402.GG7677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120913183402.GG7677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu 13-09-12 11:34:02, Tejun Heo wrote:
[...]
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -4075,8 +4075,18 @@ static long cgroup_create(struct cgroup 
>  		set_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
>  
>  	for_each_subsys(root, ss) {
> -		struct cgroup_subsys_state *css = ss->create(cgrp);
> +		struct cgroup_subsys_state *css;
> +
> +		if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
> +		    parent->parent) {
> +			pr_warning("cgroup: %s (%d) created nested cgroup for controller \"%s\" which has incomplete hierarchy support. Nested cgroups may change behavior in the future.\n",
> +				   current->comm, current->pid, ss->name);
> +			if (!strcmp(ss->name, "memory"))
> +				pr_warning("cgroup: \"memory\" requires setting use_hierarchy to 1 on the root.\n");
> +			ss->warned_broken_hierarchy = true;
> +		}
>  
> +		css = ss->create(cgrp);

As I said in other email. We have to move the warning after the create
callback or you will not give any chance to the controller to say
whether broken_hierarchy is really the case here.

[...]
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3855,12 +3855,17 @@ static int mem_cgroup_hierarchy_write(st
>  	 */
>  	if ((!parent_memcg || !parent_memcg->use_hierarchy) &&
>  				(val == 1 || val == 0)) {
> -		if (list_empty(&cont->children))
> +		if (list_empty(&cont->children)) {
>  			memcg->use_hierarchy = val;
> -		else
> +			/* we're fully hierarchical iff root uses hierarchy */
> +			if (mem_cgroup_is_root(memcg))
> +				mem_cgroup_subsys.broken_hierarchy = !val;

This is not necessary because mem_cgroup_create will take care of the
proper broken_hierarchy setting.

> +		} else {
>  			retval = -EBUSY;
> -	} else
> +		}
> +	} else {
>  		retval = -EINVAL;
> +	}
>  
>  out:
>  	cgroup_unlock();
> @@ -4973,6 +4978,13 @@ mem_cgroup_create(struct cgroup *cont)
>  	} else {
>  		res_counter_init(&memcg->res, NULL);
>  		res_counter_init(&memcg->memsw, NULL);
> +		/*
> +		 * Deeper hierachy with use_hierarchy == false doesn't make
> +		 * much sense so let cgroup subsystem know about this
> +		 * unfortunate state in our controller.
> +		 */
> +		if (parent && parent != root_mem_cgroup)
> +			mem_cgroup_subsys.broken_hierarchy = true;

This should be sufficient.

>  	}
>  	memcg->last_scanned_node = MAX_NUMNODES;
>  	INIT_LIST_HEAD(&memcg->oom_notify);

-- 
Michal Hocko
SUSE Labs
