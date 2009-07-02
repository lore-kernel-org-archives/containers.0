From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 7/9] [RFC] Support multiply-bindable cgroup subsystems
Date: Thu, 2 Jul 2009 11:45:55 +0900
Message-ID: <20090702114555.b7253edf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>
	<20090702021128.14469.3360.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702021128.14469.3360.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 01 Jul 2009 19:11:28 -0700
Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> [RFC] Support multiply-bindable cgroup subsystems
> 
> This patch allows a cgroup subsystem to be marked as bindable on
> multiple cgroup hierarchies independently, when declared in
> cgroup_subsys.h via MULTI_SUBSYS() rather than SUBSYS().
> 
> The state for such subsystems cannot be accessed directly from a
> task->cgroups (since there's no unique mapping for a task) but instead
> must be accessed via a particular control group object.
> 
> Multiply-bound subsystems are useful in cases where there's no direct
> correspondence between the cgroup configuration and some property of
> the kernel outside of the cgroups subsystem.  So this would not be
> applicable to e.g. the CFS cgroup, since there has to a unique mapping
> from a task to its CFS run queue.
> 
> As an example, the "debug" subsystem is marked multiply-bindable,
> since it has no state outside the cgroups framework itself.
> 
> Example usage:
> 
> mount -t cgroup -o name=foo,debug,cpu cgroup /mnt1
> mount -t cgroup -o name=bar,debug,memory cgroup /mnt2
> 
> Open Issues:
> 
> - in the current version of this patch, mounting a cgroups hierarchy
>   with no options does *not* get you any of the multi-bindable
>   subsystems; possibly for consistency it should give you all of the
>   multi-bindable subsystems as well as all of the single-bindable
>   subsystems.
> 
I don't think this is a big problem. Hmm, I wonder there are no people who
uses cgroup without any options (= mounts all subsys at once)...


> - how can we avoid the checkpatch.pl errors due to creative use of
>   macros to generate enum names?
> 
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> ---
> 
>  include/linux/cgroup.h        |   38 +++++++-
>  include/linux/cgroup_subsys.h |    2 
>  kernel/cgroup.c               |  192 ++++++++++++++++++++++++++++-------------
>  3 files changed, 168 insertions(+), 64 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index a6bb0ca..02fdea9 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -39,10 +39,38 @@ extern int cgroupstats_build(struct cgroupstats *stats,
>  
>  extern struct file_operations proc_cgroup_operations;
>  
> -/* Define the enumeration of all cgroup subsystems */
> -#define SUBSYS(_x) _x ## _subsys_id,
> +/*
> + * Define the enumeration of all cgroup subsystems. There are two
> + * kinds of subsystems:
> + *
> + * - regular (singleton) subsystems can be only mounted once; these
> + * generally correspond to some system that has substantial state
> + * outside of the cgroups framework, or where the state is being used
> + * to control some external behaviour (e.g. CPU scheduler).  Every
> + * task has an associated state pointer (accessed efficiently through
> + * task->cgroups) for each singleton subsystem.
> + *
> + * - multiply-bound subsystems may be mounted on zero or more
> + * hierarchies. Since there's no unique mapping from a task to a
> + * subsystem state pointer for multiply-bound subsystems, the state of
> + * these subsystems cannot be accessed rapidly from a task
> + * pointer. These correspond to subsystems where most or all of the
> + * state is maintained within the subsystem itself, and/or the
> + * subsystem is used for monitoring rather than control.
> + */
>  enum cgroup_subsys_id {
> +#define SUBSYS(_x) _x ## _subsys_id,
> +#define MULTI_SUBSYS(_x)
> +#include <linux/cgroup_subsys.h>
> +#undef SUBSYS
> +#undef MULTI_SUBSYS
> +	CGROUP_SINGLETON_SUBSYS_COUNT,
> +	CGROUP_DUMMY_ENUM_RESET = CGROUP_SINGLETON_SUBSYS_COUNT - 1,
> +#define SUBSYS(_x)
> +#define MULTI_SUBSYS(_x) _x ## _subsys_id,
>  #include <linux/cgroup_subsys.h>
> +#undef SUBSYS
> +#undef MULTI_SUBSYS
>  	CGROUP_SUBSYS_COUNT
>  };

Wow...seems complicated. How about adding linux/cgroup_multisubsys.h ?

Thanks,
-Kame


>  #undef SUBSYS
> @@ -231,7 +259,7 @@ struct css_set {
>  	 * time). Multi-subsystems don't have an entry in here since
>  	 * there's no unique state for a given task.
>  	 */
> -	struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT];
> +	struct cgroup_subsys_state *subsys[CGROUP_SINGLETON_SUBSYS_COUNT];
>  };
>  
>  /*
> @@ -418,8 +446,10 @@ struct cgroup_subsys {
>  };
>  
>  #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
> +#define MULTI_SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
>  #include <linux/cgroup_subsys.h>
>  #undef SUBSYS
> +#undef MULTI_SUBSYS
>  
>  static inline struct cgroup_subsys_state *cgroup_subsys_state(
>  	struct cgroup *cgrp, int subsys_id)
> @@ -430,6 +460,8 @@ static inline struct cgroup_subsys_state *cgroup_subsys_state(
>  static inline struct cgroup_subsys_state *task_subsys_state(
>  	struct task_struct *task, int subsys_id)
>  {
> +	/* This check is optimized out for most callers */
> +	BUG_ON(subsys_id >= CGROUP_SINGLETON_SUBSYS_COUNT);
>  	return rcu_dereference(task->cgroups->subsys[subsys_id]);
>  }
>  
> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
> index 9c8d31b..f78605e 100644
> --- a/include/linux/cgroup_subsys.h
> +++ b/include/linux/cgroup_subsys.h
> @@ -14,7 +14,7 @@ SUBSYS(cpuset)
>  /* */
>  
>  #ifdef CONFIG_CGROUP_DEBUG
> -SUBSYS(debug)
> +MULTI_SUBSYS(debug)
>  #endif
>  
>  /* */
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 74840ea..a527687 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -54,10 +54,18 @@
>  static DEFINE_MUTEX(cgroup_mutex);
>  
>  /* Generate an array of cgroup subsystem pointers */
> -#define SUBSYS(_x) &_x ## _subsys,
>  
>  static struct cgroup_subsys *subsys[] = {
> +#define SUBSYS(_x) (&_x ## _subsys),
> +#define MULTI_SUBSYS(_x)
>  #include <linux/cgroup_subsys.h>
> +#undef SUBSYS
> +#undef MULTI_SUBSYS
> +#define SUBSYS(_x)
> +#define MULTI_SUBSYS(_x) (&_x ## _subsys),
> +#include <linux/cgroup_subsys.h>
> +#undef SUBSYS
> +#undef MULTI_SUBSYS
>  };
>  
>  #define MAX_CGROUP_ROOT_NAMELEN 64
> @@ -269,7 +277,7 @@ static struct hlist_head *css_set_hash(struct cgroup_subsys_state *css[])
>  	int index;
>  	unsigned long tmp = 0UL;
>  
> -	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++)
> +	for (i = 0; i < CGROUP_SINGLETON_SUBSYS_COUNT; i++)
>  		tmp += (unsigned long)css[i];
>  	tmp = (tmp >> 16) ^ tmp;
>  
> @@ -440,7 +448,7 @@ static struct css_set *find_existing_css_set(
>  
>  	/* Build the set of subsystem state objects that we want to
>  	 * see in the new css_set */
> -	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> +	for (i = 0; i < CGROUP_SINGLETON_SUBSYS_COUNT; i++) {
>  		if (root->subsys_bits & (1UL << i)) {
>  			/* Subsystem is in this hierarchy. So we want
>  			 * the subsystem state from the new
> @@ -534,7 +542,7 @@ static struct css_set *find_css_set(
>  	struct css_set *oldcg, struct cgroup *cgrp)
>  {
>  	struct css_set *res;
> -	struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
> +	struct cgroup_subsys_state *template[CGROUP_SINGLETON_SUBSYS_COUNT];
>  
>  	struct list_head tmp_cg_links;
>  
> @@ -857,17 +865,33 @@ static void cgroup_wakeup_rmdir_waiters(const struct cgroup *cgrp)
>  		wake_up_all(&cgroup_rmdir_waitq);
>  }
>  
> +static void init_cgroup_css(struct cgroup_subsys_state *css,
> +			       struct cgroup_subsys *ss,
> +			       struct cgroup *cgrp)
> +{
> +	css->cgroup = cgrp;
> +	atomic_set(&css->refcnt, 1);
> +	css->flags = 0;
> +	css->id = NULL;
> +	if (cgrp == dummytop)
> +		set_bit(CSS_ROOT, &css->flags);
> +	BUG_ON(cgrp->subsys[ss->subsys_id]);
> +	cgrp->subsys[ss->subsys_id] = css;
> +}
> +
>  static int rebind_subsystems(struct cgroupfs_root *root,
>  			     unsigned long final_bits)
>  {
> -	unsigned long added_bits, removed_bits;
> +	unsigned long added_bits, removed_bits, rollback_bits;
> +	int ret = 0;
>  	struct cgroup *cgrp = &root->top_cgroup;
>  	int i;
>  
>  	removed_bits = root->subsys_bits & ~final_bits;
>  	added_bits = final_bits & ~root->subsys_bits;
> +	rollback_bits = 0;
>  	/* Check that any added subsystems are currently free */
> -	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> +	for (i = 0; i < CGROUP_SINGLETON_SUBSYS_COUNT; i++) {
>  		unsigned long bit = 1UL << i;
>  		if (!(bit & added_bits))
>  			continue;
> @@ -884,33 +908,45 @@ static int rebind_subsystems(struct cgroupfs_root *root,
>  	if (root->number_of_cgroups > 1)
>  		return -EBUSY;
>  
> -	/* Process each subsystem */
> +	/*
> +	 * Process each subsystem. First try to add all new
> +	 * subsystems, since this may require rollback
> +	 */
>  	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
>  		struct cgroup_subsys *ss = subsys[i];
> +		bool singleton = i < CGROUP_SINGLETON_SUBSYS_COUNT;
>  		unsigned long bit = 1UL << i;
>  		if (bit & added_bits) {
> +			struct cgroup_subsys_state *css;
>  			/* We're binding this subsystem to this hierarchy */
>  			BUG_ON(cgrp->subsys[i]);
> -			BUG_ON(!dummytop->subsys[i]);
> -			BUG_ON(dummytop->subsys[i]->cgroup != dummytop);
> -			BUG_ON(!(rootnode.subsys_bits & bit));
> +			if (singleton) {
> +				css = dummytop->subsys[i];
> +				BUG_ON(!css);
> +
> +				BUG_ON(css->cgroup != dummytop);
> +				BUG_ON(!(rootnode.subsys_bits & bit));
> +			} else {
> +				BUG_ON(dummytop->subsys[i]);
> +				BUG_ON(rootnode.subsys_bits & bit);
> +				css = ss->create(ss, cgrp);
> +				if (IS_ERR(css)) {
> +					ret = PTR_ERR(css);
> +					break;
> +				}
> +				init_cgroup_css(css, ss, cgrp);
> +			}
>  			mutex_lock(&ss->hierarchy_mutex);
> -			cgrp->subsys[i] = dummytop->subsys[i];
> -			cgrp->subsys[i]->cgroup = cgrp;
> -			rootnode.subsys_bits &= ~bit;
> +			cgrp->subsys[i] = css;
> +			css->cgroup = cgrp;
> +			if (singleton)
> +				rootnode.subsys_bits &= ~bit;
>  			root->subsys_bits |= bit;
>  			mutex_unlock(&ss->hierarchy_mutex);
> +			rollback_bits |= bit;
>  		} else if (bit & removed_bits) {
> -			/* We're removing this subsystem */
> -			BUG_ON(cgrp->subsys[i] != dummytop->subsys[i]);
> -			BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
> -			BUG_ON(rootnode.subsys_bits & bit);
> -			mutex_lock(&ss->hierarchy_mutex);
> -			dummytop->subsys[i]->cgroup = dummytop;
> -			cgrp->subsys[i] = NULL;
> -			root->subsys_bits &= ~bit;
> -			rootnode.subsys_bits |= bit;
> -			mutex_unlock(&ss->hierarchy_mutex);
> +			/* Deal with this after adds are successful */
> +			BUG_ON(!cgrp->subsys[i]);
>  		} else if (bit & final_bits) {
>  			/* Subsystem state should already exist */
>  			BUG_ON(!cgrp->subsys[i]);
> @@ -919,9 +955,47 @@ static int rebind_subsystems(struct cgroupfs_root *root,
>  			BUG_ON(cgrp->subsys[i]);
>  		}
>  	}
> +	if (ret) {
> +		/* We failed to add some subsystem - roll back */
> +		removed_bits = rollback_bits;
> +	}
> +
> +	/*
> +	 * Now either remove the subsystems that were requested to be
> +	 * removed, or roll back the subsystems that were added before
> +	 * the error occurred
> +	 */
> +	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> +		struct cgroup_subsys *ss = subsys[i];
> +		bool singleton = i < CGROUP_SINGLETON_SUBSYS_COUNT;
> +		unsigned long bit = 1UL << i;
> +		if (bit & removed_bits) {
> +			struct cgroup_subsys_state *css;
> +			/* We're removing this subsystem */
> +			css = cgrp->subsys[i];
> +			BUG_ON(css->cgroup != cgrp);
> +			if (singleton) {
> +				BUG_ON(css != dummytop->subsys[i]);
> +				BUG_ON(rootnode.subsys_bits & bit);
> +			}
> +			mutex_lock(&ss->hierarchy_mutex);
> +			if (singleton) {
> +				css->cgroup = dummytop;
> +			} else {
> +				/* Is this safe? */
> +				ss->destroy(ss, cgrp);
> +			}
> +			cgrp->subsys[i] = NULL;
> +			root->subsys_bits &= ~bit;
> +			if (singleton)
> +				rootnode.subsys_bits |= bit;
> +			mutex_unlock(&ss->hierarchy_mutex);
> +		}
> +	}
> +
>  	synchronize_rcu();
>  
> -	return 0;
> +	return ret;
>  }
>  
>  static int cgroup_show_options(struct seq_file *seq, struct vfsmount *vfs)
> @@ -976,7 +1050,7 @@ static int parse_cgroupfs_options(char *data,
>  			/* Add all non-disabled subsystems */
>  			int i;
>  			opts->subsys_bits = 0;
> -			for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> +			for (i = 0; i < CGROUP_SINGLETON_SUBSYS_COUNT; i++) {
>  				struct cgroup_subsys *ss = subsys[i];
>  				if (!ss->disabled)
>  					opts->subsys_bits |= 1ul << i;
> @@ -1296,16 +1370,13 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>  		}
>  
>  		ret = rebind_subsystems(root, opts.subsys_bits);
> -		if (ret == -EBUSY) {
> +		if (ret) {
>  			mutex_unlock(&cgroup_mutex);
>  			mutex_unlock(&inode->i_mutex);
>  			free_cg_links(&tmp_cg_links);
>  			goto drop_new_super;
>  		}
>  
> -		/* EBUSY should be the only error here */
> -		BUG_ON(ret);
> -
>  		list_add(&root->root_list, &roots);
>  		root_count++;
>  
> @@ -2623,20 +2694,6 @@ static int cgroup_populate_dir(struct cgroup *cgrp)
>  	return 0;
>  }
>  
> -static void init_cgroup_css(struct cgroup_subsys_state *css,
> -			       struct cgroup_subsys *ss,
> -			       struct cgroup *cgrp)
> -{
> -	css->cgroup = cgrp;
> -	atomic_set(&css->refcnt, 1);
> -	css->flags = 0;
> -	css->id = NULL;
> -	if (cgrp == dummytop)
> -		set_bit(CSS_ROOT, &css->flags);
> -	BUG_ON(cgrp->subsys[ss->subsys_id]);
> -	cgrp->subsys[ss->subsys_id] = css;
> -}
> -
>  static void cgroup_lock_hierarchy(struct cgroupfs_root *root)
>  {
>  	/* We need to take each hierarchy_mutex in a consistent order */
> @@ -2922,21 +2979,23 @@ again:
>  static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
>  {
>  	struct cgroup_subsys_state *css;
> -
> +	bool singleton = ss->subsys_id < CGROUP_SINGLETON_SUBSYS_COUNT;
>  	printk(KERN_INFO "Initializing cgroup subsys %s\n", ss->name);
>  
> -	/* Create the top cgroup state for this subsystem */
> -	css = ss->create(ss, dummytop);
> -	/* We don't handle early failures gracefully */
> -	BUG_ON(IS_ERR(css));
> -	init_cgroup_css(css, ss, dummytop);
> -
> -	/* Update the init_css_set to contain a subsys
> -	 * pointer to this state - since the subsystem is
> -	 * newly registered, all tasks and hence the
> -	 * init_css_set is in the subsystem's top cgroup. */
> -	init_css_set.subsys[ss->subsys_id] = dummytop->subsys[ss->subsys_id];
> +	if (singleton) {
> +		/* Create the top cgroup state for this subsystem */
> +		css = ss->create(ss, dummytop);
> +		/* We don't handle early failures gracefully */
> +		BUG_ON(IS_ERR(css));
> +		init_cgroup_css(css, ss, dummytop);
>  
> +		/* Update the init_css_set to contain a subsys
> +		 * pointer to this state - since the subsystem is
> +		 * newly registered, all tasks and hence the
> +		 * init_css_set is in the subsystem's top cgroup. */
> +		init_css_set.subsys[ss->subsys_id] = css;
> +		rootnode.subsys_bits |= 1ULL << ss->subsys_id;
> +	}
>  	need_forkexit_callback |= ss->fork || ss->exit;
>  
>  	/* At system boot, before all subsystems have been
> @@ -2948,7 +3007,6 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
>  	lockdep_set_class(&ss->hierarchy_mutex, &ss->subsys_key);
>  	ss->active = 1;
>  
> -	rootnode.subsys_bits |= 1ULL << ss->subsys_id;
>  }
>  
>  /**
> @@ -3125,23 +3183,35 @@ struct file_operations proc_cgroup_operations = {
>  static void proc_show_subsys(struct seq_file *m, struct cgroupfs_root *root,
>  			     struct cgroup_subsys *ss)
>  {
> -	seq_printf(m, "%s\t%d\t%d\t%d\n",
> +	seq_printf(m, "%s\t%d\t%d\t%d\t%d\n",
>  		   ss->name, root->hierarchy_id,
> -		   root->number_of_cgroups, !ss->disabled);
> +		   root->number_of_cgroups, !ss->disabled,
> +		   ss->subsys_id >= CGROUP_SINGLETON_SUBSYS_COUNT);
>  }
>  
>  static int proc_cgroupstats_show(struct seq_file *m, void *v)
>  {
>  	int i;
> -	seq_puts(m, "#subsys_name\thierarchy\tnum_cgroups\tenabled\n");
> +	seq_puts(m, "#subsys_name\thierarchy\tnum_cgroups\tenabled\tmulti\n");
>  	mutex_lock(&cgroup_mutex);
>  	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> +		bool seen = false;
>  		struct cgroup_subsys *ss = subsys[i];
>  		unsigned long bit = 1ULL << ss->subsys_id;
>  		struct cgroupfs_root *root;
>  		for_each_root(root) {
> -			if (root->subsys_bits & bit)
> +			if (root->subsys_bits & bit) {
>  				proc_show_subsys(m, root, ss);
> +				seen = true;
> +			}
> +		}
> +		if (!seen) {
> +			BUG_ON(i < CGROUP_SINGLETON_SUBSYS_COUNT);
> +			/*
> +			 * multi-bindable subsystems show up in the
> +			 * rootnode if they're not bound elsewhere.
> +			 */
> +			proc_show_subsys(m, &rootnode, ss);
>  		}
>  	}
>  	mutex_unlock(&cgroup_mutex);
> @@ -3317,6 +3387,8 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
>  
>  	/* We shouldn't be called by an unregistered subsystem */
>  	BUG_ON(!subsys->active);
> +	/* We can only support singleton subsystems */
> +	BUG_ON(subsys->subsys_id >= CGROUP_SINGLETON_SUBSYS_COUNT);
>  
>  	/* First figure out what hierarchy and cgroup we're dealing
>  	 * with, and pin them so we can drop cgroup_mutex */
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
