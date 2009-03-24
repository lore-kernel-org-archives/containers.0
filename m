From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Tue, 24 Mar 2009 11:14:13 -0700
Message-ID: <e98e18940903241114u1e03ae7dhf654d7d8d0fc0302__38449.1408979104$1237918682$gmane$org@mail.gmail.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090312100054.GA8024@linux.vnet.ibm.com>
	<20090312140450.GE10919@redhat.com> <49C0A171.8060009@cn.fujitsu.com>
	<20090318215529.GA3338@redhat.com>
	<e98e18940903232232i432f62c5r9dfd74268e1b2684@mail.gmail.com>
	<20090324125842.GA21389@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090324125842.GA21389-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Tue, Mar 24, 2009 at 5:58 AM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, Mar 23, 2009 at 10:32:41PM -0700, Nauman Rafique wrote:
>
> [..]
>> > DESC
>> > io-controller: idle for sometime on sync queue before expiring it
>> > EDESC
>> >
>> > o When a sync queue expires, in many cases it might be empty and then
>> > =E1it will be deleted from the active tree. This will lead to a scenar=
io
>> > =E1where out of two competing queues, only one is on the tree and when=
 a
>> > =E1new queue is selected, vtime jump takes place and we don't see serv=
ices
>> > =E1provided in proportion to weight.
>> >
>> > o In general this is a fundamental problem with fairness of sync queues
>> > =E1where queues are not continuously backlogged. Looks like idling is
>> > =E1only solution to make sure such kind of queues can get some decent =
amount
>> > =E1of disk bandwidth in the face of competion from continusouly backlo=
gged
>> > =E1queues. But excessive idling has potential to reduce performance on=
 SSD
>> > =E1and disks with commnad queuing.
>> >
>> > o This patch experiments with waiting for next request to come before a
>> > =E1queue is expired after it has consumed its time slice. This can ens=
ure
>> > =E1more accurate fairness numbers in some cases.
>>
>> Vivek, have you introduced this option just to play with it, or you
>> are planning to make it a part of the patch set. Waiting for a new
>> request to come before expiring time slice sounds problematic.
>
> Why are the issues you forsee with it. This is just an extra 8ms idling
> on the sync queue that is also if think time of the queue is not high.
>
> We already do idling on sync queues. In this case we are doing an extra
> idle even if queue has consumed its allocated quota. It helps me get
> fairness numbers and I have put it under a tunable "fairness". So by
> default this code will not kick in.
>
> Other possible option could be that when expiring a sync queue, don't
> remove the queue immediately from the tree and remove it later if there
> is no request from the queue in 8ms or so. I am not sure with BFQ, is it
> feasible to do that without creating issues with current implementation.
> Current implementation was simple, so I stick to it to begin with.

If the maximum wait is bounded by 8ms, then it should be fine. The
comments on the patch did not talk about such limit; it sounded like
unbounded wait to me.

Does keeping the sync queue in ready tree solves the problem too? Is
it because it avoid a virtual time jump?

>
> So yes, I am planning to keep it under tunable, unless there are
> significant issues in doing that.
>
> Thanks
> Vivek
>
>>
>> >
>> > o Introduced a tunable "fairness". If set, io-controller will put more
>> > =E1focus on getting fairness right than getting throughput right.
>> >
>> >
>> > ---
>> > =E1block/blk-sysfs.c =E1 | =E1 =E17 ++++
>> > =E1block/elevator-fq.c | =E1 85 ++++++++++++++++++++++++++++++++++++++=
+++++++-------
>> > =E1block/elevator-fq.h | =E1 12 +++++++
>> > =E13 files changed, 94 insertions(+), 10 deletions(-)
>> >
>> > Index: linux1/block/elevator-fq.h
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- linux1.orig/block/elevator-fq.h =E1 =E1 2009-03-18 17:34:46.000000=
000 -0400
>> > +++ linux1/block/elevator-fq.h =E12009-03-18 17:34:53.000000000 -0400
>> > @@ -318,6 +318,13 @@ struct elv_fq_data {
>> > =E1 =E1 =E1 =E1unsigned long long rate_sampling_start; /*sampling wind=
ow start jifies*/
>> > =E1 =E1 =E1 =E1/* number of sectors finished io during current samplin=
g window */
>> > =E1 =E1 =E1 =E1unsigned long rate_sectors_current;
>> > +
>> > + =E1 =E1 =E1 /*
>> > + =E1 =E1 =E1 =E1* If set to 1, will disable many optimizations done f=
or boost
>> > + =E1 =E1 =E1 =E1* throughput and focus more on providing fairness for=
 sync
>> > + =E1 =E1 =E1 =E1* queues.
>> > + =E1 =E1 =E1 =E1*/
>> > + =E1 =E1 =E1 int fairness;
>> > =E1};
>> >
>> > =E1extern int elv_slice_idle;
>> > @@ -340,6 +347,7 @@ enum elv_queue_state_flags {
>> > =E1 =E1 =E1 =E1ELV_QUEUE_FLAG_idle_window, =E1 =E1 =E1 /* elevator sli=
ce idling enabled */
>> > =E1 =E1 =E1 =E1ELV_QUEUE_FLAG_wait_request, =E1 =E1 =E1/* waiting for =
a request */
>> > =E1 =E1 =E1 =E1ELV_QUEUE_FLAG_slice_new, =E1 =E1 =E1 =E1 /* no request=
s dispatched in slice */
>> > + =E1 =E1 =E1 ELV_QUEUE_FLAG_wait_busy, =E1 =E1 =E1 =E1 /* wait for th=
is queue to get busy */
>> > =E1 =E1 =E1 =E1ELV_QUEUE_FLAG_NR,
>> > =E1};
>> >
>> > @@ -362,6 +370,7 @@ ELV_IO_QUEUE_FLAG_FNS(sync)
>> > =E1ELV_IO_QUEUE_FLAG_FNS(wait_request)
>> > =E1ELV_IO_QUEUE_FLAG_FNS(idle_window)
>> > =E1ELV_IO_QUEUE_FLAG_FNS(slice_new)
>> > +ELV_IO_QUEUE_FLAG_FNS(wait_busy)
>> >
>> > =E1static inline struct io_service_tree *
>> > =E1io_entity_service_tree(struct io_entity *entity)
>> > @@ -554,6 +563,9 @@ static inline struct io_queue *elv_looku
>> > =E1extern ssize_t elv_slice_idle_show(struct request_queue *q, char *n=
ame);
>> > =E1extern ssize_t elv_slice_idle_store(struct request_queue *q, const =
char *name,
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =
=E1 =E1 =E1 =E1 =E1 =E1 =E1size_t count);
>> > +extern ssize_t elv_fairness_show(struct request_queue *q, char *name);
>> > +extern ssize_t elv_fairness_store(struct request_queue *q, const char=
 *name,
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =
=E1 =E1 =E1 =E1 =E1 =E1 size_t count);
>> >
>> > =E1/* Functions used by elevator.c */
>> > =E1extern int elv_init_fq_data(struct request_queue *q, struct elevato=
r_queue *e);
>> > Index: linux1/block/elevator-fq.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- linux1.orig/block/elevator-fq.c =E1 =E1 2009-03-18 17:34:46.000000=
000 -0400
>> > +++ linux1/block/elevator-fq.c =E12009-03-18 17:34:53.000000000 -0400
>> > @@ -1837,6 +1837,44 @@ void elv_ioq_served(struct io_queue *ioq
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1ioq->total_service);
>> > =E1}
>> >
>> > +/* Functions to show and store fairness value through sysfs */
>> > +ssize_t elv_fairness_show(struct request_queue *q, char *name)
>> > +{
>> > + =E1 =E1 =E1 struct elv_fq_data *efqd;
>> > + =E1 =E1 =E1 unsigned int data;
>> > + =E1 =E1 =E1 unsigned long flags;
>> > +
>> > + =E1 =E1 =E1 spin_lock_irqsave(q->queue_lock, flags);
>> > + =E1 =E1 =E1 efqd =3D &q->elevator->efqd;
>> > + =E1 =E1 =E1 data =3D efqd->fairness;
>> > + =E1 =E1 =E1 spin_unlock_irqrestore(q->queue_lock, flags);
>> > + =E1 =E1 =E1 return sprintf(name, "%d\n", data);
>> > +}
>> > +
>> > +ssize_t elv_fairness_store(struct request_queue *q, const char *name,
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 size_t count)
>> > +{
>> > + =E1 =E1 =E1 struct elv_fq_data *efqd;
>> > + =E1 =E1 =E1 unsigned int data;
>> > + =E1 =E1 =E1 unsigned long flags;
>> > +
>> > + =E1 =E1 =E1 char *p =3D (char *)name;
>> > +
>> > + =E1 =E1 =E1 data =3D simple_strtoul(p, &p, 10);
>> > +
>> > + =E1 =E1 =E1 if (data < 0)
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 data =3D 0;
>> > + =E1 =E1 =E1 else if (data > INT_MAX)
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 data =3D INT_MAX;
>> > +
>> > + =E1 =E1 =E1 spin_lock_irqsave(q->queue_lock, flags);
>> > + =E1 =E1 =E1 efqd =3D &q->elevator->efqd;
>> > + =E1 =E1 =E1 efqd->fairness =3D data;
>> > + =E1 =E1 =E1 spin_unlock_irqrestore(q->queue_lock, flags);
>> > +
>> > + =E1 =E1 =E1 return count;
>> > +}
>> > +
>> > =E1/* Functions to show and store elv_idle_slice value through sysfs */
>> > =E1ssize_t elv_slice_idle_show(struct request_queue *q, char *name)
>> > =E1{
>> > @@ -2263,10 +2301,11 @@ void __elv_ioq_slice_expired(struct requ
>> > =E1 =E1 =E1 =E1assert_spin_locked(q->queue_lock);
>> > =E1 =E1 =E1 =E1elv_log_ioq(efqd, ioq, "slice expired upd=3D%d", budget=
_update);
>> >
>> > - =E1 =E1 =E1 if (elv_ioq_wait_request(ioq))
>> > + =E1 =E1 =E1 if (elv_ioq_wait_request(ioq) || elv_ioq_wait_busy(ioq))
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1del_timer(&efqd->idle_slice_timer);
>> >
>> > =E1 =E1 =E1 =E1elv_clear_ioq_wait_request(ioq);
>> > + =E1 =E1 =E1 elv_clear_ioq_wait_busy(ioq);
>> >
>> > =E1 =E1 =E1 =E1/*
>> > =E1 =E1 =E1 =E1 * if ioq->slice_end =3D 0, that means a queue was expi=
red before first
>> > @@ -2482,8 +2521,9 @@ void elv_ioq_request_add(struct request_
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 * immediately and flag that we must no=
t expire this queue
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 * just now
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 */
>> > - =E1 =E1 =E1 =E1 =E1 =E1 =E1 if (elv_ioq_wait_request(ioq)) {
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 if (elv_ioq_wait_request(ioq) || elv_ioq=
_wait_busy(ioq)) {
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1del_timer(&efqd->idle_s=
lice_timer);
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 elv_clear_ioq_wait_busy(=
ioq);
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1blk_start_queueing(q);
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1}
>> > =E1 =E1 =E1 =E1} else if (elv_should_preempt(q, ioq, rq)) {
>> > @@ -2519,6 +2559,9 @@ void elv_idle_slice_timer(unsigned long
>> >
>> > =E1 =E1 =E1 =E1if (ioq) {
>> >
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 if (elv_ioq_wait_busy(ioq))
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 goto expire;
>> > +
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1/*
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 * expired
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 */
>> > @@ -2546,7 +2589,7 @@ out_cont:
>> > =E1 =E1 =E1 =E1spin_unlock_irqrestore(q->queue_lock, flags);
>> > =E1}
>> >
>> > -void elv_ioq_arm_slice_timer(struct request_queue *q)
>> > +void elv_ioq_arm_slice_timer(struct request_queue *q, int wait_for_bu=
sy)
>> > =E1{
>> > =E1 =E1 =E1 =E1struct elv_fq_data *efqd =3D &q->elevator->efqd;
>> > =E1 =E1 =E1 =E1struct io_queue *ioq =3D elv_active_ioq(q->elevator);
>> > @@ -2563,15 +2606,27 @@ void elv_ioq_arm_slice_timer(struct requ
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1return;
>> >
>> > =E1 =E1 =E1 =E1/*
>> > - =E1 =E1 =E1 =E1* still requests with the driver, don't idle
>> > + =E1 =E1 =E1 =E1* idle is disabled, either manually or by past proces=
s history
>> > =E1 =E1 =E1 =E1 */
>> > - =E1 =E1 =E1 if (efqd->rq_in_driver)
>> > + =E1 =E1 =E1 if (!efqd->elv_slice_idle || !elv_ioq_idle_window(ioq))
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1return;
>> >
>> > =E1 =E1 =E1 =E1/*
>> > - =E1 =E1 =E1 =E1* idle is disabled, either manually or by past proces=
s history
>> > + =E1 =E1 =E1 =E1* This queue has consumed its time slice. We are wait=
ing only for
>> > + =E1 =E1 =E1 =E1* it to become busy before we select next queue for d=
ispatch.
>> > =E1 =E1 =E1 =E1 */
>> > - =E1 =E1 =E1 if (!efqd->elv_slice_idle || !elv_ioq_idle_window(ioq))
>> > + =E1 =E1 =E1 if (efqd->fairness && wait_for_busy) {
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 elv_mark_ioq_wait_busy(ioq);
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 sl =3D efqd->elv_slice_idle;
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 mod_timer(&efqd->idle_slice_timer, jiffi=
es + sl);
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 elv_log(efqd, "arm idle: %lu wait busy=
=3D1", sl);
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 return;
>> > + =E1 =E1 =E1 }
>> > +
>> > + =E1 =E1 =E1 /*
>> > + =E1 =E1 =E1 =E1* still requests with the driver, don't idle
>> > + =E1 =E1 =E1 =E1*/
>> > + =E1 =E1 =E1 if (efqd->rq_in_driver)
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1return;
>> >
>> > =E1 =E1 =E1 =E1/*
>> > @@ -2628,6 +2683,12 @@ void *elv_fq_select_ioq(struct request_q
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1}
>> > =E1 =E1 =E1 =E1}
>> >
>> > + =E1 =E1 =E1 /* We are waiting for this queue to become busy before i=
t expires.*/
>> > + =E1 =E1 =E1 if (efqd->fairness && elv_ioq_wait_busy(ioq)) {
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 ioq =3D NULL;
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 goto keep_queue;
>> > + =E1 =E1 =E1 }
>> > +
>> > =E1 =E1 =E1 =E1/*
>> > =E1 =E1 =E1 =E1 * The active queue has run out of time, expire it and =
select new.
>> > =E1 =E1 =E1 =E1 */
>> > @@ -2802,10 +2863,14 @@ void elv_ioq_completed_request(struct re
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1elv_ioq_set_prio_slice(=
q, ioq);
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1elv_clear_ioq_slice_new=
(ioq);
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1}
>> > - =E1 =E1 =E1 =E1 =E1 =E1 =E1 if (elv_ioq_slice_used(ioq) || elv_ioq_c=
lass_idle(ioq))
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 if (elv_ioq_class_idle(ioq))
>> > =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1elv_ioq_slice_expired(q=
, 1);
>> > - =E1 =E1 =E1 =E1 =E1 =E1 =E1 else if (sync && !ioq->nr_queued)
>> > - =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 elv_ioq_arm_slice_timer(=
q);
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 else if (sync && !ioq->nr_queued) {
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 if (elv_ioq_slice_used(i=
oq))
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 elv_ioq_=
arm_slice_timer(q, 1);
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 else
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 =E1 elv_ioq_=
arm_slice_timer(q, 0);
>> > + =E1 =E1 =E1 =E1 =E1 =E1 =E1 }
>> > =E1 =E1 =E1 =E1}
>> >
>> > =E1 =E1 =E1 =E1if (!efqd->rq_in_driver)
>> > Index: linux1/block/blk-sysfs.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- linux1.orig/block/blk-sysfs.c =E1 =E1 =E1 2009-03-18 17:34:28.0000=
00000 -0400
>> > +++ linux1/block/blk-sysfs.c =E1 =E12009-03-18 17:34:53.000000000 -0400
>> > @@ -282,6 +282,12 @@ static struct queue_sysfs_entry queue_sl
>> > =E1 =E1 =E1 =E1.show =3D elv_slice_idle_show,
>> > =E1 =E1 =E1 =E1.store =3D elv_slice_idle_store,
>> > =E1};
>> > +
>> > +static struct queue_sysfs_entry queue_fairness_entry =3D {
>> > + =E1 =E1 =E1 .attr =3D {.name =3D "fairness", .mode =3D S_IRUGO | S_I=
WUSR },
>> > + =E1 =E1 =E1 .show =3D elv_fairness_show,
>> > + =E1 =E1 =E1 .store =3D elv_fairness_store,
>> > +};
>> > =E1#endif
>> > =E1static struct attribute *default_attrs[] =3D {
>> > =E1 =E1 =E1 =E1&queue_requests_entry.attr,
>> > @@ -296,6 +302,7 @@ static struct attribute *default_attrs[]
>> > =E1 =E1 =E1 =E1&queue_iostats_entry.attr,
>> > =E1#ifdef CONFIG_ELV_FAIR_QUEUING
>> > =E1 =E1 =E1 =E1&queue_slice_idle_entry.attr,
>> > + =E1 =E1 =E1 &queue_fairness_entry.attr,
>> > =E1#endif
>> > =E1 =E1 =E1 =E1NULL,
>> > =E1};
>> >
>
