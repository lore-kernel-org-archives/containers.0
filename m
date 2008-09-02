From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH -mm 0/5] cgroup: block device i/o controller (v9)
Date: Tue, 02 Sep 2008 22:50:12 +0200
Message-ID: <48BDA704.9040000__4361.96241430498$1220388731$gmane$org@gmail.com>
References: <1219853257-11052-1-git-send-email-righi.andrea@gmail.com>
	<20080902180620.GE15847@redhat.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080902180620.GE15847-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, roberto-5KDOxZqKugI@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> On Wed, Aug 27, 2008 at 06:07:32PM +0200, Andrea Righi wrote:
>> The objective of the i/o controller is to improve i/o performance
>> predictability of different cgroups sharing the same block devices.
>>
>> Respect to other priority/weight-based solutions the approach used by this
>> controller is to explicitly choke applications' requests that directly (or
>> indirectly) generate i/o activity in the system.
>>
> 
> Hi Andrea,
> 
> I was checking out the pass discussion on this topic and there seemed to
> be two kind of people. One who wanted to control max bandwidth and other
> who liked proportional bandwidth approach  (dm-ioband folks).
> 
> I was just wondering, is it possible to have both the approaches and let
> users decide at run time which one do they want to use (something like
> the way users can choose io schedulers).
> 
> Thanks
> Vivek

Hi Vivek,

yes, sounds reasonable (adding the proportional bandwidth control to my
TODO list).

Right now I've a totally experimental patch to add the ionice-like
functionality (it's not the same but it's quite similar to the
proportional bandwidth feature) on-top-of my IO controller. See below.

The patch is not very well tested, I don't even know if it applies
cleanly to the latest io-throttle patch I posted, or if it have runtime
failures, it needs more testing.

Anyway, this adds the file blockio.ionice that can be used to set
per-cgroup IO priorities, just like ionice, the difference is that it
works per-cgroup instead of per-task (it can be easily improved to
also support per-device priority).

The solution I've used is really trivial: all the tasks belonging to a
cgroup share the same io_context, so actually it means that they also
share the same disk time given by the IO scheduler and the tasks'
requests coming from a cgroup are considered as they were issued by a
single task. This works only for CFQ and AS, because deadline and noop
have no concept of IO contexts.

I would also like to merge the Satoshi's cfq-cgroup functionalities to
provide "fairness" also within each cgroup, but the drawback is that it
would work only for CFQ.

So, in conclusion, I'd really like to implement a more generic
weighted/priority cgroup-based policy to schedule bios like dm-ioband,
maybe implementing the hook directly in submit_bio() or
generic_make_request(), independent also of the dm infrastructure.

-Andrea

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/blk-io-throttle.c         |   72 +++++++++++++++++++++++++++++++++++++--
 block/blk-ioc.c                 |   16 +-------
 include/linux/blk-io-throttle.h |    7 ++++
 include/linux/iocontext.h       |   15 ++++++++
 kernel/fork.c                   |    3 +-
 5 files changed, 95 insertions(+), 18 deletions(-)

diff --git a/block/blk-io-throttle.c b/block/blk-io-throttle.c
index 0fa235d..2a52e8d 100644
--- a/block/blk-io-throttle.c
+++ b/block/blk-io-throttle.c
@@ -29,6 +29,8 @@
 #include <linux/err.h>
 #include <linux/sched.h>
 #include <linux/genhd.h>
+#include <linux/iocontext.h>
+#include <linux/ioprio.h>
 #include <linux/fs.h>
 #include <linux/jiffies.h>
 #include <linux/hardirq.h>
@@ -129,8 +131,10 @@ struct iothrottle_node {
 struct iothrottle {
 	struct cgroup_subsys_state css;
 	struct list_head list;
+	struct io_context *ioc;
 };
 static struct iothrottle init_iothrottle;
+static struct io_context init_ioc;
 
 static inline struct iothrottle *cgroup_to_iothrottle(struct cgroup *cgrp)
 {
@@ -197,12 +201,17 @@ iothrottle_create(struct cgroup_subsys *ss, struct cgroup *cgrp)
 {
 	struct iothrottle *iot;
 
-	if (unlikely((cgrp->parent) == NULL))
+	if (unlikely((cgrp->parent) == NULL)) {
 		iot = &init_iothrottle;
-	else {
+		init_io_context(&init_ioc);
+		iot->ioc = &init_ioc;
+	} else {
 		iot = kmalloc(sizeof(*iot), GFP_KERNEL);
 		if (unlikely(!iot))
 			return ERR_PTR(-ENOMEM);
+		iot->ioc = alloc_io_context(GFP_KERNEL, -1);
+		if (unlikely(!iot->ioc))
+			return ERR_PTR(-ENOMEM);
 	}
 	INIT_LIST_HEAD(&iot->list);
 
@@ -223,6 +232,7 @@ static void iothrottle_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
 	 */
 	list_for_each_entry_safe(n, p, &iot->list, node)
 		kfree(n);
+	put_io_context(iot->ioc);
 	kfree(iot);
 }
 
@@ -470,6 +480,27 @@ out1:
 	return ret;
 }
 
+static u64 ionice_read_u64(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct iothrottle *iot = cgroup_to_iothrottle(cgrp);
+
+	return iot->ioc->ioprio;
+}
+
+static int ionice_write_u64(struct cgroup *cgrp, struct cftype *cft, u64 val)
+{
+	struct iothrottle *iot;
+
+	if (!cgroup_lock_live_group(cgrp))
+		return -ENODEV;
+	iot = cgroup_to_iothrottle(cgrp);
+	iot->ioc->ioprio = (int)val;
+	iot->ioc->ioprio_changed = 1;
+	cgroup_unlock();
+
+	return 0;
+}
+
 static struct cftype files[] = {
 	{
 		.name = "bandwidth-max",
@@ -486,6 +517,11 @@ static struct cftype files[] = {
 		.private = IOTHROTTLE_IOPS,
 	},
 	{
+		.name = "ionice",
+		.read_u64 = ionice_read_u64,
+		.write_u64 = ionice_write_u64,
+	},
+	{
 		.name = "throttlecnt",
 		.read_seq_string = iothrottle_read,
 		.private = IOTHROTTLE_FAILCNT,
@@ -497,15 +533,45 @@ static int iothrottle_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
 	return cgroup_add_files(cgrp, ss, files, ARRAY_SIZE(files));
 }
 
+static void iothrottle_move_task(struct cgroup_subsys *ss,
+		struct cgroup *cgrp, struct cgroup *old_cgrp,
+		struct task_struct *tsk)
+{
+	struct iothrottle *iot;
+
+	iot = cgroup_to_iothrottle(cgrp);
+
+	task_lock(tsk);
+	put_io_context(tsk->io_context);
+	tsk->io_context = ioc_task_link(iot->ioc);
+	BUG_ON(!tsk->io_context);
+	task_unlock(tsk);
+}
+
 struct cgroup_subsys iothrottle_subsys = {
 	.name = "blockio",
 	.create = iothrottle_create,
 	.destroy = iothrottle_destroy,
 	.populate = iothrottle_populate,
+	.attach = iothrottle_move_task,
 	.subsys_id = iothrottle_subsys_id,
-	.early_init = 1,
+	.early_init = 0,
 };
 
+int cgroup_copy_io(struct task_struct *tsk)
+{
+	struct iothrottle *iot;
+
+	rcu_read_lock();
+	iot = task_to_iothrottle(current);
+	BUG_ON(!iot);
+	tsk->io_context = ioc_task_link(iot->ioc);
+	rcu_read_unlock();
+	BUG_ON(!tsk->io_context);
+
+	return 0;
+}
+
 /*
  * NOTE: called with rcu_read_lock() held.
  */
diff --git a/block/blk-ioc.c b/block/blk-ioc.c
index 012f065..629a80b 100644
--- a/block/blk-ioc.c
+++ b/block/blk-ioc.c
@@ -89,20 +89,8 @@ struct io_context *alloc_io_context(gfp_t gfp_flags, int node)
 	struct io_context *ret;
 
 	ret = kmem_cache_alloc_node(iocontext_cachep, gfp_flags, node);
-	if (ret) {
-		atomic_set(&ret->refcount, 1);
-		atomic_set(&ret->nr_tasks, 1);
-		spin_lock_init(&ret->lock);
-		ret->ioprio_changed = 0;
-		ret->ioprio = 0;
-		ret->last_waited = jiffies; /* doesn't matter... */
-		ret->nr_batch_requests = 0; /* because this is 0 */
-		ret->aic = NULL;
-		INIT_RADIX_TREE(&ret->radix_root, GFP_ATOMIC | __GFP_HIGH);
-		INIT_HLIST_HEAD(&ret->cic_list);
-		ret->ioc_data = NULL;
-	}
-
+	if (ret)
+		init_io_context(ret);
 	return ret;
 }
 
diff --git a/include/linux/blk-io-throttle.h b/include/linux/blk-io-throttle.h
index e901818..bee3975 100644
--- a/include/linux/blk-io-throttle.h
+++ b/include/linux/blk-io-throttle.h
@@ -14,6 +14,8 @@ extern unsigned long long
 cgroup_io_throttle(struct page *page, struct block_device *bdev,
 		ssize_t bytes, int can_sleep);
 
+extern int cgroup_copy_io(struct task_struct *tsk);
+
 static inline void set_in_aio(void)
 {
 	atomic_set(&current->in_aio, 1);
@@ -51,6 +53,11 @@ cgroup_io_throttle(struct page *page, struct block_device *bdev,
 	return 0;
 }
 
+static inline int cgroup_copy_io(struct task_struct *tsk)
+{
+	return -1;
+}
+
 static inline void set_in_aio(void) { }
 
 static inline void unset_in_aio(void) { }
diff --git a/include/linux/iocontext.h b/include/linux/iocontext.h
index 08b987b..d06af02 100644
--- a/include/linux/iocontext.h
+++ b/include/linux/iocontext.h
@@ -85,6 +85,21 @@ struct io_context {
 	void *ioc_data;
 };
 
+static inline void init_io_context(struct io_context *ioc)
+{
+	atomic_set(&ioc->refcount, 1);
+	atomic_set(&ioc->nr_tasks, 1);
+	spin_lock_init(&ioc->lock);
+	ioc->ioprio_changed = 0;
+	ioc->ioprio = 0;
+	ioc->last_waited = jiffies; /* doesn't matter... */
+	ioc->nr_batch_requests = 0; /* because this is 0 */
+	ioc->aic = NULL;
+	INIT_RADIX_TREE(&ioc->radix_root, GFP_ATOMIC | __GFP_HIGH);
+	INIT_HLIST_HEAD(&ioc->cic_list);
+	ioc->ioc_data = NULL;
+}
+
 static inline struct io_context *ioc_task_link(struct io_context *ioc)
 {
 	/*
diff --git a/kernel/fork.c b/kernel/fork.c
index 9ee7408..cf38989 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -41,6 +41,7 @@
 #include <linux/tracehook.h>
 #include <linux/futex.h>
 #include <linux/task_io_accounting_ops.h>
+#include <linux/blk-io-throttle.h>
 #include <linux/rcupdate.h>
 #include <linux/ptrace.h>
 #include <linux/mount.h>
@@ -733,7 +734,7 @@ static int copy_io(unsigned long clone_flags, struct task_struct *tsk)
 #ifdef CONFIG_BLOCK
 	struct io_context *ioc = current->io_context;
 
-	if (!ioc)
+	if (!ioc || !cgroup_copy_io(tsk))
 		return 0;
 	/*
 	 * Share io context with parent, if CLONE_IO is set
