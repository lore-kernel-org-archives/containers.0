From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 00/12] New version of the BFQ I/O
	Scheduler
Date: Mon, 23 Jun 2014 15:53:09 +0200
Message-ID: <8F719638-0CD7-4BD2-8F4F-088913A0EE2D@unimore.it>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
	<538926F6.7080409@kernel.dk>
	<20140531051635.GA19925@mtj.dyndns.org>
	<538C8A47.1050502@kernel.dk>
	<0A5218F8-0215-4B4F-959B-EE5AAEFC164A@unimore.it>
	<20140619014600.GA20100@mtj.dyndns.org>
	<53A24B1C.1070004@kernel.dk>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <53A24B1C.1070004-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
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


Il giorno 19/giu/2014, alle ore 04:29, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org> ha scri=
tto:

> On 2014-06-18 18:46, Tejun Heo wrote:
>> Hello,
>> =

>> On Tue, Jun 17, 2014 at 05:55:57PM +0200, Paolo Valente wrote:
>>> In general, with both a smooth but messy and a sharp but clean
>>> transformation, there seems to be the following common problems:
>>> =

>>> 1) The main benefits highlighted by Jens, i.e., being able to move
>>> back and forth and easily understand what works and what does not,
>>> seem to be lost, because, with both solutions, intermediate versions
>>> would likely have a worse performance than the current version of
>>> cfq.
>> =

>> So, the perfectly smooth and performant transformation is possible,
>> it'd be great, but I don't really think that'd be the case.  My
>> opinion is that if the infrastructure pieces can be mostly maintained
>> while making logical gradual steps it should be fine.  ie. pick
>> whatever strategy which seems executable, chop down the pieces which
>> get in the way (ie. tear down all the cfq heuristics if you have to),
>> transform the base and then build things on top again.  Ensuring that
>> each step is logical and keeps working should give us enough safety
>> net, IMO.
>> =

>> Jens, what do you think?
> =

> I was thinking the same - strip CFQ back down, getting rid of the heurist=
ics, then go forward to BFQ. That should be feasible. You need to find the =
common core first.

OK, I will try exactly this approach (hoping not to have misunderstood anyt=
hing).
Here is, very briefly, the strategy I am thinking about:
1) In a first, only-destructive phase, bring CFQ back, more or less, to its=
 state
at the time when BFQ was forked initially, and justify the removal of every=
 heuristic
and improvement. Depending on how many patches come out during this phase,
possibly pack them into a first, separate patch series.
2) In a second, only-constructive phase: (a) turn the stripped-down version=
 of CFQ into
a flat BFQ-v0, (b) turn the latter into BFQ-v0, and, finally, (c) progressi=
vely turn BFQ-v0
into the last version of BFQ, through the previously-submitted patches. Of =
course after
fixing and improving all the involved patches according to the suggestions =
and corrections
of Tejun.

I will wait shortly for a possible feedback on this proposal, and, then, if=
 nothing has still to be
changed or refined, silently start the process.

> =

>>> 2) bfq, on one side, does not export some of the sysfs parameters of
>>> cfq, such as slice_sync, and, on the other side, uses other common
>>> parameters in a different way. For example, bfq turns I/O priorities
>>> into throughput shares in a different way than cfq does. As a
>>> consequence, existing configurations may break or behave in
>>> unexpected ways.
>> =

>> This is why I hate exposing internal knobs without layering proper
>> semantic interpretation on top.  It ends up creating unnecessary
>> lock-in effect too often just to serve some esoteric cases which
>> aren't all that useful.  For knobs which don't make any sense for the
>> new scheduler, the appropriate thing to do would be just making them
>> noop and generate a warning message when it's written to.
>> =

>> As for behavior change for existing users, any change to scheduler
>> does that.  I don't think it's practical to avoid any changes for that
>> reason.  I think there already is a pretty solid platform to base
>> things on and the way forward is making the changes and iterating as
>> testing goes on and issues get reported.
> =

> Completely agree, don't worry about that. It's not like we advertise hard=
 guarantees on the priorities right now, for instance, so as long as the en=
d result isn't orders of magnitude different for the classes/levels, then i=
t'll likely be good enough.
> =

> Ditto on the sysfs files, as some of those are likely fairly widely used.=
 But if we warn and do nothing, then that'll allow us to sort out popular u=
ses of it before we (later on) remove the files.

Great, thanks. BTW, most of the =91internal=92 parameters inappropriately e=
xposed by BFQ,
as noted by Tejun, were exposed just because we forgot to remove them while=
 turning
the testing version of BFQ into the submitted one. Sorry about that.

Thanks,
Paolo

> =

> -- =

> Jens Axboe


--
Paolo Valente                                                 =

Algogroup
Dipartimento di Fisica, Informatica e Matematica		=

Via Campi, 213/B
41125 Modena - Italy        				  =

homepage:  http://algogroup.unimore.it/people/paolo/
