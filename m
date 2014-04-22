From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] audit: log namespace serial numbers
Date: Tue, 22 Apr 2014 14:12:53 -0400
Message-ID: <644ef842bae19c55ae11af07e9fd7ac0ec9c74a1.1398176489.git.rgb@redhat.com>
References: <cover.1398176489.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1398176489.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1398176489.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References: <cover.1398176489.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Log the namespace details of a task.

Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/linux/audit.h |    7 +++++++
 kernel/audit.c        |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 22cfddb..0ef404a 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -101,6 +101,13 @@ extern int __weak audit_classify_compat_syscall(int abi, unsigned syscall);
 struct filename;
 
 extern void audit_log_session_info(struct audit_buffer *ab);
+#ifdef CONFIG_NAMESPACES
+extern void audit_log_namespace_info(struct audit_buffer *ab, struct task_struct *tsk);
+#else
+void audit_log_namespace_info(struct audit_buffer *ab, struct task_struct *tsk)
+{
+}
+#endif
 
 #ifdef CONFIG_AUDIT_COMPAT_GENERIC
 #define audit_is_compat(arch)  (!((arch) & __AUDIT_ARCH_64BIT))
diff --git a/kernel/audit.c b/kernel/audit.c
index 59c0bbe..9049049 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -64,7 +64,15 @@
 #endif
 #include <linux/freezer.h>
 #include <linux/tty.h>
+#include <linux/nsproxy.h>
+#include <linux/utsname.h>
+#include <linux/ipc_namespace.h>
+#include "../fs/mount.h"
+#include <linux/mount.h>
+#include <linux/mnt_namespace.h>
 #include <linux/pid_namespace.h>
+#include <net/net_namespace.h>
+#include <linux/user_namespace.h>
 #include <net/netns/generic.h>
 
 #include "audit.h"
@@ -1617,6 +1625,35 @@ void audit_log_session_info(struct audit_buffer *ab)
 	audit_log_format(ab, " auid=%u ses=%u", auid, sessionid);
 }
 
+#ifdef CONFIG_NAMESPACES
+void audit_log_namespace_info(struct audit_buffer *ab, struct task_struct *tsk)
+{
+	struct nsproxy *nsproxy;
+
+	rcu_read_lock();
+	nsproxy = task_nsproxy(tsk);
+	if (nsproxy != NULL) {
+		audit_log_format(ab, " mntns=%x", nsproxy->mnt_ns->serial_num);
+#ifdef CONFIG_NET_NS
+		audit_log_format(ab, " netns=%x", nsproxy->net_ns->serial_num);
+#endif
+#ifdef CONFIG_UTS_NS
+		audit_log_format(ab, " utsns=%x", nsproxy->uts_ns->serial_num);
+#endif
+#ifdef CONFIG_IPC_NS
+		audit_log_format(ab, " ipcns=%x", nsproxy->ipc_ns->serial_num);
+#endif
+	}
+#ifdef CONFIG_PID_NS
+	audit_log_format(ab, " pidns=%x", task_active_pid_ns(tsk)->serial_num);
+#endif
+#ifdef CONFIG_USER_NS
+	audit_log_format(ab, " userns=%x", task_cred_xxx(tsk, user_ns)->serial_num);
+#endif
+	rcu_read_unlock();
+}
+#endif /* CONFIG_NAMESPACES */
+
 void audit_log_key(struct audit_buffer *ab, char *key)
 {
 	audit_log_format(ab, " key=");
@@ -1861,6 +1898,7 @@ void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk)
 		up_read(&mm->mmap_sem);
 	} else
 		audit_log_format(ab, " exe=(null)");
+	audit_log_namespace_info(ab, tsk);
 	audit_log_task_context(ab);
 }
 EXPORT_SYMBOL(audit_log_task_info);
-- 
1.7.1
