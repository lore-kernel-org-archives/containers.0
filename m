From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 03/20] audit: make audit_skb_queue per audit namespace
Date: Thu, 24 Oct 2013 15:31:48 +0800
Message-ID: <1382599925-25143-4-git-send-email-gaofeng@cn.fujitsu.com>
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

This patch makes audit_skb_queue per audit namespace,
Since we haven't finished the preparations, only
allow user to attach/detach skb to the queue of
init_audit_ns.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit_namespace.h |  3 +++
 kernel/audit.c                  | 18 +++++++++---------
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/include/linux/audit_namespace.h b/include/linux/audit_namespace.h
index ac22649..65acab1 100644
--- a/include/linux/audit_namespace.h
+++ b/include/linux/audit_namespace.h
@@ -4,11 +4,13 @@
 #include <linux/audit.h>
 #include <linux/atomic.h>
 #include <linux/slab.h>
+#include <linux/skbuff.h>
 #include <linux/user_namespace.h>
 
 struct audit_namespace {
 	atomic_t count;
 	struct user_namespace *user_ns;
+	struct sk_buff_head queue;
 };
 
 extern struct audit_namespace init_audit_ns;
@@ -26,6 +28,7 @@ void put_audit_ns(struct audit_namespace *ns)
 {
 	if (atomic_dec_and_test(&ns->count)) {
 		put_user_ns(ns->user_ns);
+		skb_queue_purge(&ns->queue);
 		kfree(ns);
 	}
 }
diff --git a/kernel/audit.c b/kernel/audit.c
index 468950b..f3c2150 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -64,6 +64,7 @@
 #include <linux/freezer.h>
 #include <linux/tty.h>
 #include <linux/pid_namespace.h>
+#include <linux/audit_namespace.h>
 
 #include "audit.h"
 
@@ -133,7 +134,6 @@ static DEFINE_SPINLOCK(audit_freelist_lock);
 static int	   audit_freelist_count;
 static LIST_HEAD(audit_freelist);
 
-static struct sk_buff_head audit_skb_queue;
 /* queue of skbs to send to auditd when/if it comes back */
 static struct sk_buff_head audit_skb_hold_queue;
 static struct task_struct *kauditd_task;
@@ -446,7 +446,7 @@ static int kauditd_thread(void *dummy)
 
 		flush_hold_queue();
 
-		skb = skb_dequeue(&audit_skb_queue);
+		skb = skb_dequeue(&init_audit_ns.queue);
 		wake_up(&audit_backlog_wait);
 		if (skb) {
 			if (audit_pid)
@@ -458,7 +458,7 @@ static int kauditd_thread(void *dummy)
 		set_current_state(TASK_INTERRUPTIBLE);
 		add_wait_queue(&kauditd_wait, &wait);
 
-		if (!skb_queue_len(&audit_skb_queue)) {
+		if (!skb_queue_len(&init_audit_ns.queue)) {
 			try_to_freeze();
 			schedule();
 		}
@@ -665,7 +665,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		status_set.rate_limit	 = audit_rate_limit;
 		status_set.backlog_limit = audit_backlog_limit;
 		status_set.lost		 = atomic_read(&audit_lost);
-		status_set.backlog	 = skb_queue_len(&audit_skb_queue);
+		status_set.backlog	 = skb_queue_len(&init_audit_ns.queue);
 		audit_send_reply(NETLINK_CB(skb).portid, seq, AUDIT_GET, 0, 0,
 				 &status_set, sizeof(status_set));
 		break;
@@ -911,7 +911,7 @@ static int __init audit_init(void)
 	else
 		audit_sock->sk_sndtimeo = MAX_SCHEDULE_TIMEOUT;
 
-	skb_queue_head_init(&audit_skb_queue);
+	skb_queue_head_init(&init_audit_ns.queue);
 	skb_queue_head_init(&audit_skb_hold_queue);
 	audit_initialized = AUDIT_INITIALIZED;
 	audit_enabled = audit_default;
@@ -1066,7 +1066,7 @@ static void wait_for_auditd(unsigned long sleep_time)
 	add_wait_queue(&audit_backlog_wait, &wait);
 
 	if (audit_backlog_limit &&
-	    skb_queue_len(&audit_skb_queue) > audit_backlog_limit)
+	    skb_queue_len(&init_audit_ns.queue) > audit_backlog_limit)
 		schedule_timeout(sleep_time);
 
 	__set_current_state(TASK_RUNNING);
@@ -1117,7 +1117,7 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 				entries over the normal backlog limit */
 
 	while (audit_backlog_limit
-	       && skb_queue_len(&audit_skb_queue) > audit_backlog_limit + reserve) {
+	       && skb_queue_len(&init_audit_ns.queue) > audit_backlog_limit + reserve) {
 		if (gfp_mask & __GFP_WAIT && audit_backlog_wait_time) {
 			unsigned long sleep_time;
 
@@ -1132,7 +1132,7 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 			printk(KERN_WARNING
 			       "audit: audit_backlog=%d > "
 			       "audit_backlog_limit=%d\n",
-			       skb_queue_len(&audit_skb_queue),
+			       skb_queue_len(&init_audit_ns.queue),
 			       audit_backlog_limit);
 		audit_log_lost("backlog limit exceeded");
 		audit_backlog_wait_time = audit_backlog_wait_overflow;
@@ -1677,7 +1677,7 @@ void audit_log_end(struct audit_buffer *ab)
 		nlh->nlmsg_len = ab->skb->len - NLMSG_HDRLEN;
 
 		if (audit_pid) {
-			skb_queue_tail(&audit_skb_queue, ab->skb);
+			skb_queue_tail(&init_audit_ns.queue, ab->skb);
 			wake_up_interruptible(&kauditd_wait);
 		} else {
 			audit_printk_skb(ab->skb);
-- 
1.8.3.1
