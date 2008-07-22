From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH -mm 1/3] i/o bandwidth controller documentation
Date: Tue, 22 Jul 2008 22:58:57 +0200
Message-ID: <1216760339-24205-2-git-send-email-righi.andrea__7972.28883388943$1216760501$gmane$org@gmail.com>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Documentation of the block device I/O bandwidth controller: description, usage,
advantages and design.

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 Documentation/controllers/io-throttle.txt |  328 +++++++++++++++++++++++++++++
 1 files changed, 328 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/controllers/io-throttle.txt

diff --git a/Documentation/controllers/io-throttle.txt b/Documentation/controllers/io-throttle.txt
new file mode 100644
index 0000000..f6b8bb9
--- /dev/null
+++ b/Documentation/controllers/io-throttle.txt
@@ -0,0 +1,328 @@
+
+               Block device I/O bandwidth controller
+
+----------------------------------------------------------------------
+1. DESCRIPTION
+
+This controller allows to limit the I/O bandwidth of specific block devices for
+specific process containers (cgroups) imposing additional delays on I/O
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
+predictability and provide performance isolation of different control groups
+sharing the same block devices.
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
+A new I/O bandwidth limitation rule is described using the file
+blockio.bandwidth.
+
+The same file can be used to set multiple rules for different block devices
+relative to the same cgroup.
+
+2.1. Configure I/O bandwidth limiting rules
+
+The syntax to configure a limiting rule is the following:
+
+# /bin/echo DEV:BW:STRATEGY:BUCKET_SIZE > CGROUP/blockio.bandwidth
+
+- DEV is the name of the device the limiting rule is applied to.
+
+- BW is the maximum I/O bandwidth on DEV allowed by CGROUP; bandwidth must be
+  expressed in bytes/s. A generic I/O bandwidth limiting rule for a block
+  device DEV can be removed setting the BW value to 0.
+
+- STRATEGY is the throttling strategy used to throttle the applications' I/O
+  requests from/to device DEV. At the moment two different strategies can be
+  used:
+
+  0 = leaky bucket: the controller accepts at most B bytes (B = BW * time);
+		    further I/O requests are delayed scheduling a timeout for
+                    the tasks that made those requests.
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
+  1 = token bucket: BW tokens are added to the bucket every seconds; the bucket
+		    can hold at the most BUCKET_SIZE tokens; I/O requests are
+		    accepted if there are available tokens in the bucket; when
+		    a request of N bytes arrives N tokens are removed from the
+		    bucket; if fewer than N tokens are available the request is
+		    delayed until a sufficient amount of token is available in
+                    the bucket.
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
+  Leaky bucket is more precise than token bucket to respect the bandwidth
+  limits, because bursty workloads are always smoothed. Token bucket, instead,
+  allows a small irregularity degree in the I/O flows (burst limit), and, for
+  this, it is better in terms of efficiency (bursty workloads are not smoothed
+  when there are sufficient tokens in the bucket).
+
+- BUCKET_SIZE is used only with token bucket (STRATEGY == 1) and defines the
+  size of the bucket in bytes.
+
+- CGROUP is the name of the limited process container.
+
+Also the following syntaxes are allowed:
+
+- remove an I/O bandwidth limiting rule
+# /bin/echo DEV:0 > CGROUP/blockio.bandwidth
+
+- configure a limiting rule using leaky bucket throttling (ignore bucket size):
+# /bin/echo DEV:BW:0 > CGROUP/blockio.bandwidth
+
+2.2. Show I/O bandwidth limiting rules
+
+All the defined rules and statistics for a specific cgroup can be shown reading
+the file blockio.bandwidth. The following syntax is used:
+
+$ cat CGROUP/blockio.bandwidth
+MAJOR MINOR BW STRATEGY LEAKY_STAT BUCKET_SIZE BUCKET_FILL TIME_DELTA
+
+- MAJOR is the major device number of DEV (defined above)
+
+- MINOR is the minor device number of DEV (defined above)
+
+- BW, STRATEGY and BUCKET_SIZE are the same parameters defined above
+
+- LEAKY_STAT is the amount of bytes currently allowed by the I/O bandwidth
+  controller (only used with leaky bucket strategy - STRATEGY == 0)
+
+- BUCKET_FILL represents the amount of tokens present in the bucket (only used
+  with token bucket strategy - STRATEGY == 1)
+
+- TIME_DELTA can be one of the following:
+  - the amount of jiffies elapsed from the last I/O request (token bucket)
+  - the amount of jiffies during which the bytes given by LEAKY_STAT have been
+    accumulated (leaky bucket)
+
+Multiple per-block device rules are reported in multiple rows
+(DEVi, i = 1 ..  n):
+
+$ cat CGROUP/blockio.bandwidth
+MAJOR1 MINOR1 BW1 STRATEGY1 LEAKY_STAT1 BUCKET_SIZE1 BUCKET_FILL1 TIME_DELTA1
+MAJOR1 MINOR1 BW2 STRATEGY2 LEAKY_STAT2 BUCKET_SIZE2 BUCKET_FILL2 TIME_DELTA2
+...
+MAJORn MINORn BWn STRATEGYn LEAKY_STATn BUCKET_SIZEn BUCKET_FILLn TIME_DELTAn
+
+2.3 Configure I/O operations/sec limiting rules
+
+The syntax to limit I/O operations/sec is the following:
+
+# /bin/echo DEV:IOPS > CGROUP/blockio.iops
+
+- DEV is the name of the device the limiting rule is applied to.
+
+- IOPS is the number of the maximum I/O operations per second that can be
+  issued on device DEV by the tasks belonging to cgroup CGROUP. The I/O
+  operations limit can be removed setting IOPS to 0.
+
+2.4 Show I/O operations/sec limiting rules
+
+The I/O operations limits and statistics for a specific cgroup can be shown
+reading the file blockio.ops. The following syntax is used:
+
+$ cat CGROUP/blockio.iops
+MAJOR MINOR IOPS IOPS_STAT TIME_DELTA
+
+- MAJOR is the major device number of DEV (defined above)
+
+- MINOR is the minor device number of DEV (defined above)
+
+- IOPS is the I/O operations/sec limit
+
+- IOPS_STAT is the number of I/O operations accumulated by the iops counter
+
+- TIME_DELTA can be one of the following:
+  - the amount of jiffies during which the number of I/O operations reported in
+    IOPS_STAT have been accumulated
+
+Multiple per-block device rules are reported in multiple rows
+(DEVi, i = 1 ..  n):
+
+$ cat CGROUP/blockio.bandwidth
+MAJOR1 MINOR1 IOPS1 IOPS_STAT1 TIME_DELTA1
+MAJOR2 MINOR2 IOPS2 IOPS_STAT2 TIME_DELTA2
+...
+MAJORn MINORn IOPSn IOPS_STATn TIME_DELTAn
+
+2.5. Examples
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
+  > /mnt/cgroup/foo/blockio.bandwidth
+  # sh
+  --> the subshell 'sh' is running in cgroup "foo" and it can use a maximum I/O
+      bandwidth of 1MiB/s on /dev/sda
+
+* Give maximum 8MiB/s of I/O bandwidth on /dev/sdb for the cgroup "foo", using
+  token bucket throttling strategy, bucket size = 8MiB:
+  # /bin/echo /dev/sdb:$((8 * 1024 * 1024)):1:$((8 * 1024 * 1024)) > \
+  > /mnt/cgroup/foo/blockio.bandwidth
+  # sh
+  --> the subshell 'sh' is running in cgroup "foo" and it can use a maximum I/O
+      bandwidth of 1MiB/s on /dev/sda (controlled by leaky bucket throttling)
+      and 8MiB/s on /dev/sdb (controlled by token bucket throttling)
+
+* Run a benchmark doing I/O on /dev/sda and /dev/sdb; I/O limits and usage
+  defined for cgroup "foo" can be shown as following:
+  # cat /mnt/cgroup/foo/blockio.bandwidth
+  8 16 8388608 1 0 8388608 -522560 48
+  8 0 1048576 0 737280 0 0 216
+
+* Extend the maximum I/O bandwidth for the cgroup "foo" to 16MiB/s on /dev/sda:
+  # /bin/echo /dev/sda:$((16 * 1024 * 1024)):0:0 > \
+  > /mnt/cgroup/foo/blockio.bandwidth
+  # cat /mnt/cgroup/foo/blockio.bandwidth
+  8 16 8388608 1 0 8388608 -84432 206436
+  8 0 16777216 0 0 0 0 15212
+
+* Remove limiting rule on /dev/sdb for cgroup "foo":
+  # /bin/echo /dev/sdb:0:0:0 > /mnt/cgroup/foo/blockio.bandwidth
+  # cat /mnt/cgroup/foo/blockio.bandwidth
+  8 0 16777216 0 0 0 0 110388
+
+* Set a maximum of 100 I/O operations/sec to /dev/sdc for cgroup "foo":
+  # /bin/echo /dev/sdc:100 > /mnt/cgroup/foo/blockio.iops
+  # cat /mnt/cgroup/foo/blockio.iops
+  8 32 100 0 232268
+
+* Remove limiting rule for I/O operations from /dev/sdc for cgroup "foo":
+  # /bin/echo /dev/sdc:0 > /mnt/cgroup/foo/blockio.iops
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
+* It is even possible to implement event-based performance throttling
+  mechanisms; for example the same user-space application could actively
+  throttle the I/O bandwidth to reduce power consumption when the battery of a
+  mobile device is running low (power throttling) or when the temperature of a
+  hardware component is too high (thermal throttling)
+
+----------------------------------------------------------------------
+4. DESIGN
+
+The I/O throttling is performed imposing an explicit timeout, via
+schedule_timeout_killable() on the processes that exceed the I/O bandwidth
+dedicated to the cgroup they belong to. I/O accounting happens per cgroup.
+
+It just works as expected for read operations: the real I/O activity is reduced
+synchronously according to the defined limitations.
+
+Write operations, instead, are modeled depending of the dirty pages ratio
+(write throttling in memory), since the writes to the real block devices are
+processed asynchronously by different kernel threads (pdflush). However, the
+dirty pages ratio is directly proportional to the actual I/O that will be
+performed on the real block device. So, due to the asynchronous transfers
+through the page cache, the I/O throttling in memory can be considered a form
+of anticipatory throttling to the underlying block devices.
+
+Multiple re-writes in already dirtied page cache areas are not considered for
+accounting the I/O activity. This is valid for multiple re-reads of pages
+already present in the page cache as well.
+
+This means that a process that re-writes and/or re-reads multiple times the
+same blocks in a file (without re-creating it by truncate(), ftrunctate(),
+creat(), etc.) is affected by the I/O limitations only for the actual I/O
+performed to (or from) the underlying block devices.
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
+  cost and usage (idea proposed by Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>).
-- 
1.5.4.3
