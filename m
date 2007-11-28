From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch -mm 4/4] mqueue namespace: adapt sysctl
Date: Wed, 28 Nov 2007 17:37:32 +0100
Message-ID: <14283.0868870535$1196268638@news.gmane.org>
References: <20071128163728.177495768@fr.ibm.com>>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=mq_namespace-fix-sysctl.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

Largely inspired from ipc/ipc_sysctl.c. This patch isolates the mqueue 
sysctl stuff in its own file.

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 include/linux/mq_namespace.h |   10 +++
 init/Kconfig                 |    6 ++
 ipc/Makefile                 |    1 
 ipc/mq_sysctl.c              |  117 +++++++++++++++++++++++++++++++++++++++++++
 ipc/mqueue.c                 |   56 --------------------
 5 files changed, 135 insertions(+), 55 deletions(-)

Index: 2.6.24-rc3-mm2/ipc/mqueue.c
===================================================================
--- 2.6.24-rc3-mm2.orig/ipc/mqueue.c
+++ 2.6.24-rc3-mm2/ipc/mqueue.c
@@ -1230,60 +1230,6 @@ struct file_system_type mqueue_fs_type =
 	.kill_sb = kill_litter_super,
 };
 
-static int msg_max_limit_min = DFLT_MSGMAX;
-static int msg_max_limit_max = HARD_MSGMAX;
-
-static int msg_maxsize_limit_min = DFLT_MSGSIZEMAX;
-static int msg_maxsize_limit_max = INT_MAX;
-
-static ctl_table mq_sysctls[] = {
-	{
-		.procname	= "queues_max",
-		.data		= &init_mq_ns.queues_max,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
-	{
-		.procname	= "msg_max",
-		.data		= &init_mq_ns.msg_max,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.extra1		= &msg_max_limit_min,
-		.extra2		= &msg_max_limit_max,
-	},
-	{
-		.procname	= "msgsize_max",
-		.data		= &init_mq_ns.msgsize_max,
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
@@ -1295,7 +1241,7 @@ static int __init init_mqueue_fs(void)
 		return -ENOMEM;
 
 	/* ignore failues - they are not fatal */
-	mq_sysctl_table = register_sysctl_table(mq_sysctl_root);
+	mq_sysctl_table = mq_register_sysctl_table();
 
 	error = register_filesystem(&mqueue_fs_type);
 	if (error)
Index: 2.6.24-rc3-mm2/init/Kconfig
===================================================================
--- 2.6.24-rc3-mm2.orig/init/Kconfig
+++ 2.6.24-rc3-mm2/init/Kconfig
@@ -139,6 +139,12 @@ config POSIX_MQUEUE
 
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
Index: 2.6.24-rc3-mm2/ipc/Makefile
===================================================================
--- 2.6.24-rc3-mm2.orig/ipc/Makefile
+++ 2.6.24-rc3-mm2/ipc/Makefile
@@ -9,4 +9,5 @@ obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
 obj-$(CONFIG_MQ_NS) += mq_namespace.o
+obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
 
Index: 2.6.24-rc3-mm2/ipc/mq_sysctl.c
===================================================================
--- /dev/null
+++ 2.6.24-rc3-mm2/ipc/mq_sysctl.c
@@ -0,0 +1,117 @@
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
+#include <linux/mq_namespace.h>
+#include <linux/sysctl.h>
+
+
+static void *get_mq(ctl_table *table)
+{
+	char *which = table->data;
+	struct mq_namespace *mq_ns = current->nsproxy->mq_ns;
+	which = (which - (char *)&init_mq_ns) + (char *)mq_ns;
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
+#else
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
+#endif
+
+static int msg_max_limit_min = DFLT_MSGMAX;
+static int msg_max_limit_max = HARD_MSGMAX;
+
+static int msg_maxsize_limit_min = DFLT_MSGSIZEMAX;
+static int msg_maxsize_limit_max = INT_MAX;
+
+static ctl_table mq_sysctls[] = {
+	{
+		.procname	= "queues_max",
+		.data		= &init_mq_ns.queues_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_mq_dointvec,
+	},
+	{
+		.procname	= "msg_max",
+		.data		= &init_mq_ns.msg_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_mq_dointvec_minmax,
+		.extra1		= &msg_max_limit_min,
+		.extra2		= &msg_max_limit_max,
+	},
+	{
+		.procname	= "msgsize_max",
+		.data		= &init_mq_ns.msgsize_max,
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
Index: 2.6.24-rc3-mm2/include/linux/mq_namespace.h
===================================================================
--- 2.6.24-rc3-mm2.orig/include/linux/mq_namespace.h
+++ 2.6.24-rc3-mm2/include/linux/mq_namespace.h
@@ -70,4 +70,14 @@ static inline void put_mq_ns(struct mq_n
 
 #endif /* CONFIG_POSIX_MQUEUE */
 
+#ifdef CONFIG_POSIX_MQUEUE_SYSCTL
+struct ctl_table_header;
+extern struct ctl_table_header *mq_register_sysctl_table(void);
+#else
+static inline struct ctl_table_header *mq_register_sysctl_table(void)
+{
+	return NULL;
+}
+#endif /* CONFIG_POSIX_MQUEUE_SYSCTL */
+
 #endif /* _LINUX_MQ_H */

-- 
