From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 7/7] let io-throttle support using bio-cgroup id
Date: Thu, 20 Nov 2008 19:15:40 +0800
Message-ID: <492546DC.20505__35900.7500847385$1227180157$gmane$org@cn.fujitsu.com>
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

This patch makes io throttle support bio-cgroup id.
With this patch, you don't have to mount io-throttle and
bio-cgroup together. It's more gentle to other subsystems
who also want to use bio-cgroup.

Signed-of-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/blk-core.c                |    4 +-
 block/blk-io-throttle.c         |  324 ++++++++++++++++++++++++++++++++++++++-
 include/linux/biotrack.h        |    2 +
 include/linux/blk-io-throttle.h |    5 +-
 mm/biotrack.c                   |   11 ++
 5 files changed, 339 insertions(+), 7 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index e187476..da3c8af 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1537,8 +1537,8 @@ void submit_bio(int rw, struct bio *bio)
 	if (bio_has_data(bio)) {
 		if (rw & WRITE) {
 			count_vm_events(PGPGOUT, count);
-			cgroup_io_throttle(bio_iovec_idx(bio, 0)->bv_page,
-					bio->bi_bdev, bio->bi_size, 0);
+			cgroup_io_throttle(bio,	bio->bi_bdev, 
+					   bio->bi_size, 0);
 		} else {
 			task_io_account_read(bio->bi_size);
 			count_vm_events(PGPGIN, count);
diff --git a/block/blk-io-throttle.c b/block/blk-io-throttle.c
index e6a0a03..77f58a6 100644
--- a/block/blk-io-throttle.c
+++ b/block/blk-io-throttle.c
@@ -32,6 +32,9 @@
 #include <linux/seq_file.h>
 #include <linux/spinlock.h>
 #include <linux/blk-io-throttle.h>
+#include <linux/biotrack.h>
+#include <linux/sched.h>
+#include <linux/bio.h>
 
 /*
  * Statistics for I/O bandwidth controller.
@@ -126,6 +129,13 @@ struct iothrottle_node {
 	struct iothrottle_stat stat;
 };
 
+/* A list of iothrottle which associate with a bio_cgroup */
+static LIST_HEAD(bio_group_list);
+static DECLARE_MUTEX(bio_group_list_sem);
+
+enum {
+	MOVING_FORBIDDEN,
+};
 /**
  * struct iothrottle - throttling rules for a cgroup
  * @css: pointer to the cgroup state
@@ -139,9 +149,125 @@ struct iothrottle_node {
 struct iothrottle {
 	struct cgroup_subsys_state css;
 	struct list_head list;
+	struct list_head bio_node;
+	int bio_id;
+	unsigned long flags;
 };
 static struct iothrottle init_iothrottle;
 
+static inline int is_bind_biocgroup(void)
+{
+	if (init_iothrottle.css.cgroup->subsys[bio_cgroup_subsys_id])
+		return 1;
+
+	return 0;
+}
+
+static inline int is_moving_forbidden(const struct iothrottle *iot)
+{
+	return test_bit(MOVING_FORBIDDEN, &iot->flags);
+}
+
+
+static struct iothrottle *bioid_to_iothrottle(int id)
+{
+	struct iothrottle *iot;
+	
+	down(&bio_group_list_sem);
+	list_for_each_entry(iot, &bio_group_list, bio_node) {
+		if (iot->bio_id == id) {
+			up(&bio_group_list_sem);
+			return iot;
+		}
+	}
+	up(&bio_group_list_sem);
+	return NULL;
+}
+
+static int is_bio_group(struct iothrottle *iot)
+{
+	if (iot && iot->bio_id > 0)
+		return 0;
+
+	return -1;
+}
+
+static int synchronize_bio_cgroup(int old_id, int new_id,
+				  struct task_struct *tsk)
+{
+	struct iothrottle *old_group, *new_group;
+	int ret = 0;
+
+	old_group = bioid_to_iothrottle(old_id);
+	new_group = bioid_to_iothrottle(new_id);
+
+	/* no need hold cgroup_lock(), for bio_cgroup holding it already*/
+	get_task_struct(tsk);
+
+	/* This has nothing to do with us! */
+	if (is_bio_group(old_group) && is_bio_group(new_group)) {
+		goto out;
+	}
+
+	/* if moving from an associated one to an unassociated one,
+	   just moving it to root
+	*/
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
+
+
+ out:
+	put_task_struct(tsk);
+	return ret;
+}
+
+static int iothrottle_notifier_call(struct notifier_block *this, unsigned long event,
+			       void *ptr)
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
+	tsk = tmm->tsk;
+	synchronize_bio_cgroup(old_id, new_id, tsk);
+
+	return NOTIFY_OK;
+}
+
+
+static struct notifier_block iothrottle_notifier = {
+	.notifier_call = iothrottle_notifier_call,
+};
+
 static inline struct iothrottle *cgroup_to_iothrottle(struct cgroup *cgrp)
 {
 	return container_of(cgroup_subsys_state(cgrp, iothrottle_subsys_id),
@@ -209,14 +335,20 @@ iothrottle_create(struct cgroup_subsys *ss, struct cgroup *cgrp)
 {
 	struct iothrottle *iot;
 
-	if (unlikely((cgrp->parent) == NULL))
+	if (unlikely((cgrp->parent) == NULL)) {
 		iot = &init_iothrottle;
+		/* where should we release?*/
+		register_biocgroup_notifier(&iothrottle_notifier);
+	}
 	else {
 		iot = kmalloc(sizeof(*iot), GFP_KERNEL);
 		if (unlikely(!iot))
 			return ERR_PTR(-ENOMEM);
 	}
 	INIT_LIST_HEAD(&iot->list);
+	INIT_LIST_HEAD(&iot->bio_node);
+	iot->bio_id = -1;
+	clear_bit(MOVING_FORBIDDEN, &iot->flags);
 
 	return &iot->css;
 }
@@ -229,6 +361,9 @@ static void iothrottle_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
 	struct iothrottle_node *n, *p;
 	struct iothrottle *iot = cgroup_to_iothrottle(cgrp);
 
+	if (unlikely((cgrp->parent) == NULL))
+		unregister_biocgroup_notifier(&iothrottle_notifier);
+
 	/*
 	 * don't worry about locking here, at this point there must be not any
 	 * reference to the list.
@@ -523,6 +658,138 @@ out1:
 	return ret;
 }
 
+s64 read_bio_id(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct iothrottle *iot;
+
+	iot = cgroup_to_iothrottle(cgrp);
+	return iot->bio_id;
+}
+
+int write_bio_id(struct cgroup *cgrp, struct cftype *cft, s64 val)
+{
+	int id, i, count;
+	struct cgroup *bio_cgroup;
+	struct cgroup_iter it;
+	struct iothrottle *iot, *pos;
+	struct task_struct **tasks;
+
+	if (is_bind_biocgroup())
+		return -EPERM;
+
+	iot = cgroup_to_iothrottle(cgrp);
+
+	/* no more operation if it's a root */
+	if (!cgrp->parent)
+		return 0;
+
+	id = val;
+
+	/* de-associate from a bio-cgroup*/
+	if (id < 0) {
+		if (is_bio_group(iot)) {
+			return 0;
+		}
+
+		read_lock(&tasklist_lock);
+		count = cgroup_task_count(cgrp);
+		if (!count) {
+			;
+		} else {
+			tasks = (struct task_struct **)kmalloc(count * sizeof(*tasks),
+							       GFP_KERNEL);
+			if (unlikely(!tasks)) {
+				read_unlock(&tasklist_lock);
+				return -ENOMEM;
+			}
+			i = 0;
+			cgroup_iter_start(cgrp, &it);
+			while ((tasks[i] = cgroup_iter_next(cgrp, &it))) {
+				get_task_struct(tasks[i]);
+				i++;
+			}
+			cgroup_iter_end(cgrp, &it);
+
+			clear_bit(MOVING_FORBIDDEN, &iot->flags);
+			cgroup_lock();
+			for (i = 0; i < count; i++) {
+				cgroup_attach_task(init_iothrottle.css.cgroup, tasks[i]);
+				put_task_struct(tasks[i]);
+			}
+			cgroup_unlock();
+			kfree(tasks);
+		}
+
+		read_unlock(&tasklist_lock);
+		down(&bio_group_list_sem);
+		list_del_init(&iot->bio_node);
+		up(&bio_group_list_sem);
+
+		iot->bio_id = -1;
+		return 0;
+	}
+
+	if (cgroup_task_count(cgrp))
+		return -EPERM;
+
+	bio_cgroup = bio_id_to_cgroup(id);
+	if (bio_cgroup) {
+		/* 
+		   Go through the bio_group_list, if don't exist, put it 
+		   into this list.
+		*/
+		down(&bio_group_list_sem);
+		list_for_each_entry(pos, &bio_group_list, bio_node) {
+			if (pos->bio_id == id) {
+				up(&bio_group_list_sem);
+				return -EEXIST;
+			}
+		}
+		up(&bio_group_list_sem);
+
+		read_lock(&tasklist_lock);
+ 		count = cgroup_task_count(bio_cgroup);
+		if (count) {
+			tasks = (struct task_struct **)kmalloc(count * sizeof(*tasks), 
+							       GFP_KERNEL);
+			if (unlikely(!tasks)) {
+				read_unlock(&tasklist_lock);	
+				return -ENOMEM;
+			}
+		} else
+			goto no_tasks;
+
+		i = 0;
+
+		/* synchronize tasks with bio_cgroup */
+		cgroup_iter_start(bio_cgroup, &it);
+		while ((tasks[i] = cgroup_iter_next(bio_cgroup, &it))) {
+			get_task_struct(tasks[i]);
+			i++;
+		}
+		cgroup_iter_end(bio_cgroup, &it);
+		
+		cgroup_lock();
+		for (i = 0; i < count; i++) {
+			cgroup_attach_task(cgrp, tasks[i]);
+			put_task_struct(tasks[i]);
+		}
+		cgroup_unlock();
+		
+		kfree(tasks);
+	no_tasks:
+		read_unlock(&tasklist_lock);
+		down(&bio_group_list_sem);
+		list_add(&iot->bio_node, &bio_group_list);
+		up(&bio_group_list_sem);
+
+		iot->bio_id = id;
+		set_bit(MOVING_FORBIDDEN, &iot->flags);
+	}
+
+	return 0;
+}
+
 static struct cftype files[] = {
 	{
 		.name = "bandwidth-max",
@@ -548,6 +815,11 @@ static struct cftype files[] = {
 		.read_seq_string = iothrottle_read,
 		.private = IOTHROTTLE_STAT,
 	},
+	{
+		.name = "bio_id",
+		.write_s64 = write_bio_id,
+		.read_s64 = read_bio_id,
+	}
 };
 
 static int iothrottle_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
@@ -555,11 +827,41 @@ static int iothrottle_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
 	return cgroup_add_files(cgrp, ss, files, ARRAY_SIZE(files));
 }
 
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
+	
+	if (subsys_bits & ~allow_subsys_bits)
+		return -1;
+	return 0;
+}
+
 struct cgroup_subsys iothrottle_subsys = {
 	.name = "blockio",
 	.create = iothrottle_create,
 	.destroy = iothrottle_destroy,
 	.populate = iothrottle_populate,
+	.can_attach = iothrottle_can_attach,
+	.subsys_depend = iothrottle_subsys_depend,
 	.subsys_id = iothrottle_subsys_id,
 	.early_init = 1,
 };
@@ -681,13 +983,15 @@ static inline int is_kthread_io(void)
  * timeout.
  **/
 unsigned long long
-cgroup_io_throttle(struct page *page, struct block_device *bdev,
+cgroup_io_throttle(struct bio *bio, struct block_device *bdev,
 		ssize_t bytes, int can_sleep)
 {
 	struct iothrottle *iot;
 	struct iothrottle_sleep s = {};
 	unsigned long long sleep;
+	struct page *page;
 
+	iot = NULL;
 	if (unlikely(!bdev))
 		return 0;
 	BUG_ON(!bdev->bd_inode || !bdev->bd_disk);
@@ -710,7 +1014,21 @@ cgroup_io_throttle(struct page *page, struct block_device *bdev,
 		(irqs_disabled() || in_interrupt() || in_atomic()));
 
 	/* check if we need to throttle */
-	iot = get_iothrottle_from_page(page);
+	
+	if (bio) {
+		page = bio_iovec_idx(bio, 0)->bv_page;
+		iot = get_iothrottle_from_page(page);
+	}
+	if (!iot) {
+		int id;
+
+		if (bio) {
+			id = get_bio_cgroup_id(bio);
+			iot = bioid_to_iothrottle(id);
+		}
+		if (iot)
+			css_get(&iot->css);
+	}
 	rcu_read_lock();
 	if (!iot) {
 		iot = task_to_iothrottle(current);
diff --git a/include/linux/biotrack.h b/include/linux/biotrack.h
index 546017c..e3957af 100644
--- a/include/linux/biotrack.h
+++ b/include/linux/biotrack.h
@@ -26,12 +26,14 @@ struct bio_cgroup {
 /*	struct radix_tree_root io_context_root; per device io_context */
 };
 
+
 static inline void __init_bio_page_cgroup(struct page_cgroup *pc)
 {
 	pc->bio_cgroup_id = 0;
 }
 extern struct cgroup *get_cgroup_from_page(struct page *page);
 extern void put_cgroup_from_page(struct page *page);
+extern struct cgroup *bio_id_to_cgroup(int id);
 
 static inline int bio_cgroup_disabled(void)
 {
diff --git a/include/linux/blk-io-throttle.h b/include/linux/blk-io-throttle.h
index a241758..9ef414e 100644
--- a/include/linux/blk-io-throttle.h
+++ b/include/linux/blk-io-throttle.h
@@ -14,8 +14,9 @@
 #define IOTHROTTLE_STAT		3
 
 #ifdef CONFIG_CGROUP_IO_THROTTLE
+
 extern unsigned long long
-cgroup_io_throttle(struct page *page, struct block_device *bdev,
+cgroup_io_throttle(struct bio *bio, struct block_device *bdev,
 		ssize_t bytes, int can_sleep);
 
 static inline void set_in_aio(void)
@@ -58,7 +59,7 @@ get_io_throttle_sleep(struct task_struct *t, int type)
 }
 #else
 static inline unsigned long long
-cgroup_io_throttle(struct page *page, struct block_device *bdev,
+cgroup_io_throttle(struct bio *bio, struct block_device *bdev,
 		ssize_t bytes, int can_sleep)
 {
 	return 0;
diff --git a/mm/biotrack.c b/mm/biotrack.c
index 979efcd..e3d9ad7 100644
--- a/mm/biotrack.c
+++ b/mm/biotrack.c
@@ -229,6 +229,17 @@ static struct bio_cgroup *find_bio_cgroup(int id)
 	return biog;
 }
 
+struct cgroup *bio_id_to_cgroup(int id)
+{
+	struct bio_cgroup *biog;
+
+	biog = find_bio_cgroup(id);
+	if (biog)
+		return biog->css.cgroup;
+
+	return NULL;
+}
+
 struct cgroup *get_cgroup_from_page(struct page *page)
 {
 	struct page_cgroup *pc;
-- 1.5.4.rc3 
