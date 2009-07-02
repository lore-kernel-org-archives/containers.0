From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 23/25] io-controller: Support per cgroup per device weights
	and io class
Date: Thu,  2 Jul 2009 16:01:55 -0400
Message-ID: <1246564917-19603-24-git-send-email-vgoyal__15233.342399779$1246567722$gmane$org@redhat.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246564917-19603-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

This patch enables per-cgroup per-device weight and ioprio_class handling.
A new cgroup interface "policy" is introduced. You can make use of this
file to configure weight and ioprio_class for each device in a given cgroup.
The original "weight" and "ioprio_class" files are still available. If you
don't do special configuration for a particular device, "weight" and
"ioprio_class" are used as default values in this device.

You can use the following format to play with the new interface.
#echo dev_major:dev_minor weight ioprio_class > /patch/to/cgroup/policy
weight=0 means removing the policy for device.

Examples:
Configure weight=300 ioprio_class=2 on /dev/hdb (8:16) in this cgroup
# echo "8:16 300 2" > io.policy
# cat io.policy
dev	weight	class
8:16	300	2

Configure weight=500 ioprio_class=1 on /dev/hda (8:0) in this cgroup
# echo "8:0 500 1" > io.policy
# cat io.policy
dev	weight	class
8:0	500	1
8:16	300	2

Remove the policy for /dev/hda in this cgroup
# echo 8:0 0 1 > io.policy
# cat io.policy
dev	weight	class
8:16	300	2

Changelog (v1 -> v2)
- Rename some structures
- Use spin_lock_irqsave() and spin_lock_irqrestore() version to prevent
  from enabling the interrupts unconditionally.
- Fix policy setup bug when switching to another io scheduler.
- If a policy is available for a specific device, don't update weight and
  io class when writing "weight" and "iprio_class".
- Fix a bug when parsing policy string.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/elevator-fq.c |  266 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 block/elevator-fq.h |   10 ++
 2 files changed, 272 insertions(+), 4 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 2a2b68d..31b066d 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -17,6 +17,7 @@
 #include <linux/blktrace_api.h>
 #include <linux/seq_file.h>
 #include <linux/biotrack.h>
+#include <linux/genhd.h>
 
 /* Values taken from cfq */
 const int elv_slice_sync = HZ / 10;
@@ -1053,12 +1054,31 @@ static void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
 	entity->sched_data = &iog->sched_data;
 }
 
-static void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
+static struct io_policy_node *policy_search_node(const struct io_cgroup *iocg,
+						 dev_t dev);
+
+static void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog,
+			  dev_t dev)
 {
 	struct io_entity *entity = &iog->entity;
+	struct io_policy_node *pn;
+	unsigned long flags;
+
+	spin_lock_irqsave(&iocg->lock, flags);
+	pn = policy_search_node(iocg, dev);
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
+	spin_unlock_irqrestore(&iocg->lock, flags);
 
-	entity->weight = entity->new_weight = iocg->weight;
-	entity->ioprio_class = entity->new_ioprio_class = iocg->ioprio_class;
 	entity->ioprio_changed = 1;
 	entity->my_sched_data = &iog->sched_data;
 }
@@ -1174,6 +1194,227 @@ io_cgroup_lookup_group(struct io_cgroup *iocg, void *key)
 	return NULL;
 }
 
+static int io_cgroup_policy_read(struct cgroup *cgrp, struct cftype *cft,
+				  struct seq_file *m)
+{
+	struct io_cgroup *iocg;
+	struct io_policy_node *pn;
+
+	iocg = cgroup_to_io_cgroup(cgrp);
+
+	if (list_empty(&iocg->policy_list))
+		goto out;
+
+	seq_printf(m, "dev\tweight\tclass\n");
+
+	spin_lock_irq(&iocg->lock);
+	list_for_each_entry(pn, &iocg->policy_list, node) {
+		seq_printf(m, "%u:%u\t%u\t%hu\n", MAJOR(pn->dev),
+			   MINOR(pn->dev), pn->weight, pn->ioprio_class);
+	}
+	spin_unlock_irq(&iocg->lock);
+out:
+	return 0;
+}
+
+static inline void policy_insert_node(struct io_cgroup *iocg,
+					  struct io_policy_node *pn)
+{
+	list_add(&pn->node, &iocg->policy_list);
+}
+
+/* Must be called with iocg->lock held */
+static inline void policy_delete_node(struct io_policy_node *pn)
+{
+	list_del(&pn->node);
+}
+
+/* Must be called with iocg->lock held */
+static struct io_policy_node *policy_search_node(const struct io_cgroup *iocg,
+						 dev_t dev)
+{
+	struct io_policy_node *pn;
+
+	if (list_empty(&iocg->policy_list))
+		return NULL;
+
+	list_for_each_entry(pn, &iocg->policy_list, node) {
+		if (pn->dev == dev)
+			return pn;
+	}
+
+	return NULL;
+}
+
+static int check_dev_num(dev_t dev)
+{
+	int part = 0;
+	struct gendisk *disk;
+
+	disk = get_gendisk(dev, &part);
+	if (!disk || part)
+		return -ENODEV;
+
+	return 0;
+}
+
+static int policy_parse_and_set(char *buf, struct io_policy_node *newpn)
+{
+	char *s[4], *p, *major_s = NULL, *minor_s = NULL;
+	int ret;
+	unsigned long major, minor, temp;
+	int i = 0;
+	dev_t dev;
+
+	memset(s, 0, sizeof(s));
+	while ((p = strsep(&buf, " ")) != NULL) {
+		if (!*p)
+			continue;
+		s[i++] = p;
+
+		/* Prevent from inputing too many things */
+		if (i == 4)
+			break;
+	}
+
+	if (i != 3)
+		return -EINVAL;
+
+	p = strsep(&s[0], ":");
+	if (p != NULL)
+		major_s = p;
+	else
+		return -EINVAL;
+
+	minor_s = s[0];
+	if (!minor_s)
+		return -EINVAL;
+
+	ret = strict_strtoul(major_s, 10, &major);
+	if (ret)
+		return -EINVAL;
+
+	ret = strict_strtoul(minor_s, 10, &minor);
+	if (ret)
+		return -EINVAL;
+
+	dev = MKDEV(major, minor);
+
+	ret = check_dev_num(dev);
+	if (ret)
+		return ret;
+
+	newpn->dev = dev;
+
+	if (s[1] == NULL)
+		return -EINVAL;
+
+	ret = strict_strtoul(s[1], 10, &temp);
+	if (ret || temp > WEIGHT_MAX)
+		return -EINVAL;
+
+	newpn->weight =  temp;
+
+	if (s[2] == NULL)
+		return -EINVAL;
+
+	ret = strict_strtoul(s[2], 10, &temp);
+	if (ret || temp < IOPRIO_CLASS_RT || temp > IOPRIO_CLASS_IDLE)
+		return -EINVAL;
+	newpn->ioprio_class = temp;
+
+	return 0;
+}
+
+static int io_cgroup_policy_write(struct cgroup *cgrp, struct cftype *cft,
+			    const char *buffer)
+{
+	struct io_cgroup *iocg;
+	struct io_policy_node *newpn, *pn;
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
+	pn = policy_search_node(iocg, newpn->dev);
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
+		if (iog->dev == newpn->dev) {
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
 #define SHOW_FUNCTION(__VAR)						\
 static u64 io_cgroup_##__VAR##_read(struct cgroup *cgroup,		\
 				       struct cftype *cftype)		\
@@ -1206,6 +1447,7 @@ static int io_cgroup_##__VAR##_write(struct cgroup *cgroup,		\
 	struct io_cgroup *iocg;					\
 	struct io_group *iog;						\
 	struct hlist_node *n;						\
+	struct io_policy_node *pn;					\
 									\
 	if (val < (__MIN) || val > (__MAX))				\
 		return -EINVAL;						\
@@ -1218,6 +1460,9 @@ static int io_cgroup_##__VAR##_write(struct cgroup *cgroup,		\
 	spin_lock_irq(&iocg->lock);					\
 	iocg->__VAR = (unsigned long)val;				\
 	hlist_for_each_entry(iog, n, &iocg->group_data, group_node) {	\
+		pn = policy_search_node(iocg, iog->dev);		\
+		if (pn)							\
+			continue;					\
 		iog->entity.new_##__VAR = (unsigned long)val;		\
 		smp_wmb();						\
 		iog->entity.ioprio_changed = 1;				\
@@ -1295,6 +1540,12 @@ static int io_cgroup_disk_sectors_read(struct cgroup *cgroup,
 
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
@@ -1336,6 +1587,7 @@ static struct cgroup_subsys_state *iocg_create(struct cgroup_subsys *subsys,
 	INIT_HLIST_HEAD(&iocg->group_data);
 	iocg->weight = IO_DEFAULT_GRP_WEIGHT;
 	iocg->ioprio_class = IO_DEFAULT_GRP_CLASS;
+	INIT_LIST_HEAD(&iocg->policy_list);
 
 	return &iocg->css;
 }
@@ -1438,7 +1690,7 @@ io_group_chain_alloc(struct request_queue *q, void *key, struct cgroup *cgroup)
 		sscanf(dev_name(bdi->dev), "%u:%u", &major, &minor);
 		iog->dev = MKDEV(major, minor);
 
-		io_group_init_entity(iocg, iog);
+		io_group_init_entity(iocg, iog, iog->dev);
 		iog->my_entity = &iog->entity;
 
 		atomic_set(&iog->ref, 0);
@@ -1904,6 +2156,7 @@ static void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
 	struct io_group *iog;
 	struct elv_fq_data *efqd;
 	unsigned long uninitialized_var(flags);
+	struct io_policy_node *pn, *pntmp;
 
 	/*
 	 * io groups are linked in two lists. One list is maintained
@@ -1943,6 +2196,11 @@ remove_entry:
 	goto remove_entry;
 
 done:
+	list_for_each_entry_safe(pn, pntmp, &iocg->policy_list, node) {
+		policy_delete_node(pn);
+		kfree(pn);
+	}
+
 	free_css_id(&io_subsys, &iocg->css);
 	rcu_read_unlock();
 	BUG_ON(!hlist_empty(&iocg->group_data));
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 214fb61..58c650b 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -267,6 +267,13 @@ struct io_group {
 	struct request_list rl;
 };
 
+struct io_policy_node {
+	struct list_head node;
+	dev_t dev;
+	unsigned int weight;
+	unsigned short ioprio_class;
+};
+
 /**
  * struct io_cgroup - io cgroup data structure.
  * @css: subsystem state for io in the containing cgroup.
@@ -284,6 +291,9 @@ struct io_cgroup {
 	unsigned int weight;
 	unsigned short ioprio_class;
 
+	/* list of io_policy_node */
+	struct list_head policy_list;
+
 	spinlock_t lock;
 	struct hlist_head group_data;
 };
-- 
1.6.0.6
