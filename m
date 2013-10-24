From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 05/20] audit: make audit_pid per audit namespace
Date: Thu, 24 Oct 2013 15:31:50 +0800
Message-ID: <1382599925-25143-6-git-send-email-gaofeng__27255.759193986$1382599950$gmane$org@cn.fujitsu.com>
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

Every audit namespace has its own auditd process,
so audit_pid should be per audit namespace too.

Since some places such as audit_filter_syscall
use audit_pid to identify if the task is auditd,
so we should store auditd's pid which for init
pid namespace not for current pid ns.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit_namespace.h |  2 ++
 kernel/audit.c                  | 43 ++++++++++++++++++++++++++++++-----------
 kernel/audit.h                  |  5 ++---
 kernel/auditsc.c                |  6 +++---
 4 files changed, 39 insertions(+), 17 deletions(-)

diff --git a/include/linux/audit_namespace.h b/include/linux/audit_namespace.h
index 9b7b4c5..fdbb6c1 100644
--- a/include/linux/audit_namespace.h
+++ b/include/linux/audit_namespace.h
@@ -9,6 +9,8 @@
 
 struct audit_namespace {
 	atomic_t count;
+	/* pid of the auditd process */
+	int pid;
 	struct user_namespace *user_ns;
 	struct sk_buff_head queue;
 	/* queue of skbs to send to auditd when/if it comes back */
diff --git a/kernel/audit.c b/kernel/audit.c
index 51ee701..e5e8cb1 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -94,7 +94,6 @@ static int	audit_failure = AUDIT_FAIL_PRINTK;
  * contains the pid of the auditd process and audit_nlk_portid contains
  * the portid to use to send netlink messages to that process.
  */
-int		audit_pid;
 static int	audit_nlk_portid;
 
 /* If audit_rate_limit is non-zero, limit the rate of sending audit records
@@ -187,7 +186,7 @@ void audit_panic(const char *message)
 		break;
 	case AUDIT_FAIL_PANIC:
 		/* test audit_pid since printk is always losey, why bother? */
-		if (audit_pid)
+		if (init_audit_ns.pid)
 			panic("audit: %s\n", message);
 		break;
 	}
@@ -386,9 +385,9 @@ static void kauditd_send_skb(struct sk_buff *skb)
 	err = netlink_unicast(audit_sock, skb, audit_nlk_portid, 0);
 	if (err < 0) {
 		BUG_ON(err != -ECONNREFUSED); /* Shouldn't happen */
-		printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n", audit_pid);
+		printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n", init_audit_ns.pid);
 		audit_log_lost("auditd disappeared\n");
-		audit_pid = 0;
+		init_audit_ns.pid = 0;
 		/* we might get lucky and get this in the next auditd */
 		audit_hold_skb(skb);
 	} else
@@ -415,14 +414,14 @@ static void flush_hold_queue(void)
 {
 	struct sk_buff *skb;
 
-	if (!audit_default || !audit_pid)
+	if (!audit_default || !init_audit_ns.pid)
 		return;
 
 	skb = skb_dequeue(&init_audit_ns.hold_queue);
 	if (likely(!skb))
 		return;
 
-	while (skb && audit_pid) {
+	while (skb && init_audit_ns.pid) {
 		kauditd_send_skb(skb);
 		skb = skb_dequeue(&init_audit_ns.hold_queue);
 	}
@@ -447,7 +446,7 @@ static int kauditd_thread(void *dummy)
 		skb = skb_dequeue(&init_audit_ns.queue);
 		wake_up(&audit_backlog_wait);
 		if (skb) {
-			if (audit_pid)
+			if (init_audit_ns.pid)
 				kauditd_send_skb(skb);
 			else
 				audit_printk_skb(skb);
@@ -659,11 +658,22 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	case AUDIT_GET:
 		status_set.enabled	 = audit_enabled;
 		status_set.failure	 = audit_failure;
-		status_set.pid		 = audit_pid;
+		status_set.pid		 = init_audit_ns.pid;
 		status_set.rate_limit	 = audit_rate_limit;
 		status_set.backlog_limit = audit_backlog_limit;
 		status_set.lost		 = atomic_read(&audit_lost);
 		status_set.backlog	 = skb_queue_len(&init_audit_ns.queue);
+
+		rcu_read_lock();
+		{
+			struct task_struct *task;
+
+			task = find_task_by_pid_ns(ns->pid, &init_pid_ns);
+
+			if (task)
+				status_set.pid = task_pid_vnr(task);
+		}
+		rcu_read_unlock();
 		audit_send_reply(NETLINK_CB(skb).portid, seq, AUDIT_GET, 0, 0,
 				 &status_set, sizeof(status_set));
 		break;
@@ -683,10 +693,20 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		}
 		if (status_get->mask & AUDIT_STATUS_PID) {
 			int new_pid = status_get->pid;
+			struct task_struct *task;
+
+			rcu_read_lock();
+			task = find_task_by_vpid(new_pid);
+
+			if (task)
+				new_pid = task_pid_nr_ns(task, &init_pid_ns);
 
 			if (audit_enabled != AUDIT_OFF)
-				audit_log_config_change("audit_pid", new_pid, audit_pid, 1);
-			audit_pid = new_pid;
+				audit_log_config_change("audit_pid", new_pid, init_audit_ns.pid, 1);
+
+			init_audit_ns.pid = new_pid;
+			rcu_read_unlock();
+
 			audit_nlk_portid = NETLINK_CB(skb).portid;
 		}
 		if (status_get->mask & AUDIT_STATUS_RATE_LIMIT) {
@@ -909,6 +929,7 @@ static int __init audit_init(void)
 	else
 		audit_sock->sk_sndtimeo = MAX_SCHEDULE_TIMEOUT;
 
+	init_audit_ns.pid = 0;
 	skb_queue_head_init(&init_audit_ns.queue);
 	skb_queue_head_init(&init_audit_ns.hold_queue);
 	audit_initialized = AUDIT_INITIALIZED;
@@ -1674,7 +1695,7 @@ void audit_log_end(struct audit_buffer *ab)
 		struct nlmsghdr *nlh = nlmsg_hdr(ab->skb);
 		nlh->nlmsg_len = ab->skb->len - NLMSG_HDRLEN;
 
-		if (audit_pid) {
+		if (init_audit_ns.pid) {
 			skb_queue_tail(&init_audit_ns.queue, ab->skb);
 			wake_up_interruptible(&kauditd_wait);
 		} else {
diff --git a/kernel/audit.h b/kernel/audit.h
index 123c9b7..75362dd 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -23,6 +23,7 @@
 #include <linux/audit.h>
 #include <linux/skbuff.h>
 #include <uapi/linux/mqueue.h>
+#include <linux/audit_namespace.h>
 
 /* 0 = no checking
    1 = put_count checking
@@ -218,8 +219,6 @@ extern void audit_log_name(struct audit_context *context,
 			   struct audit_names *n, struct path *path,
 			   int record_num, int *call_panic);
 
-extern int audit_pid;
-
 #define AUDIT_INODE_BUCKETS	32
 extern struct list_head audit_inode_hash[AUDIT_INODE_BUCKETS];
 
@@ -310,7 +309,7 @@ extern u32 audit_sig_sid;
 extern int __audit_signal_info(int sig, struct task_struct *t);
 static inline int audit_signal_info(int sig, struct task_struct *t)
 {
-	if (unlikely((audit_pid && t->tgid == audit_pid) ||
+	if (unlikely((init_audit_ns.pid && t->tgid == init_audit_ns.pid) ||
 		     (audit_signals && !audit_dummy_context())))
 		return __audit_signal_info(sig, t);
 	return 0;
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 9845cb3..61a85d8 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -745,7 +745,7 @@ static enum audit_state audit_filter_syscall(struct task_struct *tsk,
 	struct audit_entry *e;
 	enum audit_state state;
 
-	if (audit_pid && tsk->tgid == audit_pid)
+	if (init_audit_ns.pid && tsk->tgid == init_audit_ns.pid)
 		return AUDIT_DISABLED;
 
 	rcu_read_lock();
@@ -806,7 +806,7 @@ void audit_filter_inodes(struct task_struct *tsk, struct audit_context *ctx)
 {
 	struct audit_names *n;
 
-	if (audit_pid && tsk->tgid == audit_pid)
+	if (init_audit_ns.pid && tsk->tgid == init_audit_ns.pid)
 		return;
 
 	rcu_read_lock();
@@ -2226,7 +2226,7 @@ int __audit_signal_info(int sig, struct task_struct *t)
 	struct audit_context *ctx = tsk->audit_context;
 	kuid_t uid = current_uid(), t_uid = task_uid(t);
 
-	if (audit_pid && t->tgid == audit_pid) {
+	if (init_audit_ns.pid && t->tgid == init_audit_ns.pid) {
 		if (sig == SIGTERM || sig == SIGHUP || sig == SIGUSR1 || sig == SIGUSR2) {
 			audit_sig_pid = tsk->pid;
 			if (uid_valid(tsk->loginuid))
-- 
1.8.3.1
