From: "Dong-Jae Kang" <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] dm-ioband: I/O bandwidth controller v1.7.0:
	Introduction
Date: Thu, 9 Oct 2008 15:15:18 +0900
Message-ID: <2891419e0810082315v28f2f4cbu5f95230db3be0bc1__27454.4415450238$1223533150$gmane$org@mail.gmail.com>
References: <20081003.143749.193701570.ryov@valinux.co.jp>
	<2891419e0810080129sb6b35y11362f4bef71c174@mail.gmail.com>
	<20081008.194022.226783199.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081008.194022.226783199.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Content-Disposition: inline
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
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Ryo tsuruta.
Thank you for your fast reply.
Your comments was very helpful for me ^^

> 2. tiotest is not an appropriate tool to see how bandwith is shared
>   among devices, becasue those three tiotests don't finish at the
>   same time, a process which issues I/Os to a device with the highest
>   weight finishes first, so you can't see how bandwidth is shared
>   from the results of each tiotest.

Yes, you are right, and it is good point for correct IO testing in
dm-ioband and other controllers.
So, I tested dm-ioband and bio-cgroup patches with another IO testing
tool, xdd ver6.5(http://www.ioperformance.com/),  after your reply.
Xdd supports O_DIRECT mode and time limit options.
I think, personally, it is proper tool for testing of IO controllers
in Linux Container ML.

And I found some strange points in test results. In fact, it will be
not strange for other persons^^

1. dm-ioband can control IO bandwidth well in O_DIRECT mode(read and
write), I think the result is very reasonable. but it can't control it
in Buffered mode when I checked just only output of xdd. I think
bio-cgroup patches is for solving the problems, is it right? If so,
how can I check or confirm the role of bio-cgroup patches?

2. As showed in test results, the IO performance in Buffered IO mode
is very low compared with it in O_DIRECT mode. In my opinion, the
reverse case is more natural in real life.
Can you give me a answer about it?

3. Compared with physical bandwidth(when it is checked with one
process and without dm-ioband device), the sum of the bandwidth by
dm-ioband has very considerable gap with the physical bandwidth. I
wonder the reason=85. Is it overhead of dm-ioband or bio-cgroup patches?
or Are there any another reasons?

the new testing result is like below.

- Testing target : the patches of dm-ioband ver1.7.0 and bio-cgroup
latest version

- Testing Cases
1.Read and write stress test in O_DIRECT IO mode
2.Read and write stress test in not Buffered IO mode

- Testing tool : xdd ver6.5 ( http://www.ioperformance.com/ )

* Total bandwidth

Read IO
T  Q       Bytes      Ops    Time      Rate      IOPS   Latency
%CPU  OP_Type    ReqSize
0  1    1048576000   128000    15.700    66.790     8153.04    0.0001
   0.00   read        8192
0  1    1048576000   128000    15.700    66.790     8153.04    0.0001
   0.00   read        8192
1  1    1048576000   128000    15.700    66.790     8153.04    0.0001
   0.00   read        8192

Write IO
T  Q       Bytes      Ops    Time      Rate      IOPS   Latency
%CPU  OP_Type    ReqSize
0  1    1048576000   128000    14.730    71.185     8689.59    0.0001
   0.00   write        8192
0  1    1048576000   128000    14.730    71.185     8689.59    0.0001
   0.00   write        8192
1  1    1048576000   128000    14.730    71.185     8689.59    0.0001
   0.00   write        8192

* Read IO test in O_DIRECT mode

Command :
xdd.linux -op read -targets 1 /dev/mapper/ioband1 -reqsize 8 -numreqs
128000 -verbose -timelimit 30 =96dio

Result :
cgroup1 (weight : 10)
T  Q       Bytes       Ops      Time      Rate      IOPS     Latency
 %CPU  OP_Type    ReqSize
0  1      84549632    10321    30.086     2.810     343.05    0.0029
  0.00   read        8192
0  1      84549632    10321    30.086     2.810     343.05    0.0029
  0.00   read        8192
1  1      84549632    10321    30.086     2.810     343.05    0.0029
  0.00   read        8192

cgroup1 (weight : 30)
T  Q       Bytes       Ops      Time      Rate      IOPS     Latency
  %CPU  OP_Type    ReqSize
0  1     256425984    31302    30.089     8.522     1040.31    0.0010
   0.00   read        8192
0  1     256425984    31302    30.089     8.522     1040.31    0.0010
   0.00   read        8192
1  1     256425984    31302    30.089     8.522     1040.31    0.0010
   0.00   read        8192

cgroup1 (weight : 60)
T  Q       Bytes       Ops      Time      Rate      IOPS      Latency
   %CPU  OP_Type    ReqSize
0  1     483467264    59017    30.000    16.116     1967.22    0.0005
   0.00   read        8192
0  1     483467264    59017    30.000    16.116     1967.22    0.0005
   0.00   read        8192
1  1     483467264    59017    30.000    16.116     1967.22    0.0005
   0.00   read        8192

* Write IO test in O_DIRECT mode

Command :
xdd.linux -op write -targets 1 /dev/mapper/ioband1 -reqsize 8 -numreqs
128000 -verbose -timelimit 30 =96dio

Result :
cgroup1 (weight : 10)
T  Q       Bytes      Ops    Time      Rate      IOPS   Latency
%CPU  OP_Type    ReqSize
0  1     106790912    13036    30.034     3.556     434.04    0.0023
  0.00   write        8192
0  1     106790912    13036    30.034     3.556     434.04    0.0023
  0.00   write        8192
1  1     106790912    13036    30.034     3.556     434.04    0.0023
  0.00   write        8192

cgroup1 (weight : 30)
T  Q       Bytes      Ops    Time      Rate      IOPS   Latency
%CPU  OP_Type    ReqSize
0  1     347176960    42380    30.006    11.570     1412.40    0.0007
   0.00   write        8192
0  1     347176960    42380    30.006    11.570     1412.40    0.0007
   0.00   write        8192
1  1     347176960    42380    30.006    11.570     1412.40    0.0007
   0.00   write        8192

cgroup1 (weight : 60)
T  Q       Bytes      Ops    Time      Rate      IOPS   Latency
%CPU  OP_Type    ReqSize
0  1     636256256    77668    30.000    21.209     2588.93    0.0004
   0.00   write        8192
0  1     636256256    77668    30.000    21.209     2588.93    0.0004
   0.00   write        8192
1  1     636256256    77668    30.000    21.209     2588.93    0.0004
   0.00   write        8192

* Read IO test in Buffered IO mode

Command :
xdd.linux -op read -targets 1 /dev/mapper/ioband1 -reqsize 8 -numreqs
128000 -verbose -timelimit 30

Result :
cgroup1 (weight : 10)
T  Q       Bytes      Ops    Time      Rate      IOPS   Latency
%CPU  OP_Type    ReqSize
0  1     161284096    19688    30.012     5.374     656.00    0.0015
  0.00   read        8192
0  1     161284096    19688    30.012     5.374     656.00    0.0015
  0.00   read        8192
1  1     161284096    19688    30.012     5.374     656.00    0.0015
  0.00   read        8192

cgroup1 (weight : 30)
T  Q       Bytes      Ops    Time      Rate      IOPS   Latency
%CPU  OP_Type    ReqSize
0  1     162816000    19875    30.005     5.426     662.38    0.0015
  0.00   read        8192
0  1     162816000    19875    30.005     5.426     662.38    0.0015
  0.00   read        8192
1  1     162816000    19875    30.005     5.426     662.38    0.0015
  0.00   read        8192

cgroup1 (weight : 60)
T  Q       Bytes      Ops    Time      Rate      IOPS   Latency
%CPU  OP_Type    ReqSize
0  1     167198720    20410    30.002     5.573     680.29    0.0015
  0.00   read        8192
0  1     167198720    20410    30.002     5.573     680.29    0.0015
  0.00   read        8192
1  1     167198720    20410    30.002     5.573     680.29    0.0015
  0.00   read        8192

* Write IO test in Buffered IO mode

Command :
xdd.linux -op write -targets 1 /dev/mapper/ioband1 -reqsize 8 -numreqs
128000 -verbose -timelimit 30

Result :
cgroup1 (weight : 10)
T  Q       Bytes      Ops    Time      Rate      IOPS   Latency
%CPU  OP_Type    ReqSize
0  1     550633472    67216    30.017    18.344     2239.30    0.0004
   0.00   write        8192
0  1     550633472    67216    30.017    18.344     2239.30    0.0004
   0.00   write        8192
1  1     550633472    67216    30.017    18.344     2239.30    0.0004
   0.00   write        8192

cgroup1 (weight : 30)
T  Q       Bytes      Ops    Time      Rate      IOPS   Latency
%CPU  OP_Type    ReqSize
0  1         32768        4    32.278     0.001       0.12    8.0694
  0.00   write        8192
0  1         32768        4    32.278     0.001       0.12    8.0694
  0.00   write        8192
1  1         32768        4    32.278     0.001       0.12    8.0694
  0.00   write        8192

cgroup1 (weight : 60)
T  Q       Bytes      Ops    Time      Rate      IOPS   Latency
%CPU  OP_Type    ReqSize
0  1       4505600      550    31.875     0.141      17.25    0.0580
  0.00   write        8192
0  1       4505600      550    31.875     0.141      17.25    0.0580
  0.00   write        8192
1  1       4505600      550    31.875     0.141      17.25    0.0580
  0.00   write        8192

>   I use iostat to see the time variation of bandiwdth. The followings
>   are the outputs of iostat just after starting three tiotests on the
>   same setting as yours.
>
>    # iostat -p dm-0 -p dm-1 -p dm-2 1
>    Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
>    dm-0           5430.00         0.00     10860.00          0      10860
>    dm-1          16516.00         0.00     16516.00          0      16516
>    dm-2          32246.00         0.00     32246.00          0      32246
>
>    avg-cpu:  %user   %nice %system %iowait  %steal   %idle
>               0.51    0.00   21.83   76.14    0.00    1.52
>
>    Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
>    dm-0           5720.00         0.00     11440.00          0      11440
>    dm-1          16138.00         0.00     16138.00          0      16138
>    dm-2          32734.00         0.00     32734.00          0      32734
>    ...
>

Thank you for your kindness ^^

>
> Could you give me the O_DIRECT patch?
>
Of course, if you want. But it is nothing
Tiobench tool is very simple and light source code, so I just add the
O_DIRECT option in tiotest.c of tiobench testing tool.
Anyway, after I make a patch file, I send it to you

Best Regards,
Dong-Jae Kang
