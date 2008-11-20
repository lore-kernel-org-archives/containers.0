From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 2/7] Porting io-throttle v11 to 2.6.28-rc2-mm1
Date: Thu, 20 Nov 2008 19:09:52 +0800
Message-ID: <49254580.2060103__9532.01019806347$1227179765$gmane$org@cn.fujitsu.com>
References: <4925445C.10302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4925445C.10302-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Porting io-throttle v11 to 2.6.28-rc2-mm1

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 Documentation/controllers/io-throttle.txt |  409 ++++++++++++++++
 block/Makefile                            |    2 +
 block/blk-core.c                          |    4 +
 block/blk-io-throttle.c                   |  735 +++++++++++++++++++++++++++++
 fs/aio.c                                  |   12 +
 fs/direct-io.c                            |    3 +
 fs/proc/base.c                            |   18 +
 include/linux/blk-io-throttle.h           |   95 ++++
 include/linux/cgroup_subsys.h             |    6 +
 include/linux/memcontrol.h                |    5 +-
 include/linux/res_counter.h               |   69 ++-
 include/linux/sched.h                     |    7 +
 init/Kconfig                              |   10 +
 kernel/fork.c                             |    8 +
 kernel/res_counter.c                      |   73 +++-
 mm/memcontrol.c                           |   30 ++
 mm/page-writeback.c                       |    4 +
 mm/readahead.c                            |    3 +
 18 files changed, 1474 insertions(+), 19 deletions(-)
 create mode 100644 Documentation/controllers/io-throttle.txt
 create mode 100644 block/blk-io-throttle.c
 create mode 100644 include/linux/blk-io-throttle.h

diff --git a/Documentation/controllers/io-throttle.txt b/Documentation/controllers/io-throttle.txt
new file mode 100644
index 0000000..2a3bbd1
--- /dev/null
+++ b/Documentation/controllers/io-throttle.txt
@@ -0,0 +1,409 @@
+
+               Block device I/O bandwidth controller
+
+----------------------------------------------------------------------
+1. DESCRIPTION
+
+This controller allows to limit the I/O bandwidth of specific block devices for
+specific process containers (cgroups [1]) imposing additional delays on I/O
+requests for those processes that exceed the limits defined in the control
+group filesystem.
+
+Bandwidth limiting rules offer better control over QoS with respect to priority
+or weight-based solutions that only give information about applications'
+relative performance requirements. Nevertheless, priority based solutions are
+affected by performance bursts, when only low-priority requests are submitted
+to a general purpose resource dispatcher.
+
+The goal of the I/O bandwidth controller is to improve performance
+predictability from the applications' point of view and provide performance
+isolation of different control groups sharing the same block devices.
+
+NOTE #1: If you're looking for a way to improve the overall throughput of the
+system probably you should use a different solution.
+
+NOTE #2: The current implementation does not guarantee minimum bandwidth
+levels, the QoS is implemented only slowing down I/O "traffic" that exceeds the
+limits specified by the user; minimum I/O rate thresholds are supposed to be
+guaranteed if the user configures a proper I/O bandwidth partitioning of the
+block devices shared among the different cgroups (theoretically if the sum of
+all the single limits defined for a block device doesn't exceed the total I/O
+bandwidth of that device).
+
+----------------------------------------------------------------------
+2. USER INTERFACE
+
+A new I/O limitation rule is described using the files:
+- blockio.bandwidth-max
+- blockio.iops-max
+
+The I/O bandwidth (blockio.bandwidth-max) can be used to limit the throughput
+of a certain cgroup, while blockio.iops-max can be used to throttle cgroups
+containing applications doing a sparse/seeky I/O workload. Any combination of
+them can be used to define more complex I/O limiting rules, expressed both in
+terms of iops/s and bandwidth.
+
+The same files can be used to set multiple rules for different block devices
+relative to the same cgroup.
+
+The following syntax can be used to configure any limiting rule:
+
+# /bin/echo DEV:LIMIT:STRATEGY:BUCKET_SIZE > CGROUP/FILE
+
+- DEV is the name of the device the limiting rule is applied to.
+
+- LIMIT is the maximum I/O activity allowed on DEV by CGROUP; LIMIT can
+  represent a bandwidth limitation (expressed in bytes/s) when writing to
+  blockio.bandwidth-max, or a limitation to the maximum I/O operations per
+  second (expressed in iops/s) issued by CGROUP.
+
+  A generic I/O limiting rule for a block device DEV can be removed setting the
+  LIMIT to 0.
+
+- STRATEGY is the throttling strategy used to throttle the applications' I/O
+  requests from/to device DEV. At the moment two different strategies can be
+  used [2][3]:
+
+  0 = leaky bucket: the controller accepts at most B bytes (B = LIMIT * time)
+		    or O operations (O = LIMIT * time); further I/O requests
+		    are delayed scheduling a timeout for the tasks that made
+		    those requests.
+
+            Different I/O flow
+               | | |
+               | v |
+               |   v
+               v
+              .......
+              \     /
+               \   /  leaky-bucket
+                ---
+                |||
+                vvv
+             Smoothed I/O flow
+
+  1 = token bucket: LIMIT tokens are added to the bucket every seconds; the
+		    bucket can hold at the most BUCKET_SIZE tokens; I/O
+		    requests are accepted if there are available tokens in the
+		    bucket; when a request of N bytes arrives N tokens are
+		    removed from the bucket; if fewer than N tokens are
+		    available the request is delayed until a sufficient amount
+		    of token is available in the bucket.
+
+            Tokens (I/O rate)
+                o
+                o
+                o
+              ....... <--.
+              \     /    | Bucket size (burst limit)
+               \ooo/     |
+                ---   <--'
+                 |ooo
+    Incoming --->|---> Conforming
+    I/O          |oo   I/O
+    requests  -->|-->  requests
+                 |
+            ---->|
+
+  Leaky bucket is more precise than token bucket to respect the limits, because
+  bursty workloads are always smoothed. Token bucket, instead, allows a small
+  irregularity degree in the I/O flows (burst limit), and, for this, it is
+  better in terms of efficiency (bursty workloads are not smoothed when there
+  are sufficient tokens in the bucket).
+
+- BUCKET_SIZE is used only with token bucket (STRATEGY == 1) and defines the
+  size of the bucket in bytes (blockio.bandwidth-max) or in I/O operations
+  (blockio.iops-max).
+
+- CGROUP is the name of the limited process container.
+
+Also the following syntaxes are allowed:
+
+- remove an I/O bandwidth limiting rule
+# /bin/echo DEV:0 > CGROUP/blockio.bandwidth-max
+
+- configure a limiting rule using leaky bucket throttling (ignore bucket size):
+# /bin/echo DEV:LIMIT:0 > CGROUP/blockio.bandwidth-max
+
+- configure a limiting rule using token bucket throttling
+  (with bucket size == LIMIT):
+# /bin/echo DEV:LIMIT:1 > CGROUP/blockio.bandwidth-max
+
+2.2. Show I/O limiting rules
+
+All the defined rules and statistics for a specific cgroup can be shown reading
+the files blockio.bandwidth-max for bandwidth constraints and blockio.iops-max
+for I/O operations per second constraints.
+
+The following syntax is used:
+
+$ cat CGROUP/blockio.bandwidth-max
+MAJOR MINOR LIMIT STRATEGY LEAKY_STAT BUCKET_SIZE BUCKET_FILL TIME_DELTA
+
+- MAJOR is the major device number of DEV (defined above)
+
+- MINOR is the minor device number of DEV (defined above)
+
+- LIMIT, STRATEGY and BUCKET_SIZE are the same parameters defined above
+
+- LEAKY_STAT is the amount of bytes (blockio.bandwidth-max) or I/O operations
+  (blockio.iops-max) currently allowed by the I/O controller (only used with
+  leaky bucket strategy - STRATEGY == 0)
+
+- BUCKET_FILL represents the amount of tokens present in the bucket (only used
+  with token bucket strategy - STRATEGY == 1)
+
+- TIME_DELTA can be one of the following:
+  - the amount of jiffies elapsed from the last I/O request (token bucket)
+  - the amount of jiffies during which the bytes or the number of I/O
+    operations given by LEAKY_STAT have been accumulated (leaky bucket)
+
+Multiple per-block device rules are reported in multiple rows
+(DEVi, i = 1 ..  n):
+
+$ cat CGROUP/blockio.bandwidth-max
+MAJOR1 MINOR1 BW1 STRATEGY1 LEAKY_STAT1 BUCKET_SIZE1 BUCKET_FILL1 TIME_DELTA1
+MAJOR1 MINOR1 BW2 STRATEGY2 LEAKY_STAT2 BUCKET_SIZE2 BUCKET_FILL2 TIME_DELTA2
+...
+MAJORn MINORn BWn STRATEGYn LEAKY_STATn BUCKET_SIZEn BUCKET_FILLn TIME_DELTAn
+
+The same fields are used to describe I/O operations/sec rules. The only
+difference is that the cost of each I/O operation is scaled up by a factor of
+1000. This allows to apply better fine grained sleeps and provide a more
+precise throttling.
+
+$ cat CGROUP/blockio.iops-max
+MAJOR MINOR LIMITx1000 STRATEGY LEAKY_STATx1000 BUCKET_SIZEx1000 BUCKET_FILLx1000 TIME_DELTA
+...
+
+2.3. Additional I/O statistics
+
+Additional cgroup I/O throttling statistics are reported in
+blockio.throttlecnt:
+
+$ cat CGROUP/blockio.throttlecnt
+MAJOR MINOR BW_COUNTER BW_SLEEP IOPS_COUNTER IOPS_SLEEP
+
+ - MAJOR, MINOR are respectively the major and the minor number of the device
+   the following statistics refer to
+ - BW_COUNTER gives the number of times that the cgroup bandwidth limit of
+   this particular device was exceeded
+ - BW_SLEEP is the amount of sleep time measured in clock ticks (divide
+   by sysconf(_SC_CLK_TCK)) imposed to the processes of this cgroup that
+   exceeded the bandwidth limit for this particular device
+ - IOPS_COUNTER gives the number of times that the cgroup I/O operation per
+   second limit of this particular device was exceeded
+ - IOPS_SLEEP is the amount of sleep time measured in clock ticks (divide
+   by sysconf(_SC_CLK_TCK)) imposed to the processes of this cgroup that
+   exceeded the I/O operations per second limit for this particular device
+
+Example:
+$ cat CGROUP/blockio.throttlecnt
+8 0 0 0 0 0
+^ ^ ^ ^ ^ ^
+ \ \ \ \ \ \___iops sleep (in clock ticks)
+  \ \ \ \ \____iops throttle counter
+   \ \ \ \_____bandwidth sleep (in clock ticks)
+    \ \ \______bandwidth throttle counter
+     \ \_______minor dev. number
+      \________major dev. number
+
+Distinct statistics for each process are reported in
+/proc/PID/io-throttle-stat:
+
+$ cat /proc/PID/io-throttle-stat
+BW_COUNTER BW_SLEEP IOPS_COUNTER IOPS_SLEEP
+
+Example:
+$ cat /proc/$$/io-throttle-stat
+0 0 0 0
+^ ^ ^ ^
+ \ \ \ \_____global iops sleep (in clock ticks)
+  \ \ \______global iops counter
+   \ \_______global bandwidth sleep (clock ticks)
+    \________global bandwidth counter
+
+2.4. Examples
+
+* Mount the cgroup filesystem (blockio subsystem):
+  # mkdir /mnt/cgroup
+  # mount -t cgroup -oblockio blockio /mnt/cgroup
+
+* Instantiate the new cgroup "foo":
+  # mkdir /mnt/cgroup/foo
+  --> the cgroup foo has been created
+
+* Add the current shell process to the cgroup "foo":
+  # /bin/echo $$ > /mnt/cgroup/foo/tasks
+  --> the current shell has been added to the cgroup "foo"
+
+* Give maximum 1MiB/s of I/O bandwidth on /dev/sda for the cgroup "foo", using
+  leaky bucket throttling strategy:
+  # /bin/echo /dev/sda:$((1024 * 1024)):0:0 > \
+  > /mnt/cgroup/foo/blockio.bandwidth-max
+  # sh
+  --> the subshell 'sh' is running in cgroup "foo" and it can use a maximum I/O
+      bandwidth of 1MiB/s on /dev/sda
+
+* Give maximum 8MiB/s of I/O bandwidth on /dev/sdb for the cgroup "foo", using
+  token bucket throttling strategy, bucket size = 8MiB:
+  # /bin/echo /dev/sdb:$((8 * 1024 * 1024)):1:$((8 * 1024 * 1024)) > \
+  > /mnt/cgroup/foo/blockio.bandwidth-max
+  # sh
+  --> the subshell 'sh' is running in cgroup "foo" and it can use a maximum I/O
+      bandwidth of 1MiB/s on /dev/sda (controlled by leaky bucket throttling)
+      and 8MiB/s on /dev/sdb (controlled by token bucket throttling)
+
+* Run a benchmark doing I/O on /dev/sda and /dev/sdb; I/O limits and usage
+  defined for cgroup "foo" can be shown as following:
+  # cat /mnt/cgroup/foo/blockio.bandwidth-max
+  8 16 8388608 1 0 8388608 -522560 48
+  8 0 1048576 0 737280 0 0 216
+
+* Extend the maximum I/O bandwidth for the cgroup "foo" to 16MiB/s on /dev/sda:
+  # /bin/echo /dev/sda:$((16 * 1024 * 1024)):0:0 > \
+  > /mnt/cgroup/foo/blockio.bandwidth-max
+  # cat /mnt/cgroup/foo/blockio.bandwidth-max
+  8 16 8388608 1 0 8388608 -84432 206436
+  8 0 16777216 0 0 0 0 15212
+
+* Remove limiting rule on /dev/sdb for cgroup "foo":
+  # /bin/echo /dev/sdb:0:0:0 > /mnt/cgroup/foo/blockio.bandwidth-max
+  # cat /mnt/cgroup/foo/blockio.bandwidth-max
+  8 0 16777216 0 0 0 0 110388
+
+* Set a maximum of 100 I/O operations/sec (leaky bucket strategy) to /dev/sdc
+  for cgroup "foo":
+  # /bin/echo /dev/sdc:100:0 > /mnt/cgroup/foo/blockio.iops-max
+  # cat /mnt/cgroup/foo/blockio.iops-max
+  8 32 100000 0 846000 0 2113
+          ^        ^
+         /________/
+        /
+  Remember: these values are scaled up by a factor of 1000 to apply a fine
+  grained throttling (i.e. LIMIT == 100000 means a maximum of 100 I/O operation
+  per second)
+
+* Remove limiting rule for I/O operations from /dev/sdc for cgroup "foo":
+  # /bin/echo /dev/sdc:0 > /mnt/cgroup/foo/blockio.iops-max
+
+----------------------------------------------------------------------
+3. ADVANTAGES OF PROVIDING THIS FEATURE
+
+* Allow I/O traffic shaping for block device shared among different cgroups
+* Improve I/O performance predictability on block devices shared between
+  different cgroups
+* Limiting rules do not depend of the particular I/O scheduler (anticipatory,
+  deadline, CFQ, noop) and/or the type of the underlying block devices
+* The bandwidth limitations are guaranteed both for synchronous and
+  asynchronous operations, even the I/O passing through the page cache or
+  buffers and not only direct I/O (see below for details)
+* It is possible to implement a simple user-space application to dynamically
+  adjust the I/O workload of different process containers at run-time,
+  according to the particular users' requirements and applications' performance
+  constraints
+
+----------------------------------------------------------------------
+4. DESIGN
+
+The I/O throttling is performed imposing an explicit timeout, via
+schedule_timeout_killable() on the processes that exceed the I/O limits
+dedicated to the cgroup they belong to. I/O accounting happens per cgroup.
+
+It just works as expected for read operations: the real I/O activity is reduced
+synchronously according to the defined limitations.
+
+Multiple re-reads of pages already present in the page cache are not considered
+to account the I/O activity, since they actually don't generate any real I/O
+operation.
+
+This means that a process that re-reads multiple times the same blocks of a
+file is affected by the I/O limitations only for the actual I/O performed from
+the underlying block devices.
+
+For write operations the scenario is a bit more complex, because the writes in
+the page cache are processed asynchronously by kernel threads (pdflush), using
+a write-back policy. So the real writes to the underlying block devices occur
+in a different I/O context respect to the task that originally generated the
+dirty pages.
+
+The I/O bandwidth controller uses the following solution to resolve this
+problem.
+
+The cost of each I/O operation is always accounted when the operation is
+submitted to the I/O subsystem (submit_bio()).
+
+If the operation is a read then we automatically know that the context of the
+request is the current task and so we can charge the cgroup the current task
+belongs to. And throttle the current task as well, if it exceeded the cgroup
+limitations.
+
+If the operation is a write, we can charge the right cgroup looking at the
+owner of the first page involved in the I/O operation, that gives the context
+that generated the I/O activity at the source. This information can be
+retrieved using the page_cgroup functionality provided by the cgroup memory
+controller [4]. In this way we can correctly account the I/O cost to the right
+cgroup, but we cannot throttle the current task in this stage, because, in
+general, it is a different task (e.g. a kernel thread that is processing
+asynchronously the dirty page). For this reason, throttling of write operations
+is always performed asynchronously in balance_dirty_pages_ratelimited_nr(), a
+function always called by processes which are dirtying memory.
+
+Multiple rules for different block devices are stored in a linked list, using
+the dev_t number of each block device as key to uniquely identify each element
+of the list. RCU synchronization is used to protect the whole list structure,
+since the elements in the list are not supposed to change frequently (they
+change only when a new rule is defined or an old rule is removed or updated),
+while the reads in the list occur at each operation that generates I/O. This
+allows to provide zero overhead for cgroups that do not use any limitation.
+
+WARNING: per-block device limiting rules always refer to the dev_t device
+number. If a block device is unplugged (i.e. a USB device) the limiting rules
+defined for that device persist and they are still valid if a new device is
+plugged in the system and it uses the same major and minor numbers.
+
+NOTE: explicit sleeps are *not* imposed on tasks doing asynchronous I/O (AIO)
+operations; AIO throttling is performed returning -EAGAIN from sys_io_submit().
+Userspace applications must be able to handle this error code opportunely.
+
+----------------------------------------------------------------------
+5. TODO
+
+* Implement a rbtree per request queue; all the requests queued to the I/O
+  subsystem first will go in this rbtree. Then based on cgroup grouping and
+  control policy dispatch the requests and pass them to the elevator associated
+  with the queue. This would allow to provide both bandwidth limiting and
+  proportional bandwidth functionalities using a generic approach (suggested by
+  Vivek Goyal)
+
+* Improve fair throttling: distribute the time to sleep among all the tasks of
+  a cgroup that exceeded the I/O limits, depending of the amount of IO activity
+  previously generated in the past by each task (see task_io_accounting)
+
+* Try to reduce the cost of calling cgroup_io_throttle() on every submit_bio();
+  this is not too much expensive, but the call of task_subsys_state() has
+  surely a cost. A possible solution could be to temporarily account I/O in the
+  current task_struct and call cgroup_io_throttle() only on each X MB of I/O.
+  Or on each Y number of I/O requests as well. Better if both X and/or Y can be
+  tuned at runtime by a userspace tool
+
+* Think an alternative design for general purpose usage; special purpose usage
+  right now is restricted to improve I/O performance predictability and
+  evaluate more precise response timings for applications doing I/O. To a large
+  degree the block I/O bandwidth controller should implement a more complex
+  logic to better evaluate real I/O operations cost, depending also on the
+  particular block device profile (i.e. USB stick, optical drive, hard disk,
+  etc.). This would also allow to appropriately account I/O cost for seeky
+  workloads, respect to large stream workloads. Instead of looking at the
+  request stream and try to predict how expensive the I/O cost will be, a
+  totally different approach could be to collect request timings (start time /
+  elapsed time) and based on collected informations, try to estimate the I/O
+  cost and usage
+
+----------------------------------------------------------------------
+6. REFERENCES
+
+[1] Documentation/cgroups/cgroups.txt
+[2] http://en.wikipedia.org/wiki/Leaky_bucket
+[3] http://en.wikipedia.org/wiki/Token_bucket
+[4] Documentation/controllers/memory.txt
diff --git a/block/Makefile b/block/Makefile
index bfe7304..6049d09 100644
--- a/block/Makefile
+++ b/block/Makefile
@@ -13,6 +13,8 @@ obj-$(CONFIG_IOSCHED_AS)	+= as-iosched.o
 obj-$(CONFIG_IOSCHED_DEADLINE)	+= deadline-iosched.o
 obj-$(CONFIG_IOSCHED_CFQ)	+= cfq-iosched.o
 
+obj-$(CONFIG_CGROUP_IO_THROTTLE)	+= blk-io-throttle.o
+
 obj-$(CONFIG_BLK_DEV_IO_TRACE)	+= blktrace.o
 obj-$(CONFIG_BLOCK_COMPAT)	+= compat_ioctl.o
 obj-$(CONFIG_BLK_DEV_INTEGRITY)	+= blk-integrity.o
diff --git a/block/blk-core.c b/block/blk-core.c
index c3df30c..e187476 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -26,6 +26,7 @@
 #include <linux/swap.h>
 #include <linux/writeback.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/blktrace_api.h>
 #include <linux/fault-inject.h>
 
@@ -1536,9 +1537,12 @@ void submit_bio(int rw, struct bio *bio)
 	if (bio_has_data(bio)) {
 		if (rw & WRITE) {
 			count_vm_events(PGPGOUT, count);
+			cgroup_io_throttle(bio_iovec_idx(bio, 0)->bv_page,
+					bio->bi_bdev, bio->bi_size, 0);
 		} else {
 			task_io_account_read(bio->bi_size);
 			count_vm_events(PGPGIN, count);
+			cgroup_io_throttle(NULL, bio->bi_bdev, bio->bi_size, 1);
 		}
 
 		if (unlikely(block_dump)) {
diff --git a/block/blk-io-throttle.c b/block/blk-io-throttle.c
new file mode 100644
index 0000000..bb27587
--- /dev/null
+++ b/block/blk-io-throttle.c
@@ -0,0 +1,735 @@
+/*
+ * blk-io-throttle.c
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ * Copyright (C) 2008 Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/res_counter.h>
+#include <linux/memcontrol.h>
+#include <linux/slab.h>
+#include <linux/gfp.h>
+#include <linux/err.h>
+#include <linux/genhd.h>
+#include <linux/hardirq.h>
+#include <linux/list.h>
+#include <linux/seq_file.h>
+#include <linux/spinlock.h>
+#include <linux/blk-io-throttle.h>
+
+/*
+ * Statistics for I/O bandwidth controller.
+ */
+enum iothrottle_stat_index {
+	/* # of times the cgroup has been throttled for bw limit */
+	IOTHROTTLE_STAT_BW_COUNT,
+	/* # of jiffies spent to sleep for throttling for bw limit */
+	IOTHROTTLE_STAT_BW_SLEEP,
+	/* # of times the cgroup has been throttled for iops limit */
+	IOTHROTTLE_STAT_IOPS_COUNT,
+	/* # of jiffies spent to sleep for throttling for iops limit */
+	IOTHROTTLE_STAT_IOPS_SLEEP,
+	/* total number of bytes read and written */
+	IOTHROTTLE_STAT_BYTES_TOT,
+	/* total number of I/O operations */
+	IOTHROTTLE_STAT_IOPS_TOT,
+
+	IOTHROTTLE_STAT_NSTATS,
+};
+
+struct iothrottle_stat_cpu {
+	unsigned long long count[IOTHROTTLE_STAT_NSTATS];
+} ____cacheline_aligned_in_smp;
+
+struct iothrottle_stat {
+	struct iothrottle_stat_cpu cpustat[NR_CPUS];
+};
+
+static void iothrottle_stat_add(struct iothrottle_stat *stat,
+			enum iothrottle_stat_index type, unsigned long long val)
+{
+	int cpu = get_cpu();
+
+	stat->cpustat[cpu].count[type] += val;
+	put_cpu();
+}
+
+static void iothrottle_stat_add_sleep(struct iothrottle_stat *stat,
+			int type, unsigned long long sleep)
+{
+	int cpu = get_cpu();
+
+	switch (type) {
+	case IOTHROTTLE_BANDWIDTH:
+		stat->cpustat[cpu].count[IOTHROTTLE_STAT_BW_COUNT]++;
+		stat->cpustat[cpu].count[IOTHROTTLE_STAT_BW_SLEEP] += sleep;
+		break;
+	case IOTHROTTLE_IOPS:
+		stat->cpustat[cpu].count[IOTHROTTLE_STAT_IOPS_COUNT]++;
+		stat->cpustat[cpu].count[IOTHROTTLE_STAT_IOPS_SLEEP] += sleep;
+		break;
+	}
+	put_cpu();
+}
+
+static unsigned long long iothrottle_read_stat(struct iothrottle_stat *stat,
+				enum iothrottle_stat_index idx)
+{
+	int cpu;
+	unsigned long long ret = 0;
+
+	for_each_possible_cpu(cpu)
+		ret += stat->cpustat[cpu].count[idx];
+	return ret;
+}
+
+struct iothrottle_sleep {
+	unsigned long long bw_sleep;
+	unsigned long long iops_sleep;
+};
+
+/*
+ * struct iothrottle_node - throttling rule of a single block device
+ * @node: list of per block device throttling rules
+ * @dev: block device number, used as key in the list
+ * @bw: max i/o bandwidth (in bytes/s)
+ * @iops: max i/o operations per second
+ * @stat: throttling statistics
+ *
+ * Define a i/o throttling rule for a single block device.
+ *
+ * NOTE: limiting rules always refer to dev_t; if a block device is unplugged
+ * the limiting rules defined for that device persist and they are still valid
+ * if a new device is plugged and it uses the same dev_t number.
+ */
+struct iothrottle_node {
+	struct list_head node;
+	dev_t dev;
+	struct res_counter bw;
+	struct res_counter iops;
+	struct iothrottle_stat stat;
+};
+
+/**
+ * struct iothrottle - throttling rules for a cgroup
+ * @css: pointer to the cgroup state
+ * @list: list of iothrottle_node elements
+ *
+ * Define multiple per-block device i/o throttling rules.
+ * Note: the list of the throttling rules is protected by RCU locking:
+ *	 - hold cgroup_lock() for update.
+ *	 - hold rcu_read_lock() for read.
+ */
+struct iothrottle {
+	struct cgroup_subsys_state css;
+	struct list_head list;
+};
+static struct iothrottle init_iothrottle;
+
+static inline struct iothrottle *cgroup_to_iothrottle(struct cgroup *cgrp)
+{
+	return container_of(cgroup_subsys_state(cgrp, iothrottle_subsys_id),
+			    struct iothrottle, css);
+}
+
+/*
+ * Note: called with rcu_read_lock() held.
+ */
+static inline struct iothrottle *task_to_iothrottle(struct task_struct *task)
+{
+	return container_of(task_subsys_state(task, iothrottle_subsys_id),
+			    struct iothrottle, css);
+}
+
+/*
+ * Note: called with rcu_read_lock() or iot->lock held.
+ */
+static struct iothrottle_node *
+iothrottle_search_node(const struct iothrottle *iot, dev_t dev)
+{
+	struct iothrottle_node *n;
+
+	if (list_empty(&iot->list))
+		return NULL;
+	list_for_each_entry_rcu(n, &iot->list, node)
+		if (n->dev == dev)
+			return n;
+	return NULL;
+}
+
+/*
+ * Note: called with iot->lock held.
+ */
+static inline void iothrottle_insert_node(struct iothrottle *iot,
+						struct iothrottle_node *n)
+{
+	list_add_rcu(&n->node, &iot->list);
+}
+
+/*
+ * Note: called with iot->lock held.
+ */
+static inline void
+iothrottle_replace_node(struct iothrottle *iot, struct iothrottle_node *old,
+			struct iothrottle_node *new)
+{
+	list_replace_rcu(&old->node, &new->node);
+}
+
+/*
+ * Note: called with iot->lock held.
+ */
+static inline void
+iothrottle_delete_node(struct iothrottle *iot, struct iothrottle_node *n)
+{
+	list_del_rcu(&n->node);
+}
+
+/*
+ * Note: called from kernel/cgroup.c with cgroup_lock() held.
+ */
+static struct cgroup_subsys_state *
+iothrottle_create(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct iothrottle *iot;
+
+	if (unlikely((cgrp->parent) == NULL))
+		iot = &init_iothrottle;
+	else {
+		iot = kmalloc(sizeof(*iot), GFP_KERNEL);
+		if (unlikely(!iot))
+			return ERR_PTR(-ENOMEM);
+	}
+	INIT_LIST_HEAD(&iot->list);
+
+	return &iot->css;
+}
+
+/*
+ * Note: called from kernel/cgroup.c with cgroup_lock() held.
+ */
+static void iothrottle_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct iothrottle_node *n, *p;
+	struct iothrottle *iot = cgroup_to_iothrottle(cgrp);
+
+	/*
+	 * don't worry about locking here, at this point there must be not any
+	 * reference to the list.
+	 */
+	if (!list_empty(&iot->list))
+		list_for_each_entry_safe(n, p, &iot->list, node)
+			kfree(n);
+	kfree(iot);
+}
+
+/*
+ * NOTE: called with rcu_read_lock() held.
+ *
+ * do not care too much about locking for single res_counter values here.
+ */
+static void iothrottle_show_limit(struct seq_file *m, dev_t dev,
+			struct res_counter *res)
+{
+	if (!res->limit)
+		return;
+	seq_printf(m, "%u %u %llu %llu %lli %llu %li\n",
+		MAJOR(dev), MINOR(dev),
+		res->limit, res->policy,
+		(long long)res->usage, res->capacity,
+		jiffies_to_clock_t(res_counter_ratelimit_delta_t(res)));
+}
+
+/*
+ * NOTE: called with rcu_read_lock() held.
+ *
+ */
+static void iothrottle_show_failcnt(struct seq_file *m, dev_t dev,
+				struct iothrottle_stat *stat)
+{
+	unsigned long long bw_count, bw_sleep, iops_count, iops_sleep;
+
+	bw_count = iothrottle_read_stat(stat, IOTHROTTLE_STAT_BW_COUNT);
+	bw_sleep = iothrottle_read_stat(stat, IOTHROTTLE_STAT_BW_SLEEP);
+	iops_count = iothrottle_read_stat(stat, IOTHROTTLE_STAT_IOPS_COUNT);
+	iops_sleep = iothrottle_read_stat(stat, IOTHROTTLE_STAT_IOPS_SLEEP);
+
+	seq_printf(m, "%u %u %llu %li %llu %li\n", MAJOR(dev), MINOR(dev),
+		bw_count, jiffies_to_clock_t(bw_sleep),
+		iops_count, jiffies_to_clock_t(iops_sleep));
+}
+
+/*
+ * NOTE: called with rcu_read_lock() held.
+ */
+static void iothrottle_show_stat(struct seq_file *m, dev_t dev,
+				struct iothrottle_stat *stat)
+{
+	unsigned long long bytes, iops;
+
+	bytes = iothrottle_read_stat(stat, IOTHROTTLE_STAT_BYTES_TOT);
+	iops = iothrottle_read_stat(stat, IOTHROTTLE_STAT_IOPS_TOT);
+
+	seq_printf(m, "%u %u %llu %llu\n", MAJOR(dev), MINOR(dev), bytes, iops);
+}
+
+static int iothrottle_read(struct cgroup *cgrp, struct cftype *cft,
+				struct seq_file *m)
+{
+	struct iothrottle *iot = cgroup_to_iothrottle(cgrp);
+	struct iothrottle_node *n;
+
+	rcu_read_lock();
+	if (list_empty(&iot->list))
+		goto unlock_and_return;
+	list_for_each_entry_rcu(n, &iot->list, node) {
+		BUG_ON(!n->dev);
+		switch (cft->private) {
+		case IOTHROTTLE_BANDWIDTH:
+			iothrottle_show_limit(m, n->dev, &n->bw);
+			break;
+		case IOTHROTTLE_IOPS:
+			iothrottle_show_limit(m, n->dev, &n->iops);
+			break;
+		case IOTHROTTLE_FAILCNT:
+			iothrottle_show_failcnt(m, n->dev, &n->stat);
+			break;
+		case IOTHROTTLE_STAT:
+			iothrottle_show_stat(m, n->dev, &n->stat);
+			break;
+		}
+	}
+unlock_and_return:
+	rcu_read_unlock();
+	return 0;
+}
+
+static dev_t devname2dev_t(const char *buf)
+{
+	struct block_device *bdev;
+	dev_t dev = 0;
+	struct gendisk *disk;
+	int part;
+
+	/* use a lookup to validate the block device */
+	bdev = lookup_bdev(buf);
+	if (IS_ERR(bdev))
+		return 0;
+	/* only entire devices are allowed, not single partitions */
+	disk = get_gendisk(bdev->bd_dev, &part);
+	if (disk && !part) {
+		BUG_ON(!bdev->bd_inode);
+		dev = bdev->bd_inode->i_rdev;
+	}
+	bdput(bdev);
+
+	return dev;
+}
+
+/*
+ * The userspace input string must use one of the following syntaxes:
+ *
+ * dev:0			<- delete an i/o limiting rule
+ * dev:io-limit:0		<- set a leaky bucket throttling rule
+ * dev:io-limit:1:bucket-size	<- set a token bucket throttling rule
+ * dev:io-limit:1		<- set a token bucket throttling rule using
+ *				   bucket-size == io-limit
+ */
+static int iothrottle_parse_args(char *buf, size_t nbytes, int filetype,
+			dev_t *dev, unsigned long long *iolimit,
+			unsigned long long *strategy,
+			unsigned long long *bucket_size)
+{
+	char *p;
+	int count = 0;
+	char *s[4];
+	int ret;
+
+	memset(s, 0, sizeof(s));
+	*dev = 0;
+	*iolimit = 0;
+	*strategy = 0;
+	*bucket_size = 0;
+
+	/* split the colon-delimited input string into its elements */
+	while (count < ARRAY_SIZE(s)) {
+		p = strsep(&buf, ":");
+		if (!p)
+			break;
+		if (!*p)
+			continue;
+		s[count++] = p;
+	}
+
+	/* i/o limit */
+	if (!s[1])
+		return -EINVAL;
+	ret = strict_strtoull(s[1], 10, iolimit);
+	if (ret < 0)
+		return ret;
+	if (!*iolimit)
+		goto out;
+	/* throttling strategy (leaky bucket / token bucket) */
+	if (!s[2])
+		return -EINVAL;
+	ret = strict_strtoull(s[2], 10, strategy);
+	if (ret < 0)
+		return ret;
+	switch (*strategy) {
+	case RATELIMIT_LEAKY_BUCKET:
+		goto out;
+	case RATELIMIT_TOKEN_BUCKET:
+		break;
+	default:
+		return -EINVAL;
+	}
+	/* bucket size */
+	if (!s[3])
+		*bucket_size = *iolimit;
+	else {
+		ret = strict_strtoll(s[3], 10, bucket_size);
+		if (ret < 0)
+			return ret;
+	}
+	if (*bucket_size <= 0)
+		return -EINVAL;
+out:
+	/* block device number */
+	*dev = devname2dev_t(s[0]);
+	return *dev ? 0 : -EINVAL;
+}
+
+static int iothrottle_write(struct cgroup *cgrp, struct cftype *cft,
+				const char *buffer)
+{
+	struct iothrottle *iot;
+	struct iothrottle_node *n, *newn = NULL;
+	dev_t dev;
+	unsigned long long iolimit, strategy, bucket_size;
+	char *buf;
+	size_t nbytes = strlen(buffer);
+	int ret = 0;
+
+	/*
+	 * We need to allocate a new buffer here, because
+	 * iothrottle_parse_args() can modify it and the buffer provided by
+	 * write_string is supposed to be const.
+	 */
+	buf = kmalloc(nbytes + 1, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+	memcpy(buf, buffer, nbytes + 1);
+
+	ret = iothrottle_parse_args(buf, nbytes, cft->private, &dev, &iolimit,
+				&strategy, &bucket_size);
+	if (ret)
+		goto out1;
+	newn = kzalloc(sizeof(*newn), GFP_KERNEL);
+	if (!newn) {
+		ret = -ENOMEM;
+		goto out1;
+	}
+	newn->dev = dev;
+	res_counter_init(&newn->bw);
+	res_counter_init(&newn->iops);
+
+	switch (cft->private) {
+	case IOTHROTTLE_BANDWIDTH:
+		res_counter_ratelimit_set_limit(&newn->iops, 0, 0, 0);
+		res_counter_ratelimit_set_limit(&newn->bw, strategy,
+				ALIGN(iolimit, 1024), ALIGN(bucket_size, 1024));
+		break;
+	case IOTHROTTLE_IOPS:
+		res_counter_ratelimit_set_limit(&newn->bw, 0, 0, 0);
+		/*
+		 * scale up iops cost by a factor of 1000, this allows to apply
+		 * a more fine grained sleeps, and throttling results more
+		 * precise this way.
+		 */
+		res_counter_ratelimit_set_limit(&newn->iops, strategy,
+				iolimit * 1000, bucket_size * 1000);
+		break;
+	default:
+		WARN_ON(1);
+		break;
+	}
+
+	if (!cgroup_lock_live_group(cgrp)) {
+		ret = -ENODEV;
+		goto out1;
+	}
+	iot = cgroup_to_iothrottle(cgrp);
+
+	n = iothrottle_search_node(iot, dev);
+	if (!n) {
+		if (iolimit) {
+			/* Add a new block device limiting rule */
+			iothrottle_insert_node(iot, newn);
+			newn = NULL;
+		}
+		goto out2;
+	}
+	switch (cft->private) {
+	case IOTHROTTLE_BANDWIDTH:
+		if (!iolimit && !n->iops.limit) {
+			/* Delete a block device limiting rule */
+			iothrottle_delete_node(iot, n);
+			goto out2;
+		}
+		if (!n->iops.limit)
+			break;
+		/* Update a block device limiting rule */
+		newn->iops = n->iops;
+		break;
+	case IOTHROTTLE_IOPS:
+		if (!iolimit && !n->bw.limit) {
+			/* Delete a block device limiting rule */
+			iothrottle_delete_node(iot, n);
+			goto out2;
+		}
+		if (!n->bw.limit)
+			break;
+		/* Update a block device limiting rule */
+		newn->bw = n->bw;
+		break;
+	}
+	iothrottle_replace_node(iot, n, newn);
+	newn = NULL;
+out2:
+	cgroup_unlock();
+	if (n) {
+		synchronize_rcu();
+		kfree(n);
+	}
+out1:
+	kfree(newn);
+	kfree(buf);
+	return ret;
+}
+
+static struct cftype files[] = {
+	{
+		.name = "bandwidth-max",
+		.read_seq_string = iothrottle_read,
+		.write_string = iothrottle_write,
+		.max_write_len = 256,
+		.private = IOTHROTTLE_BANDWIDTH,
+	},
+	{
+		.name = "iops-max",
+		.read_seq_string = iothrottle_read,
+		.write_string = iothrottle_write,
+		.max_write_len = 256,
+		.private = IOTHROTTLE_IOPS,
+	},
+	{
+		.name = "throttlecnt",
+		.read_seq_string = iothrottle_read,
+		.private = IOTHROTTLE_FAILCNT,
+	},
+	{
+		.name = "stat",
+		.read_seq_string = iothrottle_read,
+		.private = IOTHROTTLE_STAT,
+	},
+};
+
+static int iothrottle_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	return cgroup_add_files(cgrp, ss, files, ARRAY_SIZE(files));
+}
+
+struct cgroup_subsys iothrottle_subsys = {
+	.name = "blockio",
+	.create = iothrottle_create,
+	.destroy = iothrottle_destroy,
+	.populate = iothrottle_populate,
+	.subsys_id = iothrottle_subsys_id,
+	.early_init = 1,
+};
+
+/*
+ * NOTE: called with rcu_read_lock() held.
+ */
+static void iothrottle_evaluate_sleep(struct iothrottle_sleep *sleep,
+				struct iothrottle *iot,
+				struct block_device *bdev, ssize_t bytes)
+{
+	struct iothrottle_node *n;
+	dev_t dev;
+
+	if (unlikely(!iot))
+		return;
+
+	/* accounting and throttling is done only on entire block devices */
+	dev = MKDEV(MAJOR(bdev->bd_inode->i_rdev), bdev->bd_disk->first_minor);
+	n = iothrottle_search_node(iot, dev);
+	if (!n)
+		return;
+
+	/* Update statistics */
+	iothrottle_stat_add(&n->stat, IOTHROTTLE_STAT_BYTES_TOT, bytes);
+	if (bytes)
+		iothrottle_stat_add(&n->stat, IOTHROTTLE_STAT_IOPS_TOT, 1);
+
+	/* Evaluate sleep values */
+	sleep->bw_sleep = res_counter_ratelimit_sleep(&n->bw, bytes);
+	/*
+	 * scale up iops cost by a factor of 1000, this allows to apply
+	 * a more fine grained sleeps, and throttling works better in
+	 * this way.
+	 *
+	 * Note: do not account any i/o operation if bytes is negative or zero.
+	 */
+	sleep->iops_sleep = res_counter_ratelimit_sleep(&n->iops,
+						bytes ? 1000 : 0);
+}
+
+/*
+ * NOTE: called with rcu_read_lock() held.
+ */
+static void iothrottle_acct_stat(struct iothrottle *iot,
+			struct block_device *bdev, int type,
+			unsigned long long sleep)
+{
+	struct iothrottle_node *n;
+	dev_t dev = MKDEV(MAJOR(bdev->bd_inode->i_rdev),
+			bdev->bd_disk->first_minor);
+
+	n = iothrottle_search_node(iot, dev);
+	if (!n)
+		return;
+	iothrottle_stat_add_sleep(&n->stat, type, sleep);
+}
+
+static void iothrottle_acct_task_stat(int type, unsigned long long sleep)
+{
+	/*
+	 * XXX: per-task statistics may be inaccurate (this is not a
+	 * critical issue, anyway, respect to introduce locking
+	 * overhead or increase the size of task_struct).
+	 */
+	switch (type) {
+	case IOTHROTTLE_BANDWIDTH:
+		current->io_throttle_bw_cnt++;
+		current->io_throttle_bw_sleep += sleep;
+		break;
+
+	case IOTHROTTLE_IOPS:
+		current->io_throttle_iops_cnt++;
+		current->io_throttle_iops_sleep += sleep;
+		break;
+	}
+}
+
+static struct iothrottle *get_iothrottle_from_page(struct page *page)
+{
+	struct cgroup *cgrp;
+	struct iothrottle *iot;
+
+	if (!page)
+		return NULL;
+	cgrp = get_cgroup_from_page(page);
+	if (!cgrp)
+		return NULL;
+	iot = cgroup_to_iothrottle(cgrp);
+	css_get(&iot->css);
+	put_cgroup_from_page(page);
+
+	return iot;
+}
+
+static inline int is_kthread_io(void)
+{
+	return current->flags & (PF_KTHREAD | PF_FLUSHER | PF_KSWAPD);
+}
+
+/**
+ * cgroup_io_throttle() - account and throttle i/o activity
+ * @page:	a page used to retrieve the owner of the i/o operation.
+ * @bdev:	block device involved for the i/o.
+ * @bytes:	size in bytes of the i/o operation.
+ * @can_sleep:	used to set to 1 if we're in a sleep()able context, 0
+ *		otherwise; into a non-sleep()able context we only account the
+ *		i/o activity without applying any throttling sleep.
+ *
+ * This is the core of the block device i/o bandwidth controller. This function
+ * must be called by any function that generates i/o activity (directly or
+ * indirectly). It provides both i/o accounting and throttling functionalities;
+ * throttling is disabled if @can_sleep is set to 0.
+ *
+ * Returns the value of sleep in jiffies if it was not possible to schedule the
+ * timeout.
+ **/
+unsigned long long
+cgroup_io_throttle(struct page *page, struct block_device *bdev,
+		ssize_t bytes, int can_sleep)
+{
+	struct iothrottle *iot;
+	struct iothrottle_sleep s = {};
+	unsigned long long sleep;
+
+	if (unlikely(!bdev))
+		return 0;
+	BUG_ON(!bdev->bd_inode || !bdev->bd_disk);
+	/*
+	 * Never throttle kernel threads, since they may completely block other
+	 * cgroups, the i/o on other block devices or even the whole system.
+	 *
+	 * And never sleep also if we're inside an AIO context; just account
+	 * the i/o activity. Throttling is performed in io_submit_one()
+	 * returning * -EAGAIN when the limits are exceeded.
+	 */
+	if (is_kthread_io() || is_in_aio())
+		can_sleep = 0;
+	/*
+	 * WARNING: in_atomic() do not know about held spinlocks in
+	 * non-preemptible kernels, but we want to check it here to raise
+	 * potential bugs by preemptible kernels.
+	 */
+	WARN_ON_ONCE(can_sleep &&
+		(irqs_disabled() || in_interrupt() || in_atomic()));
+
+	/* check if we need to throttle */
+	iot = get_iothrottle_from_page(page);
+	rcu_read_lock();
+	if (!iot) {
+		iot = task_to_iothrottle(current);
+		css_get(&iot->css);
+	}
+	iothrottle_evaluate_sleep(&s, iot, bdev, bytes);
+	sleep = max(s.bw_sleep, s.iops_sleep);
+	if (unlikely(sleep && can_sleep)) {
+		int type = (s.bw_sleep < s.iops_sleep) ?
+				IOTHROTTLE_IOPS : IOTHROTTLE_BANDWIDTH;
+
+		iothrottle_acct_stat(iot, bdev, type, sleep);
+		css_put(&iot->css);
+		rcu_read_unlock();
+
+		pr_debug("io-throttle: task %p (%s) must sleep %llu jiffies\n",
+			 current, current->comm, sleep);
+		iothrottle_acct_task_stat(type, sleep);
+		schedule_timeout_killable(sleep);
+		return 0;
+	}
+	css_put(&iot->css);
+	rcu_read_unlock();
+	return sleep;
+}
diff --git a/fs/aio.c b/fs/aio.c
index f658441..ee8d452 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -22,6 +22,7 @@
 #include <linux/sched.h>
 #include <linux/fs.h>
 #include <linux/file.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
 #include <linux/slab.h>
@@ -1558,6 +1559,7 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 {
 	struct kiocb *req;
 	struct file *file;
+	struct block_device *bdev;
 	ssize_t ret;
 
 	/* enforce forwards compatibility on users */
@@ -1580,6 +1582,14 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 	if (unlikely(!file))
 		return -EBADF;
 
+	/* check if we're exceeding the IO throttling limits */
+	bdev = as_to_bdev(file->f_mapping);
+	ret = cgroup_io_throttle(NULL, bdev, 0, 0);
+	if (unlikely(ret)) {
+		fput(file);
+		return -EAGAIN;
+	}
+
 	req = aio_get_req(ctx);		/* returns with 2 references to req */
 	if (unlikely(!req)) {
 		fput(file);
@@ -1622,12 +1632,14 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
 		goto out_put_req;
 
 	spin_lock_irq(&ctx->ctx_lock);
+	set_in_aio();
 	aio_run_iocb(req);
 	if (!list_empty(&ctx->run_list)) {
 		/* drain the run list */
 		while (__aio_run_iocbs(ctx))
 			;
 	}
+	unset_in_aio();
 	spin_unlock_irq(&ctx->ctx_lock);
 	aio_put_req(req);	/* drop extra ref to req */
 	return 0;
diff --git a/fs/direct-io.c b/fs/direct-io.c
index 222a970..cd78bab 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -28,6 +28,7 @@
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/bio.h>
 #include <linux/wait.h>
 #include <linux/err.h>
@@ -658,10 +659,12 @@ submit_page_section(struct dio *dio, struct page *page,
 	int ret = 0;
 
 	if (dio->rw & WRITE) {
+		struct block_device *bdev = dio->inode->i_sb->s_bdev;
 		/*
 		 * Read accounting is performed in submit_bio()
 		 */
 		task_io_account_write(len);
+		cgroup_io_throttle(NULL, bdev, 0, 1);
 	}
 
 	/*
diff --git a/fs/proc/base.c b/fs/proc/base.c
index cf42c42..9d2574a 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -54,6 +54,7 @@
 #include <linux/proc_fs.h>
 #include <linux/stat.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/init.h>
 #include <linux/capability.h>
 #include <linux/file.h>
@@ -2458,6 +2459,17 @@ static int proc_pid_personality(struct seq_file *m, struct pid_namespace *ns,
 	return 0;
 }
 
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+static int proc_iothrottle_stat(struct task_struct *task, char *buffer)
+{
+	return sprintf(buffer, "%llu %llu %llu %llu\n",
+			get_io_throttle_cnt(task, IOTHROTTLE_BANDWIDTH),
+			get_io_throttle_sleep(task, IOTHROTTLE_BANDWIDTH),
+			get_io_throttle_cnt(task, IOTHROTTLE_IOPS),
+			get_io_throttle_sleep(task, IOTHROTTLE_IOPS));
+}
+#endif /* CONFIG_CGROUP_IO_THROTTLE */
+
 /*
  * Thread groups
  */
@@ -2534,6 +2546,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 #ifdef CONFIG_TASK_IO_ACCOUNTING
 	INF("io",	S_IRUGO, tgid_io_accounting),
 #endif
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+	INF("io-throttle-stat",	S_IRUGO, iothrottle_stat),
+#endif
 };
 
 static int proc_tgid_base_readdir(struct file * filp,
@@ -2866,6 +2881,9 @@ static const struct pid_entry tid_base_stuff[] = {
 #ifdef CONFIG_TASK_IO_ACCOUNTING
 	INF("io",	S_IRUGO, tid_io_accounting),
 #endif
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+	INF("io-throttle-stat",	S_IRUGO, iothrottle_stat),
+#endif
 };
 
 static int proc_tid_base_readdir(struct file * filp,
diff --git a/include/linux/blk-io-throttle.h b/include/linux/blk-io-throttle.h
new file mode 100644
index 0000000..a241758
--- /dev/null
+++ b/include/linux/blk-io-throttle.h
@@ -0,0 +1,95 @@
+#ifndef BLK_IO_THROTTLE_H
+#define BLK_IO_THROTTLE_H
+
+#include <linux/fs.h>
+#include <linux/jiffies.h>
+#include <linux/sched.h>
+#include <linux/cgroup.h>
+#include <asm/atomic.h>
+#include <asm/current.h>
+
+#define IOTHROTTLE_BANDWIDTH	0
+#define IOTHROTTLE_IOPS		1
+#define IOTHROTTLE_FAILCNT	2
+#define IOTHROTTLE_STAT		3
+
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+extern unsigned long long
+cgroup_io_throttle(struct page *page, struct block_device *bdev,
+		ssize_t bytes, int can_sleep);
+
+static inline void set_in_aio(void)
+{
+	atomic_set(&current->in_aio, 1);
+}
+
+static inline void unset_in_aio(void)
+{
+	atomic_set(&current->in_aio, 0);
+}
+
+static inline int is_in_aio(void)
+{
+	return atomic_read(&current->in_aio);
+}
+
+static inline unsigned long long
+get_io_throttle_cnt(struct task_struct *t, int type)
+{
+	switch (type) {
+	case IOTHROTTLE_BANDWIDTH:
+		return t->io_throttle_bw_cnt;
+	case IOTHROTTLE_IOPS:
+		return t->io_throttle_iops_cnt;
+	}
+	BUG();
+}
+
+static inline unsigned long long
+get_io_throttle_sleep(struct task_struct *t, int type)
+{
+	switch (type) {
+	case IOTHROTTLE_BANDWIDTH:
+		return jiffies_to_clock_t(t->io_throttle_bw_sleep);
+	case IOTHROTTLE_IOPS:
+		return jiffies_to_clock_t(t->io_throttle_iops_sleep);
+	}
+	BUG();
+}
+#else
+static inline unsigned long long
+cgroup_io_throttle(struct page *page, struct block_device *bdev,
+		ssize_t bytes, int can_sleep)
+{
+	return 0;
+}
+
+static inline void set_in_aio(void) { }
+
+static inline void unset_in_aio(void) { }
+
+static inline int is_in_aio(void)
+{
+	return 0;
+}
+
+static inline unsigned long long
+get_io_throttle_cnt(struct task_struct *t, int type)
+{
+	return 0;
+}
+
+static inline unsigned long long
+get_io_throttle_sleep(struct task_struct *t, int type)
+{
+	return 0;
+}
+#endif /* CONFIG_CGROUP_IO_THROTTLE */
+
+static inline struct block_device *as_to_bdev(struct address_space *mapping)
+{
+	return (mapping->host && mapping->host->i_sb->s_bdev) ?
+		mapping->host->i_sb->s_bdev : NULL;
+}
+
+#endif /* BLK_IO_THROTTLE_H */
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 8eb6f48..97277c9 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -55,6 +55,12 @@ SUBSYS(devices)
 
 /* */
 
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+SUBSYS(iothrottle)
+#endif
+
+/* */
+
 #ifdef CONFIG_CGROUP_FREEZER
 SUBSYS(freezer)
 #endif
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f519a88..009e5e4 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -20,7 +20,7 @@
 #ifndef _LINUX_MEMCONTROL_H
 #define _LINUX_MEMCONTROL_H
 
-#struct mem_cgroup;
+struct mem_cgroup;
 struct page_cgroup;
 struct page;
 struct mm_struct;
@@ -49,6 +49,9 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
+extern struct cgroup *get_cgroup_from_page(struct page *page);
+extern void put_cgroup_from_page(struct page *page);
+
 #define mm_match_cgroup(mm, cgroup)	\
 	((cgroup) == mem_cgroup_from_task((mm)->owner))
 
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 271c1c2..0cb9251 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -14,30 +14,36 @@
  */
 
 #include <linux/cgroup.h>
+#include <linux/jiffies.h>
 
-/*
- * The core object. the cgroup that wishes to account for some
- * resource may include this counter into its structures and use
- * the helpers described beyond
- */
+/* The various policies that can be used for ratelimiting resources */
+#define	RATELIMIT_LEAKY_BUCKET	0
+#define	RATELIMIT_TOKEN_BUCKET	1
 
+/**
+ * struct res_counter - the core object to account cgroup resources
+ *
+ * @usage:	the current resource consumption level
+ * @max_usage:	the maximal value of the usage from the counter creation
+ * @limit:	the limit that usage cannot be exceeded
+ * @failcnt:	the number of unsuccessful attempts to consume the resource
+ * @policy:	the limiting policy / algorithm
+ * @capacity:	the maximum capacity of the resource
+ * @timestamp:	timestamp of the last accounted resource request
+ * @lock:	the lock to protect all of the above.
+ *		The routines below consider this to be IRQ-safe
+ *
+ * The cgroup that wishes to account for some resource may include this counter
+ * into its structures and use the helpers described beyond.
+ */
 struct res_counter {
-	/*
-	 * the current resource consumption level
-	 */
 	unsigned long long usage;
-	/*
-	 * the maximal value of the usage from the counter creation
-	 */
 	unsigned long long max_usage;
-	/*
-	 * the limit that usage cannot exceed
-	 */
 	unsigned long long limit;
-	/*
-	 * the number of unsuccessful attempts to consume the resource
-	 */
 	unsigned long long failcnt;
+	unsigned long long policy;
+	unsigned long long capacity;
+	unsigned long long timestamp;
 	/*
 	 * the lock to protect all of the above.
 	 * the routines below consider this to be IRQ-safe
@@ -80,6 +86,9 @@ enum {
 	RES_USAGE,
 	RES_MAX_USAGE,
 	RES_LIMIT,
+	RES_POLICY,
+	RES_TIMESTAMP,
+	RES_CAPACITY,
 	RES_FAILCNT,
 };
 
@@ -126,6 +135,15 @@ static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
 	return false;
 }
 
+static inline unsigned long long
+res_counter_ratelimit_delta_t(struct res_counter *res)
+{
+	return (long long)get_jiffies_64() - (long long)res->timestamp;
+}
+
+unsigned long long
+res_counter_ratelimit_sleep(struct res_counter *res, ssize_t val);
+
 /*
  * Helper function to detect if the cgroup is within it's limit or
  * not. It's currently called from cgroup_rss_prepare()
@@ -159,6 +177,23 @@ static inline void res_counter_reset_failcnt(struct res_counter *cnt)
 	spin_unlock_irqrestore(&cnt->lock, flags);
 }
 
+static inline int
+res_counter_ratelimit_set_limit(struct res_counter *cnt,
+			unsigned long long policy,
+			unsigned long long limit, unsigned long long max)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	cnt->limit = limit;
+	cnt->capacity = max;
+	cnt->policy = policy;
+	cnt->timestamp = get_jiffies_64();
+	cnt->usage = 0;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return 0;
+}
+
 static inline int res_counter_set_limit(struct res_counter *cnt,
 		unsigned long long limit)
 {
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 346616d..49426be 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1250,6 +1250,13 @@ struct task_struct {
 	unsigned long ptrace_message;
 	siginfo_t *last_siginfo; /* For ptrace use.  */
 	struct task_io_accounting ioac;
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+	atomic_t in_aio;
+	unsigned long long io_throttle_bw_cnt;
+	unsigned long long io_throttle_bw_sleep;
+	unsigned long long io_throttle_iops_cnt;
+	unsigned long long io_throttle_iops_sleep;
+#endif
 #if defined(CONFIG_TASK_XACCT)
 	u64 acct_rss_mem1;	/* accumulated rss usage */
 	u64 acct_vm_mem1;	/* accumulated virtual memory usage */
diff --git a/init/Kconfig b/init/Kconfig
index 6394a25..06649c5 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -313,6 +313,16 @@ config CGROUP_DEVICE
 	  Provides a cgroup implementing whitelists for devices which
 	  a process in the cgroup can mknod or open.
 
+config CGROUP_IO_THROTTLE
+	bool "Enable cgroup I/O throttling (EXPERIMENTAL)"
+	depends on CGROUPS && CGROUP_MEM_RES_CTLR && RESOURCE_COUNTERS && EXPERIMENTAL
+	help
+	  This allows to limit the maximum I/O bandwidth for specific
+	  cgroup(s).
+	  See Documentation/controllers/io-throttle.txt for more information.
+
+	  If unsure, say N.
+
 config CPUSETS
 	bool "Cpuset support"
 	depends on SMP && CGROUPS
diff --git a/kernel/fork.c b/kernel/fork.c
index dba2d3f..8188067 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1025,6 +1025,14 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	task_io_accounting_init(&p->ioac);
 	acct_clear_integrals(p);
 
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+	atomic_set(&p->in_aio, 0);
+	p->io_throttle_bw_cnt = 0;
+	p->io_throttle_bw_sleep = 0;
+	p->io_throttle_iops_cnt = 0;
+	p->io_throttle_iops_sleep = 0;
+#endif
+
 	posix_cpu_timers_init(p);
 
 	p->lock_depth = -1;		/* -1 = no lock */
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index f275c8e..e55c674 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -9,6 +9,7 @@
 
 #include <linux/types.h>
 #include <linux/parser.h>
+#include <linux/jiffies.h>
 #include <linux/fs.h>
 #include <linux/slab.h>
 #include <linux/res_counter.h>
@@ -19,6 +20,8 @@ void res_counter_init(struct res_counter *counter)
 {
 	spin_lock_init(&counter->lock);
 	counter->limit = (unsigned long long)LLONG_MAX;
+	counter->capacity = (unsigned long long)LLONG_MAX;
+	counter->timestamp = get_jiffies_64();
 }
 
 int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
@@ -62,7 +65,6 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
 	spin_unlock_irqrestore(&counter->lock, flags);
 }
 
-
 static inline unsigned long long *
 res_counter_member(struct res_counter *counter, int member)
 {
@@ -73,6 +75,12 @@ res_counter_member(struct res_counter *counter, int member)
 		return &counter->max_usage;
 	case RES_LIMIT:
 		return &counter->limit;
+	case RES_POLICY:
+		return &counter->policy;
+	case RES_TIMESTAMP:
+		return &counter->timestamp;
+	case RES_CAPACITY:
+		return &counter->capacity;
 	case RES_FAILCNT:
 		return &counter->failcnt;
 	};
@@ -137,3 +145,66 @@ int res_counter_write(struct res_counter *counter, int member,
 	spin_unlock_irqrestore(&counter->lock, flags);
 	return 0;
 }
+
+static unsigned long long
+ratelimit_leaky_bucket(struct res_counter *res, ssize_t val)
+{
+	unsigned long long delta, t;
+
+	res->usage += val;
+	delta = res_counter_ratelimit_delta_t(res);
+	if (!delta)
+		return 0;
+	t = res->usage * USEC_PER_SEC;
+	t = usecs_to_jiffies(div_u64(t, res->limit));
+	if (t > delta)
+		return t - delta;
+	/* Reset i/o statistics */
+	res->usage = 0;
+	res->timestamp = get_jiffies_64();
+	return 0;
+}
+
+static unsigned long long
+ratelimit_token_bucket(struct res_counter *res, ssize_t val)
+{
+	unsigned long long delta;
+	long long tok;
+
+	res->usage -= val;
+	delta = jiffies_to_msecs(res_counter_ratelimit_delta_t(res));
+	res->timestamp = get_jiffies_64();
+	tok = (long long)res->usage * MSEC_PER_SEC;
+	if (delta) {
+		long long max = (long long)res->capacity * MSEC_PER_SEC;
+
+		tok += delta * res->limit;
+		if (tok > max)
+			tok = max;
+		res->usage = (unsigned long long)div_s64(tok, MSEC_PER_SEC);
+	}
+	return (tok < 0) ? msecs_to_jiffies(div_u64(-tok, res->limit)) : 0;
+}
+
+unsigned long long
+res_counter_ratelimit_sleep(struct res_counter *res, ssize_t val)
+{
+	unsigned long long sleep = 0;
+	unsigned long flags;
+
+	spin_lock_irqsave(&res->lock, flags);
+	if (res->limit)
+		switch (res->policy) {
+		case RATELIMIT_LEAKY_BUCKET:
+			sleep = ratelimit_leaky_bucket(res, val);
+			break;
+		case RATELIMIT_TOKEN_BUCKET:
+			sleep = ratelimit_token_bucket(res, val);
+			break;
+		default:
+			WARN_ON(1);
+			break;
+		}
+	spin_unlock_irqrestore(&res->lock, flags);
+	return sleep;
+}
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 95048fe..097278c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -241,6 +241,36 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 				struct mem_cgroup, css);
 }
 
+struct cgroup *get_cgroup_from_page(struct page *page)
+{
+	struct page_cgroup *pc;
+	struct cgroup *cgrp = NULL;
+
+	pc = lookup_page_cgroup(page);
+	if (pc) {
+		lock_page_cgroup(pc);
+		if(pc->mem_cgroup) {
+			css_get(&pc->mem_cgroup->css);
+			cgrp = pc->mem_cgroup->css.cgroup;
+		}
+		unlock_page_cgroup(pc);
+	}
+
+	return cgrp;
+}
+
+void put_cgroup_from_page(struct page *page)
+{
+	struct page_cgroup *pc;
+
+	pc = lookup_page_cgroup(page);
+	if (pc) {
+		lock_page_cgroup(pc);
+		css_put(&pc->mem_cgroup->css);
+		unlock_page_cgroup(pc);
+	}
+}
+
 static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
 			struct page_cgroup *pc)
 {
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index f24daaa..6112fa4 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -20,6 +20,7 @@
 #include <linux/slab.h>
 #include <linux/pagemap.h>
 #include <linux/writeback.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/init.h>
 #include <linux/backing-dev.h>
 #include <linux/task_io_accounting_ops.h>
@@ -557,6 +558,9 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 	static DEFINE_PER_CPU(unsigned long, ratelimits) = 0;
 	unsigned long ratelimit;
 	unsigned long *p;
+	struct block_device *bdev = as_to_bdev(mapping);
+
+	cgroup_io_throttle(NULL, bdev, 0, 1);
 
 	ratelimit = ratelimit_pages;
 	if (mapping->backing_dev_info->dirty_exceeded)
diff --git a/mm/readahead.c b/mm/readahead.c
index bec83c1..7debb81 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -14,6 +14,7 @@
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 
@@ -58,6 +59,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 			int (*filler)(void *, struct page *), void *data)
 {
 	struct page *page;
+	struct block_device *bdev = as_to_bdev(mapping);
 	int ret = 0;
 
 	while (!list_empty(pages)) {
@@ -76,6 +78,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 			break;
 		}
 		task_io_account_read(PAGE_CACHE_SIZE);
+		cgroup_io_throttle(NULL, bdev, PAGE_CACHE_SIZE, 1);
 	}
 	return ret;
 }
-- 1.5.4.rc3 
