From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/12] cgroup: convert all non-memcg controllers to the new
	cftype interface
Date: Wed, 21 Mar 2012 15:17:39 -0700
Message-ID: <1332368265-21586-7-git-send-email-tj@kernel.org>
References: <1332368265-21586-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1332368265-21586-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Convert debug, freezer, cpuset, cpu_cgroup, cpuacct, net_prio, blkio,
net_cls and device controllers to use the new cftype based interface.
Termination entry is added to cftype arrays and populate callbacks are
replaced with cgroup_subsys->base_cftypes initializations.

This is functionally identical transformation.  There shouldn't be any
visible behavior change.

memcg is rather special and will be converted separately.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/blk-cgroup.c        |    9 ++-------
 kernel/cgroup.c           |   10 +++-------
 kernel/cgroup_freezer.c   |   11 +++--------
 kernel/cpuset.c           |   31 ++++++++++---------------------
 kernel/sched/core.c       |   16 ++++------------
 net/core/netprio_cgroup.c |    8 ++------
 net/sched/cls_cgroup.c    |    8 ++------
 security/device_cgroup.c  |   10 ++--------
 8 files changed, 28 insertions(+), 75 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index c0cbe8b..a13e189 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -1515,14 +1515,9 @@ struct cftype blkio_files[] = {
 		.read_map = blkiocg_file_read_map,
 	},
 #endif
+	{ }	/* terminate */
 };
 
-static int blkiocg_populate(struct cgroup_subsys *subsys, struct cgroup *cgroup)
-{
-	return cgroup_add_files(cgroup, subsys, blkio_files,
-				ARRAY_SIZE(blkio_files));
-}
-
 static void blkiocg_destroy(struct cgroup *cgroup)
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgroup);
@@ -1642,11 +1637,11 @@ struct cgroup_subsys blkio_subsys = {
 	.can_attach = blkiocg_can_attach,
 	.attach = blkiocg_attach,
 	.destroy = blkiocg_destroy,
-	.populate = blkiocg_populate,
 #ifdef CONFIG_BLK_CGROUP
 	/* note: blkio_subsys_id is otherwise defined in blk-cgroup.h */
 	.subsys_id = blkio_subsys_id,
 #endif
+	.base_cftypes = blkio_files,
 	.use_id = 1,
 	.module = THIS_MODULE,
 };
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 45657d1..d6fe34a 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5354,19 +5354,15 @@ static struct cftype debug_files[] =  {
 		.name = "releasable",
 		.read_u64 = releasable_read,
 	},
-};
 
-static int debug_populate(struct cgroup_subsys *ss, struct cgroup *cont)
-{
-	return cgroup_add_files(cont, ss, debug_files,
-				ARRAY_SIZE(debug_files));
-}
+	{ }	/* terminate */
+};
 
 struct cgroup_subsys debug_subsys = {
 	.name = "debug",
 	.create = debug_create,
 	.destroy = debug_destroy,
-	.populate = debug_populate,
 	.subsys_id = debug_subsys_id,
+	.base_cftypes = debug_files,
 };
 #endif /* CONFIG_CGROUP_DEBUG */
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index f86e939..3649fc6 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -358,24 +358,19 @@ static int freezer_write(struct cgroup *cgroup,
 static struct cftype files[] = {
 	{
 		.name = "state",
+		.flags = CFTYPE_NOT_ON_ROOT,
 		.read_seq_string = freezer_read,
 		.write_string = freezer_write,
 	},
+	{ }	/* terminate */
 };
 
-static int freezer_populate(struct cgroup_subsys *ss, struct cgroup *cgroup)
-{
-	if (!cgroup->parent)
-		return 0;
-	return cgroup_add_files(cgroup, ss, files, ARRAY_SIZE(files));
-}
-
 struct cgroup_subsys freezer_subsys = {
 	.name		= "freezer",
 	.create		= freezer_create,
 	.destroy	= freezer_destroy,
-	.populate	= freezer_populate,
 	.subsys_id	= freezer_subsys_id,
 	.can_attach	= freezer_can_attach,
 	.fork		= freezer_fork,
+	.base_cftypes	= files,
 };
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 5d57583..81cf9b7 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1792,28 +1792,17 @@ static struct cftype files[] = {
 		.write_u64 = cpuset_write_u64,
 		.private = FILE_SPREAD_SLAB,
 	},
-};
-
-static struct cftype cft_memory_pressure_enabled = {
-	.name = "memory_pressure_enabled",
-	.read_u64 = cpuset_read_u64,
-	.write_u64 = cpuset_write_u64,
-	.private = FILE_MEMORY_PRESSURE_ENABLED,
-};
 
-static int cpuset_populate(struct cgroup_subsys *ss, struct cgroup *cont)
-{
-	int err;
+	{
+		.name = "memory_pressure_enabled",
+		.flags = CFTYPE_ONLY_ON_ROOT,
+		.read_u64 = cpuset_read_u64,
+		.write_u64 = cpuset_write_u64,
+		.private = FILE_MEMORY_PRESSURE_ENABLED,
+	},
 
-	err = cgroup_add_files(cont, ss, files, ARRAY_SIZE(files));
-	if (err)
-		return err;
-	/* memory_pressure_enabled is in root cpuset only */
-	if (!cont->parent)
-		err = cgroup_add_file(cont, ss,
-				      &cft_memory_pressure_enabled);
-	return err;
-}
+	{ }	/* terminate */
+};
 
 /*
  * post_clone() is called during cgroup_create() when the
@@ -1914,9 +1903,9 @@ struct cgroup_subsys cpuset_subsys = {
 	.destroy = cpuset_destroy,
 	.can_attach = cpuset_can_attach,
 	.attach = cpuset_attach,
-	.populate = cpuset_populate,
 	.post_clone = cpuset_post_clone,
 	.subsys_id = cpuset_subsys_id,
+	.base_cftypes = files,
 	.early_init = 1,
 };
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index ff12f72..90815b5 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7902,13 +7902,9 @@ static struct cftype cpu_files[] = {
 		.write_u64 = cpu_rt_period_write_uint,
 	},
 #endif
+	{ }	/* terminate */
 };
 
-static int cpu_cgroup_populate(struct cgroup_subsys *ss, struct cgroup *cont)
-{
-	return cgroup_add_files(cont, ss, cpu_files, ARRAY_SIZE(cpu_files));
-}
-
 struct cgroup_subsys cpu_cgroup_subsys = {
 	.name		= "cpu",
 	.create		= cpu_cgroup_create,
@@ -7916,8 +7912,8 @@ struct cgroup_subsys cpu_cgroup_subsys = {
 	.can_attach	= cpu_cgroup_can_attach,
 	.attach		= cpu_cgroup_attach,
 	.exit		= cpu_cgroup_exit,
-	.populate	= cpu_cgroup_populate,
 	.subsys_id	= cpu_cgroup_subsys_id,
+	.base_cftypes	= cpu_files,
 	.early_init	= 1,
 };
 
@@ -8102,13 +8098,9 @@ static struct cftype files[] = {
 		.name = "stat",
 		.read_map = cpuacct_stats_show,
 	},
+	{ }	/* terminate */
 };
 
-static int cpuacct_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
-{
-	return cgroup_add_files(cgrp, ss, files, ARRAY_SIZE(files));
-}
-
 /*
  * charge this task's execution time to its accounting group.
  *
@@ -8140,7 +8132,7 @@ struct cgroup_subsys cpuacct_subsys = {
 	.name = "cpuacct",
 	.create = cpuacct_create,
 	.destroy = cpuacct_destroy,
-	.populate = cpuacct_populate,
 	.subsys_id = cpuacct_subsys_id,
+	.base_cftypes = files,
 };
 #endif	/* CONFIG_CGROUP_CPUACCT */
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index c802613..aa1d391 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -241,21 +241,17 @@ static struct cftype ss_files[] = {
 		.read_map = read_priomap,
 		.write_string = write_priomap,
 	},
+	{ }	/* terminate */
 };
 
-static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
-{
-	return cgroup_add_files(cgrp, ss, ss_files, ARRAY_SIZE(ss_files));
-}
-
 struct cgroup_subsys net_prio_subsys = {
 	.name		= "net_prio",
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
-	.populate	= cgrp_populate,
 #ifdef CONFIG_NETPRIO_CGROUP
 	.subsys_id	= net_prio_subsys_id,
 #endif
+	.base_cftypes	= ss_files,
 	.module		= THIS_MODULE
 };
 
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 024df8a..7743ea8 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -70,21 +70,17 @@ static struct cftype ss_files[] = {
 		.read_u64 = read_classid,
 		.write_u64 = write_classid,
 	},
+	{ }	/* terminate */
 };
 
-static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
-{
-	return cgroup_add_files(cgrp, ss, ss_files, ARRAY_SIZE(ss_files));
-}
-
 struct cgroup_subsys net_cls_subsys = {
 	.name		= "net_cls",
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
-	.populate	= cgrp_populate,
 #ifdef CONFIG_NET_CLS_CGROUP
 	.subsys_id	= net_cls_subsys_id,
 #endif
+	.base_cftypes	= ss_files,
 	.module		= THIS_MODULE,
 };
 
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index c43a332..442204c 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -447,22 +447,16 @@ static struct cftype dev_cgroup_files[] = {
 		.read_seq_string = devcgroup_seq_read,
 		.private = DEVCG_LIST,
 	},
+	{ }	/* terminate */
 };
 
-static int devcgroup_populate(struct cgroup_subsys *ss,
-				struct cgroup *cgroup)
-{
-	return cgroup_add_files(cgroup, ss, dev_cgroup_files,
-					ARRAY_SIZE(dev_cgroup_files));
-}
-
 struct cgroup_subsys devices_subsys = {
 	.name = "devices",
 	.can_attach = devcgroup_can_attach,
 	.create = devcgroup_create,
 	.destroy = devcgroup_destroy,
-	.populate = devcgroup_populate,
 	.subsys_id = devices_subsys_id,
+	.base_cftypes = dev_cgroup_files,
 };
 
 int __devcgroup_inode_permission(struct inode *inode, int mask)
-- 
1.7.7.3
