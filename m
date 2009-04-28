From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v15 5/7] kiothrottled: throttle buffered (writeback) IO
Date: Tue, 28 Apr 2009 10:43:52 +0200
Message-ID: <1240908234-15434-6-git-send-email-righi.andrea__22728.4536850222$1240908941$gmane$org@gmail.com>
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

Together with cgroup_io_throttle() the kiothrottled kernel thread
represents the core of the io-throttle subsystem.

All the writeback IO requests that need to be throttled are not
dispatched immediately in submit_bio(). Instead, they are added into an
rbtree by iothrottle_make_request() and processed asynchronously by
kiothrottled.

A deadline is associated to each request depending on the bandwidth
usage of the cgroup it belongs. When a request is inserted into the
rbtree kiothrottled is awakened. This thread selects all the requests
with an expired deadline and submit the bunch of selected requests to
the underlying block devices using generic_make_request().

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/Makefile       |    2 +-
 block/kiothrottled.c |  341 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 342 insertions(+), 1 deletions(-)
 create mode 100644 block/kiothrottled.c

diff --git a/block/Makefile b/block/Makefile
index 42b6a46..5f10a45 100644
--- a/block/Makefile
+++ b/block/Makefile
@@ -13,6 +13,6 @@ obj-$(CONFIG_IOSCHED_AS)	+= as-iosched.o
 obj-$(CONFIG_IOSCHED_DEADLINE)	+= deadline-iosched.o
 obj-$(CONFIG_IOSCHED_CFQ)	+= cfq-iosched.o
 
-obj-$(CONFIG_CGROUP_IO_THROTTLE)	+= blk-io-throttle.o
+obj-$(CONFIG_CGROUP_IO_THROTTLE)	+= blk-io-throttle.o kiothrottled.o
 obj-$(CONFIG_BLOCK_COMPAT)	+= compat_ioctl.o
 obj-$(CONFIG_BLK_DEV_INTEGRITY)	+= blk-integrity.o
diff --git a/block/kiothrottled.c b/block/kiothrottled.c
new file mode 100644
index 0000000..3df22c1
--- /dev/null
+++ b/block/kiothrottled.c
@@ -0,0 +1,341 @@
+/*
+ * kiothrottled.c
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
+#include <linux/sched.h>
+#include <linux/seq_file.h>
+#include <linux/proc_fs.h>
+#include <linux/kthread.h>
+#include <linux/jiffies.h>
+#include <linux/ioprio.h>
+#include <linux/rbtree.h>
+#include <linux/blkdev.h>
+
+/* io-throttle bio element */
+struct iot_bio {
+	struct rb_node node;
+	unsigned long deadline;
+	struct bio *bio;
+};
+
+/* io-throttle bio tree */
+struct iot_bio_tree {
+	/* Protect the iothrottle rbtree */
+	spinlock_t lock;
+	struct rb_root tree;
+};
+
+/*
+ * TODO: create one iothrottle rbtree per block device and many kiothrottled
+ * threads per rbtree, instead of a poor scalable single rbtree / single thread
+ * solution.
+ */
+static struct iot_bio_tree *iot;
+static struct task_struct *kiothrottled_thread;
+
+/* Timer used to periodically wake-up kiothrottled */
+static struct timer_list kiothrottled_timer;
+
+/* Insert a new iot_bio element in the iot_bio_tree */
+static void iot_bio_insert(struct rb_root *root, struct iot_bio *data)
+{
+	struct rb_node **new = &(root->rb_node), *parent = NULL;
+
+	while (*new) {
+		struct iot_bio *this = container_of(*new, struct iot_bio, node);
+		parent = *new;
+		if (data->deadline < this->deadline)
+			new = &((*new)->rb_left);
+		else
+			new = &((*new)->rb_right);
+	}
+	rb_link_node(&data->node, parent, new);
+	rb_insert_color(&data->node, root);
+}
+
+/*
+ * NOTE: no need to care about locking here, we're flushing all the pending
+ * requests, kiothrottled has been stopped and no additional request will be
+ * submitted in the tree.
+ */
+static void iot_bio_cleanup(struct rb_root *root)
+{
+	struct iot_bio *data;
+	struct rb_node *next;
+
+	next = rb_first(root);
+	while (next) {
+		data = rb_entry(next, struct iot_bio, node);
+		pr_debug("%s: dispatching element: %p (%lu)\n",
+				__func__, data->bio, data->deadline);
+		generic_make_request(data->bio);
+		next = rb_next(&data->node);
+		rb_erase(&data->node, root);
+		kfree(data);
+	}
+}
+
+/**
+ * iothrottle_make_request() - submit a delayed IO requests that will be
+ * processed asynchronously by kiothrottled.
+ *
+ * @bio:	the bio structure that contains the IO request's informations
+ * @deadline:	the request will be actually dispatched only when the deadline
+ *		will expire
+ *
+ * Returns 0 if the request is successfully submitted and inserted into the
+ * iot_bio_tree. Return a negative value in case of failure.
+ **/
+int iothrottle_make_request(struct bio *bio, unsigned long deadline)
+{
+	struct iot_bio *data;
+
+	BUG_ON(!iot);
+
+	if (unlikely(!kiothrottled_thread))
+		return -ENOENT;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (unlikely(!data))
+		return -ENOMEM;
+	data->deadline = deadline;
+	data->bio = bio;
+
+	spin_lock_irq(&iot->lock);
+	iot_bio_insert(&iot->tree, data);
+	spin_unlock_irq(&iot->lock);
+
+	wake_up_process(kiothrottled_thread);
+	return 0;
+}
+EXPORT_SYMBOL(iothrottle_make_request);
+
+static void kiothrottled_timer_expired(unsigned long __unused)
+{
+	wake_up_process(kiothrottled_thread);
+}
+
+static void kiothrottled_sleep(void)
+{
+	set_current_state(TASK_INTERRUPTIBLE);
+	schedule();
+}
+
+/**
+ * kiothrottled() - throttle buffered (writeback) i/o activity
+ *
+ * Together with cgroup_io_throttle() this kernel thread represents the core of
+ * the cgroup-io-throttle subsystem.
+ *
+ * All the writeback IO requests that need to be throttled are not dispatched
+ * immediately in submit_bio(). Instead, they are added into the iot_bio_tree
+ * rbtree by iothrottle_make_request() and processed asynchronously by
+ * kiothrottled.
+ *
+ * A deadline is associated to each request depending on the bandwidth usage of
+ * the cgroup it belongs. When a request is inserted into the rbtree
+ * kiothrottled is awakened. This thread selects all the requests with an
+ * expired deadline and submit the bunch of selected requests to the underlying
+ * block devices using generic_make_request().
+ **/
+static int kiothrottled(void *__unused)
+{
+	/*
+	 * kiothrottled is responsible of dispatching all the writeback IO
+	 * requests with an expired deadline. To dispatch those requests as
+	 * soon as possible and to avoid priority inversion problems set
+	 * maximum IO real-time priority for this thread.
+	 */
+	set_task_ioprio(current, IOPRIO_PRIO_VALUE(IOPRIO_CLASS_RT, 0));
+
+	while (!kthread_should_stop()) {
+		struct iot_bio *data;
+		struct rb_node *req;
+		struct rb_root staging_tree = RB_ROOT;
+		unsigned long now = jiffies;
+		long delta_t = 0;
+
+		/* Select requests to dispatch */
+		spin_lock_irq(&iot->lock);
+		req = rb_first(&iot->tree);
+		while (req) {
+			data = rb_entry(req, struct iot_bio, node);
+			delta_t = (long)data->deadline - (long)now;
+			if (delta_t > 0)
+				break;
+			req = rb_next(&data->node);
+			rb_erase(&data->node, &iot->tree);
+			iot_bio_insert(&staging_tree, data);
+		}
+		spin_unlock_irq(&iot->lock);
+
+		/* Dispatch requests */
+		req = rb_first(&staging_tree);
+		while (req) {
+			data = rb_entry(req, struct iot_bio, node);
+			req = rb_next(&data->node);
+			rb_erase(&data->node, &staging_tree);
+			pr_debug("%s: dispatching request: %p (%lu)\n",
+					__func__, data->bio, data->deadline);
+			generic_make_request(data->bio);
+			kfree(data);
+		}
+
+		/* Wait for new requests ready to be dispatched */
+		if (delta_t > 0)
+			mod_timer(&kiothrottled_timer, jiffies + HZ);
+		kiothrottled_sleep();
+	}
+	return 0;
+}
+
+/* TODO: handle concurrent startup and shutdown */
+static void kiothrottle_shutdown(void)
+{
+	if (!kiothrottled_thread)
+		return;
+	del_timer(&kiothrottled_timer);
+	printk(KERN_INFO "%s: stopping kiothrottled\n", __func__);
+	kthread_stop(kiothrottled_thread);
+	printk(KERN_INFO "%s: flushing pending requests\n", __func__);
+	spin_lock_irq(&iot->lock);
+	kiothrottled_thread = NULL;
+	spin_unlock_irq(&iot->lock);
+	iot_bio_cleanup(&iot->tree);
+}
+
+static int kiothrottle_startup(void)
+{
+	init_timer(&kiothrottled_timer);
+	kiothrottled_timer.function = kiothrottled_timer_expired;
+
+	printk(KERN_INFO "%s: starting kiothrottled\n", __func__);
+	kiothrottled_thread = kthread_run(kiothrottled, NULL, "kiothrottled");
+	if (IS_ERR(kiothrottled_thread))
+		return -PTR_ERR(kiothrottled_thread);
+	return 0;
+}
+
+/*
+ * NOTE: provide this interface only for emergency situations, when we need to
+ * force the immediate flush of pending (writeback) IO throttled requests.
+ */
+int iothrottle_sync(void)
+{
+	kiothrottle_shutdown();
+	return kiothrottle_startup();
+}
+EXPORT_SYMBOL(iothrottle_sync);
+
+/*
+ * Writing in /proc/kiothrottled_debug enforces an immediate flush of throttled
+ * IO requests.
+ */
+static ssize_t kiothrottle_write(struct file *filp, const char __user *buffer,
+				size_t count, loff_t *data)
+{
+	int ret;
+
+	ret = iothrottle_sync();
+	if (ret)
+		return ret;
+	return count;
+}
+
+/*
+ * Export to userspace the list of pending IO throttled requests.
+ * TODO: this can be useful only for debugging, maybe we should make this
+ * interface optionally, depending on an opportune compile-time config option.
+ */
+static int kiothrottle_show(struct seq_file *m, void *v)
+{
+	struct iot_bio *data;
+	struct rb_node *next;
+	unsigned long now = jiffies;
+	long delta_t;
+
+	spin_lock_irq(&iot->lock);
+	next = rb_first(&iot->tree);
+	while (next) {
+		data = rb_entry(next, struct iot_bio, node);
+		delta_t = (long)data->deadline - (long)now;
+		seq_printf(m, "%p %lu %lu %li\n", data->bio,
+				data->deadline, now, delta_t);
+		next = rb_next(&data->node);
+	}
+	spin_unlock_irq(&iot->lock);
+
+	return 0;
+}
+
+static int kiothrottle_open(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, kiothrottle_show, NULL);
+}
+
+static const struct file_operations kiothrottle_ops = {
+	.open           = kiothrottle_open,
+	.read           = seq_read,
+	.write		= kiothrottle_write,
+	.llseek         = seq_lseek,
+	.release        = seq_release,
+};
+
+int __init kiothrottled_init(void)
+{
+	struct proc_dir_entry *pe;
+	int ret;
+
+	iot = kzalloc(sizeof(*iot), GFP_KERNEL);
+	if (unlikely(!iot))
+		return -ENOMEM;
+	spin_lock_init(&iot->lock);
+	iot->tree = RB_ROOT;
+
+	pe = create_proc_entry("kiothrottled_debug", 0644, NULL);
+	if (!pe) {
+		kfree(iot);
+		return -ENOMEM;
+	}
+	pe->proc_fops = &kiothrottle_ops;
+
+	ret = kiothrottle_startup();
+	if (ret) {
+		remove_proc_entry("kiothrottled_debug", NULL);
+		kfree(iot);
+		return ret;
+	}
+	printk(KERN_INFO "%s: initialized\n", __func__);
+	return 0;
+}
+
+void __exit kiothrottled_exit(void)
+{
+	kiothrottle_shutdown();
+	remove_proc_entry("kiothrottled_debug", NULL);
+	kfree(iot);
+	printk(KERN_INFO "%s: unloaded\n", __func__);
+}
+
+module_init(kiothrottled_init);
+module_exit(kiothrottled_exit);
+MODULE_LICENSE("GPL");
-- 
1.6.0.4
