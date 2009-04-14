From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 5/9] io-throttle controller infrastructure
Date: Tue, 14 Apr 2009 22:21:16 +0200
Message-ID: <1239740480-28125-6-git-send-email-righi.andrea__47771.5555964552$1239740749$gmane$org@gmail.com>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239740480-28125-1-git-send-email-righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

This is the core of the io-throttle kernel infrastructure. It creates
the basic interfaces to the cgroup subsystem and implements the I/O
measurement and throttling functionality.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/Makefile                  |    1 +
 block/blk-io-throttle.c         | 1052 +++++++++++++++++++++++++++++++++++++++
 include/linux/blk-io-throttle.h |  110 ++++
 include/linux/cgroup_subsys.h   |    6 +
 init/Kconfig                    |   10 +
 5 files changed, 1179 insertions(+), 0 deletions(-)
 create mode 100644 block/blk-io-throttle.c
 create mode 100644 include/linux/blk-io-throttle.h

diff --git a/block/Makefile b/block/Makefile
index e9fa4dd..42b6a46 100644
--- a/block/Makefile
+++ b/block/Makefile
@@ -13,5 +13,6 @@ obj-$(CONFIG_IOSCHED_AS)	+= as-iosched.o
 obj-$(CONFIG_IOSCHED_DEADLINE)	+= deadline-iosched.o
 obj-$(CONFIG_IOSCHED_CFQ)	+= cfq-iosched.o
 
+obj-$(CONFIG_CGROUP_IO_THROTTLE)	+= blk-io-throttle.o
 obj-$(CONFIG_BLOCK_COMPAT)	+= compat_ioctl.o
 obj-$(CONFIG_BLK_DEV_INTEGRITY)	+= blk-integrity.o
diff --git a/block/blk-io-throttle.c b/block/blk-io-throttle.c
new file mode 100644
index 0000000..36db803
--- /dev/null
+++ b/block/blk-io-throttle.c
@@ -0,0 +1,1052 @@
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
+#include <linux/biotrack.h>
+#include <linux/blk-io-throttle.h>
+#include <linux/biotrack.h>
+#include <linux/sched.h>
+#include <linux/bio.h>
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
+/* A list of iothrottle which associate with a bio_cgroup */
+static LIST_HEAD(bio_group_list);
+static DECLARE_MUTEX(bio_group_list_sem);
+
+enum {
+	MOVING_FORBIDDEN,
+};
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
+	struct list_head bio_node;
+	int bio_id;
+	unsigned long flags;
+};
+static struct iothrottle init_iothrottle;
+
+static inline int is_bind_biocgroup(void)
+{
+	if (init_iothrottle.css.cgroup->subsys[bio_cgroup_subsys_id])
+		return 1;
+	return 0;
+}
+
+static inline int is_moving_forbidden(const struct iothrottle *iot)
+{
+	return test_bit(MOVING_FORBIDDEN, &iot->flags);
+}
+
+/* NOTE: must be called with rcu_read_lock() or bio_group_list_sem held */
+static struct iothrottle *get_bioid_to_iothrottle(int id)
+{
+	struct iothrottle *iot;
+
+	list_for_each_entry_rcu(iot, &bio_group_list, bio_node) {
+		if (iot->bio_id == id) {
+			css_get(&iot->css);
+			return iot;
+		}
+	}
+	return NULL;
+}
+
+static int is_bio_group(struct iothrottle *iot)
+{
+	if (iot && iot->bio_id > 0)
+		return 0;
+	return -1;
+}
+
+static int synchronize_bio_cgroup(int old_id, int new_id,
+				  struct task_struct *tsk)
+{
+	struct iothrottle *old_group, *new_group;
+	int ret = 0;
+
+	old_group = get_bioid_to_iothrottle(old_id);
+	new_group = get_bioid_to_iothrottle(new_id);
+
+	/* no need to hold cgroup_lock() for bio_cgroup holding it already */
+	get_task_struct(tsk);
+
+	/* This has nothing to do with us! */
+	if (is_bio_group(old_group) && is_bio_group(new_group))
+		goto out;
+
+	/*
+	 * If moving from an associated one to an unassociated one,
+	 * just move it to root.
+	 */
+	if (!is_bio_group(old_group) && is_bio_group(new_group)) {
+		BUG_ON(is_moving_forbidden(&init_iothrottle));
+		clear_bit(MOVING_FORBIDDEN, &old_group->flags);
+		ret = cgroup_attach_task(init_iothrottle.css.cgroup, tsk);
+		set_bit(MOVING_FORBIDDEN, &old_group->flags);
+		goto out;
+	}
+
+	if (!is_bio_group(new_group) && is_bio_group(old_group)) {
+		BUG_ON(!is_moving_forbidden(new_group));
+		clear_bit(MOVING_FORBIDDEN, &new_group->flags);
+		ret = cgroup_attach_task(new_group->css.cgroup, tsk);
+		set_bit(MOVING_FORBIDDEN, &new_group->flags);
+		goto out;
+	}
+
+	if (!is_bio_group(new_group) && !is_bio_group(old_group)) {
+		BUG_ON(!is_moving_forbidden(new_group));
+		clear_bit(MOVING_FORBIDDEN, &new_group->flags);
+		clear_bit(MOVING_FORBIDDEN, &old_group->flags);
+		ret = cgroup_attach_task(new_group->css.cgroup, tsk);
+		set_bit(MOVING_FORBIDDEN, &old_group->flags);
+		set_bit(MOVING_FORBIDDEN, &new_group->flags);
+		goto out;
+	}
+out:
+	put_task_struct(tsk);
+	if (new_group)
+		css_put(&new_group->css);
+	if (old_group)
+		css_put(&old_group->css);
+	return ret;
+}
+
+static int iothrottle_notifier_call(struct notifier_block *this,
+				unsigned long event, void *ptr)
+{
+	struct tsk_move_msg *tmm;
+	int old_id, new_id;
+	struct task_struct *tsk;
+
+	if (is_bind_biocgroup())
+		return NOTIFY_OK;
+
+	tmm = (struct tsk_move_msg *)ptr;
+	old_id = tmm->old_id;
+	new_id = tmm->new_id;
+	if (old_id == new_id)
+		return NOTIFY_OK;
+	tsk = tmm->tsk;
+	down(&bio_group_list_sem);
+	synchronize_bio_cgroup(old_id, new_id, tsk);
+	up(&bio_group_list_sem);
+
+	return NOTIFY_OK;
+}
+
+
+static struct notifier_block iothrottle_notifier = {
+	.notifier_call = iothrottle_notifier_call,
+};
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
+	if (unlikely((cgrp->parent) == NULL)) {
+		iot = &init_iothrottle;
+		/* where should we release? */
+		register_biocgroup_notifier(&iothrottle_notifier);
+	} else {
+		iot = kzalloc(sizeof(*iot), GFP_KERNEL);
+		if (unlikely(!iot))
+			return ERR_PTR(-ENOMEM);
+	}
+	INIT_LIST_HEAD(&iot->list);
+	INIT_LIST_HEAD(&iot->bio_node);
+	iot->bio_id = -1;
+	clear_bit(MOVING_FORBIDDEN, &iot->flags);
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
+	if (unlikely((cgrp->parent) == NULL))
+		unregister_biocgroup_notifier(&iothrottle_notifier);
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
+	res_counter_init(&newn->bw, NULL);
+	res_counter_init(&newn->iops, NULL);
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
+static s64 read_bio_id(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct iothrottle *iot;
+
+	iot = cgroup_to_iothrottle(cgrp);
+	return iot->bio_id;
+}
+
+/**
+ * iothrottle_do_move_task - move a given task to another iothrottle cgroup
+ * @tsk: pointer to task_struct the task to move
+ * @scan: struct cgroup_scanner
+ *
+ * Called by cgroup_scan_tasks() for each task in a cgroup.
+ */
+static void iothrottle_do_move_task(struct task_struct *tsk,
+					struct cgroup_scanner *scan)
+{
+	struct cgroup *new_cgroup = scan->data;
+
+	cgroup_attach_task(new_cgroup, tsk);
+}
+
+/**
+ * move_tasks_to_cgroup - move tasks from one cgroup to another iothrottle
+ * cgroup
+ * @from: iothrottle in which the tasks currently reside
+ * @to: iothrottle to which the tasks will be moved
+ *
+ * NOTE: called with cgroup_mutex held
+ *
+ * The cgroup_scan_tasks() function will scan all the tasks in a cgroup
+ * calling callback functions for each.
+ */
+static void move_tasks_to_init_cgroup(struct cgroup *from, struct cgroup *to)
+{
+	struct cgroup_scanner scan;
+
+	scan.cg = from;
+	scan.test_task = NULL; /* select all tasks in cgroup */
+	scan.process_task = iothrottle_do_move_task;
+	scan.heap = NULL;
+	scan.data = to;
+
+	if (cgroup_scan_tasks(&scan))
+		printk(KERN_ERR "%s: cgroup_scan_tasks failed\n", __func__);
+}
+
+static int write_bio_id(struct cgroup *cgrp, struct cftype *cft, s64 val)
+{
+	struct cgroup *bio_cgroup;
+	struct iothrottle *iot, *pos;
+	int id;
+
+	if (is_bind_biocgroup())
+		return -EPERM;
+
+	iot = cgroup_to_iothrottle(cgrp);
+
+	/* No more operation if it's a root cgroup */
+	if (!cgrp->parent)
+		return 0;
+	id = val;
+
+	/* De-associate from a bio-cgroup */
+	if (id < 0) {
+		if (is_bio_group(iot))
+			return 0;
+
+		clear_bit(MOVING_FORBIDDEN, &iot->flags);
+		cgroup_lock();
+		move_tasks_to_init_cgroup(cgrp, init_iothrottle.css.cgroup);
+		cgroup_unlock();
+
+		down(&bio_group_list_sem);
+		list_del_rcu(&iot->bio_node);
+		up(&bio_group_list_sem);
+
+		iot->bio_id = -1;
+		return 0;
+	}
+
+	/* Not allowed if there're tasks in the iothrottle cgroup */
+	if (cgroup_task_count(cgrp))
+		return -EPERM;
+
+	bio_cgroup = bio_id_to_cgroup(id);
+	if (!bio_cgroup)
+		return 0;
+	/*
+	 * Go through the bio_group_list, if don't exist, put it into this
+	 * list.
+	 */
+	rcu_read_lock();
+	list_for_each_entry_rcu(pos, &bio_group_list, bio_node) {
+		if (pos->bio_id == id) {
+			rcu_read_unlock();
+			return -EEXIST;
+		}
+	}
+	rcu_read_unlock();
+
+	/* Synchronize tasks with bio_cgroup */
+	cgroup_lock();
+	move_tasks_to_init_cgroup(bio_cgroup, cgrp);
+	cgroup_unlock();
+
+	down(&bio_group_list_sem);
+	list_add_rcu(&iot->bio_node, &bio_group_list);
+	up(&bio_group_list_sem);
+
+	iot->bio_id = id;
+	set_bit(MOVING_FORBIDDEN, &iot->flags);
+
+	return 0;
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
+	{
+		.name = "bio_id",
+		.write_s64 = write_bio_id,
+		.read_s64 = read_bio_id,
+	},
+};
+
+static int iothrottle_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	return cgroup_add_files(cgrp, ss, files, ARRAY_SIZE(files));
+}
+
+static int iothrottle_can_attach(struct cgroup_subsys *ss,
+			     struct cgroup *cont, struct task_struct *tsk)
+{
+	struct iothrottle *new_iot, *old_iot;
+
+	new_iot = cgroup_to_iothrottle(cont);
+	old_iot = task_to_iothrottle(tsk);
+
+	if (!is_moving_forbidden(new_iot) && !is_moving_forbidden(old_iot))
+		return 0;
+	else
+		return -EPERM;
+}
+
+static int iothrottle_subsys_depend(struct cgroup_subsys *ss,
+				    unsigned long subsys_bits)
+{
+	unsigned long allow_subsys_bits;
+
+	allow_subsys_bits = 0;
+	allow_subsys_bits |= 1ul << bio_cgroup_subsys_id;
+	allow_subsys_bits |= 1ul << iothrottle_subsys_id;
+	if (subsys_bits & ~allow_subsys_bits)
+		return -1;
+	return 0;
+}
+
+struct cgroup_subsys iothrottle_subsys = {
+	.name = "blockio",
+	.create = iothrottle_create,
+	.destroy = iothrottle_destroy,
+	.populate = iothrottle_populate,
+	.can_attach = iothrottle_can_attach,
+	.subsys_depend = iothrottle_subsys_depend,
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
+	if (!iot)
+		return NULL;
+	css_get(&iot->css);
+	put_cgroup_from_page(page);
+
+	return iot;
+}
+
+static struct iothrottle *get_iothrottle_from_bio(struct bio *bio)
+{
+	struct iothrottle *iot;
+	struct page *page;
+	int id;
+
+	if (!bio)
+		return NULL;
+	page = bio_iovec_idx(bio, 0)->bv_page;
+	iot = get_iothrottle_from_page(page);
+	if (iot)
+		return iot;
+	id = get_bio_cgroup_id(bio);
+	rcu_read_lock();
+	iot = get_bioid_to_iothrottle(id);
+	rcu_read_unlock();
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
+ * cgroup_io_throttle() - account and throttle synchronous i/o activity
+ * @bio:	the bio structure used to retrieve the owner of the i/o
+ *		operation.
+ * @bdev:	block device involved for the i/o.
+ * @bytes:	size in bytes of the i/o operation.
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
+cgroup_io_throttle(struct bio *bio, struct block_device *bdev, ssize_t bytes)
+{
+	struct iothrottle *iot = NULL;
+	struct iothrottle_sleep s = {};
+	unsigned long long sleep;
+	int can_sleep = 1;
+
+	if (unlikely(!bdev))
+		return 0;
+	BUG_ON(!bdev->bd_inode || !bdev->bd_disk);
+	/*
+	 * Never throttle kernel threads directly, since they may completely
+	 * block other cgroups, the i/o on other block devices or even the
+	 * whole system.
+	 *
+	 * And never sleep if we're inside an AIO context; just account the i/o
+	 * activity. Throttling is performed in io_submit_one() returning
+	 * -EAGAIN when the limits are exceeded.
+	 */
+	if (is_kthread_io() || is_in_aio())
+		can_sleep = 0;
+	/*
+	 * WARNING: in_atomic() do not know about held spinlocks in
+	 * non-preemptible kernels, but we want to check it here to raise
+	 * potential bugs when a preemptible kernel is used.
+	 */
+	WARN_ON_ONCE(can_sleep &&
+			(irqs_disabled() || in_interrupt() || in_atomic()));
+
+	/* Apply IO throttling */
+	iot = get_iothrottle_from_bio(bio);
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
+		current, current->comm, sleep);
+		iothrottle_acct_task_stat(type, sleep);
+		schedule_timeout_killable(sleep);
+		return 0;
+	}
+	css_put(&iot->css);
+	rcu_read_unlock();
+
+	/*
+	 * Account, but do not delay filesystems' metadata IO or IO that is
+	 * explicitly marked to not wait or being anticipated, i.e. writes with
+	 * wbc->sync_mode set to WBC_SYNC_ALL - fsync() - or journal activity.
+	 */
+	if (bio && (bio_rw_meta(bio) || bio_noidle(bio)))
+		sleep = 0;
+	return sleep;
+}
diff --git a/include/linux/blk-io-throttle.h b/include/linux/blk-io-throttle.h
new file mode 100644
index 0000000..d3c6e86
--- /dev/null
+++ b/include/linux/blk-io-throttle.h
@@ -0,0 +1,110 @@
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
+
+extern unsigned long long
+cgroup_io_throttle(struct bio *bio, struct block_device *bdev, ssize_t bytes);
+
+extern int iothrottle_make_request(struct bio *bio, unsigned long deadline);
+
+extern int iothrottle_sync(void);
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
+#else /* CONFIG_CGROUP_IO_THROTTLE */
+
+static inline unsigned long long
+cgroup_io_throttle(struct bio *bio, struct block_device *bdev, ssize_t bytes)
+{
+	return 0;
+}
+
+static inline int
+iothrottle_make_request(struct bio *bio, unsigned long deadline)
+{
+	return 0;
+}
+
+static inline int iothrottle_sync(void)
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
index 5df23f8..3ea63f3 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -49,6 +49,12 @@ SUBSYS(bio_cgroup)
 
 /* */
 
+#ifdef CONFIG_CGROUP_IO_THROTTLE
+SUBSYS(iothrottle)
+#endif
+
+/* */
+
 #ifdef CONFIG_CGROUP_DEVICE
 SUBSYS(devices)
 #endif
diff --git a/init/Kconfig b/init/Kconfig
index 8f7b23c..045f7c5 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -617,6 +617,16 @@ config CGROUP_BIO
 	  kind of module such as dm-ioband device mapper modules or
 	  the cfq-scheduler.
 
+config CGROUP_IO_THROTTLE
+	bool "Enable cgroup I/O throttling"
+	depends on CGROUPS && CGROUP_BIO && RESOURCE_COUNTERS && EXPERIMENTAL
+	help
+	  This allows to limit the maximum I/O bandwidth for specific
+	  cgroup(s).
+	  See Documentation/cgroups/io-throttle.txt for more information.
+
+	  If unsure, say N.
+
 endif # CGROUPS
 
 config CGROUP_PAGE
-- 
1.5.6.3
