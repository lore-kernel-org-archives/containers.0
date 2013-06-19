From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 20/22] Audit: Log audit config change in uninit user namespace
Date: Wed, 19 Jun 2013 09:53:52 +0800
Message-ID: <1371606834-5802-21-git-send-email-gaofeng__22859.4565800906$1371606947$gmane$org@cn.fujitsu.com>
References: <1371606834-5802-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371606834-5802-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, matthltc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch allow to log audit config change in
uninit user namespace.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/audit.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index 2d81aac..84a882c 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -245,13 +245,14 @@ void audit_log_lost(const char *message)
 	}
 }
 
-static int audit_log_config_change(char *function_name, int new, int old,
+static int audit_log_config_change(struct user_namespace *ns,
+				   char *function_name, int new, int old,
 				   int allow_changes)
 {
 	struct audit_buffer *ab;
 	int rc = 0;
 
-	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
+	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
 	if (unlikely(!ab))
 		return rc;
 	audit_log_format(ab, "%s=%d old=%d", function_name, new, old);
@@ -260,7 +261,7 @@ static int audit_log_config_change(char *function_name, int new, int old,
 	if (rc)
 		allow_changes = 0; /* Something weird, deny request */
 	audit_log_format(ab, " res=%d", allow_changes);
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 	return rc;
 }
 
@@ -276,7 +277,8 @@ static int audit_do_config_change(char *function_name, int *to_change, int new)
 		allow_changes = 1;
 
 	if (ns->audit.enabled != AUDIT_OFF) {
-		rc = audit_log_config_change(function_name, new, old, allow_changes);
+		rc = audit_log_config_change(ns, function_name, new,
+					     old, allow_changes);
 		if (rc)
 			allow_changes = 0;
 	}
@@ -711,7 +713,8 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			int new_pid = status_get->pid;
 
 			if (ns->audit.enabled != AUDIT_OFF)
-				audit_log_config_change("audit_pid", new_pid,
+				audit_log_config_change(ns, "audit_pid",
+							new_pid,
 							ns->audit.pid, 1);
 			ns->audit.pid = new_pid;
 			ns->audit.portid = NETLINK_CB(skb).portid;
-- 
1.8.1.4
