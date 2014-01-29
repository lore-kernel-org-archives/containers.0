From: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/6] cgroup: clean up cgroup_subsys names and
	initialization
Date: Wed, 29 Jan 2014 11:23:26 -0500
Message-ID: <20140129162325.GI15457@redhat.com>
References: <1390952641-15950-1-git-send-email-tj@kernel.org>
	<1390952641-15950-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1390952641-15950-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

> --- a/security/device_cgroup.c
> +++ b/security/device_cgroup.c
> @@ -58,11 +58,9 @@ static inline struct dev_cgroup *css_to_devcgroup(struct cgroup_subsys_state *s)
>  
>  static inline struct dev_cgroup *task_devcgroup(struct task_struct *task)
>  {
> -	return css_to_devcgroup(task_css(task, devices_subsys_id));
> +	return css_to_devcgroup(task_css(task, devices_cgrp_id));
>  }
>  
> -struct cgroup_subsys devices_subsys;
> -
>  /*
>   * called under devcgroup_mutex
>   */
> @@ -684,13 +682,11 @@ static struct cftype dev_cgroup_files[] = {
>  	{ }	/* terminate */
>  };
>  
> -struct cgroup_subsys devices_subsys = {
> -	.name = "devices",
> +struct cgroup_subsys devices_cgrp_subsys = {
>  	.css_alloc = devcgroup_css_alloc,
>  	.css_free = devcgroup_css_free,
>  	.css_online = devcgroup_online,
>  	.css_offline = devcgroup_offline,
> -	.subsys_id = devices_subsys_id,
>  	.base_cftypes = dev_cgroup_files,
>  };

ACK

-- 
Aristeu
