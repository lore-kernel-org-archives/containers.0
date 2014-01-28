From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/6] cgroup: clean up cgroup_subsys names and initialization
Date: Tue, 28 Jan 2014 18:43:58 -0500
Message-ID: <1390952641-15950-4-git-send-email-tj@kernel.org>
References: <1390952641-15950-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390952641-15950-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_subsys is a bit messier than it needs to be.

* The name of a subsys can be different from its internal identifier
  defined in cgroup_subsys.h.  Most subsystems use the matching name
  but three - cpu, memory and perf_event - use different ones.

* cgroup_subsys_id enums are postfixed with _subsys_id and each
  cgroup_subsys is postfixed with _subsys.  cgroup.h is widely
  included throughout various subsystems, it doesn't and shouldn't
  have claim on such generic names which don't have any qualifier
  indicating that they belong to cgroup.

* cgroup_subsys->subsys_id should always equal the matching
  cgroup_subsys_id enum; however, we require each controller to
  initialize it and then BUG if they don't match, which is a bit
  silly.

This patch cleans up cgroup_subsys names and initialization by doing
the followings.

* cgroup_subsys_id enums are now postfixed with _cgrp_id, and each
  cgroup_subsys with _cgrp_subsys.

* With the above, renaming subsys identifiers to match the userland
  visible names doesn't cause any naming conflicts.  All non-matching
  identifiers are renamed to match the official names.

  cpu_cgroup -> cpu
  mem_cgroup -> memory
  perf -> perf_event

* controllers no longer need to initialize ->subsys_id and ->name.
  They're generated in cgroup core and set automatically during boot.

* Redundant cgroup_subsys declarations removed.

* While updating BUG_ON()s in cgroup_init_early(), convert them to
  WARN()s.  BUGging that early during boot is stupid - the kernel
  can't print anything, even through serial console and the trap
  handler doesn't even link stack frame properly for back-tracing.

This patch doesn't introduce any behavior changes.

v2: Rebased on top of fe1217c4f3f7 ("net: net_cls: move cgroupfs
    classid handling into core").

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Acked-by: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
---
 block/blk-cgroup.c             |  8 +++-----
 block/blk-cgroup.h             |  2 +-
 fs/bio.c                       |  2 +-
 include/linux/cgroup.h         |  7 ++++---
 include/linux/cgroup_subsys.h  |  6 +++---
 include/linux/hugetlb_cgroup.h |  2 +-
 include/linux/memcontrol.h     |  2 +-
 include/net/cls_cgroup.h       |  2 +-
 include/net/netprio_cgroup.h   |  2 +-
 kernel/cgroup.c                | 34 ++++++++++++++++++++--------------
 kernel/cgroup_freezer.c        |  8 ++------
 kernel/cpuset.c                | 10 ++++------
 kernel/events/core.c           |  8 +++-----
 kernel/sched/core.c            |  6 ++----
 kernel/sched/cpuacct.c         |  6 ++----
 mm/hugetlb_cgroup.c            |  9 +++------
 mm/memcontrol.c                | 22 ++++++++++------------
 net/core/netclassid_cgroup.c   |  6 ++----
 net/core/netprio_cgroup.c      |  4 +---
 net/ipv4/tcp_memcontrol.c      |  2 +-
 security/device_cgroup.c       |  8 ++------
 21 files changed, 68 insertions(+), 88 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 660d419..1cef07c 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -906,16 +906,14 @@ static int blkcg_can_attach(struct cgroup_subsys_state *css,
 	return ret;
 }
 
-struct cgroup_subsys blkio_subsys = {
-	.name = "blkio",
+struct cgroup_subsys blkio_cgrp_subsys = {
 	.css_alloc = blkcg_css_alloc,
 	.css_offline = blkcg_css_offline,
 	.css_free = blkcg_css_free,
 	.can_attach = blkcg_can_attach,
-	.subsys_id = blkio_subsys_id,
 	.base_cftypes = blkcg_files,
 };
-EXPORT_SYMBOL_GPL(blkio_subsys);
+EXPORT_SYMBOL_GPL(blkio_cgrp_subsys);
 
 /**
  * blkcg_activate_policy - activate a blkcg policy on a request_queue
@@ -1105,7 +1103,7 @@ int blkcg_policy_register(struct blkcg_policy *pol)
 
 	/* everything is in place, add intf files for the new policy */
 	if (pol->cftypes)
-		WARN_ON(cgroup_add_cftypes(&blkio_subsys, pol->cftypes));
+		WARN_ON(cgroup_add_cftypes(&blkio_cgrp_subsys, pol->cftypes));
 	ret = 0;
 out_unlock:
 	mutex_unlock(&blkcg_pol_mutex);
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 86154ea..453b528 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -186,7 +186,7 @@ static inline struct blkcg *css_to_blkcg(struct cgroup_subsys_state *css)
 
 static inline struct blkcg *task_blkcg(struct task_struct *tsk)
 {
-	return css_to_blkcg(task_css(tsk, blkio_subsys_id));
+	return css_to_blkcg(task_css(tsk, blkio_cgrp_id));
 }
 
 static inline struct blkcg *bio_blkcg(struct bio *bio)
diff --git a/fs/bio.c b/fs/bio.c
index 33d79a4..26a62d7 100644
--- a/fs/bio.c
+++ b/fs/bio.c
@@ -2002,7 +2002,7 @@ int bio_associate_current(struct bio *bio)
 
 	/* associate blkcg if exists */
 	rcu_read_lock();
-	css = task_css(current, blkio_subsys_id);
+	css = task_css(current, blkio_cgrp_id);
 	if (css && css_tryget(css))
 		bio->bi_css = css;
 	rcu_read_unlock();
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index d842a73..cd6611e 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -41,7 +41,7 @@ extern int cgroupstats_build(struct cgroupstats *stats,
 extern int proc_cgroup_show(struct seq_file *, void *);
 
 /* define the enumeration of all cgroup subsystems */
-#define SUBSYS(_x) _x ## _subsys_id,
+#define SUBSYS(_x) _x ## _cgrp_id,
 enum cgroup_subsys_id {
 #include <linux/cgroup_subsys.h>
 	CGROUP_SUBSYS_COUNT,
@@ -573,7 +573,6 @@ struct cgroup_subsys {
 		     struct task_struct *task);
 	void (*bind)(struct cgroup_subsys_state *root_css);
 
-	int subsys_id;
 	int disabled;
 	int early_init;
 
@@ -592,6 +591,8 @@ struct cgroup_subsys {
 	bool broken_hierarchy;
 	bool warned_broken_hierarchy;
 
+	/* the following two fields are initialized automtically during boot */
+	int subsys_id;
 #define MAX_CGROUP_TYPE_NAMELEN 32
 	const char *name;
 
@@ -606,7 +607,7 @@ struct cgroup_subsys {
 	struct cftype_set base_cftset;
 };
 
-#define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
+#define SUBSYS(_x) extern struct cgroup_subsys _x ## _cgrp_subsys;
 #include <linux/cgroup_subsys.h>
 #undef SUBSYS
 
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 11c42f6..768fe44 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -12,7 +12,7 @@ SUBSYS(debug)
 #endif
 
 #if IS_ENABLED(CONFIG_CGROUP_SCHED)
-SUBSYS(cpu_cgroup)
+SUBSYS(cpu)
 #endif
 
 #if IS_ENABLED(CONFIG_CGROUP_CPUACCT)
@@ -20,7 +20,7 @@ SUBSYS(cpuacct)
 #endif
 
 #if IS_ENABLED(CONFIG_MEMCG)
-SUBSYS(mem_cgroup)
+SUBSYS(memory)
 #endif
 
 #if IS_ENABLED(CONFIG_CGROUP_DEVICE)
@@ -40,7 +40,7 @@ SUBSYS(blkio)
 #endif
 
 #if IS_ENABLED(CONFIG_CGROUP_PERF)
-SUBSYS(perf)
+SUBSYS(perf_event)
 #endif
 
 #if IS_ENABLED(CONFIG_CGROUP_NET_PRIO)
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index 787bba3..0129f89 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -49,7 +49,7 @@ int set_hugetlb_cgroup(struct page *page, struct hugetlb_cgroup *h_cg)
 
 static inline bool hugetlb_cgroup_disabled(void)
 {
-	if (hugetlb_subsys.disabled)
+	if (hugetlb_cgrp_subsys.disabled)
 		return true;
 	return false;
 }
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index abd0113..eccfb4a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -162,7 +162,7 @@ extern int do_swap_account;
 
 static inline bool mem_cgroup_disabled(void)
 {
-	if (mem_cgroup_subsys.disabled)
+	if (memory_cgrp_subsys.disabled)
 		return true;
 	return false;
 }
diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 9cf2d5e..c15d394 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -34,7 +34,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
 		return 0;
 
 	rcu_read_lock();
-	classid = container_of(task_css(p, net_cls_subsys_id),
+	classid = container_of(task_css(p, net_cls_cgrp_id),
 			       struct cgroup_cls_state, css)->classid;
 	rcu_read_unlock();
 
diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index b7ff5bd..f2a9597 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -33,7 +33,7 @@ static inline u32 task_netprioidx(struct task_struct *p)
 	u32 idx;
 
 	rcu_read_lock();
-	css = task_css(p, net_prio_subsys_id);
+	css = task_css(p, net_prio_cgrp_id);
 	idx = css->cgroup->id;
 	rcu_read_unlock();
 	return idx;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 81ce64a..6734cfa 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -120,10 +120,18 @@ static struct workqueue_struct *cgroup_destroy_wq;
 static struct workqueue_struct *cgroup_pidlist_destroy_wq;
 
 /* generate an array of cgroup subsystem pointers */
-#define SUBSYS(_x) [_x ## _subsys_id] = &_x ## _subsys,
+#define SUBSYS(_x) [_x ## _cgrp_id] = &_x ## _cgrp_subsys,
 static struct cgroup_subsys *cgroup_subsys[] = {
 #include <linux/cgroup_subsys.h>
 };
+#undef SUBSYS
+
+/* array of cgroup subsystem names */
+#define SUBSYS(_x) [_x ## _cgrp_id] = #_x,
+static const char *cgroup_subsys_name[] = {
+#include <linux/cgroup_subsys.h>
+};
+#undef SUBSYS
 
 /*
  * The dummy hierarchy, reserved for the subsystems that are otherwise
@@ -1076,7 +1084,7 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 	BUG_ON(!mutex_is_locked(&cgroup_mutex));
 
 #ifdef CONFIG_CPUSETS
-	mask = ~(1UL << cpuset_subsys_id);
+	mask = ~(1UL << cpuset_cgrp_id);
 #endif
 
 	memset(opts, 0, sizeof(*opts));
@@ -4518,15 +4526,15 @@ int __init cgroup_init_early(void)
 	list_add(&init_cgrp_cset_link.cgrp_link, &init_css_set.cgrp_links);
 
 	for_each_subsys(ss, i) {
-		BUG_ON(!ss->name);
-		BUG_ON(strlen(ss->name) > MAX_CGROUP_TYPE_NAMELEN);
-		BUG_ON(!ss->css_alloc);
-		BUG_ON(!ss->css_free);
-		if (ss->subsys_id != i) {
-			printk(KERN_ERR "cgroup: Subsys %s id == %d\n",
-			       ss->name, ss->subsys_id);
-			BUG();
-		}
+		WARN(!ss->css_alloc || !ss->css_free || ss->name || ss->subsys_id,
+		     "invalid cgroup_subsys %d:%s css_alloc=%p css_free=%p name:id=%d:%s\n",
+		     i, cgroup_subsys_name[i], ss->css_alloc, ss->css_free,
+		     ss->subsys_id, ss->name);
+		WARN(strlen(cgroup_subsys_name[i]) > MAX_CGROUP_TYPE_NAMELEN,
+		     "cgroup_subsys_name %s too long\n", cgroup_subsys_name[i]);
+
+		ss->subsys_id = i;
+		ss->name = cgroup_subsys_name[i];
 
 		if (ss->early_init)
 			cgroup_init_subsys(ss);
@@ -5156,11 +5164,9 @@ static struct cftype debug_files[] =  {
 	{ }	/* terminate */
 };
 
-struct cgroup_subsys debug_subsys = {
-	.name = "debug",
+struct cgroup_subsys debug_cgrp_subsys = {
 	.css_alloc = debug_css_alloc,
 	.css_free = debug_css_free,
-	.subsys_id = debug_subsys_id,
 	.base_cftypes = debug_files,
 };
 #endif /* CONFIG_CGROUP_DEBUG */
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 6c3154e..98ea26a9 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -52,7 +52,7 @@ static inline struct freezer *css_freezer(struct cgroup_subsys_state *css)
 
 static inline struct freezer *task_freezer(struct task_struct *task)
 {
-	return css_freezer(task_css(task, freezer_subsys_id));
+	return css_freezer(task_css(task, freezer_cgrp_id));
 }
 
 static struct freezer *parent_freezer(struct freezer *freezer)
@@ -84,8 +84,6 @@ static const char *freezer_state_strs(unsigned int state)
 	return "THAWED";
 };
 
-struct cgroup_subsys freezer_subsys;
-
 static struct cgroup_subsys_state *
 freezer_css_alloc(struct cgroup_subsys_state *parent_css)
 {
@@ -473,13 +471,11 @@ static struct cftype files[] = {
 	{ }	/* terminate */
 };
 
-struct cgroup_subsys freezer_subsys = {
-	.name		= "freezer",
+struct cgroup_subsys freezer_cgrp_subsys = {
 	.css_alloc	= freezer_css_alloc,
 	.css_online	= freezer_css_online,
 	.css_offline	= freezer_css_offline,
 	.css_free	= freezer_css_free,
-	.subsys_id	= freezer_subsys_id,
 	.attach		= freezer_attach,
 	.fork		= freezer_fork,
 	.base_cftypes	= files,
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 4410ac6..2d018c7 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -119,7 +119,7 @@ static inline struct cpuset *css_cs(struct cgroup_subsys_state *css)
 /* Retrieve the cpuset for a task */
 static inline struct cpuset *task_cs(struct task_struct *task)
 {
-	return css_cs(task_css(task, cpuset_subsys_id));
+	return css_cs(task_css(task, cpuset_cgrp_id));
 }
 
 static inline struct cpuset *parent_cs(struct cpuset *cs)
@@ -1521,7 +1521,7 @@ static void cpuset_attach(struct cgroup_subsys_state *css,
 	struct task_struct *task;
 	struct task_struct *leader = cgroup_taskset_first(tset);
 	struct cgroup_subsys_state *oldcss = cgroup_taskset_cur_css(tset,
-							cpuset_subsys_id);
+							cpuset_cgrp_id);
 	struct cpuset *cs = css_cs(css);
 	struct cpuset *oldcs = css_cs(oldcss);
 	struct cpuset *cpus_cs = effective_cpumask_cpuset(cs);
@@ -2024,8 +2024,7 @@ static void cpuset_css_free(struct cgroup_subsys_state *css)
 	kfree(cs);
 }
 
-struct cgroup_subsys cpuset_subsys = {
-	.name = "cpuset",
+struct cgroup_subsys cpuset_cgrp_subsys = {
 	.css_alloc = cpuset_css_alloc,
 	.css_online = cpuset_css_online,
 	.css_offline = cpuset_css_offline,
@@ -2033,7 +2032,6 @@ struct cgroup_subsys cpuset_subsys = {
 	.can_attach = cpuset_can_attach,
 	.cancel_attach = cpuset_cancel_attach,
 	.attach = cpuset_attach,
-	.subsys_id = cpuset_subsys_id,
 	.base_cftypes = files,
 	.early_init = 1,
 };
@@ -2699,7 +2697,7 @@ int proc_cpuset_show(struct seq_file *m, void *unused_v)
 		goto out_free;
 
 	rcu_read_lock();
-	css = task_css(tsk, cpuset_subsys_id);
+	css = task_css(tsk, cpuset_cgrp_id);
 	retval = cgroup_path(css->cgroup, buf, PAGE_SIZE);
 	rcu_read_unlock();
 	if (retval < 0)
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 56003c6..6490373 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -342,7 +342,7 @@ struct perf_cgroup {
 static inline struct perf_cgroup *
 perf_cgroup_from_task(struct task_struct *task)
 {
-	return container_of(task_css(task, perf_subsys_id),
+	return container_of(task_css(task, perf_event_cgrp_id),
 			    struct perf_cgroup, css);
 }
 
@@ -595,7 +595,7 @@ static inline int perf_cgroup_connect(int fd, struct perf_event *event,
 
 	rcu_read_lock();
 
-	css = css_from_dir(f.file->f_dentry, &perf_subsys);
+	css = css_from_dir(f.file->f_dentry, &perf_event_cgrp_subsys);
 	if (IS_ERR(css)) {
 		ret = PTR_ERR(css);
 		goto out;
@@ -8055,9 +8055,7 @@ static void perf_cgroup_exit(struct cgroup_subsys_state *css,
 	task_function_call(task, __perf_cgroup_move, task);
 }
 
-struct cgroup_subsys perf_subsys = {
-	.name		= "perf_event",
-	.subsys_id	= perf_subsys_id,
+struct cgroup_subsys perf_event_cgrp_subsys = {
 	.css_alloc	= perf_cgroup_css_alloc,
 	.css_free	= perf_cgroup_css_free,
 	.exit		= perf_cgroup_exit,
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 7fea865..436ba19 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7174,7 +7174,7 @@ void sched_move_task(struct task_struct *tsk)
 	if (unlikely(running))
 		tsk->sched_class->put_prev_task(rq, tsk);
 
-	tg = container_of(task_css_check(tsk, cpu_cgroup_subsys_id,
+	tg = container_of(task_css_check(tsk, cpu_cgrp_id,
 				lockdep_is_held(&tsk->sighand->siglock)),
 			  struct task_group, css);
 	tg = autogroup_task_group(tsk, tg);
@@ -7955,8 +7955,7 @@ static struct cftype cpu_files[] = {
 	{ }	/* terminate */
 };
 
-struct cgroup_subsys cpu_cgroup_subsys = {
-	.name		= "cpu",
+struct cgroup_subsys cpu_cgrp_subsys = {
 	.css_alloc	= cpu_cgroup_css_alloc,
 	.css_free	= cpu_cgroup_css_free,
 	.css_online	= cpu_cgroup_css_online,
@@ -7964,7 +7963,6 @@ struct cgroup_subsys cpu_cgroup_subsys = {
 	.can_attach	= cpu_cgroup_can_attach,
 	.attach		= cpu_cgroup_attach,
 	.exit		= cpu_cgroup_exit,
-	.subsys_id	= cpu_cgroup_subsys_id,
 	.base_cftypes	= cpu_files,
 	.early_init	= 1,
 };
diff --git a/kernel/sched/cpuacct.c b/kernel/sched/cpuacct.c
index 622e081..c143ee3 100644
--- a/kernel/sched/cpuacct.c
+++ b/kernel/sched/cpuacct.c
@@ -41,7 +41,7 @@ static inline struct cpuacct *css_ca(struct cgroup_subsys_state *css)
 /* return cpu accounting group to which this task belongs */
 static inline struct cpuacct *task_ca(struct task_struct *tsk)
 {
-	return css_ca(task_css(tsk, cpuacct_subsys_id));
+	return css_ca(task_css(tsk, cpuacct_cgrp_id));
 }
 
 static inline struct cpuacct *parent_ca(struct cpuacct *ca)
@@ -275,11 +275,9 @@ void cpuacct_account_field(struct task_struct *p, int index, u64 val)
 	rcu_read_unlock();
 }
 
-struct cgroup_subsys cpuacct_subsys = {
-	.name		= "cpuacct",
+struct cgroup_subsys cpuacct_cgrp_subsys = {
 	.css_alloc	= cpuacct_css_alloc,
 	.css_free	= cpuacct_css_free,
-	.subsys_id	= cpuacct_subsys_id,
 	.base_cftypes	= files,
 	.early_init	= 1,
 };
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index cb00829..b135853 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -30,7 +30,6 @@ struct hugetlb_cgroup {
 #define MEMFILE_IDX(val)	(((val) >> 16) & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
 
-struct cgroup_subsys hugetlb_subsys __read_mostly;
 static struct hugetlb_cgroup *root_h_cgroup __read_mostly;
 
 static inline
@@ -42,7 +41,7 @@ struct hugetlb_cgroup *hugetlb_cgroup_from_css(struct cgroup_subsys_state *s)
 static inline
 struct hugetlb_cgroup *hugetlb_cgroup_from_task(struct task_struct *task)
 {
-	return hugetlb_cgroup_from_css(task_css(task, hugetlb_subsys_id));
+	return hugetlb_cgroup_from_css(task_css(task, hugetlb_cgrp_id));
 }
 
 static inline bool hugetlb_cgroup_is_root(struct hugetlb_cgroup *h_cg)
@@ -358,7 +357,7 @@ static void __init __hugetlb_cgroup_file_init(int idx)
 	cft = &h->cgroup_files[4];
 	memset(cft, 0, sizeof(*cft));
 
-	WARN_ON(cgroup_add_cftypes(&hugetlb_subsys, h->cgroup_files));
+	WARN_ON(cgroup_add_cftypes(&hugetlb_cgrp_subsys, h->cgroup_files));
 
 	return;
 }
@@ -402,10 +401,8 @@ void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
 	return;
 }
 
-struct cgroup_subsys hugetlb_subsys = {
-	.name = "hugetlb",
+struct cgroup_subsys hugetlb_cgrp_subsys = {
 	.css_alloc	= hugetlb_cgroup_css_alloc,
 	.css_offline	= hugetlb_cgroup_css_offline,
 	.css_free	= hugetlb_cgroup_css_free,
-	.subsys_id	= hugetlb_subsys_id,
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 19d5d42..d4a8c40 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -66,8 +66,8 @@
 
 #include <trace/events/vmscan.h>
 
-struct cgroup_subsys mem_cgroup_subsys __read_mostly;
-EXPORT_SYMBOL(mem_cgroup_subsys);
+struct cgroup_subsys memory_cgrp_subsys __read_mostly;
+EXPORT_SYMBOL(memory_cgrp_subsys);
 
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 static struct mem_cgroup *root_mem_cgroup __read_mostly;
@@ -538,7 +538,7 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 {
 	struct cgroup_subsys_state *css;
 
-	css = css_from_id(id - 1, &mem_cgroup_subsys);
+	css = css_from_id(id - 1, &memory_cgrp_subsys);
 	return mem_cgroup_from_css(css);
 }
 
@@ -1072,7 +1072,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 	if (unlikely(!p))
 		return NULL;
 
-	return mem_cgroup_from_css(task_css(p, mem_cgroup_subsys_id));
+	return mem_cgroup_from_css(task_css(p, memory_cgrp_id));
 }
 
 struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
@@ -1702,7 +1702,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 	rcu_read_lock();
 
 	mem_cgrp = memcg->css.cgroup;
-	task_cgrp = task_cgroup(p, mem_cgroup_subsys_id);
+	task_cgrp = task_cgroup(p, memory_cgrp_id);
 
 	ret = cgroup_path(task_cgrp, memcg_name, PATH_MAX);
 	if (ret < 0) {
@@ -6188,7 +6188,7 @@ static int memcg_write_event_control(struct cgroup_subsys_state *css,
 
 	ret = -EINVAL;
 	cfile_css = css_from_dir(cfile.file->f_dentry->d_parent,
-				 &mem_cgroup_subsys);
+				 &memory_cgrp_subsys);
 	if (cfile_css == css && css_tryget(css))
 		ret = 0;
 
@@ -6567,11 +6567,11 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		 * unfortunate state in our controller.
 		 */
 		if (parent != root_mem_cgroup)
-			mem_cgroup_subsys.broken_hierarchy = true;
+			memory_cgrp_subsys.broken_hierarchy = true;
 	}
 	mutex_unlock(&memcg_create_mutex);
 
-	return memcg_init_kmem(memcg, &mem_cgroup_subsys);
+	return memcg_init_kmem(memcg, &memory_cgrp_subsys);
 }
 
 /*
@@ -7265,9 +7265,7 @@ static void mem_cgroup_bind(struct cgroup_subsys_state *root_css)
 		mem_cgroup_from_css(root_css)->use_hierarchy = true;
 }
 
-struct cgroup_subsys mem_cgroup_subsys = {
-	.name = "memory",
-	.subsys_id = mem_cgroup_subsys_id,
+struct cgroup_subsys memory_cgrp_subsys = {
 	.css_alloc = mem_cgroup_css_alloc,
 	.css_online = mem_cgroup_css_online,
 	.css_offline = mem_cgroup_css_offline,
@@ -7293,7 +7291,7 @@ __setup("swapaccount=", enable_swap_account);
 
 static void __init memsw_file_init(void)
 {
-	WARN_ON(cgroup_add_cftypes(&mem_cgroup_subsys, memsw_cgroup_files));
+	WARN_ON(cgroup_add_cftypes(&memory_cgrp_subsys, memsw_cgroup_files));
 }
 
 static void __init enable_swap_cgroup(void)
diff --git a/net/core/netclassid_cgroup.c b/net/core/netclassid_cgroup.c
index 9e5ad5d..b865662 100644
--- a/net/core/netclassid_cgroup.c
+++ b/net/core/netclassid_cgroup.c
@@ -23,7 +23,7 @@ static inline struct cgroup_cls_state *css_cls_state(struct cgroup_subsys_state
 
 struct cgroup_cls_state *task_cls_state(struct task_struct *p)
 {
-	return css_cls_state(task_css(p, net_cls_subsys_id));
+	return css_cls_state(task_css(p, net_cls_cgrp_id));
 }
 EXPORT_SYMBOL_GPL(task_cls_state);
 
@@ -102,12 +102,10 @@ static struct cftype ss_files[] = {
 	{ }	/* terminate */
 };
 
-struct cgroup_subsys net_cls_subsys = {
-	.name			= "net_cls",
+struct cgroup_subsys net_cls_cgrp_subsys = {
 	.css_alloc		= cgrp_css_alloc,
 	.css_online		= cgrp_css_online,
 	.css_free		= cgrp_css_free,
 	.attach			= cgrp_attach,
-	.subsys_id		= net_cls_subsys_id,
 	.base_cftypes		= ss_files,
 };
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 857e160..d7d23e2 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -244,13 +244,11 @@ static struct cftype ss_files[] = {
 	{ }	/* terminate */
 };
 
-struct cgroup_subsys net_prio_subsys = {
-	.name		= "net_prio",
+struct cgroup_subsys net_prio_cgrp_subsys = {
 	.css_alloc	= cgrp_css_alloc,
 	.css_online	= cgrp_css_online,
 	.css_free	= cgrp_css_free,
 	.attach		= net_prio_attach,
-	.subsys_id	= net_prio_subsys_id,
 	.base_cftypes	= ss_files,
 };
 
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index f7e522c..20a0aca 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -219,7 +219,7 @@ static struct cftype tcp_files[] = {
 
 static int __init tcp_memcontrol_init(void)
 {
-	WARN_ON(cgroup_add_cftypes(&mem_cgroup_subsys, tcp_files));
+	WARN_ON(cgroup_add_cftypes(&memory_cgrp_subsys, tcp_files));
 	return 0;
 }
 __initcall(tcp_memcontrol_init);
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index d3b6d2c..7f88bcd 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -58,11 +58,9 @@ static inline struct dev_cgroup *css_to_devcgroup(struct cgroup_subsys_state *s)
 
 static inline struct dev_cgroup *task_devcgroup(struct task_struct *task)
 {
-	return css_to_devcgroup(task_css(task, devices_subsys_id));
+	return css_to_devcgroup(task_css(task, devices_cgrp_id));
 }
 
-struct cgroup_subsys devices_subsys;
-
 /*
  * called under devcgroup_mutex
  */
@@ -684,13 +682,11 @@ static struct cftype dev_cgroup_files[] = {
 	{ }	/* terminate */
 };
 
-struct cgroup_subsys devices_subsys = {
-	.name = "devices",
+struct cgroup_subsys devices_cgrp_subsys = {
 	.css_alloc = devcgroup_css_alloc,
 	.css_free = devcgroup_css_free,
 	.css_online = devcgroup_online,
 	.css_offline = devcgroup_offline,
-	.subsys_id = devices_subsys_id,
 	.base_cftypes = dev_cgroup_files,
 };
 
-- 
1.8.5.3
