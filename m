From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 11/12] block,
	bfq: boost the throughput on NCQ-capable flash-based devices
Date: Mon, 16 Jun 2014 12:46:36 +0200
Message-ID: <D163E069-ED77-4BF5-A488-9A90C41C60C1@unimore.it>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<1401354343-5527-12-git-send-email-paolo.valente@unimore.it>
	<20140531115216.GB5057@htj.dyndns.org>
	<36BFDB73-AEC2-4B87-9FD6-205E9431E722@unimore.it>
	<20140603171124.GE26210@htj.dyndns.org>
	<03CDD106-DB18-4E8F-B3D6-2AAD45782A06@unimore.it>
	<20140604135627.GB5004@htj.dyndns.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140604135627.GB5004-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Il giorno 04/giu/2014, alle ore 15:56, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> ha scritto:

> Hello, Paolo.

Hello, and sorry for the late reply.

> [=85]
>> =

>> Actually we have been asked several times to improve random-I/O
>> performance on HDDs over the last years, by people recording, for
>> the typical tasks performed by their machines, much lower throughput
>> than with the other schedulers. Major problems have been reported
>> for server workloads (database, web), and for btrfs. According to
>> the feedback received after introducing this optimization in bfq,
>> those problems seem to be finally gone.
> =

> I see.  The equal priority part can probably work in enough cases to
> be meaningful given that it just depends on the busy queues having the
> same weight instead of everything in the system.  It'd nice to note
> that in the comment tho.
> =

> I'm still quite skeptical about the cgroup part tho.  The triggering
> condition is too specific and fragile.  If I'm reading the bfq blkcg
> implementation correctly, it seems to be applying the scheduling
> algorithm recursively walking down the tree one level at a time.

Yes.

>  cfq
> does it differently.  cfq flattens the hierarchy by calculating the
> nested weight of each active leaf queue and schedule all of them from
> the same service tree.  IOW, scheduling algorithm per-se doesn't care
> about the hierarchy.  All it sees are differing weights competing
> equally regardless of the hierarchical structure.
> =


To preserve the desired distribution of the device throughput (or time), th=
is
scheme entails updating weights every time the set of active queues changes.
For example (sorry for the trivial example, but I just want to make sure th=
at I am
not misunderstanding what you are telling me), suppose that two groups,
A and B, are reserved 50% of the throughput each, and that the first group =
contains
two processes, whereas the second group just one process. Apart from the
additional per-queue interventions of cfq to improve latency or throughput,=
 the
queues the two processes in in group A are reserved 50% of the group throug=
hput
each. It follows that, if all the three queues are backlogged, then a corre=
ct weight
distribution for a flat underlying scheduler is, e.g., 25 and 25 for the tw=
o processes
in group A, and 50 for the process in group B.

But, if one of the queues in group A becomes idle, then the correct weights
of the still-active queues become, e.g., 50 and 50.

Changing weights this way has basically no influence of the per-request lat=
ency
guarantees of cfq, because cfq is based on a round-robin scheme, and the la=
tter
already suffers from a large deviation with respect to an ideal service. In=
 contrast,
things change dramatically with an accurate scheduler, such as the internal
B-WF2Q+ scheduler of BFQ. In that case, as explained, e.g., here for packet
scheduling (but the problem is exactly the same)

http://www.algogroup.unimore.it/people/paolo/dynWF2Q+/dynWF2Q+.pdf

weight changes would just break service guarantees, and lead to the same
deviation as a round-robin scheduler. As proved in the same
document, to preserve guarantees, weight updates should be delayed/concealed
in a non-trivial (although computationally cheap) way.

> If the same strategy can be applied to bfq, possibly the same strategy
> of checking whether all the active queues have the same weight can be
> used regardless of blkcg?  That'd be simpler and a lot more robust.
> =


Unfortunately, because of the above problems, this scheme would break
service guarantees with an accurate scheduler such as bfq.

The hierarchical scheme used by bfq does not suffer from this problem,
also because it does implement the mechanisms described in the
above document. In particular, it allows these mechanism to be
implemented in a quite simple way, whereas things would become
more convoluted after flattening the hierarchy.

If useful, I am willing to provide more details, although these aspects are=
 most
certainly quite theoretical and boring.

> Another thing I'm curious about is that the logic that you're using to
> disable idling assumes that the disk will serve the queued commands
> more or less in fair manner over time, right?  If so, why does queues
> having the same weight matter?  Shouldn't the bandwidth scheduling
> eventually make them converge to the specified weights over time?
> Isn't wr_coeff > 1 test enough for maintaining reasonable
> responsiveness?

Unfortunately, when I first defined bfq with Fabio, this was one of the main
mistakes made in most of existing research I/O schedulers. More precisely, =
your
statement is true for async queues, but fails for sync queues. The problem =
is that
the (only) way in which a process pushes a scheduler into giving it its res=
erved
throughput is by issuing requests at a higher rate than that at which they =
are
served. But, with sync queues this just cannot happen. In particular,
postponing the service of a sync request delays the arrival of the next,
but not-yet-arrived, sync request of the same process. Intuitively, for the=
 scheduler,
it is like if the process was happy with the throughput it is receiving, be=
cause
it happens to issue requests exactly at that rate.

This problems is described in more detail, for example, in Section 5.3 of
http://www.algogroup.unimore.it/people/paolo/disk_sched/bf1-v1-suite-result=
s.pdf

bfq deals with this problem by properly back-shifting request timestamps wh=
en
needed. But idling is necessary for this mechanism to work (unless more
complex solutions are adopted).

> =

>> Besides, turning back to bfq, if its low-latency heuristics are
>> disabled for non rotational devices, then, according to our results
>> with slower devices, such as SD Cards and eMMCs, latency becomes
>> easily unbearable, with no throughput gain.
> =

> Hmmm... looking at the nonrot optimizations again, so yeah assuming
> the weight counting is necessary for NCQ hdds the part specific to
> ssds isn't that big.  You probably wanna sequence it the other way
> around tho.  This really should be primarily about disks at this
> point.
> =

> The thing which still makes me cringe is how it scatters
> blk_queue_nonrot() tests across multiple places without clear
> explanation on what's going on.  A bfqq being constantly seeky or not
> doesn't have much to do with whether the device is rotational or not.
> Its effect does and I don't think avoiding the overhead of keeping the
> counters is meaningful.  Things like this make the code a lot harder
> to maintain in the long term as code is organized according to
> seemingly arbitrary optimization rather than semantic structure.  So,
> let's please keep the accounting and optimization separate.
> =


Added to the list of changes to make, thanks.

Paolo

> Thanks.
> =

> -- =

> tejun


--
Paolo Valente                                                 =

Algogroup
Dipartimento di Fisica, Informatica e Matematica		=

Via Campi, 213/B
41125 Modena - Italy        				  =

homepage:  http://algogroup.unimore.it/people/paolo/
