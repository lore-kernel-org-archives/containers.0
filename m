From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V3 5/6] audit: log namespace serial numbers
Date: Tue, 20 May 2014 09:12:06 -0400
Message-ID: <b3179496aaed0eca9a2f21e752e4d5417bea6027.1400271129.git.rgb__1688.21781776405$1400591625$gmane$org@redhat.com>
References: <cover.1400271129.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1400271129.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1400271129.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References: <cover.1400271129.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Log the namespace serial numbers of a task in audit_log_task_info() which
is used by syscall audits, among others..

Idea first presented:
	https://www.redhat.com/archives/linux-audit/2013-March/msg00020.html

Typical output format would look something like:
	        type=SYSCALL msg=audit(1399651071.433:72): arch=c000003e syscall=272 success=yes exit=0 a0=40000000 a1=ffffffffffffffff a2=0 a3=22 items=0 ppid=1 pid=483 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="(t-daemon)" exe="/usr/lib/systemd/systemd" netns=97 utsns=2 ipcns=1 pidns=4 userns=3 mntns=5 subj=system_u:system_r:init_t:s0 key=(null)

The serial numbers are printed in hex.

Suggested-by: Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 include/linux/audit.h |    7 +++++++
 kernel/audit.c        |   21 ++++++++++++++++++++-
 2 files changed, 27 insertions(+), 1 deletions(-)

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
index 59c0bbe..6452278 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -64,7 +64,7 @@
 #endif
 #include <linux/freezer.h>
 #include <linux/tty.h>
-#include <linux/pid_namespace.h>
+#include <linux/proc_ns.h>
 #include <net/netns/generic.h>
 
 #include "audit.h"
@@ -1617,6 +1617,24 @@ void audit_log_session_info(struct audit_buffer *ab)
 	audit_log_format(ab, " auid=%u ses=%u", auid, sessionid);
 }
 
+#ifdef CONFIG_NAMESPACES
+void audit_log_namespace_info(struct audit_buffer *ab, struct task_struct *tsk)
+{
+	const struct proc_ns_operations **entry;
+	bool end = false;
+
+	if (!tsk)
+		return;
+	for (entry = ns_entries; !end; entry++) {
+		void *ns = (*entry)->get(tsk);
+		audit_log_format(ab, " %sns=%llx", (*entry)->name,
+				 (*entry)->snum(ns));
+		(*entry)->put(ns);
+		end = (*entry)->type == CLONE_NEWNS;
+	}
+}
+#endif /* CONFIG_NAMESPACES */
+
 void audit_log_key(struct audit_buffer *ab, char *key)
 {
 	audit_log_format(ab, " key=");
@@ -1861,6 +1879,7 @@ void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk)
 		up_read(&mm->mmap_sem);
 	} else
 		audit_log_format(ab, " exe=(null)");
+	audit_log_namespace_info(ab, tsk);
 	audit_log_task_context(ab);
 }
 EXPORT_SYMBOL(audit_log_task_info);
-- 
1.7.1
