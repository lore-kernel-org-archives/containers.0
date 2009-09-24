From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 07/28] io-controller: cgroup related changes for hierarchical
	group support
Date: Thu, 24 Sep 2009 15:25:11 -0400
Message-ID: <1253820332-10246-8-git-send-email-vgoyal__36811.9221333929$1253821029$gmane$org@redhat.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253820332-10246-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

o This patch introduces some of the cgroup related code for io controller.

Signed-off-by: Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-ioc.c               |    3 +
 block/elevator-fq.c           |  169 ++++++++++++++++++++++++++++++++++++++++-
 block/elevator-fq.h           |   14 ++++
 include/linux/cgroup_subsys.h |    6 ++
 include/linux/iocontext.h     |    5 +
 5 files changed, 196 insertions(+), 1 deletions(-)

diff --git a/block/blk-ioc.c b/block/blk-ioc.c
index d4ed600..0d56336 100644
--- a/block/blk-ioc.c
+++ b/block/blk-ioc.c
@@ -95,6 +95,9 @@ struct io_context *alloc_io_context(gfp_t gfp_flags, int node)
 		spin_lock_init(&ret->lock);
 		ret->ioprio_changed = 0;
 		ret->ioprio = 0;
+#ifdef CONFIG_GROUP_IOSCHED
+		ret->cgroup_changed = 0;
+#endif
 		ret->last_waited = jiffies; /* doesn't matter... */
 		ret->nr_batch_requests = 0; /* because this is 0 */
 		ret->aic = NULL;
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 0e3d58c..0c060a6 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -265,7 +265,7 @@ static void entity_served(struct io_entity *entity, unsigned long served,
 	unsigned long charge = queue_charge;
 
 	for_each_entity(entity) {
-		entity->vdisktime += elv_delta_fair(queue_charge, entity);
+		entity->vdisktime += elv_delta_fair(charge, entity);
 		update_min_vdisktime(entity->st);
 		/* Group charge can be different from queue charge */
 		charge = group_charge;
@@ -920,6 +920,173 @@ EXPORT_SYMBOL(elv_io_group_set_async_queue);
 
 #ifdef CONFIG_GROUP_IOSCHED
 
+struct io_cgroup io_root_cgroup = {
+	.weight = IO_WEIGHT_DEFAULT,
+	.ioprio_class = IOPRIO_CLASS_BE,
+};
+
+static struct io_cgroup *cgroup_to_io_cgroup(struct cgroup *cgroup)
+{
+	return container_of(cgroup_subsys_state(cgroup, io_subsys_id),
+			    struct io_cgroup, css);
+}
+
+#define SHOW_FUNCTION(__VAR)						\
+static u64 io_cgroup_##__VAR##_read(struct cgroup *cgroup,		\
+				       struct cftype *cftype)		\
+{									\
+	struct io_cgroup *iocg;					\
+	u64 ret;							\
+									\
+	if (!cgroup_lock_live_group(cgroup))				\
+		return -ENODEV;						\
+									\
+	iocg = cgroup_to_io_cgroup(cgroup);				\
+	spin_lock_irq(&iocg->lock);					\
+	ret = iocg->__VAR;						\
+	spin_unlock_irq(&iocg->lock);					\
+									\
+	cgroup_unlock();						\
+									\
+	return ret;							\
+}
+
+SHOW_FUNCTION(weight);
+SHOW_FUNCTION(ioprio_class);
+#undef SHOW_FUNCTION
+
+#define STORE_FUNCTION(__VAR, __MIN, __MAX)				\
+static int io_cgroup_##__VAR##_write(struct cgroup *cgroup,		\
+					struct cftype *cftype,		\
+					u64 val)			\
+{									\
+	struct io_cgroup *iocg;					\
+	struct io_group *iog;						\
+	struct hlist_node *n;						\
+									\
+	if (val < (__MIN) || val > (__MAX))				\
+		return -EINVAL;						\
+									\
+	if (!cgroup_lock_live_group(cgroup))				\
+		return -ENODEV;						\
+									\
+	iocg = cgroup_to_io_cgroup(cgroup);				\
+									\
+	spin_lock_irq(&iocg->lock);					\
+	iocg->__VAR = (unsigned long)val;				\
+	hlist_for_each_entry(iog, n, &iocg->group_data, group_node) {	\
+		iog->entity.__VAR = (unsigned long)val;		\
+		smp_wmb();						\
+		iog->entity.ioprio_changed = 1;				\
+	}								\
+	spin_unlock_irq(&iocg->lock);					\
+									\
+	cgroup_unlock();						\
+									\
+	return 0;							\
+}
+
+STORE_FUNCTION(weight, IO_WEIGHT_MIN, IO_WEIGHT_MAX);
+STORE_FUNCTION(ioprio_class, IOPRIO_CLASS_RT, IOPRIO_CLASS_IDLE);
+#undef STORE_FUNCTION
+
+struct cftype io_files[] = {
+	{
+		.name = "weight",
+		.read_u64 = io_cgroup_weight_read,
+		.write_u64 = io_cgroup_weight_write,
+	},
+	{
+		.name = "ioprio_class",
+		.read_u64 = io_cgroup_ioprio_class_read,
+		.write_u64 = io_cgroup_ioprio_class_write,
+	},
+};
+
+static int iocg_populate(struct cgroup_subsys *subsys, struct cgroup *cgroup)
+{
+	return cgroup_add_files(cgroup, subsys, io_files, ARRAY_SIZE(io_files));
+}
+
+static struct cgroup_subsys_state *iocg_create(struct cgroup_subsys *subsys,
+						struct cgroup *cgroup)
+{
+	struct io_cgroup *iocg;
+
+	if (cgroup->parent != NULL) {
+		iocg = kzalloc(sizeof(*iocg), GFP_KERNEL);
+		if (iocg == NULL)
+			return ERR_PTR(-ENOMEM);
+	} else
+		iocg = &io_root_cgroup;
+
+	spin_lock_init(&iocg->lock);
+	INIT_HLIST_HEAD(&iocg->group_data);
+	iocg->weight = IO_WEIGHT_DEFAULT;
+	iocg->ioprio_class = IOPRIO_CLASS_BE;
+
+	return &iocg->css;
+}
+
+/*
+ * We cannot support shared io contexts, as we have no mean to support
+ * two tasks with the same ioc in two different groups without major rework
+ * of the main cic data structures.  By now we allow a task to change
+ * its cgroup only if it's the only owner of its ioc; the drawback of this
+ * behavior is that a group containing a task that forked using CLONE_IO
+ * will not be destroyed until the tasks sharing the ioc die.
+ */
+static int iocg_can_attach(struct cgroup_subsys *subsys, struct cgroup *cgroup,
+			    struct task_struct *tsk)
+{
+	struct io_context *ioc;
+	int ret = 0;
+
+	/* task_lock() is needed to avoid races with exit_io_context() */
+	task_lock(tsk);
+	ioc = tsk->io_context;
+	if (ioc != NULL && atomic_read(&ioc->nr_tasks) > 1)
+		/*
+		 * ioc == NULL means that the task is either too young or
+		 * exiting: if it has still no ioc the ioc can't be shared,
+		 * if the task is exiting the attach will fail anyway, no
+		 * matter what we return here.
+		 */
+		ret = -EINVAL;
+	task_unlock(tsk);
+
+	return ret;
+}
+
+static void iocg_attach(struct cgroup_subsys *subsys, struct cgroup *cgroup,
+			 struct cgroup *prev, struct task_struct *tsk)
+{
+	struct io_context *ioc;
+
+	task_lock(tsk);
+	ioc = tsk->io_context;
+	if (ioc != NULL)
+		ioc->cgroup_changed = 1;
+	task_unlock(tsk);
+}
+
+static void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
+{
+
+	/* Implemented in later patch */
+}
+
+struct cgroup_subsys io_subsys = {
+	.name = "io",
+	.create = iocg_create,
+	.can_attach = iocg_can_attach,
+	.attach = iocg_attach,
+	.destroy = iocg_destroy,
+	.populate = iocg_populate,
+	.subsys_id = io_subsys_id,
+	.use_id = 1,
+};
+
 static void io_free_root_group(struct elevator_queue *e)
 {
 	struct io_group *iog = e->efqd->root_group;
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 068f240..f343841 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -13,6 +13,7 @@
 
 #ifdef CONFIG_BLOCK
 #include <linux/blkdev.h>
+#include <linux/cgroup.h>
 
 #ifndef _ELV_SCHED_H
 #define _ELV_SCHED_H
@@ -98,6 +99,8 @@ struct io_group {
 	struct io_entity entity;
 	atomic_t ref;
 	struct io_sched_data sched_data;
+	struct hlist_node group_node;
+	unsigned short iocg_id;
 	/*
 	 * async queue for each priority case for RT and BE class.
 	 * Used only for cfq.
@@ -108,6 +111,17 @@ struct io_group {
 	void *key;
 };
 
+struct io_cgroup {
+	struct cgroup_subsys_state css;
+
+	unsigned int weight;
+	unsigned short ioprio_class;
+
+	spinlock_t lock;
+	struct hlist_head group_data;
+};
+
+
 #else /* CONFIG_GROUP_IOSCHED */
 
 struct io_group {
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 9c8d31b..baf544f 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -60,3 +60,9 @@ SUBSYS(net_cls)
 #endif
 
 /* */
+
+#ifdef CONFIG_GROUP_IOSCHED
+SUBSYS(io)
+#endif
+
+/* */
diff --git a/include/linux/iocontext.h b/include/linux/iocontext.h
index 4da4a75..b343594 100644
--- a/include/linux/iocontext.h
+++ b/include/linux/iocontext.h
@@ -73,6 +73,11 @@ struct io_context {
 	unsigned short ioprio;
 	unsigned short ioprio_changed;
 
+#ifdef CONFIG_GROUP_IOSCHED
+	/* If task changes the cgroup, elevator processes it asynchronously */
+	unsigned short cgroup_changed;
+#endif
+
 	/*
 	 * For request batching
 	 */
-- 
1.6.0.6
