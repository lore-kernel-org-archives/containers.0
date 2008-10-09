From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 0/2] dm-ioband: I/O bandwidth controller v1.7.0:
	Introduction
Date: Thu, 09 Oct 2008 21:14:14 +0900 (JST)
Message-ID: <20081009.211414.193713198.ryov__42321.2045491256$1223554662$gmane$org@valinux.co.jp>
References: <2891419e0810080129sb6b35y11362f4bef71c174@mail.gmail.com>
	<20081008.194022.226783199.ryov@valinux.co.jp>
	<2891419e0810082315v28f2f4cbu5f95230db3be0bc1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2891419e0810082315v28f2f4cbu5f95230db3be0bc1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Dong-Jae,

> So, I tested dm-ioband and bio-cgroup patches with another IO testing
> tool, xdd ver6.5(http://www.ioperformance.com/),  after your reply.
> Xdd supports O_DIRECT mode and time limit options.
> I think, personally, it is proper tool for testing of IO controllers
> in Linux Container ML.

Xdd is really useful for me. Thanks for letting me know.

> And I found some strange points in test results. In fact, it will be
> not strange for other persons^^
> 
> 1. dm-ioband can control IO bandwidth well in O_DIRECT mode(read and
> write), I think the result is very reasonable. but it can't control it
> in Buffered mode when I checked just only output of xdd. I think
> bio-cgroup patches is for solving the problems, is it right? If so,
> how can I check or confirm the role of bio-cgroup patches?
>
> 2. As showed in test results, the IO performance in Buffered IO mode
> is very low compared with it in O_DIRECT mode. In my opinion, the
> reverse case is more natural in real life.
> Can you give me a answer about it?

Your results show all xdd programs belong to the same cgroup,
could you explain me in detail about your test procedure?

To know how many I/Os are actually issued to a physical device in
buffered mode within a measurement period, you should check the
/sys/block/<dev>/stat file just before starting a test program and
just after the end of the test program. The contents of the stat file
is described in the following document:
   kernel/Documentation/block/stat.txt

> 3. Compared with physical bandwidth(when it is checked with one
> process and without dm-ioband device), the sum of the bandwidth by
> dm-ioband has very considerable gap with the physical bandwidth. I
> wonder the reason. Is it overhead of dm-ioband or bio-cgroup patches?
> or Are there any another reasons?

The followings are the results on my PC with SATA disk, and there is
no big difference between with and without dm-ioband. Please try the
same thing if you have time.

without dm-ioband
=================
# xdd.linux -op write -queuedepth 16 -targets 1 /dev/sdb1 \
  -reqsize 8 -numreqs 128000 -verbose -timelimit 30 -dio -randomize

T  Q       Bytes      Ops    Time      Rate    IOPS   Latency
%CPU  OP_Type    ReqSize
0 16   140001280    17090    30.121     4.648     567.38    0.0018
0.01   write        8192

with dm-ioband
==============
* cgroup1 (weight 10)
# cat /cgroup/1/bio.id
1
# echo $$ > /cgroup/1/tasks
# xdd.linux -op write -queuedepth 16 -targets 1 /dev/mapper/ioband1
  -reqsize 8 -numreqs 128000 -verbose -timelimit 30 -dio -randomize
T  Q       Bytes      Ops    Time      Rate      IOPS   Latency
%CPU  OP_Type    ReqSize     
0 16    14393344     1757    30.430     0.473      57.74    0.0173
0.00   write        8192 

* cgroup2 (weight 20)
# cat /cgroup/2/bio.id
2
# echo $$ > /cgroup/2/tasks
# xdd.linux -op write -queuedepth 16 -targets 1 /dev/mapper/ioband1
  -reqsize 8 -numreqs 128000 -verbose -timelimit 30 -dio -randomize
T  Q       Bytes      Ops    Time      Rate      IOPS   Latency
%CPU  OP_Type    ReqSize     
0 16    44113920     5385    30.380     1.452     177.25    0.0056
0.00   write        8192 

* cgroup3 (weight 60)
# cat /cgroup/3/bio.id
3
# echo $$ > /cgroup/3/tasks
# xdd.linux -op write -queuedepth 16 -targets 1 /dev/mapper/ioband1
  -reqeize 8 -numreqs 128000 -verbose -timelimit 30 -dio -randomize
T  Q       Bytes      Ops    Time      Rate      IOPS   Latency
%CPU  OP_Type    ReqSize     
0 16    82485248    10069    30.256     2.726     332.79    0.0030
0.00   write        8192 

Total
=====
                  Bytes        Ops    Rate   IOPS
  w/o dm-ioband  140001280    17090  4.648  567.38
  w/  dm-ioband  140992512    17211  4.651  567.78

> > Could you give me the O_DIRECT patch?
> >
> Of course, if you want. But it is nothing
> Tiobench tool is very simple and light source code, so I just add the
> O_DIRECT option in tiotest.c of tiobench testing tool.
> Anyway, after I make a patch file, I send it to you

Thank you very much!

Ryo Tsuruta
