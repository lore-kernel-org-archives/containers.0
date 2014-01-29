From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/6] cgroup: drop module support
Date: Wed, 29 Jan 2014 12:16:38 +0800
Message-ID: <52E880A6.4040902@huawei.com>
References: <1390952641-15950-1-git-send-email-tj@kernel.org>
	<1390952641-15950-3-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390952641-15950-3-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

>  /**
> - * for_each_subsys - iterate all loaded cgroup subsystems
> + * for_each_subsys - iterate all enabled cgroup subsystems
>   * @ss: the iteration cursor
>   * @ssid: the index of @ss, CGROUP_SUBSYS_COUNT after reaching the end
> - *
> - * Iterates through all loaded subsystems.  Should be called under
> - * cgroup_mutex or cgroup_root_mutex.
>   */
>  #define for_each_subsys(ss, ssid)					\
> -	for (({ cgroup_assert_mutex_or_root_locked(); (ssid) = 0; });	\
> -	     (ssid) < CGROUP_SUBSYS_COUNT; (ssid)++)			\
> -		if (!((ss) = cgroup_subsys[(ssid)])) { }		\
> -		else
> -
> -/**
> - * for_each_builtin_subsys - iterate all built-in cgroup subsystems
> - * @ss: the iteration cursor
> - * @i: the index of @ss, CGROUP_BUILTIN_SUBSYS_COUNT after reaching the end
> - *
> - * Bulit-in subsystems are always present and iteration itself doesn't
> - * require any synchronization.
> - */
> -#define for_each_builtin_subsys(ss, i)					\
> -	for ((i) = 0; (i) < CGROUP_BUILTIN_SUBSYS_COUNT &&		\
> -	     (((ss) = cgroup_subsys[i]) || true); (i)++)
> +	for ((ssid) = 0; (ssid) < CGROUP_SUBSYS_COUNT &&		\
> +	     (((ss) = cgroup_subsys[ssid]) || true); (ssid)++)

Now cgroup_subsys[i] won't be NULL, so we can drop "|| true".

>  
>  /* iterate across the active hierarchies */
>  #define for_each_active_root(root)					\
> @@ -975,50 +951,24 @@ static void cgroup_d_remove_dir(struct dentry *dentry)
>  	remove_dir(dentry);
>  }
>  

...

> -	if (need_forkexit_callback) {
> -		/*
> -		 * fork/exit callbacks are supported only for builtin
> -		 * subsystems, and the builtin section of the subsys
> -		 * array is immutable, so we don't need to lock the
> -		 * subsys array here. On the other hand, modular section
> -		 * of the array can be freed at module unload, so we
> -		 * can't touch that.
> -		 */
> -		for_each_builtin_subsys(ss, i)
> +	if (need_forkexit_callback)
> +		for_each_subsys(ss, i)
>  			if (ss->fork)
>  				ss->fork(child);
> -	}

This looks a bit ugly. How about leaving the parentheses for the
outmost if statement?

if (need_forkexit_callback) {
	for_each_subsys(ss, i)
		if (ss->fork)
			ss->fork(child);
}
