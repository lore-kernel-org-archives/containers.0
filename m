From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/4] Support named cgroups hierarchies
Date: Thu, 23 Jul 2009 14:20:42 +0800
Message-ID: <4A68013A.2020302__29478.9314190441$1248330275$gmane$org@cn.fujitsu.com>
References: <20090722194644.7481.47805.stgit@menage.mtv.corp.google.com>
	<20090722195029.7481.94700.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090722195029.7481.94700.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> Support named cgroups hierarchies
> 
> To simplify referring to cgroup hierarchies in mount statements, and
> to allow disambiguation in the presence of empty hierarchies and
> multiply-bindable subsystems this patch adds support for naming a new
> cgroup hierarchy via the "name=" mount option
> 
> A pre-existing hierarchy may be specified by either name or by
> subsystems; a hierarchy's name cannot be changed by a remount
> operation.
> 
> Example usage:
> 
> # To create a hierarchy called "foo" containing the "cpu" subsystem
> mount -t cgroup -oname=foo,cpu cgroup /mnt/cgroup1
> 
> # To mount the "foo" hierarchy on a second location
> mount -t cgroup -oname=foo cgroup /mnt/cgroup2
> 
> 
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 

Looks good to me.

Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Except a few comments below:

> ---
> 
>  Documentation/cgroups/cgroups.txt |   19 ++++
>  kernel/cgroup.c                   |  186 +++++++++++++++++++++++++++----------
>  2 files changed, 157 insertions(+), 48 deletions(-)
> 
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
> index 6eb1a97..1f7cf9f 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt
> @@ -408,6 +408,25 @@ You can attach the current shell task by echoing 0:
>  
>  # echo 0 > tasks
>  
> +2.3 Mounting hierarchies by name
> +--------------------------------
> +
> +Passing the name=<x> option when mounting a cgroups hierarchy
> +associates the given name with the hierarchy.  This can be used when
> +mounting a pre-existing hierarchy, in order to refer to it by name
> +rather than by its set of active subsystems.
> +
> +The name should match [\w.-]+
> +

"[\w._-]+" ?

But I double we need to check this.

> +When passing a name=<x> option for a new hierarchy, you need to
> +specify subsystems manually; the legacy behaviour of mounting all
> +subsystems when none are explicitly specified is not supported when
> +you give a subsystem a name.
> +

Mention that a hierarchy either has no name or should have a uniq name?

> +The name of the subsystem appears as part of the hierarchy description
> +in /proc/mounts and /proc/<pid>/cgroups.

...

>  static int cgroup_set_super(struct super_block *sb, void *data)
>  {
>  	int ret;
> -	struct cgroupfs_root *root = data;
> +	struct cgroup_sb_opts *opts = data;
> +
> +	/* If we don't have a new root, we can't set up a new sb */
> +	if (!opts->new_root)
> +		return -EINVAL;
> +

I think this should be BUG_ON(). If set_super() is called,
we are allocating a new root, so opts->new_root won't be NULL.

> +	BUG_ON(!opts->subsys_bits);
>  
>  	ret = set_anon_super(sb, NULL);
>  	if (ret)
>  		return ret;
>  
> -	sb->s_fs_info = root;
> -	root->sb = sb;
> +	sb->s_fs_info = opts->new_root;
> +	opts->new_root->sb = sb;
>  
>  	sb->s_blocksize = PAGE_CACHE_SIZE;
>  	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
> @@ -1039,48 +1106,44 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>  			 void *data, struct vfsmount *mnt)
>  {
>  	struct cgroup_sb_opts opts;
> +	struct cgroupfs_root *root;
>  	int ret = 0;
>  	struct super_block *sb;
> -	struct cgroupfs_root *root;
> -	struct list_head tmp_cg_links;
>  
>  	/* First find the desired set of subsystems */
>  	ret = parse_cgroupfs_options(data, &opts);
> -	if (ret) {
> -		kfree(opts.release_agent);
> -		return ret;
> -	}
> -
> -	root = kzalloc(sizeof(*root), GFP_KERNEL);
> -	if (!root) {
> -		kfree(opts.release_agent);
> -		return -ENOMEM;
> -	}
> +	if (ret)
> +		goto out_err;
>  
> -	init_cgroup_root(root);
> -	root->subsys_bits = opts.subsys_bits;
> -	root->flags = opts.flags;
> -	if (opts.release_agent) {
> -		strcpy(root->release_agent_path, opts.release_agent);
> -		kfree(opts.release_agent);
> +	/*
> +	 * Allocate a new cgroup root. We may not need it if we're
> +	 * reusing an existing hierarchy.
> +	 */
> +	{

I don't think this is a normal coding style.

> +		struct cgroupfs_root *new_root = cgroup_root_from_opts(&opts);

Why not just declare new_root in the beginning of cgroup_get_sb()?

> +		if (IS_ERR(new_root)) {
> +			ret = PTR_ERR(new_root);
> +			goto out_err;
> +		}
> +		opts.new_root = new_root;
>  	}
>  
> -	sb = sget(fs_type, cgroup_test_super, cgroup_set_super, root);
> -
> +	/* Locate an existing or new sb for this hierarchy */
> +	sb = sget(fs_type, cgroup_test_super, cgroup_set_super, &opts);
>  	if (IS_ERR(sb)) {
> -		kfree(root);
> -		return PTR_ERR(sb);
> +		ret = PTR_ERR(sb);
> +		kfree(opts.new_root);
> +		goto out_err;
>  	}
>  
> -	if (sb->s_fs_info != root) {
> -		/* Reusing an existing superblock */
> -		BUG_ON(sb->s_root == NULL);
> -		kfree(root);
> -		root = NULL;
> -	} else {
> -		/* New superblock */
> +	root = sb->s_fs_info;
> +	BUG_ON(!root);
> +	if (root == opts.new_root) {
> +		/* We used the new root structure, so this is a new hierarchy */
> +		struct list_head tmp_cg_links;
>  		struct cgroup *root_cgrp = &root->top_cgroup;
>  		struct inode *inode;
> +		struct cgroupfs_root *existing_root;
>  		int i;
>  
>  		BUG_ON(sb->s_root != NULL);
> @@ -1093,6 +1156,18 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>  		mutex_lock(&inode->i_mutex);
>  		mutex_lock(&cgroup_mutex);
>  
> +		if (strlen(root->name)) {
> +			/* Check for name clashes with existing mounts */
> +			for_each_active_root(existing_root) {
> +				if (!strcmp(existing_root->name, root->name)) {
> +					ret = -EBUSY;
> +					mutex_unlock(&cgroup_mutex);
> +					mutex_unlock(&inode->i_mutex);
> +					goto drop_new_super;
> +				}
> +			}
> +		}
> +
>  		/*
>  		 * We're accessing css_set_count without locking
>  		 * css_set_lock here, but that's OK - it can only be
> @@ -1111,7 +1186,8 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>  		if (ret == -EBUSY) {
>  			mutex_unlock(&cgroup_mutex);
>  			mutex_unlock(&inode->i_mutex);
> -			goto free_cg_links;
> +			free_cg_links(&tmp_cg_links);
> +			goto drop_new_super;
>  		}
>  
>  		/* EBUSY should be the only error here */
> @@ -1145,15 +1221,26 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>  		cgroup_populate_dir(root_cgrp);
>  		mutex_unlock(&inode->i_mutex);
>  		mutex_unlock(&cgroup_mutex);
> +	} else {
> +		/*
> +		 * We re-used an existing hierarchy - the new root (if
> +		 * any) is not needed
> +		 */
> +		kfree(opts.new_root);
>  	}
>  
>  	simple_set_mnt(mnt, sb);
> +	kfree(opts.release_agent);
> +	kfree(opts.name);
>  	return 0;
>  
> - free_cg_links:
> -	free_cg_links(&tmp_cg_links);
>   drop_new_super:
>  	deactivate_locked_super(sb);
> +
> + out_err:
> +	kfree(opts.release_agent);
> +	kfree(opts.name);
> +
>  	return ret;
>  }
>  
