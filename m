From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: Re: BFQ speed tests [was Re: [PATCH RFC - TAKE TWO - 00/12] New
	version of the BFQ I/O Scheduler]
Date: Wed, 11 Jun 2014 22:39:31 +0200
Message-ID: <DE2B8BBD-EFC6-46C7-8B0E-DC2CBCBDBC6A@unimore.it>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<20140530160712.GG24871@htj.dyndns.org>
	<464F6CBE-A63E-46EF-A90D-BF8450430444@unimore.it>
	<20140530232804.GA5057@htj.dyndns.org>
	<20140602111432.GA3737@amd.pavel.ucw.cz>
	<20140602130226.GA14654@amd.pavel.ucw.cz>
	<FCFE0106-A4DD-4DEF-AAAE-040F3823A447@unimore.it>
	<20140604100358.GA4799@amd.pavel.ucw.cz>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140604100358.GA4799-tWAi6jLit6GreWDznjuHag@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Il giorno 04/giu/2014, alle ore 12:03, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org> ha scrit=
to:

> Hi!
> =

>> Should this attempt be useless as well, I will, if you do not mind, try =
by asking you more details about your system and reproducing your configura=
tion as much as I can.
>> =

> =

> Try making BFQ the default scheduler. That seems to break it for me,
> when selected at runtime, it looks stable.

As I have already written to you privately, we have fixed the bug. It was a
clerical error, made while turning the original patchset into the series of
patches we have then submitted.

The new patchset is available here:
http://algogroup.unimore.it/people/paolo/disk_sched/debugging-patches/3.16.=
0-rc0-v7rc5.tgz

I=92m not submitting this new, fixed patchset by email, because, before doi=
ng that,
we want to apply all the changes recommended by Tejun, and try to turn the
new patchset into a 'transformer' of cfq into bfq (of course, should it be =
better
to proceed in a different way also for this intermediate new version of bfq,
we are willing to).

> =

> Anyway, here are some speed tests. Background load:
> [=85]
> root@duo:/data/tmp# echo cfq > /sys/block/sda/queue/scheduler =

> root@duo:/data/tmp# echo 3 > /proc/sys/vm/drop_caches
> root@duo:/data/tmp# cat /dev/zero > delme; cat /dev/zero > delme;cat
> /dev/zero > delme;cat /dev/zero > delme;cat /dev/zero > delme;cat
> /dev/zero > delme
> =

> (Machine was running out of disk space.)
> =

> (I alternate between cfq and bfq).
> =

> Benchmark. I chose git describe because it is part of kernel build
> sometimes .. and I actually wait for that.
> [=85]

We have solved also this regression, related to both the queue-merge
mechanism and the heuristic for providing a low-latency to soft real-time
applications. The new patchset contains also this fix. We have repeated
your tests (and other similar tests) with this fixed version of bfq.
These are now our results with your tests.

# Test with background writes

[root@bfq-testbed data]# echo cfq > /sys/block/sda/queue/scheduler
[root@bfq-testbed data]# echo 3 > /proc/sys/vm/drop_caches
[root@bfq-testbed data]# cat /dev/zero > delme; cat /dev/zero > delme;cat
/dev/zero > delme;cat /dev/zero > delme;cat /dev/zero > delme;cat
/dev/zero > delme

[root@bfq-testbed linux-lkml]# time git describe
v3.15-rc8-78-gd531c25

# BFQ
0.24user 0.14system 0:07.42elapsed 5%CPU
# CFQ
0.24user 0.16system 0:08.39elapsed 4%CPU
# BFQ
0.25user 0.15system 0:08.45elapsed 4%CPU
# CFQ
0.26user 0.15system 0:09.11elapsed 4%CPU

# Results without background workload

# BFQ
0.23user 0.12system 0:07.23elapsed 4%CPU
# CFQ
0.25user 0.13system 0:07.36elapsed 5%CPU
# BFQ
0.23user 0.14system 0:07.24elapsed 5%CPU
# CFQ
0.22user 0.14system 0:07.36elapsed 5%CPU

Any feedback on these and other tests is more than welcome.

Thanks,
Paolo
