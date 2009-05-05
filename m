From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 07/18] io-controller: Export disk time used and nr sectors
	dipatched through cgroups
Date: Tue,  5 May 2009 15:58:34 -0400
Message-ID: <1241553525-28095-8-git-send-email-vgoyal__9723.84616402469$1241555545$gmane$org@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1241553525-28095-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, fer
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

o This patch exports some statistics through cgroup interface. Two of the
  statistics currently exported are actual disk time assigned to the cgroup
  and actual number of sectors dispatched to disk on behalf of this cgroup.

o Currently these numbers are aggregate. That means it is for all the tasks
  in that cgroup on all the disks. Later may be it will help to get per
  disk statistics also.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/elevator-fq.c |  101 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 block/elevator-fq.h |    7 ++++
 2 files changed, 106 insertions(+), 2 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index cdaa46f..b8dbc8b 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -886,13 +886,16 @@ struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
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
@@ -1064,6 +1067,92 @@ STORE_FUNCTION(weight, 0, WEIGHT_MAX);
 STORE_FUNCTION(ioprio_class, IOPRIO_CLASS_RT, IOPRIO_CLASS_IDLE);
 #undef STORE_FUNCTION
 
+/*
+ * traverse through all the io_groups associated with this cgroup and calculate
+ * the aggr disk time received by all the groups on respective disks.
+ */
+static u64 calculate_aggr_disk_time(struct io_cgroup *iocg)
+{
+	struct io_group *iog;
+	struct hlist_node *n;
+	u64 disk_time = 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
+		/*
+		 * There might be groups which are not functional and
+		 * waiting to be reclaimed upon cgoup deletion.
+		 */
+		if (rcu_dereference(iog->key))
+			disk_time += iog->entity.total_service;
+	}
+	rcu_read_unlock();
+
+	return disk_time;
+}
+
+static u64 io_cgroup_disk_time_read(struct cgroup *cgroup,
+					struct cftype *cftype)
+{
+	struct io_cgroup *iocg;
+	u64 ret;
+
+	if (!cgroup_lock_live_group(cgroup))
+		return -ENODEV;
+
+	iocg = cgroup_to_io_cgroup(cgroup);
+	spin_lock_irq(&iocg->lock);
+	ret = jiffies_to_msecs(calculate_aggr_disk_time(iocg));
+	spin_unlock_irq(&iocg->lock);
+
+	cgroup_unlock();
+
+	return ret;
+}
+
+/*
+ * traverse through all the io_groups associated with this cgroup and calculate
+ * the aggr number of sectors transferred by all the groups on respective disks.
+ */
+static u64 calculate_aggr_disk_sectors(struct io_cgroup *iocg)
+{
+	struct io_group *iog;
+	struct hlist_node *n;
+	u64 disk_sectors = 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
+		/*
+		 * There might be groups which are not functional and
+		 * waiting to be reclaimed upon cgoup deletion.
+		 */
+		if (rcu_dereference(iog->key))
+			disk_sectors += iog->entity.total_sector_service;
+	}
+	rcu_read_unlock();
+
+	return disk_sectors;
+}
+
+static u64 io_cgroup_disk_sectors_read(struct cgroup *cgroup,
+					struct cftype *cftype)
+{
+	struct io_cgroup *iocg;
+	u64 ret;
+
+	if (!cgroup_lock_live_group(cgroup))
+		return -ENODEV;
+
+	iocg = cgroup_to_io_cgroup(cgroup);
+	spin_lock_irq(&iocg->lock);
+	ret = calculate_aggr_disk_sectors(iocg);
+	spin_unlock_irq(&iocg->lock);
+
+	cgroup_unlock();
+
+	return ret;
+}
+
 /**
  * bfq_group_chain_alloc - allocate a chain of groups.
  * @bfqd: queue descriptor.
@@ -1297,6 +1386,14 @@ struct cftype bfqio_files[] = {
 		.read_u64 = io_cgroup_ioprio_class_read,
 		.write_u64 = io_cgroup_ioprio_class_write,
 	},
+	{
+		.name = "disk_time",
+		.read_u64 = io_cgroup_disk_time_read,
+	},
+	{
+		.name = "disk_sectors",
+		.read_u64 = io_cgroup_disk_sectors_read,
+	},
 };
 
 int iocg_populate(struct cgroup_subsys *subsys, struct cgroup *cgroup)
@@ -1712,7 +1809,7 @@ EXPORT_SYMBOL(elv_get_slice_idle);
 
 void elv_ioq_served(struct io_queue *ioq, bfq_service_t served)
 {
-	entity_served(&ioq->entity, served);
+	entity_served(&ioq->entity, served, ioq->nr_sectors);
 }
 
 /* Tells whether ioq is queued in root group or not */
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 8c60cf7..f4c6361 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -145,6 +145,13 @@ struct io_entity {
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
-- 
1.6.0.1
