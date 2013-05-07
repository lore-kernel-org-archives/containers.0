From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 43/48] Audit: xfrm: translate audit_log_start to
	audit_log_start_ns
Date: Tue, 7 May 2013 10:21:04 +0800
Message-ID: <1367893269-9308-44-git-send-email-gaofeng__12827.9403121725$1367893513$gmane$org@cn.fujitsu.com>
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
 include/net/xfrm.h     |  7 ++++---
 net/xfrm/xfrm_policy.c |  4 ++--
 net/xfrm/xfrm_state.c  | 14 +++++++-------
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ae16531..1a99744 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -683,11 +683,12 @@ struct xfrm_audit {
 static inline struct audit_buffer *xfrm_audit_start(const char *op)
 {
 	struct audit_buffer *audit_buf = NULL;
+	struct user_namespace *ns = current_user_ns();
 
-	if (audit_enabled == 0)
+	if (audit_enabled_ns(ns) == 0)
 		return NULL;
-	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC,
-				    AUDIT_MAC_IPSEC_EVENT);
+	audit_buf = audit_log_start_ns(ns, current->audit_context,
+				       GFP_ATOMIC, AUDIT_MAC_IPSEC_EVENT);
 	if (audit_buf == NULL)
 		return NULL;
 	audit_log_format(audit_buf, "op=%s", op);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 23cea0f..f3cc1b9 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -3008,7 +3008,7 @@ void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
 	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
 	xfrm_audit_common_policyinfo(xp, audit_buf);
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_policy_add);
 
@@ -3023,7 +3023,7 @@ void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
 	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
 	xfrm_audit_common_policyinfo(xp, audit_buf);
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_policy_delete);
 #endif
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 78f66fa..50115d9 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2119,7 +2119,7 @@ void xfrm_audit_state_add(struct xfrm_state *x, int result,
 	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
 	xfrm_audit_helper_sainfo(x, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_add);
 
@@ -2134,7 +2134,7 @@ void xfrm_audit_state_delete(struct xfrm_state *x, int result,
 	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
 	xfrm_audit_helper_sainfo(x, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_delete);
 
@@ -2152,7 +2152,7 @@ void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
 	 * of audit message */
 	spi = ntohl(x->id.spi);
 	audit_log_format(audit_buf, " spi=%u(0x%x)", spi, spi);
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_replay_overflow);
 
@@ -2169,7 +2169,7 @@ void xfrm_audit_state_replay(struct xfrm_state *x,
 	spi = ntohl(x->id.spi);
 	audit_log_format(audit_buf, " spi=%u(0x%x) seqno=%u",
 			 spi, spi, ntohl(net_seq));
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_replay);
 
@@ -2181,7 +2181,7 @@ void xfrm_audit_state_notfound_simple(struct sk_buff *skb, u16 family)
 	if (audit_buf == NULL)
 		return;
 	xfrm_audit_helper_pktinfo(skb, family, audit_buf);
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_notfound_simple);
 
@@ -2198,7 +2198,7 @@ void xfrm_audit_state_notfound(struct sk_buff *skb, u16 family,
 	spi = ntohl(net_spi);
 	audit_log_format(audit_buf, " spi=%u(0x%x) seqno=%u",
 			 spi, spi, ntohl(net_seq));
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_notfound);
 
@@ -2218,7 +2218,7 @@ void xfrm_audit_state_icvfail(struct xfrm_state *x,
 		audit_log_format(audit_buf, " spi=%u(0x%x) seqno=%u",
 				 spi, spi, ntohl(net_seq));
 	}
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_icvfail);
 #endif /* CONFIG_AUDITSYSCALL */
-- 
1.8.1.4
