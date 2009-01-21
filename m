From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Subject: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Wed, 21 Jan 2009 16:38:21 +0530
Message-ID: <200901211638.23101.knikanth__48793.021697975$1232536397$gmane$org@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Arve =?iso-8859-1?q?Hj=F8nnev=E5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

As Alan Cox suggested/wondered in this thread, 
http://lkml.org/lkml/2009/1/12/235 , this is a container group based approach 
to override the oom killer selection without losing all the benefits of the 
current oom killer heuristics and oom_adj interface.

It adds a tunable oom.victim to the oom cgroup. The oom killer will kill the 
process using the usual badness value but only within the cgroup with the 
maximum value for oom.victim before killing any process from a cgroup with a 
lesser oom.victim number. Oom killing could be disabled by setting 
oom.victim=0.

Signed-off-by: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>

---

diff --git a/Documentation/cgroups/oom.txt b/Documentation/cgroups/oom.txt
new file mode 100644
index 0000000..9102830
--- /dev/null
+++ b/Documentation/cgroups/oom.txt
@@ -0,0 +1,29 @@
+OOM Killer controller
+--- ------ ----------
+
+The OOM killer kills the process based on a set of heuristics such that only
+minimum amount of work done will be lost, a large amount of memory would be
+recovered and minimum no of processes are killed.
+
+The user can adjust the score used to select the processes to be killed using
+/proc/<pid>/oom_adj. Giving it a high score will increase the likelihood of 
+this process being killed by the oom-killer.  Valid values are in the range 
+-16 to +15, plus the special value -17, which disables oom-killing altogether
+for that process.
+
+But it is very difficult to suggest an order among tasks to be killed during
+Out Of Memory situation. The OOM Killer controller aids in doing that.
+
+USAGE
+-----
+
+Mount the oom controller by passing 'oom' when mounting cgroups. Echo
+a value in oom.victim file to change the order. The oom killer would kill
+all the processes in a cgroup with a higher oom.victim value before killing a
+process in a cgroup with lower oom.victim value. Among those tasks with same
+oom.victim value, the usual badness heuristics would be applied. The 
+/proc/<pid>/oom_adj still helps adjusting the oom killer score. Also having
+oom.victim = 0 would disable oom killing for the tasks in that cgroup.
+
+Note: If this is used without proper consideration, innocent processes may
+get killed unnecesarily.
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 9c8d31b..6944f99 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -59,4 +59,8 @@ SUBSYS(freezer)
 SUBSYS(net_cls)
 #endif
 
+#ifdef CONFIG_CGROUP_OOM
+SUBSYS(oom)
+#endif
+
 /* */
diff --git a/include/linux/oomcontrol.h b/include/linux/oomcontrol.h
new file mode 100644
index 0000000..18146ab
--- /dev/null
+++ b/include/linux/oomcontrol.h
@@ -0,0 +1,14 @@
+#ifndef _LINUX_OOMCONTROL_H
+#define _LINUX_OOMCONTROL_H
+
+#ifdef CONFIG_CGROUP_OOM
+struct oom_cgroup { 
+	struct cgroup_subsys_state css;
+	/*
+	 * the order to be victimized for this group
+	 */  
+	u64 victim;
+};
+
+#endif
+#endif
diff --git a/init/Kconfig b/init/Kconfig
index 2af8382..99ed0de 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -354,6 +354,15 @@ config CGROUP_DEBUG
 
 	  Say N if unsure.
 
+config CGROUP_OOM
+	bool "Oom cgroup subsystem"
+	depends on CGROUPS
+	help
+	  This provides a cgroup subsystem which aids controlling
+	  the order in which tasks whould be killed during
+	  out of memory situations.
+	
+
 config CGROUP_NS
 	bool "Namespace cgroup subsystem"
 	depends on CGROUPS
diff --git a/mm/Makefile b/mm/Makefile
index 72255be..a5d7222 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -33,3 +33,4 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_CGROUP_OOM) += oomcontrol.o 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 40ba050..f697d50 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -26,6 +26,7 @@
 #include <linux/module.h>
 #include <linux/notifier.h>
 #include <linux/memcontrol.h>
+#include <linux/oomcontrol.h>
 #include <linux/security.h>
 
 int sysctl_panic_on_oom;
@@ -205,6 +206,9 @@ static struct task_struct *select_bad_process(unsigned 
long *ppoints,
 	struct task_struct *g, *p;
 	struct task_struct *chosen = NULL;
 	struct timespec uptime;
+#ifdef CONFIG_CGROUP_OOM
+	u64 chosenvictim = 1, taskvictim;
+#endif
 	*ppoints = 0;
 
 	do_posix_clock_monotonic_gettime(&uptime);
@@ -257,10 +261,26 @@ static struct task_struct *select_bad_process(unsigned 
long *ppoints,
 			continue;
 
 		points = badness(p, uptime.tv_sec);
+#ifdef CONFIG_CGROUP_OOM
+		taskvictim = (container_of(p->cgroups->subsys[oom_subsys_id],
+						struct oom_cgroup, css))->victim;
+
+		if (taskvictim > chosenvictim ||
+			(taskvictim == chosenvictim && points > *ppoints) ||
+			!chosen) {
+
+			chosen = p;
+			*ppoints = points;
+			chosenvictim = taskvictim;
+
+		}
+		
+#else
 		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;
 		}
+#endif
 	} while_each_thread(g, p);
 
 	return chosen;
diff --git a/mm/oomcontrol.c b/mm/oomcontrol.c
new file mode 100644
index 0000000..2bfa325
--- /dev/null
+++ b/mm/oomcontrol.c
@@ -0,0 +1,95 @@
+/*
+ * kernel/cgroup_oom.c - oom handler cgroup.
+ */
+
+#include <linux/cgroup.h>
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <linux/oomcontrol.h>
+
+/*
+ * Helper to retrieve oom controller data from cgroup
+ */
+static struct oom_cgroup *oom_css_from_cgroup(struct cgroup *cgrp)
+{
+        return container_of(cgroup_subsys_state(cgrp,
+                                oom_subsys_id), struct oom_cgroup,
+                                css);
+}
+
+
+static struct cgroup_subsys_state *oom_create(struct cgroup_subsys *ss,
+						   struct cgroup *cont)
+{
+	struct oom_cgroup *oom_css = kzalloc(sizeof(*oom_css), GFP_KERNEL);
+	struct oom_cgroup *parent;
+
+	if (!oom_css)
+		return ERR_PTR(-ENOMEM);
+
+	/*
+	 * if root last/only group to be victimized
+	 * else inherit parents value
+	 */
+	if (cont->parent == NULL)
+		oom_css->victim = 1;
+	else {
+		parent = oom_css_from_cgroup(cont->parent);
+		oom_css->victim = parent->victim;
+	}
+
+	return &oom_css->css;
+}
+
+static void oom_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	kfree(cont->subsys[oom_subsys_id]);
+}
+
+static int oom_victim_write(struct cgroup *cgrp, struct cftype *cft,
+                                       u64 val)
+{
+
+        cgroup_lock();
+
+	(oom_css_from_cgroup(cgrp))->victim = val;
+
+        cgroup_unlock();
+
+        return 0;
+}
+
+static u64 oom_victim_read(struct cgroup *cgrp, struct cftype *cft)
+{
+        u64 victim = (oom_css_from_cgroup(cgrp))->victim;
+
+        return victim;
+}
+
+
+static struct cftype oom_cgroup_files[] = {
+	{
+		.name = "victim",
+		.read_u64 = oom_victim_read,
+		.write_u64 = oom_victim_write,
+	},
+};
+
+static int oom_populate(struct cgroup_subsys *ss,
+                                struct cgroup *cont)
+{
+        int ret;
+
+        ret = cgroup_add_files(cont, ss, oom_cgroup_files,
+                                ARRAY_SIZE(oom_cgroup_files));
+
+        return ret;
+}
+
+struct cgroup_subsys oom_subsys = {
+	.name = "oom",
+	.subsys_id = oom_subsys_id,
+	.create = oom_create,
+	.destroy = oom_destroy,
+	.populate = oom_populate,
+};
