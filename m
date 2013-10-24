From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 09/20] audit: make audit_backlog_wait per audit namespace
Date: Thu, 24 Oct 2013 15:31:54 +0800
Message-ID: <1382599925-25143-10-git-send-email-gaofeng__32000.0846557834$1382599934$gmane$org@cn.fujitsu.com>
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

Tasks are added to audit_backlog_wait when the
audit_skb_queue of audit namespace is full, so
audit_backlog_wait should be per audit namespace too.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit_namespace.h |  1 +
 kernel/audit.c                  | 11 +++++------
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/audit_namespace.h b/include/linux/audit_namespace.h
index 2888238..79a9b78 100644
--- a/include/linux/audit_namespace.h
+++ b/include/linux/audit_namespace.h
@@ -20,6 +20,7 @@ struct audit_namespace {
 	struct sk_buff_head hold_queue;
 	struct task_struct *kauditd_task;
 	wait_queue_head_t kauditd_wait;
+	wait_queue_head_t backlog_wait;
 };
 
 extern struct audit_namespace init_audit_ns;
diff --git a/kernel/audit.c b/kernel/audit.c
index a4bfd7f..d7a0993 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -126,8 +126,6 @@ static DEFINE_SPINLOCK(audit_freelist_lock);
 static int	   audit_freelist_count;
 static LIST_HEAD(audit_freelist);
 
-static DECLARE_WAIT_QUEUE_HEAD(audit_backlog_wait);
-
 /* Serialize requests from userspace. */
 DEFINE_MUTEX(audit_cmd_mutex);
 
@@ -443,7 +441,7 @@ static int kauditd_thread(void *dummy)
 		flush_hold_queue(ns);
 
 		skb = skb_dequeue(&ns->queue);
-		wake_up(&audit_backlog_wait);
+		wake_up(&init_audit_ns.backlog_wait);
 		if (skb) {
 			if (ns->pid)
 				kauditd_send_skb(skb);
@@ -941,6 +939,7 @@ static int __init audit_init(void)
 	skb_queue_head_init(&init_audit_ns.queue);
 	skb_queue_head_init(&init_audit_ns.hold_queue);
 	init_waitqueue_head(&init_audit_ns.kauditd_wait);
+	init_waitqueue_head(&init_audit_ns.backlog_wait);
 	audit_initialized = AUDIT_INITIALIZED;
 	audit_enabled = audit_default;
 	audit_ever_enabled |= !!audit_default;
@@ -1091,14 +1090,14 @@ static void wait_for_auditd(unsigned long sleep_time)
 {
 	DECLARE_WAITQUEUE(wait, current);
 	set_current_state(TASK_UNINTERRUPTIBLE);
-	add_wait_queue(&audit_backlog_wait, &wait);
+	add_wait_queue(&init_audit_ns.backlog_wait, &wait);
 
 	if (audit_backlog_limit &&
 	    skb_queue_len(&init_audit_ns.queue) > audit_backlog_limit)
 		schedule_timeout(sleep_time);
 
 	__set_current_state(TASK_RUNNING);
-	remove_wait_queue(&audit_backlog_wait, &wait);
+	remove_wait_queue(&init_audit_ns.backlog_wait, &wait);
 }
 
 /* Obtain an audit buffer.  This routine does locking to obtain the
@@ -1164,7 +1163,7 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 			       audit_backlog_limit);
 		audit_log_lost("backlog limit exceeded");
 		audit_backlog_wait_time = audit_backlog_wait_overflow;
-		wake_up(&audit_backlog_wait);
+		wake_up(&init_audit_ns.backlog_wait);
 		return NULL;
 	}
 
-- 
1.8.3.1
