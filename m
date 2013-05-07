From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 33/48] Audit: Log filter related audit message to proper
	user namespace
Date: Tue, 7 May 2013 10:20:54 +0800
Message-ID: <1367893269-9308-34-git-send-email-gaofeng__3882.46158040619$1367893499$gmane$org@cn.fujitsu.com>
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

Now, we can log filter related audit message to the user namespace
which the task belongs to.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/auditfilter.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/kernel/auditfilter.c b/kernel/auditfilter.c
index f2afe9b..8af148b 100644
--- a/kernel/auditfilter.c
+++ b/kernel/auditfilter.c
@@ -1120,15 +1120,16 @@ static void audit_log_rule_change(kuid_t loginuid, u32 sessionid, u32 sid,
 				  int res)
 {
 	struct audit_buffer *ab;
+	struct user_namespace *ns = current_user_ns();
 
-	if (!audit_enabled)
+	if (!ns->audit.enabled)
 		return;
 
-	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
+	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
 	if (!ab)
 		return;
 	audit_log_format(ab, "auid=%u ses=%u",
-			 from_kuid(&init_user_ns, loginuid), sessionid);
+			 from_kuid(ns, loginuid), sessionid);
 	if (sid) {
 		char *ctx = NULL;
 		u32 len;
@@ -1143,7 +1144,7 @@ static void audit_log_rule_change(kuid_t loginuid, u32 sessionid, u32 sid,
 	audit_log_string(ab, action);
 	audit_log_key(ab, rule->filterkey);
 	audit_log_format(ab, " list=%d res=%d", rule->listnr, res);
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 }
 
 /**
-- 
1.8.1.4
