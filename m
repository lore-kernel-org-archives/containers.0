From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 08/18] io-controller: idle for sometime on sync queue
	before expiring it
Date: Tue, 9 Jun 2009 13:51:31 -0400
Message-ID: <20090609175131.GB13476__49386.0066905201$1244570015$gmane$org@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<1241553525-28095-9-git-send-email-vgoyal@redhat.com>
	<4A2E15B6.8030001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A2E15B6.8030001-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jun 09, 2009 at 03:56:38PM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> ...
> > +ssize_t elv_fairness_store(struct request_queue *q, const char *name,
> > +			  size_t count)
> > +{
> > +	struct elv_fq_data *efqd;
> > +	unsigned int data;
> > +	unsigned long flags;
> > +
> > +	char *p = (char *)name;
> > +
> > +	data = simple_strtoul(p, &p, 10);
> > +
> > +	if (data < 0)
> > +		data = 0;
> > +	else if (data > INT_MAX)
> > +		data = INT_MAX;
> 
>   Hi Vivek,
> 
>   data might overflow on 64 bit systems. In addition, since "fairness" is nothing 
>   more than a switch, just let it be.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---

Hi Gui,

How about following patch? Currently this should apply at the end of the
patch series. If it looks good, I will merge the changes in higher level
patches.

Thanks
Vivek

o Previously common layer elevator parameters were appearing as request
  queue parameters in sysfs. But actually these are io scheduler parameters
  in hiearchical mode. Fix it.

o Use macros to define multiple sysfs C functions doing the same thing. Code
  borrowed from CFQ. Helps reduce the number of lines of by 140.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/as-iosched.c       |    5 
 block/blk-sysfs.c        |   39 -------
 block/cfq-iosched.c      |    5 
 block/deadline-iosched.c |    5 
 block/elevator-fq.c      |  245 +++++++++++------------------------------------
 block/elevator-fq.h      |   26 ++--
 block/noop-iosched.c     |   10 +
 7 files changed, 97 insertions(+), 238 deletions(-)

Index: linux18/block/elevator-fq.h
===================================================================
--- linux18.orig/block/elevator-fq.h	2009-06-09 10:34:59.000000000 -0400
+++ linux18/block/elevator-fq.h	2009-06-09 13:35:03.000000000 -0400
@@ -27,6 +27,9 @@ struct io_queue;
 
 #ifdef CONFIG_ELV_FAIR_QUEUING
 
+#define ELV_ATTR(name) \
+	__ATTR(name, S_IRUGO|S_IWUSR, elv_##name##_show, elv_##name##_store)
+
 /**
  * struct bfq_service_tree - per ioprio_class service tree.
  * @active: tree for active entities (i.e., those backlogged).
@@ -364,7 +367,7 @@ struct elv_fq_data {
 	 * throughput and focus more on providing fairness for sync
 	 * queues.
 	 */
-	int fairness;
+	unsigned int fairness;
 	int only_root_group;
 };
 
@@ -650,23 +653,22 @@ static inline struct io_queue *elv_looku
 
 #endif /* GROUP_IOSCHED */
 
-/* Functions used by blksysfs.c */
-extern ssize_t elv_slice_idle_show(struct request_queue *q, char *name);
-extern ssize_t elv_slice_idle_store(struct request_queue *q, const char *name,
+extern ssize_t elv_slice_idle_show(struct elevator_queue *e, char *name);
+extern ssize_t elv_slice_idle_store(struct elevator_queue *e, const char *name,
 						size_t count);
-extern ssize_t elv_slice_sync_show(struct request_queue *q, char *name);
-extern ssize_t elv_slice_sync_store(struct request_queue *q, const char *name,
+extern ssize_t elv_slice_sync_show(struct elevator_queue *e, char *name);
+extern ssize_t elv_slice_sync_store(struct elevator_queue *e, const char *name,
 						size_t count);
 
-extern ssize_t elv_async_slice_idle_show(struct request_queue *q, char *name);
-extern ssize_t elv_async_slice_idle_store(struct request_queue *q,
+extern ssize_t elv_async_slice_idle_show(struct elevator_queue *e, char *name);
+extern ssize_t elv_async_slice_idle_store(struct elevator_queue *e,
 					const char *name, size_t count);
 
-extern ssize_t elv_slice_async_show(struct request_queue *q, char *name);
-extern ssize_t elv_slice_async_store(struct request_queue *q, const char *name,
+extern ssize_t elv_slice_async_show(struct elevator_queue *e, char *name);
+extern ssize_t elv_slice_async_store(struct elevator_queue *e, const char *name,
 						size_t count);
-extern ssize_t elv_fairness_show(struct request_queue *q, char *name);
-extern ssize_t elv_fairness_store(struct request_queue *q, const char *name,
+extern ssize_t elv_fairness_show(struct elevator_queue *e, char *name);
+extern ssize_t elv_fairness_store(struct elevator_queue *e, const char *name,
 						size_t count);
 
 /* Functions used by elevator.c */
Index: linux18/block/elevator-fq.c
===================================================================
--- linux18.orig/block/elevator-fq.c	2009-06-09 10:34:59.000000000 -0400
+++ linux18/block/elevator-fq.c	2009-06-09 13:39:48.000000000 -0400
@@ -2618,201 +2618,72 @@ static inline int is_root_group_ioq(stru
 	return (ioq->entity.sched_data == &efqd->root_group->sched_data);
 }
 
-/* Functions to show and store fairness value through sysfs */
-ssize_t elv_fairness_show(struct request_queue *q, char *name)
-{
-	struct elv_fq_data *efqd;
-	unsigned int data;
-	unsigned long flags;
-
-	spin_lock_irqsave(q->queue_lock, flags);
-	efqd = &q->elevator->efqd;
-	data = efqd->fairness;
-	spin_unlock_irqrestore(q->queue_lock, flags);
-	return sprintf(name, "%d\n", data);
-}
-
-ssize_t elv_fairness_store(struct request_queue *q, const char *name,
-			  size_t count)
-{
-	struct elv_fq_data *efqd;
-	unsigned int data;
-	unsigned long flags;
-
-	char *p = (char *)name;
-
-	data = simple_strtoul(p, &p, 10);
-
-	if (data < 0)
-		data = 0;
-	else if (data > INT_MAX)
-		data = INT_MAX;
-
-	spin_lock_irqsave(q->queue_lock, flags);
-	efqd = &q->elevator->efqd;
-	efqd->fairness = data;
-	spin_unlock_irqrestore(q->queue_lock, flags);
-
-	return count;
-}
-
-/* Functions to show and store elv_idle_slice value through sysfs */
-ssize_t elv_slice_idle_show(struct request_queue *q, char *name)
-{
-	struct elv_fq_data *efqd;
-	unsigned int data;
-	unsigned long flags;
-
-	spin_lock_irqsave(q->queue_lock, flags);
-	efqd = &q->elevator->efqd;
-	data = jiffies_to_msecs(efqd->elv_slice_idle);
-	spin_unlock_irqrestore(q->queue_lock, flags);
-	return sprintf(name, "%d\n", data);
-}
-
-ssize_t elv_slice_idle_store(struct request_queue *q, const char *name,
-			  size_t count)
-{
-	struct elv_fq_data *efqd;
-	unsigned int data;
-	unsigned long flags;
-
-	char *p = (char *)name;
-
-	data = simple_strtoul(p, &p, 10);
-
-	if (data < 0)
-		data = 0;
-	else if (data > INT_MAX)
-		data = INT_MAX;
-
-	data = msecs_to_jiffies(data);
-
-	spin_lock_irqsave(q->queue_lock, flags);
-	efqd = &q->elevator->efqd;
-	efqd->elv_slice_idle = data;
-	spin_unlock_irqrestore(q->queue_lock, flags);
-
-	return count;
-}
-
-/* Functions to show and store elv_idle_slice value through sysfs */
-ssize_t elv_async_slice_idle_show(struct request_queue *q, char *name)
-{
-	struct elv_fq_data *efqd;
-	unsigned int data;
-	unsigned long flags;
-
-	spin_lock_irqsave(q->queue_lock, flags);
-	efqd = &q->elevator->efqd;
-	data = jiffies_to_msecs(efqd->elv_async_slice_idle);
-	spin_unlock_irqrestore(q->queue_lock, flags);
-	return sprintf(name, "%d\n", data);
-}
-
-ssize_t elv_async_slice_idle_store(struct request_queue *q, const char *name,
-			  size_t count)
-{
-	struct elv_fq_data *efqd;
-	unsigned int data;
-	unsigned long flags;
-
-	char *p = (char *)name;
-
-	data = simple_strtoul(p, &p, 10);
-
-	if (data < 0)
-		data = 0;
-	else if (data > INT_MAX)
-		data = INT_MAX;
-
-	data = msecs_to_jiffies(data);
-
-	spin_lock_irqsave(q->queue_lock, flags);
-	efqd = &q->elevator->efqd;
-	efqd->elv_async_slice_idle = data;
-	spin_unlock_irqrestore(q->queue_lock, flags);
-
-	return count;
-}
-
-/* Functions to show and store elv_slice_sync value through sysfs */
-ssize_t elv_slice_sync_show(struct request_queue *q, char *name)
+/*
+ * sysfs parts below -->
+ */
+static ssize_t
+elv_var_show(unsigned int var, char *page)
 {
-	struct elv_fq_data *efqd;
-	unsigned int data;
-	unsigned long flags;
-
-	spin_lock_irqsave(q->queue_lock, flags);
-	efqd = &q->elevator->efqd;
-	data = efqd->elv_slice[1];
-	spin_unlock_irqrestore(q->queue_lock, flags);
-	return sprintf(name, "%d\n", data);
+	return sprintf(page, "%d\n", var);
 }
 
-ssize_t elv_slice_sync_store(struct request_queue *q, const char *name,
-			  size_t count)
+static ssize_t
+elv_var_store(unsigned int *var, const char *page, size_t count)
 {
-	struct elv_fq_data *efqd;
-	unsigned int data;
-	unsigned long flags;
-
-	char *p = (char *)name;
-
-	data = simple_strtoul(p, &p, 10);
-
-	if (data < 0)
-		data = 0;
-	/* 100ms is the limit for now*/
-	else if (data > 100)
-		data = 100;
-
-	spin_lock_irqsave(q->queue_lock, flags);
-	efqd = &q->elevator->efqd;
-	efqd->elv_slice[1] = data;
-	spin_unlock_irqrestore(q->queue_lock, flags);
+	char *p = (char *) page;
 
+	*var = simple_strtoul(p, &p, 10);
 	return count;
 }
 
-/* Functions to show and store elv_slice_async value through sysfs */
-ssize_t elv_slice_async_show(struct request_queue *q, char *name)
-{
-	struct elv_fq_data *efqd;
-	unsigned int data;
-	unsigned long flags;
-
-	spin_lock_irqsave(q->queue_lock, flags);
-	efqd = &q->elevator->efqd;
-	data = efqd->elv_slice[0];
-	spin_unlock_irqrestore(q->queue_lock, flags);
-	return sprintf(name, "%d\n", data);
-}
-
-ssize_t elv_slice_async_store(struct request_queue *q, const char *name,
-			  size_t count)
-{
-	struct elv_fq_data *efqd;
-	unsigned int data;
-	unsigned long flags;
-
-	char *p = (char *)name;
-
-	data = simple_strtoul(p, &p, 10);
-
-	if (data < 0)
-		data = 0;
-	/* 100ms is the limit for now*/
-	else if (data > 100)
-		data = 100;
-
-	spin_lock_irqsave(q->queue_lock, flags);
-	efqd = &q->elevator->efqd;
-	efqd->elv_slice[0] = data;
-	spin_unlock_irqrestore(q->queue_lock, flags);
-
-	return count;
-}
+#define SHOW_FUNCTION(__FUNC, __VAR, __CONV)				\
+ssize_t __FUNC(struct elevator_queue *e, char *page)		\
+{									\
+	struct elv_fq_data *efqd = &e->efqd;				\
+	unsigned int __data = __VAR;					\
+	if (__CONV)							\
+		__data = jiffies_to_msecs(__data);			\
+	return elv_var_show(__data, (page));				\
+}
+SHOW_FUNCTION(elv_fairness_show, efqd->fairness, 0);
+EXPORT_SYMBOL(elv_fairness_show);
+SHOW_FUNCTION(elv_slice_idle_show, efqd->elv_slice_idle, 1);
+EXPORT_SYMBOL(elv_slice_idle_show);
+SHOW_FUNCTION(elv_async_slice_idle_show, efqd->elv_async_slice_idle, 1);
+EXPORT_SYMBOL(elv_async_slice_idle_show);
+SHOW_FUNCTION(elv_slice_sync_show, efqd->elv_slice[1], 1);
+EXPORT_SYMBOL(elv_slice_sync_show);
+SHOW_FUNCTION(elv_slice_async_show, efqd->elv_slice[0], 1);
+EXPORT_SYMBOL(elv_slice_async_show);
+#undef SHOW_FUNCTION
+
+#define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
+ssize_t __FUNC(struct elevator_queue *e, const char *page, size_t count)	\
+{									\
+	struct elv_fq_data *efqd = &e->efqd;				\
+	unsigned int __data;						\
+	int ret = elv_var_store(&__data, (page), count);		\
+	if (__data < (MIN))						\
+		__data = (MIN);						\
+	else if (__data > (MAX))					\
+		__data = (MAX);						\
+	if (__CONV)							\
+		*(__PTR) = msecs_to_jiffies(__data);			\
+	else								\
+		*(__PTR) = __data;					\
+	return ret;							\
+}
+STORE_FUNCTION(elv_fairness_store, &efqd->fairness, 0, 1, 0);
+EXPORT_SYMBOL(elv_fairness_store);
+STORE_FUNCTION(elv_slice_idle_store, &efqd->elv_slice_idle, 0, UINT_MAX, 1);
+EXPORT_SYMBOL(elv_slice_idle_store);
+STORE_FUNCTION(elv_async_slice_idle_store, &efqd->elv_async_slice_idle, 0, UINT_MAX, 1);
+EXPORT_SYMBOL(elv_async_slice_idle_store);
+STORE_FUNCTION(elv_slice_sync_store, &efqd->elv_slice[1], 1, UINT_MAX, 1);
+EXPORT_SYMBOL(elv_slice_sync_store);
+STORE_FUNCTION(elv_slice_async_store, &efqd->elv_slice[0], 1, UINT_MAX, 1);
+EXPORT_SYMBOL(elv_slice_async_store);
+#undef STORE_FUNCTION
 
 void elv_schedule_dispatch(struct request_queue *q)
 {
Index: linux18/block/blk-sysfs.c
===================================================================
--- linux18.orig/block/blk-sysfs.c	2009-06-09 10:34:59.000000000 -0400
+++ linux18/block/blk-sysfs.c	2009-06-09 13:24:42.000000000 -0400
@@ -307,38 +307,6 @@ static struct queue_sysfs_entry queue_io
 	.store = queue_iostats_store,
 };
 
-#ifdef CONFIG_ELV_FAIR_QUEUING
-static struct queue_sysfs_entry queue_slice_idle_entry = {
-	.attr = {.name = "slice_idle", .mode = S_IRUGO | S_IWUSR },
-	.show = elv_slice_idle_show,
-	.store = elv_slice_idle_store,
-};
-
-static struct queue_sysfs_entry queue_async_slice_idle_entry = {
-	.attr = {.name = "async_slice_idle", .mode = S_IRUGO | S_IWUSR },
-	.show = elv_async_slice_idle_show,
-	.store = elv_async_slice_idle_store,
-};
-
-static struct queue_sysfs_entry queue_slice_sync_entry = {
-	.attr = {.name = "slice_sync", .mode = S_IRUGO | S_IWUSR },
-	.show = elv_slice_sync_show,
-	.store = elv_slice_sync_store,
-};
-
-static struct queue_sysfs_entry queue_slice_async_entry = {
-	.attr = {.name = "slice_async", .mode = S_IRUGO | S_IWUSR },
-	.show = elv_slice_async_show,
-	.store = elv_slice_async_store,
-};
-
-static struct queue_sysfs_entry queue_fairness_entry = {
-	.attr = {.name = "fairness", .mode = S_IRUGO | S_IWUSR },
-	.show = elv_fairness_show,
-	.store = elv_fairness_store,
-};
-#endif
-
 static struct attribute *default_attrs[] = {
 	&queue_requests_entry.attr,
 #ifdef CONFIG_GROUP_IOSCHED
@@ -353,13 +321,6 @@ static struct attribute *default_attrs[]
 	&queue_nomerges_entry.attr,
 	&queue_rq_affinity_entry.attr,
 	&queue_iostats_entry.attr,
-#ifdef CONFIG_ELV_FAIR_QUEUING
-	&queue_slice_idle_entry.attr,
-	&queue_async_slice_idle_entry.attr,
-	&queue_slice_sync_entry.attr,
-	&queue_slice_async_entry.attr,
-	&queue_fairness_entry.attr,
-#endif
 	NULL,
 };
 
Index: linux18/block/cfq-iosched.c
===================================================================
--- linux18.orig/block/cfq-iosched.c	2009-06-09 10:34:55.000000000 -0400
+++ linux18/block/cfq-iosched.c	2009-06-09 13:25:42.000000000 -0400
@@ -2095,6 +2095,11 @@ static struct elv_fs_entry cfq_attrs[] =
 	CFQ_ATTR(back_seek_max),
 	CFQ_ATTR(back_seek_penalty),
 	CFQ_ATTR(slice_async_rq),
+	ELV_ATTR(fairness),
+	ELV_ATTR(slice_idle),
+	ELV_ATTR(async_slice_idle),
+	ELV_ATTR(slice_sync),
+	ELV_ATTR(slice_async),
 	__ATTR_NULL
 };
 
Index: linux18/block/as-iosched.c
===================================================================
--- linux18.orig/block/as-iosched.c	2009-06-09 10:34:58.000000000 -0400
+++ linux18/block/as-iosched.c	2009-06-09 13:27:38.000000000 -0400
@@ -1766,6 +1766,11 @@ static struct elv_fs_entry as_attrs[] = 
 	AS_ATTR(antic_expire),
 	AS_ATTR(read_batch_expire),
 	AS_ATTR(write_batch_expire),
+#ifdef CONFIG_IOSCHED_AS_HIER
+	ELV_ATTR(fairness),
+	ELV_ATTR(slice_idle),
+	ELV_ATTR(slice_sync),
+#endif
 	__ATTR_NULL
 };
 
Index: linux18/block/deadline-iosched.c
===================================================================
--- linux18.orig/block/deadline-iosched.c	2009-06-09 10:34:55.000000000 -0400
+++ linux18/block/deadline-iosched.c	2009-06-09 13:28:51.000000000 -0400
@@ -460,6 +460,11 @@ static struct elv_fs_entry deadline_attr
 	DD_ATTR(writes_starved),
 	DD_ATTR(front_merges),
 	DD_ATTR(fifo_batch),
+#ifdef CONFIG_IOSCHED_DEADLINE_HIER
+	ELV_ATTR(fairness),
+	ELV_ATTR(slice_idle),
+	ELV_ATTR(slice_sync),
+#endif
 	__ATTR_NULL
 };
 
Index: linux18/block/noop-iosched.c
===================================================================
--- linux18.orig/block/noop-iosched.c	2009-06-09 10:34:52.000000000 -0400
+++ linux18/block/noop-iosched.c	2009-06-09 13:31:48.000000000 -0400
@@ -82,6 +82,15 @@ static void noop_free_noop_queue(struct 
 	kfree(nq);
 }
 
+#ifdef CONFIG_IOSCHED_NOOP_HIER
+static struct elv_fs_entry noop_attrs[] = {
+	ELV_ATTR(fairness),
+	ELV_ATTR(slice_idle),
+	ELV_ATTR(slice_sync),
+	__ATTR_NULL
+};
+#endif
+
 static struct elevator_type elevator_noop = {
 	.ops = {
 		.elevator_merge_req_fn		= noop_merged_requests,
@@ -94,6 +103,7 @@ static struct elevator_type elevator_noo
 	},
 #ifdef CONFIG_IOSCHED_NOOP_HIER
 	.elevator_features = ELV_IOSCHED_NEED_FQ | ELV_IOSCHED_SINGLE_IOQ,
+	.elevator_attrs = noop_attrs,
 #endif
 	.elevator_name = "noop",
 	.elevator_owner = THIS_MODULE,
