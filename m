From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 07/20] aduit: make audit_nlk_portid per audit namespace
Date: Thu, 24 Oct 2013 15:31:52 +0800
Message-ID: <1382599925-25143-8-git-send-email-gaofeng__6148.7634935931$1382599941$gmane$org@cn.fujitsu.com>
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

We should use audit_nlk_portid to decide to send
audit netlink message to which auditd processes.
it should be per audit namespace too.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit_namespace.h |  2 ++
 kernel/audit.c                  | 14 ++++----------
 2 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/include/linux/audit_namespace.h b/include/linux/audit_namespace.h
index 2c0eede..a9e6a40 100644
--- a/include/linux/audit_namespace.h
+++ b/include/linux/audit_namespace.h
@@ -11,6 +11,8 @@ struct audit_namespace {
 	atomic_t count;
 	/* pid of the auditd process */
 	int pid;
+	/* portid of the auditd process's netlink socket */
+	int portid;
 	struct user_namespace *user_ns;
 	struct sk_buff_head queue;
 	/* queue of skbs to send to auditd when/if it comes back */
diff --git a/kernel/audit.c b/kernel/audit.c
index ceb1cbd..37375fb 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -89,13 +89,6 @@ static int	audit_default;
 /* If auditing cannot proceed, audit_failure selects what happens. */
 static int	audit_failure = AUDIT_FAIL_PRINTK;
 
-/*
- * If audit records are to be written to the netlink socket, audit_pid
- * contains the pid of the auditd process and audit_nlk_portid contains
- * the portid to use to send netlink messages to that process.
- */
-static int	audit_nlk_portid;
-
 /* If audit_rate_limit is non-zero, limit the rate of sending audit records
  * to that number per second.  This prevents DoS attacks, but results in
  * audit records being dropped. */
@@ -381,7 +374,7 @@ static void kauditd_send_skb(struct sk_buff *skb)
 	int err;
 	/* take a reference in case we can't send it and we want to hold it */
 	skb_get(skb);
-	err = netlink_unicast(audit_sock, skb, audit_nlk_portid, 0);
+	err = netlink_unicast(audit_sock, skb, init_audit_ns.portid, 0);
 	if (err < 0) {
 		BUG_ON(err != -ECONNREFUSED); /* Shouldn't happen */
 		printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n", init_audit_ns.pid);
@@ -645,7 +638,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	u16			msg_type = nlh->nlmsg_type;
 	struct audit_sig_info   *sig_data;
 	char			*ctx = NULL;
-	struct audit_namespace	*ns = current_audit_ns();
+	struct audit_namespace	*ns = current->nsproxy->audit_ns;
 	u32			len;
 
 	err = audit_netlink_ok(skb, msg_type);
@@ -721,7 +714,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			init_audit_ns.pid = new_pid;
 			rcu_read_unlock();
 
-			audit_nlk_portid = NETLINK_CB(skb).portid;
+			init_audit_ns.portid = NETLINK_CB(skb).portid;
 		}
 		if (status_get->mask & AUDIT_STATUS_RATE_LIMIT) {
 			err = audit_set_rate_limit(status_get->rate_limit);
@@ -944,6 +937,7 @@ static int __init audit_init(void)
 		audit_sock->sk_sndtimeo = MAX_SCHEDULE_TIMEOUT;
 
 	init_audit_ns.pid = 0;
+	init_audit_ns.portid = 0;
 	init_audit_ns.kauditd_task = NULL;
 	skb_queue_head_init(&init_audit_ns.queue);
 	skb_queue_head_init(&init_audit_ns.hold_queue);
-- 
1.8.3.1
