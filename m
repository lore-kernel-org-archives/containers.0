From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/23] cgroup: add/update accessors which obtain subsys
	specific data from css
Date: Thu,  1 Aug 2013 17:49:44 -0400
Message-ID: <1375393801-4817-7-git-send-email-tj@kernel.org>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375393801-4817-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

css (cgroup_subsys_state) is usually embedded in a subsys specific
data structure.  Subsystems either use container_of() directly to cast
from css to such data structure or has an accessor function wrapping
such cast.  As cgroup as whole is moving towards using css as the main
interface handle, add and update such accessors to ease dealing with
css's.

All accessors explicitly handle NULL input and return NULL in those
cases.  While this looks like an extra branch in the code, as all
controllers specific data structures have css as the first field, the
casting doesn't involve any offsetting and the compiler can trivially
optimize out the branch.

* blkio, freezer, cpuset, cpu, cpuacct and net_cls didn't have such
  accessor.  Added.

* memory, hugetlb and devices already had one but didn't explicitly
  handle NULL input.  Updated.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.h       | 12 ++++++++----
 kernel/cgroup_freezer.c  | 11 +++++++----
 kernel/cpuset.c          | 11 +++++++----
 kernel/sched/core.c      |  8 ++++++--
 kernel/sched/cpuacct.c   | 11 +++++++----
 mm/hugetlb_cgroup.c      |  2 +-
 mm/memcontrol.c          |  2 +-
 net/sched/cls_cgroup.c   | 11 +++++++----
 security/device_cgroup.c |  2 +-
 9 files changed, 45 insertions(+), 25 deletions(-)

diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 628e50f..8e5863e 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -179,21 +179,25 @@ int blkg_conf_prep(struct blkcg *blkcg, const struct blkcg_policy *pol,
 void blkg_conf_finish(struct blkg_conf_ctx *ctx);
 
 
+static inline struct blkcg *css_to_blkcg(struct cgroup_subsys_state *css)
+{
+	return css ? container_of(css, struct blkcg, css) : NULL;
+}
+
 static inline struct blkcg *cgroup_to_blkcg(struct cgroup *cgroup)
 {
-	return container_of(cgroup_css(cgroup, blkio_subsys_id),
-			    struct blkcg, css);
+	return css_to_blkcg(cgroup_css(cgroup, blkio_subsys_id));
 }
 
 static inline struct blkcg *task_blkcg(struct task_struct *tsk)
 {
-	return container_of(task_css(tsk, blkio_subsys_id), struct blkcg, css);
+	return css_to_blkcg(task_css(tsk, blkio_subsys_id));
 }
 
 static inline struct blkcg *bio_blkcg(struct bio *bio)
 {
 	if (bio && bio->bi_css)
-		return container_of(bio->bi_css, struct blkcg, css);
+		return css_to_blkcg(bio->bi_css);
 	return task_blkcg(current);
 }
 
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 9d3f615..1db686e 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -45,16 +45,19 @@ struct freezer {
 	spinlock_t			lock;
 };
 
+static inline struct freezer *css_freezer(struct cgroup_subsys_state *css)
+{
+	return css ? container_of(css, struct freezer, css) : NULL;
+}
+
 static inline struct freezer *cgroup_freezer(struct cgroup *cgroup)
 {
-	return container_of(cgroup_css(cgroup, freezer_subsys_id),
-			    struct freezer, css);
+	return css_freezer(cgroup_css(cgroup, freezer_subsys_id));
 }
 
 static inline struct freezer *task_freezer(struct task_struct *task)
 {
-	return container_of(task_css(task, freezer_subsys_id),
-			    struct freezer, css);
+	return css_freezer(task_css(task, freezer_subsys_id));
 }
 
 static struct freezer *parent_freezer(struct freezer *freezer)
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index f737134..6e9cbdd 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -114,18 +114,21 @@ struct cpuset {
 	int relax_domain_level;
 };
 
+static inline struct cpuset *css_cs(struct cgroup_subsys_state *css)
+{
+	return css ? container_of(css, struct cpuset, css) : NULL;
+}
+
 /* Retrieve the cpuset for a cgroup */
 static inline struct cpuset *cgroup_cs(struct cgroup *cgrp)
 {
-	return container_of(cgroup_css(cgrp, cpuset_subsys_id),
-			    struct cpuset, css);
+	return css_cs(cgroup_css(cgrp, cpuset_subsys_id));
 }
 
 /* Retrieve the cpuset for a task */
 static inline struct cpuset *task_cs(struct task_struct *task)
 {
-	return container_of(task_css(task, cpuset_subsys_id),
-			    struct cpuset, css);
+	return css_cs(task_css(task, cpuset_subsys_id));
 }
 
 static inline struct cpuset *parent_cs(struct cpuset *cs)
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 323d907..5bccb02 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7083,11 +7083,15 @@ int sched_rt_handler(struct ctl_table *table, int write,
 
 #ifdef CONFIG_CGROUP_SCHED
 
+static inline struct task_group *css_tg(struct cgroup_subsys_state *css)
+{
+	return css ? container_of(css, struct task_group, css) : NULL;
+}
+
 /* return corresponding task_group object of a cgroup */
 static inline struct task_group *cgroup_tg(struct cgroup *cgrp)
 {
-	return container_of(cgroup_css(cgrp, cpu_cgroup_subsys_id),
-			    struct task_group, css);
+	return css_tg(cgroup_css(cgrp, cpu_cgroup_subsys_id));
 }
 
 static struct cgroup_subsys_state *cpu_cgroup_css_alloc(struct cgroup *cgrp)
diff --git a/kernel/sched/cpuacct.c b/kernel/sched/cpuacct.c
index 4a210fa..8ccfa10 100644
--- a/kernel/sched/cpuacct.c
+++ b/kernel/sched/cpuacct.c
@@ -33,18 +33,21 @@ struct cpuacct {
 	struct kernel_cpustat __percpu *cpustat;
 };
 
+static inline struct cpuacct *css_ca(struct cgroup_subsys_state *css)
+{
+	return css ? container_of(css, struct cpuacct, css) : NULL;
+}
+
 /* return cpu accounting group corresponding to this container */
 static inline struct cpuacct *cgroup_ca(struct cgroup *cgrp)
 {
-	return container_of(cgroup_css(cgrp, cpuacct_subsys_id),
-			    struct cpuacct, css);
+	return css_ca(cgroup_css(cgrp, cpuacct_subsys_id));
 }
 
 /* return cpu accounting group to which this task belongs */
 static inline struct cpuacct *task_ca(struct task_struct *tsk)
 {
-	return container_of(task_css(tsk, cpuacct_subsys_id),
-			    struct cpuacct, css);
+	return css_ca(task_css(tsk, cpuacct_subsys_id));
 }
 
 static inline struct cpuacct *__parent_ca(struct cpuacct *ca)
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index d2f9fc0..95585a0 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -36,7 +36,7 @@ static struct hugetlb_cgroup *root_h_cgroup __read_mostly;
 static inline
 struct hugetlb_cgroup *hugetlb_cgroup_from_css(struct cgroup_subsys_state *s)
 {
-	return container_of(s, struct hugetlb_cgroup, css);
+	return s ? container_of(s, struct hugetlb_cgroup, css) : NULL;
 }
 
 static inline
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b47bd3a..11d659e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -486,7 +486,7 @@ static DEFINE_MUTEX(memcg_create_mutex);
 static inline
 struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
 {
-	return container_of(s, struct mem_cgroup, css);
+	return s ? container_of(s, struct mem_cgroup, css) : NULL;
 }
 
 /* Some nice accessors for the vmpressure. */
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 5ee72a0..af412ab 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -23,16 +23,19 @@
 #include <net/sock.h>
 #include <net/cls_cgroup.h>
 
+static inline struct cgroup_cls_state *css_cls_state(struct cgroup_subsys_state *css)
+{
+	return css ? container_of(css, struct cgroup_cls_state, css) : NULL;
+}
+
 static inline struct cgroup_cls_state *cgrp_cls_state(struct cgroup *cgrp)
 {
-	return container_of(cgroup_css(cgrp, net_cls_subsys_id),
-			    struct cgroup_cls_state, css);
+	return css_cls_state(cgroup_css(cgrp, net_cls_subsys_id));
 }
 
 static inline struct cgroup_cls_state *task_cls_state(struct task_struct *p)
 {
-	return container_of(task_css(p, net_cls_subsys_id),
-			    struct cgroup_cls_state, css);
+	return css_cls_state(task_css(p, net_cls_subsys_id));
 }
 
 static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 87a0a03..9095364 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -53,7 +53,7 @@ struct dev_cgroup {
 
 static inline struct dev_cgroup *css_to_devcgroup(struct cgroup_subsys_state *s)
 {
-	return container_of(s, struct dev_cgroup, css);
+	return s ? container_of(s, struct dev_cgroup, css) : NULL;
 }
 
 static inline struct dev_cgroup *cgroup_to_devcgroup(struct cgroup *cgroup)
-- 
1.8.3.1
