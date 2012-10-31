From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 2/8] cgroup: kill CSS_REMOVED
Date: Wed, 31 Oct 2012 16:39:26 +0100
Message-ID: <20121031153926.GC22809__45329.633417032$1351697989$gmane$org@dhcp22.suse.cz>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
	<1351657365-25055-3-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351657365-25055-3-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue 30-10-12 21:22:39, Tejun Heo wrote:
> CSS_REMOVED is one of the several contortions which were necessary to
> support css reference draining on cgroup removal.  All css->refcnts
> which need draining should be deactivated and verified to equal zero
> atomically w.r.t. css_tryget().  If any one isn't zero, all refcnts
> needed to be re-activated and css_tryget() shouldn't fail in the
> process.
> 
> This was achieved by letting css_tryget() busy-loop until either the
> refcnt is reactivated (failed removal attempt) or CSS_REMOVED is set
> (committing to removal).
> 
> Now that css refcnt draining is no longer used, there's no need for
> atomic rollback mechanism.  css_tryget() simply can look at the
> reference count and fail if the it's deactivated - it's never getting
> re-activated.
> 
> This patch removes CSS_REMOVED and updates __css_tryget() to fail if
> the refcnt is deactivated.
> 
> Note that this removes css_is_removed() whose only user is VM_BUG_ON()
> in memcontrol.c.  We can replace it with a check on the refcnt but
> given that the only use case is a debug assert, I think it's better to
> simply unexport it.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

Few questions/suggestions below but it looks good in general to me.
Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

> ---
>  include/linux/cgroup.h |  6 ------
>  kernel/cgroup.c        | 31 ++++++++++++-------------------
>  mm/memcontrol.c        |  7 +++----
>  3 files changed, 15 insertions(+), 29 deletions(-)
> 
[...]
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 033bf4b..a49cdbc 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -170,8 +170,8 @@ struct css_id {
>  	 * The css to which this ID points. This pointer is set to valid value
>  	 * after cgroup is populated. If cgroup is removed, this will be NULL.
>  	 * This pointer is expected to be RCU-safe because destroy()
> -	 * is called after synchronize_rcu(). But for safe use, css_is_removed()
> -	 * css_tryget() should be used for avoiding race.
> +	 * is called after synchronize_rcu(). But for safe use, css_tryget()
> +	 * should be used for avoiding race.
>  	 */
>  	struct cgroup_subsys_state __rcu *css;
>  	/*
> @@ -4088,8 +4088,6 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
>  	}
>  	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
>  
> -	local_irq_disable();
> -

OK, so the new charges shouldn't come from the IRQ context so we cannot
race with css_tryget but why did we need this in the first place?
A separate patch which removes this with an explanation would be nice.

>  	/* block new css_tryget() by deactivating refcnt */
>  	for_each_subsys(cgrp->root, ss) {
>  		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5a1d584..6f8bd9d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2343,7 +2343,6 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  again:
>  	if (*ptr) { /* css should be a valid one */
>  		memcg = *ptr;
> -		VM_BUG_ON(css_is_removed(&memcg->css));

All the callers seem to be fine but this was a safety net that something
didn't leak out. Can we keep it and test that the reference counter has
been disabled already (css_refcnt(&memcg->css) < 0 - I do not care
whether open coded or wrapped innsude css_is_removed albeit helper
sounds nicer)?

>  		if (mem_cgroup_is_root(memcg))
>  			goto done;
>  		if (nr_pages == 1 && consume_stock(memcg))
> @@ -2483,9 +2482,9 @@ static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
>  
>  /*
>   * A helper function to get mem_cgroup from ID. must be called under
> - * rcu_read_lock(). The caller must check css_is_removed() or some if
> - * it's concern. (dropping refcnt from swap can be called against removed
> - * memcg.)
> + * rcu_read_lock(). The caller is responsible for verifying the returned
> + * memcg is still alive if necessary. (dropping refcnt from swap can be
> + * called against removed memcg.)

I think that something like the following would be more instructive:

+ * rcu_read_lock(). The caller is responsible for calling css_tryget
+ * if the mem_cgroup is used for charging. (dropping refcnt from swap can be
+ * called against removed memcg.)

Thanks!
-- 
Michal Hocko
SUSE Labs
