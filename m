From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 07/20] io-controller: Export disk time used and nr sectors
	dipatched through cgroups
Date: Fri, 19 Jun 2009 16:37:25 -0400
Message-ID: <1245443858-8487-8-git-send-email-vgoyal__31738.2717541934$1245445108$gmane$org@redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1245443858-8487-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

o This patch exports some statistics through cgroup interface. Two of the
  statistics currently exported are actual disk time assigned to the cgroup
  and actual number of sectors dispatched to disk on behalf of this cgroup.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/elevator-fq.c |   87 +++++++++++++++++++++++++++++++++++++++++++++++---
 block/elevator-fq.h |   10 ++++++
 2 files changed, 91 insertions(+), 6 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index e52ace7..11a7fca 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -13,6 +13,7 @@
 #include <linux/blkdev.h>
 #include "elevator-fq.h"
 #include <linux/blktrace_api.h>
+#include <linux/seq_file.h>
 
 /* Values taken from cfq */
 const int elv_slice_sync = HZ / 10;
@@ -979,12 +980,15 @@ struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
 	return entity;
 }
 
-void entity_served(struct io_entity *entity, bfq_service_t served)
+void entity_served(struct io_entity *entity, bfq_service_t served,
+					bfq_service_t nr_sectors)
 {
 	struct io_service_tree *st;
 	for_each_entity(entity) {
 		st = io_entity_service_tree(entity);
 		entity->service += served;
+		entity->total_service += served;
+		entity->total_sector_service += nr_sectors;
 		BUG_ON(st->wsum == 0);
 		st->vtime += bfq_delta(served, st->wsum);
 		bfq_forget_idle(st);
@@ -1145,6 +1149,66 @@ STORE_FUNCTION(weight, 1, WEIGHT_MAX);
 STORE_FUNCTION(ioprio_class, IOPRIO_CLASS_RT, IOPRIO_CLASS_IDLE);
 #undef STORE_FUNCTION
 
+static int io_cgroup_disk_time_read(struct cgroup *cgroup,
+				struct cftype *cftype, struct seq_file *m)
+{
+	struct io_cgroup *iocg;
+	struct io_group *iog;
+	struct hlist_node *n;
+
+	if (!cgroup_lock_live_group(cgroup))
+		return -ENODEV;
+
+	iocg = cgroup_to_io_cgroup(cgroup);
+
+	spin_lock_irq(&iocg->lock);
+	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
+		/*
+		 * There might be groups which are not functional and
+		 * waiting to be reclaimed upon cgoup deletion.
+		 */
+		if (iog->key) {
+			seq_printf(m, "%u %u %lu\n", MAJOR(iog->dev),
+					MINOR(iog->dev),
+					iog->entity.total_service);
+		}
+	}
+	spin_unlock_irq(&iocg->lock);
+	cgroup_unlock();
+
+	return 0;
+}
+
+static int io_cgroup_disk_sectors_read(struct cgroup *cgroup,
+				struct cftype *cftype, struct seq_file *m)
+{
+	struct io_cgroup *iocg;
+	struct io_group *iog;
+	struct hlist_node *n;
+
+	if (!cgroup_lock_live_group(cgroup))
+		return -ENODEV;
+
+	iocg = cgroup_to_io_cgroup(cgroup);
+
+	spin_lock_irq(&iocg->lock);
+	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
+		/*
+		 * There might be groups which are not functional and
+		 * waiting to be reclaimed upon cgoup deletion.
+		 */
+		if (iog->key) {
+			seq_printf(m, "%u %u %lu\n", MAJOR(iog->dev),
+					MINOR(iog->dev),
+					iog->entity.total_sector_service);
+		}
+	}
+	spin_unlock_irq(&iocg->lock);
+	cgroup_unlock();
+
+	return 0;
+}
+
 /**
  * bfq_group_chain_alloc - allocate a chain of groups.
  * @bfqd: queue descriptor.
@@ -1155,7 +1219,7 @@ STORE_FUNCTION(ioprio_class, IOPRIO_CLASS_RT, IOPRIO_CLASS_IDLE);
  * to the root has already an allocated group on @bfqd.
  */
 struct io_group *io_group_chain_alloc(struct request_queue *q, void *key,
-					struct cgroup *cgroup)
+					struct cgroup *cgroup, struct bio *bio)
 {
 	struct io_cgroup *iocg;
 	struct io_group *iog, *leaf = NULL, *prev = NULL;
@@ -1180,6 +1244,9 @@ struct io_group *io_group_chain_alloc(struct request_queue *q, void *key,
 
 		iog->iocg_id = css_id(&iocg->css);
 
+		sscanf(dev_name(bdi->dev), "%u:%u", &major, &minor);
+		iog->dev = MKDEV(major, minor);
+
 		io_group_init_entity(iocg, iog);
 		iog->my_entity = &iog->entity;
 
@@ -1297,7 +1364,7 @@ void io_group_chain_link(struct request_queue *q, void *key,
  */
 struct io_group *io_find_alloc_group(struct request_queue *q,
 			struct cgroup *cgroup, struct elv_fq_data *efqd,
-			int create)
+			int create, struct bio *bio)
 {
 	struct io_cgroup *iocg = cgroup_to_io_cgroup(cgroup);
 	struct io_group *iog = NULL;
@@ -1316,7 +1383,7 @@ struct io_group *io_find_alloc_group(struct request_queue *q,
 	if (iog != NULL || !create)
 		goto end;
 
-	iog = io_group_chain_alloc(q, key, cgroup);
+	iog = io_group_chain_alloc(q, key, cgroup, bio);
 	if (iog != NULL)
 		io_group_chain_link(q, key, cgroup, iog, efqd);
 
@@ -1346,7 +1413,7 @@ struct io_group *io_get_io_group(struct request_queue *q, int create)
 
 	rcu_read_lock();
 	cgroup = task_cgroup(current, io_subsys_id);
-	iog = io_find_alloc_group(q, cgroup, efqd, create);
+	iog = io_find_alloc_group(q, cgroup, efqd, create, NULL);
 	if (!iog) {
 		if (create)
 			iog = efqd->root_group;
@@ -1421,6 +1488,14 @@ struct cftype bfqio_files[] = {
 		.read_u64 = io_cgroup_ioprio_class_read,
 		.write_u64 = io_cgroup_ioprio_class_write,
 	},
+	{
+		.name = "disk_time",
+		.read_seq_string = io_cgroup_disk_time_read,
+	},
+	{
+		.name = "disk_sectors",
+		.read_seq_string = io_cgroup_disk_sectors_read,
+	},
 };
 
 int iocg_populate(struct cgroup_subsys *subsys, struct cgroup *cgroup)
@@ -1868,7 +1943,7 @@ EXPORT_SYMBOL(elv_get_slice_idle);
 
 void elv_ioq_served(struct io_queue *ioq, bfq_service_t served)
 {
-	entity_served(&ioq->entity, served);
+	entity_served(&ioq->entity, served, ioq->nr_sectors);
 }
 
 /* Tells whether ioq is queued in root group or not */
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index d9a643a..9f0c9a0 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -150,6 +150,13 @@ struct io_entity {
 	unsigned short ioprio_class, new_ioprio_class;
 
 	int ioprio_changed;
+
+	/*
+	 * Keep track of total service received by this entity. Keep the
+	 * stats both for time slices and number of sectors dispatched
+	 */
+	unsigned long total_service;
+	unsigned long total_sector_service;
 };
 
 /*
@@ -243,6 +250,9 @@ struct io_group {
 
 	int deleting;
 	unsigned short iocg_id;
+
+	/* The device MKDEV(major, minor), this group has been created for */
+	dev_t	dev;
 };
 
 /**
-- 
1.6.0.6
