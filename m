From: "Kirill A. Shutsemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: [PATCH 2/2] cgroups: introduce timer slack subsystem
Date: Sun, 30 Jan 2011 11:59:22 +0200
Message-ID: <1296381562-14377-2-git-send-email-kirill__4983.53380612588$1296381692$gmane$org@shutemov.name>
References: <1296381562-14377-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1296381562-14377-1-git-send-email-kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>

Provides a way of tasks grouping by timer slack value. Introduces per
cgroup timer slack value which will override the default timer slack
value once a task is attached to a cgroup.

It's useful in mobile devices where certain background apps are
attached to a cgroup and minimum wakeups are desired.

Based on patch by Jacob Pan.

Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
---
 include/linux/cgroup_subsys.h |    6 ++
 include/linux/init_task.h     |    4 +-
 init/Kconfig                  |   10 ++++
 kernel/Makefile               |    1 +
 kernel/cgroup_timer_slack.c   |  115 +++++++++++++++++++++++++++++++++++++++++
 5 files changed, 135 insertions(+), 1 deletions(-)
 create mode 100644 kernel/cgroup_timer_slack.c

diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index ccefff0..e399228 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -66,3 +66,9 @@ SUBSYS(blkio)
 #endif
 
 /* */
+
+#ifdef CONFIG_CGROUP_TIMER_SLACK
+SUBSYS(timer_slack)
+#endif
+
+/* */
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index caa151f..48eca8f 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -124,6 +124,8 @@ extern struct cred init_cred;
 # define INIT_PERF_EVENTS(tsk)
 #endif
 
+#define TIMER_SLACK_NS_DEFAULT 50000
+
 /*
  *  INIT_TASK is used to set up the first task table, touch at
  * your own risk!. Base=0, limit=0x1fffff (=2MB)
@@ -177,7 +179,7 @@ extern struct cred init_cred;
 	.cpu_timers	= INIT_CPU_TIMERS(tsk.cpu_timers),		\
 	.fs_excl	= ATOMIC_INIT(0),				\
 	.pi_lock	= __RAW_SPIN_LOCK_UNLOCKED(tsk.pi_lock),	\
-	.timer_slack_ns = 50000, /* 50 usec default slack */		\
+	.timer_slack_ns = TIMER_SLACK_NS_DEFAULT,			\
 	.pids = {							\
 		[PIDTYPE_PID]  = INIT_PID_LINK(PIDTYPE_PID),		\
 		[PIDTYPE_PGID] = INIT_PID_LINK(PIDTYPE_PGID),		\
diff --git a/init/Kconfig b/init/Kconfig
index be788c0..f21b4ce 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -596,6 +596,16 @@ config CGROUP_FREEZER
 	  Provides a way to freeze and unfreeze all tasks in a
 	  cgroup.
 
+config CGROUP_TIMER_SLACK
+	tristate "Timer slack cgroup subsystem"
+	help
+	  Provides a way of tasks grouping by timer slack value.
+	  Introduces per cgroup timer slack value which will override
+	  the default timer slack value once a task is attached to a
+	  cgroup.
+	  It's useful in mobile devices where certain background apps
+	  are attached to a cgroup and minimum wakeups are desired.
+
 config CGROUP_DEVICE
 	bool "Device controller for cgroups"
 	help
diff --git a/kernel/Makefile b/kernel/Makefile
index 353d3fe..0b60239 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -61,6 +61,7 @@ obj-$(CONFIG_BACKTRACE_SELF_TEST) += backtracetest.o
 obj-$(CONFIG_COMPAT) += compat.o
 obj-$(CONFIG_CGROUPS) += cgroup.o
 obj-$(CONFIG_CGROUP_FREEZER) += cgroup_freezer.o
+obj-$(CONFIG_CGROUP_TIMER_SLACK) += cgroup_timer_slack.o
 obj-$(CONFIG_CPUSETS) += cpuset.o
 obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
 obj-$(CONFIG_UTS_NS) += utsname.o
diff --git a/kernel/cgroup_timer_slack.c b/kernel/cgroup_timer_slack.c
new file mode 100644
index 0000000..9f3c370
--- /dev/null
+++ b/kernel/cgroup_timer_slack.c
@@ -0,0 +1,115 @@
+#include <linux/cgroup.h>
+#include <linux/init_task.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+
+static struct cgroup_subsys timer_slack_subsys;
+struct timer_slack_cgroup {
+	struct cgroup_subsys_state css;
+	unsigned long timer_slack_ns;
+};
+
+static struct timer_slack_cgroup *cgroup_to_tslack_cgroup(struct cgroup *cgroup)
+{
+	struct cgroup_subsys_state *css;
+
+	css = cgroup_subsys_state(cgroup, timer_slack_subsys.subsys_id);
+	return container_of(css, struct timer_slack_cgroup, css);
+}
+
+static struct cgroup_subsys_state *
+tslack_cgroup_create(struct cgroup_subsys *subsys, struct cgroup *cgroup)
+{
+	struct timer_slack_cgroup *tslack_cgroup;
+	struct cgroup *parent = cgroup->parent;
+
+	tslack_cgroup = kmalloc(sizeof(*tslack_cgroup), GFP_KERNEL);
+	if (!tslack_cgroup)
+		return ERR_PTR(-ENOMEM);
+
+	if (parent)
+		tslack_cgroup->timer_slack_ns =
+			cgroup_to_tslack_cgroup(parent)->timer_slack_ns;
+	else
+		tslack_cgroup->timer_slack_ns = TIMER_SLACK_NS_DEFAULT;
+
+	return &tslack_cgroup->css;
+}
+
+static void tslack_cgroup_destroy(struct cgroup_subsys *subsys,
+		struct cgroup *cgroup)
+{
+	kfree(cgroup_to_tslack_cgroup(cgroup));
+}
+
+static void tslack_cgroup_attach(struct cgroup_subsys *subsys,
+		struct cgroup *cgroup, struct cgroup *prev,
+		struct task_struct *tsk, bool threadgroup)
+{
+	struct timer_slack_cgroup *tslack_cgroup;
+
+	tslack_cgroup = cgroup_to_tslack_cgroup(cgroup);
+	task_lock(tsk);
+	tsk->timer_slack_ns = tslack_cgroup->timer_slack_ns;
+	task_unlock(tsk);
+}
+
+static u64 tslack_read_slack_ns(struct cgroup *cgroup, struct cftype *cft)
+{
+       return cgroup_to_tslack_cgroup(cgroup)->timer_slack_ns;
+}
+
+static int tslack_write_slack_ns(struct cgroup *cgroup, struct cftype *cft,
+		u64 val)
+{
+	struct cgroup_iter it;
+	struct task_struct *task;
+
+	if (!val)
+		return -EINVAL;
+
+	cgroup_to_tslack_cgroup(cgroup)->timer_slack_ns = val;
+
+	/* change timer slack value for all tasks in the cgroup */
+	cgroup_iter_start(cgroup, &it);
+	while ((task = cgroup_iter_next(cgroup, &it)))
+		task->timer_slack_ns = val;
+	cgroup_iter_end(cgroup, &it);
+
+	return 0;
+}
+
+static struct cftype cft_timer_slack = {
+	.name = "slack_ns",
+	.read_u64 = tslack_read_slack_ns,
+	.write_u64 = tslack_write_slack_ns,
+};
+
+static int tslack_cgroup_populate(struct cgroup_subsys *subsys,
+		struct cgroup *cgroup)
+{
+	return cgroup_add_file(cgroup, subsys, &cft_timer_slack);
+}
+
+static struct cgroup_subsys timer_slack_subsys = {
+	.name = "timer_slack",
+	.module = THIS_MODULE,
+	.create = tslack_cgroup_create,
+	.destroy = tslack_cgroup_destroy,
+	.attach = tslack_cgroup_attach,
+	.populate = tslack_cgroup_populate,
+};
+
+static int __init init_cgroup_timer_slack(void)
+{
+	return cgroup_load_subsys(&timer_slack_subsys);
+}
+
+static void __exit exit_cgroup_timer_slack(void)
+{
+	cgroup_unload_subsys(&timer_slack_subsys);
+}
+
+module_init(init_cgroup_timer_slack);
+module_exit(exit_cgroup_timer_slack);
+MODULE_LICENSE("GPL");
-- 
1.7.3.5
