From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 04/20] audit: make audit_skb_hold_queue per audit namespace
Date: Thu, 24 Oct 2013 15:31:49 +0800
Message-ID: <1382599925-25143-5-git-send-email-gaofeng@cn.fujitsu.com>
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

This patch makes audit_skb_hold_queue per audit namespace.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit_namespace.h |  3 +++
 kernel/audit.c                  | 12 +++++-------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/audit_namespace.h b/include/linux/audit_namespace.h
index 65acab1..9b7b4c5 100644
--- a/include/linux/audit_namespace.h
+++ b/include/linux/audit_namespace.h
@@ -11,6 +11,8 @@ struct audit_namespace {
 	atomic_t count;
 	struct user_namespace *user_ns;
 	struct sk_buff_head queue;
+	/* queue of skbs to send to auditd when/if it comes back */
+	struct sk_buff_head hold_queue;
 };
 
 extern struct audit_namespace init_audit_ns;
@@ -29,6 +31,7 @@ void put_audit_ns(struct audit_namespace *ns)
 	if (atomic_dec_and_test(&ns->count)) {
 		put_user_ns(ns->user_ns);
 		skb_queue_purge(&ns->queue);
+		skb_queue_purge(&ns->hold_queue);
 		kfree(ns);
 	}
 }
diff --git a/kernel/audit.c b/kernel/audit.c
index f3c2150..51ee701 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -134,8 +134,6 @@ static DEFINE_SPINLOCK(audit_freelist_lock);
 static int	   audit_freelist_count;
 static LIST_HEAD(audit_freelist);
 
-/* queue of skbs to send to auditd when/if it comes back */
-static struct sk_buff_head audit_skb_hold_queue;
 static struct task_struct *kauditd_task;
 static DECLARE_WAIT_QUEUE_HEAD(kauditd_wait);
 static DECLARE_WAIT_QUEUE_HEAD(audit_backlog_wait);
@@ -355,8 +353,8 @@ static int audit_set_failure(int state)
 static void audit_hold_skb(struct sk_buff *skb)
 {
 	if (audit_default &&
-	    skb_queue_len(&audit_skb_hold_queue) < audit_backlog_limit)
-		skb_queue_tail(&audit_skb_hold_queue, skb);
+	    skb_queue_len(&init_audit_ns.hold_queue) < audit_backlog_limit)
+		skb_queue_tail(&init_audit_ns.hold_queue, skb);
 	else
 		kfree_skb(skb);
 }
@@ -420,13 +418,13 @@ static void flush_hold_queue(void)
 	if (!audit_default || !audit_pid)
 		return;
 
-	skb = skb_dequeue(&audit_skb_hold_queue);
+	skb = skb_dequeue(&init_audit_ns.hold_queue);
 	if (likely(!skb))
 		return;
 
 	while (skb && audit_pid) {
 		kauditd_send_skb(skb);
-		skb = skb_dequeue(&audit_skb_hold_queue);
+		skb = skb_dequeue(&init_audit_ns.hold_queue);
 	}
 
 	/*
@@ -912,7 +910,7 @@ static int __init audit_init(void)
 		audit_sock->sk_sndtimeo = MAX_SCHEDULE_TIMEOUT;
 
 	skb_queue_head_init(&init_audit_ns.queue);
-	skb_queue_head_init(&audit_skb_hold_queue);
+	skb_queue_head_init(&init_audit_ns.hold_queue);
 	audit_initialized = AUDIT_INITIALIZED;
 	audit_enabled = audit_default;
 	audit_ever_enabled |= !!audit_default;
-- 
1.8.3.1
