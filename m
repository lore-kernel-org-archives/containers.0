From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] IO Controller: Add per-device weight and ioprio_class
	handling
Date: Thu, 14 May 2009 09:51:13 +0800
Message-ID: <4A0B7911.6080005__49590.8302291811$1242265972$gmane$org@cn.fujitsu.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<4A0A29B5.7030109@cn.fujitsu.com>
	<20090513155900.GA15623@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090513155900.GA15623-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
...
> 
> Hi Gui,
> 
> It might make sense to also store the device name or device major and
> minor number in io_group while creating the io group. This will help us
> to display io.disk_time and io.disk_sector statistics per device instead
> of aggregate.
> 
> I am attaching a patch I was playing around with to display per device
> statistics instead of aggregate one. So if user has specified the per
> device rule.
> 
> Thanks
> Vivek
> 
> 
> o Currently the statistics exported through cgroup are aggregate of statistics
>   on all devices for that cgroup. Instead of aggregate, make these per device.

Hi Vivek,

Actually, I did it also.
FYI

Examples:
# cat io.disk_time
dev:/dev/hdb time:4421
dev:others time:3741

# cat io.disk_sectors
dev:/dev/hdb sectors:585696
dev:others sectors:2664

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/elevator-fq.c |  104 +++++++++++++++++++++++---------------------------
 1 files changed, 48 insertions(+), 56 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 7c95d55..1620074 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -1162,90 +1162,82 @@ STORE_FUNCTION(weight, 0, WEIGHT_MAX);
 STORE_FUNCTION(ioprio_class, IOPRIO_CLASS_RT, IOPRIO_CLASS_IDLE);
 #undef STORE_FUNCTION
 
-/*
- * traverse through all the io_groups associated with this cgroup and calculate
- * the aggr disk time received by all the groups on respective disks.
- */
-static u64 calculate_aggr_disk_time(struct io_cgroup *iocg)
+static int io_cgroup_disk_time_read(struct cgroup *cgroup,
+				    struct cftype *cftype,
+				    struct seq_file *m)
 {
+	struct io_cgroup *iocg;
 	struct io_group *iog;
 	struct hlist_node *n;
-	u64 disk_time = 0;
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
-		/*
-		 * There might be groups which are not functional and
-		 * waiting to be reclaimed upon cgoup deletion.
-		 */
-		if (rcu_dereference(iog->key))
-			disk_time += iog->entity.total_service;
-	}
-	rcu_read_unlock();
-
-	return disk_time;
-}
+	struct policy_node *pn;
+	unsigned int other, time;
 
-static u64 io_cgroup_disk_time_read(struct cgroup *cgroup,
-					struct cftype *cftype)
-{
-	struct io_cgroup *iocg;
-	u64 ret;
+	other = 0;
 
 	if (!cgroup_lock_live_group(cgroup))
 		return -ENODEV;
 
 	iocg = cgroup_to_io_cgroup(cgroup);
 	spin_lock_irq(&iocg->lock);
-	ret = jiffies_to_msecs(calculate_aggr_disk_time(iocg));
+	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
+		if (iog->key != NULL) {
+			pn = policy_search_node(iocg, iog->key);
+			if (pn) {
+				time = jiffies_to_msecs(iog->entity.
+							total_service);
+				seq_printf(m, "dev:%s time:%u\n",
+					   pn->dev_name, time);
+			} else {
+				other += jiffies_to_msecs(iog->entity.
+							  total_service);
+			}
+		}
+	}
+	seq_printf(m, "dev:others time:%u\n", other);
+
 	spin_unlock_irq(&iocg->lock);
 
 	cgroup_unlock();
 
-	return ret;
+	return 0;
 }
 
-/*
- * traverse through all the io_groups associated with this cgroup and calculate
- * the aggr number of sectors transferred by all the groups on respective disks.
- */
-static u64 calculate_aggr_disk_sectors(struct io_cgroup *iocg)
+static int io_cgroup_disk_sectors_read(struct cgroup *cgroup,
+				       struct cftype *cftype,
+				       struct seq_file *m)
 {
+	struct io_cgroup *iocg;
 	struct io_group *iog;
 	struct hlist_node *n;
-	u64 disk_sectors = 0;
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
-		/*
-		 * There might be groups which are not functional and
-		 * waiting to be reclaimed upon cgoup deletion.
-		 */
-		if (rcu_dereference(iog->key))
-			disk_sectors += iog->entity.total_sector_service;
-	}
-	rcu_read_unlock();
+	struct policy_node *pn;
+	u64 other = 0;
 
-	return disk_sectors;
-}
-
-static u64 io_cgroup_disk_sectors_read(struct cgroup *cgroup,
-					struct cftype *cftype)
-{
-	struct io_cgroup *iocg;
-	u64 ret;
 
 	if (!cgroup_lock_live_group(cgroup))
 		return -ENODEV;
 
 	iocg = cgroup_to_io_cgroup(cgroup);
 	spin_lock_irq(&iocg->lock);
-	ret = calculate_aggr_disk_sectors(iocg);
+	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
+		if (iog->key) {
+			pn = policy_search_node(iocg, iog->key);
+			if (pn) {
+				seq_printf(m, "dev:%s sectors:%lu\n",
+					   pn->dev_name,
+					   iog->entity.total_sector_service);
+			} else {
+				other += iog->entity.total_sector_service;
+			}
+		}
+	}
+
+	seq_printf(m, "dev:others sectors:%llu\n", other);
+
 	spin_unlock_irq(&iocg->lock);
 
 	cgroup_unlock();
 
-	return ret;
+	return 0;
 }
 
 /**
@@ -1783,11 +1775,11 @@ struct cftype bfqio_files[] = {
 	},
 	{
 		.name = "disk_time",
-		.read_u64 = io_cgroup_disk_time_read,
+		.read_seq_string = io_cgroup_disk_time_read,
 	},
 	{
 		.name = "disk_sectors",
-		.read_u64 = io_cgroup_disk_sectors_read,
+		.read_seq_string = io_cgroup_disk_sectors_read,
 	},
 };
 
-- 
1.5.4.rc3
