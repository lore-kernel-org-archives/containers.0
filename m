From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 15/20] audit: Log audit pid config change in audit namespace
Date: Thu, 24 Oct 2013 15:32:00 +0800
Message-ID: <1382599925-25143-16-git-send-email-gaofeng@cn.fujitsu.com>
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

This patch allow to log audit config change in
audit namespace.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/audit.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index 92da21d..095f54d 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -252,13 +252,15 @@ void audit_log_lost(const char *message)
 	}
 }
 
-static int audit_log_config_change(char *function_name, int new, int old,
+static int audit_log_config_change(struct audit_namespace *ns,
+				   char *function_name,
+				   int new, int old,
 				   int allow_changes)
 {
 	struct audit_buffer *ab;
 	int rc = 0;
 
-	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
+	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
 	if (unlikely(!ab))
 		return rc;
 	audit_log_format(ab, "%s=%d old=%d", function_name, new, old);
@@ -267,7 +269,7 @@ static int audit_log_config_change(char *function_name, int new, int old,
 	if (rc)
 		allow_changes = 0; /* Something weird, deny request */
 	audit_log_format(ab, " res=%d", allow_changes);
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 	return rc;
 }
 
@@ -282,7 +284,10 @@ static int audit_do_config_change(char *function_name, int *to_change, int new)
 		allow_changes = 1;
 
 	if (audit_enabled != AUDIT_OFF) {
-		rc = audit_log_config_change(function_name, new, old, allow_changes);
+		rc = audit_log_config_change(&init_audit_ns,
+					     function_name,
+					     new, old,
+					     allow_changes);
 		if (rc)
 			allow_changes = 0;
 	}
@@ -697,7 +702,10 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 				new_pid = task_pid_nr_ns(task, &init_pid_ns);
 
 			if (audit_enabled != AUDIT_OFF)
-				audit_log_config_change("audit_pid", new_pid, ns->pid, 1);
+				audit_log_config_change(&init_audit_ns,
+							"audit_pid",
+							new_pid,
+							ns->pid, 1);
 
 			ns->pid = new_pid;
 			rcu_read_unlock();
-- 
1.8.3.1
