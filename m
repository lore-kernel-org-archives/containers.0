From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/8] cgroup: add cgroup->id
Date: Tue, 20 Nov 2012 13:34:54 +0900
Message-ID: <50AB086E.70901@jp.fujitsu.com>
References: <1353093624-22608-1-git-send-email-tj@kernel.org>
	<1353093624-22608-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353093624-22608-2-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, srivatsa.bhat-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

(2012/11/17 4:20), Tejun Heo wrote:
> With the introduction of generic cgroup hierarchy iterators, css_id is
> being phased out.  It was unnecessarily complex, id'ing the wrong
> thing (cgroups need IDs, not CSSes) and has other oddities like not
> being available at ->css_alloc().
> 
> This patch adds cgroup->id, which is a simple per-hierarchy
> ida-allocated ID which is assigned before ->css_alloc() and released
> after ->css_free().
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


I'm sorry if I misunderstand ... current usage of css-id in memory/swap cgroup
is for recording information of memory cgroup which may be destroyed. In some case,
a memcg's cgroup is freed but a struct memcgroup and its css are available, swap_cgroup
may contain id ot if.
This patch puts cgroup's id at diput(), so, the id used in swap_cgroup can be
reused while it's in use. Right ?

Thanks,
-Kame

> ---
>   include/linux/cgroup.h |  2 ++
>   kernel/cgroup.c        | 15 ++++++++++++++-
>   2 files changed, 16 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index d5fc8a7..b512469 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -159,6 +159,8 @@ struct cgroup {
>   	 */
>   	atomic_t count;
>   
> +	int id;				/* ida allocated in-hierarchy ID */
> +
>   	/*
>   	 * We link our 'sibling' struct into our parent's 'children'.
>   	 * Our children link their 'sibling' into our 'children'.
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 99d5e69..0b25dcb 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -138,6 +138,9 @@ struct cgroupfs_root {
>   	/* Hierarchy-specific flags */
>   	unsigned long flags;
>   
> +	/* IDs for cgroups in this hierarchy */
> +	struct ida cgroup_ida;
> +
>   	/* The path to use for release notifications. */
>   	char release_agent_path[PATH_MAX];
>   
> @@ -890,6 +893,7 @@ static void cgroup_diput(struct dentry *dentry, struct inode *inode)
>   
>   		simple_xattrs_free(&cgrp->xattrs);
>   
> +		ida_simple_remove(&cgrp->root->cgroup_ida, cgrp->id);
>   		kfree(cgrp);
>   	} else {
>   		struct cfent *cfe = __d_cfe(dentry);
> @@ -1465,6 +1469,7 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
>   
>   	root->subsys_mask = opts->subsys_mask;
>   	root->flags = opts->flags;
> +	ida_init(&root->cgroup_ida);
>   	if (opts->release_agent)
>   		strcpy(root->release_agent_path, opts->release_agent);
>   	if (opts->name)
> @@ -1483,6 +1488,7 @@ static void cgroup_drop_root(struct cgroupfs_root *root)
>   	spin_lock(&hierarchy_id_lock);
>   	ida_remove(&hierarchy_ida, root->hierarchy_id);
>   	spin_unlock(&hierarchy_id_lock);
> +	ida_destroy(&root->cgroup_ida);
>   	kfree(root);
>   }
>   
> @@ -4093,10 +4099,15 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>   	struct cgroup_subsys *ss;
>   	struct super_block *sb = root->sb;
>   
> +	/* allocate the cgroup and its ID, 0 is reserved for the root */
>   	cgrp = kzalloc(sizeof(*cgrp), GFP_KERNEL);
>   	if (!cgrp)
>   		return -ENOMEM;
>   
> +	cgrp->id = ida_simple_get(&root->cgroup_ida, 1, 0, GFP_KERNEL);
> +	if (cgrp->id < 0)
> +		goto err_free_cgrp;
> +
>   	/*
>   	 * Only live parents can have children.  Note that the liveliness
>   	 * check isn't strictly necessary because cgroup_mkdir() and
> @@ -4106,7 +4117,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>   	 */
>   	if (!cgroup_lock_live_group(parent)) {
>   		err = -ENODEV;
> -		goto err_free_cgrp;
> +		goto err_free_id;
>   	}
>   
>   	/* Grab a reference on the superblock so the hierarchy doesn't
> @@ -4198,6 +4209,8 @@ err_free_all:
>   	mutex_unlock(&cgroup_mutex);
>   	/* Release the reference count that we took on the superblock */
>   	deactivate_super(sb);
> +err_free_id:
> +	ida_simple_remove(&root->cgroup_ida, cgrp->id);
>   err_free_cgrp:
>   	kfree(cgrp);
>   	return err;
> 
