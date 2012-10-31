From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 1/8] cgroup: kill
	cgroup_subsys->__DEPRECATED_clear_css_refs
Date: Wed, 31 Oct 2012 20:02:37 +0100
Message-ID: <20121031190237.GA1271@dhcp22.suse.cz>
References: <1351707391-22287-1-git-send-email-tj@kernel.org>
	<1351707391-22287-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351707391-22287-2-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On Wed 31-10-12 11:16:24, Tejun Heo wrote:
> 2ef37d3fe4 ("memcg: Simplify mem_cgroup_force_empty_list error
> handling") removed the last user of __DEPRECATED_clear_css_refs.  This
> patch removes __DEPRECATED_clear_css_refs and mechanisms to support
> it.
> 
> * Conditionals dependent on __DEPRECATED_clear_css_refs removed.
> 
> * ->pre_destroy() now can only fail if a new task is attached or child
>   cgroup is created while ->pre_destroy()s are being called.  As the
>   condition is checked again after re-acquiring cgroup_mutex
>   afterwards, we don't need to take any immediate action on
>   ->pre_destroy() failures.  

Well, this is racy because the task can exit until we reach the
re-check. As the result there might still be some pages on the memcg
LRUs left.
As I said in the previous version, I do not see any reason why we
shouldn't just return EBUSY here. I would even skip WARN_ON_ONCE because
it doesn't give us any valueable information. One can trigger that
easily as well.

[...]
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 7981850..033bf4b 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
[...]
> @@ -4168,11 +4075,9 @@ again:
>  	 * Call pre_destroy handlers of subsys. Notify subsystems
>  	 * that rmdir() request comes.
>  	 */
> -	ret = cgroup_call_pre_destroy(cgrp);
> -	if (ret) {
> -		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
> -		return ret;
> -	}
> +	for_each_subsys(cgrp->root, ss)
> +		if (ss->pre_destroy)
> +			WARN_ON_ONCE(ss->pre_destroy(cgrp));
	for_each_subsys(cgrp->root, ss)
		if (ss->pre_destroy) {
			int ret = ss->pre_destroy(cgrp);
			clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
			return ret;
		}
>  
>  	mutex_lock(&cgroup_mutex);
>  	parent = cgrp->parent;
[...]
-- 
Michal Hocko
SUSE Labs
