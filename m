From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: ns_can_attach (nsproxy cgroup)
Date: Sat, 13 Dec 2008 15:03:52 +0800
Message-ID: <49435E58.9050209@cn.fujitsu.com>
References: <20081212095153.GA20956@megiteam.pl>	<20081212140908.GA9571@us.ibm.com>
	<20081212213042.GA23581@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081212213042.GA23581-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

>  /**
> - * cgroup_is_descendant - see if @cgrp is a descendant of current task's cgrp
> + * cgroup_is_descendant - see if @cgrp is a descendant of @task's cgrp
>   * @cgrp: the cgroup in question
> + * @task: the task in question
> + * @subsys_id: cgroup subsystem id used to determine hierarchy; if negative,
> + * 		use get_first_subsys()

The last argument is redundant.

[...]

> -	orig = task_cgroup(task, ns_subsys_id);
> -	if (orig && orig != new_cgroup->parent)
> +	if (!cgroup_is_descendant(new_cgroup, task, ns_subsys_id))

It makes no difference with:
	if (!cgroup_is_descendant(new_cgroup, task, -1))

That's why we don't need argument 'subsys_id'.

>  		return -EPERM;
>  
>  	return 0;
> @@ -78,7 +75,7 @@ static struct cgroup_subsys_state *ns_create(struct cgroup_subsys *ss,
>  
>  	if (!capable(CAP_SYS_ADMIN))
>  		return ERR_PTR(-EPERM);
> -	if (!cgroup_is_descendant(cgroup))
> +	if (!cgroup_is_descendant(cgroup, current, -1))
>  		return ERR_PTR(-EPERM);
>  
>  	ns_cgroup = kzalloc(sizeof(*ns_cgroup), GFP_KERNEL);
