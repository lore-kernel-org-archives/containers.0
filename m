From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IO Controller: Add per-device weight and ioprio_class
	handling
Date: Wed, 13 May 2009 13:17:34 -0400
Message-ID: <20090513171734.GA18371__30919.2044930116$1242235405$gmane$org@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<4A0A29B5.7030109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A0A29B5.7030109-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, May 13, 2009 at 10:00:21AM +0800, Gui Jianfeng wrote:
> Hi Vivek,
> 
> This patch enables per-cgroup per-device weight and ioprio_class handling.
> A new cgroup interface "policy" is introduced. You can make use of this 
> file to configure weight and ioprio_class for each device in a given cgroup.
> The original "weight" and "ioprio_class" files are still available. If you
> don't do special configuration for a particular device, "weight" and 
> "ioprio_class" are used as default values in this device.
> 
> You can use the following format to play with the new interface.
> #echo DEV:weight:ioprio_class > /patch/to/cgroup/policy
> weight=0 means removing the policy for DEV.
> 
> Examples:
> Configure weight=300 ioprio_class=2 on /dev/hdb in this cgroup
> # echo /dev/hdb:300:2 > io.policy
> # cat io.policy
> dev weight class
> /dev/hdb 300 2
> 
> Configure weight=500 ioprio_class=1 on /dev/hda in this cgroup
> # echo /dev/hda:500:1 > io.policy
> # cat io.policy
> dev weight class
> /dev/hda 500 1
> /dev/hdb 300 2
> 
> Remove the policy for /dev/hda in this cgroup
> # echo /dev/hda:0:1 > io.policy
> # cat io.policy
> dev weight class
> /dev/hdb 300 2
> 
> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  block/elevator-fq.c |  239 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  block/elevator-fq.h |   11 +++
>  2 files changed, 245 insertions(+), 5 deletions(-)
> 
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index 69435ab..7c95d55 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -12,6 +12,9 @@
>  #include "elevator-fq.h"
>  #include <linux/blktrace_api.h>
>  #include <linux/biotrack.h>
> +#include <linux/seq_file.h>
> +#include <linux/genhd.h>
> +
>  
>  /* Values taken from cfq */
>  const int elv_slice_sync = HZ / 10;
> @@ -1045,12 +1048,30 @@ struct io_group *io_lookup_io_group_current(struct request_queue *q)
>  }
>  EXPORT_SYMBOL(io_lookup_io_group_current);
>  
> -void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
> +static struct policy_node *policy_search_node(const struct io_cgroup *iocg,
> +					      void *key);
> +
> +void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog,
> +			  void *key)
>  {
>  	struct io_entity *entity = &iog->entity;
> +	struct policy_node *pn;
> +
> +	spin_lock_irq(&iocg->lock);
> +	pn = policy_search_node(iocg, key);
> +	if (pn) {
> +		entity->weight = pn->weight;
> +		entity->new_weight = pn->weight;
> +		entity->ioprio_class = pn->ioprio_class;
> +		entity->new_ioprio_class = pn->ioprio_class;
> +	} else {
> +		entity->weight = iocg->weight;
> +		entity->new_weight = iocg->weight;
> +		entity->ioprio_class = iocg->ioprio_class;
> +		entity->new_ioprio_class = iocg->ioprio_class;
> +	}
> +	spin_unlock_irq(&iocg->lock);
>  

I think we need to use spin_lock_irqsave() and spin_lock_irqrestore()
version above because it can be called with request queue lock held and we
don't want to enable the interrupts unconditionally here.

I hit following lock validator warning.

 
[   81.521242] =================================
[   81.522127] [ INFO: inconsistent lock state ]
[   81.522127] 2.6.30-rc4-ioc #47
[   81.522127] ---------------------------------
[   81.522127] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[   81.522127] io-group-bw-tes/4138 [HC0[0]:SC0[0]:HE1:SE1] takes:
[   81.522127]  (&q->__queue_lock){+.?...}, at: [<ffffffff811d7b2e>] __make_request+0x35/0x396
[   81.522127] {IN-SOFTIRQ-W} state was registered at:
[   81.522127]   [<ffffffffffffffff>] 0xffffffffffffffff
[   81.522127] irq event stamp: 1006
[   81.522127] hardirqs last  enabled at (1005): [<ffffffff810c1198>] kmem_cache_alloc+0x9d/0x105
[   81.522127] hardirqs last disabled at (1006): [<ffffffff8150343f>] _spin_lock_irq+0x12/0x3e
[   81.522127] softirqs last  enabled at (286): [<ffffffff81042039>] __do_softirq+0x17a/0x187
[   81.522127] softirqs last disabled at (271): [<ffffffff8100ccfc>] call_softirq+0x1c/0x34
[   81.522127] 
[   81.522127] other info that might help us debug this:
[   81.522127] 3 locks held by io-group-bw-tes/4138:
[   81.522127]  #0:  (&type->i_mutex_dir_key#4){+.+.+.}, at: [<ffffffff810cfd2c>] do_lookup+0x82/0x15f
[   81.522127]  #1:  (&q->__queue_lock){+.?...}, at: [<ffffffff811d7b2e>] __make_request+0x35/0x396
[   81.522127]  #2:  (rcu_read_lock){.+.+..}, at: [<ffffffff811e55bb>] __rcu_read_lock+0x0/0x30
[   81.522127] 
[   81.522127] stack backtrace:
[   81.522127] Pid: 4138, comm: io-group-bw-tes Not tainted 2.6.30-rc4-ioc #47
[   81.522127] Call Trace:
[   81.522127]  [<ffffffff8105edad>] valid_state+0x17c/0x18f
[   81.522127]  [<ffffffff8105eb8a>] ? check_usage_backwards+0x0/0x52
[   81.522127]  [<ffffffff8105ee9b>] mark_lock+0xdb/0x1ff
[   81.522127]  [<ffffffff8105f00c>] mark_held_locks+0x4d/0x6b
[   81.522127]  [<ffffffff8150331a>] ? _spin_unlock_irq+0x2b/0x31
[   81.522127]  [<ffffffff8105f13e>] trace_hardirqs_on_caller+0x114/0x138
[   81.522127]  [<ffffffff8105f16f>] trace_hardirqs_on+0xd/0xf
[   81.522127]  [<ffffffff8150331a>] _spin_unlock_irq+0x2b/0x31
[   81.522127]  [<ffffffff811e5534>] ? io_group_init_entity+0x2a/0xb1
[   81.522127]  [<ffffffff811e5597>] io_group_init_entity+0x8d/0xb1
[   81.522127]  [<ffffffff811e688e>] ? io_group_chain_alloc+0x49/0x167
[   81.522127]  [<ffffffff811e68fe>] io_group_chain_alloc+0xb9/0x167
[   81.522127]  [<ffffffff811e6a04>] io_find_alloc_group+0x58/0x85
[   81.522127]  [<ffffffff811e6aec>] io_get_io_group+0x6e/0x94
[   81.522127]  [<ffffffff811e6d8c>] io_group_get_request_list+0x10/0x21
[   81.522127]  [<ffffffff811d7021>] blk_get_request_list+0x9/0xb
[   81.522127]  [<ffffffff811d7ab0>] get_request_wait+0x132/0x17b
[   81.522127]  [<ffffffff811d7dc1>] __make_request+0x2c8/0x396
[   81.522127]  [<ffffffff811d6806>] generic_make_request+0x1f2/0x28c
[   81.522127]  [<ffffffff810e9ee7>] ? bio_init+0x18/0x32
[   81.522127]  [<ffffffff811d8019>] submit_bio+0xb1/0xbc
[   81.522127]  [<ffffffff810e61c1>] submit_bh+0xfb/0x11e
[   81.522127]  [<ffffffff8111f554>] __ext3_get_inode_loc+0x263/0x2c2
[   81.522127]  [<ffffffff81122286>] ext3_iget+0x69/0x399
[   81.522127]  [<ffffffff81125b92>] ext3_lookup+0x81/0xd0
[   81.522127]  [<ffffffff810cfd81>] do_lookup+0xd7/0x15f
[   81.522127]  [<ffffffff810d15c2>] __link_path_walk+0x319/0x67f
[   81.522127]  [<ffffffff810d1976>] path_walk+0x4e/0x97
[   81.522127]  [<ffffffff810d1b48>] do_path_lookup+0x115/0x15a
[   81.522127]  [<ffffffff810d0fec>] ? getname+0x19d/0x1bf
[   81.522127]  [<ffffffff810d252a>] user_path_at+0x52/0x8c
[   81.522127]  [<ffffffff811ee668>] ? __up_read+0x1c/0x8c
[   81.522127]  [<ffffffff8150379b>] ? _spin_unlock_irqrestore+0x3f/0x47
[   81.522127]  [<ffffffff8105f13e>] ? trace_hardirqs_on_caller+0x114/0x138
[   81.522127]  [<ffffffff810cb6c1>] vfs_fstatat+0x35/0x62
[   81.522127]  [<ffffffff811ee6d0>] ? __up_read+0x84/0x8c
[   81.522127]  [<ffffffff810cb7bb>] vfs_stat+0x16/0x18
[   81.522127]  [<ffffffff810cb7d7>] sys_newstat+0x1a/0x34
[   81.522127]  [<ffffffff8100c5e9>] ? retint_swapgs+0xe/0x13
[   81.522127]  [<ffffffff8105f13e>] ? trace_hardirqs_on_caller+0x114/0x138
[   81.522127]  [<ffffffff8107f771>] ? audit_syscall_entry+0xfe/0x12a
[   81.522127]  [<ffffffff8100bb2b>] system_call_fastpath+0x16/0x1b

Thanks
Vivek
