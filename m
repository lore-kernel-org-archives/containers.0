From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/6] cgroup: remove cgroup->actual_subsys_mask
Date: Mon, 24 Jun 2013 18:26:03 +0800
Message-ID: <51C81EBB.5030403@huawei.com>
References: <1371864854-28364-1-git-send-email-tj@kernel.org>
	<1371864854-28364-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371864854-28364-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/6/22 9:34, Tejun Heo wrote:
> cgroup curiously has two subsystem masks, ->subsys_mask and
> ->actual_subsys_mask.  The latter only exists because the new target
> subsys_mask is passed into rebind_subsystems() via @cgrp->subsys_mask.

s/cgrp->/root->/

> rebind_subsystems() needs to know what the current mask is to decide
> how to reach the target mask so ->actual_subsys_mask is used as the
> temp location to remember the current state.
> 
> Adding a temporary field to a permanent data structure is rather silly
> and can be misleading.  Update rebind_subsystems() to take @added_mask
> and @removed_mask instead and remove @cgrp->actual_subsys_mask.
> 

ditto

> This patch shouldn't introduce any behavior changes.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>  include/linux/cgroup.h |  3 ---
>  kernel/cgroup.c        | 22 ++++++++++++----------
>  2 files changed, 12 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 46a59d0..7d8c4ec 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -295,9 +295,6 @@ struct cgroupfs_root {
>  	/* Unique id for this hierarchy. */
>  	int hierarchy_id;
>  
> -	/* The bitmask of subsystems currently attached to this hierarchy */
> -	unsigned long actual_subsys_mask;
> -

I think it's better to change this comment:

        /*
         * The bitmask of subsystems intended to be attached to this
         * hierarchy
         */
        unsigned long subsys_mask;

to

	/* The bitmask of subsystems attached to this hierarchy */

>  	/* A list running through the attached subsystems */
>  	struct list_head subsys_list;
>  

Other than those comments:

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
