From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 4/5] cgroup: remove extra calls to find_existing_css_set
Date: Tue, 20 Dec 2011 15:30:50 -0800
Message-ID: <20111220233050.GM10752__10878.5723489293$1324423869$gmane$org@google.com>
References: <1324422873-31001-1-git-send-email-msb@chromium.org>
	<1324422873-31001-5-git-send-email-msb@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1324422873-31001-5-git-send-email-msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Tue, Dec 20, 2011 at 03:14:32PM -0800, Mandeep Singh Baines wrote:
> @@ -1942,9 +1917,17 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
>  		}
>  	}
>  
> -	retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, false);
> -	if (retval)
> +	task_lock(tsk);
> +	oldcg = tsk->cgroups;
> +	task_unlock(tsk);

Probably this is patch order issue w/ Frederic's patch but we don't
need task_lock here, right?

> @@ -2171,17 +2088,18 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
>  	 * step 2: make sure css_sets exist for all threads to be migrated.
>  	 * we use find_css_set, which allocates a new one if necessary.
>  	 */
> -	INIT_LIST_HEAD(&newcg_list);
>  	for (i = 0; i < group_size; i++) {
>  		tc = flex_array_get(group, i);
>  		/* get old css_set pointer */
>  		task_lock(tc->task);
>  		oldcg = tc->task->cgroups;
>  		task_unlock(tc->task);
> -		/* if we don't already have it in the list get a new one */
> -		if (!css_set_fetched(cgrp, tc->task, oldcg, &newcg_list))
> -			if (retval = css_set_prefetch(cgrp, oldcg, &newcg_list))
> -				goto out_list_teardown;
> +		tc->cg = find_css_set(oldcg, cgrp);
> +		if (!tc->cg) {
> +			retval = -ENOMEM;
> +			css_set_refs = i + 1;
> +			goto out_list_teardown;
> +		}

Nice cleanup, but can't the above be merged into the loop which builds
the flex array?

Thanks.

-- 
tejun
