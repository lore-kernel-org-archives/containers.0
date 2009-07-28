From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 7/7] blkio-cgroup-v10: Add a cgroup support to dm-ioband
Date: Tue, 28 Jul 2009 21:20:20 +0900 (JST)
Message-ID: <20090728.212020.183038601.ryov__3388.36905216358$1248783717$gmane$org@valinux.co.jp>
References: <20090728.211850.104046372.ryov@valinux.co.jp>
	<20090728.211922.189712796.ryov@valinux.co.jp>
	<20090728.211956.112608332.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090728.211956.112608332.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org
List-Id: containers.vger.kernel.org

With this patch, dm-ioband can work with the blkio-cgroup.

Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>

---
 drivers/md/dm-ioband-ctl.c     |  201 ++++++++++++++++++++++++++++++++++++++++-
 drivers/md/dm-ioband-policy.c  |   20 +++-
 drivers/md/dm-ioband-rangebw.c |   13 ++
 drivers/md/dm-ioband-type.c    |   10 --
 drivers/md/dm-ioband.h         |   14 ++
 drivers/md/dm-ioctl.c          |    1 
 include/linux/biotrack.h       |    7 +
 mm/biotrack.c                  |  116 +++++++++++++++++++++++
 8 files changed, 371 insertions(+), 11 deletions(-)

Index: linux-2.6.31-rc3-mm1/include/linux/biotrack.h
===================================================================
--- linux-2.6.31-rc3-mm1.orig/include/linux/biotrack.h
+++ linux-2.6.31-rc3-mm1/include/linux/biotrack.h
@@ -9,6 +9,7 @@
 
 struct io_context;
 struct block_device;
+struct ioband_cgroup_ops;
 
 struct blkio_cgroup {
 	struct cgroup_subsys_state css;
@@ -48,6 +49,12 @@ extern void blkio_cgroup_copy_owner(stru
 extern struct io_context *get_blkio_cgroup_iocontext(struct bio *bio);
 extern unsigned long get_blkio_cgroup_id(struct bio *bio);
 extern struct cgroup *blkio_cgroup_lookup(unsigned long id);
+extern int blkio_cgroup_register_ioband(const struct ioband_cgroup_ops *ops);
+
+static inline int blkio_cgroup_unregister_ioband(void)
+{
+	return blkio_cgroup_register_ioband(NULL);
+}
 
 #else /* !CONFIG_CGROUP_BLKIO */
 
Index: linux-2.6.31-rc3-mm1/mm/biotrack.c
===================================================================
--- linux-2.6.31-rc3-mm1.orig/mm/biotrack.c
+++ linux-2.6.31-rc3-mm1/mm/biotrack.c
@@ -20,6 +20,9 @@
 #include <linux/blkdev.h>
 #include <linux/biotrack.h>
 #include <linux/mm_inline.h>
+#include <linux/seq_file.h>
+#include <linux/dm-ioctl.h>
+#include <../drivers/md/dm-ioband.h>
 
 /*
  * The block I/O tracking mechanism is implemented on the cgroup memory
@@ -46,6 +49,8 @@ static struct io_context default_blkio_i
 static struct blkio_cgroup default_blkio_cgroup = {
 	.io_context	= &default_blkio_io_context,
 };
+static DEFINE_MUTEX(ioband_ops_lock);
+static const struct ioband_cgroup_ops *ioband_ops = NULL;
 
 /**
  * blkio_cgroup_set_owner() - set the owner ID of a page.
@@ -181,6 +186,14 @@ blkio_cgroup_create(struct cgroup_subsys
 static void blkio_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
 {
 	struct blkio_cgroup *biog = cgroup_blkio(cgrp);
+	int id;
+
+	mutex_lock(&ioband_ops_lock);
+	if (ioband_ops) {
+		id = css_id(&biog->css);
+		ioband_ops->remove_group(id);
+	}
+	mutex_unlock(&ioband_ops_lock);
 
 	put_io_context(biog->io_context);
 	free_css_id(&blkio_cgroup_subsys, &biog->css);
@@ -253,9 +266,28 @@ struct cgroup *blkio_cgroup_lookup(unsig
 		return NULL;
 	return css->cgroup;
 }
+
+/**
+ * blkio_cgroup_register_ioband() - register ioband
+ * @p:	a pointer to struct ioband_cgroup_ops
+ *
+ * Calling with NULL means unregistration.
+ * Returns 0 on success.
+ */
+int blkio_cgroup_register_ioband(const struct ioband_cgroup_ops *p)
+{
+	if (blkio_cgroup_disabled())
+		return -1;
+
+	mutex_lock(&ioband_ops_lock);
+	ioband_ops = p;
+	mutex_unlock(&ioband_ops_lock);
+	return 0;
+}
 EXPORT_SYMBOL(get_blkio_cgroup_id);
 EXPORT_SYMBOL(get_blkio_cgroup_iocontext);
 EXPORT_SYMBOL(blkio_cgroup_lookup);
+EXPORT_SYMBOL(blkio_cgroup_register_ioband);
 
 /* Read the ID of the specified blkio cgroup. */
 static u64 blkio_id_read(struct cgroup *cgrp, struct cftype *cft)
@@ -265,11 +297,95 @@ static u64 blkio_id_read(struct cgroup *
 	return (u64)css_id(&biog->css);
 }
 
+/* Show all ioband devices and their settings. */
+static int blkio_devs_read(struct cgroup *cgrp, struct cftype *cft,
+							struct seq_file *m)
+{
+	mutex_lock(&ioband_ops_lock);
+	if (ioband_ops)
+		ioband_ops->show_device(m);
+	mutex_unlock(&ioband_ops_lock);
+	return 0;
+}
+
+/* Configure ioband devices specified by an ioband device ID */
+static int blkio_devs_write(struct cgroup *cgrp, struct cftype *cft,
+							const char *buffer)
+{
+	char **argv;
+	int argc, r = 0;
+
+	if (cgrp != cgrp->top_cgroup)
+		return -EACCES;
+
+	argv = argv_split(GFP_KERNEL, buffer, &argc);
+	if (!argv)
+		return -ENOMEM;
+
+	mutex_lock(&ioband_ops_lock);
+	if (ioband_ops)
+		r = ioband_ops->config_device(argc, argv);
+	mutex_unlock(&ioband_ops_lock);
+
+	argv_free(argv);
+	return r;
+}
+
+/* Show the settings of the specified blkio cgroup. */
+static int blkio_settings_read(struct cgroup *cgrp, struct cftype *cft,
+							struct seq_file *m)
+{
+	struct blkio_cgroup *biog;
+	int id;
+
+	mutex_lock(&ioband_ops_lock);
+	if (ioband_ops) {
+		biog = cgroup_blkio(cgrp);
+		id = css_id(&biog->css);
+		ioband_ops->show_group(m, biog, id);
+	}
+	mutex_unlock(&ioband_ops_lock);
+	return 0;
+}
+
+/* Configure the specified blkio cgroup. */
+static int blkio_settings_write(struct cgroup *cgrp, struct cftype *cft,
+							const char *buffer)
+{
+	struct blkio_cgroup *biog;
+	char **argv;
+	int argc, id, r = 0;
+
+	argv = argv_split(GFP_KERNEL, buffer, &argc);
+	if (!argv)
+		return -ENOMEM;
+
+	mutex_lock(&ioband_ops_lock);
+	if (ioband_ops) {
+		biog = cgroup_blkio(cgrp);
+		id = css_id(&biog->css);
+		r = ioband_ops->config_group(argc, argv, biog, id);
+	}
+	mutex_unlock(&ioband_ops_lock);
+	argv_free(argv);
+	return r;
+}
+
 static struct cftype blkio_files[] = {
 	{
 		.name = "id",
 		.read_u64 = blkio_id_read,
 	},
+	{
+		.name = "devices",
+		.read_seq_string = blkio_devs_read,
+		.write_string = blkio_devs_write,
+	},
+	{
+		.name = "settings",
+		.read_seq_string = blkio_settings_read,
+		.write_string = blkio_settings_write,
+	},
 };
 
 static int blkio_cgroup_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
Index: linux-2.6.31-rc3-mm1/drivers/md/dm-ioctl.c
===================================================================
--- linux-2.6.31-rc3-mm1.orig/drivers/md/dm-ioctl.c
+++ linux-2.6.31-rc3-mm1/drivers/md/dm-ioctl.c
@@ -1601,3 +1601,4 @@ out:
 
 	return r;
 }
+EXPORT_SYMBOL(dm_copy_name_and_uuid);
Index: linux-2.6.31-rc3-mm1/drivers/md/dm-ioband-policy.c
===================================================================
--- linux-2.6.31-rc3-mm1.orig/drivers/md/dm-ioband-policy.c
+++ linux-2.6.31-rc3-mm1/drivers/md/dm-ioband-policy.c
@@ -8,6 +8,7 @@
 #include <linux/bio.h>
 #include <linux/workqueue.h>
 #include <linux/rbtree.h>
+#include <linux/seq_file.h>
 #include "dm.h"
 #include "dm-ioband.h"
 
@@ -276,7 +277,7 @@ static int policy_weight_param(struct io
 	if (value)
 		err = strict_strtol(value, 0, &val);
 
-	if (!strcmp(cmd, "weight")) {
+	if (!cmd || !strcmp(cmd, "weight")) {
 		if (!value)
 			set_weight(gp, DEFAULT_WEIGHT);
 		else if (!err && 0 < val && val <= SHORT_MAX)
@@ -341,6 +342,19 @@ static void policy_weight_show(struct io
 	*szp = sz;
 }
 
+static void policy_weight_show_device(struct seq_file *m,
+				      struct ioband_device *dp)
+{
+	seq_printf(m, " token=%d carryover=%d",
+				dp->g_token_bucket, dp->g_carryover);
+}
+
+static void policy_weight_show_group(struct seq_file *m,
+				     struct ioband_group *gp)
+{
+	seq_printf(m, " weight=%d", gp->c_weight);
+}
+
 /*
  *  <Method>      <description>
  * g_can_submit   : To determine whether a given group has the right to
@@ -369,6 +383,8 @@ static void policy_weight_show(struct io
  *                  Return 1 if a given group can't receive any more BIOs,
  *                  otherwise return 0.
  * g_show         : Show the configuration.
+ * g_show_device  : Show the configuration of the specified ioband device.
+ * g_show_group   : Show the configuration of the spacified ioband group.
  */
 static int policy_weight_init(struct ioband_device *dp, int argc, char **argv)
 {
@@ -391,6 +407,8 @@ static int policy_weight_init(struct iob
 	dp->g_set_param = policy_weight_param;
 	dp->g_should_block = is_queue_full;
 	dp->g_show = policy_weight_show;
+	dp->g_show_device = policy_weight_show_device;
+	dp->g_show_group = policy_weight_show_group;
 
 	dp->g_epoch = 0;
 	dp->g_weight_total = 0;
Index: linux-2.6.31-rc3-mm1/drivers/md/dm-ioband-rangebw.c
===================================================================
--- linux-2.6.31-rc3-mm1.orig/drivers/md/dm-ioband-rangebw.c
+++ linux-2.6.31-rc3-mm1/drivers/md/dm-ioband-rangebw.c
@@ -25,6 +25,7 @@
 #include <linux/random.h>
 #include <linux/time.h>
 #include <linux/timer.h>
+#include <linux/seq_file.h>
 #include "dm.h"
 #include "md.h"
 #include "dm-ioband.h"
@@ -459,7 +460,7 @@ static int policy_range_bw_param(struct 
 			err++;
 	}
 
-	if (!strcmp(cmd, "range-bw")) {
+	if (!cmd || !strcmp(cmd, "range-bw")) {
 		if (!err && 0 <= min_val &&
 		    min_val <= (INT_MAX / 2) &&	0 <= max_val &&
 		    max_val <= (INT_MAX / 2) && min_val <= max_val)
@@ -547,6 +548,12 @@ static void policy_range_bw_show(struct 
 	*szp = sz;
 }
 
+static void policy_range_bw_show_group(struct seq_file *m,
+				       struct ioband_group *gp)
+{
+	seq_printf(m, " range-bw=%d:%d", gp->c_min_bw, gp->c_max_bw);
+}
+
 static int range_bw_prepare_token(struct ioband_group *gp,
 						struct bio *bio, int flag)
 {
@@ -633,6 +640,8 @@ void range_bw_timeover(unsigned long gp)
  *                  Return 1 if a given group can't receive any more BIOs,
  *                  otherwise return 0.
  * g_show         : Show the configuration.
+ * g_show_device  : Show the configuration of the specified ioband device.
+ * g_show_group   : Show the configuration of the spacified ioband group.
  */
 
 int policy_range_bw_init(struct ioband_device *dp, int argc, char **argv)
@@ -656,6 +665,8 @@ int policy_range_bw_init(struct ioband_d
 	dp->g_set_param = policy_range_bw_param;
 	dp->g_should_block = range_bw_queue_full;
 	dp->g_show = policy_range_bw_show;
+	dp->g_show_device = NULL;
+	dp->g_show_group = policy_range_bw_show_group;
 
 	dp->g_min_bw_total = 0;
 	dp->g_running_gp = NULL;
Index: linux-2.6.31-rc3-mm1/drivers/md/dm-ioband-ctl.c
===================================================================
--- linux-2.6.31-rc3-mm1.orig/drivers/md/dm-ioband-ctl.c
+++ linux-2.6.31-rc3-mm1/drivers/md/dm-ioband-ctl.c
@@ -13,6 +13,8 @@
 #include <linux/slab.h>
 #include <linux/workqueue.h>
 #include <linux/rbtree.h>
+#include <linux/biotrack.h>
+#include <linux/dm-ioctl.h>
 #include "dm.h"
 #include "md.h"
 #include "dm-ioband.h"
@@ -109,6 +111,7 @@ static struct ioband_device *alloc_ioban
 	INIT_DELAYED_WORK(&new_dp->g_conductor, ioband_conduct);
 	INIT_LIST_HEAD(&new_dp->g_groups);
 	INIT_LIST_HEAD(&new_dp->g_list);
+	INIT_LIST_HEAD(&new_dp->g_heads);
 	spin_lock_init(&new_dp->g_lock);
 	bio_list_init(&new_dp->g_urgent_bios);
 	new_dp->g_io_throttle = io_throttle;
@@ -241,6 +244,7 @@ static int ioband_group_init(struct ioba
 	int r;
 
 	INIT_LIST_HEAD(&gp->c_list);
+	INIT_LIST_HEAD(&gp->c_heads);
 	bio_list_init(&gp->c_blocked_bios);
 	bio_list_init(&gp->c_prio_bios);
 	gp->c_id = id;	/* should be verified */
@@ -271,7 +275,8 @@ static int ioband_group_init(struct ioba
 		ioband_group_add_node(&head->c_group_root, gp);
 		gp->c_dev = head->c_dev;
 		gp->c_target = head->c_target;
-	}
+	} else
+		list_add_tail(&gp->c_heads, &dp->g_heads);
 
 	spin_unlock_irqrestore(&dp->g_lock, flags);
 	return 0;
@@ -285,6 +290,8 @@ static void ioband_group_release(struct 
 	list_del(&gp->c_list);
 	if (head)
 		rb_erase(&gp->c_group_node, &head->c_group_root);
+	else
+		list_del(&gp->c_heads);
 	dp->g_group_dtr(gp);
 	kfree(gp);
 }
@@ -1297,6 +1304,191 @@ static struct target_type ioband_target 
 	.iterate_devices = ioband_iterate_devices,
 };
 
+#ifdef CONFIG_CGROUP_BLKIO
+/* Read the ID of the specified blkio cgroup. */
+static void ioband_copy_name(struct ioband_group *gp, char *name)
+{
+	struct mapped_device *md;
+
+	md = dm_table_get_md(gp->c_target->table);
+	dm_copy_name_and_uuid(md, name, NULL);
+	dm_put(md);
+}
+
+/* Show all ioband devices and their settings. */
+static void ioband_cgroup_show_device(struct seq_file *m)
+{
+	struct ioband_device *dp;
+	struct ioband_group *gp;
+	char name[DM_NAME_LEN];
+
+	mutex_lock(&ioband_lock);
+	list_for_each_entry(dp, &ioband_device_list, g_list) {
+		seq_printf(m, "%s policy=%s io_throttle=%d io_limit=%d",
+			   dp->g_name, dp->g_policy->p_name,
+			   dp->g_io_throttle, dp->g_io_limit);
+		if (dp->g_show_device)
+			dp->g_show_device(m, dp);
+		seq_putc(m, '\n');
+
+		list_for_each_entry(gp, &dp->g_heads, c_heads) {
+			if (strcmp(gp->c_type->t_name, "cgroup"))
+				continue;
+			ioband_copy_name(gp, name);
+			seq_printf(m, "  %s\n", name);
+		}
+	}
+	mutex_unlock(&ioband_lock);
+}
+
+/* Configure ioband devices specified by an ioband device ID */
+static int ioband_cgroup_config_device(int argc, char **argv)
+{
+	struct ioband_device *dp;
+	struct ioband_group *gp;
+	char name[DM_NAME_LEN];
+	int r;
+
+	if (argc < 1)
+		return -EINVAL;
+
+	mutex_lock(&ioband_lock);
+	/* look up the ioband device */
+	list_for_each_entry(dp, &ioband_device_list, g_list) {
+		/* assuming argv[0] is a share name */
+		if (!strcmp(dp->g_name, argv[0])) {
+			gp = list_first_entry(&dp->g_heads,
+					      struct ioband_group, c_heads);
+			goto found;
+		}
+
+		/* assuming argv[0] is a device name */
+		list_for_each_entry(gp, &dp->g_heads, c_heads) {
+			ioband_copy_name(gp, name);
+			if (!strcmp(name, argv[0]))
+				goto found;
+		}
+	}
+	mutex_unlock(&ioband_lock);
+	return -ENODEV;
+
+found:
+	if (!strcmp(gp->c_type->t_name, "cgroup"))
+		r = __ioband_message(gp->c_target, --argc, &argv[1]);
+	else
+		r = -ENODEV;
+
+	mutex_unlock(&ioband_lock);
+	return r;
+}
+
+/* Show the settings of the specified blkio cgroup. */
+static void ioband_cgroup_show_group(struct seq_file *m,
+				     struct blkio_cgroup *biog, int id)
+{
+	struct ioband_device *dp;
+	struct ioband_group *head, *gp;
+	struct cgroup *cgrp = biog->css.cgroup;
+	char name[DM_NAME_LEN];
+
+	mutex_lock(&ioband_lock);
+	list_for_each_entry(dp, &ioband_device_list, g_list) {
+		list_for_each_entry(head, &dp->g_heads, c_heads) {
+			if (strcmp(head->c_type->t_name, "cgroup"))
+				continue;
+
+			if (cgrp == cgrp->top_cgroup)
+				gp = head;
+			else {
+				gp = ioband_group_find(head, id);
+				if (!gp)
+					continue;
+			}
+
+			ioband_copy_name(head, name);
+			seq_puts(m, name);
+			if (dp->g_show_group)
+				dp->g_show_group(m, gp);
+			seq_putc(m, '\n');
+		}
+	}
+	mutex_unlock(&ioband_lock);
+}
+
+/* Configure the specified blkio cgroup. */
+static int ioband_cgroup_config_group(int argc, char **argv,
+				      struct blkio_cgroup *biog, int id)
+{
+	struct ioband_device *dp;
+	struct ioband_group *head, *gp;
+	struct cgroup *cgrp = biog->css.cgroup;
+	char name[DM_NAME_LEN];
+	int r;
+
+	if (argc != 1 && argc != 2)
+		return -EINVAL;
+
+	mutex_lock(&ioband_lock);
+	list_for_each_entry(dp, &ioband_device_list, g_list) {
+		list_for_each_entry(head, &dp->g_heads, c_heads) {
+			if (strcmp(head->c_type->t_name, "cgroup"))
+				continue;
+			ioband_copy_name(head, name);
+			if (!strcmp(name, argv[0]))
+				goto found;
+		}
+	}
+	mutex_unlock(&ioband_lock);
+	return -ENODEV;
+
+found:
+	if (argc == 1) {
+		if (cgrp == cgrp->top_cgroup)
+			r = -EINVAL;
+		else
+			r = ioband_group_detach(head, id);
+	} else {
+		if (cgrp == cgrp->top_cgroup)
+			gp = head;
+		else
+			gp = ioband_group_find(head, id);
+
+		if (!gp)
+			r = ioband_group_attach(head, id, argv[1]);
+		else
+			r = gp->c_banddev->g_set_param(gp, NULL, argv[1]);
+	}
+
+	mutex_unlock(&ioband_lock);
+	return r;
+}
+
+/* Remove the specified blkio cgroup. */
+static void ioband_cgroup_remove_group(int id)
+{
+	struct ioband_device *dp;
+	struct ioband_group *head;
+
+	mutex_lock(&ioband_lock);
+	list_for_each_entry(dp, &ioband_device_list, g_list) {
+		list_for_each_entry(head, &dp->g_heads, c_heads) {
+			if (strcmp(head->c_type->t_name, "cgroup"))
+				continue;
+			ioband_group_detach(head, id);
+		}
+	}
+	mutex_unlock(&ioband_lock);
+}
+
+static const struct ioband_cgroup_ops ioband_ops = {
+	.show_device	= ioband_cgroup_show_device,
+	.config_device	= ioband_cgroup_config_device,
+	.show_group	= ioband_cgroup_show_group,
+	.config_group	= ioband_cgroup_config_group,
+	.remove_group	= ioband_cgroup_remove_group,
+};
+#endif
+
 static int __init dm_ioband_init(void)
 {
 	int r;
@@ -1304,11 +1496,18 @@ static int __init dm_ioband_init(void)
 	r = dm_register_target(&ioband_target);
 	if (r < 0)
 		DMERR("register failed %d", r);
+#ifdef CONFIG_CGROUP_BLKIO
+	else
+		r = blkio_cgroup_register_ioband(&ioband_ops);
+#endif
 	return r;
 }
 
 static void __exit dm_ioband_exit(void)
 {
+#ifdef CONFIG_CGROUP_BLKIO
+	blkio_cgroup_unregister_ioband();
+#endif
 	dm_unregister_target(&ioband_target);
 }
 
Index: linux-2.6.31-rc3-mm1/drivers/md/dm-ioband.h
===================================================================
--- linux-2.6.31-rc3-mm1.orig/drivers/md/dm-ioband.h
+++ linux-2.6.31-rc3-mm1/drivers/md/dm-ioband.h
@@ -44,6 +44,7 @@ struct ioband_device {
 
 	int g_ref;
 	struct list_head g_list;
+	struct list_head g_heads;
 	int g_flags;
 	char g_name[IOBAND_NAME_MAX + 1];
 	const struct ioband_policy_type *g_policy;
@@ -59,6 +60,8 @@ struct ioband_device {
 	int (*g_set_param) (struct ioband_group *, const char *, const char *);
 	int (*g_should_block) (struct ioband_group *);
 	void (*g_show) (struct ioband_group *, int *, char *, unsigned);
+	void (*g_show_device) (struct seq_file *, struct ioband_device *);
+	void (*g_show_group) (struct seq_file *, struct ioband_group *);
 
 	/* members for weight balancing policy */
 	int g_epoch;
@@ -104,6 +107,7 @@ struct ioband_group_stat {
 
 struct ioband_group {
 	struct list_head c_list;
+	struct list_head c_heads;
 	struct ioband_device *c_banddev;
 	struct dm_dev *c_dev;
 	struct dm_target *c_target;
@@ -150,6 +154,16 @@ struct ioband_group {
 
 };
 
+struct blkio_cgroup;
+
+struct ioband_cgroup_ops {
+	void (*show_device)(struct seq_file *);
+	int (*config_device)(int, char **);
+	void (*show_group)(struct seq_file *, struct blkio_cgroup *, int);
+	int (*config_group)(int, char **, struct blkio_cgroup *, int);
+	void (*remove_group)(int);
+};
+
 #define IOBAND_URGENT 1
 
 #define DEV_BIO_BLOCKED		1
Index: linux-2.6.31-rc3-mm1/drivers/md/dm-ioband-type.c
===================================================================
--- linux-2.6.31-rc3-mm1.orig/drivers/md/dm-ioband-type.c
+++ linux-2.6.31-rc3-mm1/drivers/md/dm-ioband-type.c
@@ -6,6 +6,7 @@
  * This file is released under the GPL.
  */
 #include <linux/bio.h>
+#include <linux/biotrack.h>
 #include "dm.h"
 #include "dm-ioband.h"
 
@@ -52,14 +53,7 @@ static int ioband_node(struct bio *bio)
 
 static int ioband_cgroup(struct bio *bio)
 {
-	/*
-	 * This function should return the ID of the cgroup which
-	 * issued "bio". The ID of the cgroup which the current
-	 * process belongs to won't be suitable ID for this purpose,
-	 * since some BIOs will be handled by kernel threads like aio
-	 * or pdflush on behalf of the process requesting the BIOs.
-	 */
-	return 0;	/* not implemented yet */
+	return get_blkio_cgroup_id(bio);
 }
 
 const struct ioband_group_type dm_ioband_group_type[] = {
