From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] mqueue namespace: adapt sysctl
Date: Fri, 19 Dec 2008 11:20:59 -0600
Message-ID: <20081219172059.GC17381@us.ibm.com>
References: <20081219171930.GA17335@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081219171930.GA17335-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>

Largely inspired from ipc/ipc_sysctl.c. This patch isolates the mqueue
sysctl stuff in its own file.

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/ipc_namespace.h |   14 +++++
 init/Kconfig                  |    6 ++
 ipc/Makefile                  |    1 +
 ipc/mq_sysctl.c               |  125 +++++++++++++++++++++++++++++++++++++++++
 ipc/mqueue.c                  |   65 +---------------------
 5 files changed, 147 insertions(+), 64 deletions(-)
 create mode 100644 ipc/mq_sysctl.c

diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
index a73bbef..9f57f55 100644
--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -121,4 +121,18 @@ static inline void put_ipc_ns(struct ipc_namespace *ns)
 {
 }
 #endif
+
+#ifdef CONFIG_POSIX_MQUEUE_SYSCTL
+
+struct ctl_table_header;
+extern struct ctl_table_header *mq_register_sysctl_table(void);
+
+#else /* CONFIG_POSIX_MQUEUE_SYSCTL */
+
+static inline struct ctl_table_header *mq_register_sysctl_table(void)
+{
+	return NULL;
+}
+
+#endif /* CONFIG_POSIX_MQUEUE_SYSCTL */
 #endif
diff --git a/init/Kconfig b/init/Kconfig
index 32c6315..5d96f40 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -148,6 +148,12 @@ config POSIX_MQUEUE
 
 	  If unsure, say Y.
 
+config POSIX_MQUEUE_SYSCTL
+	bool
+	depends on POSIX_MQUEUE
+	depends on SYSCTL
+	default y
+
 config BSD_PROCESS_ACCT
 	bool "BSD Process Accounting"
 	help
diff --git a/ipc/Makefile b/ipc/Makefile
index 65c3843..4e1955e 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -8,4 +8,5 @@ obj-$(CONFIG_SYSVIPC_SYSCTL) += ipc_sysctl.o
 obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
+obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
 
diff --git a/ipc/mq_sysctl.c b/ipc/mq_sysctl.c
new file mode 100644
index 0000000..81f01b7
--- /dev/null
+++ b/ipc/mq_sysctl.c
@@ -0,0 +1,125 @@
+/*
+ *  Copyright (C) 2007 IBM Corporation
+ *
+ *  Author: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ */
+
+#include <linux/nsproxy.h>
+#include <linux/ipc_namespace.h>
+#include <linux/sysctl.h>
+
+/*
+ * Define the ranges various user-specified maximum values can
+ * be set to.
+ */
+#define MIN_MSGMAX	1		/* min value for msg_max */
+#define MAX_MSGMAX	HARD_MSGMAX	/* max value for msg_max */
+#define MIN_MSGSIZEMAX	128		/* min value for msgsize_max */
+#define MAX_MSGSIZEMAX	(8192*128)	/* max value for msgsize_max */
+
+static void *get_mq(ctl_table *table)
+{
+	char *which = table->data;
+	struct ipc_namespace *ipc_ns = current->nsproxy->ipc_ns;
+	which = (which - (char *)&init_ipc_ns) + (char *)ipc_ns;
+	return which;
+}
+
+#ifdef CONFIG_PROC_FS
+static int proc_mq_dointvec(ctl_table *table, int write, struct file *filp,
+	void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct ctl_table mq_table;
+	memcpy(&mq_table, table, sizeof(mq_table));
+	mq_table.data = get_mq(table);
+
+	return proc_dointvec(&mq_table, write, filp, buffer, lenp, ppos);
+}
+
+static int proc_mq_dointvec_minmax(ctl_table *table, int write,
+	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct ctl_table mq_table;
+	memcpy(&mq_table, table, sizeof(mq_table));
+	mq_table.data = get_mq(table);
+
+	return proc_dointvec_minmax(&mq_table, write, filp, buffer,
+					lenp, ppos);
+}
+#else /* CONFIG_PROC_FS */
+static int proc_mq_dointvec(ctl_table *table, int write, struct file *filp,
+	void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return -ENOSYS;
+}
+
+static int proc_mq_dointvec_minmax(ctl_table *table, int write,
+	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return -ENOSYS;
+}
+#endif /* CONFIG_PROC_FS */
+
+static int msg_max_limit_min = MIN_MSGMAX;
+static int msg_max_limit_max = MAX_MSGMAX;
+
+static int msg_maxsize_limit_min = MIN_MSGSIZEMAX;
+static int msg_maxsize_limit_max = MAX_MSGSIZEMAX;
+
+static ctl_table mq_sysctls[] = {
+	{
+		.procname	= "queues_max",
+		.data		= &init_ipc_ns.mq_queues_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_mq_dointvec,
+	},
+	{
+		.procname	= "msg_max",
+		.data		= &init_ipc_ns.mq_msg_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_mq_dointvec_minmax,
+		.extra1		= &msg_max_limit_min,
+		.extra2		= &msg_max_limit_max,
+	},
+	{
+		.procname	= "msgsize_max",
+		.data		= &init_ipc_ns.mq_msgsize_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_mq_dointvec_minmax,
+		.extra1		= &msg_maxsize_limit_min,
+		.extra2		= &msg_maxsize_limit_max,
+	},
+	{ .ctl_name = 0 }
+};
+
+static ctl_table mq_sysctl_dir[] = {
+	{
+		.procname	= "mqueue",
+		.mode		= 0555,
+		.child		= mq_sysctls,
+	},
+	{ .ctl_name = 0 }
+};
+
+static ctl_table mq_sysctl_root[] = {
+	{
+		.ctl_name	= CTL_FS,
+		.procname	= "fs",
+		.mode		= 0555,
+		.child		= mq_sysctl_dir,
+	},
+	{ .ctl_name = 0 }
+};
+
+struct ctl_table_header *mq_register_sysctl_table(void)
+{
+	return register_sysctl_table(mq_sysctl_root);
+}
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 464dc9d..827fddc 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -47,15 +47,6 @@
 #define STATE_PENDING	1
 #define STATE_READY	2
 
-/*
- * Define the ranges various user-specified maximum values can
- * be set to.
- */
-#define MIN_MSGMAX	1		/* min value for msg_max */
-#define MAX_MSGMAX	HARD_MSGMAX	/* max value for msg_max */
-#define MIN_MSGSIZEMAX	128		/* min value for msgsize_max */
-#define MAX_MSGSIZEMAX	(8192*128)	/* max value for msgsize_max */
-
 struct ext_wait_queue {		/* queue of sleeping tasks */
 	struct task_struct *task;
 	struct list_head list;
@@ -1295,60 +1286,6 @@ void mq_put_mnt(struct ipc_namespace *ns)
 	mntput(ns->mq_mnt);
 }
 
-static int msg_max_limit_min = MIN_MSGMAX;
-static int msg_max_limit_max = MAX_MSGMAX;
-
-static int msg_maxsize_limit_min = MIN_MSGSIZEMAX;
-static int msg_maxsize_limit_max = MAX_MSGSIZEMAX;
-
-static ctl_table mq_sysctls[] = {
-	{
-		.procname	= "queues_max",
-		.data		= &init_ipc_ns.mq_queues_max,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
-	{
-		.procname	= "msg_max",
-		.data		= &init_ipc_ns.mq_msg_max,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.extra1		= &msg_max_limit_min,
-		.extra2		= &msg_max_limit_max,
-	},
-	{
-		.procname	= "msgsize_max",
-		.data		= &init_ipc_ns.mq_msgsize_max,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.extra1		= &msg_maxsize_limit_min,
-		.extra2		= &msg_maxsize_limit_max,
-	},
-	{ .ctl_name = 0 }
-};
-
-static ctl_table mq_sysctl_dir[] = {
-	{
-		.procname	= "mqueue",
-		.mode		= 0555,
-		.child		= mq_sysctls,
-	},
-	{ .ctl_name = 0 }
-};
-
-static ctl_table mq_sysctl_root[] = {
-	{
-		.ctl_name	= CTL_FS,
-		.procname	= "fs",
-		.mode		= 0555,
-		.child		= mq_sysctl_dir,
-	},
-	{ .ctl_name = 0 }
-};
-
 static int __init init_mqueue_fs(void)
 {
 	int error;
@@ -1360,7 +1297,7 @@ static int __init init_mqueue_fs(void)
 		return -ENOMEM;
 
 	/* ignore failues - they are not fatal */
-	mq_sysctl_table = register_sysctl_table(mq_sysctl_root);
+	mq_sysctl_table = mq_register_sysctl_table();
 
 	error = register_filesystem(&mqueue_fs_type);
 	if (error)
-- 
1.5.4.3
