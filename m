From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 4/9] cgroup_freezer: trivial cleanups
Date: Thu, 8 Nov 2012 10:53:53 +0100
Message-ID: <20121108095353.GB31821@dhcp22.suse.cz>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351931915-1701-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On Sat 03-11-12 01:38:30, Tejun Heo wrote:
> * Clean-up indentation and line-breaks.  Drop the invalid comment
>   about freezer->lock.
> 
> * Make all internal functions take @freezer instead of both @cgroup
>   and @freezer.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Looks reasonable
Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

> ---
>  kernel/cgroup_freezer.c | 41 +++++++++++++++++++----------------------
>  1 file changed, 19 insertions(+), 22 deletions(-)
> 
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index bedefd9..975b3d8 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -29,17 +29,15 @@ enum freezer_state {
>  };
>  
>  struct freezer {
> -	struct cgroup_subsys_state css;
> -	enum freezer_state state;
> -	spinlock_t lock; /* protects _writes_ to state */
> +	struct cgroup_subsys_state	css;
> +	enum freezer_state		state;
> +	spinlock_t			lock;
>  };
>  
> -static inline struct freezer *cgroup_freezer(
> -		struct cgroup *cgroup)
> +static inline struct freezer *cgroup_freezer(struct cgroup *cgroup)
>  {
> -	return container_of(
> -		cgroup_subsys_state(cgroup, freezer_subsys_id),
> -		struct freezer, css);
> +	return container_of(cgroup_subsys_state(cgroup, freezer_subsys_id),
> +			    struct freezer, css);
>  }
>  
>  static inline struct freezer *task_freezer(struct task_struct *task)
> @@ -180,8 +178,9 @@ out:
>   * migrated into or out of @cgroup, so we can't verify task states against
>   * @freezer state here.  See freezer_attach() for details.
>   */
> -static void update_if_frozen(struct cgroup *cgroup, struct freezer *freezer)
> +static void update_if_frozen(struct freezer *freezer)
>  {
> +	struct cgroup *cgroup = freezer->css.cgroup;
>  	struct cgroup_iter it;
>  	struct task_struct *task;
>  
> @@ -211,12 +210,11 @@ notyet:
>  static int freezer_read(struct cgroup *cgroup, struct cftype *cft,
>  			struct seq_file *m)
>  {
> -	struct freezer *freezer;
> +	struct freezer *freezer = cgroup_freezer(cgroup);
>  	enum freezer_state state;
>  
> -	freezer = cgroup_freezer(cgroup);
>  	spin_lock_irq(&freezer->lock);
> -	update_if_frozen(cgroup, freezer);
> +	update_if_frozen(freezer);
>  	state = freezer->state;
>  	spin_unlock_irq(&freezer->lock);
>  
> @@ -225,8 +223,9 @@ static int freezer_read(struct cgroup *cgroup, struct cftype *cft,
>  	return 0;
>  }
>  
> -static void freeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
> +static void freeze_cgroup(struct freezer *freezer)
>  {
> +	struct cgroup *cgroup = freezer->css.cgroup;
>  	struct cgroup_iter it;
>  	struct task_struct *task;
>  
> @@ -236,8 +235,9 @@ static void freeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
>  	cgroup_iter_end(cgroup, &it);
>  }
>  
> -static void unfreeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
> +static void unfreeze_cgroup(struct freezer *freezer)
>  {
> +	struct cgroup *cgroup = freezer->css.cgroup;
>  	struct cgroup_iter it;
>  	struct task_struct *task;
>  
> @@ -247,11 +247,9 @@ static void unfreeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
>  	cgroup_iter_end(cgroup, &it);
>  }
>  
> -static void freezer_change_state(struct cgroup *cgroup,
> +static void freezer_change_state(struct freezer *freezer,
>  				 enum freezer_state goal_state)
>  {
> -	struct freezer *freezer = cgroup_freezer(cgroup);
> -
>  	/* also synchronizes against task migration, see freezer_attach() */
>  	spin_lock_irq(&freezer->lock);
>  
> @@ -260,13 +258,13 @@ static void freezer_change_state(struct cgroup *cgroup,
>  		if (freezer->state != CGROUP_THAWED)
>  			atomic_dec(&system_freezing_cnt);
>  		freezer->state = CGROUP_THAWED;
> -		unfreeze_cgroup(cgroup, freezer);
> +		unfreeze_cgroup(freezer);
>  		break;
>  	case CGROUP_FROZEN:
>  		if (freezer->state == CGROUP_THAWED)
>  			atomic_inc(&system_freezing_cnt);
>  		freezer->state = CGROUP_FREEZING;
> -		freeze_cgroup(cgroup, freezer);
> +		freeze_cgroup(freezer);
>  		break;
>  	default:
>  		BUG();
> @@ -275,8 +273,7 @@ static void freezer_change_state(struct cgroup *cgroup,
>  	spin_unlock_irq(&freezer->lock);
>  }
>  
> -static int freezer_write(struct cgroup *cgroup,
> -			 struct cftype *cft,
> +static int freezer_write(struct cgroup *cgroup, struct cftype *cft,
>  			 const char *buffer)
>  {
>  	enum freezer_state goal_state;
> @@ -288,7 +285,7 @@ static int freezer_write(struct cgroup *cgroup,
>  	else
>  		return -EINVAL;
>  
> -	freezer_change_state(cgroup, goal_state);
> +	freezer_change_state(cgroup_freezer(cgroup), goal_state);
>  	return 0;
>  }
>  
> -- 
> 1.7.11.7
> 

-- 
Michal Hocko
SUSE Labs
