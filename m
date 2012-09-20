From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 09/27] audit: Don't pass pid or uid to
	audit_log_common_recv_msg
Date: Wed, 19 Sep 2012 18:52:11 -0700
Message-ID: <1348105949-25454-9-git-send-email-ebiederm@xmission.com>
References: <871uhx1n71.fsf@xmission.com>
	<1348105949-25454-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348105949-25454-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

The only place we use the uid and the pid that we calculate in
audit_receive_msg is in audit_log_common_recv_msg so move the
calculation of these values into the audit_log_common_recv_msg.

Simplify the calcuation of the current pid and uid by
reading them from current instead of reading them from
NETLINK_CREDS.

Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/audit.c |   29 ++++++++++++++---------------
 1 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index a31e31b..2e0dd5e 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -607,8 +607,7 @@ static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
 }
 
 static int audit_log_common_recv_msg(struct audit_buffer **ab, u16 msg_type,
-				     u32 pid, u32 uid, uid_t auid, u32 ses,
-				     u32 sid)
+				     uid_t auid, u32 ses, u32 sid)
 {
 	int rc = 0;
 	char *ctx = NULL;
@@ -621,7 +620,9 @@ static int audit_log_common_recv_msg(struct audit_buffer **ab, u16 msg_type,
 
 	*ab = audit_log_start(NULL, GFP_KERNEL, msg_type);
 	audit_log_format(*ab, "pid=%d uid=%u auid=%u ses=%u",
-			 pid, uid, auid, ses);
+			 task_tgid_vnr(current),
+			 from_kuid(&init_user_ns, current_uid()),
+			 auid, ses);
 	if (sid) {
 		rc = security_secid_to_secctx(sid, &ctx, &len);
 		if (rc)
@@ -637,7 +638,7 @@ static int audit_log_common_recv_msg(struct audit_buffer **ab, u16 msg_type,
 
 static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	u32			uid, pid, seq, sid;
+	u32			seq, sid;
 	void			*data;
 	struct audit_status	*status_get, status_set;
 	int			err;
@@ -663,8 +664,6 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return err;
 	}
 
-	pid  = NETLINK_CREDS(skb)->pid;
-	uid  = NETLINK_CREDS(skb)->uid;
 	loginuid = audit_get_loginuid(current);
 	sessionid = audit_get_sessionid(current);
 	security_task_getsecid(current, &sid);
@@ -735,7 +734,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 				if (err)
 					break;
 			}
-			audit_log_common_recv_msg(&ab, msg_type, pid, uid,
+			audit_log_common_recv_msg(&ab, msg_type,
 						  loginuid, sessionid, sid);
 
 			if (msg_type != AUDIT_USER_TTY)
@@ -760,8 +759,8 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (nlmsg_len(nlh) < sizeof(struct audit_rule))
 			return -EINVAL;
 		if (audit_enabled == AUDIT_LOCKED) {
-			audit_log_common_recv_msg(&ab, AUDIT_CONFIG_CHANGE, pid,
-						  uid, loginuid, sessionid, sid);
+			audit_log_common_recv_msg(&ab, AUDIT_CONFIG_CHANGE,
+						  loginuid, sessionid, sid);
 
 			audit_log_format(ab, " audit_enabled=%d res=0",
 					 audit_enabled);
@@ -779,8 +778,8 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (nlmsg_len(nlh) < sizeof(struct audit_rule_data))
 			return -EINVAL;
 		if (audit_enabled == AUDIT_LOCKED) {
-			audit_log_common_recv_msg(&ab, AUDIT_CONFIG_CHANGE, pid,
-						  uid, loginuid, sessionid, sid);
+			audit_log_common_recv_msg(&ab, AUDIT_CONFIG_CHANGE,
+						  loginuid, sessionid, sid);
 
 			audit_log_format(ab, " audit_enabled=%d res=0",
 					 audit_enabled);
@@ -796,8 +795,8 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	case AUDIT_TRIM:
 		audit_trim_trees();
 
-		audit_log_common_recv_msg(&ab, AUDIT_CONFIG_CHANGE, pid,
-					  uid, loginuid, sessionid, sid);
+		audit_log_common_recv_msg(&ab, AUDIT_CONFIG_CHANGE,
+					  loginuid, sessionid, sid);
 
 		audit_log_format(ab, " op=trim res=1");
 		audit_log_end(ab);
@@ -828,8 +827,8 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		/* OK, here comes... */
 		err = audit_tag_tree(old, new);
 
-		audit_log_common_recv_msg(&ab, AUDIT_CONFIG_CHANGE, pid,
-					  uid, loginuid, sessionid, sid);
+		audit_log_common_recv_msg(&ab, AUDIT_CONFIG_CHANGE,
+					  loginuid, sessionid, sid);
 
 		audit_log_format(ab, " op=make_equiv old=");
 		audit_log_untrustedstring(ab, old);
-- 
1.7.5.4
