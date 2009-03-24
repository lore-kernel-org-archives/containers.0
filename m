From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Mon, 23 Mar 2009 22:32:41 -0700
Message-ID: <e98e18940903232232i432f62c5r9dfd74268e1b2684__9411.99149606309$1237873043$gmane$org@mail.gmail.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090312100054.GA8024@linux.vnet.ibm.com>
	<20090312140450.GE10919@redhat.com> <49C0A171.8060009@cn.fujitsu.com>
	<20090318215529.GA3338@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090318215529.GA3338-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Mar 18, 2009 at 2:55 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Wed, Mar 18, 2009 at 03:23:29PM +0800, Gui Jianfeng wrote:
>> Vivek Goyal wrote:
>> >> Hi Vivek,
>> >>
>> >> I would be interested in knowing if these are the results expected?
>> >>
>> >
>> > Hi Dhaval,
>> >
>> > Good question. Keeping current expectation in mind, yes these are expe=
cted
>> > results. To begin with, current expectations are that try to emulate
>> > cfq behavior and the kind of service differentiation we get between
>> > threads of different priority, same kind of service differentiation we
>> > should get from different cgroups.
>> >
>> > Having said that, in theory a more accurate estimate should be amount
>> > of actual disk time a queue/cgroup got. I have put a tracing message
>> > to keep track of total service received by a queue. If you run "blktra=
ce"
>> > then you can see that. Ideally, total service received by two threads
>> > over a period of time should be in same proportion as their cgroup
>> > weights.
>> >
>> > It will not be easy to achive it given the constraints we have got in
>> > terms of how to accurately we can account for disk time actually used =
by a
>> > queue in certain situations. So to begin with I am targetting that
>> > try to meet same kind of service differentation between cgroups as
>> > cfq provides between threads and then slowly refine it to see how
>> > close one can come to get accurate numbers in terms of "total_serivce"
>> > received by each queue.
>>
>> =A0 Hi Vivek,
>>
>> =A0 I simply tested with blktrace opened. I create two groups and set io=
prio
>> =A0 4 and 7 respectively(the corresponding weight should 4:1, right?),
>
> Hi Gui,
>
> Thanks for testing. You are right about weight proportions.
>
>> and
>> =A0 start two dd concurrently. UUIC, Ideally, the proportion of service =
two
>> =A0 dd got should be 4:1 in a period of time when they are running. I ex=
tract
>> =A0 *served* value from blktrace output and sum them up. I found the pro=
portion
>> =A0 of the sum of *served* value is about 1.7:1
>> =A0 Am i missing something?
>
> Actually getting the service proportion in same ratio as weight proportion
> is quite hard for sync queues. The biggest issue is that many a times sync
> queues are not continuously backlogged and they do some IO and then dispa=
tch
> a next round of requests.
>
> Most of the time idling seems to be the solution for giving an impression
> that sync queue is continuously backlogged but it also has potential to
> reduce throughput on faster hardware.
>
> Anyway, can you please send me your complete blkparse output. There are
> many a places where code has been designed to favor throughput than
> fairness. Looking at your blkparse output, will give me better idea what's
> the issue in your setup.
>
> Also please try the attached patch. I have experimented with waiting for
> new request to come before sync queue is expired. It helps me in getting
> the fairness numbers at least with noop on non-queueing rotational media.
>
> I also have introduced a new tunable "fairness". Above code will kick in
> only if this variable is set to 1. Many a places where we favor throughput
> over fairness, I plan to use this variable as condition to let user
> decide whether to choose fairness over throughput. I am not sure at how m=
any
> places it really makes sense, but it atleast gives us something to play a=
nd
> compare the throughput in two cases.
>
> This patch applies on my current tree after removing tomost patceh
> "anticipatory scheduling changes". My code has changed a bit since the
> posting, so you might have to message this patch a bit.
>
> Thanks
> Vivek
>
>
> DESC
> io-controller: idle for sometime on sync queue before expiring it
> EDESC
>
> o When a sync queue expires, in many cases it might be empty and then
> =A0it will be deleted from the active tree. This will lead to a scenario
> =A0where out of two competing queues, only one is on the tree and when a
> =A0new queue is selected, vtime jump takes place and we don't see services
> =A0provided in proportion to weight.
>
> o In general this is a fundamental problem with fairness of sync queues
> =A0where queues are not continuously backlogged. Looks like idling is
> =A0only solution to make sure such kind of queues can get some decent amo=
unt
> =A0of disk bandwidth in the face of competion from continusouly backlogged
> =A0queues. But excessive idling has potential to reduce performance on SSD
> =A0and disks with commnad queuing.
>
> o This patch experiments with waiting for next request to come before a
> =A0queue is expired after it has consumed its time slice. This can ensure
> =A0more accurate fairness numbers in some cases.

Vivek, have you introduced this option just to play with it, or you
are planning to make it a part of the patch set. Waiting for a new
request to come before expiring time slice sounds problematic.

>
> o Introduced a tunable "fairness". If set, io-controller will put more
> =A0focus on getting fairness right than getting throughput right.
>
>
> ---
> =A0block/blk-sysfs.c =A0 | =A0 =A07 ++++
> =A0block/elevator-fq.c | =A0 85 +++++++++++++++++++++++++++++++++++++++++=
++++-------
> =A0block/elevator-fq.h | =A0 12 +++++++
> =A03 files changed, 94 insertions(+), 10 deletions(-)
>
> Index: linux1/block/elevator-fq.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux1.orig/block/elevator-fq.h =A0 =A0 2009-03-18 17:34:46.000000000=
 -0400
> +++ linux1/block/elevator-fq.h =A02009-03-18 17:34:53.000000000 -0400
> @@ -318,6 +318,13 @@ struct elv_fq_data {
> =A0 =A0 =A0 =A0unsigned long long rate_sampling_start; /*sampling window =
start jifies*/
> =A0 =A0 =A0 =A0/* number of sectors finished io during current sampling w=
indow */
> =A0 =A0 =A0 =A0unsigned long rate_sectors_current;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* If set to 1, will disable many optimizations done for =
boost
> + =A0 =A0 =A0 =A0* throughput and focus more on providing fairness for sy=
nc
> + =A0 =A0 =A0 =A0* queues.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 int fairness;
> =A0};
>
> =A0extern int elv_slice_idle;
> @@ -340,6 +347,7 @@ enum elv_queue_state_flags {
> =A0 =A0 =A0 =A0ELV_QUEUE_FLAG_idle_window, =A0 =A0 =A0 /* elevator slice =
idling enabled */
> =A0 =A0 =A0 =A0ELV_QUEUE_FLAG_wait_request, =A0 =A0 =A0/* waiting for a r=
equest */
> =A0 =A0 =A0 =A0ELV_QUEUE_FLAG_slice_new, =A0 =A0 =A0 =A0 /* no requests d=
ispatched in slice */
> + =A0 =A0 =A0 ELV_QUEUE_FLAG_wait_busy, =A0 =A0 =A0 =A0 /* wait for this =
queue to get busy */
> =A0 =A0 =A0 =A0ELV_QUEUE_FLAG_NR,
> =A0};
>
> @@ -362,6 +370,7 @@ ELV_IO_QUEUE_FLAG_FNS(sync)
> =A0ELV_IO_QUEUE_FLAG_FNS(wait_request)
> =A0ELV_IO_QUEUE_FLAG_FNS(idle_window)
> =A0ELV_IO_QUEUE_FLAG_FNS(slice_new)
> +ELV_IO_QUEUE_FLAG_FNS(wait_busy)
>
> =A0static inline struct io_service_tree *
> =A0io_entity_service_tree(struct io_entity *entity)
> @@ -554,6 +563,9 @@ static inline struct io_queue *elv_looku
> =A0extern ssize_t elv_slice_idle_show(struct request_queue *q, char *name=
);
> =A0extern ssize_t elv_slice_idle_store(struct request_queue *q, const cha=
r *name,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0size_t count);
> +extern ssize_t elv_fairness_show(struct request_queue *q, char *name);
> +extern ssize_t elv_fairness_store(struct request_queue *q, const char *n=
ame,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 size_t count);
>
> =A0/* Functions used by elevator.c */
> =A0extern int elv_init_fq_data(struct request_queue *q, struct elevator_q=
ueue *e);
> Index: linux1/block/elevator-fq.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux1.orig/block/elevator-fq.c =A0 =A0 2009-03-18 17:34:46.000000000=
 -0400
> +++ linux1/block/elevator-fq.c =A02009-03-18 17:34:53.000000000 -0400
> @@ -1837,6 +1837,44 @@ void elv_ioq_served(struct io_queue *ioq
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ioq->total_service);
> =A0}
>
> +/* Functions to show and store fairness value through sysfs */
> +ssize_t elv_fairness_show(struct request_queue *q, char *name)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd;
> + =A0 =A0 =A0 unsigned int data;
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(q->queue_lock, flags);
> + =A0 =A0 =A0 efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 data =3D efqd->fairness;
> + =A0 =A0 =A0 spin_unlock_irqrestore(q->queue_lock, flags);
> + =A0 =A0 =A0 return sprintf(name, "%d\n", data);
> +}
> +
> +ssize_t elv_fairness_store(struct request_queue *q, const char *name,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t count)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd;
> + =A0 =A0 =A0 unsigned int data;
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 char *p =3D (char *)name;
> +
> + =A0 =A0 =A0 data =3D simple_strtoul(p, &p, 10);
> +
> + =A0 =A0 =A0 if (data < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 data =3D 0;
> + =A0 =A0 =A0 else if (data > INT_MAX)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 data =3D INT_MAX;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(q->queue_lock, flags);
> + =A0 =A0 =A0 efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 efqd->fairness =3D data;
> + =A0 =A0 =A0 spin_unlock_irqrestore(q->queue_lock, flags);
> +
> + =A0 =A0 =A0 return count;
> +}
> +
> =A0/* Functions to show and store elv_idle_slice value through sysfs */
> =A0ssize_t elv_slice_idle_show(struct request_queue *q, char *name)
> =A0{
> @@ -2263,10 +2301,11 @@ void __elv_ioq_slice_expired(struct requ
> =A0 =A0 =A0 =A0assert_spin_locked(q->queue_lock);
> =A0 =A0 =A0 =A0elv_log_ioq(efqd, ioq, "slice expired upd=3D%d", budget_up=
date);
>
> - =A0 =A0 =A0 if (elv_ioq_wait_request(ioq))
> + =A0 =A0 =A0 if (elv_ioq_wait_request(ioq) || elv_ioq_wait_busy(ioq))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0del_timer(&efqd->idle_slice_timer);
>
> =A0 =A0 =A0 =A0elv_clear_ioq_wait_request(ioq);
> + =A0 =A0 =A0 elv_clear_ioq_wait_busy(ioq);
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * if ioq->slice_end =3D 0, that means a queue was expired=
 before first
> @@ -2482,8 +2521,9 @@ void elv_ioq_request_add(struct request_
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * immediately and flag that we must not e=
xpire this queue
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * just now
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (elv_ioq_wait_request(ioq)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (elv_ioq_wait_request(ioq) || elv_ioq_wa=
it_busy(ioq)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0del_timer(&efqd->idle_slic=
e_timer);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_clear_ioq_wait_busy(ioq=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_start_queueing(q);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0} else if (elv_should_preempt(q, ioq, rq)) {
> @@ -2519,6 +2559,9 @@ void elv_idle_slice_timer(unsigned long
>
> =A0 =A0 =A0 =A0if (ioq) {
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (elv_ioq_wait_busy(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto expire;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * expired
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> @@ -2546,7 +2589,7 @@ out_cont:
> =A0 =A0 =A0 =A0spin_unlock_irqrestore(q->queue_lock, flags);
> =A0}
>
> -void elv_ioq_arm_slice_timer(struct request_queue *q)
> +void elv_ioq_arm_slice_timer(struct request_queue *q, int wait_for_busy)
> =A0{
> =A0 =A0 =A0 =A0struct elv_fq_data *efqd =3D &q->elevator->efqd;
> =A0 =A0 =A0 =A0struct io_queue *ioq =3D elv_active_ioq(q->elevator);
> @@ -2563,15 +2606,27 @@ void elv_ioq_arm_slice_timer(struct requ
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0* still requests with the driver, don't idle
> + =A0 =A0 =A0 =A0* idle is disabled, either manually or by past process h=
istory
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (efqd->rq_in_driver)
> + =A0 =A0 =A0 if (!efqd->elv_slice_idle || !elv_ioq_idle_window(ioq))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0* idle is disabled, either manually or by past process h=
istory
> + =A0 =A0 =A0 =A0* This queue has consumed its time slice. We are waiting=
 only for
> + =A0 =A0 =A0 =A0* it to become busy before we select next queue for disp=
atch.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (!efqd->elv_slice_idle || !elv_ioq_idle_window(ioq))
> + =A0 =A0 =A0 if (efqd->fairness && wait_for_busy) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_mark_ioq_wait_busy(ioq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sl =3D efqd->elv_slice_idle;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mod_timer(&efqd->idle_slice_timer, jiffies =
+ sl);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_log(efqd, "arm idle: %lu wait busy=3D1"=
, sl);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* still requests with the driver, don't idle
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (efqd->rq_in_driver)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0/*
> @@ -2628,6 +2683,12 @@ void *elv_fq_select_ioq(struct request_q
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 /* We are waiting for this queue to become busy before it e=
xpires.*/
> + =A0 =A0 =A0 if (efqd->fairness && elv_ioq_wait_busy(ioq)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioq =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto keep_queue;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * The active queue has run out of time, expire it and sel=
ect new.
> =A0 =A0 =A0 =A0 */
> @@ -2802,10 +2863,14 @@ void elv_ioq_completed_request(struct re
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0elv_ioq_set_prio_slice(q, =
ioq);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0elv_clear_ioq_slice_new(io=
q);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (elv_ioq_slice_used(ioq) || elv_ioq_clas=
s_idle(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (elv_ioq_class_idle(ioq))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0elv_ioq_slice_expired(q, 1=
);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (sync && !ioq->nr_queued)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_ioq_arm_slice_timer(q);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (sync && !ioq->nr_queued) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (elv_ioq_slice_used(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_ioq_arm=
_slice_timer(q, 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_ioq_arm=
_slice_timer(q, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (!efqd->rq_in_driver)
> Index: linux1/block/blk-sysfs.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux1.orig/block/blk-sysfs.c =A0 =A0 =A0 2009-03-18 17:34:28.0000000=
00 -0400
> +++ linux1/block/blk-sysfs.c =A0 =A02009-03-18 17:34:53.000000000 -0400
> @@ -282,6 +282,12 @@ static struct queue_sysfs_entry queue_sl
> =A0 =A0 =A0 =A0.show =3D elv_slice_idle_show,
> =A0 =A0 =A0 =A0.store =3D elv_slice_idle_store,
> =A0};
> +
> +static struct queue_sysfs_entry queue_fairness_entry =3D {
> + =A0 =A0 =A0 .attr =3D {.name =3D "fairness", .mode =3D S_IRUGO | S_IWUS=
R },
> + =A0 =A0 =A0 .show =3D elv_fairness_show,
> + =A0 =A0 =A0 .store =3D elv_fairness_store,
> +};
> =A0#endif
> =A0static struct attribute *default_attrs[] =3D {
> =A0 =A0 =A0 =A0&queue_requests_entry.attr,
> @@ -296,6 +302,7 @@ static struct attribute *default_attrs[]
> =A0 =A0 =A0 =A0&queue_iostats_entry.attr,
> =A0#ifdef CONFIG_ELV_FAIR_QUEUING
> =A0 =A0 =A0 =A0&queue_slice_idle_entry.attr,
> + =A0 =A0 =A0 &queue_fairness_entry.attr,
> =A0#endif
> =A0 =A0 =A0 =A0NULL,
> =A0};
>
