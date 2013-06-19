From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 11/22] Audit: make audit_ever_enabled per user namespace
Date: Wed, 19 Jun 2013 09:53:43 +0800
Message-ID: <1371606834-5802-12-git-send-email-gaofeng@cn.fujitsu.com>
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

We set audit_ever_enabled true after we enabled audit once.
and if audit_ever_enabled is true, we will allocate audit
context for task.

We should decide if to allocate audit context for tasks based on
if the audit is enabled once in the user namespace which the
task belongs to.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/user_namespace.h | 1 +
 kernel/audit.c                 | 7 +++----
 kernel/auditsc.c               | 5 ++++-
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 9972f0f..a2c0a79 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -27,6 +27,7 @@ struct audit_ctrl {
 	struct sk_buff_head	queue;
 	struct sk_buff_head	hold_queue;
 	struct task_struct	*kauditd_task;
+	bool			ever_enabled;
 };
 #endif
 
diff --git a/kernel/audit.c b/kernel/audit.c
index 758b1e8..923fe27 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -78,7 +78,6 @@ static int	audit_initialized;
 #define AUDIT_OFF	0
 #define AUDIT_ON	1
 #define AUDIT_LOCKED	2
-bool		audit_ever_enabled;
 
 /* Default state when kernel boots without any parameters. */
 static int	audit_default;
@@ -313,7 +312,7 @@ static int audit_set_enabled(struct user_namespace *ns, int state)
 	rc =  audit_do_config_change("audit_enabled", &ns->audit.enabled,
 				     state);
 	if (!rc)
-		audit_ever_enabled |= !!state;
+		ns->audit.ever_enabled |= !!state;
 
 	return rc;
 }
@@ -965,7 +964,6 @@ static int __init audit_init(void)
 
 	audit_set_user_ns(&init_user_ns);
 	audit_initialized = AUDIT_INITIALIZED;
-	audit_ever_enabled |= !!audit_default;
 
 	audit_log(NULL, GFP_KERNEL, AUDIT_KERNEL, "initialized");
 
@@ -987,7 +985,7 @@ static int __init audit_enable(char *str)
 
 	if (audit_initialized == AUDIT_INITIALIZED) {
 		init_user_ns.audit.enabled = audit_default;
-		audit_ever_enabled |= !!audit_default;
+		init_user_ns.audit.ever_enabled |= !!audit_default;
 	} else if (audit_initialized == AUDIT_UNINITIALIZED) {
 		printk(" (after initialization)");
 	} else {
@@ -1792,6 +1790,7 @@ void audit_set_user_ns(struct user_namespace *ns)
 	skb_queue_head_init(&ns->audit.queue);
 	skb_queue_head_init(&ns->audit.hold_queue);
 	ns->audit.enabled = audit_default;
+	ns->audit.ever_enabled |= !!audit_default;
 }
 
 void audit_free_user_ns(struct user_namespace *ns)
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 8ba8684..3fa69cb 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -938,8 +938,11 @@ int audit_alloc(struct task_struct *tsk)
 	struct audit_context *context;
 	enum audit_state     state;
 	char *key = NULL;
+	struct user_namespace *ns = current_user_ns();
+	/* Use current_user_ns, since this new task may run
+	 * in new user namespace */
 
-	if (likely(!audit_ever_enabled))
+	if (likely(!ns->audit.ever_enabled))
 		return 0; /* Return if not auditing. */
 
 	state = audit_filter_task(tsk, &key);
-- 
1.8.1.4
