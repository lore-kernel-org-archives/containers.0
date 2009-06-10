From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 08/18] io-controller: idle for sometime on sync queue
	before expiring it
Date: Wed, 10 Jun 2009 09:30:38 +0800
Message-ID: <4A2F0CBE.8030208__30143.3779568926$1244597575$gmane$org@cn.fujitsu.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<1241553525-28095-9-git-send-email-vgoyal@redhat.com>
	<4A2E15B6.8030001@cn.fujitsu.com>
	<20090609175131.GB13476@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090609175131.GB13476-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
> On Tue, Jun 09, 2009 at 03:56:38PM +0800, Gui Jianfeng wrote:
>> Vivek Goyal wrote:
>> ...
>>> +ssize_t elv_fairness_store(struct request_queue *q, const char *name,
>>> +			  size_t count)
>>> +{
>>> +	struct elv_fq_data *efqd;
>>> +	unsigned int data;
>>> +	unsigned long flags;
>>> +
>>> +	char *p = (char *)name;
>>> +
>>> +	data = simple_strtoul(p, &p, 10);
>>> +
>>> +	if (data < 0)
>>> +		data = 0;
>>> +	else if (data > INT_MAX)
>>> +		data = INT_MAX;
>>   Hi Vivek,
>>
>>   data might overflow on 64 bit systems. In addition, since "fairness" is nothing 
>>   more than a switch, just let it be.
>>
>> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> ---
> 
> Hi Gui,
> 
> How about following patch? Currently this should apply at the end of the
> patch series. If it looks good, I will merge the changes in higher level
> patches.

  This patch seems good to me. Some trivial issues comment below.

> 
> Thanks
> Vivek
> 
> o Previously common layer elevator parameters were appearing as request
>   queue parameters in sysfs. But actually these are io scheduler parameters
>   in hiearchical mode. Fix it.
> 
> o Use macros to define multiple sysfs C functions doing the same thing. Code
>   borrowed from CFQ. Helps reduce the number of lines of by 140.
> 
> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
...	\
> +}
> +SHOW_FUNCTION(elv_fairness_show, efqd->fairness, 0);
> +EXPORT_SYMBOL(elv_fairness_show);
> +SHOW_FUNCTION(elv_slice_idle_show, efqd->elv_slice_idle, 1);
> +EXPORT_SYMBOL(elv_slice_idle_show);
> +SHOW_FUNCTION(elv_async_slice_idle_show, efqd->elv_async_slice_idle, 1);
> +EXPORT_SYMBOL(elv_async_slice_idle_show);
> +SHOW_FUNCTION(elv_slice_sync_show, efqd->elv_slice[1], 1);
> +EXPORT_SYMBOL(elv_slice_sync_show);
> +SHOW_FUNCTION(elv_slice_async_show, efqd->elv_slice[0], 1);
> +EXPORT_SYMBOL(elv_slice_async_show);
> +#undef SHOW_FUNCTION
> +
> +#define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
> +ssize_t __FUNC(struct elevator_queue *e, const char *page, size_t count)	\
> +{									\
> +	struct elv_fq_data *efqd = &e->efqd;				\
> +	unsigned int __data;						\
> +	int ret = elv_var_store(&__data, (page), count);		\

  Since simple_strtoul returns unsigned long, it's better to make __data 
  be that type.

> +	if (__data < (MIN))						\
> +		__data = (MIN);						\
> +	else if (__data > (MAX))					\
> +		__data = (MAX);						\
> +	if (__CONV)							\
> +		*(__PTR) = msecs_to_jiffies(__data);			\
> +	else								\
> +		*(__PTR) = __data;					\
> +	return ret;							\
> +}
> +STORE_FUNCTION(elv_fairness_store, &efqd->fairness, 0, 1, 0);
> +EXPORT_SYMBOL(elv_fairness_store);
> +STORE_FUNCTION(elv_slice_idle_store, &efqd->elv_slice_idle, 0, UINT_MAX, 1);

  Do we need to set an actual max limitation rather than UINT_MAX for these entries?

> +EXPORT_SYMBOL(elv_slice_idle_store);
> +STORE_FUNCTION(elv_async_slice_idle_store, &efqd->elv_async_slice_idle, 0, UINT_MAX, 1);
> +EXPORT_SYMBOL(elv_async_slice_idle_store);
> +STORE_FUNCTION(elv_slice_sync_store, &efqd->elv_slice[1], 1, UINT_MAX, 1);
> +EXPORT_SYMBOL(elv_slice_sync_store);
> +STORE_FUNCTION(elv_slice_async_store, &efqd->elv_slice[0], 1, UINT_MAX, 1);
> +EXPORT_SYMBOL(elv_slice_async_store);
> +#undef STORE_FUNCTION
>  
>  void elv_schedule_dispatch(struct request_queue *q)
>  {
> Index: linux18/block/blk-sysfs.c
> ===================================================================
> --- linux18.orig/block/blk-sysfs.c	2009-06-09 10:34:59.000000000 -0400
> +++ linux18/block/blk-sysfs.c	2009-06-09 13:24:42.000000000 -0400
> @@ -307,38 +307,6 @@ static struct queue_sysfs_entry queue_io
>  	.store = queue_iostats_store,
>  };
>  
> -#ifdef CONFIG_ELV_FAIR_QUEUING
> -static struct queue_sysfs_entry queue_slice_idle_entry = {
> -	.attr = {.name = "slice_idle", .mode = S_IRUGO | S_IWUSR },
> -	.show = elv_slice_idle_show,
> -	.store = elv_slice_idle_store,
> -};
> -
> -static struct queue_sysfs_entry queue_async_slice_idle_entry = {
> -	.attr = {.name = "async_slice_idle", .mode = S_IRUGO | S_IWUSR },
> -	.show = elv_async_slice_idle_show,
> -	.store = elv_async_slice_idle_store,
> -};
> -
> -static struct queue_sysfs_entry queue_slice_sync_entry = {
> -	.attr = {.name = "slice_sync", .mode = S_IRUGO | S_IWUSR },
> -	.show = elv_slice_sync_show,
> -	.store = elv_slice_sync_store,
> -};
> -
> -static struct queue_sysfs_entry queue_slice_async_entry = {
> -	.attr = {.name = "slice_async", .mode = S_IRUGO | S_IWUSR },
> -	.show = elv_slice_async_show,
> -	.store = elv_slice_async_store,
> -};
> -
> -static struct queue_sysfs_entry queue_fairness_entry = {
> -	.attr = {.name = "fairness", .mode = S_IRUGO | S_IWUSR },
> -	.show = elv_fairness_show,
> -	.store = elv_fairness_store,
> -};
> -#endif
> -
>  static struct attribute *default_attrs[] = {
>  	&queue_requests_entry.attr,
>  #ifdef CONFIG_GROUP_IOSCHED
> @@ -353,13 +321,6 @@ static struct attribute *default_attrs[]
>  	&queue_nomerges_entry.attr,
>  	&queue_rq_affinity_entry.attr,
>  	&queue_iostats_entry.attr,
> -#ifdef CONFIG_ELV_FAIR_QUEUING
> -	&queue_slice_idle_entry.attr,
> -	&queue_async_slice_idle_entry.attr,
> -	&queue_slice_sync_entry.attr,
> -	&queue_slice_async_entry.attr,
> -	&queue_fairness_entry.attr,
> -#endif
>  	NULL,
>  };
>  
> Index: linux18/block/cfq-iosched.c
> ===================================================================
> --- linux18.orig/block/cfq-iosched.c	2009-06-09 10:34:55.000000000 -0400
> +++ linux18/block/cfq-iosched.c	2009-06-09 13:25:42.000000000 -0400
> @@ -2095,6 +2095,11 @@ static struct elv_fs_entry cfq_attrs[] =
>  	CFQ_ATTR(back_seek_max),
>  	CFQ_ATTR(back_seek_penalty),
>  	CFQ_ATTR(slice_async_rq),
> +	ELV_ATTR(fairness),
> +	ELV_ATTR(slice_idle),
> +	ELV_ATTR(async_slice_idle),
> +	ELV_ATTR(slice_sync),
> +	ELV_ATTR(slice_async),
>  	__ATTR_NULL
>  };
>  
> Index: linux18/block/as-iosched.c
> ===================================================================
> --- linux18.orig/block/as-iosched.c	2009-06-09 10:34:58.000000000 -0400
> +++ linux18/block/as-iosched.c	2009-06-09 13:27:38.000000000 -0400
> @@ -1766,6 +1766,11 @@ static struct elv_fs_entry as_attrs[] = 
>  	AS_ATTR(antic_expire),
>  	AS_ATTR(read_batch_expire),
>  	AS_ATTR(write_batch_expire),
> +#ifdef CONFIG_IOSCHED_AS_HIER
> +	ELV_ATTR(fairness),
> +	ELV_ATTR(slice_idle),
> +	ELV_ATTR(slice_sync),
> +#endif
>  	__ATTR_NULL
>  };
>  
> Index: linux18/block/deadline-iosched.c
> ===================================================================
> --- linux18.orig/block/deadline-iosched.c	2009-06-09 10:34:55.000000000 -0400
> +++ linux18/block/deadline-iosched.c	2009-06-09 13:28:51.000000000 -0400
> @@ -460,6 +460,11 @@ static struct elv_fs_entry deadline_attr
>  	DD_ATTR(writes_starved),
>  	DD_ATTR(front_merges),
>  	DD_ATTR(fifo_batch),
> +#ifdef CONFIG_IOSCHED_DEADLINE_HIER
> +	ELV_ATTR(fairness),
> +	ELV_ATTR(slice_idle),
> +	ELV_ATTR(slice_sync),
> +#endif
>  	__ATTR_NULL
>  };
>  
> Index: linux18/block/noop-iosched.c
> ===================================================================
> --- linux18.orig/block/noop-iosched.c	2009-06-09 10:34:52.000000000 -0400
> +++ linux18/block/noop-iosched.c	2009-06-09 13:31:48.000000000 -0400
> @@ -82,6 +82,15 @@ static void noop_free_noop_queue(struct 
>  	kfree(nq);
>  }
>  
> +#ifdef CONFIG_IOSCHED_NOOP_HIER
> +static struct elv_fs_entry noop_attrs[] = {
> +	ELV_ATTR(fairness),
> +	ELV_ATTR(slice_idle),
> +	ELV_ATTR(slice_sync),
> +	__ATTR_NULL
> +};
> +#endif
> +
>  static struct elevator_type elevator_noop = {
>  	.ops = {
>  		.elevator_merge_req_fn		= noop_merged_requests,
> @@ -94,6 +103,7 @@ static struct elevator_type elevator_noo
>  	},
>  #ifdef CONFIG_IOSCHED_NOOP_HIER
>  	.elevator_features = ELV_IOSCHED_NEED_FQ | ELV_IOSCHED_SINGLE_IOQ,
> +	.elevator_attrs = noop_attrs,
>  #endif
>  	.elevator_name = "noop",
>  	.elevator_owner = THIS_MODULE,
> 
> 
> 

-- 
Regards
Gui Jianfeng
