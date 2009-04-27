From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH] range-bw: Another I/O scheduling policy of dm-ioband
	supporting the predicable I/O bandwidth (range bandwidth)
Date: Mon, 27 Apr 2009 20:12:14 +0900 (JST)
Message-ID: <20090427.201214.39166983.ryov@valinux.co.jp>
References: <2891419e0904230210w40482535ma3fc25c1e429969d@mail.gmail.com>
	<20090424.185823.104059944.ryov@valinux.co.jp>
	<2891419e0904270158n71b25271p6094feba70d0555d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2891419e0904270158n71b25271p6094feba70d0555d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

> I wonder your test configuration and environment.
> Your result  is some strange for me, because I didn't use the testing tool, fio.
> I have used xdd, bonnie++ and tiobench during the test.
> 
> So, I will try to evaluate range-bw using fio, to do that, I need to
> know your configuration and basic environment in briefly
> if it don't bother you, can you give me the information?

I used fio 1.22. The below is a script which I actually ran.

  #!/bin/sh
  dev1=/dev/sdb4 # SATA disk
  echo "0 $(sudo blockdev --getsize $dev1) ioband $dev1 share2 0 0
    cgroup range-bw 0" | sudo dmsetup create ioband1

  arg="--time_based --runtime=10 --ioengine=libaio --iodepth=50 \
       --direct=1 --norandommap"

  dmsetup message ioband1 0 attach 2
  dmsetup message ioband1 0 attach 3
  dmsetup message ioband1 0 min-bw 2:100
  dmsetup message ioband1 0 max-bw 2:100
  dmsetup message ioband1 0 min-bw 3:200
  dmsetup message ioband1 0 max-bw 3:200

  echo $$ > /cgroup/grp1/tasks
  fio $arg --rw=randread --name=grp1 --filename=/dev/mapper/ioband1 \
          --output=r2-1.log &
  echo $$ > /cgroup/grp2/tasks
  fio $arg --rw=randread --name=grp2 --filename=/dev/mapper/ioband1 \
          --output=r2-2.log &
  wait

Please feel free to ask me if you need more information.
 
> and I attached the result of basic evaluation of range-bw using xdd
> 6.5.(Test Result for range-bw_english.pdf)
> it was performed to evaluate the basic functionalities in one process per group.

Thanks.

> actually, more evaluation is need in specfic envinronment like as
> massive I/O by huge processes in each group.
> and it is going on now

I'm look forward to seeing the results.

Thanks,
Ryo Tsuruta
