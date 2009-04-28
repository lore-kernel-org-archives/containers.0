From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v15 0/7] cgroup: io-throttle controller
Date: Tue, 28 Apr 2009 10:43:47 +0200
Message-ID: <1240908234-15434-1-git-send-email-righi.andrea__13562.9661418081$1240908361$gmane$org@gmail.com>
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
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, tytso-3s7WtUTddSA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
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
documentation (see [PATCH 1/7]).

Implementation
~~~~~~~~~~~~~~
Patchset against latest Linus' git:

  [PATCH v15 0/7] cgroup: block device IO controller
  [PATCH v15 1/7] io-throttle documentation
  [PATCH v15 2/7] res_counter: introduce ratelimiting attributes
  [PATCH v15 3/7] page_cgroup: provide a generic page tracking infrastructure
  [PATCH v15 4/7] io-throttle controller infrastructure
  [PATCH v15 5/7] kiothrottled: throttle buffered (writeback) IO
  [PATCH v15 6/7] io-throttle instrumentation
  [PATCH v15 7/7] io-throttle: export per-task statistics to userspace

The v15 all-in-one patch, along with the previous versions, can be found at:
http://download.systemimager.org/~arighi/linux/patches/io-throttle/

Changelog (v14 -> v15)
~~~~~~~~~~~~~~~~~~~~~~
* performance optimization for direct IO (O_DIRECT): in submit_bio() instead of
  checking if the bio has been generated by the current task using the slow
  get_iothrottle_from_bio(), use the faster is_in_dio(), that simply check the
  value of task_struct->in_dio, set before submitting O_DIRECT requests and
  unset for.
* block tasks that have exceeded the cgroup limits also in
  balance_dirty_pages_ratelimited_nr(): when the submission of IO requests is
  blocked by io-throttle we also want to throttle the dirty page rate, to reduce
  the generation of hard reclaimable dirty pages in the system and prevent
  potential OOM conditions
* explicitly check if cgroup_lock() is held in the iothrottle block device list
  (suggested by: Paul E. McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>)
* fixed a build bug in page_cgroup.c when CONFIG_SPARSEMEM was not set
  (reported by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>)
* small styling fixes in res_counter

Overall diffstat
~~~~~~~~~~~~~~~~
 Documentation/cgroups/io-throttle.txt |  417 ++++++++++++++++
 block/Makefile                        |    1 +
 block/blk-core.c                      |    8 +
 block/blk-io-throttle.c               |  851 +++++++++++++++++++++++++++++++++
 block/kiothrottled.c                  |  341 +++++++++++++
 fs/aio.c                              |   12 +
 fs/buffer.c                           |    2 +
 fs/direct-io.c                        |    3 +
 fs/proc/base.c                        |   18 +
 include/linux/blk-io-throttle.h       |  168 +++++++
 include/linux/cgroup.h                |    1 +
 include/linux/cgroup_subsys.h         |    6 +
 include/linux/memcontrol.h            |    6 +
 include/linux/mmzone.h                |    4 +-
 include/linux/page_cgroup.h           |   33 ++-
 include/linux/res_counter.h           |   69 ++-
 include/linux/sched.h                 |    8 +
 init/Kconfig                          |   16 +
 kernel/cgroup.c                       |    9 +
 kernel/fork.c                         |    8 +
 kernel/res_counter.c                  |   73 +++
 mm/Makefile                           |    3 +-
 mm/bounce.c                           |    2 +
 mm/filemap.c                          |    2 +
 mm/memcontrol.c                       |    6 +
 mm/page-writeback.c                   |   13 +
 mm/page_cgroup.c                      |   96 ++++-
 mm/readahead.c                        |    3 +
 28 files changed, 2145 insertions(+), 34 deletions(-)

-Andrea
