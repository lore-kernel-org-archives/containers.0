From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 00/12] New version of the BFQ I/O
	Scheduler
Date: Tue, 17 Jun 2014 17:55:57 +0200
Message-ID: <0A5218F8-0215-4B4F-959B-EE5AAEFC164A@unimore.it>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
	<538926F6.7080409@kernel.dk>
	<20140531051635.GA19925@mtj.dyndns.org>
	<538C8A47.1050502@kernel.dk>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <538C8A47.1050502-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Il giorno 02/giu/2014, alle ore 16:29, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org> ha scri=
tto:

> On 2014-05-30 23:16, Tejun Heo wrote:
>>> for turning patch #2 into a series of changes for CFQ instead. We need =
to
>>> end up with something where we can potentially bisect our way down to
>>> whatever caused any given regression. The worst possible situation is "=
CFQ
>>> works fine for this workload, but BFQ does not" or vice versa. Or hangs=
, or
>>> whatever it might be.
>> =

>> It's likely that there will be some workloads out there which may be
>> affected adversely, which is true for any change really but with both
>> the core scheduling and heuristics properly characterized at least
>> finding a reasonable trade-off should be much less of a crapshoot and
>> the expected benefits seem to easily outweigh the risks as long as we
>> can properly sequence the changes.
> =

> Exactly, I think we are pretty much on the same page here. As I said in t=
he previous email, the biggest thing I care about is not adding a new IO sc=
heduler wholesale. If Paolo can turn the "add BFQ" patch into a series of p=
atches against CFQ, then I would have no issue merging it for testing (and =
inclusion, when it's stable enough).

We have finished analyzing possible ways to turn cfq into bfq, and unfortun=
ately
I think I need some help in this respect. In fact, we have found several, a=
pparently
non-trivial issues. To describe them, I will start from some concrete examp=
les, and
then try to discuss the overall problem in general terms, instead of provid=
ing a list
of all the issues we have found. I am sorry for providing however many deta=
ils, but
I hope they will help me sync with you, and then make other boring emails n=
eedless.

First, supposing to start the transformation from adding the low-latency he=
uristics of bfq
to cfq's engine, one of the main issues is that cfq chooses the next queue =
to serve,
within a group and class, in a different way than bfq does. In fact, cfq fi=
rst chooses the
sub-group of queues to serve according to a workload-based priority scheme,=
 and then
performs a round-robin scheduling among the queues in the sub-group. This p=
riority scheme
not only has nothing to do with the logic of the low-latency heuristics of =
bfq (and actually with
bfq altogether), but also conflicts with the freedom in choosing the next q=
ueue that these
heuristics need to succeed in guaranteeing a low latency.

If, on the opposite end, we assume, because of the above issue, to proceed =
the other
way round, i.e., to start from replacing the engine of cfq with that of bfq=
, then similar, if not worse,
issues arise:
- the internal scheduler of bfq is hierarchical, whereas the internal, roun=
d-robin-based scheduler
  of cfq is not
- the hierarchy-flattening scheme adopted in cfq has no counterpart in the =
hierarchical scheduling
  algorithm of bfq
- preemption is not trivial to implement in bfq in such a way that service =
guarantees are preserved,
  but, in the first place, would however be needed to keep a high throughpu=
t with interleaved I/O
- cfq uses the workload-based queue selection scheme I mentioned above, and=
 this has no match
  with any mechanism in bfq
...

Instead of bothering you with the full list of issues, I want to try to des=
cribe the problem, in general
terms, through the following rough simplification (in which I am neglecting=
 trivial common code
between cfq and bfq, such as handling of I/O contexts). On one side, bfq is=
 made by 80% of a
hierarchical fair-queueing scheduler, and by the remaining 20% of a set of =
heuristics to improve
some performance indexes. On the other side, cfq is made, roughly, by 40% o=
f a simple round-robin
flat scheduler, and by the remaining 60%, of: an extension to support hiera=
rchical scheduling,
workload-based improvements, preemption, virtual-time extensions, further l=
ow-latency mechanisms,
and so on. This remaining 60% of cfq has practically very little in common =
with the above 20% of
heuristics in bfq (although many of the goals of these parts are the same).=
 Probably, commonalities
amount to at most a 10%. The problem is then the remaining, almost complete=
ly incompatible, 90%
of non-common mechanisms.

To make a long story short, to implement a smooth transition from cfq to bf=
q, this 90% should of
course be progressively transformed along the way. This would apparently im=
ply that:
- the intermediate versions would not be partial versions of either cfq or =
bfq;
- the performance of these intermediate versions would most certainly be wo=
rse than that of both
  cfq and bfq, as the mechanisms of the latter schedulers have been fine-tu=
ned over the years,
  whereas the hybrid mechanisms in the intermediate versions would just be =
an attempt to avoid
  abrupt changes;
- these hybrid mechanisms would likely be more complex than the original on=
es;
- in the final steps of the transformation, these hybrid mechanisms will al=
l have to be further
  changed to become those of bfq, or just thrown away.

In the end, a smooth transition seems messy and confusing. On the opposite =
end, I thought about
a cleaner but sharper solution, which probably better matches the one propo=
sed by Tejun:
1) removing the 60% of extra code of cfq from around the round-robin engine=
 of cfq, 2) turning the
remaining core into a flat version of bfq-v0, 3) turning this flat schedule=
r into the actual, hierarchical
bfq-v0, 4) applying the remaining bfq patches.

In general, with both a smooth but messy and a sharp but clean transformati=
on, there seems to be
the following common problems:
1) The main benefits highlighted by Jens, i.e., being able to move back and=
 forth and easily
understand what works and what does not, seem to be lost, because, with bot=
h solutions,
intermediate versions would likely have a worse performance than the curren=
t version of cfq.
2) bfq, on one side, does not export some of the sysfs parameters of cfq, s=
uch as slice_sync, and,
on the other side, uses other common parameters in a different way. For exa=
mple, bfq turns I/O priorities
into throughput shares in a different way than cfq does. As a consequence, =
existing configurations may
break or behave in unexpected ways.

I=92m sorry for the long list of (only) problems, but, because of the exten=
t at which cfq and bfq have diverged
over the years, we are having a really hard time finding a sensible way to =
turn the former into the latter.
Of course, we are willing to do our best once we find a viable solution.

Thanks,
Paolo
