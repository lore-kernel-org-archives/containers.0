From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.12] cgroup: make css_for_each_descendant()
	and friends include the origin css in the iteration
Date: Thu, 8 Aug 2013 16:33:36 +0200
Message-ID: <20130808143336.GC3189__19681.7082506188$1375972432$gmane$org@dhcp22.suse.cz>
References: <20130804230703.GA12029@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130804230703.GA12029-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Ohh, this one totally sliped through cracs.

On Sun 04-08-13 19:07:03, Tejun Heo wrote:
[...]
> From 0e84b0865ab8a87f1c1443e4777c20c7f14e13b6 Mon Sep 17 00:00:00 2001
> From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Date: Sun, 4 Aug 2013 19:01:23 -0400
> 
> Previously, all css descendant iterators didn't include the origin
> (root of subtree) css in the iteration.  The reasons were maintaining
> consistency with css_for_each_child() and that at the time of
> introduction more use cases needed skipping the origin anyway;
> however, given that css_is_descendant() considers self to be a
> descendant, omitting the origin css has become more confusing and
> looking at the accumulated use cases rather clearly indicates that
> including origin would result in simpler code overall.
> 
> While this is a change which can easily lead to subtle bugs, cgroup
> API including the iterators has recently gone through major
> restructuring and no out-of-tree changes will be applicable without
> adjustments making this a relatively acceptable opportunity for this
> type of change.
> 
> The conversions are mostly straight-forward.  If the iteration block
> had explicit origin handling before or after, it's moved inside the
> iteration.  If not, if (pos == origin) continue; is added.  Some
> conversions add extra reference get/put around origin handling by
> consolidating origin handling and the rest.  While the extra ref
> operations aren't strictly necessary, this shouldn't cause any
> noticeable difference.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
> Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

yes I like it. I found it strange to omit the root during walk.
Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

> ---
>  block/blk-cgroup.c       |  8 ++------
>  block/blk-cgroup.h       |  4 +++-
>  block/blk-throttle.c     |  3 ---
>  include/linux/cgroup.h   | 17 +++++++++--------
>  kernel/cgroup.c          | 29 +++++++++++------------------
>  kernel/cgroup_freezer.c  | 29 ++++++++++++++++-------------
>  kernel/cpuset.c          | 42 ++++++++++++++++++++++++++----------------
>  mm/memcontrol.c          |  9 +--------
>  security/device_cgroup.c |  2 +-
>  9 files changed, 69 insertions(+), 74 deletions(-)
> 
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index 54ad002..e90c7c1 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -615,12 +615,10 @@ u64 blkg_stat_recursive_sum(struct blkg_policy_data *pd, int off)
>  	struct blkcg_policy *pol = blkcg_policy[pd->plid];
>  	struct blkcg_gq *pos_blkg;
>  	struct cgroup_subsys_state *pos_css;
> -	u64 sum;
> +	u64 sum = 0;
>  
>  	lockdep_assert_held(pd->blkg->q->queue_lock);
>  
> -	sum = blkg_stat_read((void *)pd + off);
> -
>  	rcu_read_lock();
>  	blkg_for_each_descendant_pre(pos_blkg, pos_css, pd_to_blkg(pd)) {
>  		struct blkg_policy_data *pos_pd = blkg_to_pd(pos_blkg, pol);
> @@ -650,13 +648,11 @@ struct blkg_rwstat blkg_rwstat_recursive_sum(struct blkg_policy_data *pd,
>  	struct blkcg_policy *pol = blkcg_policy[pd->plid];
>  	struct blkcg_gq *pos_blkg;
>  	struct cgroup_subsys_state *pos_css;
> -	struct blkg_rwstat sum;
> +	struct blkg_rwstat sum = { };
>  	int i;
>  
>  	lockdep_assert_held(pd->blkg->q->queue_lock);
>  
> -	sum = blkg_rwstat_read((void *)pd + off);
> -
>  	rcu_read_lock();
>  	blkg_for_each_descendant_pre(pos_blkg, pos_css, pd_to_blkg(pd)) {
>  		struct blkg_policy_data *pos_pd = blkg_to_pd(pos_blkg, pol);
> diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
> index 8555386..ae6969a 100644
> --- a/block/blk-cgroup.h
> +++ b/block/blk-cgroup.h
> @@ -291,6 +291,7 @@ struct blkcg_gq *__blkg_lookup(struct blkcg *blkcg, struct request_queue *q,
>   * read locked.  If called under either blkcg or queue lock, the iteration
>   * is guaranteed to include all and only online blkgs.  The caller may
>   * update @pos_css by calling css_rightmost_descendant() to skip subtree.
> + * @p_blkg is included in the iteration and the first node to be visited.
>   */
>  #define blkg_for_each_descendant_pre(d_blkg, pos_css, p_blkg)		\
>  	css_for_each_descendant_pre((pos_css), &(p_blkg)->blkcg->css)	\
> @@ -304,7 +305,8 @@ struct blkcg_gq *__blkg_lookup(struct blkcg *blkcg, struct request_queue *q,
>   * @p_blkg: target blkg to walk descendants of
>   *
>   * Similar to blkg_for_each_descendant_pre() but performs post-order
> - * traversal instead.  Synchronization rules are the same.
> + * traversal instead.  Synchronization rules are the same.  @p_blkg is
> + * included in the iteration and the last node to be visited.
>   */
>  #define blkg_for_each_descendant_post(d_blkg, pos_css, p_blkg)		\
>  	css_for_each_descendant_post((pos_css), &(p_blkg)->blkcg->css)	\
> diff --git a/block/blk-throttle.c b/block/blk-throttle.c
> index 8cefa7f..8331aba 100644
> --- a/block/blk-throttle.c
> +++ b/block/blk-throttle.c
> @@ -1379,7 +1379,6 @@ static int tg_set_conf(struct cgroup_subsys_state *css, struct cftype *cft,
>  	 * restrictions in the whole hierarchy and allows them to bypass
>  	 * blk-throttle.
>  	 */
> -	tg_update_has_rules(tg);
>  	blkg_for_each_descendant_pre(blkg, pos_css, ctx.blkg)
>  		tg_update_has_rules(blkg_to_tg(blkg));
>  
> @@ -1639,8 +1638,6 @@ void blk_throtl_drain(struct request_queue *q)
>  	blkg_for_each_descendant_post(blkg, pos_css, td->queue->root_blkg)
>  		tg_drain_bios(&blkg_to_tg(blkg)->service_queue);
>  
> -	tg_drain_bios(&td_root_tg(td)->service_queue);
> -
>  	/* finally, transfer bios from top-level tg's into the td */
>  	tg_drain_bios(&td->service_queue);
>  
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index e33eb7b..ed925f5 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -775,7 +775,8 @@ css_rightmost_descendant(struct cgroup_subsys_state *pos);
>   * @pos: the css * to use as the loop cursor
>   * @root: css whose descendants to walk
>   *
> - * Walk @root's descendants.  Must be called under rcu_read_lock().  A
> + * Walk @root's descendants.  @root is included in the iteration and the
> + * first node to be visited.  Must be called under rcu_read_lock().  A
>   * descendant css which hasn't finished ->css_online() or already has
>   * finished ->css_offline() may show up during traversal and it's each
>   * subsystem's responsibility to verify that each @pos is alive.
> @@ -797,13 +798,12 @@ css_rightmost_descendant(struct cgroup_subsys_state *pos);
>   *
>   * my_update_state(@css)
>   * {
> - *	Lock @css;
> - *	Update @css's state;
> - *	Unlock @css;
> - *
>   *	css_for_each_descendant_pre(@pos, @css) {
>   *		Lock @pos;
> - *		Verify @pos is alive and inherit state from @pos's parent;
> + *		if (@pos == @css)
> + *			Update @css's state;
> + *		else
> + *			Verify @pos is alive and inherit state from its parent;
>   *		Unlock @pos;
>   *	}
>   * }
> @@ -841,8 +841,9 @@ css_next_descendant_post(struct cgroup_subsys_state *pos,
>   * @css: css whose descendants to walk
>   *
>   * Similar to css_for_each_descendant_pre() but performs post-order
> - * traversal instead.  Note that the walk visibility guarantee described in
> - * pre-order walk doesn't apply the same to post-order walks.
> + * traversal instead.  @root is included in the iteration and the last
> + * node to be visited.  Note that the walk visibility guarantee described
> + * in pre-order walk doesn't apply the same to post-order walks.
>   */
>  #define css_for_each_descendant_post(pos, css)				\
>  	for ((pos) = css_next_descendant_post(NULL, (css)); (pos);	\
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 2bc45d3..4a19c8d 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2839,17 +2839,6 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
>  
>  	mutex_unlock(&cgroup_mutex);
>  
> -	/* @root always needs to be updated */
> -	inode = root->dentry->d_inode;
> -	mutex_lock(&inode->i_mutex);
> -	mutex_lock(&cgroup_mutex);
> -	ret = cgroup_addrm_files(root, cfts, is_add);
> -	mutex_unlock(&cgroup_mutex);
> -	mutex_unlock(&inode->i_mutex);
> -
> -	if (ret)
> -		goto out_deact;
> -
>  	/* add/rm files for all cgroups created before */
>  	rcu_read_lock();
>  	css_for_each_descendant_pre(css, cgroup_css(root, ss->subsys_id)) {
> @@ -2878,7 +2867,6 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
>  	}
>  	rcu_read_unlock();
>  	dput(prev);
> -out_deact:
>  	deactivate_super(sb);
>  	return ret;
>  }
> @@ -3070,7 +3058,8 @@ EXPORT_SYMBOL_GPL(css_next_child);
>   * @root: css whose descendants to walk
>   *
>   * To be used by css_for_each_descendant_pre().  Find the next descendant
> - * to visit for pre-order traversal of @root's descendants.
> + * to visit for pre-order traversal of @root's descendants.  @root is
> + * included in the iteration and the first node to be visited.
>   *
>   * While this function requires RCU read locking, it doesn't require the
>   * whole traversal to be contained in a single RCU critical section.  This
> @@ -3085,9 +3074,9 @@ css_next_descendant_pre(struct cgroup_subsys_state *pos,
>  
>  	WARN_ON_ONCE(!rcu_read_lock_held());
>  
> -	/* if first iteration, pretend we just visited @root */
> +	/* if first iteration, visit @root */
>  	if (!pos)
> -		pos = root;
> +		return root;
>  
>  	/* visit the first child if exists */
>  	next = css_next_child(NULL, pos);
> @@ -3157,7 +3146,8 @@ css_leftmost_descendant(struct cgroup_subsys_state *pos)
>   * @root: css whose descendants to walk
>   *
>   * To be used by css_for_each_descendant_post().  Find the next descendant
> - * to visit for post-order traversal of @root's descendants.
> + * to visit for post-order traversal of @root's descendants.  @root is
> + * included in the iteration and the last node to be visited.
>   *
>   * While this function requires RCU read locking, it doesn't require the
>   * whole traversal to be contained in a single RCU critical section.  This
> @@ -3178,14 +3168,17 @@ css_next_descendant_post(struct cgroup_subsys_state *pos,
>  		return next != root ? next : NULL;
>  	}
>  
> +	/* if we visited @root, we're done */
> +	if (pos == root)
> +		return NULL;
> +
>  	/* if there's an unvisited sibling, visit its leftmost descendant */
>  	next = css_next_child(pos, css_parent(pos));
>  	if (next)
>  		return css_leftmost_descendant(next);
>  
>  	/* no sibling left, visit parent */
> -	next = css_parent(pos);
> -	return next != root ? next : NULL;
> +	return css_parent(pos);
>  }
>  EXPORT_SYMBOL_GPL(css_next_descendant_post);
>  
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index 224da9a..f0ff64d 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -311,7 +311,6 @@ static int freezer_read(struct cgroup_subsys_state *css, struct cftype *cft,
>  	/* update states bottom-up */
>  	css_for_each_descendant_post(pos, css)
>  		update_if_frozen(pos);
> -	update_if_frozen(css);
>  
>  	rcu_read_unlock();
>  
> @@ -391,11 +390,6 @@ static void freezer_change_state(struct freezer *freezer, bool freeze)
>  {
>  	struct cgroup_subsys_state *pos;
>  
> -	/* update @freezer */
> -	spin_lock_irq(&freezer->lock);
> -	freezer_apply_state(freezer, freeze, CGROUP_FREEZING_SELF);
> -	spin_unlock_irq(&freezer->lock);
> -
>  	/*
>  	 * Update all its descendants in pre-order traversal.  Each
>  	 * descendant will try to inherit its parent's FREEZING state as
> @@ -406,14 +400,23 @@ static void freezer_change_state(struct freezer *freezer, bool freeze)
>  		struct freezer *pos_f = css_freezer(pos);
>  		struct freezer *parent = parent_freezer(pos_f);
>  
> -		/*
> -		 * Our update to @parent->state is already visible which is
> -		 * all we need.  No need to lock @parent.  For more info on
> -		 * synchronization, see freezer_post_create().
> -		 */
>  		spin_lock_irq(&pos_f->lock);
> -		freezer_apply_state(pos_f, parent->state & CGROUP_FREEZING,
> -				    CGROUP_FREEZING_PARENT);
> +
> +		if (pos_f == freezer) {
> +			freezer_apply_state(pos_f, freeze,
> +					    CGROUP_FREEZING_SELF);
> +		} else {
> +			/*
> +			 * Our update to @parent->state is already visible
> +			 * which is all we need.  No need to lock @parent.
> +			 * For more info on synchronization, see
> +			 * freezer_post_create().
> +			 */
> +			freezer_apply_state(pos_f,
> +					    parent->state & CGROUP_FREEZING,
> +					    CGROUP_FREEZING_PARENT);
> +		}
> +
>  		spin_unlock_irq(&pos_f->lock);
>  	}
>  	rcu_read_unlock();
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index bf69717..72a0383 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -222,7 +222,8 @@ static struct cpuset top_cpuset = {
>   *
>   * Walk @des_cs through the online descendants of @root_cs.  Must be used
>   * with RCU read locked.  The caller may modify @pos_css by calling
> - * css_rightmost_descendant() to skip subtree.
> + * css_rightmost_descendant() to skip subtree.  @root_cs is included in the
> + * iteration and the first node to be visited.
>   */
>  #define cpuset_for_each_descendant_pre(des_cs, pos_css, root_cs)	\
>  	css_for_each_descendant_pre((pos_css), &(root_cs)->css)		\
> @@ -506,6 +507,9 @@ static void update_domain_attr_tree(struct sched_domain_attr *dattr,
>  
>  	rcu_read_lock();
>  	cpuset_for_each_descendant_pre(cp, pos_css, root_cs) {
> +		if (cp == root_cs)
> +			continue;
> +
>  		/* skip the whole subtree if @cp doesn't have any CPU */
>  		if (cpumask_empty(cp->cpus_allowed)) {
>  			pos_css = css_rightmost_descendant(pos_css);
> @@ -613,6 +617,8 @@ static int generate_sched_domains(cpumask_var_t **domains,
>  
>  	rcu_read_lock();
>  	cpuset_for_each_descendant_pre(cp, pos_css, &top_cpuset) {
> +		if (cp == &top_cpuset)
> +			continue;
>  		/*
>  		 * Continue traversing beyond @cp iff @cp has some CPUs and
>  		 * isn't load balancing.  The former is obvious.  The
> @@ -875,15 +881,17 @@ static void update_tasks_cpumask_hier(struct cpuset *root_cs,
>  	struct cpuset *cp;
>  	struct cgroup_subsys_state *pos_css;
>  
> -	if (update_root)
> -		update_tasks_cpumask(root_cs, heap);
> -
>  	rcu_read_lock();
>  	cpuset_for_each_descendant_pre(cp, pos_css, root_cs) {
> -		/* skip the whole subtree if @cp have some CPU */
> -		if (!cpumask_empty(cp->cpus_allowed)) {
> -			pos_css = css_rightmost_descendant(pos_css);
> -			continue;
> +		if (cp == root_cs) {
> +			if (!update_root)
> +				continue;
> +		} else {
> +			/* skip the whole subtree if @cp have some CPU */
> +			if (!cpumask_empty(cp->cpus_allowed)) {
> +				pos_css = css_rightmost_descendant(pos_css);
> +				continue;
> +			}
>  		}
>  		if (!css_tryget(&cp->css))
>  			continue;
> @@ -1130,15 +1138,17 @@ static void update_tasks_nodemask_hier(struct cpuset *root_cs,
>  	struct cpuset *cp;
>  	struct cgroup_subsys_state *pos_css;
>  
> -	if (update_root)
> -		update_tasks_nodemask(root_cs, heap);
> -
>  	rcu_read_lock();
>  	cpuset_for_each_descendant_pre(cp, pos_css, root_cs) {
> -		/* skip the whole subtree if @cp have some CPU */
> -		if (!nodes_empty(cp->mems_allowed)) {
> -			pos_css = css_rightmost_descendant(pos_css);
> -			continue;
> +		if (cp == root_cs) {
> +			if (!update_root)
> +				continue;
> +		} else {
> +			/* skip the whole subtree if @cp have some CPU */
> +			if (!nodes_empty(cp->mems_allowed)) {
> +				pos_css = css_rightmost_descendant(pos_css);
> +				continue;
> +			}
>  		}
>  		if (!css_tryget(&cp->css))
>  			continue;
> @@ -2237,7 +2247,7 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
>  
>  		rcu_read_lock();
>  		cpuset_for_each_descendant_pre(cs, pos_css, &top_cpuset) {
> -			if (!css_tryget(&cs->css))
> +			if (cs == &top_cpuset || !css_tryget(&cs->css))
>  				continue;
>  			rcu_read_unlock();
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 240ae72..68a37c0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1129,14 +1129,7 @@ static struct mem_cgroup *__mem_cgroup_iter_next(struct mem_cgroup *root,
>  {
>  	struct cgroup_subsys_state *prev_css, *next_css;
>  
> -	/*
> -	 * Root is not visited by cgroup iterators so it needs an
> -	 * explicit visit.
> -	 */
> -	if (!last_visited)
> -		return root;
> -
> -	prev_css = (last_visited == root) ? NULL : &last_visited->css;
> +	prev_css = last_visited ? &last_visited->css : NULL;
>  skip_node:
>  	next_css = css_next_descendant_pre(prev_css, &root->css);
>  
> diff --git a/security/device_cgroup.c b/security/device_cgroup.c
> index 9bf230a..c123628 100644
> --- a/security/device_cgroup.c
> +++ b/security/device_cgroup.c
> @@ -456,7 +456,7 @@ static int propagate_exception(struct dev_cgroup *devcg_root,
>  		 * methods), and online ones are safe to access outside RCU
>  		 * read lock without bumping refcnt.
>  		 */
> -		if (!is_devcg_online(devcg))
> +		if (pos == &devcg_root->css || !is_devcg_online(devcg))
>  			continue;
>  
>  		rcu_read_unlock();
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
