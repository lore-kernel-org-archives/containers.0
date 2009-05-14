From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] IO Controller: Add per-device weight and ioprio_class
	handling
Date: Thu, 14 May 2009 10:25:04 +0800
Message-ID: <4A0B8100.1090007__32090.7502239153$1242268110$gmane$org@cn.fujitsu.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<4A0A29B5.7030109@cn.fujitsu.com>
	<20090513155900.GA15623@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090513155900.GA15623-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
...
> Hi Gui,
> 
> It might make sense to also store the device name or device major and
> minor number in io_group while creating the io group. This will help us
> to display io.disk_time and io.disk_sector statistics per device instead
> of aggregate.
> 
> I am attaching a patch I was playing around with to display per device
> statistics instead of aggregate one. So if user has specified the per
> device rule.
> 
> Thanks
> Vivek
> 
> 
> o Currently the statistics exported through cgroup are aggregate of statistics
>   on all devices for that cgroup. Instead of aggregate, make these per device.
> 
> o Also export another statistics io.disk_dequeue. This keeps a count of how
>   many times a particular group got out of race for the disk. This is a
>   debugging aid to keep a track how often we could create continuously
>   backlogged queues.
> 
> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  block/elevator-fq.c |  127 +++++++++++++++++++++++++++++++++-------------------
>  block/elevator-fq.h |    3 +
>  2 files changed, 85 insertions(+), 45 deletions(-)
> 
> Index: linux14/block/elevator-fq.h
> ===================================================================
> --- linux14.orig/block/elevator-fq.h	2009-05-13 11:40:32.000000000 -0400
> +++ linux14/block/elevator-fq.h	2009-05-13 11:40:57.000000000 -0400
> @@ -250,6 +250,9 @@ struct io_group {
>  
>  #ifdef CONFIG_DEBUG_GROUP_IOSCHED
>  	unsigned short iocg_id;
> +	dev_t	dev;
> +	/* How many times this group has been removed from active tree */
> +	unsigned long dequeue;
>  #endif
>  };
>  
> Index: linux14/block/elevator-fq.c
> ===================================================================
> --- linux14.orig/block/elevator-fq.c	2009-05-13 11:40:53.000000000 -0400
> +++ linux14/block/elevator-fq.c	2009-05-13 11:40:57.000000000 -0400
> @@ -12,6 +12,7 @@
>  #include "elevator-fq.h"
>  #include <linux/blktrace_api.h>
>  #include <linux/biotrack.h>
> +#include <linux/seq_file.h>
>  
>  /* Values taken from cfq */
>  const int elv_slice_sync = HZ / 10;
> @@ -758,6 +759,18 @@ int __bfq_deactivate_entity(struct io_en
>  	BUG_ON(sd->active_entity == entity);
>  	BUG_ON(sd->next_active == entity);
>  
> +#ifdef CONFIG_DEBUG_GROUP_IOSCHED
> +	{
> +		struct io_group *iog = io_entity_to_iog(entity);
> +		/*
> +		 * Keep track of how many times a group has been removed
> +		 * from active tree because it did not have any active
> +		 * backlogged ioq under it
> +		 */
> +		if (iog)
> +			iog->dequeue++;
> +	}
> +#endif
>  	return ret;
>  }
>  
> @@ -1126,90 +1139,103 @@ STORE_FUNCTION(weight, 0, WEIGHT_MAX);
>  STORE_FUNCTION(ioprio_class, IOPRIO_CLASS_RT, IOPRIO_CLASS_IDLE);
>  #undef STORE_FUNCTION
>  
> -/*
> - * traverse through all the io_groups associated with this cgroup and calculate
> - * the aggr disk time received by all the groups on respective disks.
> - */
> -static u64 calculate_aggr_disk_time(struct io_cgroup *iocg)
> +static int io_cgroup_disk_time_read(struct cgroup *cgroup,
> +				struct cftype *cftype, struct seq_file *m)
>  {
> +	struct io_cgroup *iocg;
>  	struct io_group *iog;
>  	struct hlist_node *n;
> -	u64 disk_time = 0;
> +
> +	if (!cgroup_lock_live_group(cgroup))
> +		return -ENODEV;
> +
> +	iocg = cgroup_to_io_cgroup(cgroup);
>  
>  	rcu_read_lock();
> +	spin_lock_irq(&iocg->lock);
>  	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
>  		/*
>  		 * There might be groups which are not functional and
>  		 * waiting to be reclaimed upon cgoup deletion.
>  		 */
> -		if (rcu_dereference(iog->key))
> -			disk_time += iog->entity.total_service;
> +		if (rcu_dereference(iog->key)) {
> +			seq_printf(m, "%u %u %lu\n", MAJOR(iog->dev),
> +					MINOR(iog->dev),
> +					iog->entity.total_service);

  Hi Vivek,

  I think it's easier for users if device name is also shown here.

> +		}
>  	}
> +	spin_unlock_irq(&iocg->lock);
>  	rcu_read_unlock();
>  
> -	return disk_time;
> +	cgroup_unlock();
> +
> +	return 0;
>  }
>  

-- 
Regards
Gui Jianfeng
