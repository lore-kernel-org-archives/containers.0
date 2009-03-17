From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 4/7] [RFC] Allow cgroup hierarchies to be created with
	no	bound subsystems
Date: Tue, 17 Mar 2009 14:45:33 +0800
Message-ID: <49BF470D.8080600@cn.fujitsu.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>
	<20090312105137.24154.34890.stgit@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090312105137.24154.34890.stgit-B63HFAS8fGlSzHKm+aFRNNkmqwFzkYv6@public.gmane.org>
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
> [RFC] Allow cgroup hierarchies to be created with no bound subsystems
> 
> This patch removes the restriction that a cgroup hierarchy must have
> at least one bound subsystem. The mount option "none" is treated as an
> explicit request for no bound subsystems.
> 
> A hierarchy with no subsystems can be useful for plan task tracking,

s/plan/plain/ ;)

> and is also a step towards the support for multiply-bindable
> subsystems in a later patch in this series.
> 
> As part of this change, the hierarchy id is no longer calculated from
> the bitmask of subsystems in the hierarchy (since this is not
> guaranteed to be unique) but is allocated via an ida. Reference counts
> on cgroups from css_set objects are now taken explicitly one per
> hierarchy, rather than one per subsystem.
> 
> Example usage:
> 
> mount -t cgroup -o none,name=foo cgroup /mnt/cgroup
> 
> Based on the "no-op"/"none" subsystem concept proposed by
> kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
> 
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> ---
> 
>  kernel/cgroup.c |  158 ++++++++++++++++++++++++++++++++++++-------------------
>  1 files changed, 104 insertions(+), 54 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 9cdbbac..4a7ef2c 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -72,6 +72,9 @@ struct cgroupfs_root {
>  	 */
>  	unsigned long subsys_bits;
>  
> +	/* Unique id for this hierarchy. */
> +	int hierarchy_id;
> +
>  	/* The bitmask of subsystems currently attached to this hierarchy */
>  	unsigned long actual_subsys_bits;
>  
> @@ -142,6 +145,10 @@ struct css_id {
>  static LIST_HEAD(roots);
>  static int root_count;
>  
> +static DEFINE_IDA(hierarchy_ida);
> +static int next_hierarchy_id;
> +static DEFINE_SPINLOCK(hierarchy_id_lock);
> +
>  /* dummytop is a shorthand for the dummy hierarchy's top cgroup */
>  #define dummytop (&rootnode.top_cgroup)
>  
> @@ -259,42 +266,10 @@ static struct hlist_head *css_set_hash(struct cgroup_subsys_state *css[])
>   * compiled into their kernel but not actually in use */
>  static int use_task_css_set_links __read_mostly;
>  
> -/* When we create or destroy a css_set, the operation simply
> - * takes/releases a reference count on all the cgroups referenced
> - * by subsystems in this css_set. This can end up multiple-counting
> - * some cgroups, but that's OK - the ref-count is just a
> - * busy/not-busy indicator; ensuring that we only count each cgroup
> - * once would require taking a global lock to ensure that no
> - * subsystems moved between hierarchies while we were doing so.
> - *
> - * Possible TODO: decide at boot time based on the number of
> - * registered subsystems and the number of CPUs or NUMA nodes whether
> - * it's better for performance to ref-count every subsystem, or to
> - * take a global lock and only add one ref count to each hierarchy.
> - */
> -
> -/*
> - * unlink a css_set from the list and free it
> - */
> -static void unlink_css_set(struct css_set *cg)
> +static void __put_css_set(struct css_set *cg, int taskexit)
>  {
>  	struct cg_cgroup_link *link;
>  	struct cg_cgroup_link *saved_link;
> -
> -	hlist_del(&cg->hlist);
> -	css_set_count--;
> -
> -	list_for_each_entry_safe(link, saved_link, &cg->cg_links,
> -				 cg_link_list) {
> -		list_del(&link->cg_link_list);
> -		list_del(&link->cgrp_link_list);
> -		kfree(link);
> -	}
> -}
> -
> -static void __put_css_set(struct css_set *cg, int taskexit)
> -{
> -	int i;
>  	/*
>  	 * Ensure that the refcount doesn't hit zero while any readers
>  	 * can see it. Similar to atomic_dec_and_lock(), but for an
> @@ -307,20 +282,27 @@ static void __put_css_set(struct css_set *cg, int taskexit)
>  		write_unlock(&css_set_lock);
>  		return;
>  	}
> -	unlink_css_set(cg);
> -	write_unlock(&css_set_lock);
>  
> -	rcu_read_lock();
> -	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> -		struct cgroup *cgrp = rcu_dereference(cg->subsys[i]->cgroup);
> +	/* This css_set is dead. unlink it and release cgroup refcounts */
> +	hlist_del(&cg->hlist);
> +	css_set_count--;
> +
> +	list_for_each_entry_safe(link, saved_link, &cg->cg_links,
> +				 cg_link_list) {
> +		struct cgroup *cgrp = link->cgrp;
> +		list_del(&link->cg_link_list);
> +		list_del(&link->cgrp_link_list);
>  		if (atomic_dec_and_test(&cgrp->count) &&
>  		    notify_on_release(cgrp)) {
>  			if (taskexit)
>  				set_bit(CGRP_RELEASABLE, &cgrp->flags);
>  			check_for_release(cgrp);
>  		}
> +
> +		kfree(link);
>  	}
> -	rcu_read_unlock();
> +
> +	write_unlock(&css_set_lock);
>  	kfree(cg);
>  }
>  
> @@ -513,6 +495,7 @@ static void link_css_set(struct list_head *tmp_cg_links,
>  				cgrp_link_list);
>  	link->cg = cg;
>  	link->cgrp = cgrp;
> +	atomic_inc(&cgrp->count);
>  	list_move(&link->cgrp_link_list, &cgrp->css_sets);
>  	/*
>  	 * Always add links to the tail of the list so that the list
> @@ -533,7 +516,6 @@ static struct css_set *find_css_set(
>  {
>  	struct css_set *res;
>  	struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
> -	int i;
>  
>  	struct list_head tmp_cg_links;
>  
> @@ -572,10 +554,6 @@ static struct css_set *find_css_set(
>  
>  	write_lock(&css_set_lock);
>  	/* Add reference counts and links from the new css_set. */
> -	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> -		struct cgroup *cgrp = res->subsys[i]->cgroup;
> -		atomic_inc(&cgrp->count);
> -	}
>  	list_for_each_entry_safe(link, saved_link, &oldcg->cg_links,
>  				 cg_link_list) {
>  		struct cgroup *c = link->cgrp;
> @@ -955,6 +933,10 @@ struct cgroup_sb_opts {
>  	unsigned long flags;
>  	char *release_agent;
>  	char *name;
> +
> +	/* User explicitly requested empty subsystem */
> +	bool none;
> +
>  	/* A flag indicating that a root was created from this options block */
>  	bool created_root;
>  };
> @@ -983,6 +965,9 @@ static int parse_cgroupfs_options(char *data,
>  				if (!ss->disabled)
>  					opts->subsys_bits |= 1ul << i;
>  			}
> +		} else if (!strcmp(token, "none")) {
> +			/* Explicitly have no subsystems */
> +			opts->none = true;
>  		} else if (!strcmp(token, "noprefix")) {
>  			set_bit(ROOT_NOPREFIX, &opts->flags);
>  		} else if (!strncmp(token, "release_agent=", 14)) {
> @@ -1019,7 +1004,16 @@ static int parse_cgroupfs_options(char *data,
>  		}
>  	}
>  
> -	/* We can't have an empty hierarchy */
> +	/* Consistency checks */
> +
> +	/* Can't specify "none" and some subsystems */
> +	if (opts->subsys_bits && opts->none)
> +		return -EINVAL;
> +
> +	/*
> +	 * We either have to specify by name or by subsystems. (So all
> +	 * empty hierarchies must have a name).
> +	 */
>  	if (!opts->subsys_bits && !opts->name)
>  		return -EINVAL;
>  
> @@ -1085,6 +1079,7 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
>  	INIT_LIST_HEAD(&cgrp->release_list);
>  	init_rwsem(&cgrp->pids_mutex);
>  }
> +
>  static void init_cgroup_root(struct cgroupfs_root *root)
>  {
>  	struct cgroup *cgrp = &root->top_cgroup;
> @@ -1096,6 +1091,18 @@ static void init_cgroup_root(struct cgroupfs_root *root)
>  	init_cgroup_housekeeping(cgrp);
>  }
>  
> +static void init_root_id(struct cgroupfs_root *root)
> +{
> +	BUG_ON(!ida_pre_get(&hierarchy_ida, GFP_KERNEL));

we should return -errno, BUG_ON() on this is wrong

> +	spin_lock(&hierarchy_id_lock);
> +	if (ida_get_new_above(&hierarchy_ida, next_hierarchy_id,
> +			      &root->hierarchy_id)) {
> +		BUG_ON(ida_get_new(&hierarchy_ida, &root->hierarchy_id));
> +	}

next_hierarchy_id is redundant, just use ida_get_new() instead of
ida_get_new_above()

and I think we should check EAGAIN:

/*
 * ida_get_new - allocate new ID
 ...
 * If memory is required, it will return -EAGAIN, you should unlock
 * and go back to the idr_pre_get() call. ...
 */

> +	next_hierarchy_id = root->hierarchy_id + 1;
> +	spin_unlock(&hierarchy_id_lock);
> +}
> +
>  static int cgroup_test_super(struct super_block *sb, void *data)
>  {
>  	struct cgroup_sb_opts *new = data;
> @@ -1116,7 +1123,7 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
>  {
>  	struct cgroupfs_root *root;
>  
> -	if (!opts->subsys_bits)
> +	if (!opts->subsys_bits && !opts->none)
>  		return ERR_PTR(-EINVAL);
>  

Shouldn't we check this in parse_cgroupfs_options() instead?

>  	root = kzalloc(sizeof(*root), GFP_KERNEL);
> @@ -1124,6 +1131,8 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
>  		return ERR_PTR(-ENOMEM);
>  
>  	init_cgroup_root(root);
> +	init_root_id(root);
> +
>  	root->subsys_bits = opts->subsys_bits;
>  	root->flags = opts->flags;
>  	if (opts->release_agent)
> @@ -1134,6 +1143,15 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
>  	return root;
>  }
>  
> +static void cgroup_drop_root(struct cgroupfs_root *root)
> +{
> +	BUG_ON(!root->hierarchy_id);

I think this BUG_ON() is redundant, if root->hierarchy_id == 0,
we are freeing the dummy root, and kfree(root) should trigger
kernel oops.

> +	spin_lock(&hierarchy_id_lock);
> +	ida_remove(&hierarchy_ida, root->hierarchy_id);
> +	spin_unlock(&hierarchy_id_lock);
> +	kfree(root);
> +}
> +
>  static int cgroup_set_super(struct super_block *sb, void *data)
>  {
>  	int ret;
> @@ -1145,7 +1163,7 @@ static int cgroup_set_super(struct super_block *sb, void *data)
>  		return PTR_ERR(root);
>  	ret = set_anon_super(sb, NULL);
>  	if (ret) {
> -		kfree(root);
> +		cgroup_drop_root(root);
>  		return ret;
>  	}
>  
> @@ -1331,7 +1349,7 @@ static void cgroup_kill_sb(struct super_block *sb) {
>  	mutex_unlock(&cgroup_mutex);
>  
>  	kill_litter_super(sb);
> -	kfree(root);
> +	cgroup_drop_root(root);
>  }
>  
>  static struct file_system_type cgroup_fs_type = {
> @@ -2975,7 +2993,7 @@ int __init cgroup_init(void)
>  	/* Add init_css_set to the hash table */
>  	hhead = css_set_hash(init_css_set.subsys);
>  	hlist_add_head(&init_css_set.hlist, hhead);
> -
> +	init_root_id(&rootnode);
>  	err = register_filesystem(&cgroup_fs_type);
>  	if (err < 0)
>  		goto out;
> @@ -3030,7 +3048,7 @@ static int proc_cgroup_show(struct seq_file *m, void *v)
>  		struct cgroup *cgrp;
>  		int count = 0;
>  
> -		seq_printf(m, "%lu:", root->subsys_bits);
> +		seq_printf(m, "%d:", root->hierarchy_id);
>  		for_each_subsys(root, ss)
>  			seq_printf(m, "%s%s", count++ ? "," : "", ss->name);
>  		if (strlen(root->name))
> @@ -3076,8 +3094,8 @@ static int proc_cgroupstats_show(struct seq_file *m, void *v)
>  	mutex_lock(&cgroup_mutex);
>  	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
>  		struct cgroup_subsys *ss = subsys[i];
> -		seq_printf(m, "%s\t%lu\t%d\t%d\n",
> -			   ss->name, ss->root->subsys_bits,
> +		seq_printf(m, "%s\t%d\t%d\t%d\n",
> +			   ss->name, ss->root->hierarchy_id,
>  			   ss->root->number_of_cgroups, !ss->disabled);
>  	}
>  	mutex_unlock(&cgroup_mutex);
> @@ -3800,8 +3818,8 @@ static int current_css_set_cg_links_read(struct cgroup *cont,
>  			name = c->dentry->d_name.name;
>  		else
>  			name = "?";
> -		seq_printf(seq, "Root %lu group %s\n",
> -			   c->root->subsys_bits, name);
> +		seq_printf(seq, "Root %d group %s\n",
> +			   c->root->hierarchy_id, name);
>  		rcu_read_unlock();
>  	}
>  	task_unlock(current);
> @@ -3809,6 +3827,33 @@ static int current_css_set_cg_links_read(struct cgroup *cont,
>  	return 0;
>  }
>  
> +#define MAX_TASKS_SHOWN_PER_CSS 25
> +static int cgroup_css_links_read(struct cgroup *cont,
> +				 struct cftype *cft,
> +				 struct seq_file *seq)
> +{
> +	struct cg_cgroup_link *link, *saved_link;
> +	write_lock_irq(&css_set_lock);
> +	list_for_each_entry_safe(link, saved_link, &cont->css_sets,
> +				 cgrp_link_list) {
> +		struct css_set *cg = link->cg;
> +		struct task_struct *task, *saved_task;
> +		int count = 0;

> +		seq_printf(seq, "css_set %p\n", cg);
> +		list_for_each_entry_safe(task, saved_task, &cg->tasks,
> +					 cg_list) {
> +			if (count++ > MAX_TASKS_SHOWN_PER_CSS) {

actually this prints at most 26 tasks but not 25

and what's the concern to not print out all the tasks? the buffer
limit of seqfile?

> +				seq_puts(seq, "  ...\n");
> +				break;
> +			} else {
> +				seq_printf(seq, "  task %d\n", task->pid);

I guess we should call task_pid_vnr(tsk) instead of accessing task->pid
directly.

> +			}
> +		}
> +	}
> +	write_unlock_irq(&css_set_lock);
> +	return 0;
> +}
> +
>  static u64 releasable_read(struct cgroup *cgrp, struct cftype *cft)
>  {
>  	return test_bit(CGRP_RELEASABLE, &cgrp->flags);
> @@ -3840,6 +3885,11 @@ static struct cftype debug_files[] =  {
>  	},
>  
>  	{
> +		.name = "cgroup_css_links",
> +		.read_seq_string = cgroup_css_links_read,
> +	},
> +
> +	{
>  		.name = "releasable",
>  		.read_u64 = releasable_read,
>  	},
> 
> 
> 
