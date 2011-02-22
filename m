From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/5] page_cgroup: make page tracking available for blkio
Date: Tue, 22 Feb 2011 16:22:53 -0500
Message-ID: <20110222212253.GJ28269__1489.48937790028$1298410039$gmane$org@redhat.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
	<1298394776-9957-4-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1298394776-9957-4-git-send-email-arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 22, 2011 at 06:12:54PM +0100, Andrea Righi wrote:
> The page_cgroup infrastructure, currently available only for the memory
> cgroup controller, can be used to store the owner of each page and
> opportunely track the writeback IO. This information is encoded in
> the upper 16-bits of the page_cgroup->flags.
> 
> A owner can be identified using a generic ID number and the following
> interfaces are provided to store a retrieve this information:
> 
>   unsigned long page_cgroup_get_owner(struct page *page);
>   int page_cgroup_set_owner(struct page *page, unsigned long id);
>   int page_cgroup_copy_owner(struct page *npage, struct page *opage);
> 
> The blkio.throttle controller can use the cgroup css_id() as the owner's
> ID number.
> 
> Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
> ---
>  block/Kconfig               |    2 +
>  block/blk-cgroup.c          |    6 ++
>  include/linux/memcontrol.h  |    6 ++
>  include/linux/mmzone.h      |    4 +-
>  include/linux/page_cgroup.h |   33 ++++++++++-
>  init/Kconfig                |    4 +
>  mm/Makefile                 |    3 +-
>  mm/memcontrol.c             |    6 ++
>  mm/page_cgroup.c            |  129 +++++++++++++++++++++++++++++++++++++++----
>  9 files changed, 176 insertions(+), 17 deletions(-)
> 
> diff --git a/block/Kconfig b/block/Kconfig
> index 60be1e0..1351ea8 100644
> --- a/block/Kconfig
> +++ b/block/Kconfig
> @@ -80,6 +80,8 @@ config BLK_DEV_INTEGRITY
>  config BLK_DEV_THROTTLING
>  	bool "Block layer bio throttling support"
>  	depends on BLK_CGROUP=y && EXPERIMENTAL
> +	select MM_OWNER
> +	select PAGE_TRACKING
>  	default n
>  	---help---
>  	Block layer bio throttling support. It can be used to limit
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index f283ae1..5c57f0a 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -107,6 +107,12 @@ blkio_policy_search_node(const struct blkio_cgroup *blkcg, dev_t dev,
>  	return NULL;
>  }
>  
> +bool blkio_cgroup_disabled(void)
> +{
> +	return blkio_subsys.disabled ? true : false;
> +}
> +EXPORT_SYMBOL_GPL(blkio_cgroup_disabled);
> +

I think there should be option to just disable this asyn feature of
blkio controller. So those who don't want it (running VMs with cache=none
option) and don't want to take the memory reservation hit should be
able to disable just ASYNC facility of blkio controller and not
the whole blkio controller facility.

Thanks
Vivek
