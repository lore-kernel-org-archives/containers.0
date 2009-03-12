From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 7/7] [RFC] Example multi-bindable subsystem: a per-cgroup
	notes field
Date: Thu, 12 Mar 2009 03:51:53 -0700
Message-ID: <20090312105153.24154.29389.stgit@menage.corp.google.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090312104507.24154.71691.stgit-B63HFAS8fGlSzHKm+aFRNNkmqwFzkYv6@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
List-Id: containers.vger.kernel.org

[RFC] Example multi-bindable subsystem: a per-cgroup notes field

As an example of a multiply-bindable subsystem, this patch introduces
the "info" subsystem, which provides a single file, "info.notes", in
which user-space middleware can store an arbitrary (up to one page)
string representing configuration data about that cgroup. This reduces
the need to keep additional state outside the cgroup filesystem.

TODO: a single page is somewhat limiting - the file limit should be
userspace-configurable, and the system should store large notes in a
vector of pages (to avoid trying to kmalloc() an excessively large
chunk of memory. (Or maybe just use vmalloc())

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 include/linux/cgroup_subsys.h |    6 +++
 init/Kconfig                  |    8 ++++
 kernel/Makefile               |    1 
 kernel/info_cgroup.c          |   93 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 108 insertions(+), 0 deletions(-)
 create mode 100644 kernel/info_cgroup.c

diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index f78605e..5dfea38 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -60,3 +60,9 @@ SUBSYS(net_cls)
 #endif
 
 /* */
+
+#ifdef CONFIG_CGROUP_INFO
+MULTI_SUBSYS(info)
+#endif
+
+/* */
diff --git a/init/Kconfig b/init/Kconfig
index fd5e3be..018601b 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -604,6 +604,14 @@ config CGROUP_MEM_RES_CTLR_SWAP
 	  there will be no overhead from this. Even when you set this config=y,
 	  if boot option "noswapaccount" is set, swap will not be accounted.
 
+config CGROUP_INFO
+	bool "Simple application-specific info cgroup subsystem
+	help
+	  Provides a simple cgroups subsystem with an "info.notes"
+	  field, which can be used by middleware to store
+	  application-specific configuration data about a cgroup. Can
+	  be mounted on multiple hierarchies at once.
+
 endif # CGROUPS
 
 config MM_OWNER
diff --git a/kernel/Makefile b/kernel/Makefile
index bdc528f..782752f 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -60,6 +60,7 @@ obj-$(CONFIG_CGROUPS) += cgroup.o
 obj-$(CONFIG_CGROUP_FREEZER) += cgroup_freezer.o
 obj-$(CONFIG_CPUSETS) += cpuset.o
 obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
+obj-$(CONFIG_CGROUP_INFO) += info_cgroup.o
 obj-$(CONFIG_UTS_NS) += utsname.o
 obj-$(CONFIG_USER_NS) += user_namespace.o
 obj-$(CONFIG_PID_NS) += pid_namespace.o
diff --git a/kernel/info_cgroup.c b/kernel/info_cgroup.c
new file mode 100644
index 0000000..b8fdb37
--- /dev/null
+++ b/kernel/info_cgroup.c
@@ -0,0 +1,93 @@
+/*
+ * info_cgroup.c - simple cgroup providing a "notes" field
+ */
+
+#include "linux/cgroup.h"
+#include "linux/err.h"
+#include "linux/seq_file.h"
+
+#define MAX_NOTES_LEN PAGE_SIZE
+
+struct info_cgroup {
+	struct cgroup_subsys_state css;
+	const char *notes;
+	spinlock_t lock;
+};
+
+static inline struct info_cgroup *cg_info(struct cgroup *cg)
+{
+	return container_of(cgroup_subsys_state(cg, info_subsys_id),
+			    struct info_cgroup, css);
+}
+
+static struct cgroup_subsys_state *info_create(struct cgroup_subsys *ss,
+					       struct cgroup *cg)
+{
+	struct info_cgroup *info = kzalloc(sizeof(*info), GFP_KERNEL);
+	if (!info)
+		return ERR_PTR(-ENOMEM);
+	spin_lock_init(&info->lock);
+	return &info->css;
+}
+
+static void info_destroy(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	struct info_cgroup *css = cg_info(cont);
+	kfree(css->notes);
+	kfree(css);
+}
+
+static int info_read(struct cgroup *cont,
+		     struct cftype *cft,
+		     struct seq_file *seq)
+{
+	struct info_cgroup *css = cg_info(cont);
+	spin_lock(&css->lock);
+	if (css->notes)
+		seq_puts(seq, css->notes);
+	spin_unlock(&css->lock);
+	return 0;
+}
+
+static int info_write(struct cgroup *cont,
+		      struct cftype *cft,
+		      const char *str) {
+	struct info_cgroup *css = cg_info(cont);
+	if (*str) {
+		if (strlen(str) > MAX_NOTES_LEN)
+			return -ENOSPC;
+		str = kstrdup(str, GFP_KERNEL);
+		if (!str)
+			return -ENOMEM;
+	} else {
+		str = NULL;
+	}
+
+	spin_lock(&css->lock);
+	kfree(css->notes);
+	css->notes = str;
+	spin_unlock(&css->lock);
+	return 0;
+}
+
+static struct cftype info_files[] =  {
+	{
+		.name = "notes",
+		.read_seq_string = info_read,
+		.write_string = info_write,
+	},
+};
+
+static int info_populate(struct cgroup_subsys *ss, struct cgroup *cont)
+{
+	return cgroup_add_files(cont, ss, info_files,
+				ARRAY_SIZE(info_files));
+}
+
+struct cgroup_subsys info_subsys = {
+	.name = "info",
+	.create = info_create,
+	.destroy = info_destroy,
+	.populate = info_populate,
+	.subsys_id = info_subsys_id,
+};
