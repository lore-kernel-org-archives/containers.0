From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 1/9] cgroup: add cgroup_subsys->post_create()
Date: Wed, 7 Nov 2012 16:25:16 +0100
Message-ID: <20121107152516.GA4131@dhcp22.suse.cz>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351931915-1701-2-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On Sat 03-11-12 01:38:27, Tejun Heo wrote:
> Currently, there's no way for a controller to find out whether a new
> cgroup finished all ->create() allocatinos successfully and is
> considered "live" by cgroup.
> 
> This becomes a problem later when we add generic descendants walking
> to cgroup which can be used by controllers as controllers don't have a
> synchronization point where it can synchronize against new cgroups
> appearing in such walks.
> 
> This patch adds ->post_create().  It's called after all ->create()
> succeeded and the cgroup is linked into the generic cgroup hierarchy.
> This plays the counterpart of ->pre_destroy().

Hmm, I had to look at "cgroup_freezer: implement proper hierarchy
support" to actually understand what is the callback good for. The above
sounds as if the callback is needed when a controller wants to use
the new iterators or when pre_destroy is defined.

I think it would be helpful if the changelog described that the callback
is needed when the controller keeps a mutable shared state for the
hierarchy. For example memory controller doesn't have any such a strict
requirement so we can safely use your new iterators without pre_destroy.

Anyway, I like this change because the shared state is now really easy
to implement.

> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

> ---
>  include/linux/cgroup.h |  1 +
>  kernel/cgroup.c        | 12 ++++++++++--
>  2 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index fe876a7..b442122 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -438,6 +438,7 @@ int cgroup_taskset_size(struct cgroup_taskset *tset);
>  
>  struct cgroup_subsys {
>  	struct cgroup_subsys_state *(*create)(struct cgroup *cgrp);
> +	void (*post_create)(struct cgroup *cgrp);
>  	void (*pre_destroy)(struct cgroup *cgrp);
>  	void (*destroy)(struct cgroup *cgrp);
>  	int (*can_attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index e3045ad..f05d992 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -4060,10 +4060,15 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>  	if (err < 0)
>  		goto err_remove;
>  
> -	/* each css holds a ref to the cgroup's dentry */
> -	for_each_subsys(root, ss)
> +	for_each_subsys(root, ss) {
> +		/* each css holds a ref to the cgroup's dentry */
>  		dget(dentry);
>  
> +		/* creation succeeded, notify subsystems */
> +		if (ss->post_create)
> +			ss->post_create(cgrp);
> +	}
> +
>  	/* The cgroup directory was pre-locked for us */
>  	BUG_ON(!mutex_is_locked(&cgrp->dentry->d_inode->i_mutex));
>  
> @@ -4281,6 +4286,9 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
>  
>  	ss->active = 1;
>  
> +	if (ss->post_create)
> +		ss->post_create(&ss->root->top_cgroup);
> +
>  	/* this function shouldn't be used with modular subsystems, since they
>  	 * need to register a subsys_id, among other things */
>  	BUG_ON(ss->module);
> -- 
> 1.7.11.7
> 

-- 
Michal Hocko
SUSE Labs
