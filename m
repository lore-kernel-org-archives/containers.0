From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH -mm 3/6] i/o controller infrastructure
Date: Tue,  7 Oct 2008 12:03:35 +0200
Message-ID: <1223373818-13687-4-git-send-email-righi.andrea__13835.4084840559$1223374122$gmane$org@gmail.com>
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
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

This is the core of the cgroup-io-throttle kernel infrastructure. It creates
the basic interfaces to cgroups and implements the I/O measurement and
throttling functionality.

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/Makefile                  |    2 +
 block/blk-io-throttle.c         |  735 +++++++++++++++++++++++++++++++++++++++
 include/linux/blk-io-throttle.h |   95 +++++
 include/linux/cgroup_subsys.h   |    6 +
 init/Kconfig                    |   10 +
 5 files changed, 848 insertions(+), 0 deletions(-)
 create mode 100644 block/blk-io-throttle.c
 create mode 100644 include/linux/blk-io-throttle.h

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
index a5b0fa4..76dc04d 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -49,6 +49,12 @@ SUBSYS(devices)
 
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
diff --git a/init/Kconfig b/init/Kconfig
index a32de66..1eb83e1 100644
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
-- 
1.5.4.3
