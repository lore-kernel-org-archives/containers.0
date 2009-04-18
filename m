From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/7] cgroup: io-throttle controller (v14)
Date: Sat, 18 Apr 2009 23:37:09 +0200
Message-ID: <1240090636-898-1-git-send-email-righi.andrea__3666.17642944238$1240091671$gmane$org@gmail.com>
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
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
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

  [PATCH 0/7] cgroup: block device IO controller (v14)
  [PATCH 1/7] io-throttle documentation
  [PATCH 2/7] res_counter: introduce ratelimiting attributes
  [PATCH 3/7] page_cgroup: provide a generic page tracking infrastructure
  [PATCH 4/7] io-throttle controller infrastructure
  [PATCH 5/7] kiothrottled: throttle buffered (writeback) IO
  [PATCH 6/7] io-throttle instrumentation
  [PATCH 7/7] export per-task io-throttle statistics to userspace

The v14 all-in-one patch, along with the previous versions, can be found at:
http://download.systemimager.org/~arighi/linux/patches/io-throttle/

What's new
~~~~~~~~~~
In this new version I've embedded the bio-cgroup code inside
io-throttle, providing the page_cgroup page tracking infrastructure.

This completely removes the complexity and the overhead of associating
multiple IO controllers (bio-cgroup groups and io-throttle groups) from
userspace, preserving the same tracking and throttling functionalities
for writeback IO. And it is also possibel to bind other cgroup
subsystems with io-throttle.

I've removed the tracking of IO generated by anonymous pages (swap), to
reduce the overhead of the page tracking functionality (and probably is
not a good idea to delay IO requests that come from swap-in/swap-out
operations).

I've also removed the ext3 specific patch to tag journal IO with
BIO_RW_META to never throttle such IO requests.

As suggested by Ted and Jens we need a more specific solution, where
filesystems inform the IO subsystem which IO requests come from tasks
that are holding filesystem exclusive resources (journal IO, metadata,
etc.). Then, the IO subsystem (both the IO scheduler and the IO
controller) will be able to dispatched those "special" requests at the
highest priority to avoid the classic priority inversion problems.

Changelog (v13 -> v14)
~~~~~~~~~~~~~~~~~~~~~~
* implemented the bio-cgroup functionality as pure infrastructure for page
  tracking capability
* removed the tracking and throttling of IO generated by anonymous pages (swap)
* updated documentation

Overall diffstat
~~~~~~~~~~~~~~~~
 Documentation/cgroups/io-throttle.txt |  417 +++++++++++++++++
 block/Makefile                        |    1 +
 block/blk-core.c                      |    8 +
 block/blk-io-throttle.c               |  822 +++++++++++++++++++++++++++++++++
 block/kiothrottled.c                  |  341 ++++++++++++++
 fs/aio.c                              |   12 +
 fs/buffer.c                           |    2 +
 fs/proc/base.c                        |   18 +
 include/linux/blk-io-throttle.h       |  144 ++++++
 include/linux/cgroup_subsys.h         |    6 +
 include/linux/memcontrol.h            |    6 +
 include/linux/mmzone.h                |    4 +-
 include/linux/page_cgroup.h           |   33 ++-
 include/linux/res_counter.h           |   69 ++-
 include/linux/sched.h                 |    7 +
 init/Kconfig                          |   16 +
 kernel/fork.c                         |    7 +
 kernel/res_counter.c                  |   72 +++
 mm/Makefile                           |    3 +-
 mm/bounce.c                           |    2 +
 mm/filemap.c                          |    2 +
 mm/memcontrol.c                       |    6 +
 mm/page-writeback.c                   |    2 +
 mm/page_cgroup.c                      |   95 ++++-
 mm/readahead.c                        |    3 +
 25 files changed, 2065 insertions(+), 33 deletions(-)

-Andrea
