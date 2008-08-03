From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH -mm 1/3] i/o controller documentation
Date: Mon,  4 Aug 2008 00:14:56 +0200
Message-ID: <1217801698-13438-2-git-send-email-righi.andrea__35938.5763099$1217802026$gmane$org@gmail.com>
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

Documentation of the block device I/O controller: description, usage,
advantages and design.

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 Documentation/controllers/io-throttle.txt |  312 +++++++++++++
 block/blk-io-throttle.c                   |  719 +++++++++++++++++++++++++++++
 include/linux/blk-io-throttle.h           |   41 ++
 3 files changed, 1072 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/controllers/io-throttle.txt
 create mode 100644 block/blk-io-throttle.c
 create mode 100644 include/linux/blk-io-throttle.h

diff --git a/Documentation/controllers/io-throttle.txt b/Documentation/controllers/io-throttle.txt
new file mode 100644
index 0000000..3fa6e4a
--- /dev/null
+++ b/Documentation/controllers/io-throttle.txt
@@ -0,0 +1,312 @@
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
+  used:
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
+2.2. Show I/O bandwidth limiting rules
+
+All the defined rules and statistics for a specific cgroup can be shown reading
+the file blockio.bandwidth-max. The following syntax is used:
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
+  8 32 100 0 232268
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
+schedule_timeout_killable() on the processes that exceed the I/O limits
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
+* Try to reduce the cost of calling cgroup_io_throttle() on every
+  submit_bio(READ, ...); this is not too much expensive, but the call of
+  task_subsys_state() has surely a cost. A possible solution could be to
+  temporarily account I/O in the current task_struct and call
+  cgroup_io_throttle() only on each X MB of I/O. Or on each Y number of I/O
+  requests as well. Better if both X and/or Y can be tuned at runtime by a
+  userspace tool.
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
diff --git a/block/blk-io-throttle.c b/block/blk-io-throttle.c
new file mode 100644
index 0000000..8796f92
--- /dev/null
+++ b/block/blk-io-throttle.c
@@ -0,0 +1,719 @@
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
+#include <linux/cgroup.h>
+#include <linux/slab.h>
+#include <linux/gfp.h>
+#include <linux/err.h>
+#include <linux/sched.h>
+#include <linux/genhd.h>
+#include <linux/fs.h>
+#include <linux/jiffies.h>
+#include <linux/hardirq.h>
+#include <linux/list.h>
+#include <linux/seq_file.h>
+#include <linux/spinlock.h>
+#include <linux/uaccess.h>
+#include <linux/blk-io-throttle.h>
+
+#define IOTHROTTLE_BANDWIDTH	0
+#define IOTHROTTLE_IOPS		1
+
+/* The various types of throttling algorithms */
+enum iothrottle_strategy {
+	IOTHROTTLE_LEAKY_BUCKET = 0,
+	IOTHROTTLE_TOKEN_BUCKET = 1,
+};
+
+/**
+ * struct iothrottle_node - throttling rule of a single block device
+ * @node: list of per block device throttling rules
+ * @dev: block device number, used as key in the list
+ *
+ * @iorate: max i/o bandwidth (in bytes/s)
+ * @strategy: throttling strategy (leaky bucket / token bucket)
+ * @timestamp: timestamp of the last i/o request for bandwidth limiting
+ *             (in jiffies)
+ * @stat: i/o activity counter (leaky bucket only)
+ * @bucket_size: bucket size in bytes (token bucket only)
+ * @token: token counter (token bucket only)
+ *
+ * @iops: max i/o operations per second
+ * @iops_stat: i/o operations counter (leaky bucket policy)
+ * @iops_timestamp: timestamp of the last i/o request for iops/sec limiting
+ *                  (in jiffies)
+ * @iops_strategy: throttling strategy (leaky bucket / token bucket)
+ * @iops_bucket_size: bucket size in i/o operations * 1000 (token bucket only)
+ * @iops_token: token counter (token bucket only)
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
+
+	u64 iorate;
+	enum iothrottle_strategy strategy;
+	unsigned long timestamp;
+	atomic_long_t stat;
+	s64 bucket_size;
+	atomic_long_t token;
+
+	u64 iops;
+	enum iothrottle_strategy iops_strategy;
+	atomic_long_t iops_stat;
+	unsigned long iops_timestamp;
+	s64 iops_bucket_size;
+	atomic_long_t iops_token;
+};
+
+/**
+ * struct iothrottle - throttling rules for a cgroup
+ * @css: pointer to the cgroup state
+ * @lock: spinlock used to protect write operations in the list
+ * @list: list of iothrottle_node elements
+ *
+ * Define multiple per-block device i/o throttling rules.
+ * Note: the list of the throttling rules is protected by RCU locking.
+ */
+struct iothrottle {
+	struct cgroup_subsys_state css;
+	spinlock_t lock; /* used to protect write operations in the list */
+	struct list_head list;
+};
+
+static inline struct iothrottle *cgroup_to_iothrottle(struct cgroup *cgrp)
+{
+	return container_of(cgroup_subsys_state(cgrp, iothrottle_subsys_id),
+			    struct iothrottle, css);
+}
+
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
+	iot = kmalloc(sizeof(*iot), GFP_KERNEL);
+	if (unlikely(!iot))
+		return ERR_PTR(-ENOMEM);
+
+	INIT_LIST_HEAD(&iot->list);
+	spin_lock_init(&iot->lock);
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
+	list_for_each_entry_safe(n, p, &iot->list, node)
+		kfree(n);
+	kfree(iot);
+}
+
+static int iothrottle_read(struct cgroup *cgrp, struct cftype *cft,
+				struct seq_file *m)
+{
+	struct iothrottle *iot = cgroup_to_iothrottle(cgrp);
+	struct iothrottle_node *n;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(n, &iot->list, node) {
+		unsigned long delta;
+
+		BUG_ON(!n->dev);
+		switch (cft->private) {
+		case IOTHROTTLE_BANDWIDTH:
+			if (!n->iorate)
+				continue;
+			delta = jiffies_to_msecs((long)jiffies -
+					(long)n->timestamp);
+			seq_printf(m, "%u %u %llu %u %li %lli %li %lu\n",
+				MAJOR(n->dev), MINOR(n->dev),
+				(unsigned long long)n->iorate, n->strategy,
+				atomic_long_read(&n->stat),
+				(long long)n->bucket_size,
+				atomic_long_read(&n->token),
+				delta);
+			break;
+		case IOTHROTTLE_IOPS:
+			if (!n->iops)
+				continue;
+			delta = jiffies_to_msecs((long)jiffies -
+					(long)n->iops_timestamp);
+			seq_printf(m, "%u %u %llu %u %li %lli %li %lu\n",
+				MAJOR(n->dev), MINOR(n->dev),
+				(unsigned long long)n->iops, n->iops_strategy,
+				atomic_long_read(&n->iops_stat),
+				(long long)n->iops_bucket_size,
+				atomic_long_read(&n->iops_token),
+				delta);
+			break;
+		}
+	}
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
+
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
+					dev_t *dev, u64 *iolimit,
+					enum iothrottle_strategy *strategy,
+					s64 *bucket_size)
+{
+	char *p;
+	int count = 0;
+	char *s[4];
+	unsigned long strategy_val;
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
+	ret = strict_strtoul(s[2], 10, &strategy_val);
+	if (ret < 0)
+		return ret;
+	*strategy = (enum iothrottle_strategy)strategy_val;
+	switch (*strategy) {
+	case IOTHROTTLE_LEAKY_BUCKET:
+		goto out;
+	case IOTHROTTLE_TOKEN_BUCKET:
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
+	u64 iolimit;
+	enum iothrottle_strategy strategy;
+	s64 bucket_size;
+	char *buf;
+	size_t nbytes = strlen(buffer);
+	int ret = 0;
+
+	buf = kmalloc(nbytes + 1, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+	memcpy(buf, buffer, nbytes + 1);
+
+	ret = iothrottle_parse_args(buf, nbytes, cft->private, &dev, &iolimit,
+					&strategy, &bucket_size);
+	if (ret)
+		goto out1;
+	newn = kmalloc(sizeof(*newn), GFP_KERNEL);
+	if (!newn) {
+		ret = -ENOMEM;
+		goto out1;
+	}
+	newn->dev = dev;
+
+	switch (cft->private) {
+	case IOTHROTTLE_BANDWIDTH:
+		newn->iops = 0;
+		newn->iorate = ALIGN(iolimit, 1024);
+		newn->strategy = strategy;
+		newn->bucket_size = ALIGN(bucket_size, 1024);
+		atomic_long_set(&newn->stat, 0);
+		atomic_long_set(&newn->token, 0);
+		newn->timestamp = jiffies;
+		break;
+	case IOTHROTTLE_IOPS:
+		newn->iorate = 0;
+		newn->iops = iolimit;
+		newn->iops_strategy = strategy;
+		newn->iops_bucket_size = bucket_size;
+		atomic_long_set(&newn->iops_stat, 0);
+		atomic_long_set(&newn->iops_token, 0);
+		newn->iops_timestamp = jiffies;
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
+	spin_lock(&iot->lock);
+	n = iothrottle_search_node(iot, dev);
+	if (!n) {
+		/* Add a new block device limiting rule */
+		iothrottle_insert_node(iot, newn);
+		newn = NULL;
+		goto out2;
+	}
+
+	switch (cft->private) {
+	case IOTHROTTLE_BANDWIDTH:
+		if (!iolimit && !n->iops) {
+			/* Delete a block device limiting rule */
+			iothrottle_delete_node(iot, n);
+			goto out2;
+		}
+		if (!n->iops)
+			break;
+		/* Update a block device limiting rule */
+		newn->iops = n->iops;
+		newn->iops_strategy = n->iops_strategy;
+		newn->iops_bucket_size = n->iops_bucket_size;
+		newn->iops_timestamp = n->iops_timestamp;
+		atomic_long_set(&newn->iops_stat,
+				atomic_long_read(&n->iops_stat));
+		atomic_long_set(&newn->iops_token,
+				atomic_long_read(&n->iops_token));
+		break;
+	case IOTHROTTLE_IOPS:
+		if (!iolimit && !n->iorate) {
+			/* Delete a block device limiting rule */
+			iothrottle_delete_node(iot, n);
+			goto out2;
+		}
+		if (!n->iorate)
+			break;
+		/* Update a block device limiting rule */
+		newn->iorate = n->iorate;
+		newn->strategy = n->strategy;
+		newn->bucket_size = n->bucket_size;
+		newn->timestamp = n->timestamp;
+		atomic_long_set(&newn->stat, atomic_long_read(&n->stat));
+		atomic_long_set(&newn->token, atomic_long_read(&n->token));
+		break;
+	}
+	iothrottle_replace_node(iot, n, newn);
+	newn = NULL;
+out2:
+	spin_unlock(&iot->lock);
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
+};
+
+/*
+ * Note: called with rcu_read_lock() held.
+ */
+static unsigned long bw_leaky_bucket(struct iothrottle_node *n, ssize_t bytes)
+{
+	unsigned long delta, t;
+	long sleep, stat;
+
+	/* Account the i/o activity */
+	atomic_long_add(bytes, &n->stat);
+
+	/* Evaluate if we need to throttle the current process */
+	delta = (long)jiffies - (long)n->timestamp;
+	if (!delta)
+		return 0;
+
+	/*
+	 * NOTE: n->iorate cannot be set to zero here, iorate can only change
+	 * via the userspace->kernel interface that in case of update fully
+	 * replaces the iothrottle_node pointer in the list, using the RCU way.
+	 */
+	stat = atomic_long_read(&n->stat);
+	if (stat > 0) {
+		t = stat * USEC_PER_SEC;
+		t = usecs_to_jiffies(div_u64(t, n->iorate));
+		if (!t)
+			return 0;
+		sleep = t - delta;
+		if (unlikely(sleep > 0))
+			return sleep;
+	}
+	/* Reset i/o statistics */
+	atomic_long_set(&n->stat, 0);
+	/*
+	 * NOTE: be sure i/o statistics have been resetted before updating the
+	 * timestamp, otherwise a very small time delta may possibly be read by
+	 * another CPU w.r.t. accounted i/o statistics, generating unnecessary
+	 * long sleeps.
+	 */
+	smp_wmb();
+	n->timestamp = jiffies;
+	return 0;
+}
+
+/*
+ * Note: called with rcu_read_lock() held.
+ * XXX: need locking in order to evaluate a consistent sleep???
+ */
+static unsigned long bw_token_bucket(struct iothrottle_node *n, ssize_t bytes)
+{
+	unsigned long iorate = div_u64(n->iorate, MSEC_PER_SEC);
+	unsigned long delta;
+	long tok;
+
+	BUG_ON(!iorate);
+
+	atomic_long_sub(bytes, &n->token);
+	delta = jiffies_to_msecs((long)jiffies - (long)n->timestamp);
+	n->timestamp = jiffies;
+	tok = atomic_long_read(&n->token);
+	if (delta && tok < n->bucket_size) {
+		tok += delta * iorate;
+		pr_debug("io-throttle: adding %lu tokens\n", delta * iorate);
+		if (tok > n->bucket_size)
+			tok = n->bucket_size;
+		atomic_long_set(&n->token, tok);
+	}
+	return (tok < 0) ? msecs_to_jiffies(-tok / iorate) : 0;
+}
+
+/*
+ * This function uses a leaky bucket policy to throttle iops/sec.
+ *
+ * Note: called with rcu_read_lock() held.
+ */
+static unsigned long iops_leaky_bucket(struct iothrottle_node *n)
+{
+	unsigned long delta, t;
+	long sleep, stat;
+
+	atomic_long_add(1, &n->iops_stat);
+
+	delta = (long)jiffies - (long)n->iops_timestamp;
+	if (!delta)
+		return 0;
+
+	stat = atomic_long_read(&n->iops_stat);
+	if (stat > 0) {
+		t = stat * USEC_PER_SEC;
+		t = usecs_to_jiffies(div_u64(t, n->iops));
+		if (!t)
+			return 0;
+		sleep = t - delta;
+		if (unlikely(sleep > 0))
+			return sleep;
+	}
+	atomic_long_set(&n->iops_stat, 0);
+	/*
+	 * NOTE: be sure iops/sec statistics have been resetted before updating
+	 * the timestamp, otherwise a very small time delta may possibly be
+	 * read by another CPU w.r.t. accounted iops/sec statistics, generating
+	 * unnecessary long sleeps.
+	 */
+	smp_wmb();
+	n->iops_timestamp = jiffies;
+	return 0;
+}
+
+/*
+ * Note: called with rcu_read_lock() held.
+ * XXX: need locking in order to evaluate a consistent sleep???
+ */
+static unsigned long iops_token_bucket(struct iothrottle_node *n)
+{
+	unsigned long iops = n->iops;
+	unsigned long delta;
+	long tok;
+
+	BUG_ON(!iops);
+	/*
+	 * Scale up tokens by a factor of MSEC_PER_SEC, to evaluate a more fine
+	 * grained sleep.
+	 */
+	atomic_long_sub(MSEC_PER_SEC, &n->iops_token);
+	delta = jiffies_to_msecs((long)jiffies - (long)n->iops_timestamp);
+	n->iops_timestamp = jiffies;
+	tok = atomic_long_read(&n->iops_token);
+	if (delta && tok < (n->iops_bucket_size * MSEC_PER_SEC)) {
+		tok += delta * iops;
+		pr_debug("io-throttle: adding %lu tokens\n", delta * iops);
+		if (tok > (n->iops_bucket_size * MSEC_PER_SEC))
+			tok = n->iops_bucket_size * MSEC_PER_SEC;
+		atomic_long_set(&n->iops_token, tok);
+	}
+	return (tok < 0) ? msecs_to_jiffies(-tok / iops) : 0;
+}
+
+/**
+ * cgroup_io_throttle() - account and throttle i/o activity
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
+unsigned long
+cgroup_io_throttle(struct block_device *bdev, ssize_t bytes, int can_sleep)
+{
+	struct iothrottle *iot;
+	struct iothrottle_node *n;
+	dev_t dev;
+	unsigned long sleep = 0;
+	unsigned long iops_sleep = 0;
+
+	if (unlikely(!bdev))
+		return 0;
+	/*
+	 * WARNING: in_atomic() do not know about held spinlocks in
+	 * non-preemptible kernels, but we want to check it here to raise
+	 * potential bugs by preemptible kernels.
+	 */
+	WARN_ON_ONCE(can_sleep &&
+			(irqs_disabled() || in_interrupt() || in_atomic()));
+	/*
+	 * Do not make kernel threads to sleep, since they may completely block
+	 * other cgroups, the i/o on other devices or even the whole system.
+	 */
+	if (current->flags & PF_KTHREAD)
+		can_sleep = 0;
+	/*
+	 * AIO is accounted in io_submit_one(); instead of making the current
+	 * task to sleep, AIO throttling is performed returning -EAGAIN from
+	 * sys_io_submit().
+	 */
+	if (is_in_aio() && (bytes >= 0))
+		return 0;
+
+	iot = task_to_iothrottle(current);
+
+	BUG_ON(!iot);
+	BUG_ON(!bdev->bd_inode || !bdev->bd_disk);
+
+	/* accounting and throttling is done only on entire block devices */
+	dev = MKDEV(MAJOR(bdev->bd_inode->i_rdev), bdev->bd_disk->first_minor);
+
+	rcu_read_lock();
+	n = iothrottle_search_node(iot, dev);
+	if (!n) {
+		rcu_read_unlock();
+		return 0;
+	}
+	if (n->iorate)
+		switch (n->strategy) {
+		case IOTHROTTLE_LEAKY_BUCKET:
+			sleep = bw_leaky_bucket(n, bytes);
+			break;
+		case IOTHROTTLE_TOKEN_BUCKET:
+			sleep = bw_token_bucket(n, bytes);
+			break;
+		}
+	if (n->iops)
+		switch (n->iops_strategy) {
+		case IOTHROTTLE_LEAKY_BUCKET:
+			iops_sleep = iops_leaky_bucket(n);
+			break;
+		case IOTHROTTLE_TOKEN_BUCKET:
+			iops_sleep = iops_token_bucket(n);
+			break;
+		}
+	if (iops_sleep > sleep)
+		sleep = iops_sleep;
+	if (unlikely(can_sleep && sleep && (bytes >= 0))) {
+		rcu_read_unlock();
+		pr_debug("io-throttle: task %p (%s) must sleep %lu jiffies\n",
+			 current, current->comm, sleep);
+		schedule_timeout_killable(sleep);
+		return 0;
+	}
+	rcu_read_unlock();
+
+	return sleep;
+}
+EXPORT_SYMBOL(cgroup_io_throttle);
diff --git a/include/linux/blk-io-throttle.h b/include/linux/blk-io-throttle.h
new file mode 100644
index 0000000..d2d8b04
--- /dev/null
+++ b/include/linux/blk-io-throttle.h
@@ -0,0 +1,41 @@
+#ifndef BLK_IO_THROTTLE_H
+#define BLK_IO_THROTTLE_H
+
+#include <linux/sched.h>
+
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+extern unsigned long
+cgroup_io_throttle(struct block_device *bdev, ssize_t bytes, int can_sleep);
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
+#else
+static inline unsigned long
+cgroup_io_throttle(struct block_device *bdev, ssize_t bytes, int can_sleep)
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
+#endif /* CONFIG_CGROUP_IO_THROTTLE */
+
+#endif /* BLK_IO_THROTTLE_H */
-- 
1.5.4.3
