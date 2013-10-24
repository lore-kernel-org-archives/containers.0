From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 12/20] audit: use proper audit_namespace in kauditd_thread
Date: Thu, 24 Oct 2013 15:31:57 +0800
Message-ID: <1382599925-25143-13-git-send-email-gaofeng__989.398748106574$1382599962$gmane$org@cn.fujitsu.com>
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

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/audit.c | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index 5524deb..b203017 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -338,11 +338,11 @@ static int audit_set_failure(int state)
  * This only holds messages is audit_default is set, aka booting with audit=1
  * or building your kernel that way.
  */
-static void audit_hold_skb(struct sk_buff *skb)
+static void audit_hold_skb(struct audit_namespace *ns, struct sk_buff *skb)
 {
 	if (audit_default &&
-	    skb_queue_len(&init_audit_ns.hold_queue) < audit_backlog_limit)
-		skb_queue_tail(&init_audit_ns.hold_queue, skb);
+	    skb_queue_len(&ns->hold_queue) < audit_backlog_limit)
+		skb_queue_tail(&ns->hold_queue, skb);
 	else
 		kfree_skb(skb);
 }
@@ -351,7 +351,7 @@ static void audit_hold_skb(struct sk_buff *skb)
  * For one reason or another this nlh isn't getting delivered to the userspace
  * audit daemon, just send it to printk.
  */
-static void audit_printk_skb(struct sk_buff *skb)
+static void audit_printk_skb(struct audit_namespace *ns, struct sk_buff *skb)
 {
 	struct nlmsghdr *nlh = nlmsg_hdr(skb);
 	char *data = nlmsg_data(nlh);
@@ -363,22 +363,22 @@ static void audit_printk_skb(struct sk_buff *skb)
 			audit_log_lost("printk limit exceeded\n");
 	}
 
-	audit_hold_skb(skb);
+	audit_hold_skb(ns, skb);
 }
 
-static void kauditd_send_skb(struct sk_buff *skb)
+static void kauditd_send_skb(struct audit_namespace *ns, struct sk_buff *skb)
 {
 	int err;
 	/* take a reference in case we can't send it and we want to hold it */
 	skb_get(skb);
-	err = netlink_unicast(audit_sock, skb, init_audit_ns.portid, 0);
+	err = netlink_unicast(audit_sock, skb, ns->portid, 0);
 	if (err < 0) {
 		BUG_ON(err != -ECONNREFUSED); /* Shouldn't happen */
-		printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n", init_audit_ns.pid);
+		printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n", ns->pid);
 		audit_log_lost("auditd disappeared\n");
-		init_audit_ns.pid = 0;
+		ns->pid = 0;
 		/* we might get lucky and get this in the next auditd */
-		audit_hold_skb(skb);
+		audit_hold_skb(ns, skb);
 	} else
 		/* drop the extra reference if sent ok */
 		consume_skb(skb);
@@ -411,7 +411,7 @@ static void flush_hold_queue(struct audit_namespace *ns)
 		return;
 
 	while (skb && ns->pid) {
-		kauditd_send_skb(skb);
+		kauditd_send_skb(ns, skb);
 		skb = skb_dequeue(&ns->hold_queue);
 	}
 
@@ -441,16 +441,16 @@ static int kauditd_thread(void *dummy)
 		flush_hold_queue(ns);
 
 		skb = skb_dequeue(&ns->queue);
-		wake_up(&init_audit_ns.backlog_wait);
+		wake_up(&ns->backlog_wait);
 		if (skb) {
 			if (ns->pid)
-				kauditd_send_skb(skb);
+				kauditd_send_skb(ns, skb);
 			else
-				audit_printk_skb(skb);
+				audit_printk_skb(ns, skb);
 			continue;
 		}
 		set_current_state(TASK_INTERRUPTIBLE);
-		add_wait_queue(&init_audit_ns.kauditd_wait, &wait);
+		add_wait_queue(&ns->kauditd_wait, &wait);
 
 		if (!skb_queue_len(&ns->queue)) {
 			try_to_freeze();
@@ -458,7 +458,7 @@ static int kauditd_thread(void *dummy)
 		}
 
 		__set_current_state(TASK_RUNNING);
-		remove_wait_queue(&init_audit_ns.kauditd_wait, &wait);
+		remove_wait_queue(&ns->kauditd_wait, &wait);
 	}
 
 	ns->kauditd_task = NULL;
@@ -1713,7 +1713,7 @@ void audit_log_end(struct audit_buffer *ab)
 			skb_queue_tail(&init_audit_ns.queue, ab->skb);
 			wake_up_interruptible(&init_audit_ns.kauditd_wait);
 		} else {
-			audit_printk_skb(ab->skb);
+			audit_printk_skb(&init_audit_ns, ab->skb);
 		}
 		ab->skb = NULL;
 	}
-- 
1.8.3.1
