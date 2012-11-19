From: Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RFC 1/5] Syslog_ns: add syslog_namespace struct and API
Date: Mon, 19 Nov 2012 16:16:29 +0800
Message-ID: <50A9EADD.4040709__39328.5166858279$1353313021$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Xiang Rui <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

This patch add a struct syslog_namespace which contains the necessary member
when handling syslog.

We realize gut_syslog_ns and put_syslog_ns API, and syslog_ns is initialized
by init_syslog_ns. CONFIG_SYSLOG_NS is defined to allow to create syslog_ns.

Signed-off-by: Xiang Rui <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/linux/syslog_namespace.h |   78 ++++++++++++++++++++++++++++++++++++++
 init/Kconfig                     |    7 +++
 kernel/Makefile                  |    1 +
 kernel/syslog_namespace.c        |   31 +++++++++++++++
 4 files changed, 117 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/syslog_namespace.h
 create mode 100644 kernel/syslog_namespace.c

diff --git a/include/linux/syslog_namespace.h b/include/linux/syslog_namespace.h
new file mode 100644
index 0000000..8c8ac5a
--- /dev/null
+++ b/include/linux/syslog_namespace.h
@@ -0,0 +1,78 @@
+#ifndef _LINUX_SYSLOG_NAMESPACE_H
+#define _LINUX_SYSLOG_NAMESPACE_H
+
+#include <linux/kref.h>
+
+/* record buffer */
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+#define LOG_ALIGN 4
+#else
+#define LOG_ALIGN __alignof__(struct log)
+#endif
+
+#define CONTAINER_BUF_LEN 4096
+
+#define __LOG_BUF_LEN (1 << CONFIG_LOG_BUF_SHIFT)
+
+struct syslog_namespace {
+	struct kref kref;       /* syslog_ns reference count & control */
+
+	raw_spinlock_t logbuf_lock; /* access conflict locker */
+
+	/* index and sequence number of the first record stored in the buffer */
+	u64 log_first_seq;
+	u32 log_first_idx;
+
+	/* index and sequence number of the next record stored in the buffer */
+	u64 log_next_seq;
+	u32 log_next_idx;
+
+	/* the next printk record to read after the last 'clear' command */
+	u64 clear_seq;
+	u32 clear_idx;
+
+	char *log_buf;
+	u32 log_buf_len;
+
+	/* the next printk record to write to the console */
+	u64 console_seq;
+	u32 console_idx;
+
+	/* the next printk record to read by syslog(READ) or /proc/kmsg */
+	u64 syslog_seq;
+	u32 syslog_idx;
+	int  syslog_prev;
+	size_t syslog_partial;
+};
+
+extern struct syslog_namespace init_syslog_ns;
+
+#ifdef CONFIG_SYSLOG_NS
+extern void free_syslog_ns(struct kref *kref);
+static inline struct syslog_namespace *get_syslog_ns(
+				struct syslog_namespace *ns)
+{
+	if (ns != &init_syslog_ns)
+		kref_get(&ns->kref);
+	return ns;
+}
+
+static inline void put_syslog_ns(struct syslog_namespace *ns)
+{
+	if (ns != &init_syslog_ns)
+		kref_put(&ns->kref, free_syslog_ns);
+}
+
+#else
+static inline struct syslog_namespace *get_syslog_ns(
+				struct syslog_namespace *ns)
+{
+	return ns;
+}
+
+static inline void put_syslog_ns(struct syslog_namespace *ns)
+{
+}
+#endif
+
+#endif
diff --git a/init/Kconfig b/init/Kconfig
index 6fdd6e3..82771e0 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -988,6 +988,13 @@ config NET_NS
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.

+config SYSLOG_NS
+	bool "Syslog namespace"
+	default y
+	help
+	  Allow containers to use syslog namespaces to provide different
+	  syslog for containers.
+
 endif # NAMESPACES

 config UIDGID_CONVERTED
diff --git a/kernel/Makefile b/kernel/Makefile
index 0dfeca4..cb3cba0 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -28,6 +28,7 @@ obj-y += power/
 ifeq ($(CONFIG_CHECKPOINT_RESTORE),y)
 obj-$(CONFIG_X86) += kcmp.o
 endif
+obj-$(CONFIG_SYSLOG_NS) += syslog_namespace.o
 obj-$(CONFIG_FREEZER) += freezer.o
 obj-$(CONFIG_PROFILING) += profile.o
 obj-$(CONFIG_STACKTRACE) += stacktrace.o
diff --git a/kernel/syslog_namespace.c b/kernel/syslog_namespace.c
new file mode 100644
index 0000000..9482927
--- /dev/null
+++ b/kernel/syslog_namespace.c
@@ -0,0 +1,31 @@
+/*
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ */
+
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/syslog_namespace.h>
+
+static char __log_buf[__LOG_BUF_LEN] __aligned(LOG_ALIGN);
+
+struct syslog_namespace init_syslog_ns = {
+	.kref = {
+		.refcount = ATOMIC_INIT(2),
+	},
+	.logbuf_lock = __RAW_SPIN_LOCK_UNLOCKED(init_syslog_ns.logbuf_lock),
+	.log_buf_len = __LOG_BUF_LEN,
+	.log_buf = __log_buf,
+};
+EXPORT_SYMBOL_GPL(init_syslog_ns);
+
+void free_syslog_ns(struct kref *kref)
+{
+	struct syslog_namespace *ns;
+	ns = container_of(kref, struct syslog_namespace, kref);
+
+	kfree(ns->log_buf);
+	kfree(ns);
+}
-- 
1.7.1
