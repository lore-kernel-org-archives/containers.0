From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/7] cgroups: Make freezer subsystem bindable
Date: Fri, 22 Oct 2010 13:57:55 -0700
Message-ID: <20101022205755.GJ10119@count0.beaverton.ibm.com>
References: <4CC146A4.9090505@cn.fujitsu.com> <4CC1473D.9070201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4CC1473D.9070201-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Oct 22, 2010 at 04:11:41PM +0800, Li Zefan wrote:
> To make it bindable, we need to thaw all processes when unbinding
> the freezer subsystem from a cgroup hierarchy.
> 
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Based on experience using cgroups and questions we've fielded in the
past on IRC I'd say users will really appreciate this.

We're planning to use the freezer in checkpoint/restart. Since
checkpoint requires the tasks to remain frozen for the duration of
the syscall we add a kernel-internal freezer subsystem interface
which prevents the cgroup from thawing. So we'll need some way to
"block" unbinding for that as well.

Perhaps the bind op should be able to return an error when
unbind == true? Although that raises the question of what to do if
only one of multiple unbinds fails..

Alternately you could split the bind/unbind op function pointers
and get rid of the boolean argument. Then just don't fill in the
freezer's unbind op and refuse to unbind subsystems that lack
the unbind op. That seems a bit cleaner for now at least.

Cheers,
	-Matt Helsley

> ---
>  include/linux/cgroup.h  |    3 ++-
>  kernel/cgroup.c         |   22 ++++++++++++++++++++--
>  kernel/cgroup_freezer.c |   19 +++++++++++++++++--
>  3 files changed, 39 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 49369ff..1e4e1df 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -478,7 +478,8 @@ struct cgroup_subsys {
>  	int (*populate)(struct cgroup_subsys *ss,
>  			struct cgroup *cgrp);
>  	void (*post_clone)(struct cgroup_subsys *ss, struct cgroup *cgrp);
> -	void (*bind)(struct cgroup_subsys *ss, struct cgroup *root);
> +	void (*bind)(struct cgroup_subsys *ss, struct cgroup *cgrp,
> +		     bool unbind);
> 
>  	int subsys_id;
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 6364bb5..12c1f7c 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1105,6 +1105,22 @@ static int hierarchy_populate_dir(struct cgroup *cgrp, void *data)
>  	return 0;
>  }
> 
> +static int hierarchy_subsys_bind(struct cgroup *cgrp, void *data)
> +{
> +	struct cgroup_subsys *ss = data;
> +
> +	ss->bind(ss, cgrp, false);
> +	return 0;
> +}
> +
> +static int hierarchy_subsys_unbind(struct cgroup *cgrp, void *data)
> +{
> +	struct cgroup_subsys *ss = data;;

nit: two semicolons

> +
> +	ss->bind(ss, cgrp, true);
> +	return 0;
> +}
> +
>  /*
>   * Call with cgroup_mutex held. Drops reference counts on modules, including
>   * any duplicate ones that parse_cgroupfs_options took. If this function
> @@ -1172,7 +1188,8 @@ static int rebind_subsystems(struct cgroupfs_root *root,
>  			list_move(&ss->sibling, &root->subsys_list);
>  			ss->root = root;
>  			if (ss->bind)
> -				ss->bind(ss, cgrp);
> +				cgroup_walk_hierarchy(hierarchy_subsys_bind,
> +						      ss, cgrp);
>  			mutex_unlock(&ss->hierarchy_mutex);
>  			/* refcount was already taken, and we're keeping it */
>  		} else if (bit & removed_bits) {
> @@ -1180,7 +1197,8 @@ static int rebind_subsystems(struct cgroupfs_root *root,
>  			BUG_ON(ss == NULL);
>  			mutex_lock(&ss->hierarchy_mutex);
>  			if (ss->bind)
> -				ss->bind(ss, dummytop);
> +				cgroup_walk_hierarchy(hierarchy_subsys_unbind,
> +						      ss, cgrp);
>  			subsys[i]->root = &rootnode;
>  			list_move(&ss->sibling, &rootnode.subsys_list);
>  			mutex_unlock(&ss->hierarchy_mutex);
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index e7bebb7..de13ce4 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -383,6 +383,21 @@ static int freezer_populate(struct cgroup_subsys *ss, struct cgroup *cgroup)
>  	return cgroup_add_files(cgroup, ss, files, ARRAY_SIZE(files));
>  }
> 
> +/*
> + * Thaw all processes before unbinding the freezer subsysem from
> + * cgroup hierarchy.
> + * */
> +static void freezer_bind(struct cgroup_subsys *ss, struct cgroup *cgrp,
> +			 bool unbind)
> +{
> +	struct freezer *freezer = cgroup_freezer(cgrp);
> +
> +	if (!unbind)
> +		return;
> +
> +	unfreeze_cgroup(cgrp, freezer);
> +}
> +
>  struct cgroup_subsys freezer_subsys = {
>  	.name		= "freezer",
>  	.create		= freezer_create,
> @@ -390,7 +405,7 @@ struct cgroup_subsys freezer_subsys = {
>  	.populate	= freezer_populate,
>  	.subsys_id	= freezer_subsys_id,
>  	.can_attach	= freezer_can_attach,
> -	.attach		= NULL,
>  	.fork		= freezer_fork,
> -	.exit		= NULL,
> +	.bind		= freezer_bind,
> +	.can_bind	= 1,
>  };
> -- 
> 1.7.0.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
