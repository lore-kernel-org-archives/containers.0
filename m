From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 13/20] audit: introduce new audit logging interface for audit
	namespace
Date: Thu, 24 Oct 2013 15:31:58 +0800
Message-ID: <1382599925-25143-14-git-send-email-gaofeng__45865.465355064$1382599993$gmane$org@cn.fujitsu.com>
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

This interface audit_log_start_ns and audit_log_end_ns
will be used for logging audit logs in audit namespace.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit.h | 26 +++++++++++++--
 kernel/audit.c        | 92 ++++++++++++++++++++++++++++++---------------------
 2 files changed, 77 insertions(+), 41 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 729a4d1..717e1d1 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -43,6 +43,7 @@ struct mq_attr;
 struct mqstat;
 struct audit_watch;
 struct audit_tree;
+struct audit_namespace;
 
 struct audit_krule {
 	int			vers_ops;
@@ -421,10 +422,19 @@ extern __printf(4, 5)
 void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
 	       const char *fmt, ...);
 
-extern struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask, int type);
+extern struct audit_buffer *
+audit_log_start(struct audit_context *ctx, gfp_t gfp_mask, int type);
+
+extern struct audit_buffer *
+audit_log_start_ns(struct audit_namespace *ns,
+		   struct audit_context *ctx,
+		   gfp_t gfp_mask, int type);
+
 extern __printf(2, 3)
 void audit_log_format(struct audit_buffer *ab, const char *fmt, ...);
 extern void		    audit_log_end(struct audit_buffer *ab);
+extern void		    audit_log_end_ns(struct audit_namespace *ns,
+					     struct audit_buffer *ab);
 extern int		    audit_string_contains_control(const char *string,
 							  size_t len);
 extern void		    audit_log_n_hex(struct audit_buffer *ab,
@@ -470,8 +480,15 @@ static inline __printf(4, 5)
 void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
 	       const char *fmt, ...)
 { }
-static inline struct audit_buffer *audit_log_start(struct audit_context *ctx,
-						   gfp_t gfp_mask, int type)
+static inline struct audit_buffer *
+audit_log_start(struct audit_context *ctx, gfp_t gfp_mask, int type)
+{
+	return NULL;
+}
+static inline struct audit_buffer *
+audit_log_start_ns(struct audit_namespace *ns,
+		   struct audit_context *ctx,
+		   gfp_t gfp_mask, int type)
 {
 	return NULL;
 }
@@ -480,6 +497,9 @@ void audit_log_format(struct audit_buffer *ab, const char *fmt, ...)
 { }
 static inline void audit_log_end(struct audit_buffer *ab)
 { }
+static inline void audit_log_end_ns(struct audit_namespace *ns,
+				    struct audit_buffer *ab)
+{ }
 static inline void audit_log_n_hex(struct audit_buffer *ab,
 				   const unsigned char *buf, size_t len)
 { }
diff --git a/kernel/audit.c b/kernel/audit.c
index b203017..5ac7365 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1092,18 +1092,19 @@ static inline void audit_get_stamp(struct audit_context *ctx,
 /*
  * Wait for auditd to drain the queue a little
  */
-static void wait_for_auditd(unsigned long sleep_time)
+static void wait_for_auditd(struct audit_namespace *ns,
+			    unsigned long sleep_time)
 {
 	DECLARE_WAITQUEUE(wait, current);
 	set_current_state(TASK_UNINTERRUPTIBLE);
-	add_wait_queue(&init_audit_ns.backlog_wait, &wait);
+	add_wait_queue(&ns->backlog_wait, &wait);
 
 	if (audit_backlog_limit &&
-	    skb_queue_len(&init_audit_ns.queue) > audit_backlog_limit)
+	    skb_queue_len(&ns->queue) > audit_backlog_limit)
 		schedule_timeout(sleep_time);
 
 	__set_current_state(TASK_RUNNING);
-	remove_wait_queue(&init_audit_ns.backlog_wait, &wait);
+	remove_wait_queue(&ns->backlog_wait, &wait);
 }
 
 /* Obtain an audit buffer.  This routine does locking to obtain the
@@ -1113,23 +1114,10 @@ static void wait_for_auditd(unsigned long sleep_time)
  * will be written at syscall exit.  If there is no associated task, tsk
  * should be NULL. */
 
-/**
- * audit_log_start - obtain an audit buffer
- * @ctx: audit_context (may be NULL)
- * @gfp_mask: type of allocation
- * @type: audit message type
- *
- * Returns audit_buffer pointer on success or NULL on error.
- *
- * Obtain an audit buffer.  This routine does locking to obtain the
- * audit buffer, but then no locking is required for calls to
- * audit_log_*format.  If the task (ctx) is a task that is currently in a
- * syscall, then the syscall is marked as auditable and an audit record
- * will be written at syscall exit.  If there is no associated task, then
- * task context (ctx) should be NULL.
- */
-struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
-				     int type)
+struct audit_buffer *
+audit_log_start_ns(struct audit_namespace *ns,
+		   struct audit_context *ctx,
+		   gfp_t gfp_mask, int type)
 {
 	struct audit_buffer	*ab	= NULL;
 	struct timespec		t;
@@ -1150,14 +1138,14 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 				entries over the normal backlog limit */
 
 	while (audit_backlog_limit
-	       && skb_queue_len(&init_audit_ns.queue) > audit_backlog_limit + reserve) {
+	       && skb_queue_len(&ns->queue) > audit_backlog_limit + reserve) {
 		if (gfp_mask & __GFP_WAIT && audit_backlog_wait_time) {
 			unsigned long sleep_time;
 
 			sleep_time = timeout_start + audit_backlog_wait_time -
 					jiffies;
 			if ((long)sleep_time > 0) {
-				wait_for_auditd(sleep_time);
+				wait_for_auditd(ns, sleep_time);
 				continue;
 			}
 		}
@@ -1165,7 +1153,7 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 			printk(KERN_WARNING
 			       "audit: audit_backlog=%d > "
 			       "audit_backlog_limit=%d\n",
-			       skb_queue_len(&init_audit_ns.queue),
+			       skb_queue_len(&ns->queue),
 			       audit_backlog_limit);
 		audit_log_lost("backlog limit exceeded");
 		audit_backlog_wait_time = audit_backlog_wait_overflow;
@@ -1187,6 +1175,27 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 }
 
 /**
+ * audit_log_start - obtain an audit buffer
+ * @ctx: audit_context (may be NULL)
+ * @gfp_mask: type of allocation
+ * @type: audit message type
+ *
+ * Returns audit_buffer pointer on success or NULL on error.
+ *
+ * Obtain an audit buffer.  This routine does locking to obtain the
+ * audit buffer, but then no locking is required for calls to
+ * audit_log_*format.  If the task (ctx) is a task that is currently in a
+ * syscall, then the syscall is marked as auditable and an audit record
+ * will be written at syscall exit.  If there is no associated task, then
+ * task context (ctx) should be NULL.
+ */
+struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
+				     int type)
+{
+	return audit_log_start_ns(&init_audit_ns, ctx, gfp_mask, type);
+}
+
+/**
  * audit_expand - expand skb in the audit buffer
  * @ab: audit_buffer
  * @extra: space to add at tail of the skb
@@ -1690,16 +1699,7 @@ out:
 	kfree(name);
 }
 
-/**
- * audit_log_end - end one audit record
- * @ab: the audit_buffer
- *
- * The netlink_* functions cannot be called inside an irq context, so
- * the audit buffer is placed on a queue and a tasklet is scheduled to
- * remove them from the queue outside the irq context.  May be called in
- * any context.
- */
-void audit_log_end(struct audit_buffer *ab)
+void audit_log_end_ns(struct audit_namespace *ns, struct audit_buffer *ab)
 {
 	if (!ab)
 		return;
@@ -1709,11 +1709,11 @@ void audit_log_end(struct audit_buffer *ab)
 		struct nlmsghdr *nlh = nlmsg_hdr(ab->skb);
 		nlh->nlmsg_len = ab->skb->len - NLMSG_HDRLEN;
 
-		if (init_audit_ns.pid) {
-			skb_queue_tail(&init_audit_ns.queue, ab->skb);
-			wake_up_interruptible(&init_audit_ns.kauditd_wait);
+		if (ns->pid) {
+			skb_queue_tail(&ns->queue, ab->skb);
+			wake_up_interruptible(&ns->kauditd_wait);
 		} else {
-			audit_printk_skb(&init_audit_ns, ab->skb);
+			audit_printk_skb(ns, ab->skb);
 		}
 		ab->skb = NULL;
 	}
@@ -1721,6 +1721,20 @@ void audit_log_end(struct audit_buffer *ab)
 }
 
 /**
+ * audit_log_end - end one audit record
+ * @ab: the audit_buffer
+ *
+ * The netlink_* functions cannot be called inside an irq context, so
+ * the audit buffer is placed on a queue and a tasklet is scheduled to
+ * remove them from the queue outside the irq context.  May be called in
+ * any context.
+ */
+void audit_log_end(struct audit_buffer *ab)
+{
+	return audit_log_end_ns(&init_audit_ns, ab);
+}
+
+/**
  * audit_log - Log an audit record
  * @ctx: audit context
  * @gfp_mask: type of allocation
@@ -1774,6 +1788,8 @@ EXPORT_SYMBOL(audit_log_secctx);
 #endif
 
 EXPORT_SYMBOL(audit_log_start);
+EXPORT_SYMBOL(audit_log_start_ns);
 EXPORT_SYMBOL(audit_log_end);
+EXPORT_SYMBOL(audit_log_end_ns);
 EXPORT_SYMBOL(audit_log_format);
 EXPORT_SYMBOL(audit_log);
-- 
1.8.3.1
