From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 21/22] Audit: send reply message to the auditd in proper user
	namespace
Date: Wed, 19 Jun 2013 09:53:53 +0800
Message-ID: <1371606834-5802-22-git-send-email-gaofeng@cn.fujitsu.com>
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

We can send the audit reply message to userspace auditd
process which running in the same user namespace with the
process which send the audit request message to kernel.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/audit.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index 84a882c..0b3fd8b 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -146,6 +146,7 @@ struct audit_buffer {
 struct audit_reply {
 	int pid;
 	struct sk_buff *skb;
+	struct user_namespace *ns;
 };
 
 static void audit_set_pid(struct audit_buffer *ab, pid_t pid)
@@ -532,8 +533,9 @@ static int audit_send_reply_thread(void *arg)
 
 	/* Ignore failure. It'll only happen if the sender goes away,
 	   because our timeout is set to infinite. */
-	netlink_unicast(init_user_ns.audit.sock, reply->skb,
+	netlink_unicast(reply->ns->audit.sock, reply->skb,
 			reply->pid, 0);
+	put_user_ns(reply->ns);
 	kfree(reply);
 	return 0;
 }
@@ -572,11 +574,13 @@ static int audit_send_reply(int pid, int seq, int type, int done, int multi,
 
 	reply->pid = pid;
 	reply->skb = skb;
+	reply->ns = get_user_ns(current_user_ns());
 
 	tsk = kthread_run(audit_send_reply_thread, reply, "audit_send_reply");
 	if (!IS_ERR(tsk))
 		return 0;
 	kfree_skb(skb);
+	put_user_ns(reply->ns);
 out:
 	kfree(reply);
 	return ret;
@@ -833,7 +837,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 				security_release_secctx(ctx, len);
 			return -ENOMEM;
 		}
-		sig_data->uid = from_kuid(&init_user_ns, audit_sig_uid);
+		sig_data->uid = from_kuid(ns, audit_sig_uid);
 		sig_data->pid = audit_sig_pid;
 		if (audit_sig_sid) {
 			memcpy(sig_data->ctx, ctx, len);
-- 
1.8.1.4
