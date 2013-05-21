From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/5] device_cgroup: simplify cgroup tree walk in
	propagate_exception()
Date: Tue, 21 May 2013 17:35:44 -0500
Message-ID: <20130521223544.GA32316@tp>
References: <1369101025-28335-1-git-send-email-tj@kernel.org>
	<1369101025-28335-6-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1369101025-28335-6-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> During a config change, propagate_exception() needs to traverse the
> subtree to update config on the subtree.  Because such config updates
> need to allocate memory, it couldn't directly use
> cgroup_for_each_descendant_pre() which required the whole iteration to
> be contained in a single RCU read critical section.  To work around
> the limitation, propagate_exception() built a linked list of
> descendant cgroups while read-locking RCU and then walked the list
> afterwards, which is safe as the whole iteration is protected by
> devcgroup_mutex.  This works but is cumbersome.
> 
> With the recent updates, cgroup iterators now allow dropping RCU read
> lock while iteration is in progress making this workaround no longer
> necessary.  This patch replaces dev_cgroup->propagate_pending list and
> get_online_devcg() with direct cgroup_for_each_descendant_pre() walk.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

> ---
>  security/device_cgroup.c | 56 ++++++++++++++++--------------------------------
>  1 file changed, 18 insertions(+), 38 deletions(-)
> 
> diff --git a/security/device_cgroup.c b/security/device_cgroup.c
> index dd0dc57..e8aad69 100644
> --- a/security/device_cgroup.c
> +++ b/security/device_cgroup.c
> @@ -49,8 +49,6 @@ struct dev_cgroup {
>  	struct cgroup_subsys_state css;
>  	struct list_head exceptions;
>  	enum devcg_behavior behavior;
> -	/* temporary list for pending propagation operations */
> -	struct list_head propagate_pending;
>  };
>  
>  static inline struct dev_cgroup *css_to_devcgroup(struct cgroup_subsys_state *s)
> @@ -241,7 +239,6 @@ static struct cgroup_subsys_state *devcgroup_css_alloc(struct cgroup *cgroup)
>  	if (!dev_cgroup)
>  		return ERR_PTR(-ENOMEM);
>  	INIT_LIST_HEAD(&dev_cgroup->exceptions);
> -	INIT_LIST_HEAD(&dev_cgroup->propagate_pending);
>  	dev_cgroup->behavior = DEVCG_DEFAULT_NONE;
>  
>  	return &dev_cgroup->css;
> @@ -445,34 +442,6 @@ static void revalidate_active_exceptions(struct dev_cgroup *devcg)
>  }
>  
>  /**
> - * get_online_devcg - walks the cgroup tree and fills a list with the online
> - * 		      groups
> - * @root: cgroup used as starting point
> - * @online: list that will be filled with online groups
> - *
> - * Must be called with devcgroup_mutex held. Grabs RCU lock.
> - * Because devcgroup_mutex is held, no devcg will become online or offline
> - * during the tree walk (see devcgroup_online, devcgroup_offline)
> - * A separated list is needed because propagate_behavior() and
> - * propagate_exception() need to allocate memory and can block.
> - */
> -static void get_online_devcg(struct cgroup *root, struct list_head *online)
> -{
> -	struct cgroup *pos;
> -	struct dev_cgroup *devcg;
> -
> -	lockdep_assert_held(&devcgroup_mutex);
> -
> -	rcu_read_lock();
> -	cgroup_for_each_descendant_pre(pos, root) {
> -		devcg = cgroup_to_devcgroup(pos);
> -		if (is_devcg_online(devcg))
> -			list_add_tail(&devcg->propagate_pending, online);
> -	}
> -	rcu_read_unlock();
> -}
> -
> -/**
>   * propagate_exception - propagates a new exception to the children
>   * @devcg_root: device cgroup that added a new exception
>   * @ex: new exception to be propagated
> @@ -482,15 +451,24 @@ static void get_online_devcg(struct cgroup *root, struct list_head *online)
>  static int propagate_exception(struct dev_cgroup *devcg_root,
>  			       struct dev_exception_item *ex)
>  {
> -	struct cgroup *root = devcg_root->css.cgroup;
> -	struct dev_cgroup *devcg, *parent, *tmp;
> +	struct cgroup *root = devcg_root->css.cgroup, *pos;
>  	int rc = 0;
> -	LIST_HEAD(pending);
>  
> -	get_online_devcg(root, &pending);
> +	rcu_read_lock();
>  
> -	list_for_each_entry_safe(devcg, tmp, &pending, propagate_pending) {
> -		parent = cgroup_to_devcgroup(devcg->css.cgroup->parent);
> +	cgroup_for_each_descendant_pre(pos, root) {
> +		struct dev_cgroup *devcg = cgroup_to_devcgroup(pos);
> +
> +		/*
> +		 * Because devcgroup_mutex is held, no devcg will become
> +		 * online or offline during the tree walk (see on/offline
> +		 * methods), and online ones are safe to access outside RCU
> +		 * read lock without bumping refcnt.
> +		 */
> +		if (!is_devcg_online(devcg))
> +			continue;
> +
> +		rcu_read_unlock();
>  
>  		/*
>  		 * in case both root's behavior and devcg is allow, a new
> @@ -512,8 +490,10 @@ static int propagate_exception(struct dev_cgroup *devcg_root,
>  		}
>  		revalidate_active_exceptions(devcg);
>  
> -		list_del_init(&devcg->propagate_pending);
> +		rcu_read_lock();
>  	}
> +
> +	rcu_read_unlock();
>  	return rc;
>  }
>  
> -- 
> 1.8.1.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
