From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 1/2] cgroup:
	s/CGRP_CLONE_CHILDREN/CGRP_CPUSET_CLONE_CHILDREN/
Date: Wed, 14 Nov 2012 09:50:16 -0600
Message-ID: <20121114155016.GA21657__1173.38000932268$1352908252$gmane$org@sergelap>
References: <20121113202714.GA21185@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121113202714.GA21185-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> From 6e405c1ae4018d813e8ed9e0bd463d6976aebfa8 Mon Sep 17 00:00:00 2001
> From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Date: Tue, 13 Nov 2012 12:21:50 -0800
> 
> clone_children is only meaningful for cpuset and will stay that way.
> Rename the flag to reflect that and update documentation.  Also, drop
> clone_children() wrapper in cgroup.c.  The thin wrapper is used only a
> few times and one of them will go away soon.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Thanks.

(both)
Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

> Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> ---
> These two patches are based on top of "cgroup: allow->post_create() to
> fail" patchset.
> 
>  http://thread.gmane.org/gmane.linux.kernel.cgroups/5047
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-online-may-fail
> 
> and availalbe in the following branch.
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-remove-post_clone
> 
> Thanks.
> 
>  Documentation/cgroups/cgroups.txt |  8 +++-----
>  include/linux/cgroup.h            |  6 ++++--
>  kernel/cgroup.c                   | 28 ++++++++++++----------------
>  3 files changed, 19 insertions(+), 23 deletions(-)
> 
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
> index b06eea2..24cdf76 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt
> @@ -299,11 +299,9 @@ a cgroup hierarchy's release_agent path is empty.
>  1.5 What does clone_children do ?
>  ---------------------------------
>  
> -If the clone_children flag is enabled (1) in a cgroup, then all
> -cgroups created beneath will call the post_clone callbacks for each
> -subsystem of the newly created cgroup. Usually when this callback is
> -implemented for a subsystem, it copies the values of the parent
> -subsystem, this is the case for the cpuset.
> +This flag only affects the cpuset controller. If the clone_children
> +flag is enabled (1) in a cgroup, a new cpuset cgroup will copy its
> +configuration from the parent during initialization.
>  
>  1.6 How do I use cgroups ?
>  --------------------------
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 89c631d..926d8d1 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -143,9 +143,11 @@ enum {
>  	/* Control Group requires release notifications to userspace */
>  	CGRP_NOTIFY_ON_RELEASE,
>  	/*
> -	 * Clone cgroup values when creating a new child cgroup
> +	 * Clone the parent's configuration when creating a new child
> +	 * cpuset cgroup.  For historical reasons, this option can be
> +	 * specified at mount time and thus is implemented here.
>  	 */
> -	CGRP_CLONE_CHILDREN,
> +	CGRP_CPUSET_CLONE_CHILDREN,
>  };
>  
>  struct cgroup {
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 46c5119..a49572e 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -296,11 +296,6 @@ static int notify_on_release(const struct cgroup *cgrp)
>  	return test_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
>  }
>  
> -static int clone_children(const struct cgroup *cgrp)
> -{
> -	return test_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
> -}
> -
>  /*
>   * for_each_subsys() allows you to iterate on each subsystem attached to
>   * an active hierarchy
> @@ -1101,7 +1096,7 @@ static int cgroup_show_options(struct seq_file *seq, struct dentry *dentry)
>  		seq_puts(seq, ",xattr");
>  	if (strlen(root->release_agent_path))
>  		seq_printf(seq, ",release_agent=%s", root->release_agent_path);
> -	if (clone_children(&root->top_cgroup))
> +	if (test_bit(CGRP_CPUSET_CLONE_CHILDREN, &root->top_cgroup.flags))
>  		seq_puts(seq, ",clone_children");
>  	if (strlen(root->name))
>  		seq_printf(seq, ",name=%s", root->name);
> @@ -1113,7 +1108,7 @@ struct cgroup_sb_opts {
>  	unsigned long subsys_mask;
>  	unsigned long flags;
>  	char *release_agent;
> -	bool clone_children;
> +	bool cpuset_clone_children;
>  	char *name;
>  	/* User explicitly requested empty subsystem */
>  	bool none;
> @@ -1164,7 +1159,7 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
>  			continue;
>  		}
>  		if (!strcmp(token, "clone_children")) {
> -			opts->clone_children = true;
> +			opts->cpuset_clone_children = true;
>  			continue;
>  		}
>  		if (!strcmp(token, "xattr")) {
> @@ -1474,8 +1469,8 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
>  		strcpy(root->release_agent_path, opts->release_agent);
>  	if (opts->name)
>  		strcpy(root->name, opts->name);
> -	if (opts->clone_children)
> -		set_bit(CGRP_CLONE_CHILDREN, &root->top_cgroup.flags);
> +	if (opts->cpuset_clone_children)
> +		set_bit(CGRP_CPUSET_CLONE_CHILDREN, &root->top_cgroup.flags);
>  	return root;
>  }
>  
> @@ -3905,7 +3900,7 @@ fail:
>  static u64 cgroup_clone_children_read(struct cgroup *cgrp,
>  				    struct cftype *cft)
>  {
> -	return clone_children(cgrp);
> +	return test_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags);
>  }
>  
>  static int cgroup_clone_children_write(struct cgroup *cgrp,
> @@ -3913,9 +3908,9 @@ static int cgroup_clone_children_write(struct cgroup *cgrp,
>  				     u64 val)
>  {
>  	if (val)
> -		set_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
> +		set_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags);
>  	else
> -		clear_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
> +		clear_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags);
>  	return 0;
>  }
>  
> @@ -4130,8 +4125,8 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>  	if (notify_on_release(parent))
>  		set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
>  
> -	if (clone_children(parent))
> -		set_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
> +	if (test_bit(CGRP_CPUSET_CLONE_CHILDREN, &parent->flags))
> +		set_bit(CGRP_CPUSET_CLONE_CHILDREN, &cgrp->flags);
>  
>  	for_each_subsys(root, ss) {
>  		struct cgroup_subsys_state *css;
> @@ -4148,7 +4143,8 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>  				goto err_free_all;
>  		}
>  		/* At error, ->css_free() callback has to free assigned ID. */
> -		if (clone_children(parent) && ss->post_clone)
> +		if (test_bit(CGRP_CPUSET_CLONE_CHILDREN, &parent->flags) &&
> +		    ss->post_clone)
>  			ss->post_clone(cgrp);
>  
>  		if (ss->broken_hierarchy && !ss->warned_broken_hierarchy &&
> -- 
> 1.7.11.7
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
