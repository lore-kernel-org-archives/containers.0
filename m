From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC][PATCH -mm 0/5] cgroup: block device i/o controller (v9)
Date: Wed, 27 Aug 2008 18:07:32 +0200
Message-ID: <1219853257-11052-1-git-send-email-righi.andrea__5702.84529026157$1219853393$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <>
References: <>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


The objective of the i/o controller is to improve i/o performance
predictability of different cgroups sharing the same block devices.

Respect to other priority/weight-based solutions the approach used by this
controller is to explicitly choke applications' requests that directly (or
indirectly) generate i/o activity in the system.

The direct bandwidth and/or iops limiting method has the advantage of improving
the performance predictability at the cost of reducing, in general, the overall
performance of the system (in terms of throughput).

Detailed informations about design, its goal and usage are described in the
documentation.

Patchset against 2.6.27-rc1-mm1.

The all-in-one patch (and previous versions) can be found at:
http://download.systemimager.org/~arighi/linux/patches/io-throttle/

This patchset is an experimental implementation, it includes functional
differences respect to the previous versions (see the changelog below), and I
haven't done much testing yet. So, comments are really welcome.

Changelog: (v8 -> v9)

* introduce struct res_counter_ratelimit as a generic structure to implement
  throttling-based cgroup subsystems
* removed the throttling hooks from the page cache (set_page_dirty): set a
  single throttling hook in submit_bio() both for read and write operations; a
  generic process that is dirtying pages on a limited block device (for the
  cgroup it belongs to) is forced to flush the same amount of pages back to the
  block device (in this way write operations are forced to occur in the same IO
  context of the process that actually generated the IO)
* collect per cgroup, block device and task throttling statistics (throttle
  counter and total time slept for throttling) and export them to userspace
  through blockio.throttlcnt (in the cgroup filesystem) and
  /proc/PID/io-throttle-stat (per-task statistics)
* fair throttling: simple attempt to distribute the sleeps equally among all
  the tasks belonging to the same cgroup; instead of imposing a sleep to the
  first task that exceeds the IO limits, the time to sleep is divided by the
  number of tasks present in the same cgroup

TODO:

* Try to push down the throttling and implement it directly in the I/O
  schedulers, using bio-cgroup (http://people.valinux.co.jp/~ryov/bio-cgroup/)
  to keep track of the right cgroup context. This approach could lead to more
  memory consumption and increases the number of dirty pages (hard/slow to
  reclaim pages) in the system, since dirty-page ratio in memory is not
  limited. This could even lead to potential OOM conditions, but these problems
  can be resolved directly into the memory cgroup subsystem

* Handle I/O generated by kswapd: at the moment there's no control on the I/O
  generated by kswapd; try to use the page_cgroup functionality of the memory
  cgroup controller to track this kind of I/O and charge the right cgroup when
  pages are swapped in/out

* Improve fair throttling: distribute the time to sleep among all the tasks of
  a cgroup that exceeded the I/O limits, depending of the amount of IO activity
  generated in the past by each task (see task_io_accounting)

* Try to reduce the cost of calling cgroup_io_throttle() on every submit_bio();
  this is not too much expensive, but the call of task_subsys_state() has
  surely a cost. A possible solution could be to temporarily account I/O in the
  current task_struct and call cgroup_io_throttle() only on each X MB of I/O.
  Or on each Y number of I/O requests as well. Better if both X and/or Y can be
  tuned at runtime by a userspace tool

* Think an alternative design for general purpose usage; special purpose usage
  right now is restricted to improve I/O performance predictability and
  evaluate more precise response timings for applications doing I/O. To a large
  degree the block I/O bandwidth controller should implement a more complex
  logic to better evaluate real I/O operations cost, depending also on the
  particular block device profile (i.e. USB stick, optical drive, hard disk,
  etc.). This would also allow to appropriately account I/O cost for seeky
  workloads, respect to large stream workloads. Instead of looking at the
  request stream and try to predict how expensive the I/O cost will be, a
  totally different approach could be to collect request timings (start time /
  elapsed time) and based on collected informations, try to estimate the I/O
  cost and usage

-Andrea
