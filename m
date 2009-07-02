From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 9/9] [RFC] Example multi-bindable subsystem: a max-depth
	controller
Date: Wed, 01 Jul 2009 19:11:39 -0700
Message-ID: <20090702021139.14469.3097.stgit__15997.399602975$1246501161$gmane$org@menage.mtv.corp.google.com>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702020624.14469.47066.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

[RFC] Example multi-bindable subsystem: a max-depth controller

This subsystem introduces a new file, "maxdepth.children", in each
cgroup in its hierarchy.  This value defaults to -1, meaning no
limit. If this maxdepth.children is >= 0, then no child cgroup may be
created below this cgroup at a depth of more than maxdepth.children.
The limit is checked at cgroup creation time for all ancestor cgroups.

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 include/linux/cgroup_subsys.h |    6 +++
 init/Kconfig                  |    8 ++++
 kernel/Makefile               |    1 +
 kernel/maxdepth_cgroup.c      |   80 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 95 insertions(+), 0 deletions(-)
 create mode 100644 kernel/maxdepth_cgroup.c

diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 5dfea38..021bfc1 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -66,3 +66,9 @@ MULTI_SUBSYS(info)
 #endif
 
 /* */
+
+#ifdef CONFIG_CGROUP_MAXDEPTH
+MULTI_SUBSYS(maxdepth)
+#endif
+
+/* */
diff --git a/init/Kconfig b/init/Kconfig
index 3bd4685..69907cc 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -613,6 +613,14 @@ config CGROUP_INFO
 	  application-specific configuration data about a cgroup. Can
 	  be mounted on multiple hierarchies at once.
 
+config CGROUP_MAXDEPTH
+       bool "CGroups controller to limit the max depth of a hierarchy"
+       depends on CGROUPS
+       help
+         Provides a simple cgroups subsystem with an
+         "maxdepth.children" field that limits the maximum number of
+         child generations permitted to a cgroup.
+
 endif # CGROUPS
 
 config MM_OWNER
diff --git a/kernel/Makefile b/kernel/Makefile
index e713a67..5712cd5 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -62,6 +62,7 @@ obj-$(CONFIG_CGROUP_FREEZER) += cgroup_freezer.o
 obj-$(CONFIG_CPUSETS) += cpuset.o
 obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
 obj-$(CONFIG_CGROUP_INFO) += info_cgroup.o
+obj-$(CONFIG_CGROUP_MAXDEPTH) += maxdepth_cgroup.o
 obj-$(CONFIG_UTS_NS) += utsname.o
 obj-$(CONFIG_USER_NS) += user_namespace.o
 obj-$(CONFIG_PID_NS) += pid_namespace.o
diff --git a/kernel/maxdepth_cgroup.c b/kernel/maxdepth_cgroup.c
new file mode 100644
index 0000000..2ca92d8
--- /dev/null
+++ b/kernel/maxdepth_cgroup.c
@@ -0,0 +1,80 @@
+/*
+ * maxdepth_cgroup.c - simple cgroup providing a child generation
+ * limit field
+ */
+
+#include "linux/cgroup.h"
+#include "linux/err.h"
+#include "linux/seq_file.h"
+
+struct maxdepth_cgroup {
+	struct cgroup_subsys_state css;
+	int maxdepth;
+};
+
+static inline struct maxdepth_cgroup *cg_md(struct cgroup *cg)
+{
+	return container_of(cgroup_subsys_state(cg, maxdepth_subsys_id),
+			    struct maxdepth_cgroup, css);
+}
+
+static struct cgroup_subsys_state *md_create(struct cgroup_subsys *ss,
+					     struct cgroup *cg)
+{
+	struct maxdepth_cgroup *md;
+	int depth = 1, maxdepth;
+	while (1) {
+		cg = cg->parent;
+		if (!cg)
+			break;
+		maxdepth = cg_md(cg)->maxdepth;
+		if ((maxdepth >= 0) && (depth > maxdepth))
+			return ERR_PTR(-EINVAL);
+		depth++;
+	}
+
+	md = kzalloc(sizeof(*md), GFP_KERNEL);
+	if (!md)
+		return ERR_PTR(-ENOMEM);
+	md->maxdepth = -1;
+	return &md->css;
+}
+
+static void md_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	kfree(cg_md(cont));
+}
+
+static s64 md_read(struct cgroup *cont, struct cftype *cft)
+{
+	return cg_md(cont)->maxdepth;
+}
+
+static int md_write(struct cgroup *cont, struct cftype *cft, s64 val)
+{
+	if ((val < -1) || (val >= INT_MAX))
+		return -EINVAL;
+	cg_md(cont)->maxdepth = val;
+	return 0;
+}
+
+static struct cftype md_files[] =  {
+	{
+		.name = "children",
+		.read_s64 = md_read,
+		.write_s64 = md_write,
+	}
+};
+
+static int md_populate(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	return cgroup_add_files(cont, ss, md_files, ARRAY_SIZE(md_files));
+}
+
+struct cgroup_subsys maxdepth_subsys = {
+	.name = "maxdepth",
+	.create = md_create,
+	.destroy = md_destroy,
+	.populate = md_populate,
+	.subsys_id = maxdepth_subsys_id,
+};
