From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] IO Controller: Add per-device weight and ioprio_class handling
Date: Wed, 13 May 2009 10:00:21 +0800
Message-ID: <4A0A29B5.7030109__21762.4107645408$1242180227$gmane$org@cn.fujitsu.com>
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
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Vivek,

This patch enables per-cgroup per-device weight and ioprio_class handling.
A new cgroup interface "policy" is introduced. You can make use of this 
file to configure weight and ioprio_class for each device in a given cgroup.
The original "weight" and "ioprio_class" files are still available. If you
don't do special configuration for a particular device, "weight" and 
"ioprio_class" are used as default values in this device.

You can use the following format to play with the new interface.
#echo DEV:weight:ioprio_class > /patch/to/cgroup/policy
weight=0 means removing the policy for DEV.

Examples:
Configure weight=300 ioprio_class=2 on /dev/hdb in this cgroup
# echo /dev/hdb:300:2 > io.policy
# cat io.policy
dev weight class
/dev/hdb 300 2

Configure weight=500 ioprio_class=1 on /dev/hda in this cgroup
# echo /dev/hda:500:1 > io.policy
# cat io.policy
dev weight class
/dev/hda 500 1
/dev/hdb 300 2

Remove the policy for /dev/hda in this cgroup
# echo /dev/hda:0:1 > io.policy
# cat io.policy
dev weight class
/dev/hdb 300 2

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/elevator-fq.c |  239 +++++++++++++++++++++++++++++++++++++++++++++++++-
 block/elevator-fq.h |   11 +++
 2 files changed, 245 insertions(+), 5 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 69435ab..7c95d55 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -12,6 +12,9 @@
 #include "elevator-fq.h"
 #include <linux/blktrace_api.h>
 #include <linux/biotrack.h>
+#include <linux/seq_file.h>
+#include <linux/genhd.h>
+
 
 /* Values taken from cfq */
 const int elv_slice_sync = HZ / 10;
@@ -1045,12 +1048,30 @@ struct io_group *io_lookup_io_group_current(struct request_queue *q)
 }
 EXPORT_SYMBOL(io_lookup_io_group_current);
 
-void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
+static struct policy_node *policy_search_node(const struct io_cgroup *iocg,
+					      void *key);
+
+void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog,
+			  void *key)
 {
 	struct io_entity *entity = &iog->entity;
+	struct policy_node *pn;
+
+	spin_lock_irq(&iocg->lock);
+	pn = policy_search_node(iocg, key);
+	if (pn) {
+		entity->weight = pn->weight;
+		entity->new_weight = pn->weight;
+		entity->ioprio_class = pn->ioprio_class;
+		entity->new_ioprio_class = pn->ioprio_class;
+	} else {
+		entity->weight = iocg->weight;
+		entity->new_weight = iocg->weight;
+		entity->ioprio_class = iocg->ioprio_class;
+		entity->new_ioprio_class = iocg->ioprio_class;
+	}
+	spin_unlock_irq(&iocg->lock);
 
-	entity->weight = entity->new_weight = iocg->weight;
-	entity->ioprio_class = entity->new_ioprio_class = iocg->ioprio_class;
 	entity->ioprio_changed = 1;
 	entity->my_sched_data = &iog->sched_data;
 }
@@ -1263,7 +1284,7 @@ struct io_group *io_group_chain_alloc(struct request_queue *q, void *key,
 		atomic_set(&iog->ref, 0);
 		iog->deleting = 0;
 
-		io_group_init_entity(iocg, iog);
+		io_group_init_entity(iocg, iog, key);
 		iog->my_entity = &iog->entity;
 #ifdef CONFIG_DEBUG_GROUP_IOSCHED
 		iog->iocg_id = css_id(&iocg->css);
@@ -1549,8 +1570,208 @@ struct io_group *io_alloc_root_group(struct request_queue *q,
 	return iog;
 }
 
+static int io_cgroup_policy_read(struct cgroup *cgrp, struct cftype *cft,
+				  struct seq_file *m)
+{
+	struct io_cgroup *iocg;
+	struct policy_node *pn;
+
+	iocg = cgroup_to_io_cgroup(cgrp);
+
+	if (list_empty(&iocg->list))
+		goto out;
+
+	seq_printf(m, "dev weight class\n");
+
+	spin_lock_irq(&iocg->lock);
+	list_for_each_entry(pn, &iocg->list, node) {
+		seq_printf(m, "%s %lu %lu\n", pn->dev_name,
+			   pn->weight, pn->ioprio_class);
+	}
+	spin_unlock_irq(&iocg->lock);
+out:
+	return 0;
+}
+
+static inline void policy_insert_node(struct io_cgroup *iocg,
+					  struct policy_node *pn)
+{
+	list_add(&pn->node, &iocg->list);
+}
+
+/* Must be called with iocg->lock held */
+static inline void policy_delete_node(struct policy_node *pn)
+{
+	list_del(&pn->node);
+}
+
+/* Must be called with iocg->lock held */
+static struct policy_node *policy_search_node(const struct io_cgroup *iocg,
+					      void *key)
+{
+	struct policy_node *pn;
+
+	if (list_empty(&iocg->list))
+		return NULL;
+
+	list_for_each_entry(pn, &iocg->list, node) {
+		if (pn->key == key)
+			return pn;
+	}
+
+	return NULL;
+}
+
+static void *devname_to_efqd(const char *buf)
+{
+	struct block_device *bdev;
+	void *key = NULL;
+	struct gendisk *disk;
+	int part;
+
+	bdev = lookup_bdev(buf);
+	if (IS_ERR(bdev))
+		return NULL;
+
+	disk = get_gendisk(bdev->bd_dev, &part);
+	key = (void *)&disk->queue->elevator->efqd;
+	bdput(bdev);
+
+	return key;
+}
+
+static int policy_parse_and_set(char *buf, struct policy_node *newpn)
+{
+	char *s[3];
+	char *p;
+	int ret;
+	int i = 0;
+
+	memset(s, 0, sizeof(s));
+	while (i < ARRAY_SIZE(s)) {
+		p = strsep(&buf, ":");
+		if (!p)
+			break;
+		if (!*p)
+			continue;
+		s[i++] = p;
+	}
+
+	newpn->key = devname_to_efqd(s[0]);
+	if (!newpn->key)
+		return -EINVAL;
+
+	strcpy(newpn->dev_name, s[0]);
+
+	ret = strict_strtoul(s[1], 10, &newpn->weight);
+	if (ret || newpn->weight > WEIGHT_MAX)
+		return -EINVAL;
+
+	ret = strict_strtoul(s[2], 10, &newpn->ioprio_class);
+	if (ret || newpn->ioprio_class < IOPRIO_CLASS_RT ||
+	    newpn->ioprio_class > IOPRIO_CLASS_IDLE)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int io_cgroup_policy_write(struct cgroup *cgrp, struct cftype *cft,
+			    const char *buffer)
+{
+	struct io_cgroup *iocg;
+	struct policy_node *newpn, *pn;
+	char *buf;
+	int ret = 0;
+	int keep_newpn = 0;
+	struct hlist_node *n;
+	struct io_group *iog;
+
+	buf = kstrdup(buffer, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	newpn = kzalloc(sizeof(*newpn), GFP_KERNEL);
+	if (!newpn) {
+		ret = -ENOMEM;
+		goto free_buf;
+	}
+
+	ret = policy_parse_and_set(buf, newpn);
+	if (ret)
+		goto free_newpn;
+
+	if (!cgroup_lock_live_group(cgrp)) {
+		ret = -ENODEV;
+		goto free_newpn;
+	}
+
+	iocg = cgroup_to_io_cgroup(cgrp);
+	spin_lock_irq(&iocg->lock);
+
+	pn = policy_search_node(iocg, newpn->key);
+	if (!pn) {
+		if (newpn->weight != 0) {
+			policy_insert_node(iocg, newpn);
+			keep_newpn = 1;
+		}
+		goto update_io_group;
+	}
+
+	if (newpn->weight == 0) {
+		/* weight == 0 means deleteing a policy */
+		policy_delete_node(pn);
+		goto update_io_group;
+	}
+
+	pn->weight = newpn->weight;
+	pn->ioprio_class = newpn->ioprio_class;
+
+update_io_group:
+	hlist_for_each_entry(iog, n, &iocg->group_data, group_node) {
+		if (iog->key == newpn->key) {
+			if (newpn->weight) {
+				iog->entity.new_weight = newpn->weight;
+				iog->entity.new_ioprio_class =
+					newpn->ioprio_class;
+				/*
+				 * iog weight and ioprio_class updating
+				 * actually happens if ioprio_changed is set.
+				 * So ensure ioprio_changed is not set until
+				 * new weight and new ioprio_class are updated.
+				 */
+				smp_wmb();
+				iog->entity.ioprio_changed = 1;
+			} else {
+				iog->entity.new_weight = iocg->weight;
+				iog->entity.new_ioprio_class =
+					iocg->ioprio_class;
+
+				/* The same as above */
+				smp_wmb();
+				iog->entity.ioprio_changed = 1;
+			}
+		}
+	}
+	spin_unlock_irq(&iocg->lock);
+
+	cgroup_unlock();
+
+free_newpn:
+	if (!keep_newpn)
+		kfree(newpn);
+free_buf:
+	kfree(buf);
+	return ret;
+}
+
 struct cftype bfqio_files[] = {
 	{
+		.name = "policy",
+		.read_seq_string = io_cgroup_policy_read,
+		.write_string = io_cgroup_policy_write,
+		.max_write_len = 256,
+	},
+	{
 		.name = "weight",
 		.read_u64 = io_cgroup_weight_read,
 		.write_u64 = io_cgroup_weight_write,
@@ -1592,6 +1813,7 @@ struct cgroup_subsys_state *iocg_create(struct cgroup_subsys *subsys,
 	INIT_HLIST_HEAD(&iocg->group_data);
 	iocg->weight = IO_DEFAULT_GRP_WEIGHT;
 	iocg->ioprio_class = IO_DEFAULT_GRP_CLASS;
+	INIT_LIST_HEAD(&iocg->list);
 
 	return &iocg->css;
 }
@@ -1750,6 +1972,7 @@ void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
 	unsigned long flags, flags1;
 	int queue_lock_held = 0;
 	struct elv_fq_data *efqd;
+	struct policy_node *pn, *pntmp;
 
 	/*
 	 * io groups are linked in two lists. One list is maintained
@@ -1823,6 +2046,12 @@ locked:
 	BUG_ON(!hlist_empty(&iocg->group_data));
 
 	free_css_id(&io_subsys, &iocg->css);
+
+	list_for_each_entry_safe(pn, pntmp, &iocg->list, node) {
+		policy_delete_node(pn);
+		kfree(pn);
+	}
+
 	kfree(iocg);
 }
 
@@ -2137,7 +2366,7 @@ void elv_fq_unset_request_ioq(struct request_queue *q, struct request *rq)
 void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
 {
 	entity->ioprio = entity->new_ioprio;
-	entity->weight = entity->new_weight;
+	entity->weight = entity->new_weigh;
 	entity->ioprio_class = entity->new_ioprio_class;
 	entity->sched_data = &iog->sched_data;
 }
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index db3a347..0407633 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -253,6 +253,14 @@ struct io_group {
 #endif
 };
 
+struct policy_node {
+	struct list_head node;
+	char dev_name[32];
+	void *key;
+	unsigned long weight;
+	unsigned long ioprio_class;
+};
+
 /**
  * struct bfqio_cgroup - bfq cgroup data structure.
  * @css: subsystem state for bfq in the containing cgroup.
@@ -269,6 +277,9 @@ struct io_cgroup {
 
 	unsigned long weight, ioprio_class;
 
+	/* list of policy_node */
+	struct list_head list;
+
 	spinlock_t lock;
 	struct hlist_head group_data;
 };
-- 
1.5.4.rc3
