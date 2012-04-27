From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/11] blkcg: fix blkg_alloc() failure path
Date: Fri, 27 Apr 2012 10:26:52 -0400
Message-ID: <20120427142652.GH10579__19339.7263916724$1335536835$gmane$org@redhat.com>
References: <1335477561-11131-1-git-send-email-tj@kernel.org>
	<1335477561-11131-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1335477561-11131-2-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Apr 26, 2012 at 02:59:11PM -0700, Tejun Heo wrote:
> When policy data allocation fails in the middle, blkg_alloc() invokes
> blkg_free() to destroy the half constructed blkg.  This ends up
> calling pd_exit_fn() on policy datas which didn't go through
> pd_init_fn().  Fix it by making blkg_alloc() call pd_init_fn()
> immediately after each policy data allocation.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  block/blk-cgroup.c |    6 +-----
>  1 files changed, 1 insertions(+), 5 deletions(-)
> 
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index 02cf633..4ab7420 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -125,12 +125,8 @@ static struct blkcg_gq *blkg_alloc(struct blkcg *blkcg, struct request_queue *q)
>  
>  		blkg->pd[i] = pd;
>  		pd->blkg = blkg;
> -	}
> -
> -	/* invoke per-policy init */
> -	for (i = 0; i < BLKCG_MAX_POLS; i++) {
> -		struct blkcg_policy *pol = blkcg_policy[i];
>  
> +		/* invoke per-policy init */
>  		if (blkcg_policy_enabled(blkg->q, pol))
>  			pol->pd_init_fn(blkg);

Deja Vu. In one of the mails I had said that how about moving init_fn
in upper loop and get rid of for loop below. Then retracted it saying
probably you wanted to allocate all the groups first before calling 
init functions of individual policies. Here we are back again for a
different reason though. :-)

Acked-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Vivek
>  	}
> -- 
> 1.7.7.3
