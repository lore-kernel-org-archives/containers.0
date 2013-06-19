From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 08/22] Audit: make kauditd_task per user namespace
Date: Wed, 19 Jun 2013 09:53:40 +0800
Message-ID: <1371606834-5802-9-git-send-email-gaofeng@cn.fujitsu.com>
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

This patch makes kauditd_task per user namespace,
Since right now we only allow user in init user
namesapce to send audit netlink message to kernel,
so actually the kauditd_task belongs to other user
namespace will still not run.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/audit.h          |  1 +
 include/linux/user_namespace.h | 15 +++++++++--
 kernel/audit.c                 | 58 ++++++++++++++++++++++++++----------------
 kernel/audit.h                 |  5 ++--
 kernel/auditsc.c               |  6 ++---
 5 files changed, 55 insertions(+), 30 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 6720901..179351d 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -26,6 +26,7 @@
 #include <linux/sched.h>
 #include <linux/ptrace.h>
 #include <uapi/linux/audit.h>
+#include <linux/user_namespace.h>
 
 struct audit_sig_info {
 	uid_t		uid;
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 53420a4..ae69f20 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -21,8 +21,10 @@ struct uid_gid_map {	/* 64 bytes -- 1 cache line */
 #ifdef CONFIG_AUDIT
 struct audit_ctrl {
 	struct sock		*sock;
+	int			pid;
 	struct sk_buff_head	queue;
 	struct sk_buff_head	hold_queue;
+	struct task_struct	*kauditd_task;
 };
 #endif
 
@@ -59,8 +61,17 @@ extern void free_user_ns(struct user_namespace *ns);
 
 static inline void put_user_ns(struct user_namespace *ns)
 {
-	if (ns && atomic_dec_and_test(&ns->count))
-		free_user_ns(ns);
+	if (ns) {
+		if (atomic_dec_and_test(&ns->count)) {
+			free_user_ns(ns);
+		} else if (atomic_read(&ns->count) == 1) {
+			/* If the last user of this userns is kauditd,
+			 * we should wake up the kauditd and let it kill
+			 * itself, Then this userns will be destroyed.*/
+			if (ns->audit.kauditd_task)
+				wake_up_process(ns->audit.kauditd_task);
+		}
+	}
 }
 
 struct seq_operations;
diff --git a/kernel/audit.c b/kernel/audit.c
index 75325f0..7b696cd5 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -94,7 +94,6 @@ static int	audit_failure = AUDIT_FAIL_PRINTK;
  * contains the pid of the auditd process and audit_nlk_portid contains
  * the portid to use to send netlink messages to that process.
  */
-int		audit_pid;
 static int	audit_nlk_portid;
 
 /* If audit_rate_limit is non-zero, limit the rate of sending audit records
@@ -131,7 +130,6 @@ static DEFINE_SPINLOCK(audit_freelist_lock);
 static int	   audit_freelist_count;
 static LIST_HEAD(audit_freelist);
 
-static struct task_struct *kauditd_task;
 static DECLARE_WAIT_QUEUE_HEAD(kauditd_wait);
 static DECLARE_WAIT_QUEUE_HEAD(audit_backlog_wait);
 
@@ -184,7 +182,7 @@ void audit_panic(const char *message)
 		break;
 	case AUDIT_FAIL_PANIC:
 		/* test audit_pid since printk is always losey, why bother? */
-		if (audit_pid)
+		if (&init_user_ns.audit.pid)
 			panic("audit: %s\n", message);
 		break;
 	}
@@ -386,9 +384,10 @@ static void kauditd_send_skb(struct sk_buff *skb)
 			      audit_nlk_portid, 0);
 	if (err < 0) {
 		BUG_ON(err != -ECONNREFUSED); /* Shouldn't happen */
-		printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n", audit_pid);
+		printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n",
+		       init_user_ns.audit.pid);
 		audit_log_lost("auditd disappeared\n");
-		audit_pid = 0;
+		init_user_ns.audit.pid = 0;
 		/* we might get lucky and get this in the next auditd */
 		audit_hold_skb(skb);
 	} else
@@ -411,19 +410,19 @@ static void kauditd_send_skb(struct sk_buff *skb)
  * in 5 years when I want to play with this again I'll see this
  * note and still have no friggin idea what i'm thinking today.
  */
-static void flush_hold_queue(void)
+static void flush_hold_queue(struct user_namespace *ns)
 {
 	struct sk_buff *skb;
-	struct sk_buff_head *hold_queue = &init_user_ns.audit.hold_queue;
+	struct sk_buff_head *hold_queue = &ns->audit.hold_queue;
 
-	if (!audit_default || !audit_pid || !init_user_ns.audit.sock)
+	if (!audit_default || !ns->audit.pid || !ns->audit.sock)
 		return;
 
 	skb = skb_dequeue(hold_queue);
 	if (likely(!skb))
 		return;
 
-	while (skb && audit_pid) {
+	while (skb && ns->audit.pid) {
 		kauditd_send_skb(skb);
 		skb = skb_dequeue(hold_queue);
 	}
@@ -438,18 +437,26 @@ static void flush_hold_queue(void)
 
 static int kauditd_thread(void *dummy)
 {
+	struct user_namespace *ns = dummy;
+
 	set_freezable();
 	while (!kthread_should_stop()) {
 		struct sk_buff *skb;
-		struct sk_buff_head *queue = &init_user_ns.audit.queue;
+		struct sk_buff_head *queue = &ns->audit.queue;
 		DECLARE_WAITQUEUE(wait, current);
 
-		flush_hold_queue();
+		/* Ok, We are the last user of this userns,
+		 * It's time to go. Kill kauditd thread and
+		 * release the userns. */
+		if (atomic_read(&ns->count) == 1)
+			break;
+
+		flush_hold_queue(ns);
 
 		skb = skb_dequeue(queue);
 		wake_up(&audit_backlog_wait);
 		if (skb) {
-			if (audit_pid && init_user_ns.audit.sock)
+			if (ns->audit.pid && ns->audit.sock)
 				kauditd_send_skb(skb);
 			else
 				audit_printk_skb(skb);
@@ -466,6 +473,8 @@ static int kauditd_thread(void *dummy)
 		__set_current_state(TASK_RUNNING);
 		remove_wait_queue(&kauditd_wait, &wait);
 	}
+
+	put_user_ns(ns);
 	return 0;
 }
 
@@ -658,13 +667,17 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	ns = current_user_ns();
 	/* As soon as there's any sign of userspace auditd,
 	 * start kauditd to talk to it */
-	if (!kauditd_task) {
-		kauditd_task = kthread_run(kauditd_thread, NULL, "kauditd");
-		if (IS_ERR(kauditd_task)) {
-			err = PTR_ERR(kauditd_task);
-			kauditd_task = NULL;
-			return err;
+	if (!ns->audit.kauditd_task) {
+		struct task_struct *tsk;
+
+		tsk = kthread_run(kauditd_thread,
+				  get_user_ns(ns), "kauditd");
+		if (IS_ERR(tsk)) {
+			put_user_ns(ns);
+			return PTR_ERR(tsk);
 		}
+
+		ns->audit.kauditd_task = tsk;
 	}
 	seq  = nlh->nlmsg_seq;
 	data = nlmsg_data(nlh);
@@ -673,7 +686,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	case AUDIT_GET:
 		status_set.enabled	 = audit_enabled;
 		status_set.failure	 = audit_failure;
-		status_set.pid		 = audit_pid;
+		status_set.pid		 = ns->audit.pid;
 		status_set.rate_limit	 = audit_rate_limit;
 		status_set.backlog_limit = audit_backlog_limit;
 		status_set.lost		 = atomic_read(&audit_lost);
@@ -700,8 +713,9 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			int new_pid = status_get->pid;
 
 			if (audit_enabled != AUDIT_OFF)
-				audit_log_config_change("audit_pid", new_pid, audit_pid, 1);
-			audit_pid = new_pid;
+				audit_log_config_change("audit_pid", new_pid,
+							ns->audit.pid, 1);
+			ns->audit.pid = new_pid;
 			audit_nlk_portid = NETLINK_CB(skb).portid;
 		}
 		if (status_get->mask & AUDIT_STATUS_RATE_LIMIT) {
@@ -1714,7 +1728,7 @@ void audit_log_end(struct audit_buffer *ab)
 		struct nlmsghdr *nlh = nlmsg_hdr(ab->skb);
 		nlh->nlmsg_len = ab->skb->len - NLMSG_HDRLEN;
 
-		if (audit_pid && init_user_ns.audit.sock) {
+		if (init_user_ns.audit.pid && init_user_ns.audit.sock) {
 			skb_queue_tail(&init_user_ns.audit.queue, ab->skb);
 			wake_up_interruptible(&kauditd_wait);
 		} else {
diff --git a/kernel/audit.h b/kernel/audit.h
index 2258827..d746214 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -217,8 +217,6 @@ extern void audit_log_name(struct audit_context *context,
 			   struct audit_names *n, struct path *path,
 			   int record_num, int *call_panic);
 
-extern int audit_pid;
-
 #define AUDIT_INODE_BUCKETS	32
 extern struct list_head audit_inode_hash[AUDIT_INODE_BUCKETS];
 
@@ -309,7 +307,8 @@ extern u32 audit_sig_sid;
 extern int __audit_signal_info(int sig, struct task_struct *t);
 static inline int audit_signal_info(int sig, struct task_struct *t)
 {
-	if (unlikely((audit_pid && t->tgid == audit_pid) ||
+	if (unlikely((init_user_ns.audit.pid &&
+		      t->tgid == init_user_ns.audit.pid) ||
 		     (audit_signals && !audit_dummy_context())))
 		return __audit_signal_info(sig, t);
 	return 0;
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 3c8a601..8ba8684 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -745,7 +745,7 @@ static enum audit_state audit_filter_syscall(struct task_struct *tsk,
 	struct audit_entry *e;
 	enum audit_state state;
 
-	if (audit_pid && tsk->tgid == audit_pid)
+	if (init_user_ns.audit.pid && tsk->tgid == init_user_ns.audit.pid)
 		return AUDIT_DISABLED;
 
 	rcu_read_lock();
@@ -806,7 +806,7 @@ void audit_filter_inodes(struct task_struct *tsk, struct audit_context *ctx)
 {
 	struct audit_names *n;
 
-	if (audit_pid && tsk->tgid == audit_pid)
+	if (init_user_ns.audit.pid && tsk->tgid == init_user_ns.audit.pid)
 		return;
 
 	rcu_read_lock();
@@ -2220,7 +2220,7 @@ int __audit_signal_info(int sig, struct task_struct *t)
 	struct audit_context *ctx = tsk->audit_context;
 	kuid_t uid = current_uid(), t_uid = task_uid(t);
 
-	if (audit_pid && t->tgid == audit_pid) {
+	if (init_user_ns.audit.pid && t->tgid == init_user_ns.audit.pid) {
 		if (sig == SIGTERM || sig == SIGHUP || sig == SIGUSR1 || sig == SIGUSR2) {
 			audit_sig_pid = tsk->pid;
 			if (uid_valid(tsk->loginuid))
-- 
1.8.1.4
