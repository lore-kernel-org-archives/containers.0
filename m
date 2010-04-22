From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 5/5] blk-cgroup: Fix an RCU warning in blkiocg_create()
Date: Thu, 22 Apr 2010 12:57:25 -0700
Message-ID: <20100422195725.GM2524@linux.vnet.ibm.com>
References: <4BD016F4.8060108@cn.fujitsu.com> <4BD017AC.1020209@cn.fujitsu.com>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BD017AC.1020209-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Gui Jianfeng <GuiJianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 22, 2010 at 05:32:28PM +0800, Li Zefan wrote:
> with CONFIG_PROVE_RCU=y, a warning can be triggered:
> 
>   # mount -t cgroup -o blkio xxx /mnt
>   # mkdir /mnt/subgroup
> 
> ...
> kernel/cgroup.c:4442 invoked rcu_dereference_check() without protection!
> ...
> 
> To fix this, we avoid caling css_depth() here, which is a bit simpler
> than the original code.

Queued for 2.6.34, thank you!

							Thanx, Paul

> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  block/blk-cgroup.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index 5fe03de..2cc682b 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -286,16 +286,16 @@ done:
>  static struct cgroup_subsys_state *
>  blkiocg_create(struct cgroup_subsys *subsys, struct cgroup *cgroup)
>  {
> -	struct blkio_cgroup *blkcg, *parent_blkcg;
> +	struct blkio_cgroup *blkcg;
> +	struct cgroup *parent = cgroup->parent;
> 
> -	if (!cgroup->parent) {
> +	if (!parent) {
>  		blkcg = &blkio_root_cgroup;
>  		goto done;
>  	}
> 
>  	/* Currently we do not support hierarchy deeper than two level (0,1) */
> -	parent_blkcg = cgroup_to_blkio_cgroup(cgroup->parent);
> -	if (css_depth(&parent_blkcg->css) > 0)
> +	if (parent != cgroup->top_cgroup)
>  		return ERR_PTR(-EINVAL);
> 
>  	blkcg = kzalloc(sizeof(*blkcg), GFP_KERNEL);
> -- 
> 1.6.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
