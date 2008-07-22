From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH -mm 2/3] i/o bandwidth controller infrastructure
Date: Tue, 22 Jul 2008 22:58:58 +0200
Message-ID: <1216760339-24205-3-git-send-email-righi.andrea@gmail.com>
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

This is the core io-throttle kernel infrastructure. It creates the basic
interfaces to cgroups and implements the I/O measurement and throttling
functions.

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/Makefile                  |    2 +
 block/blk-io-throttle.c         |  668 +++++++++++++++++++++++++++++++++++++++
 include/linux/blk-io-throttle.h |   41 +++
 include/linux/cgroup_subsys.h   |    6 +
 init/Kconfig                    |   10 +
 5 files changed, 727 insertions(+), 0 deletions(-)
 create mode 100644 block/blk-io-throttle.c
 create mode 100644 include/linux/blk-io-throttle.h

diff --git a/block/Makefile b/block/Makefile
index 208000b..b3afc86 100644
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
index 0000000..6b0aa45
--- /dev/null
+++ b/block/blk-io-throttle.c
@@ -0,0 +1,668 @@
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
+ * @iorate: max i/o bandwidth (in bytes/s)
+ * @strategy: throttling strategy
+ * @timestamp: timestamp of the last i/o request for bandwidth limiting
+ *             (in jiffies)
+ * @stat: i/o activity counter (leaky bucket only)
+ * @bucket_size: bucket size in bytes (token bucket only)
+ * @token: token counter (token bucket only)
+ * @iops: max i/o operations per second
+ * @iops_stat: i/o operations counter (leaky bucket policy)
+ * @iops_timestamp: timestamp of the last i/o request for iops/sec limiting
+ *                  (in jiffies)
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
+	atomic_long_t iops_stat;
+	unsigned long iops_timestamp;
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
+	spinlock_t lock;
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
+				n->iorate, n->strategy,
+				atomic_long_read(&n->stat),
+				n->bucket_size, atomic_long_read(&n->token),
+				delta);
+			break;
+		case IOTHROTTLE_IOPS:
+			if (!n->iops)
+				continue;
+			delta = jiffies_to_msecs((long)jiffies -
+					(long)n->iops_timestamp);
+			seq_printf(m, "%u %u %llu %li %lu\n",
+				MAJOR(n->dev), MINOR(n->dev),
+				n->iops, atomic_long_read(&n->iops_stat),
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
+ * blockio.bandwidth
+ * ~~~~~~~~~~~~~~~~~
+ * dev:0			<- delete a bandwidth limiting rule
+ * dev:bw-limit:0		<- set a leaky bucket throttling rule
+ * dev:bw-limit:1:bucket-size	<- set a token bucket throttling rule
+ *
+ * blockio.iops
+ * ~~~~~~~~~~~~
+ * dev:0			<- delete a iops/sec throttling rule
+ * dev:iops			<- set an iops/sec throttling rule
+ */
+static int iothrottle_parse_args(char *buf, size_t nbytes, int filetype,
+					dev_t *dev, u64 *iops, u64 *iorate,
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
+	*iops = 0;
+	*iorate = 0;
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
+	switch (filetype) {
+	case IOTHROTTLE_BANDWIDTH:
+		/* i/o bandwidth limit */
+		if (!s[1])
+			return -EINVAL;
+		ret = strict_strtoull(s[1], 10, iorate);
+		if (ret < 0)
+			return ret;
+		if (!*iorate)
+			goto out;
+		*iorate = ALIGN(*iorate, 1024);
+		/* throttling strategy */
+		if (!s[2])
+			return -EINVAL;
+		ret = strict_strtoul(s[2], 10, &strategy_val);
+		if (ret < 0)
+			return ret;
+		*strategy = (enum iothrottle_strategy)strategy_val;
+		switch (*strategy) {
+		case IOTHROTTLE_LEAKY_BUCKET:
+			goto out;
+		case IOTHROTTLE_TOKEN_BUCKET:
+			break;
+		default:
+			return -EINVAL;
+		}
+		/* bucket size */
+		if (!s[3])
+			return -EINVAL;
+		ret = strict_strtoll(s[3], 10, bucket_size);
+		if (ret < 0)
+			return ret;
+		if (*bucket_size < 0)
+			return -EINVAL;
+		*bucket_size = ALIGN(*bucket_size, 1024);
+		break;
+	case IOTHROTTLE_IOPS:
+		/* i/o operation per sec limit */
+		if (!s[1])
+			return -EINVAL;
+		ret = strict_strtoull(s[1], 10, iops);
+		if (ret < 0)
+			return ret;
+		break;
+	}
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
+	u64 iops;
+	u64 iorate;
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
+	ret = iothrottle_parse_args(buf, nbytes, cft->private, &dev, &iops,
+					&iorate, &strategy, &bucket_size);
+	if (ret)
+		goto out1;
+	newn = kmalloc(sizeof(*newn), GFP_KERNEL);
+	if (!newn) {
+		ret = -ENOMEM;
+		goto out1;
+	}
+	newn->dev = dev;
+	newn->iops = iops;
+	newn->iorate = iorate;
+	newn->strategy = strategy;
+	newn->bucket_size = bucket_size;
+	newn->timestamp = jiffies;
+	newn->iops_timestamp = jiffies;
+	atomic_long_set(&newn->stat, 0);
+	atomic_long_set(&newn->token, 0);
+	atomic_long_set(&newn->iops_stat, 0);
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
+		if (!iorate && !n->iops) {
+			/* Delete a block device limiting rule */
+			iothrottle_delete_node(iot, n);
+			goto out2;
+		}
+		/* Update a block device limiting rule */
+		newn->iops = n->iops;
+		atomic_long_set(&newn->iops_stat,
+				atomic_long_read(&n->iops_stat));
+		break;
+	case IOTHROTTLE_IOPS:
+		if (!iops && !n->iorate) {
+			/* Delete a block device limiting rule */
+			iothrottle_delete_node(iot, n);
+			goto out2;
+		}
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
+		.name = "bandwidth",
+		.read_seq_string = iothrottle_read,
+		.write_string = iothrottle_write,
+		.max_write_len = 256,
+		.private = IOTHROTTLE_BANDWIDTH,
+	},
+	{
+		.name = "iops",
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
+static unsigned long leaky_bucket(struct iothrottle_node *n, ssize_t bytes)
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
+static unsigned long token_bucket(struct iothrottle_node *n, ssize_t bytes)
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
+	atomic_long_set(&n->token, tok);
+
+	return (tok < 0) ? msecs_to_jiffies(-tok / iorate) : 0;
+}
+
+/*
+ * This function uses a leaky bucket policy to throttle iops/sec.
+ *
+ * Note: called with rcu_read_lock() held.
+ */
+static unsigned long iops_limit(struct iothrottle_node *n)
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
+	 * NOTE: be sure iops statistics have been resetted before updating the
+	 * timestamp, otherwise a very small time delta may possibly be read by
+	 * another CPU w.r.t. accounted iops statistics, generating unnecessary
+	 * long sleeps.
+	 */
+	smp_wmb();
+	n->iops_timestamp = jiffies;
+	return 0;
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
+			sleep = leaky_bucket(n, bytes);
+			break;
+		case IOTHROTTLE_TOKEN_BUCKET:
+			sleep = token_bucket(n, bytes);
+			break;
+		}
+	if (n->iops)
+		iops_sleep = iops_limit(n);
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
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 23c02e2..198ee52 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -52,3 +52,9 @@ SUBSYS(memrlimit_cgroup)
 #endif
 
 /* */
+
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+SUBSYS(iothrottle)
+#endif
+
+/* */
diff --git a/init/Kconfig b/init/Kconfig
index 162d462..a87189d 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -306,6 +306,16 @@ config CGROUP_DEVICE
 	  Provides a cgroup implementing whitelists for devices which
 	  a process in the cgroup can mknod or open.
 
+config CGROUP_IO_THROTTLE
+	bool "Enable cgroup I/O throttling (EXPERIMENTAL)"
+	depends on CGROUPS && EXPERIMENTAL
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
