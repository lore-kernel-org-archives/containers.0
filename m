From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/7] [RFC] Support named cgroups hierarchies
Date: Tue, 17 Mar 2009 14:44:12 +0800
Message-ID: <49BF46BC.4080302@cn.fujitsu.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>
	<20090312105122.24154.73633.stgit@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090312105122.24154.73633.stgit-B63HFAS8fGlSzHKm+aFRNNkmqwFzkYv6@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> [RFC] Support named cgroups hierarchies
> 
> To simplify referring to cgroup hierarchies in mount statements, and
> to allow disambiguation in the presence of empty hierarchies and
> multiply-bindable subsystems (see later patches in series) this patch
> adds support for naming a new cgroup hierarchy via the "name=" mount
> option
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
> Open issues:
> 
> - should the specification be via a name= option as in this patch, or
>   should we simply use the "device name" as passed to the mount()
>   system call?  Using the device name is more conceptually clean and
>   consistent with the filesystem API; however, given that the device
>   name is currently ignored by cgroups, this would lead to a
>   user-visible behaviour change.
> 

If we use "device name" and don't allow it to be changed on remount,
this seems a change that may break/suprise existing users?

And another issue is, using "device name" won't allow us to use NULL
name, which is also user-visible in /proc/pid/cgroups/.

Some comments below.

> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> ---
> 
>  kernel/cgroup.c |  126 ++++++++++++++++++++++++++++++++++++-------------------
>  1 files changed, 82 insertions(+), 44 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 5995477..aa5edc8 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -92,6 +92,9 @@ struct cgroupfs_root {
>  
>  	/* The path to use for release notifications. */
>  	char release_agent_path[PATH_MAX];
> +
> +	/* The name for this hierarchy - may be empty */
> +	char name[PATH_MAX];

I think 32 or 64 is sufficient. How about reuse MAX_CGROUP_TYPE_NAMELEN
which is the length limit of cgroup_subsys.name?

>  };
>  
>  /*
> @@ -826,6 +829,8 @@ static int cgroup_show_options(struct seq_file *seq, struct vfsmount *vfs)
>  		seq_puts(seq, ",noprefix");
>  	if (strlen(root->release_agent_path))
>  		seq_printf(seq, ",release_agent=%s", root->release_agent_path);
> +	if (strlen(root->name))
> +		seq_printf(seq, ",name=%s", root->name);
>  	mutex_unlock(&cgroup_mutex);
>  	return 0;
>  }
> @@ -834,18 +839,22 @@ struct cgroup_sb_opts {
>  	unsigned long subsys_bits;
>  	unsigned long flags;
>  	char *release_agent;
> +	char *name;
> +	/* A flag indicating that a root was created from this options block */
> +	bool created_root;
>  };
>  
>  /* Convert a hierarchy specifier into a bitmask of subsystems and
>   * flags. */
>  static int parse_cgroupfs_options(char *data,
> -				     struct cgroup_sb_opts *opts)
> +				  struct cgroup_sb_opts *opts)
>  {
>  	char *token, *o = data ?: "all";
>  
>  	opts->subsys_bits = 0;
>  	opts->flags = 0;
>  	opts->release_agent = NULL;
> +	opts->name = NULL;
>  

memset() can save us some bytes.

>  	while ((token = strsep(&o, ",")) != NULL) {
>  		if (!*token)
> @@ -870,6 +879,15 @@ static int parse_cgroupfs_options(char *data,
>  				return -ENOMEM;
>  			strncpy(opts->release_agent, token + 14, PATH_MAX - 1);
>  			opts->release_agent[PATH_MAX - 1] = 0;
> +		} else if (!strncmp(token, "name=", 5)) {
> +			/* Specifying two names is forbidden */
> +			if (opts->name)
> +				return -EINVAL;
> +			opts->name = kzalloc(PATH_MAX, GFP_KERNEL);
> +			if (!opts->name)
> +				return -ENOMEM;
> +			strncpy(opts->name, token + 5, PATH_MAX - 1);
> +			opts->name[PATH_MAX - 1] = 0;

kstrndup()

>  		} else {
>  			struct cgroup_subsys *ss;
>  			int i;
> @@ -887,7 +905,7 @@ static int parse_cgroupfs_options(char *data,
>  	}
>  
>  	/* We can't have an empty hierarchy */
> -	if (!opts->subsys_bits)
> +	if (!opts->subsys_bits && !opts->name)
>  		return -EINVAL;
>  
>  	return 0;
> @@ -914,6 +932,12 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
>  		goto out_unlock;
>  	}
>  
> +	/* Don't allow name to change at remount */
> +	if (opts.name && strcmp(opts.name, root->name)) {
> +		ret = -EINVAL;
> +		goto out_unlock;
> +	}
> +
>  	ret = rebind_subsystems(root, opts.subsys_bits);
>  	if (ret)
>  		goto out_unlock;
> @@ -925,6 +949,7 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
>  		strcpy(root->release_agent_path, opts.release_agent);
>   out_unlock:
>  	kfree(opts.release_agent);
> +	kfree(opts.name);
>  	mutex_unlock(&cgroup_mutex);
>  	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
>  	return ret;
> @@ -958,28 +983,56 @@ static void init_cgroup_root(struct cgroupfs_root *root)
>  
>  static int cgroup_test_super(struct super_block *sb, void *data)
>  {
> -	struct cgroupfs_root *new = data;
> +	struct cgroup_sb_opts *new = data;
>  	struct cgroupfs_root *root = sb->s_fs_info;
>  
> -	/* First check subsystems */
> -	if (new->subsys_bits != root->subsys_bits)
> -	    return 0;
> +	/* If we asked for a name then it must match */
> +	if (new->name && strcmp(new->name, root->name))
> +		return 0;
>  
> -	/* Next check flags */
> -	if (new->flags != root->flags)

Is this change intended or unintended? With this change we allow:
 # mount -t cgroup -o cpu xxx /mnt1
 # mount -t cgroup -o cpu,noprefix xxx /mnt2
But files in /mnt2 still prefix with 'cpu.'

> +	/* If we asked for subsystems then they must match */
> +	if (new->subsys_bits && new->subsys_bits != root->subsys_bits)
>  		return 0;

This has already been checked.

>  
>  	return 1;
>  }
>  
> +static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
> +{
> +	struct cgroupfs_root *root;
> +
> +	if (!opts->subsys_bits)
> +		return ERR_PTR(-EINVAL);
> +
> +	root = kzalloc(sizeof(*root), GFP_KERNEL);
> +	if (!root)
> +		return ERR_PTR(-ENOMEM);
> +
> +	init_cgroup_root(root);
> +	root->subsys_bits = opts->subsys_bits;
> +	root->flags = opts->flags;
> +	if (opts->release_agent)
> +		strcpy(root->release_agent_path, opts->release_agent);
> +	if (opts->name)
> +		strcpy(root->name, opts->name);
> +	opts->created_root = true;
> +	return root;
> +}
> +
>  static int cgroup_set_super(struct super_block *sb, void *data)
>  {
>  	int ret;
> -	struct cgroupfs_root *root = data;
> +	struct cgroup_sb_opts *opts = data;
> +	struct cgroupfs_root *root;
>  
> +	root = cgroup_root_from_opts(opts);
> +	if (IS_ERR(root))
> +		return PTR_ERR(root);
>  	ret = set_anon_super(sb, NULL);
> -	if (ret)
> +	if (ret) {
> +		kfree(root);
>  		return ret;
> +	}
>  
>  	sb->s_fs_info = root;
>  	root->sb = sb;
> @@ -1018,47 +1071,26 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>  			 int flags, const char *unused_dev_name,
>  			 void *data, struct vfsmount *mnt)
>  {
> -	struct cgroup_sb_opts opts;
> +	struct cgroup_sb_opts opts = { 0 };

with the memset() in parse_cgroupfs_options(), this init is unneeded.

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
> -
> -	init_cgroup_root(root);
> -	root->subsys_bits = opts.subsys_bits;
> -	root->flags = opts.flags;
> -	if (opts.release_agent) {
> -		strcpy(root->release_agent_path, opts.release_agent);
> -		kfree(opts.release_agent);
> -	}

leaking opts.release_agent and opts.name with every successful mount.

> +	if (ret)
> +		goto out_err;
>  
> -	sb = sget(fs_type, cgroup_test_super, cgroup_set_super, root);
> +	sb = sget(fs_type, cgroup_test_super, cgroup_set_super, &opts);
>  
>  	if (IS_ERR(sb)) {
> -		kfree(root);
> -		return PTR_ERR(sb);
> +		ret = PTR_ERR(sb);
> +		goto out_err;
>  	}
>  
> -	if (sb->s_fs_info != root) {
> -		/* Reusing an existing superblock */
> -		BUG_ON(sb->s_root == NULL);
> -		kfree(root);
> -		root = NULL;
> -	} else {
> +	if (opts.created_root) {
>  		/* New superblock */
> +		struct cgroupfs_root *root = sb->s_fs_info;
> +		struct list_head tmp_cg_links;
>  		struct cgroup *root_cgrp = &root->top_cgroup;
>  		struct inode *inode;
>  		int i;
> @@ -1091,7 +1123,8 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>  		if (ret == -EBUSY) {
>  			mutex_unlock(&cgroup_mutex);
>  			mutex_unlock(&inode->i_mutex);
> -			goto free_cg_links;
> +			free_cg_links(&tmp_cg_links);
> +			goto drop_new_super;
>  		}
>  
>  		/* EBUSY should be the only error here */
> @@ -1130,11 +1163,14 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>  	simple_set_mnt(mnt, sb);
>  	return 0;
>  
> - free_cg_links:
> -	free_cg_links(&tmp_cg_links);
>   drop_new_super:
>  	up_write(&sb->s_umount);
>  	deactivate_super(sb);
> +
> + out_err:
> +	kfree(opts.release_agent);
> +	kfree(opts.name);
> +
>  	return ret;
>  }
>  
> @@ -2906,6 +2942,9 @@ static int proc_cgroup_show(struct seq_file *m, void *v)
>  		seq_printf(m, "%lu:", root->subsys_bits);
>  		for_each_subsys(root, ss)
>  			seq_printf(m, "%s%s", count++ ? "," : "", ss->name);
> +		if (strlen(root->name))
> +			seq_printf(m, "%sname=%s",
> +				   count++ ? "," : "", root->name);

s/count++/count

>  		seq_putc(m, ':');
>  		get_first_subsys(&root->top_cgroup, NULL, &subsys_id);
>  		cgrp = task_cgroup(tsk, subsys_id);
> @@ -3606,4 +3645,3 @@ css_get_next(struct cgroup_subsys *ss, int id,
>  	}
>  	return ret;
>  }
> -
> 
> 
> 
