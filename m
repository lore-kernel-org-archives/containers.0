From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 4/4] mqueue namespace: adapt sysctl
Date: Tue, 24 Feb 2009 16:02:56 -0600
Message-ID: <20090224220256.GA31001@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760929AbZBXWDX@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, Cedric Le Goater <clg@fr.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Largely inspired from ipc/ipc_sysctl.c. This patch isolates the mqueue
sysctl stuff in its own file.

Changelog:
	Feb 24: comments from Alexey Dobriyan:
		1. put proc handlers under CONFIG_PROC_SYSCTL and
		   make them NULL otherwise.
		2. remove & from proc_handler when assigned to
		   ctl_table.

Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
Signed-off-by: Nadia Derbey <Nadia.Derbey@bull.net>
Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/linux/ipc_namespace.h |   14 +++++
 init/Kconfig                  |    6 ++
 ipc/Makefile                  |    1 +
 ipc/mq_sysctl.c               |  116 +++++++++++++++++++++++++++++++++++++++++
 ipc/mqueue.c                  |   65 +----------------------
 5 files changed, 138 insertions(+), 64 deletions(-)
 create mode 100644 ipc/mq_sysctl.c

diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
index 3392d50..3bf40e2 100644
--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -128,4 +128,18 @@ static inline void put_ipc_ns(struct ipc_namespace *ns)
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
index 53afa38..ee70d25 100644
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
index 0000000..b542a1d
--- /dev/null
+++ b/ipc/mq_sysctl.c
@@ -0,0 +1,116 @@
+/*
+ *  Copyright (C) 2007 IBM Corporation
+ *
+ *  Author: Cedric Le Goater <clg@fr.ibm.com>
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
+#ifdef CONFIG_PROC_SYSCTL
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
+#else
+proc_handler *proc_mq_dointvec = NULL;
+proc_handler *proc_mq_dointvec_minmax = NULL;
+#endif
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
+		.proc_handler	= proc_mq_dointvec,
+	},
+	{
+		.procname	= "msg_max",
+		.data		= &init_ipc_ns.mq_msg_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_mq_dointvec_minmax,
+		.extra1		= &msg_max_limit_min,
+		.extra2		= &msg_max_limit_max,
+	},
+	{
+		.procname	= "msgsize_max",
+		.data		= &init_ipc_ns.mq_msgsize_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_mq_dointvec_minmax,
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
index 3e016e9..7f10fde 100644
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
@@ -1271,60 +1262,6 @@ void mq_put_mnt(struct ipc_namespace *ns)
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
@@ -1336,7 +1273,7 @@ static int __init init_mqueue_fs(void)
 		return -ENOMEM;
 
 	/* ignore failues - they are not fatal */
-	mq_sysctl_table = register_sysctl_table(mq_sysctl_root);
+	mq_sysctl_table = mq_register_sysctl_table();
 
 	error = register_filesystem(&mqueue_fs_type);
 	if (error)
-- 
1.5.4.3
