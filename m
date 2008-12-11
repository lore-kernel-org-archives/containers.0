From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH 1/3] CGroups: Add a per-subsystem hierarchy_mutex
Date: Thu, 11 Dec 2008 09:37:33 +0900
Message-ID: <20081211093733.c24deb6e.kamezawa.hiroyu__24715.9684695818$1228956108$gmane$org@jp.fujitsu.com>
References: <20081210233654.563182000@menage.corp.google.com>
	<20081210234432.065445000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

thank you for this work.

On Wed, 10 Dec 2008 15:36:55 -0800
menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org wrote:

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
o.k. usage is very clear.

> Thus if the subsystem holds its own hierarchy_mutex, it can safely
> traverse its own hierarchy.
> 
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
Maybe no problem..but I don't like releasing lock in the order of acquiring lock.

	for (i = CGROUP_SUBSYS_COUNT - 1; i >=0; i--)  ?


-Kame
