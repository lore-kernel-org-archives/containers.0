From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V7 09/10] audit: log on switching namespace (setns)
Date: Tue, 12 May 2015 16:02:46 -0400
Message-ID: <e34d0a4b8d18ee5f9ee18917c0626050cd6d407e.1431451547.git.rgb__38300.7195116535$1431461093$gmane$org@redhat.com>
References: <cover.1431451547.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1431451547.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1431451547.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References: <cover.1431451547.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Added six new audit message types, AUDIT_NS_SET_* and function
audit_log_ns_set() to log a switch of namespace.

Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/linux/audit.h      |    5 ++++
 include/uapi/linux/audit.h |    6 +++++
 kernel/audit.c             |   51 ++++++++++++++++++++++++++++++++++++++++++++
 kernel/nsproxy.c           |    2 +
 4 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index f922ea6..9adb538 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -490,6 +490,7 @@ extern void		    audit_log_ns_info(struct task_struct *tsk);
 extern void		    audit_log_ns_init(int type, struct ns_common *old_ns,
 					      struct ns_common *ns);
 extern void		    audit_log_ns_del(int type, struct ns_common *ns);
+extern void		    audit_log_ns_set(struct ns_common *ns);
 #else
 static inline void	    audit_log_ns_info(struct task_struct *tsk)
 { }
@@ -498,6 +499,8 @@ static inline void	    audit_log_ns_init(int type, struct ns_common *old_ns,
 { }
 static inline void	    audit_log_ns_del(int type, struct ns_common *ns)
 { }
+static inline void	    audit_log_ns_set(struct ns_common *ns)
+{ }
 #endif
 
 extern int		    audit_update_lsm_rules(void);
@@ -562,6 +565,8 @@ static inline void audit_log_ns_init(int type, struct ns_common *old_ns,
 { }
 static inline void audit_log_ns_del(int type, struct ns_common *ns)
 { }
+static inline void audit_log_ns_set(struct ns_common *ns)
+{ }
 #define audit_enabled 0
 #endif /* CONFIG_AUDIT */
 static inline void audit_log_string(struct audit_buffer *ab, const char *buf)
diff --git a/include/uapi/linux/audit.h b/include/uapi/linux/audit.h
index c4b7f15..55da5c7 100644
--- a/include/uapi/linux/audit.h
+++ b/include/uapi/linux/audit.h
@@ -123,6 +123,12 @@
 #define AUDIT_NS_DEL_USER	1339	/* Record USER namespace instance deletion */
 #define AUDIT_NS_DEL_PID	1340	/* Record PID namespace instance deletion */
 #define AUDIT_NS_DEL_NET	1341	/* Record NET namespace instance deletion */
+#define AUDIT_NS_SET_MNT	1342	/* Record mount namespace instance deletion */
+#define AUDIT_NS_SET_UTS	1343	/* Record UTS namespace instance deletion */
+#define AUDIT_NS_SET_IPC	1344	/* Record IPC namespace instance deletion */
+#define AUDIT_NS_SET_USER	1345	/* Record USER namespace instance deletion */
+#define AUDIT_NS_SET_PID	1346	/* Record PID namespace instance deletion */
+#define AUDIT_NS_SET_NET	1347	/* Record NET namespace instance deletion */
 
 #define AUDIT_AVC		1400	/* SE Linux avc denial or grant */
 #define AUDIT_SELINUX_ERR	1401	/* Internal SE Linux Errors */
diff --git a/kernel/audit.c b/kernel/audit.c
index af143b5..97fcb64 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -2044,6 +2044,57 @@ void audit_log_ns_del(int type, struct ns_common *ns)
 			 ns->inum);
 	audit_log_end(ab);
 }
+
+/**
+ * audit_log_ns_set - report a namespace set change
+ * @ns: the new namespace
+ */
+void audit_log_ns_set(struct ns_common *ns)
+{
+	struct audit_buffer *ab;
+	struct ns_common *old_ns;
+	int msg_type;
+	char old_ns_s[16];
+
+	if (!audit_enabled)
+		return;
+
+	switch (ns->ops->type) {
+	case CLONE_NEWNS:
+		msg_type = AUDIT_NS_SET_MNT;
+		break;
+	case CLONE_NEWUTS:
+		msg_type = AUDIT_NS_SET_UTS;
+		break;
+	case CLONE_NEWIPC:
+		msg_type = AUDIT_NS_SET_IPC;
+		break;
+	case CLONE_NEWUSER:
+		msg_type = AUDIT_NS_SET_USER;
+		break;
+	case CLONE_NEWPID:
+		msg_type = AUDIT_NS_SET_PID;
+		break;
+	case CLONE_NEWNET:
+		msg_type = AUDIT_NS_SET_NET;
+		break;
+	default:
+		return;
+	}
+	ab = audit_log_start(current->audit_context, GFP_KERNEL, ns->ops->type);
+	if (unlikely(!ab))
+		return;
+	old_ns = ns->ops->get(current);
+	if (!old_ns->inum)
+		sprintf(old_ns_s, "(none)");
+	else
+		sprintf(old_ns_s, "%d", old_ns->inum);
+	audit_log_format(ab, " dev=%02x:%02x old_%sns=%s %sns=%d res=1",
+			 MAJOR(ns->dev), MINOR(ns->dev), ns->ops->name,
+			 old_ns_s, ns->ops->name, ns->inum);
+	ns->ops->put(old_ns);
+	audit_log_end(ab);
+}
 #endif /* CONFIG_NAMESPACES */
 
 /**
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 49746c8..64147d0 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -25,6 +25,7 @@
 #include <linux/proc_ns.h>
 #include <linux/file.h>
 #include <linux/syscalls.h>
+#include <linux/audit.h>
 
 static struct kmem_cache *nsproxy_cachep;
 
@@ -246,6 +247,7 @@ SYSCALL_DEFINE2(setns, int, fd, int, nstype)
 		free_nsproxy(new_nsproxy);
 		goto out;
 	}
+	audit_log_ns_set(ns);
 	switch_task_namespaces(tsk, new_nsproxy);
 out:
 	fput(file);
-- 
1.7.1
