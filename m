From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 1/8] cgroup: kill
	cgroup_subsys->__DEPRECATED_clear_css_refs
Date: Wed, 31 Oct 2012 15:37:51 +0100
Message-ID: <20121031143751.GA22809__9336.76098143241$1351694294$gmane$org@dhcp22.suse.cz>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
	<1351657365-25055-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue 30-10-12 21:22:38, Tejun Heo wrote:
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
>   ->pre_destroy() failures.  This reduces cgroup_call_pre_destroy() to
>   a simple loop surrounding ->pre_destory().  Remove
>   cgroup_call_pre_destroy() and open-code the loop into
>   cgroup_rmdir().
> 
> * cgroup_clear_css_refs() can no longer fail.  All that needs to be
>   done are deactivating refcnts, setting CSS_REMOVED and putting the
>   base reference on each css.  Remove cgroup_clear_css_refs() and the
>   failure path, and open-code the loops into cgroup_rmdir().
> 
> Note that cgroup_rmdir() will see more cleanup soon.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Looks good to me and the diffstat is really encouraging
Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

with a minor note bellow
> ---
>  include/linux/cgroup.h |  12 ----
>  kernel/cgroup.c        | 159 ++++++++++++-------------------------------------
>  2 files changed, 38 insertions(+), 133 deletions(-)
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

Hmm, I am not sure I like this WARN_ON_ONCE. First it can happen for
more than one controller and second we can just clear CGRP_WAIT_ON_RMDIR
and return with EBUSY. The only possible failure at the moment is when a
new task or a child group appear.
I know it is not a big deal because it will disappear later in the
series but it would be more readable IMO.

Thanks!
-- 
Michal Hocko
SUSE Labs
