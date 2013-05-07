From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 42/48] Audit: selinux: translate audit_log_start to
	audit_log_start_ns
Date: Tue, 7 May 2013 10:21:03 +0800
Message-ID: <1367893269-9308-43-git-send-email-gaofeng__45511.3798300319$1367893493$gmane$org@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1367893269-9308-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Now we can log audit message in the user namespace which current
task belongs to.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 security/selinux/hooks.c       | 14 ++++++++++----
 security/selinux/ss/services.c |  8 +++++---
 2 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 5c6f2cd..93b6c72 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2785,6 +2785,7 @@ static int selinux_inode_setxattr(struct dentry *dentry, const char *name,
 			struct audit_buffer *ab;
 			size_t audit_size;
 			const char *str;
+			struct user_namespace *ns = current_user_ns();
 
 			/* We strip a nul only if it is at the end, otherwise the
 			 * context contains a nul and we should audit that */
@@ -2798,10 +2799,11 @@ static int selinux_inode_setxattr(struct dentry *dentry, const char *name,
 				str = "";
 				audit_size = 0;
 			}
-			ab = audit_log_start(current->audit_context, GFP_ATOMIC, AUDIT_SELINUX_ERR);
+			ab = audit_log_start_ns(ns, current->audit_context,
+						GFP_ATOMIC, AUDIT_SELINUX_ERR);
 			audit_log_format(ab, "op=setxattr invalid_context=");
 			audit_log_n_untrustedstring(ab, value, audit_size);
-			audit_log_end(ab);
+			audit_log_end_ns(ns, ab);
 
 			return rc;
 		}
@@ -5328,6 +5330,7 @@ static int selinux_setprocattr(struct task_struct *p,
 			if (!capable(CAP_MAC_ADMIN)) {
 				struct audit_buffer *ab;
 				size_t audit_size;
+				struct user_namespace *ns = current_user_ns();
 
 				/* We strip a nul only if it is at the end, otherwise the
 				 * context contains a nul and we should audit that */
@@ -5335,10 +5338,13 @@ static int selinux_setprocattr(struct task_struct *p,
 					audit_size = size - 1;
 				else
 					audit_size = size;
-				ab = audit_log_start(current->audit_context, GFP_ATOMIC, AUDIT_SELINUX_ERR);
+				ab = audit_log_start_ns(ns,
+							current->audit_context,
+							GFP_ATOMIC,
+							AUDIT_SELINUX_ERR);
 				audit_log_format(ab, "op=fscreate invalid_context=");
 				audit_log_n_untrustedstring(ab, value, audit_size);
-				audit_log_end(ab);
+				audit_log_end_ns(ns, ab);
 
 				return error;
 			}
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index b4feecc..140a383 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -473,6 +473,7 @@ static void security_dump_masked_av(struct context *scontext,
 	int index;
 	u32 length;
 	bool need_comma = false;
+	struct user_namespace *ns;
 
 	if (!permissions)
 		return;
@@ -501,8 +502,9 @@ static void security_dump_masked_av(struct context *scontext,
 		goto out;
 
 	/* audit a message */
-	ab = audit_log_start(current->audit_context,
-			     GFP_ATOMIC, AUDIT_SELINUX_ERR);
+	ns = current_user_ns();
+	ab = audit_log_start_ns(ns, current->audit_context,
+				GFP_ATOMIC, AUDIT_SELINUX_ERR);
 	if (!ab)
 		goto out;
 
@@ -522,7 +524,7 @@ static void security_dump_masked_av(struct context *scontext,
 				 ? permission_names[index] : "????");
 		need_comma = true;
 	}
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 out:
 	/* release scontext/tcontext */
 	kfree(tcontext_name);
-- 
1.8.1.4
