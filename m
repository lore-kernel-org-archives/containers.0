From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 1/8] cgroup: kill
	cgroup_subsys->__DEPRECATED_clear_css_refs
Date: Wed, 31 Oct 2012 17:21:29 +0400
Message-ID: <509125D9.8070100__9794.77024307034$1351689724$gmane$org@parallels.com>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
	<1351657365-25055-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351657365-25055-2-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


>  	}
>  	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
> -	if (!cgroup_clear_css_refs(cgrp)) {
> -		mutex_unlock(&cgroup_mutex);
> -		/*
> -		 * Because someone may call cgroup_wakeup_rmdir_waiter() before
> -		 * prepare_to_wait(), we need to check this flag.
> -		 */
> -		if (test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags))
> -			schedule();
> -		finish_wait(&cgroup_rmdir_waitq, &wait);
> -		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
> -		if (signal_pending(current))
> -			return -EINTR;
> -		goto again;
> +
> +	local_irq_disable();
> +
> +	/* block new css_tryget() by deactivating refcnt */
> +	for_each_subsys(cgrp->root, ss) {
> +		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
> +
> +		WARN_ON(atomic_read(&css->refcnt) < 0);
> +		atomic_add(CSS_DEACT_BIAS, &css->refcnt);
>  	}
> -	/* NO css_tryget() can success after here. */
> +
> +	/*
> +	 * Set REMOVED.  All in-progress css_tryget() will be released.
> +	 * Put all the base refs.  Each css holds an extra reference to the
> +	 * cgroup's dentry and cgroup removal proceeds regardless of css
> +	 * refs.  On the last put of each css, whenever that may be, the
> +	 * extra dentry ref is put so that dentry destruction happens only
> +	 * after all css's are released.
> +	 */
> +	for_each_subsys(cgrp->root, ss) {
> +		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
> +
> +		set_bit(CSS_REMOVED, &css->flags);
> +		css_put(css);
> +	}
> +
> +	local_irq_enable();
> +
>  	finish_wait(&cgroup_rmdir_waitq, &wait);

It seems to me that the main reason for doing this in two passes was to
derive a global "failed" state on the first pass. Now that we can't
fail, why can't you just loop through the subsystems just once ?
