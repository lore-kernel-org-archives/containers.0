From: paolo <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: [PATCH RFC RESEND 00/14] New version of the BFQ I/O Scheduler
Date: Tue, 27 May 2014 14:42:24 +0200
Message-ID: <1401194558-5283-1-git-send-email-paolo.valente__39906.613113317$1401197783$gmane$org@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>

[Re-posting, previous attempt seems to have partially failed]

Hi,
this patchset introduces the last version of BFQ, a proportional-share
storage-I/O scheduler. BFQ also supports hierarchical scheduling with
a cgroups interface. The first version of BFQ was submitted a few
years ago [1]. It is denoted as v0 in the patches, to distinguish it
from the version I am submitting now, v7r4. In particular, the first
four patches introduce BFQ-v0, whereas the remaining patches turn it
progressively into BFQ-v7r4. Here are some nice features of this last
version.

Low latency for interactive applications

According to our results, regardless of the actual background
workload, for interactive tasks the storage device is virtually as
responsive as if it was idle. For example, even if one or more of the
following background workloads are being executed:
- one or more large files are being read or written,
- a tree of source files is being compiled,
- one or more virtual machines are performing I/O,
- a software update is in progress,
- indexing daemons are scanning filesystems and updating their
  databases,
starting an application or loading a file from within an application
takes about the same time as if the storage device was idle. As a
comparison, with CFQ, NOOP or DEADLINE, and in the same conditions,
applications experience high latencies, or even become unresponsive
until the background workload terminates (also on SSDs).

Low latency for soft real-time applications

Also soft real-time applications, such as audio and video
players/streamers, enjoy low latency and drop rate, regardless of the
storage-device background workload. As a consequence, these
applications do not suffer from almost any glitch due to the
background workload.

High throughput

On hard disks, BFQ achieves up to 30% higher throughput than CFQ, and
up to 150% higher throughput than DEADLINE and NOOP, with half of the
parallel workloads considered in our tests. With the rest of the
workloads, and with all the workloads on flash-based devices, BFQ
achieves instead about the same throughput as the other schedulers.

Strong fairness guarantees (already provided by BFQ-v0)

As for long-term guarantees, BFQ distributes the device throughput
(and not just the device time) as desired to I/O-bound applications,
with any workload and regardless of the device parameters.

What allows BFQ to provide the above features is its accurate
scheduling engine (patches 1-4), combined with a set of simple
heuristics and improvements (patches 5-14).  A 15-minute demo of the
performance of BFQ is available here [2]. I made this demo with an
older version of BFQ (v3r4) and under Linux 3.4.0. We have further
improved BFQ since then. The performance of the last version of BFQ is
shown, e.g., through some graphs here [3], under 3.14.0, compared
against CFQ, DEADLINE and NOOP, and on: a fast and a slow hard disk, a
RAID1, an SSD, a microSDHC Card and an eMMC. As an example, our
results on the SSD are reported also in a table at the end of this
email. Finally, details on how BFQ and its components work are
provided in the descriptions of the patches. An organic description of
the main BFQ algorithm and of most of its features can instead be
found in this paper [4].

Finally, as for testing in everyday use, BFQ is the default I/O
scheduler in, e.g., Manjaro, Sabayon, OpenMandriva and Arch Linux ARM
in some NAS boxes, plus several kernel forks for PCs and
smartphones. BFQ is instead optionally available in, e.g., Arch,
PCLinuxOS and Gentoo. In addition, we record a few tens of downloads
per day from people using other distributions. The feedback received
so far basically confirms the expected latency drop and throughput
boost.

Paolo

Results on a Plextor PX-256M5S SSD

The first two rows of the next table report the aggregate throughput
achieved by BFQ, CFQ, DEADLINE and NOOP, while ten parallel processes
read, either sequentially or randomly, a separate portion of the
memory blocks each. These processes read directly from the device, and
no process performs writes, to avoid writing large files repeatedly
and wearing out the SSD during the many tests done. As can be seen,
all schedulers achieve about the same throughput with sequential
readers, whereas, with random readers, the throughput slightly grows
as the complexity, and hence the execution time, of the schedulers
decreases. In fact, with random readers, the number of IOPS is
extremely higher, and all CPUs spend all the time either executing
instructions or waiting for I/O (the total idle percentage is
0). Therefore, the processing time of I/O requests influences the
maximum throughput achievable.

The remaining rows report the cold-cache start-up time experienced by
various applications while one of the above two workloads is being
executed in parallel. In particular, "Start-up time 10 seq/rand"
stands for "Start-up time of the application at hand while 10
sequential/random readers are running". A timeout fires, and the test
is aborted, if the application does not start within 60 seconds; so,
in the table, '>60' means that the application did not start before
the timeout fired.

With sequential readers, the performance gap between BFQ and the other
schedulers is remarkable. Background workloads are intentionally very
heavy, to show the performance of the schedulers in somewhat extreme
conditions. Differences are however still significant also with
lighter workloads, as shown, e.g., here [3] for slower devices.

-----------------------------------------------------------------------------
|                      SCHEDULER                    |        Test           |
-----------------------------------------------------------------------------
|    BFQ     |    CFQ     |  DEADLINE  |    NOOP    |                       |
-----------------------------------------------------------------------------
|            |            |            |            | Aggregate Throughput  |
|            |            |            |            |       [MB/s]          |
|    399     |    400     |    400     |    400     |  10 raw seq. readers  |
|    191     |    193     |    202     |    203     | 10 raw random readers |
-----------------------------------------------------------------------------
|            |            |            |            | Start-up time 10 seq  |
|            |            |            |            |       [sec]           |
|    0.21    |    >60     |    1.91    |    1.88    |      xterm            |
|    0.93    |    >60     |    10.2    |    10.8    |     oowriter          |
|    0.89    |    >60     |    29.7    |    30.0    |      konsole          |
-----------------------------------------------------------------------------
|            |            |            |            | Start-up time 10 rand |
|            |            |            |            |       [sec]           |
|    0.20    |    0.30    |    0.21    |    0.21    |      xterm            |
|    0.81    |    3.28    |    0.80    |    0.81    |     oowriter          |
|    0.88    |    2.90    |    1.02    |    1.00    |      konsole          |
-----------------------------------------------------------------------------

[1] https://lkml.org/lkml/2008/4/1/234
    https://lkml.org/lkml/2008/11/11/148

[2] http://youtu.be/J-e7LnJblm8

[3] http://www.algogroup.unimo.it/people/paolo/disk_sched/results.php

[4] P. Valente and M. Andreolini, "Improving Application
    Responsiveness with the BFQ Disk I/O Scheduler", Proceedings of
    the 5th Annual International Systems and Storage Conference
    (SYSTOR '12), June 2012.
    Slightly extended version:
http://www.algogroup.unimo.it/people/paolo/disk_sched/bf1-v1-suite-results.pdf

Arianna Avanzini (1):
  block, bfq: add Early Queue Merge (EQM)

Fabio Checconi (4):
  block: kconfig update and build bits for BFQ
  block: introduce the BFQ-v0 I/O scheduler
  block: add hierarchical-support option to kconfig
  block, bfq: add full hierarchical scheduling and cgroups support

Paolo Valente (9):
  block, bfq: improve throughput boosting
  block, bfq: modify the peak-rate estimator
  block, bfq: add more fairness to boost throughput and reduce latency
  block, bfq: improve responsiveness
  block, bfq: reduce I/O latency for soft real-time applications
  block, bfq: preserve a low latency also with NCQ-capable drives
  block, bfq: reduce latency during request-pool saturation
  block, bfq: boost the throughput on NCQ-capable flash-based devices
  block, bfq: boost the throughput with random I/O on NCQ-capable HDDs

 block/Kconfig.iosched         |   32 +
 block/Makefile                |    1 +
 block/bfq-cgroup.c            |  909 ++++++++++
 block/bfq-ioc.c               |   36 +
 block/bfq-iosched.c           | 3802 +++++++++++++++++++++++++++++++++++++++++
 block/bfq-sched.c             | 1104 ++++++++++++
 block/bfq.h                   |  729 ++++++++
 include/linux/cgroup_subsys.h |    4 +
 8 files changed, 6617 insertions(+)
 create mode 100644 block/bfq-cgroup.c
 create mode 100644 block/bfq-ioc.c
 create mode 100644 block/bfq-iosched.c
 create mode 100644 block/bfq-sched.c
 create mode 100644 block/bfq.h

-- 
1.9.2
