From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH] range-bw: Another I/O scheduling policy of dm-ioband
	supporting the predicable I/O bandwidth (range bandwidth)
Date: Tue, 12 May 2009 20:30:14 +0900 (JST)
Message-ID: <20090512.203014.71110404.ryov__39666.0139006146$1242127919$gmane$org@valinux.co.jp>
References: <2891419e0905040423y27f25ce7y61e5211aded85f99@mail.gmail.com>
	<20090505.073655.193711315.ryov@valinux.co.jp>
	<2891419e0905051735s7371e590gc942e4c6c475aa67@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2891419e0905051735s7371e590gc942e4c6c475aa67-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, corsetproject-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Dong-Jae,

From: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] range-bw: Another I/O scheduling policy of dm-ioband s=
upporting the predicable I/O bandwidth (range bandwidth)
Date: Wed, 6 May 2009 09:35:03 +0900

> 2009/5/5 Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>:
> > Hi Dong-Jae
> >
> > From: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Subject: Re: [PATCH] range-bw: Another I/O scheduling policy of dm-ioba=
nd supporting the predicable I/O bandwidth (range bandwidth)
> > Date: Mon, 4 May 2009 20:23:04 +0900
> >
> >> Hi, Ryo
> >>
> >> I released bug-fixed range-bw(V1) controller several minutes ago
> >>
> >> Although several WARNINGs of checkpatch are remained,
> >> but patch file was strictly checked by checkpatch.pl
> >> It was very time-consuming job :)
> >> Thank you for your advice
> >>
> >> >>
> >> >> > I used fio 1.22. The below is a script which I actually ran.
> >> >> >
> >> >> > =A0#!/bin/sh
> >> >> > =A0dev1=3D/dev/sdb4 # SATA disk
> >> >> > =A0echo "0 $(sudo blockdev --getsize $dev1) ioband $dev1 share2 0=
 0
> >> >> > =A0 =A0cgroup range-bw 0" | sudo dmsetup create ioband1
> >> >> >
> >> >> > =A0arg=3D"--time_based --runtime=3D10 --ioengine=3Dlibaio --iodep=
th=3D50 \
> >> >> > =A0 =A0 =A0 --direct=3D1 --norandommap"
> >> >> >
> >> >> > =A0dmsetup message ioband1 0 attach 2
> >> >> > =A0dmsetup message ioband1 0 attach 3
> >> >> > =A0dmsetup message ioband1 0 min-bw 2:100
> >> >> > =A0dmsetup message ioband1 0 max-bw 2:100
> >> >> > =A0dmsetup message ioband1 0 min-bw 3:200
> >> >> > =A0dmsetup message ioband1 0 max-bw 3:200
> >> >>
> >> >> I recommend it is better to use different value in min-bw and max-bw
> >> >> because its concept is to support range-bw with the minimum
> >> >> guaranteeing and maximum limitation.
> >> >> exampe - min-bw : 1024 / max-bw : 3072
> >> >>
> >> >> > =A0echo $$ > /cgroup/grp1/tasks
> >> >> > =A0fio $arg --rw=3Drandread --name=3Dgrp1 --filename=3D/dev/mappe=
r/ioband1 \
> >> >> > =A0 =A0 =A0 =A0 =A0--output=3Dr2-1.log &
> >> >> > =A0echo $$ > /cgroup/grp2/tasks
> >> >> > =A0fio $arg --rw=3Drandread --name=3Dgrp2 --filename=3D/dev/mappe=
r/ioband1 \
> >> >> > =A0 =A0 =A0 =A0 =A0--output=3Dr2-2.log &
> >> >> > =A0wait
> >>
> >> after bug-fix,I evaluated range-bw according to your configuration and
> >> test environment
> >> the result is in new relesed range-bw mail, [PATCH 0/2]
> >> and more detailed documentation is also available and it can be
> >> referred in [PATCH 1/2]
> >>
> >> Ryo,
> >> can you check the result ?

I did the same test as before and got the results as expected.

               cgroup1    cgroup2
  min:max-bw    0:100      0:200
  -------------------------------------
  read          100         197
  write         103         198 [KB/s]

I got errors while applying your patch, some lines are wrapped with
carriage returns.

    +extern int policy_range_bw_init(struct ioband_device *dp, int argc,
 >> char **argv);

Thanks,
Ryo Tsuruta
