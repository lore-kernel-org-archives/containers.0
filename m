From: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] range-bw: Another I/O scheduling policy of dm-ioband
	supporting the predicable I/O bandwidth (range bandwidth)
Date: Wed, 6 May 2009 09:35:03 +0900
Message-ID: <2891419e0905051735s7371e590gc942e4c6c475aa67__26902.8645627715$1241570188$gmane$org@mail.gmail.com>
References: <2891419e0904292215x240dfeeg71f3eed0066bc112@mail.gmail.com>
	<20090430.165310.226796026.ryov@valinux.co.jp>
	<2891419e0905040423y27f25ce7y61e5211aded85f99@mail.gmail.com>
	<20090505.073655.193711315.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090505.073655.193711315.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, corsetproject-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

2009/5/5 Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>:
> Hi Dong-Jae
>
> From: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Subject: Re: [PATCH] range-bw: Another I/O scheduling policy of dm-ioband=
 supporting the predicable I/O bandwidth (range bandwidth)
> Date: Mon, 4 May 2009 20:23:04 +0900
>
>> Hi, Ryo
>>
>> I released bug-fixed range-bw(V1) controller several minutes ago
>>
>> Although several WARNINGs of checkpatch are remained,
>> but patch file was strictly checked by checkpatch.pl
>> It was very time-consuming job :)
>> Thank you for your advice
>>
>> >>
>> >> > I used fio 1.22. The below is a script which I actually ran.
>> >> >
>> >> > =A0#!/bin/sh
>> >> > =A0dev1=3D/dev/sdb4 # SATA disk
>> >> > =A0echo "0 $(sudo blockdev --getsize $dev1) ioband $dev1 share2 0 0
>> >> > =A0 =A0cgroup range-bw 0" | sudo dmsetup create ioband1
>> >> >
>> >> > =A0arg=3D"--time_based --runtime=3D10 --ioengine=3Dlibaio --iodepth=
=3D50 \
>> >> > =A0 =A0 =A0 --direct=3D1 --norandommap"
>> >> >
>> >> > =A0dmsetup message ioband1 0 attach 2
>> >> > =A0dmsetup message ioband1 0 attach 3
>> >> > =A0dmsetup message ioband1 0 min-bw 2:100
>> >> > =A0dmsetup message ioband1 0 max-bw 2:100
>> >> > =A0dmsetup message ioband1 0 min-bw 3:200
>> >> > =A0dmsetup message ioband1 0 max-bw 3:200
>> >>
>> >> I recommend it is better to use different value in min-bw and max-bw
>> >> because its concept is to support range-bw with the minimum
>> >> guaranteeing and maximum limitation.
>> >> exampe - min-bw : 1024 / max-bw : 3072
>> >>
>> >> > =A0echo $$ > /cgroup/grp1/tasks
>> >> > =A0fio $arg --rw=3Drandread --name=3Dgrp1 --filename=3D/dev/mapper/=
ioband1 \
>> >> > =A0 =A0 =A0 =A0 =A0--output=3Dr2-1.log &
>> >> > =A0echo $$ > /cgroup/grp2/tasks
>> >> > =A0fio $arg --rw=3Drandread --name=3Dgrp2 --filename=3D/dev/mapper/=
ioband1 \
>> >> > =A0 =A0 =A0 =A0 =A0--output=3Dr2-2.log &
>> >> > =A0wait
>>
>> after bug-fix,I evaluated range-bw according to your configuration and
>> test environment
>> the result is in new relesed range-bw mail, [PATCH 0/2]
>> and more detailed documentation is also available and it can be
>> referred in [PATCH 1/2]
>>
>> Ryo,
>> can you check the result ?
>
> O.K. I'll check it and report back to you.
>
Hi Ryo,
Thank you for your kindness
I am looking forward to your report.
>>
>> > bio-cgroup is renamed to bklio-cgroup. :)
>> > I don't clearly understand about range-bw but I think that you don't
>> > need to consider to support them and it should be taken care of by
>> > blkio-cgroup and the common part of dm-ioband, not the policy
>> > implementation. Do you have any problems with AIO or delayed write?
>>
>> if you are interested in range-bw, more information is available to you
>> and any questions and comments about range-bw is always welcom. =A0:)
>>
>> Ryo,
>> blkio-cgroup can be applied to dm-ioband ver1.10.3 without modification?
>> I didn't check blkio-cgroup yet.
>
> Yes, it can. Please try it.
>
Okay, I will try to apply and test it.
and then, If I have any questions and problems about that, I will
contact you again.
Thank you.

-- =

Best Regards,
Dong-Jae Kang
