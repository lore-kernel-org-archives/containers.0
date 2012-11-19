From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 08/16] userns: Kill task_user_ns
Date: Mon, 19 Nov 2012 07:12:33 -0800
Message-ID: <1353337961-12962-8-git-send-email-ebiederm__2753.35384435511$1353338042$gmane$org@xmission.com>
References: <87lidx8wbo.fsf@xmission.com>
	<1353337961-12962-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353337961-12962-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

The task_user_ns function hides the fact that it is getting the user
namespace from struct cred on the task.  struct cred may go away as
soon as the rcu lock is released.  This leads to a race where we
can dereference a stale user namespace pointer.

To make it obvious a struct cred is involved kill task_user_ns.

To kill the race modify the users of task_user_ns to only
reference the user namespace while the rcu lock is held.

Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/cred.h     |    2 --
 kernel/ptrace.c          |   10 ++++++++--
 kernel/sched/core.c      |   10 ++++++++--
 security/yama/yama_lsm.c |   12 +++++++++---
 4 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/include/linux/cred.h b/include/linux/cred.h
index ebbed2c..856d262 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -357,10 +357,8 @@ static inline void put_cred(const struct cred *_cred)
 extern struct user_namespace init_user_ns;
 #ifdef CONFIG_USER_NS
 #define current_user_ns()	(current_cred_xxx(user_ns))
-#define task_user_ns(task)	(task_cred_xxx((task), user_ns))
 #else
 #define current_user_ns()	(&init_user_ns)
-#define task_user_ns(task)	(&init_user_ns)
 #endif
 
 
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 1f5e55d..7b09b88 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -215,8 +215,12 @@ ok:
 	smp_rmb();
 	if (task->mm)
 		dumpable = get_dumpable(task->mm);
-	if (!dumpable  && !ptrace_has_cap(task_user_ns(task), mode))
+	rcu_read_lock();
+	if (!dumpable && !ptrace_has_cap(__task_cred(task)->user_ns, mode)) {
+		rcu_read_unlock();
 		return -EPERM;
+	}
+	rcu_read_unlock();
 
 	return security_ptrace_access_check(task, mode);
 }
@@ -280,8 +284,10 @@ static int ptrace_attach(struct task_struct *task, long request,
 
 	if (seize)
 		flags |= PT_SEIZED;
-	if (ns_capable(task_user_ns(task), CAP_SYS_PTRACE))
+	rcu_read_lock();
+	if (ns_capable(__task_cred(task)->user_ns, CAP_SYS_PTRACE))
 		flags |= PT_PTRACE_CAP;
+	rcu_read_unlock();
 	task->ptrace = flags;
 
 	__ptrace_link(task, current);
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 2d8927f..2f5eb18 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4029,8 +4029,14 @@ long sched_setaffinity(pid_t pid, const struct cpumask *in_mask)
 		goto out_free_cpus_allowed;
 	}
 	retval = -EPERM;
-	if (!check_same_owner(p) && !ns_capable(task_user_ns(p), CAP_SYS_NICE))
-		goto out_unlock;
+	if (!check_same_owner(p)) {
+		rcu_read_lock();
+		if (!ns_capable(__task_cred(p)->user_ns, CAP_SYS_NICE)) {
+			rcu_read_unlock();
+			goto out_unlock;
+		}
+		rcu_read_unlock();
+	}
 
 	retval = security_task_setscheduler(p);
 	if (retval)
diff --git a/security/yama/yama_lsm.c b/security/yama/yama_lsm.c
index b4c2984..0e72239 100644
--- a/security/yama/yama_lsm.c
+++ b/security/yama/yama_lsm.c
@@ -262,14 +262,18 @@ int yama_ptrace_access_check(struct task_struct *child,
 			/* No additional restrictions. */
 			break;
 		case YAMA_SCOPE_RELATIONAL:
+			rcu_read_lock();
 			if (!task_is_descendant(current, child) &&
 			    !ptracer_exception_found(current, child) &&
-			    !ns_capable(task_user_ns(child), CAP_SYS_PTRACE))
+			    !ns_capable(__task_cred(child)->user_ns, CAP_SYS_PTRACE))
 				rc = -EPERM;
+			rcu_read_unlock();
 			break;
 		case YAMA_SCOPE_CAPABILITY:
-			if (!ns_capable(task_user_ns(child), CAP_SYS_PTRACE))
+			rcu_read_lock();
+			if (!ns_capable(__task_cred(child)->user_ns, CAP_SYS_PTRACE))
 				rc = -EPERM;
+			rcu_read_unlock();
 			break;
 		case YAMA_SCOPE_NO_ATTACH:
 		default:
@@ -307,8 +311,10 @@ int yama_ptrace_traceme(struct task_struct *parent)
 	/* Only disallow PTRACE_TRACEME on more aggressive settings. */
 	switch (ptrace_scope) {
 	case YAMA_SCOPE_CAPABILITY:
-		if (!ns_capable(task_user_ns(parent), CAP_SYS_PTRACE))
+		rcu_read_lock();
+		if (!ns_capable(__task_cred(parent)->user_ns, CAP_SYS_PTRACE))
 			rc = -EPERM;
+		rcu_read_unlock();
 		break;
 	case YAMA_SCOPE_NO_ATTACH:
 		rc = -EPERM;
-- 
1.7.5.4
