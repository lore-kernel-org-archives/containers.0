From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH] range-bw: Another I/O scheduling policy of dm-ioband
	supporting the predicable I/O bandwidth (range bandwidth)
Date: Thu, 30 Apr 2009 16:53:10 +0900 (JST)
Message-ID: <20090430.165310.226796026.ryov__45866.9452266351$1241078129$gmane$org@valinux.co.jp>
References: <2891419e0904270158n71b25271p6094feba70d0555d@mail.gmail.com>
	<20090427.201214.39166983.ryov@valinux.co.jp>
	<2891419e0904292215x240dfeeg71f3eed0066bc112@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2891419e0904292215x240dfeeg71f3eed0066bc112-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

Hi Dong-Jae, =


From: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] range-bw: Another I/O scheduling policy of dm-ioband s=
upporting the predicable I/O bandwidth (range bandwidth)
Date: Thu, 30 Apr 2009 14:15:24 +0900

> Hi Ryo
> =

> I am sorry for delayed reply.
> I tested range-bw policy as you send me your configuration
> and I found some logical bugs in range-bw including big scheduling overhe=
ad.
> =

> > I used fio 1.22. The below is a script which I actually ran.
> >
> > =A0#!/bin/sh
> > =A0dev1=3D/dev/sdb4 # SATA disk
> > =A0echo "0 $(sudo blockdev --getsize $dev1) ioband $dev1 share2 0 0
> > =A0 =A0cgroup range-bw 0" | sudo dmsetup create ioband1
> >
> > =A0arg=3D"--time_based --runtime=3D10 --ioengine=3Dlibaio --iodepth=3D5=
0 \
> > =A0 =A0 =A0 --direct=3D1 --norandommap"
> >
> > =A0dmsetup message ioband1 0 attach 2
> > =A0dmsetup message ioband1 0 attach 3
> > =A0dmsetup message ioband1 0 min-bw 2:100
> > =A0dmsetup message ioband1 0 max-bw 2:100
> > =A0dmsetup message ioband1 0 min-bw 3:200
> > =A0dmsetup message ioband1 0 max-bw 3:200
> =

> I recommend it is better to use different value in min-bw and max-bw
> because its concept is to support range-bw with the minimum
> guaranteeing and maximum limitation.
> exampe - min-bw : 1024 / max-bw : 3072
> =

> > =A0echo $$ > /cgroup/grp1/tasks
> > =A0fio $arg --rw=3Drandread --name=3Dgrp1 --filename=3D/dev/mapper/ioba=
nd1 \
> > =A0 =A0 =A0 =A0 =A0--output=3Dr2-1.log &
> > =A0echo $$ > /cgroup/grp2/tasks
> > =A0fio $arg --rw=3Drandread --name=3Dgrp2 --filename=3D/dev/mapper/ioba=
nd1 \
> > =A0 =A0 =A0 =A0 =A0--output=3Dr2-2.log &
> > =A0wait
> >
> > Please feel free to ask me if you need more information.
> >
> >
> > I'm look forward to seeing the results.
> >
> Thanks for your comments.
> And I will fix the bugs and re-release it after several days
> at that time, I inform you about that.
> =

> Ryo,
> now, I am using bio-cgroup.....
> but, Is there additional things I have to consider to support AIO or
> dealyed I/O?

bio-cgroup is renamed to bklio-cgroup. :)
I don't clearly understand about range-bw but I think that you don't
need to consider to support them and it should be taken care of by
blkio-cgroup and the common part of dm-ioband, not the policy
implementation. Do you have any problems with AIO or delayed write?  =


> =

> -- =

> Best Regards,
> Dong-Jae Kang
