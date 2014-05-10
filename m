From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V2 6/6] audit: convert namespace serial number logging to use
	proc ns_entries
Date: Fri,  9 May 2014 20:27:27 -0400
Message-ID: <d7f26c13de9ad02b10a9e334c6b13848c2dc8435.1399681022.git.rgb__27903.8008804948$1399681746$gmane$org@redhat.com>
References: <cover.1399681022.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1399681022.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1399681022.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References: <cover.1399681022.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

Convert audit direct access to namespace serial numbers to insead use the proc
namespace operations structure which lists all namespace types with a
consistent api.

This should eventually squash down to: [audit: log namespace serial numbers]
(which in turn will need to follow [namespaces: expose ns_entries])

Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 kernel/audit.c |   43 ++++++++++++-------------------------------
 1 files changed, 12 insertions(+), 31 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index fe783ad..6452278 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -64,15 +64,7 @@
 #endif
 #include <linux/freezer.h>
 #include <linux/tty.h>
-#include <linux/nsproxy.h>
-#include <linux/utsname.h>
-#include <linux/ipc_namespace.h>
-#include "../fs/mount.h"
-#include <linux/mount.h>
-#include <linux/mnt_namespace.h>
-#include <linux/pid_namespace.h>
-#include <net/net_namespace.h>
-#include <linux/user_namespace.h>
+#include <linux/proc_ns.h>
 #include <net/netns/generic.h>
 
 #include "audit.h"
@@ -1628,29 +1620,18 @@ void audit_log_session_info(struct audit_buffer *ab)
 #ifdef CONFIG_NAMESPACES
 void audit_log_namespace_info(struct audit_buffer *ab, struct task_struct *tsk)
 {
-	struct nsproxy *nsproxy;
-
-	rcu_read_lock();
-	nsproxy = task_nsproxy(tsk);
-	if (nsproxy != NULL) {
-		audit_log_format(ab, " mntns=%llx", nsproxy->mnt_ns->serial_num);
-#ifdef CONFIG_NET_NS
-		audit_log_format(ab, " netns=%llx", nsproxy->net_ns->serial_num);
-#endif
-#ifdef CONFIG_UTS_NS
-		audit_log_format(ab, " utsns=%llx", nsproxy->uts_ns->serial_num);
-#endif
-#ifdef CONFIG_IPC_NS
-		audit_log_format(ab, " ipcns=%llx", nsproxy->ipc_ns->serial_num);
-#endif
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
 	}
-#ifdef CONFIG_PID_NS
-	audit_log_format(ab, " pidns=%llx", task_active_pid_ns(tsk)->serial_num);
-#endif
-#ifdef CONFIG_USER_NS
-	audit_log_format(ab, " userns=%llx", task_cred_xxx(tsk, user_ns)->serial_num);
-#endif
-	rcu_read_unlock();
 }
 #endif /* CONFIG_NAMESPACES */
 
-- 
1.7.1
