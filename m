From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH audit-next 1/2] audit: revert commit listen in all network
	namespaces
Date: Thu, 9 Jan 2014 17:11:30 +0800
Message-ID: <1389258691-2680-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch reverts the commit 1a938bec0090dc49abdb471e978e0d8155186845
"listen in all network namespaces",this commit brings the dependence
of net namespace for audit. it's a pain when we implement audit namespace.
we have to do lots of works to make sure audit socket is valid.
and unshare namespace will make things more worse.

In the next patch, I will add a compare function for audit
netlink socket, and this will make audit socket global. all
user space audit netlink will communicate with this global
socket, and kernel will send message to user space through
this socket. this will make things easy and we needn't to
consider the complicate cases.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/audit.c | 61 ++++++++++------------------------------------------------
 kernel/audit.h |  4 ----
 2 files changed, 10 insertions(+), 55 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index ff1d1d7..b62153a 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -63,7 +63,6 @@
 #include <linux/freezer.h>
 #include <linux/tty.h>
 #include <linux/pid_namespace.h>
-#include <net/netns/generic.h>
 
 #include "audit.h"
 
@@ -124,7 +123,6 @@ static atomic_t    audit_lost = ATOMIC_INIT(0);
 
 /* The netlink socket. */
 static struct sock *audit_sock;
-int audit_net_id;
 
 /* Hash for inode-based rules */
 struct list_head audit_inode_hash[AUDIT_INODE_BUCKETS];
@@ -415,7 +413,6 @@ static void kauditd_send_skb(struct sk_buff *skb)
 				audit_pid);
 			audit_log_lost("auditd disappeared\n");
 			audit_pid = 0;
-			audit_sock = NULL;
 		}
 		/* we might get lucky and get this in the next auditd */
 		audit_hold_skb(skb);
@@ -501,15 +498,13 @@ int audit_send_list(void *_dest)
 {
 	struct audit_netlink_list *dest = _dest;
 	struct sk_buff *skb;
-	struct net *net = get_net_ns_by_pid(dest->pid);
-	struct audit_net *aunet = net_generic(net, audit_net_id);
 
 	/* wait for parent to finish and send an ACK */
 	mutex_lock(&audit_cmd_mutex);
 	mutex_unlock(&audit_cmd_mutex);
 
 	while ((skb = __skb_dequeue(&dest->q)) != NULL)
-		netlink_unicast(aunet->nlsk, skb, dest->portid, 0);
+		netlink_unicast(audit_sock, skb, dest->portid, 0);
 
 	kfree(dest);
 
@@ -544,15 +539,13 @@ out_kfree_skb:
 static int audit_send_reply_thread(void *arg)
 {
 	struct audit_reply *reply = (struct audit_reply *)arg;
-	struct net *net = get_net_ns_by_pid(reply->pid);
-	struct audit_net *aunet = net_generic(net, audit_net_id);
 
 	mutex_lock(&audit_cmd_mutex);
 	mutex_unlock(&audit_cmd_mutex);
 
 	/* Ignore failure. It'll only happen if the sender goes away,
 	   because our timeout is set to infinite. */
-	netlink_unicast(aunet->nlsk , reply->skb, reply->portid, 0);
+	netlink_unicast(audit_sock, reply->skb, reply->portid, 0);
 	kfree(reply);
 	return 0;
 }
@@ -822,7 +815,6 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 				audit_log_config_change("audit_pid", new_pid, audit_pid, 1);
 			audit_pid = new_pid;
 			audit_nlk_portid = NETLINK_CB(skb).portid;
-			audit_sock = skb->sk;
 		}
 		if (s.mask & AUDIT_STATUS_RATE_LIMIT) {
 			err = audit_set_rate_limit(s.rate_limit);
@@ -1072,57 +1064,24 @@ static void audit_receive(struct sk_buff  *skb)
 	mutex_unlock(&audit_cmd_mutex);
 }
 
-static int __net_init audit_net_init(struct net *net)
-{
-	struct netlink_kernel_cfg cfg = {
-		.input	= audit_receive,
-	};
-
-	struct audit_net *aunet = net_generic(net, audit_net_id);
-
-	pr_info("audit: initializing netlink socket in namespace\n");
-
-	aunet->nlsk = netlink_kernel_create(net, NETLINK_AUDIT, &cfg);
-	if (aunet->nlsk == NULL) {
-		audit_panic("cannot initialize netlink socket in namespace");
-		return -ENOMEM;
-	}
-	aunet->nlsk->sk_sndtimeo = MAX_SCHEDULE_TIMEOUT;
-	return 0;
-}
-
-static void __net_exit audit_net_exit(struct net *net)
-{
-	struct audit_net *aunet = net_generic(net, audit_net_id);
-	struct sock *sock = aunet->nlsk;
-	if (sock == audit_sock) {
-		audit_pid = 0;
-		audit_sock = NULL;
-	}
-
-	rcu_assign_pointer(aunet->nlsk, NULL);
-	synchronize_net();
-	netlink_kernel_release(sock);
-}
-
-static struct pernet_operations audit_net_ops __net_initdata = {
-	.init = audit_net_init,
-	.exit = audit_net_exit,
-	.id = &audit_net_id,
-	.size = sizeof(struct audit_net),
-};
-
 /* Initialize audit support at boot time. */
 static int __init audit_init(void)
 {
 	int i;
+	struct netlink_kernel_cfg cfg = {
+		.input	= audit_receive,
+	};
 
 	if (audit_initialized == AUDIT_DISABLED)
 		return 0;
 
 	pr_info("audit: initializing netlink subsys (%s)\n",
 	       audit_default ? "enabled" : "disabled");
-	register_pernet_subsys(&audit_net_ops);
+	audit_sock = netlink_kernel_create(&init_net, NETLINK_AUDIT, &cfg);
+	if (!audit_sock)
+		audit_panic("cannot initialize netlink socket");
+	else
+		audit_sock->sk_sndtimeo = MAX_SCHEDULE_TIMEOUT;
 
 	skb_queue_head_init(&audit_skb_queue);
 	skb_queue_head_init(&audit_skb_hold_queue);
diff --git a/kernel/audit.h b/kernel/audit.h
index 0719b45..16380bd 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -253,10 +253,6 @@ struct audit_netlink_list {
 
 int audit_send_list(void *);
 
-struct audit_net {
-	struct sock *nlsk;
-};
-
 extern int selinux_audit_rule_update(void);
 
 extern struct mutex audit_filter_mutex;
-- 
1.8.4.2
