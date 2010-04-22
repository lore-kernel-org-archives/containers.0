From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 5/5] blk-cgroup: Fix an RCU warning in blkiocg_create()
Date: Thu, 22 Apr 2010 10:31:05 -0400
Message-ID: <20100422143105.GA3228@redhat.com>
References: <4BD016F4.8060108@cn.fujitsu.com> <4BD017AC.1020209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BD017AC.1020209@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Gui Jianfeng <GuiJianfeng@cn.fujitsu.com>
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

IIUC, so blkiocg_create() is being called with cgroup_mutex held and not
with rcu read lock held. Hence rcu_dereference() in css_depth() gives
warning.

So one easy solution is to don't use css_depth() at all. In this case
simple check like cgroup->top_cgroup should suffice. Makese sense to
me.

Acked-by: Vivek Goyal <vgoyal@redhat.com>

Thanks
Vivek

> To fix this, we avoid caling css_depth() here, which is a bit simpler
> than the original code.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
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
