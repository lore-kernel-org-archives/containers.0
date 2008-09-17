From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH -mm 0/6] cgroup: block device i/o controller (v10)
Date: Wed, 17 Sep 2008 13:05:22 +0200
Message-ID: <1221649528-8519-1-git-send-email-righi.andrea__27222.5430388518$1221649680$gmane$org@gmail.com>
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

Tested against 2.6.27-rc5-mm1.

The all-in-one patch (and previous versions) can be found at:
http://download.systemimager.org/~arighi/linux/patches/io-throttle/

Changelog: (v9 -> v10)
* fix a bug to correctly throttle small direct-IO writes
* fix: do not add a new limiting rule if the limit is 0 (unlimited)
* do not report time values directly in jiffies, always use clock_t
* remove a spinlock in struct iothrottle (we always hold cgroup_lock() when
  using it for RCU update, so an additional spinlock is not needed)
* use page_cgroup functionality provided by memory cgroup controller to charge
  the right cgroup of asynchronous i/o activity (e.g. pdflush writebacks)
* code simplification in cgroup_io_throttle()
* removed a lot of experimental stuff introduced in the previous version
* update documentation

TODO:
* Implement a rbtree per request queue; all the requests queued to the I/O
  subsystem first will go in this rbtree. Then based on cgroup grouping and
  control policy dispatch the requests and pass them to the elevator associated
  with the queue. This would allow to provide both bandwidth limiting and
  proportional bandwidth functionalities using a quite generic approach
  (suggested by Vivek Goyal)

* Improve fair throttling: distribute the time to sleep among all the tasks of
  a cgroup that exceeded the I/O limits, depending of the amount of IO activity
  previously generated in the past by each task (see task_io_accounting)

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
