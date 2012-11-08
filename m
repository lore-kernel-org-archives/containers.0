From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 3/9] cgroup: implement generic child / descendant walk
	macros
Date: Thu, 8 Nov 2012 10:50:13 +0100
Message-ID: <20121108095013.GA31821@dhcp22.suse.cz>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351931915-1701-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat 03-11-12 01:38:29, Tejun Heo wrote:
> Currently, cgroup doesn't provide any generic helper for walking a
> given cgroup's children or descendants.  This patch adds the following
> three macros.
> 
> * cgroup_for_each_child() - walk immediate children of a cgroup.
> 
> * cgroup_for_each_descendant_pre() - visit all descendants of a cgroup
>   in pre-order tree traversal.
> 
> * cgroup_for_each_descendant_post() - visit all descendants of a
>   cgroup in post-order tree traversal.
> 
> All three only require the user to hold RCU read lock during
> traversal.  Verifying that each iterated cgroup is online is the
> responsibility of the user.  When used with proper synchronization,
> cgroup_for_each_descendant_pre() can be used to propagate config
> updates to descendants in reliable way.  See comments for details.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

I will convert mem_cgroup_iter to use this rather than css_get_next
after this gets into the next tree so that it can fly via Andrew.

Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

Just a minor knit. You are talking about a config propagation while I
would consider state propagation more clear and less confusing. Config
is usually stable enough so that post_create is not necessary for
syncing (e.g. memcg.swappiness). It is a state which must be consistent
throughout the hierarchy which matters here.

Thanks!

> ---
>  include/linux/cgroup.h | 82 +++++++++++++++++++++++++++++++++++++++++++++++
>  kernel/cgroup.c        | 86 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 168 insertions(+)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 90c33eb..0020329 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -534,6 +534,88 @@ static inline struct cgroup* task_cgroup(struct task_struct *task,
>  	return task_subsys_state(task, subsys_id)->cgroup;
>  }
>  
> +/**
> + * cgroup_for_each_child - iterate through children of a cgroup
> + * @pos: the cgroup * to use as the loop cursor
> + * @cgroup: cgroup whose children to walk
> + *
> + * Walk @cgroup's children.  Must be called under rcu_read_lock().  A child
> + * cgroup which hasn't finished ->post_create() or already has finished
> + * ->pre_destroy() may show up during traversal and it's each subsystem's
> + * responsibility to verify that each @pos is alive.
> + *
> + * If a subsystem synchronizes against the parent in its ->post_create()
> + * and before starting iterating, a cgroup which finished ->post_create()
> + * is guaranteed to be visible in the future iterations.
> + */
> +#define cgroup_for_each_child(pos, cgroup)				\
> +	list_for_each_entry_rcu(pos, &(cgroup)->children, sibling)
> +
> +struct cgroup *cgroup_next_descendant_pre(struct cgroup *pos,
> +					  struct cgroup *cgroup);
> +
> +/**
> + * cgroup_for_each_descendant_pre - pre-order walk of a cgroup's descendants
> + * @pos: the cgroup * to use as the loop cursor
> + * @cgroup: cgroup whose descendants to walk
> + *
> + * Walk @cgroup's descendants.  Must be called under rcu_read_lock().  A
> + * descendant cgroup which hasn't finished ->post_create() or already has
> + * finished ->pre_destroy() may show up during traversal and it's each
> + * subsystem's responsibility to verify that each @pos is alive.
> + *
> + * If a subsystem synchronizes against the parent in its ->post_create()
> + * and before starting iterating, and synchronizes against @pos on each
> + * iteration, any descendant cgroup which finished ->post_create() is
> + * guaranteed to be visible in the future iterations.
> + *
> + * In other words, the following guarantees that a descendant can't escape
> + * configuration of its ancestors.
> + *
> + * my_post_create(@cgrp)
> + * {
> + *	Lock @cgrp->parent and @cgrp;
> + *	Inherit config from @cgrp->parent;
> + *	Unlock both.
> + * }
> + *
> + * my_update_config(@cgrp)
> + * {
> + *	Lock @cgrp;
> + *	Update @cgrp's config;
> + *	Unlock @cgrp;
> + *
> + *	cgroup_for_each_descendant_pre(@pos, @cgrp) {
> + *		Lock @pos;
> + *		Verify @pos is alive and inherit config from @pos->parent;
> + *		Unlock @pos;
> + *	}
> + * }
> + *
> + * Alternatively, a subsystem may choose to use a single global lock to
> + * synchronize ->post_create() and ->pre_destroy() against tree-walking
> + * operations.
> + */
> +#define cgroup_for_each_descendant_pre(pos, cgroup)			\
> +	for (pos = cgroup_next_descendant_pre(NULL, (cgroup)); (pos);	\
> +	     pos = cgroup_next_descendant_pre((pos), (cgroup)))
> +
> +struct cgroup *cgroup_next_descendant_post(struct cgroup *pos,
> +					   struct cgroup *cgroup);
> +
> +/**
> + * cgroup_for_each_descendant_post - post-order walk of a cgroup's descendants
> + * @pos: the cgroup * to use as the loop cursor
> + * @cgroup: cgroup whose descendants to walk
> + *
> + * Similar to cgroup_for_each_descendant_pre() but performs post-order
> + * traversal instead.  Note that the walk visibility guarantee described in
> + * pre-order walk doesn't apply the same to post-order walks.
> + */
> +#define cgroup_for_each_descendant_post(pos, cgroup)			\
> +	for (pos = cgroup_next_descendant_post(NULL, (cgroup)); (pos);	\
> +	     pos = cgroup_next_descendant_post((pos), (cgroup)))
> +
>  /* A cgroup_iter should be treated as an opaque object */
>  struct cgroup_iter {
>  	struct list_head *cg_link;
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index cc5d2a0..8bd662c 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2985,6 +2985,92 @@ static void cgroup_enable_task_cg_lists(void)
>  	write_unlock(&css_set_lock);
>  }
>  
> +/**
> + * cgroup_next_descendant_pre - find the next descendant for pre-order walk
> + * @pos: the current position (%NULL to initiate traversal)
> + * @cgroup: cgroup whose descendants to walk
> + *
> + * To be used by cgroup_for_each_descendant_pre().  Find the next
> + * descendant to visit for pre-order traversal of @cgroup's descendants.
> + */
> +struct cgroup *cgroup_next_descendant_pre(struct cgroup *pos,
> +					  struct cgroup *cgroup)
> +{
> +	struct cgroup *next;
> +
> +	WARN_ON_ONCE(!rcu_read_lock_held());
> +
> +	/* if first iteration, pretend we just visited @cgroup */
> +	if (!pos) {
> +		if (list_empty(&cgroup->children))
> +			return NULL;
> +		pos = cgroup;
> +	}
> +
> +	/* visit the first child if exists */
> +	next = list_first_or_null_rcu(&pos->children, struct cgroup, sibling);
> +	if (next)
> +		return next;
> +
> +	/* no child, visit my or the closest ancestor's next sibling */
> +	do {
> +		next = list_entry_rcu(pos->sibling.next, struct cgroup,
> +				      sibling);
> +		if (&next->sibling != &pos->parent->children)
> +			return next;
> +
> +		pos = pos->parent;
> +	} while (pos != cgroup);
> +
> +	return NULL;
> +}
> +EXPORT_SYMBOL_GPL(cgroup_next_descendant_pre);
> +
> +static struct cgroup *cgroup_leftmost_descendant(struct cgroup *pos)
> +{
> +	struct cgroup *last;
> +
> +	do {
> +		last = pos;
> +		pos = list_first_or_null_rcu(&pos->children, struct cgroup,
> +					     sibling);
> +	} while (pos);
> +
> +	return last;
> +}
> +
> +/**
> + * cgroup_next_descendant_post - find the next descendant for post-order walk
> + * @pos: the current position (%NULL to initiate traversal)
> + * @cgroup: cgroup whose descendants to walk
> + *
> + * To be used by cgroup_for_each_descendant_post().  Find the next
> + * descendant to visit for post-order traversal of @cgroup's descendants.
> + */
> +struct cgroup *cgroup_next_descendant_post(struct cgroup *pos,
> +					   struct cgroup *cgroup)
> +{
> +	struct cgroup *next;
> +
> +	WARN_ON_ONCE(!rcu_read_lock_held());
> +
> +	/* if first iteration, visit the leftmost descendant */
> +	if (!pos) {
> +		next = cgroup_leftmost_descendant(cgroup);
> +		return next != cgroup ? next : NULL;
> +	}
> +
> +	/* if there's an unvisited sibling, visit its leftmost descendant */
> +	next = list_entry_rcu(pos->sibling.next, struct cgroup, sibling);
> +	if (&next->sibling != &pos->parent->children)
> +		return cgroup_leftmost_descendant(next);
> +
> +	/* no sibling left, visit parent */
> +	next = pos->parent;
> +	return next != cgroup ? next : NULL;
> +}
> +EXPORT_SYMBOL_GPL(cgroup_next_descendant_post);
> +
>  void cgroup_iter_start(struct cgroup *cgrp, struct cgroup_iter *it)
>  	__acquires(css_set_lock)
>  {
> -- 
> 1.7.11.7
> 

-- 
Michal Hocko
SUSE Labs
