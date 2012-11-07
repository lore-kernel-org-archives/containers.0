From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 2/9] cgroup: Use rculist ops for cgroup->children
Date: Wed, 7 Nov 2012 16:30:23 +0100
Message-ID: <20121107153023.GB4131__18169.6908468895$1352302244$gmane$org@dhcp22.suse.cz>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-3-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351931915-1701-3-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On Sat 03-11-12 01:38:28, Tejun Heo wrote:
> Use RCU safe list operations for cgroup->children.  This will be used
> to implement cgroup children / descendant walking which can be used by
> controllers.
> 
> Note that cgroup_create() now puts a new cgroup at the end of the
> ->children list instead of head.  This isn't strictly necessary but is
> done so that the iteration order is more conventional.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

> ---
>  include/linux/cgroup.h | 1 +
>  kernel/cgroup.c        | 8 +++-----
>  2 files changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index b442122..90c33eb 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -12,6 +12,7 @@
>  #include <linux/cpumask.h>
>  #include <linux/nodemask.h>
>  #include <linux/rcupdate.h>
> +#include <linux/rculist.h>
>  #include <linux/cgroupstats.h>
>  #include <linux/prio_heap.h>
>  #include <linux/rwsem.h>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index f05d992..cc5d2a0 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1650,7 +1650,6 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
>  
>  		free_cg_links(&tmp_cg_links);
>  
> -		BUG_ON(!list_empty(&root_cgrp->sibling));
>  		BUG_ON(!list_empty(&root_cgrp->children));
>  		BUG_ON(root->number_of_cgroups != 1);
>  
> @@ -1699,7 +1698,6 @@ static void cgroup_kill_sb(struct super_block *sb) {
>  
>  	BUG_ON(root->number_of_cgroups != 1);
>  	BUG_ON(!list_empty(&cgrp->children));
> -	BUG_ON(!list_empty(&cgrp->sibling));
>  
>  	mutex_lock(&cgroup_mutex);
>  	mutex_lock(&cgroup_root_mutex);
> @@ -4053,7 +4051,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>  		}
>  	}
>  
> -	list_add(&cgrp->sibling, &cgrp->parent->children);
> +	list_add_tail_rcu(&cgrp->sibling, &cgrp->parent->children);
>  	root->number_of_cgroups++;
>  
>  	err = cgroup_create_dir(cgrp, dentry, mode);
> @@ -4084,7 +4082,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>  
>   err_remove:
>  
> -	list_del(&cgrp->sibling);
> +	list_del_rcu(&cgrp->sibling);
>  	root->number_of_cgroups--;
>  
>   err_destroy:
> @@ -4210,7 +4208,7 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
>  	raw_spin_unlock(&release_list_lock);
>  
>  	/* delete this cgroup from parent->children */
> -	list_del_init(&cgrp->sibling);
> +	list_del_rcu(&cgrp->sibling);
>  
>  	list_del_init(&cgrp->allcg_node);
>  
> -- 
> 1.7.11.7
> 

-- 
Michal Hocko
SUSE Labs
