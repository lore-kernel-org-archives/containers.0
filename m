From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 9/9 v2] cgroup_freezer: implement proper hierarchy support
Date: Thu, 8 Nov 2012 15:08:52 +0100
Message-ID: <20121108140852.GI31821@dhcp22.suse.cz>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-10-git-send-email-tj@kernel.org>
	<20121107163919.GC2660@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121107163919.GC2660-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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

On Wed 07-11-12 08:39:19, Tejun Heo wrote:
[...]
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
[...]
> @@ -320,14 +388,39 @@ static void freezer_apply_state(struct f
>   * @freezer: freezer of interest
>   * @freeze: whether to freeze or thaw
>   *
> - * Freeze or thaw @cgroup according to @freeze.
> + * Freeze or thaw @freezer according to @freeze.  The operations are
> + * recursive - all descendants of @freezer will be affected.
>   */
>  static void freezer_change_state(struct freezer *freezer, bool freeze)
>  {
> +	struct cgroup *pos;
> +
>  	/* update @freezer */
>  	spin_lock_irq(&freezer->lock);
>  	freezer_apply_state(freezer, freeze, CGROUP_FREEZING_SELF);
>  	spin_unlock_irq(&freezer->lock);
> +
> +	/*
> +	 * Update all its descendants in pre-order traversal.  Each
> +	 * descendant will try to inherit its parent's FREEZING state as
> +	 * CGROUP_FREEZING_PARENT.
> +	 */
> +	rcu_read_lock();
> +	cgroup_for_each_descendant_pre(pos, freezer->css.cgroup) {
> +		struct freezer *pos_f = cgroup_freezer(pos);
> +		struct freezer *parent = parent_freezer(pos_f);
> +
> +		/*
> +		 * Our update to @parent->state is already visible which is
> +		 * all we need.  No need to lock @parent.  For more info on
> +		 * synchronization, see freezer_post_create().
> +		 */
> +		spin_lock_irq(&pos_f->lock);
> +		freezer_apply_state(pos_f, parent->state & CGROUP_FREEZING,
> +				    CGROUP_FREEZING_PARENT);
> +		spin_unlock_irq(&pos_f->lock);
> +	}
> +	rcu_read_unlock();
>  }

This seems to be racy because parent->state access is not linearized.
Say we have parallel freeze and thawing on a tree like the following:
	A
	|
	B
        |
        C 

pre_order will visit them in B, C order.
	CPU1						CPU2
freezer_apply_state(A, true)
A->state & FREEZING == true		freezer_apply_state(A, false)
					A->state & FREEZING == false
					freezer_apply_state(B, false)
					B->state & FREEZING == false
freezer_apply_state(B, true)

B->state & FREEZING == true
freezer_apply_state(C, true)
					freezer_apply_state(C, false)

So A, C are thawed while B is frozen. Or am I missing something which
would prevent from this kind of race?

The easy fix is to move spin_unlock_irq(&freezer->lock); after
rcu_read_unlock.
-- 
Michal Hocko
SUSE Labs
