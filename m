From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 05/10] Allow ptrace from non-init user namespaces
Date: Thu, 24 Feb 2011 15:02:43 +0000
Message-ID: <20110224150243.GE8262__2207.30578662387$1298559956$gmane$org@mail.hallyn.com>
References: <20110224150150.GA8262@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110224150150.GA8262-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dlezcano-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, oleg-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org


ptrace is allowed to tasks in the same user namespace according to
the usual rules (i.e. the same rules as for two tasks in the init
user namespace).  ptrace is also allowed to a user namespace to
which the current task the has CAP_SYS_PTRACE capability.

Changelog:
	Dec 31: Address feedback by Eric:
		. Correct ptrace uid check
		. Rename may_ptrace_ns to ptrace_capable
		. Also fix the cap_ptrace checks.
	Jan  1: Use const cred struct
	Jan 11: use task_ns_capable() in place of ptrace_capable().
	Feb 23: same_or_ancestore_user_ns() was not an appropriate
		check to constrain cap_issubset.  Rather, cap_issubset()
		only is meaningful when both capsets are in the same
		user_ns.

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Acked-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
---
 include/linux/capability.h |    2 ++
 kernel/ptrace.c            |   27 +++++++++++++++------------
 security/commoncap.c       |   40 ++++++++++++++++++++++++++++++++--------
 3 files changed, 49 insertions(+), 20 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index 7c9c829..2ec4a8c 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -553,6 +553,8 @@ static inline kernel_cap_t cap_raise_nfsd_set(const kernel_cap_t a,
  */
 #define has_capability(t, cap) (security_real_capable((t), &init_user_ns, (cap)) == 0)
 
+#define has_ns_capability(t, ns, cap) (security_real_capable((t), (ns), (cap)) == 0)
+
 /**
  * has_capability_noaudit - Determine if a task has a superior capability available (unaudited)
  * @t: The task in question
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 1708b1e..cde4655 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -134,21 +134,24 @@ int __ptrace_may_access(struct task_struct *task, unsigned int mode)
 		return 0;
 	rcu_read_lock();
 	tcred = __task_cred(task);
-	if ((cred->uid != tcred->euid ||
-	     cred->uid != tcred->suid ||
-	     cred->uid != tcred->uid  ||
-	     cred->gid != tcred->egid ||
-	     cred->gid != tcred->sgid ||
-	     cred->gid != tcred->gid) &&
-	    !capable(CAP_SYS_PTRACE)) {
-		rcu_read_unlock();
-		return -EPERM;
-	}
+	if (cred->user->user_ns == tcred->user->user_ns &&
+	    (cred->uid == tcred->euid &&
+	     cred->uid == tcred->suid &&
+	     cred->uid == tcred->uid  &&
+	     cred->gid == tcred->egid &&
+	     cred->gid == tcred->sgid &&
+	     cred->gid == tcred->gid))
+		goto ok;
+	if (ns_capable(tcred->user->user_ns, CAP_SYS_PTRACE))
+		goto ok;
+	rcu_read_unlock();
+	return -EPERM;
+ok:
 	rcu_read_unlock();
 	smp_rmb();
 	if (task->mm)
 		dumpable = get_dumpable(task->mm);
-	if (!dumpable && !capable(CAP_SYS_PTRACE))
+	if (!dumpable && !task_ns_capable(task, CAP_SYS_PTRACE))
 		return -EPERM;
 
 	return security_ptrace_access_check(task, mode);
@@ -198,7 +201,7 @@ int ptrace_attach(struct task_struct *task)
 		goto unlock_tasklist;
 
 	task->ptrace = PT_PTRACED;
-	if (capable(CAP_SYS_PTRACE))
+	if (task_ns_capable(task, CAP_SYS_PTRACE))
 		task->ptrace |= PT_PTRACE_CAP;
 
 	__ptrace_link(task, current);
diff --git a/security/commoncap.c b/security/commoncap.c
index 6f4c327..5700ba5 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -128,18 +128,30 @@ int cap_settime(struct timespec *ts, struct timezone *tz)
  * @child: The process to be accessed
  * @mode: The mode of attachment.
  *
+ * If we are in the same or an ancestor user_ns and have all the target
+ * task's capabilities, then ptrace access is allowed.
+ * If we have the ptrace capability to the target user_ns, then ptrace
+ * access is allowed.
+ * Else denied.
+ *
  * Determine whether a process may access another, returning 0 if permission
  * granted, -ve if denied.
  */
 int cap_ptrace_access_check(struct task_struct *child, unsigned int mode)
 {
 	int ret = 0;
+	const struct cred *cred, *child_cred;
 
 	rcu_read_lock();
-	if (!cap_issubset(__task_cred(child)->cap_permitted,
-			  current_cred()->cap_permitted) &&
-	    !capable(CAP_SYS_PTRACE))
-		ret = -EPERM;
+	cred = current_cred();
+	child_cred = __task_cred(child);
+	if (cred->user->user_ns == child_cred->user->user_ns &&
+	    cap_issubset(child_cred->cap_permitted, cred->cap_permitted))
+		goto out;
+	if (ns_capable(child_cred->user->user_ns, CAP_SYS_PTRACE))
+		goto out;
+	ret = -EPERM;
+out:
 	rcu_read_unlock();
 	return ret;
 }
@@ -148,18 +160,30 @@ int cap_ptrace_access_check(struct task_struct *child, unsigned int mode)
  * cap_ptrace_traceme - Determine whether another process may trace the current
  * @parent: The task proposed to be the tracer
  *
+ * If parent is in the same or an ancestor user_ns and has all current's
+ * capabilities, then ptrace access is allowed.
+ * If parent has the ptrace capability to current's user_ns, then ptrace
+ * access is allowed.
+ * Else denied.
+ *
  * Determine whether the nominated task is permitted to trace the current
  * process, returning 0 if permission is granted, -ve if denied.
  */
 int cap_ptrace_traceme(struct task_struct *parent)
 {
 	int ret = 0;
+	const struct cred *cred, *child_cred;
 
 	rcu_read_lock();
-	if (!cap_issubset(current_cred()->cap_permitted,
-			  __task_cred(parent)->cap_permitted) &&
-	    !has_capability(parent, CAP_SYS_PTRACE))
-		ret = -EPERM;
+	cred = __task_cred(parent);
+	child_cred = current_cred();
+	if (cred->user->user_ns == child_cred->user->user_ns &&
+	    cap_issubset(child_cred->cap_permitted, cred->cap_permitted))
+		goto out;
+	if (has_ns_capability(parent, child_cred->user->user_ns, CAP_SYS_PTRACE))
+		goto out;
+	ret = -EPERM;
+out:
 	rcu_read_unlock();
 	return ret;
 }
-- 
1.7.0.4
