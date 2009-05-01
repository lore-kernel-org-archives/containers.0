From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO Controller per cgroup request descriptors (Re: [PATCH 01/10]
	Documentation)
Date: Fri, 1 May 2009 16:39:49 -0700
Message-ID: <e98e18940905011639o63c048f1n79c7e7648441a06d__31532.4298375801$1241221370$gmane$org@mail.gmail.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090406143556.GK7082@balbir.in.ibm.com>
	<20090413134017.GC18007@redhat.com> <49FB71F7.90309@ds.jp.nec.com>
	<20090501224506.GC6130@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090501224506.GC6130-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, May 1, 2009 at 3:45 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Fri, May 01, 2009 at 06:04:39PM -0400, IKEDA, Munehiro wrote:
>> Vivek Goyal wrote:
>>>>> +TODO
>>>>> +=3D=3D=3D=3D
>>>>> +- Lots of cleanups, testing, bug fixing, optimizations, benchmarking=
 etc...
>>>>> +- Convert cgroup ioprio to notion of weight.
>>>>> +- Anticipatory code will need more work. It is not working properly =
currently
>>>>> + =A0and needs more thought.
>>>> What are the problems with the code?
>>>
>>> Have not got a chance to look into the issues in detail yet. Just a cru=
de run
>>> saw drop in performance. Will debug it later the moment I have got asyn=
c writes
>>> handled...
>>>
>>>>> +- Use of bio-cgroup patches.
>>>> I saw these posted as well
>>>>
>>>>> +- Use of Nauman's per cgroup request descriptor patches.
>>>>> +
>>>> More details would be nice, I am not sure I understand
>>>
>>> Currently the number of request descriptors which can be allocated per
>>> device/request queue are fixed by a sysfs tunable (q->nr_requests). So
>>> if there is lots of IO going on from one cgroup then it will consume all
>>> the available request descriptors and other cgroup might starve and not
>>> get its fair share.
>>>
>>> Hence we also need to introduce the notion of request descriptor limit =
per
>>> cgroup so that if request descriptors from one group are exhausted, then
>>> it does not impact the IO of other cgroup.
>>
>> Unfortunately I couldn't find and I've never seen the Nauman's patches.
>> So I tried to make a patch below against this todo. =A0The reason why
>> I'm posting this despite this is just a quick and ugly hack (and it
>> might be a reinvention of wheel) is that I would like to discuss how
>> we should define the limitation of requests per cgroup.
>> This patch should be applied on Vivek's I/O controller patches
>> posted on Mar 11.
>
> Hi IKEDA,
>
> Sorry for the confusion here. Actually Nauman had sent a patch to select =
group
> of people who were initially copied on the mail thread.

I am sorry about that. Since I dropped my whole patch set in favor of
Vivek's stuff, this stuff fell through the cracks.

>
>>
>> This patch temporarily distribute q->nr_requests to each cgroup.
>> I think the number should be weighted like BFQ's budget. =A0But in
>> this case, if the hierarchy of cgroup is deep, leaf cgroups are
>> allowed to allocate very few numbers of requests. =A0I don't think
>> this is reasonable...but I don't have specific idea to solve this
>> problem. =A0Does anyone have the good idea?
>>
>
> Thanks for the patch. Yes, ideally one would expect the request descriptor
> to be allocated also in proportion to the weight but I guess that would
> become very comlicated.
>
> In terms of simpler things, two thoughts come to mind.
>
> - First approach is to make q->nr_requests per group. So every group is
> =A0entitled for q->nr_requests as set by the user. This is what your patch
> =A0seems to have done.
>
> =A0I had some concerns with this approach. First of all it does not seem =
to
> =A0have an upper bound on number of request descriptors allocated per que=
ue
> =A0because if a user creates more cgroups, total number of request
> =A0descriptors increase.
>
> - Second approach can be that we retain the meaning of q->nr_requests
> =A0which defines the total number of request descriptors on the queue (wi=
th
> =A0the exception of 50% more descriptors for batching processes). And we
> =A0define a new per group limit q->nr_group_requests which defines how ma=
ny
> =A0requests per group can be assigned. So q->nr_requests defines total po=
ol
> =A0size on the queue and q->nr_group_requests will define how many reques=
ts
> =A0each group can allocate out of that pool.
>
> =A0Here the issue is that a user shall have to balance the q->nr_group_re=
quests =A0 =A0and q->nr_requests properly.
>
> To experiment, I have implemented the second approach. I am attaching the
> patch which is in my current tree. It probably will not apply on my march
> 11 posting as since then patches have changed. But posting it here so that
> at least it will give an idea behind the thought process.
>
> Ideas are welcome...

I had started with the first option, but the second option sounds good
too. But one problem that comes to mind is how we deal with
hierarchies? The sys admin can limit the root level cgroups to
specific number of request descriptors, but if applications running in
a cgroup are allowed to create their own cgroups, then the total
request descriptors of all child cgroups should be capped by the
number assigned to parent cgroups.

>
> Thanks
> Vivek
>
> o Currently a request queue has got fixed number of request descriptors f=
or
> =A0sync and async requests. Once the request descriptors are consumed, new
> =A0processes are put to sleep and they effectively become serialized. Bec=
ause
> =A0sync and async queues are separate, async requests don't impact sync o=
nes
> =A0but if one is looking for fairness between async requests, that is not
> =A0achievable if request queue descriptors become bottleneck.
>
> o Make request descriptor's per io group so that if there is lots of IO
> =A0going on in one cgroup, it does not impact the IO of other group.
>
> o This patch implements the per cgroup request descriptors. request pool =
per
> =A0queue is still common but every group will have its own wait list and =
its
> =A0own count of request descriptors allocated to that group for sync and =
async
> =A0queues. So effectively request_list becomes per io group property and =
not a
> =A0global request queue feature.
>
> o Currently one can define q->nr_requests to limit request descriptors
> =A0allocated for the queue. Now there is another tunable q->nr_group_requ=
ests
> =A0which controls the requests descriptr limit per group. q->nr_requests
> =A0supercedes q->nr_group_requests to make sure if there are lots of grou=
ps
> =A0present, we don't end up allocating too many request descriptors on the
> =A0queue.
>
> o Issues: Currently notion of congestion is per queue. With per group req=
uest
> =A0descriptor it is possible that queue is not congested but the group bio
> =A0will go into is congested.
>
> Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>
> ---
> =A0block/blk-core.c =A0 =A0 =A0 | =A0216 ++++++++++++++++++++++++++++++++=
++---------------
> =A0block/blk-settings.c =A0 | =A0 =A03
> =A0block/blk-sysfs.c =A0 =A0 =A0| =A0 57 ++++++++++--
> =A0block/elevator-fq.c =A0 =A0| =A0 15 +++
> =A0block/elevator-fq.h =A0 =A0| =A0 =A08 +
> =A0block/elevator.c =A0 =A0 =A0 | =A0 =A06 -
> =A0include/linux/blkdev.h | =A0 62 +++++++++++++-
> =A07 files changed, 287 insertions(+), 80 deletions(-)
>
> Index: linux9/include/linux/blkdev.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux9.orig/include/linux/blkdev.h =A02009-04-30 15:43:53.000000000 -=
0400
> +++ linux9/include/linux/blkdev.h =A0 =A0 =A0 2009-04-30 16:18:29.0000000=
00 -0400
> @@ -32,21 +32,51 @@ struct request;
> =A0struct sg_io_hdr;
>
> =A0#define BLKDEV_MIN_RQ =A04
> +
> +#ifdef CONFIG_GROUP_IOSCHED
> +#define BLKDEV_MAX_RQ =A0256 =A0 =A0 /* Default maximum */
> +#define BLKDEV_MAX_GROUP_RQ =A0 =A064 =A0 =A0 =A0/* Default maximum */
> +#else
> =A0#define BLKDEV_MAX_RQ =A0128 =A0 =A0 /* Default maximum */
> +/*
> + * This is eqivalent to case of only one group present (root group). Let
> + * it consume all the request descriptors available on the queue .
> + */
> +#define BLKDEV_MAX_GROUP_RQ =A0 =A0BLKDEV_MAX_RQ =A0 =A0 =A0/* Default m=
aximum */
> +#endif
>
> =A0struct request;
> =A0typedef void (rq_end_io_fn)(struct request *, int);
>
> =A0struct request_list {
> =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0* count[], starved[], and wait[] are indexed by
> + =A0 =A0 =A0 =A0* count[], starved and wait[] are indexed by
> =A0 =A0 =A0 =A0 * BLK_RW_SYNC/BLK_RW_ASYNC
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0int count[2];
> =A0 =A0 =A0 =A0int starved[2];
> + =A0 =A0 =A0 wait_queue_head_t wait[2];
> +};
> +
> +/*
> + * This data structures keeps track of mempool of requests for the queue
> + * and some overall statistics.
> + */
> +struct request_data {
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Per queue request descriptor count. This is in additio=
n to per
> + =A0 =A0 =A0 =A0* cgroup count
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 int count[2];
> =A0 =A0 =A0 =A0int elvpriv;
> =A0 =A0 =A0 =A0mempool_t *rq_pool;
> - =A0 =A0 =A0 wait_queue_head_t wait[2];
> + =A0 =A0 =A0 int starved;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Global list for starved tasks. A task will be queued h=
ere if
> + =A0 =A0 =A0 =A0* it could not allocate request descriptor and the assoc=
iated
> + =A0 =A0 =A0 =A0* group request list does not have any requests pending.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 wait_queue_head_t starved_wait;
> =A0};
>
> =A0/*
> @@ -251,6 +281,7 @@ struct request {
> =A0#ifdef CONFIG_GROUP_IOSCHED
> =A0 =A0 =A0 =A0/* io group request belongs to */
> =A0 =A0 =A0 =A0struct io_group *iog;
> + =A0 =A0 =A0 struct request_list *rl;
> =A0#endif /* GROUP_IOSCHED */
> =A0#endif /* ELV_FAIR_QUEUING */
> =A0};
> @@ -340,6 +371,9 @@ struct request_queue
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0struct request_list =A0 =A0 rq;
>
> + =A0 =A0 =A0 /* Contains request pool and other data like starved data */
> + =A0 =A0 =A0 struct request_data =A0 =A0 rq_data;
> +
> =A0 =A0 =A0 =A0request_fn_proc =A0 =A0 =A0 =A0 *request_fn;
> =A0 =A0 =A0 =A0make_request_fn =A0 =A0 =A0 =A0 *make_request_fn;
> =A0 =A0 =A0 =A0prep_rq_fn =A0 =A0 =A0 =A0 =A0 =A0 =A0*prep_rq_fn;
> @@ -402,6 +436,8 @@ struct request_queue
> =A0 =A0 =A0 =A0 * queue settings
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 nr_requests; =A0 =A0/* M=
ax # of requests */
> + =A0 =A0 =A0 /* Max # of per io group requests */
> + =A0 =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 nr_group_requests;
> =A0 =A0 =A0 =A0unsigned int =A0 =A0 =A0 =A0 =A0 =A0nr_congestion_on;
> =A0 =A0 =A0 =A0unsigned int =A0 =A0 =A0 =A0 =A0 =A0nr_congestion_off;
> =A0 =A0 =A0 =A0unsigned int =A0 =A0 =A0 =A0 =A0 =A0nr_batching;
> @@ -773,6 +809,28 @@ extern int scsi_cmd_ioctl(struct request
> =A0extern int sg_scsi_ioctl(struct request_queue *, struct gendisk *, fmo=
de_t,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scsi_ioctl_command=
 __user *);
>
> +extern void blk_init_request_list(struct request_list *rl);
> +
> +static inline struct request_list *blk_get_request_list(struct request_q=
ueue *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct bio *bio)
> +{
> +#ifdef CONFIG_GROUP_IOSCHED
> + =A0 =A0 =A0 return io_group_get_request_list(q, bio);
> +#else
> + =A0 =A0 =A0 return &q->rq;
> +#endif
> +}
> +
> +static inline struct request_list *rq_rl(struct request_queue *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct request *rq)
> +{
> +#ifdef CONFIG_GROUP_IOSCHED
> + =A0 =A0 =A0 return rq->rl;
> +#else
> + =A0 =A0 =A0 return blk_get_request_list(q, NULL);
> +#endif
> +}
> +
> =A0/*
> =A0* Temporary export, until SCSI gets fixed up.
> =A0*/
> Index: linux9/block/elevator.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux9.orig/block/elevator.c =A0 =A0 =A0 =A02009-04-30 16:17:53.00000=
0000 -0400
> +++ linux9/block/elevator.c =A0 =A0 2009-04-30 16:18:29.000000000 -0400
> @@ -664,7 +664,7 @@ void elv_quiesce_start(struct request_qu
> =A0 =A0 =A0 =A0 * make sure we don't have any requests in flight
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0elv_drain_elevator(q);
> - =A0 =A0 =A0 while (q->rq.elvpriv) {
> + =A0 =A0 =A0 while (q->rq_data.elvpriv) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_start_queueing(q);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irq(q->queue_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0msleep(10);
> @@ -764,8 +764,8 @@ void elv_insert(struct request_queue *q,
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (unplug_it && blk_queue_plugged(q)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nrq =3D q->rq.count[BLK_RW_SYNC] + q->r=
q.count[BLK_RW_ASYNC]
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 - q->in_flight;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nrq =3D q->rq_data.count[BLK_RW_SYNC] +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->rq_data.=
count[BLK_RW_ASYNC] - q->in_flight;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (nrq >=3D q->unplug_thresh)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__generic_unplug_device(q);
> Index: linux9/block/blk-core.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux9.orig/block/blk-core.c =A0 =A0 =A0 =A02009-04-30 16:17:53.00000=
0000 -0400
> +++ linux9/block/blk-core.c =A0 =A0 2009-04-30 16:18:29.000000000 -0400
> @@ -480,20 +480,31 @@ void blk_cleanup_queue(struct request_qu
> =A0}
> =A0EXPORT_SYMBOL(blk_cleanup_queue);
>
> -static int blk_init_free_list(struct request_queue *q)
> +void blk_init_request_list(struct request_list *rl)
> =A0{
> - =A0 =A0 =A0 struct request_list *rl =3D &q->rq;
>
> =A0 =A0 =A0 =A0rl->count[BLK_RW_SYNC] =3D rl->count[BLK_RW_ASYNC] =3D 0;
> - =A0 =A0 =A0 rl->starved[BLK_RW_SYNC] =3D rl->starved[BLK_RW_ASYNC] =3D =
0;
> - =A0 =A0 =A0 rl->elvpriv =3D 0;
> =A0 =A0 =A0 =A0init_waitqueue_head(&rl->wait[BLK_RW_SYNC]);
> =A0 =A0 =A0 =A0init_waitqueue_head(&rl->wait[BLK_RW_ASYNC]);
> +}
>
> - =A0 =A0 =A0 rl->rq_pool =3D mempool_create_node(BLKDEV_MIN_RQ, mempool_=
alloc_slab,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mempool_fre=
e_slab, request_cachep, q->node);
> +static int blk_init_free_list(struct request_queue *q)
> +{
> +#ifndef CONFIG_GROUP_IOSCHED
> + =A0 =A0 =A0 struct request_list *rl =3D blk_get_request_list(q, NULL);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* In case of group scheduling, request list is inside th=
e associated
> + =A0 =A0 =A0 =A0* group and when that group is instanciated, it takes ca=
re of
> + =A0 =A0 =A0 =A0* initializing the request list also.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 blk_init_request_list(rl);
> +#endif
> + =A0 =A0 =A0 q->rq_data.rq_pool =3D mempool_create_node(BLKDEV_MIN_RQ,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mempool_all=
oc_slab, mempool_free_slab,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 request_cac=
hep, q->node);
>
> - =A0 =A0 =A0 if (!rl->rq_pool)
> + =A0 =A0 =A0 if (!q->rq_data.rq_pool)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>
> =A0 =A0 =A0 =A0return 0;
> @@ -590,6 +601,9 @@ blk_init_queue_node(request_fn_proc *rfn
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 /* init starved waiter wait queue */
> + =A0 =A0 =A0 init_waitqueue_head(&q->rq_data.starved_wait);
> +
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * if caller didn't supply a lock, they get per-queue lock=
ing with
> =A0 =A0 =A0 =A0 * our embedded lock
> @@ -639,14 +653,14 @@ static inline void blk_free_request(stru
> =A0{
> =A0 =A0 =A0 =A0if (rq->cmd_flags & REQ_ELVPRIV)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0elv_put_request(q, rq);
> - =A0 =A0 =A0 mempool_free(rq, q->rq.rq_pool);
> + =A0 =A0 =A0 mempool_free(rq, q->rq_data.rq_pool);
> =A0}
>
> =A0static struct request *
> =A0blk_alloc_request(struct request_queue *q, struct bio *bio, int rw, in=
t priv,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0gfp_t gfp_mask)
> =A0{
> - =A0 =A0 =A0 struct request *rq =3D mempool_alloc(q->rq.rq_pool, gfp_mas=
k);
> + =A0 =A0 =A0 struct request *rq =3D mempool_alloc(q->rq_data.rq_pool, gf=
p_mask);
>
> =A0 =A0 =A0 =A0if (!rq)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
> @@ -657,7 +671,7 @@ blk_alloc_request(struct request_queue *
>
> =A0 =A0 =A0 =A0if (priv) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(elv_set_request(q, rq, bio, g=
fp_mask))) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mempool_free(rq, q->rq.rq_p=
ool);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mempool_free(rq, q->rq_data=
.rq_pool);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rq->cmd_flags |=3D REQ_ELVPRIV;
> @@ -700,18 +714,18 @@ static void ioc_set_batching(struct requ
> =A0 =A0 =A0 =A0ioc->last_waited =3D jiffies;
> =A0}
>
> -static void __freed_request(struct request_queue *q, int sync)
> +static void __freed_request(struct request_queue *q, int sync,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct request_list *rl)
> =A0{
> - =A0 =A0 =A0 struct request_list *rl =3D &q->rq;
> -
> - =A0 =A0 =A0 if (rl->count[sync] < queue_congestion_off_threshold(q))
> + =A0 =A0 =A0 if (q->rq_data.count[sync] < queue_congestion_off_threshold=
(q))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_clear_queue_congested(q, sync);
>
> - =A0 =A0 =A0 if (rl->count[sync] + 1 <=3D q->nr_requests) {
> + =A0 =A0 =A0 if (q->rq_data.count[sync] + 1 <=3D q->nr_requests)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_clear_queue_full(q, sync);
> +
> + =A0 =A0 =A0 if (rl->count[sync] + 1 <=3D q->nr_group_requests) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (waitqueue_active(&rl->wait[sync]))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wake_up(&rl->wait[sync]);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_clear_queue_full(q, sync);
> =A0 =A0 =A0 =A0}
> =A0}
>
> @@ -719,18 +733,29 @@ static void __freed_request(struct reque
> =A0* A request has just been released. =A0Account for it, update the full=
 and
> =A0* congestion status, wake up any waiters. =A0 Called under q->queue_lo=
ck.
> =A0*/
> -static void freed_request(struct request_queue *q, int sync, int priv)
> +static void freed_request(struct request_queue *q, int sync, int priv,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct request_list *rl)
> =A0{
> - =A0 =A0 =A0 struct request_list *rl =3D &q->rq;
> -
> + =A0 =A0 =A0 BUG_ON(!rl->count[sync]);
> =A0 =A0 =A0 =A0rl->count[sync]--;
> +
> + =A0 =A0 =A0 BUG_ON(!q->rq_data.count[sync]);
> + =A0 =A0 =A0 q->rq_data.count[sync]--;
> +
> =A0 =A0 =A0 =A0if (priv)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rl->elvpriv--;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->rq_data.elvpriv--;
>
> - =A0 =A0 =A0 __freed_request(q, sync);
> + =A0 =A0 =A0 __freed_request(q, sync, rl);
>
> =A0 =A0 =A0 =A0if (unlikely(rl->starved[sync ^ 1]))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __freed_request(q, sync ^ 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __freed_request(q, sync ^ 1, rl);
> +
> + =A0 =A0 =A0 /* Wake up the starved process on global list, if any */
> + =A0 =A0 =A0 if (unlikely(q->rq_data.starved)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (waitqueue_active(&q->rq_data.starved_wa=
it))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up(&q->rq_data.starved=
_wait);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->rq_data.starved--;
> + =A0 =A0 =A0 }
> =A0}
>
> =A0/*
> @@ -739,10 +764,9 @@ static void freed_request(struct request
> =A0* Returns !NULL on success, with queue_lock *not held*.
> =A0*/
> =A0static struct request *get_request(struct request_queue *q, int rw_fla=
gs,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct bio *bio, gfp_t gfp_mask)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct bio *bio, gfp_t gfp_mask, str=
uct request_list *rl)
> =A0{
> =A0 =A0 =A0 =A0struct request *rq =3D NULL;
> - =A0 =A0 =A0 struct request_list *rl =3D &q->rq;
> =A0 =A0 =A0 =A0struct io_context *ioc =3D NULL;
> =A0 =A0 =A0 =A0const bool is_sync =3D rw_is_sync(rw_flags) !=3D 0;
> =A0 =A0 =A0 =A0int may_queue, priv;
> @@ -751,31 +775,38 @@ static struct request *get_request(struc
> =A0 =A0 =A0 =A0if (may_queue =3D=3D ELV_MQUEUE_NO)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto rq_starved;
>
> - =A0 =A0 =A0 if (rl->count[is_sync]+1 >=3D queue_congestion_on_threshold=
(q)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rl->count[is_sync]+1 >=3D q->nr_request=
s) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioc =3D current_io_context(=
GFP_ATOMIC, q->node);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The queue will fill af=
ter this allocation, so set
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* it as full, and mark t=
his process as "batching".
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This process will be a=
llowed to complete a batch of
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* requests, others will =
be blocked.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!blk_queue_full(q, is_s=
ync)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioc_set_bat=
ching(q, ioc);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_set_que=
ue_full(q, is_sync);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (may_que=
ue !=3D ELV_MQUEUE_MUST
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 && !ioc_batching(q, ioc)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0* The queue is full and the allocating
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0* process is not a "batcher", and not
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0* exempted by the IO scheduler
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goto out;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (q->rq_data.count[is_sync]+1 >=3D queue_congestion_on_th=
reshold(q))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_set_queue_congested(q, is_sync);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Looks like there is no user of queue full now.
> + =A0 =A0 =A0 =A0* Keeping it for time being.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (q->rq_data.count[is_sync]+1 >=3D q->nr_requests)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_set_queue_full(q, is_sync);
> +
> + =A0 =A0 =A0 if (rl->count[is_sync]+1 >=3D q->nr_group_requests) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioc =3D current_io_context(GFP_ATOMIC, q->n=
ode);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The queue request descriptor group wil=
l fill after this
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* allocation, so set
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* it as full, and mark this process as "=
batching".
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This process will be allowed to comple=
te a batch of
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* requests, others will be blocked.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rl->count[is_sync] <=3D q->nr_group_req=
uests)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioc_set_batching(q, ioc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (may_queue !=3D ELV_MQUE=
UE_MUST
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 && !ioc_batching(q, ioc)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The qu=
eue is full and the allocating
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* proces=
s is not a "batcher", and not
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* exempt=
ed by the IO scheduler
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_set_queue_congested(q, is_sync);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/*
> @@ -783,19 +814,41 @@ static struct request *get_request(struc
> =A0 =A0 =A0 =A0 * limit of requests, otherwise we could have thousands of=
 requests
> =A0 =A0 =A0 =A0 * allocated with any setting of ->nr_requests
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (rl->count[is_sync] >=3D (3 * q->nr_requests / 2))
> +
> + =A0 =A0 =A0 if (q->rq_data.count[is_sync] >=3D (3 * q->nr_requests / 2))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Allocation of request is allowed from queue perspectiv=
e. Now check
> + =A0 =A0 =A0 =A0* from per group request list
> + =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 if (rl->count[is_sync] >=3D (3 * q->nr_group_requests / 2))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> =A0 =A0 =A0 =A0rl->count[is_sync]++;
> =A0 =A0 =A0 =A0rl->starved[is_sync] =3D 0;
>
> + =A0 =A0 =A0 q->rq_data.count[is_sync]++;
> +
> =A0 =A0 =A0 =A0priv =3D !test_bit(QUEUE_FLAG_ELVSWITCH, &q->queue_flags);
> =A0 =A0 =A0 =A0if (priv)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rl->elvpriv++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->rq_data.elvpriv++;
>
> =A0 =A0 =A0 =A0spin_unlock_irq(q->queue_lock);
>
> =A0 =A0 =A0 =A0rq =3D blk_alloc_request(q, bio, rw_flags, priv, gfp_mask);
> +
> +#ifdef CONFIG_GROUP_IOSCHED
> + =A0 =A0 =A0 if (rq) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* TODO. Implement group reference counti=
ng and take the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* reference to the group to make sure gr=
oup hence request
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* list does not go away till rq finishes.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rq->rl =3D rl;
> + =A0 =A0 =A0 }
> +#endif
> =A0 =A0 =A0 =A0if (unlikely(!rq)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Allocation failed presumably due to mem=
ory. Undo anything
> @@ -805,7 +858,7 @@ static struct request *get_request(struc
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * wait queue, but this is pretty rare.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock_irq(q->queue_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 freed_request(q, is_sync, priv);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 freed_request(q, is_sync, priv, rl);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * in the very unlikely event that allocat=
ion failed and no
> @@ -815,10 +868,26 @@ static struct request *get_request(struc
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * rq mempool into READ and WRITE
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0rq_starved:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(rl->count[is_sync] =3D=3D 0))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rl->starved[is_sync] =3D 1;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(rl->count[is_sync] =3D=3D 0)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If there is a request =
pending in other direction
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* in same io group, then=
 set the starved flag of
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the group request list=
. Otherwise, we need to
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* make this process slee=
p in global starved list
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to make sure it will n=
ot sleep indefinitely.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rl->count[is_sync ^ 1] =
!=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rl->starved=
[is_sync] =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* It ind=
icates to calling function to put
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* task o=
n global starved list. Not the best
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* way
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_=
PTR(-ENOMEM);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/*
> @@ -846,15 +915,29 @@ static struct request *get_request_wait(
> =A0{
> =A0 =A0 =A0 =A0const bool is_sync =3D rw_is_sync(rw_flags) !=3D 0;
> =A0 =A0 =A0 =A0struct request *rq;
> + =A0 =A0 =A0 struct request_list *rl =3D blk_get_request_list(q, bio);
>
> - =A0 =A0 =A0 rq =3D get_request(q, rw_flags, bio, GFP_NOIO);
> - =A0 =A0 =A0 while (!rq) {
> + =A0 =A0 =A0 rq =3D get_request(q, rw_flags, bio, GFP_NOIO, rl);
> + =A0 =A0 =A0 while (!rq || (IS_ERR(rq) && PTR_ERR(rq) =3D=3D -ENOMEM)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DEFINE_WAIT(wait);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct io_context *ioc;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct request_list *rl =3D &q->rq;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 prepare_to_wait_exclusive(&rl->wait[is_sync=
], &wait,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TASK_UNINTE=
RRUPTIBLE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (IS_ERR(rq) && PTR_ERR(rq) =3D=3D -ENOME=
M) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Task failed allocation=
 and needs to wait and
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* try again. There are n=
o requests pending from
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the io group hence nee=
d to sleep on global
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* wait queue. Most likel=
y the allocation failed
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* because of memory issu=
es.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->rq_data.starved++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 prepare_to_wait_exclusive(&=
q->rq_data.starved_wait,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 &wait, TASK_UNINTERRUPTIBLE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 prepare_to_wait_exclusive(&=
rl->wait[is_sync], &wait,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 TASK_UNINTERRUPTIBLE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0trace_block_sleeprq(q, bio, rw_flags & 1);
>
> @@ -874,7 +957,12 @@ static struct request *get_request_wait(
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock_irq(q->queue_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0finish_wait(&rl->wait[is_sync], &wait);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rq =3D get_request(q, rw_flags, bio, GFP_NO=
IO);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* After the sleep check the rl again in =
case cgrop bio
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* belonged to is gone and it is mapped t=
o root group now
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rl =3D blk_get_request_list(q, bio);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rq =3D get_request(q, rw_flags, bio, GFP_NO=
IO, rl);
> =A0 =A0 =A0 =A0};
>
> =A0 =A0 =A0 =A0return rq;
> @@ -883,6 +971,7 @@ static struct request *get_request_wait(
> =A0struct request *blk_get_request(struct request_queue *q, int rw, gfp_t=
 gfp_mask)
> =A0{
> =A0 =A0 =A0 =A0struct request *rq;
> + =A0 =A0 =A0 struct request_list *rl =3D blk_get_request_list(q, NULL);
>
> =A0 =A0 =A0 =A0BUG_ON(rw !=3D READ && rw !=3D WRITE);
>
> @@ -890,7 +979,7 @@ struct request *blk_get_request(struct r
> =A0 =A0 =A0 =A0if (gfp_mask & __GFP_WAIT) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rq =3D get_request_wait(q, rw, NULL);
> =A0 =A0 =A0 =A0} else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rq =3D get_request(q, rw, NULL, gfp_mask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rq =3D get_request(q, rw, NULL, gfp_mask, r=
l);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!rq)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irq(q->queue_l=
ock);
> =A0 =A0 =A0 =A0}
> @@ -1073,12 +1162,13 @@ void __blk_put_request(struct request_qu
> =A0 =A0 =A0 =A0if (req->cmd_flags & REQ_ALLOCED) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int is_sync =3D rq_is_sync(req) !=3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int priv =3D req->cmd_flags & REQ_ELVPRIV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct request_list *rl =3D rq_rl(q, req);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(!list_empty(&req->queuelist));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(!hlist_unhashed(&req->hash));
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_free_request(q, req);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 freed_request(q, is_sync, priv);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 freed_request(q, is_sync, priv, rl);
> =A0 =A0 =A0 =A0}
> =A0}
> =A0EXPORT_SYMBOL_GPL(__blk_put_request);
> Index: linux9/block/blk-sysfs.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux9.orig/block/blk-sysfs.c =A0 =A0 =A0 2009-04-30 16:18:27.0000000=
00 -0400
> +++ linux9/block/blk-sysfs.c =A0 =A02009-04-30 16:18:29.000000000 -0400
> @@ -38,7 +38,7 @@ static ssize_t queue_requests_show(struc
> =A0static ssize_t
> =A0queue_requests_store(struct request_queue *q, const char *page, size_t=
 count)
> =A0{
> - =A0 =A0 =A0 struct request_list *rl =3D &q->rq;
> + =A0 =A0 =A0 struct request_list *rl =3D blk_get_request_list(q, NULL);
> =A0 =A0 =A0 =A0unsigned long nr;
> =A0 =A0 =A0 =A0int ret =3D queue_var_store(&nr, page, count);
> =A0 =A0 =A0 =A0if (nr < BLKDEV_MIN_RQ)
> @@ -48,32 +48,55 @@ queue_requests_store(struct request_queu
> =A0 =A0 =A0 =A0q->nr_requests =3D nr;
> =A0 =A0 =A0 =A0blk_queue_congestion_threshold(q);
>
> - =A0 =A0 =A0 if (rl->count[BLK_RW_SYNC] >=3D queue_congestion_on_thresho=
ld(q))
> + =A0 =A0 =A0 if (q->rq_data.count[BLK_RW_SYNC] >=3D queue_congestion_on_=
threshold(q))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_set_queue_congested(q, BLK_RW_SYNC);
> - =A0 =A0 =A0 else if (rl->count[BLK_RW_SYNC] < queue_congestion_off_thre=
shold(q))
> + =A0 =A0 =A0 else if (q->rq_data.count[BLK_RW_SYNC] <
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 queue_conge=
stion_off_threshold(q))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_clear_queue_congested(q, BLK_RW_SYNC);
>
> - =A0 =A0 =A0 if (rl->count[BLK_RW_ASYNC] >=3D queue_congestion_on_thresh=
old(q))
> + =A0 =A0 =A0 if (q->rq_data.count[BLK_RW_ASYNC] >=3D queue_congestion_on=
_threshold(q))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_set_queue_congested(q, BLK_RW_ASYNC);
> - =A0 =A0 =A0 else if (rl->count[BLK_RW_ASYNC] < queue_congestion_off_thr=
eshold(q))
> + =A0 =A0 =A0 else if (q->rq_data.count[BLK_RW_ASYNC] <
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 queue_conge=
stion_off_threshold(q))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_clear_queue_congested(q, BLK_RW_ASYNC);
>
> - =A0 =A0 =A0 if (rl->count[BLK_RW_SYNC] >=3D q->nr_requests) {
> + =A0 =A0 =A0 if (q->rq_data.count[BLK_RW_SYNC] >=3D q->nr_requests) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_set_queue_full(q, BLK_RW_SYNC);
> - =A0 =A0 =A0 } else if (rl->count[BLK_RW_SYNC]+1 <=3D q->nr_requests) {
> + =A0 =A0 =A0 } else if (q->rq_data.count[BLK_RW_SYNC]+1 <=3D q->nr_reque=
sts) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_clear_queue_full(q, BLK_RW_SYNC);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wake_up(&rl->wait[BLK_RW_SYNC]);
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if (rl->count[BLK_RW_ASYNC] >=3D q->nr_requests) {
> + =A0 =A0 =A0 if (q->rq_data.count[BLK_RW_ASYNC] >=3D q->nr_requests) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_set_queue_full(q, BLK_RW_ASYNC);
> - =A0 =A0 =A0 } else if (rl->count[BLK_RW_ASYNC]+1 <=3D q->nr_requests) {
> + =A0 =A0 =A0 } else if (q->rq_data.count[BLK_RW_ASYNC]+1 <=3D q->nr_requ=
ests) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_clear_queue_full(q, BLK_RW_ASYNC);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wake_up(&rl->wait[BLK_RW_ASYNC]);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0spin_unlock_irq(q->queue_lock);
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +#ifdef CONFIG_GROUP_IOSCHED
> +static ssize_t queue_group_requests_show(struct request_queue *q, char *=
page)
> +{
> + =A0 =A0 =A0 return queue_var_show(q->nr_group_requests, (page));
> +}
> +
> +static ssize_t
> +queue_group_requests_store(struct request_queue *q, const char *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 size_t count)
> +{
> + =A0 =A0 =A0 unsigned long nr;
> + =A0 =A0 =A0 int ret =3D queue_var_store(&nr, page, count);
> + =A0 =A0 =A0 if (nr < BLKDEV_MIN_RQ)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr =3D BLKDEV_MIN_RQ;
> +
> + =A0 =A0 =A0 spin_lock_irq(q->queue_lock);
> + =A0 =A0 =A0 q->nr_group_requests =3D nr;
> + =A0 =A0 =A0 spin_unlock_irq(q->queue_lock);
> + =A0 =A0 =A0 return ret;
> +}
> +#endif
>
> =A0static ssize_t queue_ra_show(struct request_queue *q, char *page)
> =A0{
> @@ -228,6 +251,14 @@ static struct queue_sysfs_entry queue_re
> =A0 =A0 =A0 =A0.store =3D queue_requests_store,
> =A0};
>
> +#ifdef CONFIG_GROUP_IOSCHED
> +static struct queue_sysfs_entry queue_group_requests_entry =3D {
> + =A0 =A0 =A0 .attr =3D {.name =3D "nr_group_requests", .mode =3D S_IRUGO=
 | S_IWUSR },
> + =A0 =A0 =A0 .show =3D queue_group_requests_show,
> + =A0 =A0 =A0 .store =3D queue_group_requests_store,
> +};
> +#endif
> +
> =A0static struct queue_sysfs_entry queue_ra_entry =3D {
> =A0 =A0 =A0 =A0.attr =3D {.name =3D "read_ahead_kb", .mode =3D S_IRUGO | =
S_IWUSR },
> =A0 =A0 =A0 =A0.show =3D queue_ra_show,
> @@ -308,6 +339,9 @@ static struct queue_sysfs_entry queue_sl
>
> =A0static struct attribute *default_attrs[] =3D {
> =A0 =A0 =A0 =A0&queue_requests_entry.attr,
> +#ifdef CONFIG_GROUP_IOSCHED
> + =A0 =A0 =A0 &queue_group_requests_entry.attr,
> +#endif
> =A0 =A0 =A0 =A0&queue_ra_entry.attr,
> =A0 =A0 =A0 =A0&queue_max_hw_sectors_entry.attr,
> =A0 =A0 =A0 =A0&queue_max_sectors_entry.attr,
> @@ -389,12 +423,11 @@ static void blk_release_queue(struct kob
> =A0{
> =A0 =A0 =A0 =A0struct request_queue *q =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0container_of(kobj, struct request_queue, k=
obj);
> - =A0 =A0 =A0 struct request_list *rl =3D &q->rq;
>
> =A0 =A0 =A0 =A0blk_sync_queue(q);
>
> - =A0 =A0 =A0 if (rl->rq_pool)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mempool_destroy(rl->rq_pool);
> + =A0 =A0 =A0 if (q->rq_data.rq_pool)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mempool_destroy(q->rq_data.rq_pool);
>
> =A0 =A0 =A0 =A0if (q->queue_tags)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__blk_queue_free_tags(q);
> Index: linux9/block/blk-settings.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux9.orig/block/blk-settings.c =A0 =A02009-04-30 15:43:53.000000000=
 -0400
> +++ linux9/block/blk-settings.c 2009-04-30 16:18:29.000000000 -0400
> @@ -123,6 +123,9 @@ void blk_queue_make_request(struct reque
> =A0 =A0 =A0 =A0 * set defaults
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0q->nr_requests =3D BLKDEV_MAX_RQ;
> +#ifdef CONFIG_GROUP_IOSCHED
> + =A0 =A0 =A0 q->nr_group_requests =3D BLKDEV_MAX_GROUP_RQ;
> +#endif
> =A0 =A0 =A0 =A0blk_queue_max_phys_segments(q, MAX_PHYS_SEGMENTS);
> =A0 =A0 =A0 =A0blk_queue_max_hw_segments(q, MAX_HW_SEGMENTS);
> =A0 =A0 =A0 =A0blk_queue_segment_boundary(q, BLK_SEG_BOUNDARY_MASK);
> Index: linux9/block/elevator-fq.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux9.orig/block/elevator-fq.c =A0 =A0 2009-04-30 16:18:27.000000000=
 -0400
> +++ linux9/block/elevator-fq.c =A02009-04-30 16:18:29.000000000 -0400
> @@ -954,6 +954,17 @@ struct io_cgroup *cgroup_to_io_cgroup(st
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct io_cgroup, =
css);
> =A0}
>
> +struct request_list *io_group_get_request_list(struct request_queue *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct bio *bio)
> +{
> + =A0 =A0 =A0 struct io_group *iog;
> +
> + =A0 =A0 =A0 iog =3D io_get_io_group_bio(q, bio, 1);
> + =A0 =A0 =A0 BUG_ON(!iog);
> +out:
> + =A0 =A0 =A0 return &iog->rl;
> +}
> +
> =A0/*
> =A0* Search the bfq_group for bfqd into the hash table (by now only a lis=
t)
> =A0* of bgrp. =A0Must be called under rcu_read_lock().
> @@ -1203,6 +1214,8 @@ struct io_group *io_group_chain_alloc(st
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0io_group_init_entity(iocg, iog);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iog->my_entity =3D &iog->entity;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_init_request_list(&iog->rl);
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (leaf =3D=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0leaf =3D iog;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prev =3D leaf;
> @@ -1446,6 +1459,8 @@ struct io_group *io_alloc_root_group(str
> =A0 =A0 =A0 =A0for (i =3D 0; i < IO_IOPRIO_CLASSES; i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iog->sched_data.service_tree[i] =3D IO_SER=
VICE_TREE_INIT;
>
> + =A0 =A0 =A0 blk_init_request_list(&iog->rl);
> +
> =A0 =A0 =A0 =A0iocg =3D &io_root_cgroup;
> =A0 =A0 =A0 =A0spin_lock_irq(&iocg->lock);
> =A0 =A0 =A0 =A0rcu_assign_pointer(iog->key, key);
> Index: linux9/block/elevator-fq.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux9.orig/block/elevator-fq.h =A0 =A0 2009-04-30 16:18:27.000000000=
 -0400
> +++ linux9/block/elevator-fq.h =A02009-04-30 16:18:29.000000000 -0400
> @@ -239,8 +239,14 @@ struct io_group {
>
> =A0 =A0 =A0 =A0/* Single ioq per group, used for noop, deadline, anticipa=
tory */
> =A0 =A0 =A0 =A0struct io_queue *ioq;
> +
> + =A0 =A0 =A0 /* request list associated with the group */
> + =A0 =A0 =A0 struct request_list rl;
> =A0};
>
> +#define IOG_FLAG_READFULL =A0 =A0 =A01 =A0 =A0 =A0 /* read queue has bee=
n filled */
> +#define IOG_FLAG_WRITEFULL =A0 =A0 2 =A0 =A0 =A0 /* write queue has been=
 filled */
> +
> =A0/**
> =A0* struct bfqio_cgroup - bfq cgroup data structure.
> =A0* @css: subsystem state for bfq in the containing cgroup.
> @@ -517,6 +523,8 @@ extern void elv_fq_unset_request_ioq(str
> =A0extern struct io_queue *elv_lookup_ioq_current(struct request_queue *q=
);
> =A0extern struct io_queue *elv_lookup_ioq_bio(struct request_queue *q,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0struct bio *bio);
> +extern struct request_list *io_group_get_request_list(struct request_que=
ue *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct bio *bio);
>
> =A0/* Returns single ioq associated with the io group. */
> =A0static inline struct io_queue *io_group_ioq(struct io_group *iog)
>
> Thanks
> Vivek
>
>> Signed-off-by: Munehiro "Muuhh" Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
>> ---
>> block/blk-core.c =A0 =A0| =A0 36 +++++++--
>> block/blk-sysfs.c =A0 | =A0 22 ++++--
>> block/elevator-fq.c | =A0133 ++++++++++++++++++++++++++++++++--
>> block/elevator-fq.h | =A0201 +++++++++++++++++++++++++++++++++++++++++++=
++++++++
>> 4 files changed, 371 insertions(+), 21 deletions(-)
>>
>> diff --git a/block/blk-core.c b/block/blk-core.c
>> index 29bcfac..21023f7 100644
>> --- a/block/blk-core.c
>> +++ b/block/blk-core.c
>> @@ -705,11 +705,15 @@ static void ioc_set_batching(struct request_queue =
*q, struct io_context *ioc)
>> static void __freed_request(struct request_queue *q, int rw)
>> {
>> =A0 =A0 =A0 struct request_list *rl =3D &q->rq;
>> -
>> - =A0 =A0 if (rl->count[rw] < queue_congestion_off_threshold(q))
>> + =A0 =A0 struct io_group *congested_iog, *full_iog;
>> +
>> + =A0 =A0 congested_iog =3D io_congested_io_group(q, rw);
>> + =A0 =A0 if (rl->count[rw] < queue_congestion_off_threshold(q) &&
>> + =A0 =A0 =A0 =A0 !congested_iog)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_clear_queue_congested(q, rw);
>>
>> - =A0 =A0 if (rl->count[rw] + 1 <=3D q->nr_requests) {
>> + =A0 =A0 full_iog =3D io_full_io_group(q, rw);
>> + =A0 =A0 if (rl->count[rw] + 1 <=3D q->nr_requests && !full_iog) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (waitqueue_active(&rl->wait[rw]))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up(&rl->wait[rw]);
>>
>> @@ -721,13 +725,16 @@ static void __freed_request(struct request_queue *=
q, int rw)
>> =A0* A request has just been released. =A0Account for it, update the ful=
l and
>> =A0* congestion status, wake up any waiters. =A0 Called under q->queue_l=
ock.
>> =A0*/
>> -static void freed_request(struct request_queue *q, int rw, int priv)
>> +static void freed_request(struct request_queue *q, struct io_group *iog,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int rw, int priv)
>> {
>> =A0 =A0 =A0 struct request_list *rl =3D &q->rq;
>>
>> =A0 =A0 =A0 rl->count[rw]--;
>> =A0 =A0 =A0 if (priv)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 rl->elvpriv--;
>> + =A0 =A0 if (iog)
>> + =A0 =A0 =A0 =A0 =A0 =A0 io_group_dec_count(iog, rw);
>>
>> =A0 =A0 =A0 __freed_request(q, rw);
>>
>> @@ -746,16 +753,21 @@ static struct request *get_request(struct request_=
queue *q, int rw_flags,
>> {
>> =A0 =A0 =A0 struct request *rq =3D NULL;
>> =A0 =A0 =A0 struct request_list *rl =3D &q->rq;
>> + =A0 =A0 struct io_group *iog;
>> =A0 =A0 =A0 struct io_context *ioc =3D NULL;
>> =A0 =A0 =A0 const int rw =3D rw_flags & 0x01;
>> =A0 =A0 =A0 int may_queue, priv;
>>
>> + =A0 =A0 iog =3D __io_get_io_group(q);
>> +
>> =A0 =A0 =A0 may_queue =3D elv_may_queue(q, rw_flags);
>> =A0 =A0 =A0 if (may_queue =3D=3D ELV_MQUEUE_NO)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto rq_starved;
>>
>> - =A0 =A0 if (rl->count[rw]+1 >=3D queue_congestion_on_threshold(q)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (rl->count[rw]+1 >=3D q->nr_requests) {
>> + =A0 =A0 if (rl->count[rw]+1 >=3D queue_congestion_on_threshold(q) ||
>> + =A0 =A0 =A0 =A0 io_group_congestion_on(iog, rw)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (rl->count[rw]+1 >=3D q->nr_requests ||
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 io_group_full(iog, rw)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioc =3D current_io_context(G=
FP_ATOMIC, q->node);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The queue will fill aft=
er this allocation, so set
>> @@ -789,8 +801,15 @@ static struct request *get_request(struct request_q=
ueue *q, int rw_flags,
>> =A0 =A0 =A0 if (rl->count[rw] >=3D (3 * q->nr_requests / 2))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>
>> + =A0 =A0 if (iog)
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (io_group_count(iog, rw) >=3D
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(3 * io_group_nr_requests(iog) / 2))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> +
>> =A0 =A0 =A0 rl->count[rw]++;
>> =A0 =A0 =A0 rl->starved[rw] =3D 0;
>> + =A0 =A0 if (iog)
>> + =A0 =A0 =A0 =A0 =A0 =A0 io_group_inc_count(iog, rw);
>>
>> =A0 =A0 =A0 priv =3D !test_bit(QUEUE_FLAG_ELVSWITCH, &q->queue_flags);
>> =A0 =A0 =A0 if (priv)
>> @@ -808,7 +827,7 @@ static struct request *get_request(struct request_qu=
eue *q, int rw_flags,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* wait queue, but this is pretty rare.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(q->queue_lock);
>> - =A0 =A0 =A0 =A0 =A0 =A0 freed_request(q, rw, priv);
>> + =A0 =A0 =A0 =A0 =A0 =A0 freed_request(q, iog, rw, priv);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* in the very unlikely event that allocat=
ion failed and no
>> @@ -1073,12 +1092,13 @@ void __blk_put_request(struct request_queue *q, =
struct request *req)
>> =A0 =A0 =A0 if (req->cmd_flags & REQ_ALLOCED) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 int rw =3D rq_data_dir(req);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 int priv =3D req->cmd_flags & REQ_ELVPRIV;
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct io_group *iog =3D io_request_io_group(r=
eq);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(!list_empty(&req->queuelist));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(!hlist_unhashed(&req->hash));
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_free_request(q, req);
>> - =A0 =A0 =A0 =A0 =A0 =A0 freed_request(q, rw, priv);
>> + =A0 =A0 =A0 =A0 =A0 =A0 freed_request(q, iog, rw, priv);
>> =A0 =A0 =A0 }
>> }
>> EXPORT_SYMBOL_GPL(__blk_put_request);
>> diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
>> index 0d98c96..af5191c 100644
>> --- a/block/blk-sysfs.c
>> +++ b/block/blk-sysfs.c
>> @@ -40,6 +40,7 @@ queue_requests_store(struct request_queue *q, const ch=
ar *page, size_t count)
>> {
>> =A0 =A0 =A0 struct request_list *rl =3D &q->rq;
>> =A0 =A0 =A0 unsigned long nr;
>> + =A0 =A0 int iog_congested[2], iog_full[2];
>> =A0 =A0 =A0 int ret =3D queue_var_store(&nr, page, count);
>> =A0 =A0 =A0 if (nr < BLKDEV_MIN_RQ)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr =3D BLKDEV_MIN_RQ;
>> @@ -47,27 +48,32 @@ queue_requests_store(struct request_queue *q, const =
char *page, size_t count)
>> =A0 =A0 =A0 spin_lock_irq(q->queue_lock);
>> =A0 =A0 =A0 q->nr_requests =3D nr;
>> =A0 =A0 =A0 blk_queue_congestion_threshold(q);
>> + =A0 =A0 io_group_set_nrq_all(q, nr, iog_congested, iog_full);
>>
>> - =A0 =A0 if (rl->count[READ] >=3D queue_congestion_on_threshold(q))
>> + =A0 =A0 if (rl->count[READ] >=3D queue_congestion_on_threshold(q) ||
>> + =A0 =A0 =A0 =A0 iog_congested[READ])
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_set_queue_congested(q, READ);
>> - =A0 =A0 else if (rl->count[READ] < queue_congestion_off_threshold(q))
>> + =A0 =A0 else if (rl->count[READ] < queue_congestion_off_threshold(q) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0!iog_congested[READ])
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_clear_queue_congested(q, READ);
>>
>> - =A0 =A0 if (rl->count[WRITE] >=3D queue_congestion_on_threshold(q))
>> + =A0 =A0 if (rl->count[WRITE] >=3D queue_congestion_on_threshold(q) ||
>> + =A0 =A0 =A0 =A0 iog_congested[WRITE])
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_set_queue_congested(q, WRITE);
>> - =A0 =A0 else if (rl->count[WRITE] < queue_congestion_off_threshold(q))
>> + =A0 =A0 else if (rl->count[WRITE] < queue_congestion_off_threshold(q) =
&&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0!iog_congested[WRITE])
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_clear_queue_congested(q, WRITE);
>>
>> - =A0 =A0 if (rl->count[READ] >=3D q->nr_requests) {
>> + =A0 =A0 if (rl->count[READ] >=3D q->nr_requests || iog_full[READ]) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_set_queue_full(q, READ);
>> - =A0 =A0 } else if (rl->count[READ]+1 <=3D q->nr_requests) {
>> + =A0 =A0 } else if (rl->count[READ]+1 <=3D q->nr_requests && !iog_full[=
READ]) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_clear_queue_full(q, READ);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up(&rl->wait[READ]);
>> =A0 =A0 =A0 }
>>
>> - =A0 =A0 if (rl->count[WRITE] >=3D q->nr_requests) {
>> + =A0 =A0 if (rl->count[WRITE] >=3D q->nr_requests || iog_full[WRITE]) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_set_queue_full(q, WRITE);
>> - =A0 =A0 } else if (rl->count[WRITE]+1 <=3D q->nr_requests) {
>> + =A0 =A0 } else if (rl->count[WRITE]+1 <=3D q->nr_requests && !iog_full=
[WRITE]) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_clear_queue_full(q, WRITE);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up(&rl->wait[WRITE]);
>> =A0 =A0 =A0 }
>> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
>> index df53418..3b021f3 100644
>> --- a/block/elevator-fq.c
>> +++ b/block/elevator-fq.c
>> @@ -924,6 +924,111 @@ struct io_group *io_lookup_io_group_current(struct=
 request_queue *q)
>> }
>> EXPORT_SYMBOL(io_lookup_io_group_current);
>>
>> +/*
>> + * TODO
>> + * This is complete dupulication of blk_queue_congestion_threshold()
>> + * except for the argument type and name. =A0Can we merge them?
>> + */
>> +static void io_group_nrq_congestion_threshold(struct io_group_nrq *nrq)
>> +{
>> + =A0 =A0 int nr;
>> +
>> + =A0 =A0 nr =3D nrq->nr_requests - (nrq->nr_requests / 8) + 1;
>> + =A0 =A0 if (nr > nrq->nr_requests)
>> + =A0 =A0 =A0 =A0 =A0 =A0 nr =3D nrq->nr_requests;
>> + =A0 =A0 nrq->nr_congestion_on =3D nr;
>> +
>> + =A0 =A0 nr =3D nrq->nr_requests - (nrq->nr_requests / 8)
>> + =A0 =A0 =A0 =A0 =A0 =A0 - (nrq->nr_requests / 16) - 1;
>> + =A0 =A0 if (nr < 1)
>> + =A0 =A0 =A0 =A0 =A0 =A0 nr =3D 1;
>> + =A0 =A0 nrq->nr_congestion_off =3D nr;
>> +}
>> +
>> +static void io_group_set_nrq(struct io_group_nrq *nrq, int nr_requests,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int *congested, int *full)
>> +{
>> + =A0 =A0 int i;
>> +
>> + =A0 =A0 BUG_ON(nr_requests < 0);
>> +
>> + =A0 =A0 nrq->nr_requests =3D nr_requests;
>> + =A0 =A0 io_group_nrq_congestion_threshold(nrq);
>> +
>> + =A0 =A0 for (i=3D0; i<2; i++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (nrq->count[i] >=3D nrq->nr_congestion_on)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congested[i] =3D 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 else if (nrq->count[i] < nrq->nr_congestion_of=
f)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congested[i] =3D 0;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (nrq->count[i] >=3D nrq->nr_requests)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 full[i] =3D 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 else if (nrq->count[i]+1 <=3D nrq->nr_requests)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 full[i] =3D 0;
>> + =A0 =A0 }
>> +}
>> +
>> +void io_group_set_nrq_all(struct request_queue *q, int nr,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int *congested, int *f=
ull)
>> +{
>> + =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
>> + =A0 =A0 struct hlist_head *head =3D &efqd->group_list;
>> + =A0 =A0 struct io_group *root =3D efqd->root_group;
>> + =A0 =A0 struct hlist_node *n;
>> + =A0 =A0 struct io_group *iog;
>> + =A0 =A0 struct io_group_nrq *nrq;
>> + =A0 =A0 int nrq_congested[2];
>> + =A0 =A0 int nrq_full[2];
>> + =A0 =A0 int i;
>> +
>> + =A0 =A0 for (i=3D0; i<2; i++)
>> + =A0 =A0 =A0 =A0 =A0 =A0 *(congested + i) =3D *(full + i) =3D 0;
>> +
>> + =A0 =A0 nrq =3D &root->nrq;
>> + =A0 =A0 io_group_set_nrq(nrq, nr, nrq_congested, nrq_full);
>> + =A0 =A0 for (i=3D0; i<2; i++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 *(congested + i) |=3D nrq_congested[i];
>> + =A0 =A0 =A0 =A0 =A0 =A0 *(full + i) |=3D nrq_full[i];
>> + =A0 =A0 }
>> +
>> + =A0 =A0 hlist_for_each_entry(iog, n, head, elv_data_node) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 nrq =3D &iog->nrq;
>> + =A0 =A0 =A0 =A0 =A0 =A0 io_group_set_nrq(nrq, nr, nrq_congested, nrq_f=
ull);
>> + =A0 =A0 =A0 =A0 =A0 =A0 for (i=3D0; i<2; i++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *(congested + i) |=3D nrq_cong=
ested[i];
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *(full + i) |=3D nrq_full[i];
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 }
>> +}
>> +
>> +struct io_group *io_congested_io_group(struct request_queue *q, int rw)
>> +{
>> + =A0 =A0 struct hlist_head *head =3D &q->elevator->efqd.group_list;
>> + =A0 =A0 struct hlist_node *n;
>> + =A0 =A0 struct io_group *iog;
>> +
>> + =A0 =A0 hlist_for_each_entry(iog, n, head, elv_data_node) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct io_group_nrq *nrq =3D &iog->nrq;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (nrq->count[rw] >=3D nrq->nr_congestion_off)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return iog;
>> + =A0 =A0 }
>> + =A0 =A0 return NULL;
>> +}
>> +
>> +struct io_group *io_full_io_group(struct request_queue *q, int rw)
>> +{
>> + =A0 =A0 struct hlist_head *head =3D &q->elevator->efqd.group_list;
>> + =A0 =A0 struct hlist_node *n;
>> + =A0 =A0 struct io_group *iog;
>> +
>> + =A0 =A0 hlist_for_each_entry(iog, n, head, elv_data_node) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct io_group_nrq *nrq =3D &iog->nrq;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (nrq->count[rw] >=3D nrq->nr_requests)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return iog;
>> + =A0 =A0 }
>> + =A0 =A0 return NULL;
>> +}
>> +
>> void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
>> {
>> =A0 =A0 =A0 struct io_entity *entity =3D &iog->entity;
>> @@ -934,6 +1039,12 @@ void io_group_init_entity(struct io_cgroup *iocg, =
struct io_group *iog)
>> =A0 =A0 =A0 entity->my_sched_data =3D &iog->sched_data;
>> }
>>
>> +static void io_group_init_nrq(struct request_queue *q, struct io_group_=
nrq *nrq)
>> +{
>> + =A0 =A0 nrq->nr_requests =3D q->nr_requests;
>> + =A0 =A0 io_group_nrq_congestion_threshold(nrq);
>> +}
>> +
>> void io_group_set_parent(struct io_group *iog, struct io_group *parent)
>> {
>> =A0 =A0 =A0 struct io_entity *entity;
>> @@ -1053,6 +1164,8 @@ struct io_group *io_group_chain_alloc(struct reque=
st_queue *q, void *key,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 io_group_init_entity(iocg, iog);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 iog->my_entity =3D &iog->entity;
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 io_group_init_nrq(q, &iog->nrq);
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (leaf =3D=3D NULL) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 leaf =3D iog;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 prev =3D leaf;
>> @@ -1176,7 +1289,7 @@ struct io_group *io_find_alloc_group(struct reques=
t_queue *q,
>> =A0* Generic function to make sure cgroup hierarchy is all setup once a =
request
>> =A0* from a cgroup is received by the io scheduler.
>> =A0*/
>> -struct io_group *io_get_io_group(struct request_queue *q)
>> +struct io_group *__io_get_io_group(struct request_queue *q)
>> {
>> =A0 =A0 =A0 struct cgroup *cgroup;
>> =A0 =A0 =A0 struct io_group *iog;
>> @@ -1192,6 +1305,19 @@ struct io_group *io_get_io_group(struct request_q=
ueue *q)
>> =A0 =A0 =A0 return iog;
>> }
>>
>> +struct io_group *io_get_io_group(struct request_queue *q)
>> +{
>> + =A0 =A0 struct io_group *iog;
>> + =A0 =A0 unsigned long flags;
>> +
>> + =A0 =A0 spin_lock_irqsave(q->queue_lock, flags);
>> + =A0 =A0 iog =3D __io_get_io_group(q);
>> + =A0 =A0 spin_unlock_irqrestore(q->queue_lock, flags);
>> + =A0 =A0 BUG_ON(!iog);
>> +
>> + =A0 =A0 return iog;
>> +}
>> +
>> void io_free_root_group(struct elevator_queue *e)
>> {
>> =A0 =A0 =A0 struct io_cgroup *iocg =3D &io_root_cgroup;
>> @@ -1220,6 +1346,7 @@ struct io_group *io_alloc_root_group(struct reques=
t_queue *q,
>> =A0 =A0 =A0 iog->entity.parent =3D NULL;
>> =A0 =A0 =A0 for (i =3D 0; i < IO_IOPRIO_CLASSES; i++)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 iog->sched_data.service_tree[i] =3D IO_SERVI=
CE_TREE_INIT;
>> + =A0 =A0 io_group_init_nrq(q, &iog->nrq);
>>
>> =A0 =A0 =A0 iocg =3D &io_root_cgroup;
>> =A0 =A0 =A0 spin_lock_irq(&iocg->lock);
>> @@ -1533,15 +1660,11 @@ void elv_fq_set_request_io_group(struct request_=
queue *q,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct request *rq)
>> {
>> =A0 =A0 =A0 struct io_group *iog;
>> - =A0 =A0 unsigned long flags;
>>
>> =A0 =A0 =A0 /* Make sure io group hierarchy has been setup and also set =
the
>> =A0 =A0 =A0 =A0* io group to which rq belongs. Later we should make use =
of
>> =A0 =A0 =A0 =A0* bio cgroup patches to determine the io group */
>> - =A0 =A0 spin_lock_irqsave(q->queue_lock, flags);
>> =A0 =A0 =A0 iog =3D io_get_io_group(q);
>> - =A0 =A0 spin_unlock_irqrestore(q->queue_lock, flags);
>> - =A0 =A0 BUG_ON(!iog);
>>
>> =A0 =A0 =A0 /* Store iog in rq. TODO: take care of referencing */
>> =A0 =A0 =A0 rq->iog =3D iog;
>> diff --git a/block/elevator-fq.h b/block/elevator-fq.h
>> index fc4110d..f8eabd4 100644
>> --- a/block/elevator-fq.h
>> +++ b/block/elevator-fq.h
>> @@ -187,6 +187,22 @@ struct io_queue {
>>
>> #ifdef CONFIG_GROUP_IOSCHED
>> /**
>> + * struct io_group_nrq - structure to store allocated requests info
>> + * @nr_requests: maximun num of requests for the io_group
>> + * @nr_congestion_on: threshold to determin the io_group is cogested.
>> + * @nr_congestion_off: threshold to determin the io_group is not conges=
ted.
>> + * @count: num of allocated requests.
>> + *
>> + * All fields are protected by queue_lock.
>> + */
>> +struct io_group_nrq {
>> + =A0 =A0 unsigned long nr_requests;
>> + =A0 =A0 unsigned int nr_congestion_on;
>> + =A0 =A0 unsigned int nr_congestion_off;
>> + =A0 =A0 int count[2];
>> +};
>> +
>> +/**
>> =A0* struct bfq_group - per (device, cgroup) data structure.
>> =A0* @entity: schedulable entity to insert into the parent group sched_d=
ata.
>> =A0* @sched_data: own sched_data, to contain child entities (they may be
>> @@ -235,6 +251,8 @@ struct io_group {
>>
>> =A0 =A0 =A0 /* Single ioq per group, used for noop, deadline, anticipato=
ry */
>> =A0 =A0 =A0 struct io_queue *ioq;
>> +
>> + =A0 =A0 struct io_group_nrq nrq;
>> };
>>
>> /**
>> @@ -469,6 +487,11 @@ extern int elv_fq_set_request_ioq(struct request_qu=
eue *q, struct request *rq,
>> extern void elv_fq_unset_request_ioq(struct request_queue *q,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct request *rq);
>> extern struct io_queue *elv_lookup_ioq_current(struct request_queue *q);
>> +extern void io_group_set_nrq_all(struct request_queue *q, int nr,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int *congested, int *f=
ull);
>> +extern struct io_group *io_congested_io_group(struct request_queue *q, =
int rw);
>> +extern struct io_group *io_full_io_group(struct request_queue *q, int r=
w);
>> +extern struct io_group *__io_get_io_group(struct request_queue *q);
>>
>> /* Returns single ioq associated with the io group. */
>> static inline struct io_queue *io_group_ioq(struct io_group *iog)
>> @@ -486,6 +509,52 @@ static inline void io_group_set_ioq(struct io_group=
 *iog, struct io_queue *ioq)
>> =A0 =A0 =A0 iog->ioq =3D ioq;
>> }
>>
>> +static inline struct io_group *io_request_io_group(struct request *rq)
>> +{
>> + =A0 =A0 return rq->iog;
>> +}
>> +
>> +static inline unsigned long io_group_nr_requests(struct io_group *iog)
>> +{
>> + =A0 =A0 BUG_ON(!iog);
>> + =A0 =A0 return iog->nrq.nr_requests;
>> +}
>> +
>> +static inline int io_group_inc_count(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 BUG_ON(!iog);
>> + =A0 =A0 return iog->nrq.count[rw]++;
>> +}
>> +
>> +static inline int io_group_dec_count(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 BUG_ON(!iog);
>> + =A0 =A0 return iog->nrq.count[rw]--;
>> +}
>> +
>> +static inline int io_group_count(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 BUG_ON(!iog);
>> + =A0 =A0 return iog->nrq.count[rw];
>> +}
>> +
>> +static inline int io_group_congestion_on(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 BUG_ON(!iog);
>> + =A0 =A0 return iog->nrq.count[rw] + 1 >=3D iog->nrq.nr_congestion_on;
>> +}
>> +
>> +static inline int io_group_congestion_off(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 BUG_ON(!iog);
>> + =A0 =A0 return iog->nrq.count[rw] < iog->nrq.nr_congestion_off;
>> +}
>> +
>> +static inline int io_group_full(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 BUG_ON(!iog);
>> + =A0 =A0 return iog->nrq.count[rw] + 1 >=3D iog->nrq.nr_requests;
>> +}
>> #else /* !GROUP_IOSCHED */
>> /*
>> =A0* No ioq movement is needed in case of flat setup. root io group gets=
 cleaned
>> @@ -537,6 +606,71 @@ static inline struct io_queue *elv_lookup_ioq_curre=
nt(struct request_queue *q)
>> =A0 =A0 =A0 return NULL;
>> }
>>
>> +static inline void io_group_set_nrq_all(struct request_queue *q, int nr,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 int *congested, int *full)
>> +{
>> + =A0 =A0 int i;
>> + =A0 =A0 for (i=3D0; i<2; i++)
>> + =A0 =A0 =A0 =A0 =A0 =A0 *(congested + i) =3D *(full + i) =3D 0;
>> +}
>> +
>> +static inline struct io_group *
>> +io_congested_io_group(struct request_queue *q, int rw)
>> +{
>> + =A0 =A0 return NULL;
>> +}
>> +
>> +static inline struct io_group *
>> +io_full_io_group(struct request_queue *q, int rw)
>> +{
>> + =A0 =A0 return NULL;
>> +}
>> +
>> +static inline struct io_group *__io_get_io_group(struct request_queue *=
q)
>> +{
>> + =A0 =A0 return NULL;
>> +}
>> +
>> +static inline struct io_group *io_request_io_group(struct request *rq)
>> +{
>> + =A0 =A0 return NULL;
>> +}
>> +
>> +static inline unsigned long io_group_nr_requests(struct io_group *iog)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline int io_group_inc_count(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline int io_group_dec_count(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline int io_group_count(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline int io_group_congestion_on(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline int io_group_congestion_off(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 return 1;
>> +}
>> +
>> +static inline int io_group_full(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> #endif /* GROUP_IOSCHED */
>>
>> /* Functions used by blksysfs.c */
>> @@ -589,6 +723,9 @@ extern void elv_free_ioq(struct io_queue *ioq);
>>
>> #else /* CONFIG_ELV_FAIR_QUEUING */
>>
>> +struct io_group {
>> +};
>> +
>> static inline int elv_init_fq_data(struct request_queue *q,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct elevator_queue *e)
>> {
>> @@ -655,5 +792,69 @@ static inline struct io_queue *elv_lookup_ioq_curre=
nt(struct request_queue *q)
>> =A0 =A0 =A0 return NULL;
>> }
>>
>> +static inline void io_group_set_nrq_all(struct request_queue *q, int nr,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 int *congested, int *full)
>> +{
>> + =A0 =A0 int i;
>> + =A0 =A0 for (i=3D0; i<2; i++)
>> + =A0 =A0 =A0 =A0 =A0 =A0 *(congested + i) =3D *(full + i) =3D 0;
>> +}
>> +
>> +static inline struct io_group *
>> +io_congested_io_group(struct request_queue *q, int rw)
>> +{
>> + =A0 =A0 return NULL;
>> +}
>> +
>> +static inline struct io_group *
>> +io_full_io_group(struct request_queue *q, int rw)
>> +{
>> + =A0 =A0 return NULL;
>> +}
>> +
>> +static inline struct io_group *__io_get_io_group(struct request_queue *=
q)
>> +{
>> + =A0 =A0 return NULL;
>> +}
>> +
>> +static inline struct io_group *io_request_io_group(struct request *rq)
>> +{
>> + =A0 =A0 return NULL;
>> +}
>> +
>> +static inline unsigned long io_group_nr_requests(struct io_group *iog)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline int io_group_inc_count(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline int io_group_dec_count(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline int io_group_count(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline int io_group_congestion_on(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline int io_group_congestion_off(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 return 1;
>> +}
>> +
>> +static inline int io_group_full(struct io_group *iog, int rw)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> #endif /* CONFIG_ELV_FAIR_QUEUING */
>> #endif /* _BFQ_SCHED_H */
>> --
>> 1.5.4.3
>>
>>
>> --
>> IKEDA, Munehiro
>> NEC Corporation of America
>> =A0 m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org
>>
>
