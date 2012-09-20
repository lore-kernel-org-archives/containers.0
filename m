From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 08/27] audit: Remove the unused uid parameter from
	audit_receive_filter
Date: Wed, 19 Sep 2012 18:52:10 -0700
Message-ID: <1348105949-25454-8-git-send-email-ebiederm@xmission.com>
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

Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/audit.h |    2 +-
 kernel/audit.c        |    4 ++--
 kernel/auditfilter.c  |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 9c9af0e..b9c5b22 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -702,7 +702,7 @@ extern int		    audit_update_lsm_rules(void);
 				/* Private API (for audit.c only) */
 extern int audit_filter_user(void);
 extern int audit_filter_type(int type);
-extern int  audit_receive_filter(int type, int pid, int uid, int seq,
+extern int  audit_receive_filter(int type, int pid, int seq,
 				void *data, size_t datasz, uid_t loginuid,
 				u32 sessionid, u32 sid);
 extern int audit_enabled;
diff --git a/kernel/audit.c b/kernel/audit.c
index 9dd4d09..a31e31b 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -771,7 +771,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		/* fallthrough */
 	case AUDIT_LIST:
 		err = audit_receive_filter(msg_type, NETLINK_CB(skb).pid,
-					   uid, seq, data, nlmsg_len(nlh),
+					   seq, data, nlmsg_len(nlh),
 					   loginuid, sessionid, sid);
 		break;
 	case AUDIT_ADD_RULE:
@@ -790,7 +790,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		/* fallthrough */
 	case AUDIT_LIST_RULES:
 		err = audit_receive_filter(msg_type, NETLINK_CB(skb).pid,
-					   uid, seq, data, nlmsg_len(nlh),
+					   seq, data, nlmsg_len(nlh),
 					   loginuid, sessionid, sid);
 		break;
 	case AUDIT_TRIM:
diff --git a/kernel/auditfilter.c b/kernel/auditfilter.c
index b754f43..e242dd9 100644
--- a/kernel/auditfilter.c
+++ b/kernel/auditfilter.c
@@ -1098,7 +1098,7 @@ static void audit_log_rule_change(uid_t loginuid, u32 sessionid, u32 sid,
  * @sessionid: sessionid for netlink audit message
  * @sid: SE Linux Security ID of sender
  */
-int audit_receive_filter(int type, int pid, int uid, int seq, void *data,
+int audit_receive_filter(int type, int pid, int seq, void *data,
 			 size_t datasz, uid_t loginuid, u32 sessionid, u32 sid)
 {
 	struct task_struct *tsk;
-- 
1.7.5.4
