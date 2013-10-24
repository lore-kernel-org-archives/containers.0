From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 02/20] audit: introduce configure option CONFIG_AUDIT_NS
Date: Thu, 24 Oct 2013 15:31:47 +0800
Message-ID: <1382599925-25143-3-git-send-email-gaofeng@cn.fujitsu.com>
References: <1382599925-25143-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1382599925-25143-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: toshi.okajima-+CUm20s59erQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch adds a new field audit_ns for struct
nsproxy, so task can access the audit_ns through
task->nsproxy->audit_ns.

Right now, we don't support create new audit_ns,
all tasks's audit_ns will point to the init_audit_ns.
next patches will add the feature creating new
audit namespace.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit_namespace.h | 51 +++++++++++++++++++++++++++++++++++++++++
 include/linux/nsproxy.h         | 11 +++++----
 init/Kconfig                    | 10 ++++++++
 kernel/Makefile                 |  2 +-
 kernel/audit_namespace.c        |  8 +++++++
 kernel/nsproxy.c                | 16 ++++++++++++-
 6 files changed, 91 insertions(+), 7 deletions(-)
 create mode 100644 include/linux/audit_namespace.h
 create mode 100644 kernel/audit_namespace.c

diff --git a/include/linux/audit_namespace.h b/include/linux/audit_namespace.h
new file mode 100644
index 0000000..ac22649
--- /dev/null
+++ b/include/linux/audit_namespace.h
@@ -0,0 +1,51 @@
+#ifndef __LINUX_AUDIT_NAMESPACE_H
+#define __LINUX_AUDIT_NAMESPACE_H
+
+#include <linux/audit.h>
+#include <linux/atomic.h>
+#include <linux/slab.h>
+#include <linux/user_namespace.h>
+
+struct audit_namespace {
+	atomic_t count;
+	struct user_namespace *user_ns;
+};
+
+extern struct audit_namespace init_audit_ns;
+
+#if defined(CONFIG_AUDIT_NS)
+static inline
+struct audit_namespace *get_audit_ns(struct audit_namespace *ns)
+{
+	atomic_inc(&ns->count);
+	return ns;
+}
+
+static inline
+void put_audit_ns(struct audit_namespace *ns)
+{
+	if (atomic_dec_and_test(&ns->count)) {
+		put_user_ns(ns->user_ns);
+		kfree(ns);
+	}
+}
+#else
+static inline
+struct audit_namespace *get_audit_ns(struct audit_namespace *ns)
+{
+	return ns;
+}
+
+static inline
+void put_audit_ns(struct audit_namespace *ns)
+{
+
+}
+#endif
+
+static inline struct
+audit_namespace *copy_audit_ns(struct audit_namespace *audit)
+{
+	return get_audit_ns(audit);
+}
+#endif
diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index b4ec59d..dc7af11 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -28,11 +28,12 @@ struct fs_struct;
  */
 struct nsproxy {
 	atomic_t count;
-	struct uts_namespace *uts_ns;
-	struct ipc_namespace *ipc_ns;
-	struct mnt_namespace *mnt_ns;
-	struct pid_namespace *pid_ns_for_children;
-	struct net 	     *net_ns;
+	struct uts_namespace	*uts_ns;
+	struct ipc_namespace	*ipc_ns;
+	struct mnt_namespace	*mnt_ns;
+	struct pid_namespace	*pid_ns_for_children;
+	struct net		*net_ns;
+	struct audit_namespace	*audit_ns;
 };
 extern struct nsproxy init_nsproxy;
 
diff --git a/init/Kconfig b/init/Kconfig
index 3ecd8a1..05e3d2c 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1154,6 +1154,16 @@ config NET_NS
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
 
+config AUDIT_NS
+	bool "Audit namespace"
+	depends on AUDIT
+	default n
+	help
+	  Support audit namespace.  This allows processes write audit message
+	  to the audit namespace they belong to.
+
+	  If unsure, say N.
+
 endif # NAMESPACES
 
 config UIDGID_STRICT_TYPE_CHECKS
diff --git a/kernel/Makefile b/kernel/Makefile
index 1ce4755..6e64333 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -71,7 +71,7 @@ obj-$(CONFIG_IKCONFIG) += configs.o
 obj-$(CONFIG_RESOURCE_COUNTERS) += res_counter.o
 obj-$(CONFIG_SMP) += stop_machine.o
 obj-$(CONFIG_KPROBES_SANITY_TEST) += test_kprobes.o
-obj-$(CONFIG_AUDIT) += audit.o auditfilter.o
+obj-$(CONFIG_AUDIT) += audit.o auditfilter.o audit_namespace.o
 obj-$(CONFIG_AUDITSYSCALL) += auditsc.o
 obj-$(CONFIG_AUDIT_WATCH) += audit_watch.o
 obj-$(CONFIG_AUDIT_TREE) += audit_tree.o
diff --git a/kernel/audit_namespace.c b/kernel/audit_namespace.c
new file mode 100644
index 0000000..6d9cb8f
--- /dev/null
+++ b/kernel/audit_namespace.c
@@ -0,0 +1,8 @@
+#include <linux/audit_namespace.h>
+#include <linux/export.h>
+
+struct audit_namespace init_audit_ns = {
+	.count = ATOMIC_INIT(1),
+	.user_ns = &init_user_ns,
+};
+EXPORT_SYMBOL_GPL(init_audit_ns);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 8e78110..e8374aa 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -22,6 +22,7 @@
 #include <linux/pid_namespace.h>
 #include <net/net_namespace.h>
 #include <linux/ipc_namespace.h>
+#include <linux/audit_namespace.h>
 #include <linux/proc_ns.h>
 #include <linux/file.h>
 #include <linux/syscalls.h>
@@ -39,6 +40,9 @@ struct nsproxy init_nsproxy = {
 #ifdef CONFIG_NET
 	.net_ns			= &init_net,
 #endif
+#ifdef CONFIG_AUDIT
+	.audit_ns		= &init_audit_ns,
+#endif
 };
 
 static inline struct nsproxy *create_nsproxy(void)
@@ -98,8 +102,16 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		goto out_net;
 	}
 
-	return new_nsp;
+	new_nsp->audit_ns = copy_audit_ns(tsk->nsproxy->audit_ns);
+	if (IS_ERR(new_nsp->audit_ns)) {
+		err = PTR_ERR(new_nsp->audit_ns);
+		goto out_audit;
+	}
 
+	return new_nsp;
+out_audit:
+	if (new_nsp->net_ns)
+		put_net(new_nsp->net_ns);
 out_net:
 	if (new_nsp->pid_ns_for_children)
 		put_pid_ns(new_nsp->pid_ns_for_children);
@@ -165,6 +177,8 @@ void free_nsproxy(struct nsproxy *ns)
 		put_ipc_ns(ns->ipc_ns);
 	if (ns->pid_ns_for_children)
 		put_pid_ns(ns->pid_ns_for_children);
+	if (ns->audit_ns)
+		put_audit_ns(ns->audit_ns);
 	put_net(ns->net_ns);
 	kmem_cache_free(nsproxy_cachep, ns);
 }
-- 
1.8.3.1
