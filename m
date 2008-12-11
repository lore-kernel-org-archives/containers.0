From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 1/3] CGroups: Add a per-subsystem hierarchy_mutex
Date: Thu, 11 Dec 2008 11:59:40 +0530
Message-ID: <20081211062940.GJ3008__29081.7740293734$1228977115$gmane$org@balbir.in.ibm.com>
References: <20081210233654.563182000@menage.corp.google.com>
	<20081210234432.065445000@menage.corp.google.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081210234432.065445000-B63HFAS8fGlSzHKm+aFRNNkmqwFzkYv6@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

* menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> [2008-12-10 15:36:55]:

> This patch adds a hierarchy_mutex to the cgroup_subsys object that
> protects changes to the hierarchy observed by that subsystem. It is
> taken by the cgroup subsystem (in addition to cgroup_mutex) for the
> following operations:
> 
> - linking a cgroup into that subsystem's cgroup tree
> - unlinking a cgroup from that subsystem's cgroup tree
> - moving the subsystem to/from a hierarchy (including across the
>   bind() callback)
> 
> Thus if the subsystem holds its own hierarchy_mutex, it can safely
> traverse its own hierarchy.
>

Ths sounds reasonable, a further abstraction in the future could be to
provide the visitor pattern. Allow cgroups to do the walking and have
callbacks called during the visit.
 
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> ---
> 
>  Documentation/cgroups/cgroups.txt |    2 +-
>  include/linux/cgroup.h            |    9 ++++++++-
>  kernel/cgroup.c                   |   37 +++++++++++++++++++++++++++++++++++--
>  3 files changed, 44 insertions(+), 4 deletions(-)
> 
> Index: hierarchy_lock-mmotm-2008-12-09/include/linux/cgroup.h
> ===================================================================
> --- hierarchy_lock-mmotm-2008-12-09.orig/include/linux/cgroup.h
> +++ hierarchy_lock-mmotm-2008-12-09/include/linux/cgroup.h
> @@ -337,8 +337,15 @@ struct cgroup_subsys {
>  #define MAX_CGROUP_TYPE_NAMELEN 32
>  	const char *name;
> 
> -	struct cgroupfs_root *root;
> +	/*
> +	 * Protects sibling/children links of cgroups in this
> +	 * hierarchy, plus protects which hierarchy (or none) the
> +	 * subsystem is a part of (i.e. root/sibling)
> +	 */
> +	struct mutex hierarchy_mutex;
> 
> +	/* Protected by this->hierarchy_mutex and cgroup_lock() */
> +	struct cgroupfs_root *root;
>  	struct list_head sibling;
>  };
> 
> Index: hierarchy_lock-mmotm-2008-12-09/kernel/cgroup.c
> ===================================================================
> --- hierarchy_lock-mmotm-2008-12-09.orig/kernel/cgroup.c
> +++ hierarchy_lock-mmotm-2008-12-09/kernel/cgroup.c
> @@ -714,23 +714,26 @@ static int rebind_subsystems(struct cgro
>  			BUG_ON(cgrp->subsys[i]);
>  			BUG_ON(!dummytop->subsys[i]);
>  			BUG_ON(dummytop->subsys[i]->cgroup != dummytop);
> +			mutex_lock(&ss->hierarchy_mutex);
>  			cgrp->subsys[i] = dummytop->subsys[i];
>  			cgrp->subsys[i]->cgroup = cgrp;
>  			list_move(&ss->sibling, &root->subsys_list);
>  			ss->root = root;
>  			if (ss->bind)
>  				ss->bind(ss, cgrp);
> -
> +			mutex_unlock(&ss->hierarchy_mutex);
>  		} else if (bit & removed_bits) {
>  			/* We're removing this subsystem */
>  			BUG_ON(cgrp->subsys[i] != dummytop->subsys[i]);
>  			BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
> +			mutex_lock(&ss->hierarchy_mutex);
>  			if (ss->bind)
>  				ss->bind(ss, dummytop);
>  			dummytop->subsys[i]->cgroup = dummytop;
>  			cgrp->subsys[i] = NULL;
>  			subsys[i]->root = &rootnode;
>  			list_move(&ss->sibling, &rootnode.subsys_list);
> +			mutex_unlock(&ss->hierarchy_mutex);
>  		} else if (bit & final_bits) {
>  			/* Subsystem state should already exist */
>  			BUG_ON(!cgrp->subsys[i]);
> @@ -2326,6 +2329,29 @@ static void init_cgroup_css(struct cgrou
>  	cgrp->subsys[ss->subsys_id] = css;
>  }
> 
> +static void cgroup_lock_hierarchy(struct cgroupfs_root *root)
> +{
> +	/* We need to take each hierarchy_mutex in a consistent order */
> +	int i;
> +
> +	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> +		struct cgroup_subsys *ss = subsys[i];
> +		if (ss->root == root)
> +			mutex_lock_nested(&ss->hierarchy_mutex, i);
> +	}
> +}
> +
> +static void cgroup_unlock_hierarchy(struct cgroupfs_root *root)
> +{
> +	int i;
> +
> +	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> +		struct cgroup_subsys *ss = subsys[i];
> +		if (ss->root == root)
> +			mutex_unlock(&ss->hierarchy_mutex);
> +	}
> +}
> +
>  /*
>   * cgroup_create - create a cgroup
>   * @parent: cgroup that will be parent of the new cgroup
> @@ -2374,7 +2400,9 @@ static long cgroup_create(struct cgroup 
>  		init_cgroup_css(css, ss, cgrp);
>  	}
> 
> +	cgroup_lock_hierarchy(root);
>  	list_add(&cgrp->sibling, &cgrp->parent->children);
> +	cgroup_unlock_hierarchy(root);
>  	root->number_of_cgroups++;
> 
>  	err = cgroup_create_dir(cgrp, dentry, mode);
> @@ -2492,8 +2520,12 @@ static int cgroup_rmdir(struct inode *un
>  	if (!list_empty(&cgrp->release_list))
>  		list_del(&cgrp->release_list);
>  	spin_unlock(&release_list_lock);
> -	/* delete my sibling from parent->children */
> +
> +	cgroup_lock_hierarchy(cgrp->root);
> +	/* delete this cgroup from parent->children */
>  	list_del(&cgrp->sibling);
> +	cgroup_unlock_hierarchy(cgrp->root);
> +
>  	spin_lock(&cgrp->dentry->d_lock);
>  	d = dget(cgrp->dentry);
>  	spin_unlock(&d->d_lock);
> @@ -2535,6 +2567,7 @@ static void __init cgroup_init_subsys(st
>  	 * need to invoke fork callbacks here. */
>  	BUG_ON(!list_empty(&init_task.tasks));
> 
> +	mutex_init(&ss->hierarchy_mutex);
>  	ss->active = 1;
>  }
> 
> Index: hierarchy_lock-mmotm-2008-12-09/Documentation/cgroups/cgroups.txt
> ===================================================================
> --- hierarchy_lock-mmotm-2008-12-09.orig/Documentation/cgroups/cgroups.txt
> +++ hierarchy_lock-mmotm-2008-12-09/Documentation/cgroups/cgroups.txt
> @@ -528,7 +528,7 @@ example in cpusets, no task may attach b
>  up.
> 
>  void bind(struct cgroup_subsys *ss, struct cgroup *root)
> -(cgroup_mutex held by caller)
> +(cgroup_mutex and ss->hierarchy_mutex held by caller)
>

Seems reasonable, I was wondering if instead of acquiring a mutex per
subsystem that shares the root, if we can collapse it to a single
mutex and prevent cgroup from changing binding. Those are
optimizations that we can think of later

Acked-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> 

-- 
	Balbir
