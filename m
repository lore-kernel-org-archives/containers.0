From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 4/8] cgroup: deactivate CSS's and mark cgroup dead before
	invoking ->pre_destroy()
Date: Wed, 31 Oct 2012 22:23:59 +0100
Message-ID: <20121031212359.GC5286@dhcp22.suse.cz>
References: <1351712650-23709-1-git-send-email-tj@kernel.org>
	<1351712650-23709-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351712650-23709-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On Wed 31-10-12 12:44:06, Tejun Heo wrote:
[...]
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index f22e3cd..66204a6 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
[...]
> @@ -4122,13 +4079,30 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
>  	}
>  	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
>  
> -	/* block new css_tryget() by deactivating refcnt */
> +	/*
> +	 * Block new css_tryget() by deactivating refcnt and mark @cgrp
> +	 * removed.  This makes future css_tryget() and child creation
> +	 * attempts fail thus maintaining the removal conditions verified
> +	 * above.
> +	 */
>  	for_each_subsys(cgrp->root, ss) {
>  		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
>  
>  		WARN_ON(atomic_read(&css->refcnt) < 0);
>  		atomic_add(CSS_DEACT_BIAS, &css->refcnt);
>  	}
> +	set_bit(CGRP_REMOVED, &cgrp->flags);
> +
> +	/*
> +	 * Tell subsystems to initate destruction.  pre_destroy() should be
> +	 * called with cgroup_mutex unlocked.  See 3fa59dfbc3 ("cgroup: fix
> +	 * potential deadlock in pre_destroy") for details.
> +	 */
> +	mutex_unlock(&cgroup_mutex);
> +	for_each_subsys(cgrp->root, ss)
> +		if (ss->pre_destroy)
> +			WARN_ON_ONCE(ss->pre_destroy(cgrp));

Do you think that BUG_ON would be too harsh?

-- 
Michal Hocko
SUSE Labs
