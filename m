From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 3/8] cgroup: use cgroup_lock_live_group(parent) in
	cgroup_create()
Date: Wed, 31 Oct 2012 16:55:14 +0100
Message-ID: <20121031155514.GD22809@dhcp22.suse.cz>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
	<1351657365-25055-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351657365-25055-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On Tue 30-10-12 21:22:40, Tejun Heo wrote:
> This patch makes cgroup_create() fail if @parent is marked removed.
> This is to prepare for further updates to cgroup_rmdir() path.
> 
> Note that this change isn't strictly necessary.  cgroup can only be
> created via mkdir and the removed marking and dentry removal happen
> without releasing cgroup_mutex, so cgroup_create() can never race with
> cgroup_rmdir().  Even after the scheduled updates to cgroup_rmdir(),
> cgroup_mkdir() and cgroup_rmdir() are synchronized by i_mutex
> rendering the added liveliness check unnecessary.
> 
> Do it anyway such that locking is contained inside cgroup proper and
> we don't get nasty surprises if we ever grow another caller of
> cgroup_create().
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Looks good. Just a nit bellow
Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

> ---
>  kernel/cgroup.c | 16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index a49cdbc..b3010ae 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -3906,6 +3906,18 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
>  	if (!cgrp)
>  		return -ENOMEM;
>  
> +	/*
> +	 * Only live parents can have children.  Note that the liveliness
> +	 * check isn't strictly necessary because cgroup_mkdir() and
> +	 * cgroup_rmdir() are fully synchronized by i_mutex; however, do it
> +	 * anyway so that locking is contained inside cgroup proper and we
> +	 * don't get nasty surprises if we ever grow another caller.
> +	 */
> +	if (!cgroup_lock_live_group(parent)) {
> +		err = -ENODEV;
> +		goto err_free;
> +	}
> +

I think this should be moved up before we try to allocate any memory.
Or is your motivation to keep cgroup_lock held for shorter time?
I could agree with that but a small comment would be helpful.

-- 
Michal Hocko
SUSE Labs
