From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] userns: ptrace: incorporate feedback from Eric
Date: Thu, 24 Feb 2011 00:49:01 +0000
Message-ID: <20110224004901.GB11822__30756.96624951$1298508809$gmane$org@mail.hallyn.com>
References: <20110217150224.GA26334@mail.hallyn.com>
	<20110217150333.GE26395@mail.hallyn.com>
	<m1aahu9hea.fsf@fess.ebiederm.org>
	<20110218043601.GB9584@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110218043601.GB9584-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

same_or_ancestore_user_ns() was not an appropriate check to
constrain cap_issubset.  Rather, cap_issubset() only is
meaningful when both capsets are in the same user_ns.

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 include/linux/user_namespace.h |    9 ---------
 kernel/user_namespace.c        |   16 ----------------
 security/commoncap.c           |   28 ++++++++++------------------
 3 files changed, 10 insertions(+), 43 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 862fc59..faf4679 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -39,9 +39,6 @@ static inline void put_user_ns(struct user_namespace *ns)
 uid_t user_ns_map_uid(struct user_namespace *to, const struct cred *cred, uid_t uid);
 gid_t user_ns_map_gid(struct user_namespace *to, const struct cred *cred, gid_t gid);
 
-int same_or_ancestor_user_ns(struct task_struct *task,
-	struct task_struct *victim);
-
 #else
 
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
@@ -69,12 +66,6 @@ static inline gid_t user_ns_map_gid(struct user_namespace *to,
 	return gid;
 }
 
-static inline int same_or_ancestor_user_ns(struct task_struct *task,
-	struct task_struct *victim)
-{
-	return 1;
-}
-
 #endif
 
 #endif /* _LINUX_USER_H */
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 0ef2258..9da289c 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -129,22 +129,6 @@ gid_t user_ns_map_gid(struct user_namespace *to, const struct cred *cred, gid_t
 	return overflowgid;
 }
 
-int same_or_ancestor_user_ns(struct task_struct *task,
-	struct task_struct *victim)
-{
-	struct user_namespace *u1 = task_cred_xxx(task, user)->user_ns;
-	struct user_namespace *u2 = task_cred_xxx(victim, user)->user_ns;
-	for (;;) {
-		if (u1 == u2)
-			return 1;
-		if (u1 == &init_user_ns)
-			return 0;
-		u1 = u1->creator->user_ns;
-	}
-	/* We never get here */
-	return 0;
-}
-
 static __init int user_namespaces_init(void)
 {
 	user_ns_cachep = KMEM_CACHE(user_namespace, SLAB_PANIC);
diff --git a/security/commoncap.c b/security/commoncap.c
index 12ff65c..526106f 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -142,19 +142,15 @@ int cap_settime(struct timespec *ts, struct timezone *tz)
 int cap_ptrace_access_check(struct task_struct *child, unsigned int mode)
 {
 	int ret = 0;
-	const struct cred *cred, *tcred;
+	const struct cred *cred, *child_cred;
 
 	rcu_read_lock();
 	cred = current_cred();
-	tcred = __task_cred(child);
-	/*
-	 * The ancestor user_ns check may be gratuitous, as I think
-	 * we've already guaranteed that in kernel/ptrace.c.
-	 */
-	if (same_or_ancestor_user_ns(current, child) &&
-	    cap_issubset(tcred->cap_permitted, cred->cap_permitted))
+	child_cred = __task_cred(child);
+	if (cred->user->user_ns == child_cred->user->user_ns &&
+	    cap_issubset(child_cred->cap_permitted, cred->cap_permitted))
 		goto out;
-	if (ns_capable(tcred->user->user_ns, CAP_SYS_PTRACE))
+	if (ns_capable(child_cred->user->user_ns, CAP_SYS_PTRACE))
 		goto out;
 	ret = -EPERM;
 out:
@@ -178,19 +174,15 @@ out:
 int cap_ptrace_traceme(struct task_struct *parent)
 {
 	int ret = 0;
-	const struct cred *cred, *tcred;
+	const struct cred *cred, *child_cred;
 
 	rcu_read_lock();
 	cred = __task_cred(parent);
-	tcred = current_cred();
-	/*
-	 * The ancestor user_ns check may be gratuitous, as I think
-	 * we've already guaranteed that in kernel/ptrace.c.
-	 */
-	if (same_or_ancestor_user_ns(parent, current) &&
-	    cap_issubset(tcred->cap_permitted, cred->cap_permitted))
+	child_cred = current_cred();
+	if (cred->user->user_ns == child_cred->user->user_ns &&
+	    cap_issubset(child_cred->cap_permitted, cred->cap_permitted))
 		goto out;
-	if (has_ns_capability(parent, tcred->user->user_ns, CAP_SYS_PTRACE))
+	if (has_ns_capability(parent, child_cred->user->user_ns, CAP_SYS_PTRACE))
 		goto out;
 	ret = -EPERM;
 out:
-- 
1.7.0.4
