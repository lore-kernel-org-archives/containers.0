From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] inotify: Convert to using per-namespace limits
Date: Mon, 14 Nov 2016 00:04:16 -0600
Message-ID: <20161114060416.GA31521@mail.hallyn.com>
References: <20161010164046.GG24081@quack2.suse.cz>
	<1476171382-11911-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1476171382-11911-1-git-send-email-kernel-6AxghH7DbtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org, jack-AlSwsSmVLrQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 11, 2016 at 10:36:22AM +0300, Nikolay Borisov wrote:
> This patchset converts inotify to using the newly introduced
> per-userns sysctl infrastructure.
> 
> Currently the inotify instances/watches are being accounted in the
> user_struct structure. This means that in setups where multiple
> users in unprivileged containers map to the same underlying
> real user (i.e. pointing to the same user_struct) the inotify limits
> are going to be shared as well, allowing one user(or application) to exhaust
> all others limits.
> 
> Fix this by switching the inotify sysctls to using the
> per-namespace/per-user limits. This will allow the server admin to
> set sensible global limits, which can further be tuned inside every
> individual user namespace. Additionally, in order to preserve the
> sysctl ABI make the existing inotify instances/watches sysctls
> modify the values of the initial user namespace.
> 
> Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>

If I'm reading the existing ucounts code correctly, this looks
good, thanks.

Acked-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>


> ---
> 
> So here is a revised version which retains the existing sysctls,
> and hooks them to the init_user_ns values. 
> 
>  fs/notify/inotify/inotify.h          | 17 +++++++++++++++++
>  fs/notify/inotify/inotify_fsnotify.c |  6 ++----
>  fs/notify/inotify/inotify_user.c     | 34 +++++++++++++++++-----------------
>  include/linux/fsnotify_backend.h     |  3 ++-
>  include/linux/sched.h                |  4 ----
>  include/linux/user_namespace.h       |  4 ++++
>  kernel/ucount.c                      |  6 +++++-
>  7 files changed, 47 insertions(+), 27 deletions(-)
> 
> diff --git a/fs/notify/inotify/inotify.h b/fs/notify/inotify/inotify.h
> index ed855ef6f077..b5536f8ad3e0 100644
> --- a/fs/notify/inotify/inotify.h
> +++ b/fs/notify/inotify/inotify.h
> @@ -30,3 +30,20 @@ extern int inotify_handle_event(struct fsnotify_group *group,
>  				const unsigned char *file_name, u32 cookie);
>  
>  extern const struct fsnotify_ops inotify_fsnotify_ops;
> +
> +#ifdef CONFIG_INOTIFY_USER
> +static void dec_inotify_instances(struct ucounts *ucounts)
> +{
> +	dec_ucount(ucounts, UCOUNT_INOTIFY_INSTANCES);
> +}
> +
> +static struct ucounts *inc_inotify_watches(struct ucounts *ucounts)
> +{
> +	return inc_ucount(ucounts->ns, ucounts->uid, UCOUNT_INOTIFY_WATCHES);
> +}
> +
> +static void dec_inotify_watches(struct ucounts *ucounts)
> +{
> +	dec_ucount(ucounts, UCOUNT_INOTIFY_WATCHES);
> +}
> +#endif
> diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
> index 2cd900c2c737..1e6b3cfc2cfd 100644
> --- a/fs/notify/inotify/inotify_fsnotify.c
> +++ b/fs/notify/inotify/inotify_fsnotify.c
> @@ -165,10 +165,8 @@ static void inotify_free_group_priv(struct fsnotify_group *group)
>  	/* ideally the idr is empty and we won't hit the BUG in the callback */
>  	idr_for_each(&group->inotify_data.idr, idr_callback, group);
>  	idr_destroy(&group->inotify_data.idr);
> -	if (group->inotify_data.user) {
> -		atomic_dec(&group->inotify_data.user->inotify_devs);
> -		free_uid(group->inotify_data.user);
> -	}
> +	if (group->inotify_data.ucounts)
> +		dec_inotify_instances(group->inotify_data.ucounts);
>  }
>  
>  static void inotify_free_event(struct fsnotify_event *fsn_event)
> diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
> index b8d08d0d0a4d..7d769a824742 100644
> --- a/fs/notify/inotify/inotify_user.c
> +++ b/fs/notify/inotify/inotify_user.c
> @@ -44,10 +44,8 @@
>  
>  #include <asm/ioctls.h>
>  
> -/* these are configurable via /proc/sys/fs/inotify/ */
> -static int inotify_max_user_instances __read_mostly;
> +/* configurable via /proc/sys/fs/inotify/ */
>  static int inotify_max_queued_events __read_mostly;
> -static int inotify_max_user_watches __read_mostly;
>  
>  static struct kmem_cache *inotify_inode_mark_cachep __read_mostly;
>  
> @@ -60,7 +58,7 @@ static int zero;
>  struct ctl_table inotify_table[] = {
>  	{
>  		.procname	= "max_user_instances",
> -		.data		= &inotify_max_user_instances,
> +		.data		= &init_user_ns.ucount_max[UCOUNT_INOTIFY_INSTANCES],
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_minmax,
> @@ -68,7 +66,7 @@ struct ctl_table inotify_table[] = {
>  	},
>  	{
>  		.procname	= "max_user_watches",
> -		.data		= &inotify_max_user_watches,
> +		.data		= &init_user_ns.ucount_max[UCOUNT_INOTIFY_WATCHES],
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_minmax,
> @@ -500,7 +498,7 @@ void inotify_ignored_and_remove_idr(struct fsnotify_mark *fsn_mark,
>  	/* remove this mark from the idr */
>  	inotify_remove_from_idr(group, i_mark);
>  
> -	atomic_dec(&group->inotify_data.user->inotify_watches);
> +	dec_inotify_watches(group->inotify_data.ucounts);
>  }
>  
>  /* ding dong the mark is dead */
> @@ -584,14 +582,17 @@ static int inotify_new_watch(struct fsnotify_group *group,
>  	tmp_i_mark->fsn_mark.mask = mask;
>  	tmp_i_mark->wd = -1;
>  
> -	ret = -ENOSPC;
> -	if (atomic_read(&group->inotify_data.user->inotify_watches) >= inotify_max_user_watches)
> -		goto out_err;
> -
>  	ret = inotify_add_to_idr(idr, idr_lock, tmp_i_mark);
>  	if (ret)
>  		goto out_err;
>  
> +	/* increment the number of watches the user has */
> +	if (!inc_inotify_watches(group->inotify_data.ucounts)) {
> +		inotify_remove_from_idr(group, tmp_i_mark);
> +		ret = -ENOSPC;
> +		goto out_err;
> +	}
> +
>  	/* we are on the idr, now get on the inode */
>  	ret = fsnotify_add_mark_locked(&tmp_i_mark->fsn_mark, group, inode,
>  				       NULL, 0);
> @@ -601,8 +602,6 @@ static int inotify_new_watch(struct fsnotify_group *group,
>  		goto out_err;
>  	}
>  
> -	/* increment the number of watches the user has */
> -	atomic_inc(&group->inotify_data.user->inotify_watches);
>  
>  	/* return the watch descriptor for this new mark */
>  	ret = tmp_i_mark->wd;
> @@ -653,10 +652,11 @@ static struct fsnotify_group *inotify_new_group(unsigned int max_events)
>  
>  	spin_lock_init(&group->inotify_data.idr_lock);
>  	idr_init(&group->inotify_data.idr);
> -	group->inotify_data.user = get_current_user();
> +	group->inotify_data.ucounts = inc_ucount(current_user_ns(),
> +						 current_euid(),
> +						 UCOUNT_INOTIFY_INSTANCES);
>  
> -	if (atomic_inc_return(&group->inotify_data.user->inotify_devs) >
> -	    inotify_max_user_instances) {
> +	if (!group->inotify_data.ucounts) {
>  		fsnotify_destroy_group(group);
>  		return ERR_PTR(-EMFILE);
>  	}
> @@ -819,8 +819,8 @@ static int __init inotify_user_setup(void)
>  	inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark, SLAB_PANIC);
>  
>  	inotify_max_queued_events = 16384;
> -	inotify_max_user_instances = 128;
> -	inotify_max_user_watches = 8192;
> +	init_user_ns.ucount_max[UCOUNT_INOTIFY_INSTANCES] = 128;
> +	init_user_ns.ucount_max[UCOUNT_INOTIFY_WATCHES] = 8192;
>  
>  	return 0;
>  }
> diff --git a/include/linux/fsnotify_backend.h b/include/linux/fsnotify_backend.h
> index 58205f33af02..892959de1162 100644
> --- a/include/linux/fsnotify_backend.h
> +++ b/include/linux/fsnotify_backend.h
> @@ -16,6 +16,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/types.h>
>  #include <linux/atomic.h>
> +#include <linux/user_namespace.h>
>  
>  /*
>   * IN_* from inotfy.h lines up EXACTLY with FS_*, this is so we can easily
> @@ -169,7 +170,7 @@ struct fsnotify_group {
>  		struct inotify_group_private_data {
>  			spinlock_t	idr_lock;
>  			struct idr      idr;
> -			struct user_struct      *user;
> +			struct ucounts *ucounts;
>  		} inotify_data;
>  #endif
>  #ifdef CONFIG_FANOTIFY
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 62c68e513e39..35230a2c73ac 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -840,10 +840,6 @@ struct user_struct {
>  	atomic_t __count;	/* reference count */
>  	atomic_t processes;	/* How many processes does this user have? */
>  	atomic_t sigpending;	/* How many pending signals does this user have? */
> -#ifdef CONFIG_INOTIFY_USER
> -	atomic_t inotify_watches; /* How many inotify watches does this user have? */
> -	atomic_t inotify_devs;	/* How many inotify devs does this user have opened? */
> -#endif
>  #ifdef CONFIG_FANOTIFY
>  	atomic_t fanotify_listeners;
>  #endif
> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> index eb209d4523f5..cbcac7a5ec41 100644
> --- a/include/linux/user_namespace.h
> +++ b/include/linux/user_namespace.h
> @@ -32,6 +32,10 @@ enum ucount_type {
>  	UCOUNT_NET_NAMESPACES,
>  	UCOUNT_MNT_NAMESPACES,
>  	UCOUNT_CGROUP_NAMESPACES,
> +#ifdef CONFIG_INOTIFY_USER 
> +	UCOUNT_INOTIFY_INSTANCES,
> +	UCOUNT_INOTIFY_WATCHES,
> +#endif
>  	UCOUNT_COUNTS,
>  };
>  
> diff --git a/kernel/ucount.c b/kernel/ucount.c
> index 9d20d5dd298a..a6bcea47306b 100644
> --- a/kernel/ucount.c
> +++ b/kernel/ucount.c
> @@ -57,7 +57,7 @@ static struct ctl_table_root set_root = {
>  
>  static int zero = 0;
>  static int int_max = INT_MAX;
> -#define UCOUNT_ENTRY(name) 				\
> +#define UCOUNT_ENTRY(name)				\
>  	{						\
>  		.procname	= name,			\
>  		.maxlen		= sizeof(int),		\
> @@ -74,6 +74,10 @@ static struct ctl_table user_table[] = {
>  	UCOUNT_ENTRY("max_net_namespaces"),
>  	UCOUNT_ENTRY("max_mnt_namespaces"),
>  	UCOUNT_ENTRY("max_cgroup_namespaces"),
> +#ifdef CONFIG_INOTIFY_USER_
> +	UCOUNT_ENTRY("max_inotify_instances"),
> +	UCOUNT_ENTRY("max_inotify_watches"),
> +#endif
>  	{ }
>  };
>  #endif /* CONFIG_SYSCTL */
> -- 
> 2.5.0
