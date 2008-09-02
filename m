From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -mm] devcgroup: remove spin_lock()
Date: Tue, 2 Sep 2008 09:56:43 -0500
Message-ID: <20080902145642.GA8524@us.ibm.com>
References: <48BBB36A.1030807@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48BBB36A.1030807-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Lai Jiangshan (laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> Since we introduced rcu for read side, spin_lock is used only for
> update. But we always hold cgroup_lock() when update, so spin_lock()
> is not need.
> 
> Additional cleanup:
> 1) include linux/rcupdate.h explicitly
> 2) remove unused variable cur_devcgroup in devcgroup_update_access()
> 
> Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

It might be worth adding a comment over parent_has_perm that it is
called under cgroup_lock().  Also, the comment above
may_access_whitelist() saying 'call with c->lock held' should be
updated.

But the patch looks correct.

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

thanks,
-serge

> ---
> diff --git a/security/device_cgroup.c b/security/device_cgroup.c
> index d5c15a7..5ba7870 100644
> --- a/security/device_cgroup.c
> +++ b/security/device_cgroup.c
> @@ -1,5 +1,5 @@
>  /*
> - * dev_cgroup.c - device cgroup subsystem
> + * device_cgroup.c - device cgroup subsystem
>   *
>   * Copyright 2007 IBM Corp
>   */
> @@ -10,6 +10,7 @@
>  #include <linux/list.h>
>  #include <linux/uaccess.h>
>  #include <linux/seq_file.h>
> +#include <linux/rcupdate.h>
> 
>  #define ACC_MKNOD 1
>  #define ACC_READ  2
> @@ -22,18 +23,8 @@
> 
>  /*
>   * whitelist locking rules:
> - * cgroup_lock() cannot be taken under dev_cgroup->lock.
> - * dev_cgroup->lock can be taken with or without cgroup_lock().
> - *
> - * modifications always require cgroup_lock
> - * modifications to a list which is visible require the
> - *   dev_cgroup->lock *and* cgroup_lock()
> - * walking the list requires dev_cgroup->lock or cgroup_lock().
> - *
> - * reasoning: dev_whitelist_copy() needs to kmalloc, so needs
> - *   a mutex, which the cgroup_lock() is.  Since modifying
> - *   a visible list requires both locks, either lock can be
> - *   taken for walking the list.
> + * hold cgroup_lock() for update/read.
> + * hold rcu_read_lock() for read.
>   */
> 
>  struct dev_whitelist_item {
> @@ -47,7 +38,6 @@ struct dev_whitelist_item {
>  struct dev_cgroup {
>  	struct cgroup_subsys_state css;
>  	struct list_head whitelist;
> -	spinlock_t lock;
>  };
> 
>  static inline struct dev_cgroup *css_to_devcgroup(struct cgroup_subsys_state *s)
> @@ -103,7 +93,6 @@ free_and_exit:
>  /* Stupid prototype - don't bother combining existing entries */
>  /*
>   * called under cgroup_lock()
> - * since the list is visible to other tasks, we need the spinlock also
>   */
>  static int dev_whitelist_add(struct dev_cgroup *dev_cgroup,
>  			struct dev_whitelist_item *wh)
> @@ -114,7 +103,6 @@ static int dev_whitelist_add(struct dev_cgroup *dev_cgroup,
>  	if (!whcopy)
>  		return -ENOMEM;
> 
> -	spin_lock(&dev_cgroup->lock);
>  	list_for_each_entry(walk, &dev_cgroup->whitelist, list) {
>  		if (walk->type != wh->type)
>  			continue;
> @@ -130,7 +118,6 @@ static int dev_whitelist_add(struct dev_cgroup *dev_cgroup,
> 
>  	if (whcopy != NULL)
>  		list_add_tail_rcu(&whcopy->list, &dev_cgroup->whitelist);
> -	spin_unlock(&dev_cgroup->lock);
>  	return 0;
>  }
> 
> @@ -144,14 +131,12 @@ static void whitelist_item_free(struct rcu_head *rcu)
> 
>  /*
>   * called under cgroup_lock()
> - * since the list is visible to other tasks, we need the spinlock also
>   */
>  static void dev_whitelist_rm(struct dev_cgroup *dev_cgroup,
>  			struct dev_whitelist_item *wh)
>  {
>  	struct dev_whitelist_item *walk, *tmp;
> 
> -	spin_lock(&dev_cgroup->lock);
>  	list_for_each_entry_safe(walk, tmp, &dev_cgroup->whitelist, list) {
>  		if (walk->type == DEV_ALL)
>  			goto remove;
> @@ -169,7 +154,6 @@ remove:
>  			call_rcu(&walk->rcu, whitelist_item_free);
>  		}
>  	}
> -	spin_unlock(&dev_cgroup->lock);
>  }
> 
>  /*
> @@ -209,7 +193,6 @@ static struct cgroup_subsys_state *devcgroup_create(struct cgroup_subsys *ss,
>  		}
>  	}
> 
> -	spin_lock_init(&dev_cgroup->lock);
>  	return &dev_cgroup->css;
>  }
> 
> @@ -325,15 +308,11 @@ static int parent_has_perm(struct dev_cgroup *childcg,
>  {
>  	struct cgroup *pcg = childcg->css.cgroup->parent;
>  	struct dev_cgroup *parent;
> -	int ret;
> 
>  	if (!pcg)
>  		return 1;
>  	parent = cgroup_to_devcgroup(pcg);
> -	spin_lock(&parent->lock);
> -	ret = may_access_whitelist(parent, wh);
> -	spin_unlock(&parent->lock);
> -	return ret;
> +	return may_access_whitelist(parent, wh);
>  }
> 
>  /*
> @@ -352,7 +331,6 @@ static int parent_has_perm(struct dev_cgroup *childcg,
>  static int devcgroup_update_access(struct dev_cgroup *devcgroup,
>  				   int filetype, const char *buffer)
>  {
> -	struct dev_cgroup *cur_devcgroup;
>  	const char *b;
>  	char *endp;
>  	int count;
> @@ -361,8 +339,6 @@ static int devcgroup_update_access(struct dev_cgroup *devcgroup,
>  	if (!capable(CAP_SYS_ADMIN))
>  		return -EPERM;
> 
> -	cur_devcgroup = task_devcgroup(current);
> -
>  	memset(&wh, 0, sizeof(wh));
>  	b = buffer;
> 
