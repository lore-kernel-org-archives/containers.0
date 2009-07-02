From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 13/25] io-controller: Wait for requests to complete from
	last queue before new queue is scheduled
Date: Thu, 2 Jul 2009 13:09:14 -0700
Message-ID: <e98e18940907021309u1f784b3at409b55ba46ed108c__38420.1777437285$1246565462$gmane$org@mail.gmail.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<1246564917-19603-14-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246564917-19603-14-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jul 2, 2009 at 1:01 PM, Vivek Goyal<vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> o Currently one can dispatch requests from multiple queues to the disk. T=
his
> =A0is true for hardware which supports queuing. So if a disk support queue
> =A0depth of 31 it is possible that 20 requests are dispatched from queue 1
> =A0and then next queue is scheduled in which dispatches more requests.
>
> o This multiple queue dispatch introduces issues for accurate accounting =
of
> =A0disk time consumed by a particular queue. For example, if one async qu=
eue
> =A0is scheduled in, it can dispatch 31 requests to the disk and then it w=
ill
> =A0be expired and a new sync queue might get scheduled in. These 31 reque=
sts
> =A0might take a long time to finish but this time is never accounted to t=
he
> =A0async queue which dispatched these requests.
>
> o This patch introduces the functionality where we wait for all the reque=
sts
> =A0to finish from previous queue before next queue is scheduled in. That =
way
> =A0a queue is more accurately accounted for disk time it has consumed. No=
te
> =A0this still does not take care of errors introduced by disk write cachi=
ng.
>
> o Because above behavior can result in reduced throughput, this behavior =
will
> =A0be enabled only if user sets "fairness" tunable to 2 or higher.

Vivek,
Did you collect any numbers for the impact on throughput from this
patch? It seems like with this change, we can even support NCQ.

>
> o This patch helps in achieving more isolation between reads and buffered
> =A0writes in different cgroups. buffered writes typically utilize full qu=
eue
> =A0depth and then expire the queue. On the contarary, sequential reads
> =A0typicaly driver queue depth of 1. So despite the fact that writes are
> =A0using more disk time it is never accounted to write queue because we d=
on't
> =A0wait for requests to finish after dispatching these. This patch helps
> =A0do more accurate accounting of disk time, especially for buffered writ=
es
> =A0hence providing better fairness hence better isolation between two cgr=
oups
> =A0running read and write workloads.
>
> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
> =A0block/elevator-fq.c | =A0 31 ++++++++++++++++++++++++++++++-
> =A01 files changed, 30 insertions(+), 1 deletions(-)
>
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index 68be1dc..7609579 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -2038,7 +2038,7 @@ STORE_FUNCTION(elv_slice_sync_store, &efqd->elv_sli=
ce[1], 1, UINT_MAX, 1);
> =A0EXPORT_SYMBOL(elv_slice_sync_store);
> =A0STORE_FUNCTION(elv_slice_async_store, &efqd->elv_slice[0], 1, UINT_MAX=
, 1);
> =A0EXPORT_SYMBOL(elv_slice_async_store);
> -STORE_FUNCTION(elv_fairness_store, &efqd->fairness, 0, 1, 0);
> +STORE_FUNCTION(elv_fairness_store, &efqd->fairness, 0, 2, 0);
> =A0EXPORT_SYMBOL(elv_fairness_store);
> =A0#undef STORE_FUNCTION
>
> @@ -2952,6 +2952,24 @@ void *elv_fq_select_ioq(struct request_queue *q, i=
nt force)
> =A0 =A0 =A0 =A0}
>
> =A0expire:
> + =A0 =A0 =A0 if (efqd->fairness >=3D 2 && !force && ioq && ioq->dispatch=
ed) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If there are request dispatched from t=
his queue, don't
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* dispatch requests from new queue till =
all the requests from
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* this queue have completed.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This helps in attributing right amount=
 of disk time consumed
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* by a particular queue when hardware al=
lows queuing.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Set ioq =3D NULL so that no more reque=
sts are dispatched from
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* this queue.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "select: wait for re=
quests to finish"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 " disp=3D%l=
u", ioq->dispatched);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioq =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto keep_queue;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0elv_ioq_slice_expired(q);
> =A0new_queue:
> =A0 =A0 =A0 =A0ioq =3D elv_set_active_ioq(q, new_ioq);
> @@ -3109,6 +3127,17 @@ void elv_ioq_completed_request(struct request_queu=
e *q, struct request *rq)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0elv_ioq_ar=
m_slice_timer(q, 1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If fairn=
ess >=3D2 and there are requests
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* dispat=
ched from this queue, don't dispatch
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* new re=
quests from a different queue till
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* all re=
quests from this queue have finished.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This h=
elps in attributing right disk time
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to a q=
ueue when hardware supports queuing.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (efqd->f=
airness >=3D 2 && ioq->dispatched)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goto done;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Expire =
the queue */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0elv_ioq_sl=
ice_expired(q);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> --
> 1.6.0.6
>
>
