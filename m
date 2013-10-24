From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 08/20] audit: make kaudit_wait queue per audit namespace
Date: Thu, 24 Oct 2013 15:31:53 +0800
Message-ID: <1382599925-25143-9-git-send-email-gaofeng@cn.fujitsu.com>
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

kauditd_task is added to the wait queue kaudit_wait when
there is no audit message being generated in audit namespace,
so the kaudit_wait should be per audit namespace too.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit_namespace.h | 2 ++
 kernel/audit.c                  | 8 ++++----
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/audit_namespace.h b/include/linux/audit_namespace.h
index a9e6a40..2888238 100644
--- a/include/linux/audit_namespace.h
+++ b/include/linux/audit_namespace.h
@@ -4,6 +4,7 @@
 #include <linux/audit.h>
 #include <linux/atomic.h>
 #include <linux/slab.h>
+#include <linux/wait.h>
 #include <linux/skbuff.h>
 #include <linux/user_namespace.h>
 
@@ -18,6 +19,7 @@ struct audit_namespace {
 	/* queue of skbs to send to auditd when/if it comes back */
 	struct sk_buff_head hold_queue;
 	struct task_struct *kauditd_task;
+	wait_queue_head_t kauditd_wait;
 };
 
 extern struct audit_namespace init_audit_ns;
diff --git a/kernel/audit.c b/kernel/audit.c
index 37375fb..a4bfd7f 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -126,7 +126,6 @@ static DEFINE_SPINLOCK(audit_freelist_lock);
 static int	   audit_freelist_count;
 static LIST_HEAD(audit_freelist);
 
-static DECLARE_WAIT_QUEUE_HEAD(kauditd_wait);
 static DECLARE_WAIT_QUEUE_HEAD(audit_backlog_wait);
 
 /* Serialize requests from userspace. */
@@ -453,7 +452,7 @@ static int kauditd_thread(void *dummy)
 			continue;
 		}
 		set_current_state(TASK_INTERRUPTIBLE);
-		add_wait_queue(&kauditd_wait, &wait);
+		add_wait_queue(&init_audit_ns.kauditd_wait, &wait);
 
 		if (!skb_queue_len(&ns->queue)) {
 			try_to_freeze();
@@ -461,7 +460,7 @@ static int kauditd_thread(void *dummy)
 		}
 
 		__set_current_state(TASK_RUNNING);
-		remove_wait_queue(&kauditd_wait, &wait);
+		remove_wait_queue(&init_audit_ns.kauditd_wait, &wait);
 	}
 
 	ns->kauditd_task = NULL;
@@ -941,6 +940,7 @@ static int __init audit_init(void)
 	init_audit_ns.kauditd_task = NULL;
 	skb_queue_head_init(&init_audit_ns.queue);
 	skb_queue_head_init(&init_audit_ns.hold_queue);
+	init_waitqueue_head(&init_audit_ns.kauditd_wait);
 	audit_initialized = AUDIT_INITIALIZED;
 	audit_enabled = audit_default;
 	audit_ever_enabled |= !!audit_default;
@@ -1706,7 +1706,7 @@ void audit_log_end(struct audit_buffer *ab)
 
 		if (init_audit_ns.pid) {
 			skb_queue_tail(&init_audit_ns.queue, ab->skb);
-			wake_up_interruptible(&kauditd_wait);
+			wake_up_interruptible(&init_audit_ns.kauditd_wait);
 		} else {
 			audit_printk_skb(ab->skb);
 		}
-- 
1.8.3.1
