From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 7/7] user namespaces: convert several capable() calls
Date: Mon, 10 Jan 2011 21:14:14 +0000
Message-ID: <20110110211414.GG22564__41818.8255549923$1294694295$gmane$org@mail.hallyn.com>
References: <20110110211135.GA22446@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110110211135.GA22446-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

CAP_IPC_OWNER and CAP_IPC_LOCK can be checked against current_user_ns(),
because the resource comes from current's own ipc namespace.

setuid/setgid are to uids in own namespace, so again checks can be
against current_user_ns().

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 ipc/shm.c             |    2 +-
 ipc/util.c            |    5 +++--
 kernel/futex.c        |   11 ++++++++++-
 kernel/futex_compat.c |   11 ++++++++++-
 kernel/groups.c       |    2 +-
 kernel/sched.c        |   25 ++++++++++++++++++++++---
 kernel/uid16.c        |    2 +-
 7 files changed, 48 insertions(+), 10 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index 7d3bb22..13891f8 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -773,7 +773,7 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int, cmd, struct shmid_ds __user *, buf)
 
 		audit_ipc_obj(&(shp->shm_perm));
 
-		if (!capable(CAP_IPC_LOCK)) {
+		if (!ns_capable(current_user_ns(), CAP_IPC_LOCK)) {
 			uid_t euid = current_euid();
 			err = -EPERM;
 			if (euid != shp->shm_perm.uid &&
diff --git a/ipc/util.c b/ipc/util.c
index 69a0cc1..0e832b9 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -627,7 +627,7 @@ int ipcperms (struct kern_ipc_perm *ipcp, short flag)
 		granted_mode >>= 3;
 	/* is there some bit set in requested_mode but not in granted_mode? */
 	if ((requested_mode & ~granted_mode & 0007) && 
-	    !capable(CAP_IPC_OWNER))
+	    !ns_capable(current->cred->user->user_ns, CAP_IPC_OWNER))
 		return -1;
 
 	return security_ipc_permission(ipcp, flag);
@@ -800,7 +800,8 @@ struct kern_ipc_perm *ipcctl_pre_down(struct ipc_ids *ids, int id, int cmd,
 
 	euid = current_euid();
 	if (euid == ipcp->cuid ||
-	    euid == ipcp->uid  || capable(CAP_SYS_ADMIN))
+	    euid == ipcp->uid  ||
+	    ns_capable(current->cred->user->user_ns, CAP_SYS_ADMIN))
 		return ipcp;
 
 	err = -EPERM;
diff --git a/kernel/futex.c b/kernel/futex.c
index 3019b92..1025fd7 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -2387,10 +2387,19 @@ SYSCALL_DEFINE3(get_robust_list, int, pid,
 			goto err_unlock;
 		ret = -EPERM;
 		pcred = __task_cred(p);
+		/* If victim is in different user_ns, then uids are not
+		   comparable, so we must have CAP_SYS_PTRACE */
+		if (cred->user->user_ns != pcred->user->user_ns) {
+			if (ns_capable(pcred->user->user_ns, CAP_SYS_PTRACE))
+				goto ok;
+			goto err_unlock;
+		}
+		/* If victim is in same user_ns, then uids are comparable */
 		if (cred->euid != pcred->euid &&
 		    cred->euid != pcred->uid &&
-		    !capable(CAP_SYS_PTRACE))
+		    !ns_capable(pcred->user->user_ns, CAP_SYS_PTRACE))
 			goto err_unlock;
+ok:
 		head = p->robust_list;
 		rcu_read_unlock();
 	}
diff --git a/kernel/futex_compat.c b/kernel/futex_compat.c
index a7934ac..f84cb9a 100644
--- a/kernel/futex_compat.c
+++ b/kernel/futex_compat.c
@@ -153,10 +153,19 @@ compat_sys_get_robust_list(int pid, compat_uptr_t __user *head_ptr,
 			goto err_unlock;
 		ret = -EPERM;
 		pcred = __task_cred(p);
+		/* If victim is in different user_ns, then uids are not
+		   comparable, so we must have CAP_SYS_PTRACE */
+		if (cred->user->user_ns != pcred->user->user_ns) {
+			if (ns_capable(pcred->user->user_ns, CAP_SYS_PTRACE))
+				goto ok;
+			goto err_unlock;
+		}
+		/* If victim is in same user_ns, then uids are comparable */
 		if (cred->euid != pcred->euid &&
 		    cred->euid != pcred->uid &&
-		    !capable(CAP_SYS_PTRACE))
+		    !ns_capable(pcred->user->user_ns, CAP_SYS_PTRACE))
 			goto err_unlock;
+ok:
 		head = p->compat_robust_list;
 		rcu_read_unlock();
 	}
diff --git a/kernel/groups.c b/kernel/groups.c
index 253dc0f..335586a 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -233,7 +233,7 @@ SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)
 	struct group_info *group_info;
 	int retval;
 
-	if (!capable(CAP_SETGID))
+	if (!ns_capable(current_user_ns(), CAP_SETGID))
 		return -EPERM;
 	if ((unsigned)gidsetsize > NGROUPS_MAX)
 		return -EINVAL;
diff --git a/kernel/sched.c b/kernel/sched.c
index a0eb094..1078fe3 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -4761,8 +4761,11 @@ static bool check_same_owner(struct task_struct *p)
 
 	rcu_read_lock();
 	pcred = __task_cred(p);
-	match = (cred->euid == pcred->euid ||
-		 cred->euid == pcred->uid);
+	if (cred->user->user_ns != pcred->user->user_ns)
+		match = false;
+	match = (cred->user->user_ns == pcred->user->user_ns &&
+			(cred->euid == pcred->euid ||
+			 cred->euid == pcred->uid));
 	rcu_read_unlock();
 	return match;
 }
@@ -5058,6 +5061,22 @@ out_unlock:
 	return retval;
 }
 
+/* TODO: Create a common helper to consolidate sched_capable and
+ * ptrace_capable, silly.
+ */
+static inline int sched_capable(struct task_struct *t, int cap)
+{
+	struct user_namespace *ns;
+	int ret;
+
+	rcu_read_lock();
+	ns = task_cred_xxx(t, user)->user_ns;
+	ret = ns_capable(ns, cap);
+	rcu_read_unlock();
+
+	return ret;
+}
+
 long sched_setaffinity(pid_t pid, const struct cpumask *in_mask)
 {
 	cpumask_var_t cpus_allowed, new_mask;
@@ -5087,7 +5106,7 @@ long sched_setaffinity(pid_t pid, const struct cpumask *in_mask)
 		goto out_free_cpus_allowed;
 	}
 	retval = -EPERM;
-	if (!check_same_owner(p) && !capable(CAP_SYS_NICE))
+	if (!check_same_owner(p) && !sched_capable(p, CAP_SYS_NICE))
 		goto out_unlock;
 
 	retval = security_task_setscheduler(p);
diff --git a/kernel/uid16.c b/kernel/uid16.c
index 4192098..8a70480 100644
--- a/kernel/uid16.c
+++ b/kernel/uid16.c
@@ -189,7 +189,7 @@ SYSCALL_DEFINE2(setgroups16, int, gidsetsize, old_gid_t __user *, grouplist)
 	struct group_info *group_info;
 	int retval;
 
-	if (!capable(CAP_SETGID))
+	if (!ns_capable(current_user_ns(), CAP_SETGID))
 		return -EPERM;
 	if ((unsigned)gidsetsize > NGROUPS_MAX)
 		return -EINVAL;
-- 
1.7.0.4
