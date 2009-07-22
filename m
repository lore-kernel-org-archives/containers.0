From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/4] Move the cgroup debug subsys into cgroup.c to access
	internal state
Date: Wed, 22 Jul 2009 12:50:35 -0700
Message-ID: <20090722195035.7481.85657.stgit@menage.mtv.corp.google.com>
References: <20090722194644.7481.47805.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090722194644.7481.47805.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Move the cgroup debug subsys into cgroup.c to access internal state

While it's architecturally clean to have the cgroup debug subsystem be
completely independent of the cgroups framework, it limits its
usefulness for debugging the contents of internal data structures.
Move the debug subsystem code into the scope of all the cgroups data
structures to make more detailed debugging possible.

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 kernel/Makefile       |    1 
 kernel/cgroup.c       |   88 +++++++++++++++++++++++++++++++++++++++++
 kernel/cgroup_debug.c |  105 -------------------------------------------------
 3 files changed, 88 insertions(+), 106 deletions(-)
 delete mode 100644 kernel/cgroup_debug.c

diff --git a/kernel/Makefile b/kernel/Makefile
index ecbd483..251adfe 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -58,7 +58,6 @@ obj-$(CONFIG_KEXEC) += kexec.o
 obj-$(CONFIG_BACKTRACE_SELF_TEST) += backtracetest.o
 obj-$(CONFIG_COMPAT) += compat.o
 obj-$(CONFIG_CGROUPS) += cgroup.o
-obj-$(CONFIG_CGROUP_DEBUG) += cgroup_debug.o
 obj-$(CONFIG_CGROUP_FREEZER) += cgroup_freezer.o
 obj-$(CONFIG_CPUSETS) += cpuset.o
 obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index abca7e5..6306757 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3762,3 +3762,91 @@ css_get_next(struct cgroup_subsys *ss, int id,
 	return ret;
 }
 
+#ifdef CONFIG_CGROUP_DEBUG
+static struct cgroup_subsys_state *debug_create(struct cgroup_subsys *ss,
+						   struct cgroup *cont)
+{
+	struct cgroup_subsys_state *css = kzalloc(sizeof(*css), GFP_KERNEL);
+
+	if (!css)
+		return ERR_PTR(-ENOMEM);
+
+	return css;
+}
+
+static void debug_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	kfree(cont->subsys[debug_subsys_id]);
+}
+
+static u64 cgroup_refcount_read(struct cgroup *cont, struct cftype *cft)
+{
+	return atomic_read(&cont->count);
+}
+
+static u64 debug_taskcount_read(struct cgroup *cont, struct cftype *cft)
+{
+	return cgroup_task_count(cont);
+}
+
+static u64 current_css_set_read(struct cgroup *cont, struct cftype *cft)
+{
+	return (u64)(long)current->cgroups;
+}
+
+static u64 current_css_set_refcount_read(struct cgroup *cont,
+					   struct cftype *cft)
+{
+	u64 count;
+
+	rcu_read_lock();
+	count = atomic_read(&current->cgroups->refcount);
+	rcu_read_unlock();
+	return count;
+}
+
+static u64 releasable_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	return test_bit(CGRP_RELEASABLE, &cgrp->flags);
+}
+
+static struct cftype debug_files[] =  {
+	{
+		.name = "cgroup_refcount",
+		.read_u64 = cgroup_refcount_read,
+	},
+	{
+		.name = "taskcount",
+		.read_u64 = debug_taskcount_read,
+	},
+
+	{
+		.name = "current_css_set",
+		.read_u64 = current_css_set_read,
+	},
+
+	{
+		.name = "current_css_set_refcount",
+		.read_u64 = current_css_set_refcount_read,
+	},
+
+	{
+		.name = "releasable",
+		.read_u64 = releasable_read,
+	},
+};
+
+static int debug_populate(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	return cgroup_add_files(cont, ss, debug_files,
+				ARRAY_SIZE(debug_files));
+}
+
+struct cgroup_subsys debug_subsys = {
+	.name = "debug",
+	.create = debug_create,
+	.destroy = debug_destroy,
+	.populate = debug_populate,
+	.subsys_id = debug_subsys_id,
+};
+#endif /* CONFIG_CGROUP_DEBUG */
diff --git a/kernel/cgroup_debug.c b/kernel/cgroup_debug.c
deleted file mode 100644
index 0c92d79..0000000
--- a/kernel/cgroup_debug.c
+++ /dev/null
@@ -1,105 +0,0 @@
-/*
- * kernel/cgroup_debug.c - Example cgroup subsystem that
- * exposes debug info
- *
- * Copyright (C) Google Inc, 2007
- *
- * Developed by Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org)
- *
- */
-
-#include <linux/cgroup.h>
-#include <linux/fs.h>
-#include <linux/slab.h>
-#include <linux/rcupdate.h>
-
-#include <asm/atomic.h>
-
-static struct cgroup_subsys_state *debug_create(struct cgroup_subsys *ss,
-						   struct cgroup *cont)
-{
-	struct cgroup_subsys_state *css = kzalloc(sizeof(*css), GFP_KERNEL);
-
-	if (!css)
-		return ERR_PTR(-ENOMEM);
-
-	return css;
-}
-
-static void debug_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
-{
-	kfree(cont->subsys[debug_subsys_id]);
-}
-
-static u64 cgroup_refcount_read(struct cgroup *cont, struct cftype *cft)
-{
-	return atomic_read(&cont->count);
-}
-
-static u64 taskcount_read(struct cgroup *cont, struct cftype *cft)
-{
-	u64 count;
-
-	count = cgroup_task_count(cont);
-	return count;
-}
-
-static u64 current_css_set_read(struct cgroup *cont, struct cftype *cft)
-{
-	return (u64)(long)current->cgroups;
-}
-
-static u64 current_css_set_refcount_read(struct cgroup *cont,
-					   struct cftype *cft)
-{
-	u64 count;
-
-	rcu_read_lock();
-	count = atomic_read(&current->cgroups->refcount);
-	rcu_read_unlock();
-	return count;
-}
-
-static u64 releasable_read(struct cgroup *cgrp, struct cftype *cft)
-{
-	return test_bit(CGRP_RELEASABLE, &cgrp->flags);
-}
-
-static struct cftype files[] =  {
-	{
-		.name = "cgroup_refcount",
-		.read_u64 = cgroup_refcount_read,
-	},
-	{
-		.name = "taskcount",
-		.read_u64 = taskcount_read,
-	},
-
-	{
-		.name = "current_css_set",
-		.read_u64 = current_css_set_read,
-	},
-
-	{
-		.name = "current_css_set_refcount",
-		.read_u64 = current_css_set_refcount_read,
-	},
-
-	{
-		.name = "releasable",
-		.read_u64 = releasable_read,
-	},
-};
-
-static int debug_populate(struct cgroup_subsys *ss, struct cgroup *cont)
-{
-	return cgroup_add_files(cont, ss, files, ARRAY_SIZE(files));
-}
-
-struct cgroup_subsys debug_subsys = {
-	.name = "debug",
-	.create = debug_create,
-	.destroy = debug_destroy,
-	.populate = debug_populate,
-	.subsys_id = debug_subsys_id,
-};
