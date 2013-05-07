From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 33/33] blk-throttle: implement proper hierarchy support
Date: Tue, 7 May 2013 09:55:11 -0400
Message-ID: <20130507135511.GA7082@redhat.com>
References: <1367880372-28312-1-git-send-email-tj@kernel.org>
	<1367880372-28312-34-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1367880372-28312-34-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, May 06, 2013 at 03:46:12PM -0700, Tejun Heo wrote:
> With the recent updates, blk-throttle is finally ready for proper
> hierarchy support.  Dispatching now honors service_queue->parent_sq
> and propagates correctly.  The only thing missing is setting
> ->parent_sq correctly so that throtl_grp hierarchy matches the cgroup
> hierarchy.
> 
> This patch updates throtl_pd_init() such that service_queues form the
> same hierarchy as the cgroup hierarchy if sane_behavior is enabled.
> As this concludes proper hierarchy support for blkcg, the shameful
> .broken_hierarchy tag is removed from blkio_subsys.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>  block/blk-cgroup.c     |  8 --------
>  block/blk-throttle.c   | 22 +++++++++++++++++++++-
>  include/linux/cgroup.h |  2 ++
>  3 files changed, 23 insertions(+), 9 deletions(-)
> 
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index af2ca27..8d9edc8 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -911,14 +911,6 @@ struct cgroup_subsys blkio_subsys = {
>  	.subsys_id = blkio_subsys_id,
>  	.base_cftypes = blkcg_files,
>  	.module = THIS_MODULE,
> -
> -	/*
> -	 * blkio subsystem is utterly broken in terms of hierarchy support.
> -	 * It treats all cgroups equally regardless of where they're
> -	 * located in the hierarchy - all cgroups are treated as if they're
> -	 * right below the root.  Fix it and remove the following.
> -	 */
> -	.broken_hierarchy = true,

So if somebody does not specify __DEVEL_sane_behavior, hierarchy is
still broken. Should we continue to display the message in that case?

Vivek
