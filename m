From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v15 1/7] io-throttle documentation
Date: Tue, 28 Apr 2009 10:43:48 +0200
Message-ID: <1240908234-15434-2-git-send-email-righi.andrea__41015.6024889604$1240908493$gmane$org@gmail.com>
References: <1240908234-15434-1-git-send-email-righi.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240908234-15434-1-git-send-email-righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, tytso-3s7WtUTddSA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Documentation of the block device I/O controller: description, usage,
advantages and design.

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 Documentation/cgroups/io-throttle.txt |  417 +++++++++++++++++++++++++++++++++
 1 files changed, 417 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/cgroups/io-throttle.txt

diff --git a/Documentation/cgroups/io-throttle.txt b/Documentation/cgroups/io-throttle.txt
new file mode 100644
index 0000000..789116c
--- /dev/null
+++ b/Documentation/cgroups/io-throttle.txt
@@ -0,0 +1,417 @@
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
+2.5. Generic usage examples
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
+The I/O throttling is performed imposing an explicit timeout on the processes
+that exceed the I/O limits dedicated to the cgroup they belong to. I/O
+accounting happens per cgroup.
+
+Only the actual I/O that flows in the block devices is considered. Multiple
+re-reads of pages already present in the page cache as well as re-writes of
+dirty pages are not considered to account and throttle the I/O activity, since
+they don't actually generate any real I/O operation.
+
+This means that a process that re-reads or re-writes multiple times the same
+blocks of a file is affected by the I/O limitations only for the actual I/O
+performed from/to the underlying block devices.
+
+4.1. Synchronous I/O tracking and throttling
+
+The io-throttle controller just works as expected for synchronous (read and
+write) operations: the real I/O activity is reduced synchronously according to
+the defined limitations.
+
+If the operation is synchronous we automatically know that the context of the
+request is the current task and so we can charge the cgroup the current task
+belongs to. And throttle the current task as well, if it exceeded the cgroup
+limitations.
+
+4.2. Buffered I/O (write-back) tracking
+
+For buffered writes the scenario is a bit more complex, because the writes in
+the page cache are processed asynchronously by kernel threads (pdflush), using
+a write-back policy. So the real writes to the underlying block devices occur
+in a different I/O context respect to the task that originally generated the
+dirty pages.
+
+The I/O bandwidth controller uses the following solution to resolve this
+problem.
+
+If the operation is a buffered write, we can charge the right cgroup looking at
+the owner of the first page involved in the I/O operation, that gives the
+context that generated the I/O activity at the source. This information can be
+retrieved using the page_cgroup functionality originally provided by the cgroup
+memory controller [4], and now provided by a modified version of the bio-cgroup
+controller [5], embedding the page tracking feature directly into the
+io-throttle controller.
+
+The page_cgroup structure is used to encode the owner of each struct page: this
+information is encoded in page_cgroup->flags. A owner is characterized by a
+numeric ID: the io-throttle css_id(). The owner of a page is set when a page is
+dirtied or added to the page cache. At the moment I/O generated by anonymous
+pages (swap) is not considered by the io-throttle controller.
+
+In this way we can correctly account the I/O cost to the right cgroup, but we
+cannot throttle the current task in this stage, because, in general, it is a
+different task (e.g., pdflush that is processing asynchronously the dirty
+page).
+
+For this reason, all the write-back requests that are not directly submitted by
+the real owner and that need to be throttled are not dispatched immediately in
+submit_bio(). Instead, they are added into an rbtree and processed
+asynchronously by a dedicated kernel thread: kiothrottled.
+
+A deadline is associated to each throttled write-back request depending on the
+bandwidth usage of the cgroup it belongs. When a request is inserted into the
+rbtree kiothrottled is awakened. This thread periodically selects all the
+requests with an expired deadline and submit the bunch of selected requests to
+the underlying block devices using generic_make_request().
+
+4.3. Per-block device IO limiting rules
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
+4.4. Asynchronous I/O (AIO) handling
+
+Explicit sleeps are *not* imposed on tasks doing asynchronous I/O (AIO)
+operations; AIO throttling is performed returning -EAGAIN from sys_io_submit().
+Userspace applications must be able to handle this error code opportunely.
+
+----------------------------------------------------------------------
+5. TODO
+
+* Support proportional I/O bandwidth for an optimal bandwidth usage. For
+  example use the kiothrottled rbtree: all the requests queued to the I/O
+  subsystem first will go into the rbtree; then based on a per-cgroup I/O
+  priority and feedback from I/O schedulers dispatch the requests to the
+  elevator. This would allow to provide both bandwidth limiting and
+  proportional bandwidth functionalities using a generic approach.
+
+* Implement a fair throttling policy: distribute the time to sleep equally
+  among all the tasks of a cgroup that exceeded the I/O limits, e.g., depending
+  of the amount of I/O activity previously generated in the past by each task
+  (see task_io_accounting).
+
+----------------------------------------------------------------------
+6. REFERENCES
+
+[1] Documentation/cgroups/cgroups.txt
+[2] http://en.wikipedia.org/wiki/Leaky_bucket
+[3] http://en.wikipedia.org/wiki/Token_bucket
+[4] Documentation/controllers/memory.txt
+[5] http://people.valinux.co.jp/~ryov/bio-cgroup
-- 
1.6.0.4
