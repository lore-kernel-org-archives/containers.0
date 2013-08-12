From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 07/14] cgroup: reorganize css init / exit paths
Date: Mon, 12 Aug 2013 10:47:33 +0800
Message-ID: <52084CC5.8050207@huawei.com>
References: <1375992831-4650-1-git-send-email-tj@kernel.org>
	<1375992831-4650-8-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375992831-4650-8-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

>  /* invoke ->css_online() on a new CSS and mark it online if successful */
> -static int online_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
> +static int online_css(struct cgroup_subsys_state *css)
>  {
> -	struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
> +	struct cgroup_subsys *ss = css->ss;
>  	int ret = 0;
>  
>  	lockdep_assert_held(&cgroup_mutex);
> @@ -4342,9 +4340,9 @@ static int online_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
>  }
>  
>  /* if the CSS is online, invoke ->css_offline() on it and mark it offline */
> -static void offline_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
> +static void offline_css(struct cgroup_subsys_state *css)
>  {
> -	struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
> +	struct cgroup_subsys *ss = css->ss;
>  
>  	lockdep_assert_held(&cgroup_mutex);
>  
> @@ -4442,10 +4440,10 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>  			goto err_free_all;
>  		}
>  
> -		init_cgroup_css(css, ss, cgrp);
> +		init_css(css, ss, cgrp);
>  
>  		if (ss->use_id) {
> -			err = alloc_css_id(ss, parent, cgrp);
> +			err = alloc_css_id(css);
>  			if (err)
>  				goto err_free_all;
>  		}
> @@ -4467,20 +4465,18 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>  	list_add_tail_rcu(&cgrp->sibling, &cgrp->parent->children);
>  	root->number_of_cgroups++;
>  
> -	/* each css holds a ref to the cgroup's dentry and the parent css */
> +	/* hold a ref to the parent's dentry */
> +	dget(parent->dentry);
> +
>  	for_each_root_subsys(root, ss) {
>  		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
>  
> +		/* each css holds a ref to the cgroup and the parent css */
>  		dget(dentry);
>  		percpu_ref_get(&css->parent->refcnt);

We called dget() and percpu_ref_get() for each css unconditionally...

> -	}
>  
> -	/* hold a ref to the parent's dentry */
> -	dget(parent->dentry);
> -
> -	/* creation succeeded, notify subsystems */
> -	for_each_root_subsys(root, ss) {
> -		err = online_css(ss, cgrp);
> +		/* creation succeeded, notify subsystems */
> +		err = online_css(css);
>  		if (err)
>  			goto err_destroy;

but now dget() and percpu_ref_get() may not be called for some css's,
but the code in failure path is not updated accordingly, which seems
wrong.

>  
> @@ -4700,7 +4696,7 @@ static void cgroup_offline_fn(struct work_struct *work)
>  	 * initate destruction.
>  	 */
>  	for_each_root_subsys(cgrp->root, ss)
> -		offline_css(ss, cgrp);
> +		offline_css(cgroup_css(cgrp, ss->subsys_id));
>  
>  	/*
>  	 * Put the css refs from cgroup_destroy_locked().  Each css holds
> @@ -4778,7 +4774,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
>  	css = ss->css_alloc(cgroup_css(cgroup_dummy_top, ss->subsys_id));
>  	/* We don't handle early failures gracefully */
>  	BUG_ON(IS_ERR(css));
> -	init_cgroup_css(css, ss, cgroup_dummy_top);
> +	init_css(css, ss, cgroup_dummy_top);
>  
>  	/* Update the init_css_set to contain a subsys
>  	 * pointer to this state - since the subsystem is
> @@ -4793,7 +4789,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
>  	 * need to invoke fork callbacks here. */
>  	BUG_ON(!list_empty(&init_task.tasks));
>  
> -	BUG_ON(online_css(ss, cgroup_dummy_top));
> +	BUG_ON(online_css(cgroup_css(cgroup_dummy_top, ss->subsys_id)));
>  
>  	mutex_unlock(&cgroup_mutex);
>  
> @@ -4866,8 +4862,8 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
>  	ss->root = &cgroup_dummy_root;
>  
>  	/* our new subsystem will be attached to the dummy hierarchy. */
> -	init_cgroup_css(css, ss, cgroup_dummy_top);
> -	/* init_idr must be after init_cgroup_css because it sets css->id. */
> +	init_css(css, ss, cgroup_dummy_top);
> +	/* init_idr must be after init_css() because it sets css->id. */
>  	if (ss->use_id) {
>  		ret = cgroup_init_idr(ss, css);
>  		if (ret)
> @@ -4897,7 +4893,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
>  	}
>  	write_unlock(&css_set_lock);
>  
> -	ret = online_css(ss, cgroup_dummy_top);
> +	ret = online_css(cgroup_css(cgroup_dummy_top, ss->subsys_id));
>  	if (ret)
>  		goto err_unload;
>  
> @@ -4936,7 +4932,7 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
>  
>  	mutex_lock(&cgroup_mutex);
>  
> -	offline_css(ss, cgroup_dummy_top);
> +	offline_css(cgroup_css(cgroup_dummy_top, ss->subsys_id));
>  
>  	if (ss->use_id)
>  		idr_destroy(&ss->idr);
> @@ -5588,20 +5584,16 @@ static int __init_or_module cgroup_init_idr(struct cgroup_subsys *ss,
>  	return 0;
>  }
>  
> -static int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *parent,
> -			struct cgroup *child)
> +static int alloc_css_id(struct cgroup_subsys_state *child_css)
>  {
> -	int subsys_id, i, depth = 0;
> -	struct cgroup_subsys_state *parent_css, *child_css;
> +	struct cgroup_subsys_state *parent_css = css_parent(child_css);
>  	struct css_id *child_id, *parent_id;
> +	int i, depth;
>  
> -	subsys_id = ss->subsys_id;
> -	parent_css = cgroup_css(parent, subsys_id);
> -	child_css = cgroup_css(child, subsys_id);
>  	parent_id = rcu_dereference_protected(parent_css->id, true);
>  	depth = parent_id->depth + 1;
>  
> -	child_id = get_new_cssid(ss, depth);
> +	child_id = get_new_cssid(child_css->ss, depth);
>  	if (IS_ERR(child_id))
>  		return PTR_ERR(child_id);
>  
> 
