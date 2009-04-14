From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/9] cgroup: io-throttle controller (v13)
Date: Tue, 14 Apr 2009 22:21:11 +0200
Message-ID: <1239740480-28125-1-git-send-email-righi.andrea__22680.0727112733$1239740698$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Objective
~~~~~~~~~
The objective of the io-throttle controller is to improve IO performance
predictability of different cgroups that share the same block devices.

State of the art (quick overview)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
A recent work made by Vivek propose a weighted BW solution introducing
fair queuing support in the elevator layer and modifying the existent IO
schedulers to use that functionality
(https://lists.linux-foundation.org/pipermail/containers/2009-March/016129.html).

For the fair queuing part Vivek's IO controller makes use of the BFQ
code as posted by Paolo and Fabio (http://lkml.org/lkml/2008/11/11/148).

The dm-ioband controller by the valinux guys is also proposing a
proportional ticket-based solution fully implemented at the device
mapper level (http://people.valinux.co.jp/~ryov/dm-ioband/).

The bio-cgroup patch (http://people.valinux.co.jp/~ryov/bio-cgroup/) is
a BIO tracking mechanism for cgroups, implemented in the cgroup memory
subsystem. It is maintained by Ryo and it allows dm-ioband to track
writeback requests issued by kernel threads (pdflush).

Another work by Satoshi implements the cgroup awareness in CFQ, mapping
per-cgroup priority to CFQ IO priorities and this also provide only the
proportional BW support (http://lwn.net/Articles/306772/).

Please correct me or integrate if I missed someone or something. :)

Proposed solution
~~~~~~~~~~~~~~~~~
Respect to other priority/weight-based solutions the approach used by
this controller is to explicitly choke applications' requests that
directly or indirectly generate IO activity in the system (this
controller addresses both synchronous IO and writeback/buffered IO).

The bandwidth and iops limiting method has the advantage of improving
the performance predictability at the cost of reducing, in general, the
overall performance of the system in terms of throughput.

IO throttling and accounting is performed during the submission of IO
requests and it is independent of the particular IO scheduler.

Detailed informations about design, goal and usage are described in the
documentation (see [PATCH 1/9]).

Implementation
~~~~~~~~~~~~~~
Patchset against latest Linus' git:

  [PATCH 0/9] cgroup: block device IO controller (v13)
  [PATCH 1/9] io-throttle documentation
  [PATCH 2/9] res_counter: introduce ratelimiting attributes
  [PATCH 3/9] bio-cgroup controller
  [PATCH 4/9] support checking of cgroup subsystem dependencies
  [PATCH 5/9] io-throttle controller infrastructure
  [PATCH 6/9] kiothrottled: throttle buffered (writeback) IO
  [PATCH 7/9] io-throttle instrumentation
  [PATCH 8/9] export per-task io-throttle statistics to userspace
  [PATCH 9/9] ext3: do not throttle metadata and journal IO

The v13 all-in-one patch (and previous versions) can be found at:
http://download.systemimager.org/~arighi/linux/patches/io-throttle/

There are some consistent changes in this patchset respect to the
previous version.

Thanks to the Gui Jianfeng's contribution the io-throttle controller now
uses bio-cgroup to track buffered (writeback) IO, instead of the memory
cgroup controller, and it is also possible to mount the memcg,
bio-cgroup and io-throttle in different mount points (see also
http://lwn.net/Articles/308108/).

Moreover, a kernel thread (kiothrottled) has been introduced to schedule
throttled writeback requests asynchronously. This allow to smooth the
bursty IO generated by the buch of pdflush's writeback requests. All
those requests are added into a rbtree and dispatched asynchronously by
kiothrottled using a deadline-based policy.

The kiothrottled scheduler can be improved in future versions to
implement a proportional/weighted IO scheduling, preferably with the
feedback of the existent IO schedulers.

Experimental results
~~~~~~~~~~~~~~~~~~~~
Following few quick experimental results with writeback IO. Results with
synchronous IO (read and write) are more or less the same obtained with
the previous io-throttle version.

Two cgroups:

cgroup-a: 4MB BW limit on /dev/sda
cgroup-b: 2MB BW limit on /dev/sda

Run 2 concurrent "dd"s (1 in cgroup-a, 1 in cgroup-b) to simulate a
large write stream and generate many writeback IO requests.

Expected results: 6MB/s from the disk's point of view, 4MB/s and 2MB/s
from the application's point of view.

Experimental results:

* From the disk's point of view (dstat -d -D sda1):

with kiothrottled	without kiothrottled
--dsk/sda1-		--dsk/sda1-
 read  writ		 read  writ
   0  6252k		   0  9688k
   0  6904k		   0  6488k
   0  6320k		   0  2320k
   0  6144k		   0  8192k
   0  6220k		   0    10M
   0  6212k		   0  5208k
   0  6228k		   0  1940k
   0  6212k		   0  1300k
   0  6312k		   0  8100k
   0  6216k		   0  8640k
   0  6228k		   0  6584k
   0  6648k		   0  2440k
       ...		      ...
      -----		      ----
 avg: 6325k		 avg: 5928k

* From the application's point of view:

- with kiothrottled -
cgroup-a)
$ dd if=/dev/zero of=4m-bw.out bs=1M
196+0 records in
196+0 records out
205520896 bytes (206 MB) copied, 40.762 s, 5.0 MB/s

cgroup-b)
$ dd if=/dev/zero of=2m-bw.out bs=1M
97+0 records in
97+0 records out
101711872 bytes (102 MB) copied, 37.3826 s, 2.7 MB/s

- without kiothrottled -
cgroup-a)
$ dd if=/dev/zero of=4m-bw.out bs=1M
133+0 records in
133+0 records out
139460608 bytes (139 MB) copied, 39.1345 s, 3.6 MB/s

cgroup-b)
$ dd if=/dev/zero of=2m-bw.out bs=1M
70+0 records in
70+0 records out
73400320 bytes (73 MB) copied, 39.0422 s, 1.9 MB/s

Changelog (v12 -> v13)
~~~~~~~~~~~~~~~~~~~~~~
* rewritten on top of bio-cgroup to track writeback IO
* now it is possible to mount memory, bio-cgroup and io-throttle cgroups in
  different mount points
* introduce a dedicated kernel thread (kiothrottled) to throttle writeback IO
* updated documentation

-Andrea
