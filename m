From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 31/48] Audit: pass proper user namespace to
	audit_filter_syscall
Date: Tue, 7 May 2013 10:20:52 +0800
Message-ID: <1367893269-9308-32-git-send-email-gaofeng__21015.2405816645$1367893506$gmane$org@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1367893269-9308-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

We should use the proper user namespace to filter the syscall.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/auditsc.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 29c3e05..5401d21 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -866,14 +866,15 @@ static enum audit_state audit_filter_task(struct task_struct *tsk, char **key)
  * also not high enough that we already know we have to write an audit
  * record (i.e., the state is AUDIT_SETUP_CONTEXT or AUDIT_BUILD_CONTEXT).
  */
-static enum audit_state audit_filter_syscall(struct task_struct *tsk,
+static enum audit_state audit_filter_syscall(struct user_namespace *ns,
+					     struct task_struct *tsk,
 					     struct audit_context *ctx,
 					     struct list_head *list)
 {
 	struct audit_entry *e;
 	enum audit_state state;
 
-	if (init_user_ns.audit.pid && tsk->tgid == init_user_ns.audit.pid)
+	if (ns->audit.pid && tsk->tgid == ns->audit.pid)
 		return AUDIT_DISABLED;
 
 	rcu_read_lock();
@@ -976,7 +977,7 @@ static inline struct audit_context *audit_get_context(struct task_struct *tsk,
 		context->return_code  = return_code;
 
 	if (context->in_syscall && !context->dummy) {
-		audit_filter_syscall(tsk, context,
+		audit_filter_syscall(ns, tsk, context,
 				&ns->audit.filter_list[AUDIT_FILTER_EXIT]);
 		audit_filter_inodes(tsk, context);
 	}
@@ -1784,7 +1785,7 @@ void __audit_syscall_entry(int arch, int major,
 	context->dummy = !audit_n_rules;
 	if (!context->dummy && state == AUDIT_BUILD_CONTEXT) {
 		context->prio = 0;
-		state = audit_filter_syscall(tsk, context,
+		state = audit_filter_syscall(ns, tsk, context,
 			&ns->audit.filter_list[AUDIT_FILTER_ENTRY]);
 	}
 	if (state == AUDIT_DISABLED)
-- 
1.8.1.4
