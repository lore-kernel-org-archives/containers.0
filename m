From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 17/22] Audit: make audit_backlog_wait per user namespace
Date: Wed, 19 Jun 2013 09:53:49 +0800
Message-ID: <1371606834-5802-18-git-send-email-gaofeng@cn.fujitsu.com>
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

Tasks are added to audit_backlog_wait when the
audit_skb_queue of user namespace is full, so
audit_backlog_wait should be per user namespace too.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/user_namespace.h |  1 +
 kernel/audit.c                 | 11 +++++------
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 28938f3..c186a84 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -29,6 +29,7 @@ struct audit_ctrl {
 	struct sk_buff_head	hold_queue;
 	struct task_struct	*kauditd_task;
 	wait_queue_head_t	kauditd_wait;
+	wait_queue_head_t	backlog_wait;
 	bool			ever_enabled;
 };
 #endif
diff --git a/kernel/audit.c b/kernel/audit.c
index e3d7da7..3dcaa97 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -119,8 +119,6 @@ static DEFINE_SPINLOCK(audit_freelist_lock);
 static int	   audit_freelist_count;
 static LIST_HEAD(audit_freelist);
 
-static DECLARE_WAIT_QUEUE_HEAD(audit_backlog_wait);
-
 /* Serialize requests from userspace. */
 DEFINE_MUTEX(audit_cmd_mutex);
 
@@ -453,7 +451,7 @@ static int kauditd_thread(void *dummy)
 		flush_hold_queue(ns);
 
 		skb = skb_dequeue(queue);
-		wake_up(&audit_backlog_wait);
+		wake_up(&ns->audit.backlog_wait);
 		if (skb) {
 			if (ns->audit.pid && ns->audit.sock)
 				kauditd_send_skb(ns, skb);
@@ -1119,14 +1117,14 @@ static void wait_for_auditd(unsigned long sleep_time)
 	const struct sk_buff_head *queue = &init_user_ns.audit.queue;
 	DECLARE_WAITQUEUE(wait, current);
 	set_current_state(TASK_UNINTERRUPTIBLE);
-	add_wait_queue(&audit_backlog_wait, &wait);
+	add_wait_queue(&init_user_ns.audit.backlog_wait, &wait);
 
 	if (audit_backlog_limit &&
 	    skb_queue_len(queue) > audit_backlog_limit)
 		schedule_timeout(sleep_time);
 
 	__set_current_state(TASK_RUNNING);
-	remove_wait_queue(&audit_backlog_wait, &wait);
+	remove_wait_queue(&init_user_ns.audit.backlog_wait, &wait);
 }
 
 /**
@@ -1185,7 +1183,7 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 			       audit_backlog_limit);
 		audit_log_lost("backlog limit exceeded");
 		audit_backlog_wait_time = audit_backlog_wait_overflow;
-		wake_up(&audit_backlog_wait);
+		wake_up(&init_user_ns.audit.backlog_wait);
 		return NULL;
 	}
 
@@ -1799,6 +1797,7 @@ void audit_set_user_ns(struct user_namespace *ns)
 	ns->audit.enabled = audit_default;
 	ns->audit.ever_enabled |= !!audit_default;
 	init_waitqueue_head(&ns->audit.kauditd_wait);
+	init_waitqueue_head(&ns->audit.backlog_wait);
 
 	ns->audit.initialized = AUDIT_INITIALIZED;
 }
-- 
1.8.1.4
