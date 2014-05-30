From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: Re: [PATCH RFC RESEND 00/14] New version of the BFQ I/O Scheduler
Date: Sat, 31 May 2014 01:33:56 +0200
Message-ID: <1263C136-7F68-465B-8185-C98496E6A73D@unimore.it>
References: <1401194558-5283-1-git-send-email-paolo.valente@unimore.it>
	<20140530153228.GE16605@redhat.com>
	<20140530161650.GH24871@htj.dyndns.org>
	<20140530170958.GF16605@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140530170958.GF16605-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Il giorno 30/mag/2014, alle ore 19:09, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> ha s=
critto:

> [=85]
> Instead of just looking at numbers, I am keen on knowing what's the
> fundamental design change which allows this. What is CFQ doing wrong
> which BFQ gets right.
> =


I think that Tejun has already highlighted the key points and provided many=
 details. To contribute to answer your questions about the reasons why bfq =
outperforms cfq, here is a summary of the most relevant underlying facts:

1) cfq is based on a round-robin scheme, in which an unlucky queue that sho=
uld be served immediately may happen instead to wait for all the other busy=
 queues before being served. In this respect, combining round robin with vi=
rtual-time-based improvements is likely to lead to not very clear solutions=
, and probably to sub-optimal results with respect to just using an optimal=
 scheduler with provable deterministic guarantees (as the internal schedule=
r of bfq).

2) To provide a queue with a higher fraction of the throughput, a round-rob=
in scheduler serves the queue for a longer time slice. Increasing time slic=
es further increases per-request latencies. The problem may be mitigated by=
 using preemption, but the result is a combination of a basic algorithm and=
 a =91corrective=92 heuristic. This is again a more convoluted, and likely =
less accurate, solution than using directly an optimal algorithm with prova=
ble guarantees.

3) In bfq, budgets play a similar role as time slices in cfq, i.e., once a =
queue has been granted access to the device, the queue is served, in the si=
mplest case, until it finishes its budget. But, under bfq, the fraction of =
the throughput received by a queue is *independent* of the budget assigned =
to the queue. I agree that this may seem counterintuitive in the first plac=
e, especially if one is accustomed to thinking a la round-robin. Differentl=
y from a round-robin algorithm, the internal scheduler of bfq controls thro=
ughput distribution by controlling the frequency at which queues are served=
. The resulting degree of freedom with respect to budget sizes has the foll=
owing two main advantages:
3.a) bfq can choose for each queue the budget that best fits the requiremen=
ts or characteristics of the queue. For example, queues corresponding to ti=
me-sensitive applications are assigned small budgets, which guarantees that=
 they are served quickly. On the opposite side, queues associated to I/O-bo=
und processes performing mostly sequential I/O are assigned large budgets, =
which helps boost the throughput.
3.b) bfq does not need to assign large budgets to queues to provide them wi=
th large fractions of the throughput; hence bfq does not need to deteriorat=
e per-request latencies to guarantee a differentiated throughput distributi=
on.

3) The internal scheduler of bfq guarantees that a queue that needs to be s=
erved quickly may wait, unjustly, for the service of at most one queue. Mor=
e formally, bfq guarantees that each budget is completed with the smallest =
possible delay, for a budget-by-budget scheduler, with respect to an ideal,=
 perfectly fair scheduler (i.e., an ideal scheduler that serves all busy qu=
eues at the same, providing each with a fraction of the throughput proporti=
onal to its weight).

4) Assigning temporarily a large fraction of the throughput is the main mec=
hanism through which bfq provides interactive and soft real-time applicatio=
ns with a low latency. Thanks to fact 3.b, bfq achieves this goal without i=
ncreasing per-request latencies. As for how applications are deemed as inte=
ractive or soft real-time, I have tried to describe both detection heuristi=
cs in patches 06 and 07.

Finally, as for adding to cfq the heuristics I have added to bfq, I think t=
hat this would probably improve application latencies also with cfq. But, b=
ecause of the above facts, the result would unavoidably be worse than with =
bfq.

Paolo

--
Paolo Valente                                                 =

Algogroup
Dipartimento di Fisica, Informatica e Matematica		=

Via Campi, 213/B
41125 Modena - Italy        				  =

homepage:  http://algogroup.unimore.it/people/paolo/
