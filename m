From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 4/4] cgroup: remove extra calls to find_existing_css_set
Date: Thu, 22 Dec 2011 13:50:46 +0800
Message-ID: <4EF2C536.7070408__3436.40323631025$1324532941$gmane$org@cn.fujitsu.com>
References: <1324527518-24461-1-git-send-email-msb@chromium.org>
	<1324527518-24461-4-git-send-email-msb@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1324527518-24461-4-git-send-email-msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
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
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

> @@ -2091,6 +2010,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
>  	 * rcu or tasklist locked. instead, build an array of all threads in the
>  	 * group - group_rwsem prevents new threads from appearing, and if
>  	 * threads exit, this will just be an over-estimate.
> +	 *
> +	 * While creating the list, also make sure css_sets exist for all
> +	 * threads to be migrated. we use find_css_set, which allocates a new
> +	 * one if necessary.
>  	 */
>  	group_size = get_nr_threads(leader);
>  	/* flex_array supports very large thread-groups better than kmalloc. */
> @@ -2137,6 +2060,12 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
>  		/* nothing to do if this task is already in the cgroup */
>  		if (ent.cgrp == cgrp)
>  			continue;
> +		ent.cg = find_css_set(tsk->cgroups, cgrp);

unfortunately This won't work, because we are holding tasklist_lock.

> +		if (!ent.cg) {
> +			retval = -ENOMEM;
> +			group_size = i;
> +			goto out_list_teardown;
> +		}
>  		retval = flex_array_put(group, i, &ent, GFP_ATOMIC);
>  		BUG_ON(retval != 0);
>  		i++;
