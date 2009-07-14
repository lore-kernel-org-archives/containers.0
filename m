From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] io-controller: implement per group request allocation
	limitation
Date: Tue, 14 Jul 2009 15:45:03 +0800
Message-ID: <4A5C377F.4040105__34716.6397645653$1247557676$gmane$org@cn.fujitsu.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<4A569FC5.7090801@cn.fujitsu.com>
	<20090713160352.GA3714@redhat.com> <4A5BA238.3030902@ds.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A5BA238.3030902-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Munehiro Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Munehiro Ikeda wrote:
> Vivek Goyal wrote, on 07/13/2009 12:03 PM:
>> On Fri, Jul 10, 2009 at 09:56:21AM +0800, Gui Jianfeng wrote:
>>> Hi Vivek,
>>>
>>> This patch exports a cgroup based per group request limits interface.
>>> and removes the global one. Now we can use this interface to perform
>>> different request allocation limitation for different groups.
>>>
>>
>> Thanks Gui. Few points come to mind.
>>
>> - You seem to be making this as per cgroup limit on all devices. I guess
>>    that different devices in the system can have different settings of
>>    q->nr_requests and hence will probably want different per group limit.
>>    So we might have to make it per cgroup per device limit.
> 
> From the viewpoint of implementation, there is a difficulty in my mind to
> implement per cgroup per device limit arising from that io_group is
> allocated
> when associated device is firstly used.  I guess Gui chose per cgroup limit
> on all devices approach because of this, right?

  Yes, I choose this solution from the simplicity point of view, the code will
  get complicated if choosing per cgroup per device limit. But it seems per 
  cgroup per device limits is more reasonable.

> 
> 
>> - There does not seem to be any checks for making sure that children
>>    cgroups don't have more request descriptors allocated than parent
>> group.
>>
>> - I am re-thinking that what's the advantage of configuring request
>>    descriptors also through cgroups. It does bring in additional
>> complexity
>>    with it and it should justfiy the advantages. Can you think of some?
>>
>>    Until and unless we can come up with some significant advantages, I
>> will
>>    prefer to continue to use per group limit through q->nr_group_requests
>>    interface instead of cgroup. Once things stablize, we can revisit
>> it and
>>    see how this interface can be improved.
> 
> I agree.  I will try to clarify if per group per device limitation is
> needed
> or not (or, if it has the advantage beyond the complexity) through some
> tests.

  Great, hope to hear you soon.

-- 
Regards
Gui Jianfeng

> 
> 
> 
> Tnaks a lot,
> Muuhh
> 
> 
>> Thanks
>> Vivek
>>
>>> Signed-off-by: Gui Jianfeng<guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>>> ---
>>>   block/blk-core.c     |   23 ++++++++++--
>>>   block/blk-settings.c |    1 -
>>>   block/blk-sysfs.c    |   43 -----------------------
>>>   block/elevator-fq.c  |   94
>>> ++++++++++++++++++++++++++++++++++++++++++++++---
>>>   block/elevator-fq.h  |    4 ++
>>>   5 files changed, 111 insertions(+), 54 deletions(-)
>>>
>>> diff --git a/block/blk-core.c b/block/blk-core.c
>>> index 79fe6a9..7010b76 100644
>>> --- a/block/blk-core.c
>>> +++ b/block/blk-core.c
>>> @@ -722,13 +722,20 @@ static void ioc_set_batching(struct
>>> request_queue *q, struct io_context *ioc)
>>>   static void __freed_request(struct request_queue *q, int sync,
>>>                       struct request_list *rl)
>>>   {
>>> +    struct io_group *iog;
>>> +    unsigned long nr_group_requests;
>>> +
>>>       if (q->rq_data.count[sync]<  queue_congestion_off_threshold(q))
>>>           blk_clear_queue_congested(q, sync);
>>>
>>>       if (q->rq_data.count[sync] + 1<= q->nr_requests)
>>>           blk_clear_queue_full(q, sync);
>>>
>>> -    if (rl->count[sync] + 1<= q->nr_group_requests) {
>>> +    iog = rl_iog(rl);
>>> +
>>> +    nr_group_requests = get_group_requests(q, iog);
>>> +
>>> +    if (nr_group_requests&&  rl->count[sync] + 1<= nr_group_requests) {
>>>           if (waitqueue_active(&rl->wait[sync]))
>>>               wake_up(&rl->wait[sync]);
>>>       }
>>> @@ -828,6 +835,8 @@ static struct request *get_request(struct
>>> request_queue *q, int rw_flags,
>>>       const bool is_sync = rw_is_sync(rw_flags) != 0;
>>>       int may_queue, priv;
>>>       int sleep_on_global = 0;
>>> +    struct io_group *iog;
>>> +    unsigned long nr_group_requests;
>>>
>>>       may_queue = elv_may_queue(q, rw_flags);
>>>       if (may_queue == ELV_MQUEUE_NO)
>>> @@ -843,7 +852,12 @@ static struct request *get_request(struct
>>> request_queue *q, int rw_flags,
>>>       if (q->rq_data.count[is_sync]+1>= q->nr_requests)
>>>           blk_set_queue_full(q, is_sync);
>>>
>>> -    if (rl->count[is_sync]+1>= q->nr_group_requests) {
>>> +    iog = rl_iog(rl);
>>> +
>>> +    nr_group_requests = get_group_requests(q, iog);
>>> +
>>> +    if (nr_group_requests&&
>>> +        rl->count[is_sync]+1>= nr_group_requests) {
>>>           ioc = current_io_context(GFP_ATOMIC, q->node);
>>>           /*
>>>            * The queue request descriptor group will fill after this
>>> @@ -852,7 +866,7 @@ static struct request *get_request(struct
>>> request_queue *q, int rw_flags,
>>>            * This process will be allowed to complete a batch of
>>>            * requests, others will be blocked.
>>>            */
>>> -        if (rl->count[is_sync]<= q->nr_group_requests)
>>> +        if (rl->count[is_sync]<= nr_group_requests)
>>>               ioc_set_batching(q, ioc);
>>>           else {
>>>               if (may_queue != ELV_MQUEUE_MUST
>>> @@ -898,7 +912,8 @@ static struct request *get_request(struct
>>> request_queue *q, int rw_flags,
>>>        * from per group request list
>>>        */
>>>
>>> -    if (rl->count[is_sync]>= (3 * q->nr_group_requests / 2))
>>> +    if (nr_group_requests&&
>>> +        rl->count[is_sync]>= (3 * nr_group_requests / 2))
>>>           goto out;
>>>
>>>       rl->starved[is_sync] = 0;
>>> diff --git a/block/blk-settings.c b/block/blk-settings.c
>>> index 78b8aec..bd582a7 100644
>>> --- a/block/blk-settings.c
>>> +++ b/block/blk-settings.c
>>> @@ -148,7 +148,6 @@ void blk_queue_make_request(struct request_queue
>>> *q, make_request_fn *mfn)
>>>        * set defaults
>>>        */
>>>       q->nr_requests = BLKDEV_MAX_RQ;
>>> -    q->nr_group_requests = BLKDEV_MAX_GROUP_RQ;
>>>
>>>       q->make_request_fn = mfn;
>>>       blk_queue_dma_alignment(q, 511);
>>> diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
>>> index 92b9f25..706d852 100644
>>> --- a/block/blk-sysfs.c
>>> +++ b/block/blk-sysfs.c
>>> @@ -78,40 +78,8 @@ queue_requests_store(struct request_queue *q,
>>> const char *page, size_t count)
>>>       return ret;
>>>   }
>>>   #ifdef CONFIG_GROUP_IOSCHED
>>> -static ssize_t queue_group_requests_show(struct request_queue *q,
>>> char *page)
>>> -{
>>> -    return queue_var_show(q->nr_group_requests, (page));
>>> -}
>>> -
>>>   extern void elv_io_group_congestion_threshold(struct request_queue *q,
>>>                             struct io_group *iog);
>>> -
>>> -static ssize_t
>>> -queue_group_requests_store(struct request_queue *q, const char *page,
>>> -                    size_t count)
>>> -{
>>> -    struct hlist_node *n;
>>> -    struct io_group *iog;
>>> -    struct elv_fq_data *efqd;
>>> -    unsigned long nr;
>>> -    int ret = queue_var_store(&nr, page, count);
>>> -
>>> -    if (nr<  BLKDEV_MIN_RQ)
>>> -        nr = BLKDEV_MIN_RQ;
>>> -
>>> -    spin_lock_irq(q->queue_lock);
>>> -
>>> -    q->nr_group_requests = nr;
>>> -
>>> -    efqd =&q->elevator->efqd;
>>> -
>>> -    hlist_for_each_entry(iog, n,&efqd->group_list, elv_data_node) {
>>> -        elv_io_group_congestion_threshold(q, iog);
>>> -    }
>>> -
>>> -    spin_unlock_irq(q->queue_lock);
>>> -    return ret;
>>> -}
>>>   #endif
>>>
>>>   static ssize_t queue_ra_show(struct request_queue *q, char *page)
>>> @@ -278,14 +246,6 @@ static struct queue_sysfs_entry
>>> queue_requests_entry = {
>>>       .store = queue_requests_store,
>>>   };
>>>
>>> -#ifdef CONFIG_GROUP_IOSCHED
>>> -static struct queue_sysfs_entry queue_group_requests_entry = {
>>> -    .attr = {.name = "nr_group_requests", .mode = S_IRUGO | S_IWUSR },
>>> -    .show = queue_group_requests_show,
>>> -    .store = queue_group_requests_store,
>>> -};
>>> -#endif
>>> -
>>>   static struct queue_sysfs_entry queue_ra_entry = {
>>>       .attr = {.name = "read_ahead_kb", .mode = S_IRUGO | S_IWUSR },
>>>       .show = queue_ra_show,
>>> @@ -360,9 +320,6 @@ static struct queue_sysfs_entry
>>> queue_iostats_entry = {
>>>
>>>   static struct attribute *default_attrs[] = {
>>>       &queue_requests_entry.attr,
>>> -#ifdef CONFIG_GROUP_IOSCHED
>>> -    &queue_group_requests_entry.attr,
>>> -#endif
>>>       &queue_ra_entry.attr,
>>>       &queue_max_hw_sectors_entry.attr,
>>>       &queue_max_sectors_entry.attr,
>>> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
>>> index 29392e7..bfb0210 100644
>>> --- a/block/elevator-fq.c
>>> +++ b/block/elevator-fq.c
>>> @@ -59,6 +59,35 @@ elv_release_ioq(struct elevator_queue *eq, struct
>>> io_queue **ioq_ptr);
>>>   #define for_each_entity_safe(entity, parent) \
>>>       for (; entity&&  ({ parent = entity->parent; 1; }); entity =
>>> parent)
>>>
>>> +unsigned short get_group_requests(struct request_queue *q,
>>> +                  struct io_group *iog)
>>> +{
>>> +    struct cgroup_subsys_state *css;
>>> +    struct io_cgroup *iocg;
>>> +    unsigned long nr_group_requests;
>>> +
>>> +    if (!iog)
>>> +        return q->nr_requests;
>>> +
>>> +    rcu_read_lock();
>>> +
>>> +    if (!iog->iocg_id) {
>>> +        nr_group_requests = 0;
>>> +        goto out;
>>> +    }
>>> +
>>> +    css = css_lookup(&io_subsys, iog->iocg_id);
>>> +    if (!css) {
>>> +        nr_group_requests = 0;
>>> +        goto out;
>>> +    }
>>> +
>>> +    iocg = container_of(css, struct io_cgroup, css);
>>> +    nr_group_requests = iocg->nr_group_requests;
>>> +out:
>>> +    rcu_read_unlock();
>>> +    return nr_group_requests;
>>> +}
>>>
>>>   static struct io_entity *bfq_lookup_next_entity(struct
>>> io_sched_data *sd,
>>>                            int extract);
>>> @@ -1257,14 +1286,17 @@ void elv_io_group_congestion_threshold(struct
>>> request_queue *q,
>>>                           struct io_group *iog)
>>>   {
>>>       int nr;
>>> +    unsigned long nr_group_requests;
>>>
>>> -    nr = q->nr_group_requests - (q->nr_group_requests / 8) + 1;
>>> -    if (nr>  q->nr_group_requests)
>>> -        nr = q->nr_group_requests;
>>> +    nr_group_requests = get_group_requests(q, iog);
>>> +
>>> +    nr = nr_group_requests - (nr_group_requests / 8) + 1;
>>> +    if (nr>  nr_group_requests)
>>> +        nr = nr_group_requests;
>>>       iog->nr_congestion_on = nr;
>>>
>>> -    nr = q->nr_group_requests - (q->nr_group_requests / 8)
>>> -            - (q->nr_group_requests / 16) - 1;
>>> +    nr = nr_group_requests - (nr_group_requests / 8)
>>> +            - (nr_group_requests / 16) - 1;
>>>       if (nr<  1)
>>>           nr = 1;
>>>       iog->nr_congestion_off = nr;
>>> @@ -1283,6 +1315,7 @@ int elv_io_group_congested(struct request_queue
>>> *q, struct page *page, int sync)
>>>   {
>>>       struct io_group *iog;
>>>       int ret = 0;
>>> +    unsigned long nr_group_requests;
>>>
>>>       rcu_read_lock();
>>>
>>> @@ -1300,10 +1333,11 @@ int elv_io_group_congested(struct
>>> request_queue *q, struct page *page, int sync)
>>>       }
>>>
>>>       ret = elv_is_iog_congested(q, iog, sync);
>>> +    nr_group_requests = get_group_requests(q, iog);
>>>       if (ret)
>>>           elv_log_iog(&q->elevator->efqd, iog, "iog congested=%d
>>> sync=%d"
>>>               " rl.count[sync]=%d nr_group_requests=%d",
>>> -            ret, sync, iog->rl.count[sync], q->nr_group_requests);
>>> +            ret, sync, iog->rl.count[sync], nr_group_requests);
>>>       rcu_read_unlock();
>>>       return ret;
>>>   }
>>> @@ -1549,6 +1583,48 @@ free_buf:
>>>       return ret;
>>>   }
>>>
>>> +static u64 io_cgroup_nr_requests_read(struct cgroup *cgroup,
>>> +                       struct cftype *cftype)
>>> +{
>>> +    struct io_cgroup *iocg;
>>> +    u64 ret;
>>> +
>>> +    if (!cgroup_lock_live_group(cgroup))
>>> +        return -ENODEV;
>>> +
>>> +    iocg = cgroup_to_io_cgroup(cgroup);
>>> +    spin_lock_irq(&iocg->lock);
>>> +    ret = iocg->nr_group_requests;
>>> +    spin_unlock_irq(&iocg->lock);
>>> +
>>> +    cgroup_unlock();
>>> +
>>> +    return ret;
>>> +}
>>> +
>>> +static int io_cgroup_nr_requests_write(struct cgroup *cgroup,
>>> +                    struct cftype *cftype,
>>> +                    u64 val)
>>> +{
>>> +    struct io_cgroup *iocg;
>>> +
>>> +    if (val<  BLKDEV_MIN_RQ)
>>> +        val = BLKDEV_MIN_RQ;
>>> +
>>> +    if (!cgroup_lock_live_group(cgroup))
>>> +        return -ENODEV;
>>> +
>>> +    iocg = cgroup_to_io_cgroup(cgroup);
>>> +
>>> +    spin_lock_irq(&iocg->lock);
>>> +    iocg->nr_group_requests = (unsigned long)val;
>>> +    spin_unlock_irq(&iocg->lock);
>>> +
>>> +    cgroup_unlock();
>>> +
>>> +    return 0;
>>> +}
>>> +
>>>   #define SHOW_FUNCTION(__VAR)                        \
>>>   static u64 io_cgroup_##__VAR##_read(struct cgroup *cgroup,        \
>>>                          struct cftype *cftype)        \
>>> @@ -1735,6 +1811,11 @@ static int io_cgroup_disk_dequeue_read(struct
>>> cgroup *cgroup,
>>>
>>>   struct cftype bfqio_files[] = {
>>>       {
>>> +        .name = "nr_group_requests",
>>> +        .read_u64 = io_cgroup_nr_requests_read,
>>> +        .write_u64 = io_cgroup_nr_requests_write,
>>> +    },
>>> +    {
>>>           .name = "policy",
>>>           .read_seq_string = io_cgroup_policy_read,
>>>           .write_string = io_cgroup_policy_write,
>>> @@ -1790,6 +1871,7 @@ static struct cgroup_subsys_state
>>> *iocg_create(struct cgroup_subsys *subsys,
>>>
>>>       spin_lock_init(&iocg->lock);
>>>       INIT_HLIST_HEAD(&iocg->group_data);
>>> +    iocg->nr_group_requests = BLKDEV_MAX_GROUP_RQ;
>>>       iocg->weight = IO_DEFAULT_GRP_WEIGHT;
>>>       iocg->ioprio_class = IO_DEFAULT_GRP_CLASS;
>>>       INIT_LIST_HEAD(&iocg->policy_list);
>>> diff --git a/block/elevator-fq.h b/block/elevator-fq.h
>>> index f089a55..df077d0 100644
>>> --- a/block/elevator-fq.h
>>> +++ b/block/elevator-fq.h
>>> @@ -308,6 +308,7 @@ struct io_cgroup {
>>>       unsigned int weight;
>>>       unsigned short ioprio_class;
>>>
>>> +    unsigned long nr_group_requests;
>>>       /* list of io_policy_node */
>>>       struct list_head policy_list;
>>>
>>> @@ -386,6 +387,9 @@ struct elv_fq_data {
>>>       unsigned int fairness;
>>>   };
>>>
>>> +extern unsigned short get_group_requests(struct request_queue *q,
>>> +                     struct io_group *iog);
>>> +
>>>   /* Logging facilities. */
>>>   #ifdef CONFIG_DEBUG_GROUP_IOSCHED
>>>   #define elv_log_ioq(efqd, ioq, fmt, args...) \
>>> -- 
>>> 1.5.4.rc3
>>
> 
