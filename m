From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: cgroup attach/fork hooks consistency with the ns_cgroup
Date: Wed, 17 Jun 2009 17:35:57 +0200
Message-ID: <4A390D5D.5040702@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040701040103000808080802"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------040701040103000808080802
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I noticed two different behaviours, the second one looks weird for me:

  1) when the cgroup is manually created:
	mkdir /cgroup/foo
	echo $$ > /cgroup/foo/tasks

  only the "attach" callback is called as expected.

  2) when the cgroup is automatically created via the ns_cgroup with the 
clone function and the namespace flags,

   the "attach" *and* the "fork" callbacks are called.


IMHO, these two different behaviours look inconsistent. Won't this lead 
to some problems or a specific code to handle both cases if a cgroup is 
using the fork and the attach hooks ?

For example, let's imagine we create a control group which shows the 
number of tasks running. We have a global atomic and we display its 
value in the cgroupfs.

When a task attaches to the cgroup, we do atomic_inc in the attach 
callback. For all its child, the fork hook will do atomic_inc and exit 
hook will do atomic_dec.

If we create the cgroup manually like the case 1) that works. But if we 
use the control group with the ns_cgroup the task counter will be set to 
2 for the first tasks entering the cgroup because the attach callback 
will increment the counter and the fork callback will increment it again.

In attachment a source code to illustrate the example.

Shouldn't the ns_cgroup_clone be called after the cgroup_fork_callbacks 
in copy_process function ? So we don't call the fork callback for the 
first tasks and we keep the consistency ?

Thanks
  -- Daniel



--------------040701040103000808080802
Content-Type: text/x-diff;
 name="make-evident-the-ns-cgroup-bug.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="make-evident-the-ns-cgroup-bug.patch"

---
 include/linux/cgroup_subsys.h |    1 
 kernel/Makefile               |    2 
 kernel/cgroup_bug.c           |   87 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 89 insertions(+), 1 deletion(-)

Index: linux-2.6/kernel/cgroup_bug.c
===================================================================
--- /dev/null
+++ linux-2.6/kernel/cgroup_bug.c
@@ -0,0 +1,87 @@
+#include <linux/cgroup.h>
+#include <asm/atomic.h>
+
+struct bug_cg {
+	struct cgroup_subsys_state css;
+	atomic_t ntasks;
+};
+
+static inline struct bug_cg *bug_cgroup(struct cgroup *cgroup)
+{
+	return container_of(cgroup_subsys_state(cgroup, bug_subsys_id),
+			    struct bug_cg, css);
+}
+
+static struct cgroup_subsys_state *bug_cgroup_create(struct cgroup_subsys *ss,
+						     struct cgroup *cgroup)
+{
+	struct bug_cg *bug_cg;
+
+	bug_cg = kzalloc(sizeof(*bug_cg), GFP_KERNEL);
+	if (!bug_cg)
+		return ERR_PTR(-ENOMEM);
+
+	atomic_set(&bug_cg->ntasks, 0);
+
+	return &bug_cg->css;
+}
+
+static void bug_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cgroup)
+{
+	struct bug_cg *bug_cg = bug_cgroup(cgroup);
+	kfree(bug_cg);
+}
+
+static void bug_cgroup_attach(struct cgroup_subsys *ss, struct cgroup *cgroup,
+			      struct cgroup *old_cgroup,
+			      struct task_struct *task)
+{
+	struct bug_cg *bug_cg = bug_cgroup(cgroup);
+
+	atomic_inc(&bug_cg->ntasks);
+}
+
+static int bug_cgroup_fork(struct cgroup_subsys *ss, struct task_struct *task,
+			   unsigned long clone_flags)
+{
+	struct cgroup *cgroup = task_cgroup(task, bug_subsys_id);
+
+	atomic_inc(&bug_cgroup(cgroup)->ntasks);
+
+	return 0;
+}
+
+static void bug_cgroup_exit(struct cgroup_subsys *ss, struct task_struct *task)
+{
+	struct cgroup *cgroup = task_cgroup(task, bug_subsys_id);
+
+	atomic_dec(&bug_cgroup(cgroup)->ntasks);
+}
+
+static u64 task_count_read(struct cgroup *cgroup, struct cftype *cft)
+{
+	return atomic_read(&bug_cgroup(cgroup)->ntasks);
+}
+
+static struct cftype files[] = {
+	{
+		.name = "ntask",
+		.read_u64 = task_count_read,
+	},
+};
+
+static int bug_cgroup_populate(struct cgroup_subsys *ss, struct cgroup *cgroup)
+{
+	return cgroup_add_files(cgroup, ss, files, ARRAY_SIZE(files));
+}
+
+struct cgroup_subsys bug_subsys = {
+	.name		= "bug",
+	.subsys_id	= bug_subsys_id,
+	.create		= bug_cgroup_create,
+	.destroy	= bug_cgroup_destroy,
+	.populate	= bug_cgroup_populate,
+	.attach         = bug_cgroup_attach,
+	.fork		= bug_cgroup_fork,
+	.exit		= bug_cgroup_exit,
+};
Index: linux-2.6/include/linux/cgroup_subsys.h
===================================================================
--- linux-2.6.orig/include/linux/cgroup_subsys.h
+++ linux-2.6/include/linux/cgroup_subsys.h
@@ -21,6 +21,7 @@ SUBSYS(debug)
 
 #ifdef CONFIG_CGROUP_NS
 SUBSYS(ns)
+SUBSYS(bug)
 #endif
 
 /* */
Index: linux-2.6/kernel/Makefile
===================================================================
--- linux-2.6.orig/kernel/Makefile
+++ linux-2.6/kernel/Makefile
@@ -60,7 +60,7 @@ obj-$(CONFIG_CGROUPS) += cgroup.o
 obj-$(CONFIG_CGROUP_DEBUG) += cgroup_debug.o
 obj-$(CONFIG_CGROUP_FREEZER) += cgroup_freezer.o
 obj-$(CONFIG_CPUSETS) += cpuset.o
-obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
+obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o cgroup_bug.o
 obj-$(CONFIG_UTS_NS) += utsname.o
 obj-$(CONFIG_USER_NS) += user_namespace.o
 obj-$(CONFIG_PID_NS) += pid_namespace.o

--------------040701040103000808080802
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------040701040103000808080802--
