From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 19/20] audit: make audit_backlog_limit per audit namespace
Date: Thu, 24 Oct 2013 15:32:04 +0800
Message-ID: <1382599925-25143-20-git-send-email-gaofeng__9790.23906770653$1382600030$gmane$org@cn.fujitsu.com>
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

This patch makes audit_backlog_limit per audit
namespace, so we can limit the memory usage of
audit namespace through limit the value of
auditns's audit_backlog_limit.

By default, the backlog_limit of new created
audit namespace is zero, so processes in this
auditns has no ability to generate audit log.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit_namespace.h |  2 ++
 kernel/audit.c                  | 47 +++++++++++++++++++++++------------------
 2 files changed, 28 insertions(+), 21 deletions(-)

diff --git a/include/linux/audit_namespace.h b/include/linux/audit_namespace.h
index b17f052..4648b4f 100644
--- a/include/linux/audit_namespace.h
+++ b/include/linux/audit_namespace.h
@@ -14,6 +14,8 @@ struct audit_namespace {
 	int pid;
 	/* portid of the auditd process's netlink socket */
 	int portid;
+	/* number of outstanding audit_buffers allowed */
+	int backlog_limit;
 	struct user_namespace *user_ns;
 	struct sk_buff_head queue;
 	/* queue of skbs to send to auditd when/if it comes back */
diff --git a/kernel/audit.c b/kernel/audit.c
index 86212d3..63797557 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -94,8 +94,6 @@ static int	audit_failure = AUDIT_FAIL_PRINTK;
  * audit records being dropped. */
 static int	audit_rate_limit;
 
-/* Number of outstanding audit_buffers allowed. */
-static int	audit_backlog_limit = 64;
 static int	audit_backlog_wait_time = 60 * HZ;
 static int	audit_backlog_wait_overflow = 0;
 
@@ -210,15 +208,7 @@ static inline int audit_rate_check(void)
 	return retval;
 }
 
-/**
- * audit_log_lost - conditionally log lost audit message event
- * @message: the message stating reason for lost audit message
- *
- * Emit at least 1 message per second, even if audit_rate_check is
- * throttling.
- * Always increment the lost messages counter.
-*/
-void audit_log_lost(const char *message)
+void audit_log_lost_ns(struct audit_namespace *ns, const char *message)
 {
 	static unsigned long	last_msg = 0;
 	static DEFINE_SPINLOCK(lock);
@@ -240,18 +230,31 @@ void audit_log_lost(const char *message)
 		spin_unlock_irqrestore(&lock, flags);
 	}
 
-	if (print) {
+	if (print && (ns == &init_audit_ns)) {
 		if (printk_ratelimit())
 			printk(KERN_WARNING
 				"audit: audit_lost=%d audit_rate_limit=%d "
 				"audit_backlog_limit=%d\n",
 				atomic_read(&audit_lost),
 				audit_rate_limit,
-				audit_backlog_limit);
+				ns->backlog_limit);
 		audit_panic(message);
 	}
 }
 
+/**
+ * audit_log_lost - conditionally log lost audit message event
+ * @message: the message stating reason for lost audit message
+ *
+ * Emit at least 1 message per second, even if audit_rate_check is
+ * throttling.
+ * Always increment the lost messages counter.
+*/
+void audit_log_lost(const char *message)
+{
+	return audit_log_lost_ns(&init_audit_ns, message);
+}
+
 static int audit_log_config_change(struct audit_namespace *ns,
 				   char *function_name,
 				   int new, int old,
@@ -308,7 +311,8 @@ static int audit_set_rate_limit(int limit)
 
 static int audit_set_backlog_limit(int limit)
 {
-	return audit_do_config_change("audit_backlog_limit", &audit_backlog_limit, limit);
+	return audit_do_config_change("audit_backlog_limit",
+				      &init_audit_ns.backlog_limit, limit);
 }
 
 static int audit_set_enabled(int state)
@@ -346,7 +350,7 @@ static int audit_set_failure(int state)
 static void audit_hold_skb(struct audit_namespace *ns, struct sk_buff *skb)
 {
 	if (audit_default &&
-	    skb_queue_len(&ns->hold_queue) < audit_backlog_limit)
+	    skb_queue_len(&ns->hold_queue) < ns->backlog_limit)
 		skb_queue_tail(&ns->hold_queue, skb);
 	else
 		kfree_skb(skb);
@@ -675,7 +679,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		status_set.failure	 = audit_failure;
 		status_set.pid		 = ns->pid;
 		status_set.rate_limit	 = audit_rate_limit;
-		status_set.backlog_limit = audit_backlog_limit;
+		status_set.backlog_limit = ns->backlog_limit;
 		status_set.lost		 = atomic_read(&audit_lost);
 		status_set.backlog	 = skb_queue_len(&ns->queue);
 
@@ -971,6 +975,7 @@ static int __init audit_init(void)
 
 	init_audit_ns.pid = 0;
 	init_audit_ns.portid = 0;
+	init_audit_ns.backlog_limit = 64;
 	init_audit_ns.kauditd_task = NULL;
 	skb_queue_head_init(&init_audit_ns.queue);
 	skb_queue_head_init(&init_audit_ns.hold_queue);
@@ -1129,8 +1134,8 @@ static void wait_for_auditd(struct audit_namespace *ns,
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	add_wait_queue(&ns->backlog_wait, &wait);
 
-	if (audit_backlog_limit &&
-	    skb_queue_len(&ns->queue) > audit_backlog_limit)
+	if (ns->backlog_limit &&
+	    skb_queue_len(&ns->queue) > ns->backlog_limit)
 		schedule_timeout(sleep_time);
 
 	__set_current_state(TASK_RUNNING);
@@ -1167,8 +1172,8 @@ audit_log_start_ns(struct audit_namespace *ns,
 		reserve = 5; /* Allow atomic callers to go up to five
 				entries over the normal backlog limit */
 
-	while (audit_backlog_limit
-	       && skb_queue_len(&ns->queue) > audit_backlog_limit + reserve) {
+	while (ns->backlog_limit
+	       && skb_queue_len(&ns->queue) > ns->backlog_limit + reserve) {
 		if (gfp_mask & __GFP_WAIT && audit_backlog_wait_time) {
 			unsigned long sleep_time;
 
@@ -1184,7 +1189,7 @@ audit_log_start_ns(struct audit_namespace *ns,
 			       "audit: audit_backlog=%d > "
 			       "audit_backlog_limit=%d\n",
 			       skb_queue_len(&ns->queue),
-			       audit_backlog_limit);
+			       ns->backlog_limit);
 		audit_log_lost("backlog limit exceeded");
 		audit_backlog_wait_time = audit_backlog_wait_overflow;
 		wake_up(&init_audit_ns.backlog_wait);
-- 
1.8.3.1
