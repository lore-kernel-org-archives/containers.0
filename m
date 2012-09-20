From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 04/27] audit: Use current instead of NETLINK_CREDS() in
	audit_filter
Date: Wed, 19 Sep 2012 18:52:06 -0700
Message-ID: <1348105949-25454-4-git-send-email-ebiederm@xmission.com>
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

Get caller process uid and gid and pid values from the current task
instead of the NETLINK_CB.  This is simpler than passing NETLINK_CREDS
from from audit_receive_msg to audit_filter_user_rules and avoid the
chance of being hit by the occassional bugs in netlink uid/gid
credential passing.  This is a safe changes because all netlink
requests are processed in the task of the sending process.

Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/audit.h |    2 +-
 kernel/audit.c        |    2 +-
 kernel/auditfilter.c  |   13 ++++++-------
 3 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 36abf2a..9c9af0e 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -700,7 +700,7 @@ extern void 		    audit_log_secctx(struct audit_buffer *ab, u32 secid);
 extern int		    audit_update_lsm_rules(void);
 
 				/* Private API (for audit.c only) */
-extern int audit_filter_user(struct netlink_skb_parms *cb);
+extern int audit_filter_user(void);
 extern int audit_filter_type(int type);
 extern int  audit_receive_filter(int type, int pid, int uid, int seq,
 				void *data, size_t datasz, uid_t loginuid,
diff --git a/kernel/audit.c b/kernel/audit.c
index 7b7268e..fecb150 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -744,7 +744,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (!audit_enabled && msg_type != AUDIT_USER_AVC)
 			return 0;
 
-		err = audit_filter_user(&NETLINK_CB(skb));
+		err = audit_filter_user();
 		if (err == 1) {
 			err = 0;
 			if (msg_type == AUDIT_USER_TTY) {
diff --git a/kernel/auditfilter.c b/kernel/auditfilter.c
index a6c3f1a..b754f43 100644
--- a/kernel/auditfilter.c
+++ b/kernel/auditfilter.c
@@ -1236,8 +1236,7 @@ int audit_compare_dname_path(const char *dname, const char *path,
 	return strncmp(p, dname, dlen);
 }
 
-static int audit_filter_user_rules(struct netlink_skb_parms *cb,
-				   struct audit_krule *rule,
+static int audit_filter_user_rules(struct audit_krule *rule,
 				   enum audit_state *state)
 {
 	int i;
@@ -1249,13 +1248,13 @@ static int audit_filter_user_rules(struct netlink_skb_parms *cb,
 
 		switch (f->type) {
 		case AUDIT_PID:
-			result = audit_comparator(cb->creds.pid, f->op, f->val);
+			result = audit_comparator(task_pid_vnr(current), f->op, f->val);
 			break;
 		case AUDIT_UID:
-			result = audit_comparator(cb->creds.uid, f->op, f->val);
+			result = audit_comparator(current_uid(), f->op, f->val);
 			break;
 		case AUDIT_GID:
-			result = audit_comparator(cb->creds.gid, f->op, f->val);
+			result = audit_comparator(current_gid(), f->op, f->val);
 			break;
 		case AUDIT_LOGINUID:
 			result = audit_comparator(audit_get_loginuid(current),
@@ -1287,7 +1286,7 @@ static int audit_filter_user_rules(struct netlink_skb_parms *cb,
 	return 1;
 }
 
-int audit_filter_user(struct netlink_skb_parms *cb)
+int audit_filter_user(void)
 {
 	enum audit_state state = AUDIT_DISABLED;
 	struct audit_entry *e;
@@ -1295,7 +1294,7 @@ int audit_filter_user(struct netlink_skb_parms *cb)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(e, &audit_filter_list[AUDIT_FILTER_USER], list) {
-		if (audit_filter_user_rules(cb, &e->rule, &state)) {
+		if (audit_filter_user_rules(&e->rule, &state)) {
 			if (state == AUDIT_DISABLED)
 				ret = 0;
 			break;
-- 
1.7.5.4
