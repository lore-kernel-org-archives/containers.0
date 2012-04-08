From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 06/43] userns: Use cred->user_ns instead of cred->user->user_ns
Date: Sat,  7 Apr 2012 22:15:02 -0700
Message-ID: <1333862139-31737-6-git-send-email-ebiederm@xmission.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11unyn70b.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Optimize performance and prepare for the removal of the user_ns reference
from user_struct.  Remove the slow long walk through cred->user->user_ns and
instead go straight to cred->user_ns.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ecryptfs/messaging.c      |    2 +-
 ipc/namespace.c              |    2 +-
 kernel/ptrace.c              |    4 ++--
 kernel/sched/core.c          |    2 +-
 kernel/signal.c              |    4 ++--
 kernel/sys.c                 |    8 ++++----
 kernel/user_namespace.c      |    4 ++--
 kernel/utsname.c             |    2 +-
 security/commoncap.c         |   14 +++++++-------
 security/keys/key.c          |    2 +-
 security/keys/permission.c   |    2 +-
 security/keys/process_keys.c |    2 +-
 12 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/fs/ecryptfs/messaging.c b/fs/ecryptfs/messaging.c
index ab22480..a750f95 100644
--- a/fs/ecryptfs/messaging.c
+++ b/fs/ecryptfs/messaging.c
@@ -303,7 +303,7 @@ int ecryptfs_process_response(struct ecryptfs_message *msg, uid_t euid,
 		mutex_unlock(&ecryptfs_daemon_hash_mux);
 		goto wake_up;
 	}
-	tsk_user_ns = __task_cred(msg_ctx->task)->user->user_ns;
+	tsk_user_ns = __task_cred(msg_ctx->task)->user_ns;
 	ctx_euid = task_euid(msg_ctx->task);
 	rc = ecryptfs_find_daemon_by_euid(&daemon, ctx_euid, tsk_user_ns);
 	rcu_read_unlock();
diff --git a/ipc/namespace.c b/ipc/namespace.c
index ce0a647..f362298c 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -46,7 +46,7 @@ static struct ipc_namespace *create_ipc_ns(struct task_struct *tsk,
 	ipcns_notify(IPCNS_CREATED);
 	register_ipcns_notifier(ns);
 
-	ns->user_ns = get_user_ns(task_cred_xxx(tsk, user)->user_ns);
+	ns->user_ns = get_user_ns(task_cred_xxx(tsk, user_ns));
 
 	return ns;
 }
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index ee8d49b..24e0a5a 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -198,7 +198,7 @@ int __ptrace_may_access(struct task_struct *task, unsigned int mode)
 		return 0;
 	rcu_read_lock();
 	tcred = __task_cred(task);
-	if (cred->user->user_ns == tcred->user->user_ns &&
+	if (cred->user_ns == tcred->user_ns &&
 	    (cred->uid == tcred->euid &&
 	     cred->uid == tcred->suid &&
 	     cred->uid == tcred->uid  &&
@@ -206,7 +206,7 @@ int __ptrace_may_access(struct task_struct *task, unsigned int mode)
 	     cred->gid == tcred->sgid &&
 	     cred->gid == tcred->gid))
 		goto ok;
-	if (ptrace_has_cap(tcred->user->user_ns, mode))
+	if (ptrace_has_cap(tcred->user_ns, mode))
 		goto ok;
 	rcu_read_unlock();
 	return -EPERM;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 4603b9d..96bff85 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4042,7 +4042,7 @@ static bool check_same_owner(struct task_struct *p)
 
 	rcu_read_lock();
 	pcred = __task_cred(p);
-	if (cred->user->user_ns == pcred->user->user_ns)
+	if (cred->user_ns == pcred->user_ns)
 		match = (cred->euid == pcred->euid ||
 			 cred->euid == pcred->uid);
 	else
diff --git a/kernel/signal.c b/kernel/signal.c
index 17afcaf..e2c5d84 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -767,14 +767,14 @@ static int kill_ok_by_cred(struct task_struct *t)
 	const struct cred *cred = current_cred();
 	const struct cred *tcred = __task_cred(t);
 
-	if (cred->user->user_ns == tcred->user->user_ns &&
+	if (cred->user_ns == tcred->user_ns &&
 	    (cred->euid == tcred->suid ||
 	     cred->euid == tcred->uid ||
 	     cred->uid  == tcred->suid ||
 	     cred->uid  == tcred->uid))
 		return 1;
 
-	if (ns_capable(tcred->user->user_ns, CAP_KILL))
+	if (ns_capable(tcred->user_ns, CAP_KILL))
 		return 1;
 
 	return 0;
diff --git a/kernel/sys.c b/kernel/sys.c
index f7a4351..82d8714 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -133,11 +133,11 @@ static bool set_one_prio_perm(struct task_struct *p)
 {
 	const struct cred *cred = current_cred(), *pcred = __task_cred(p);
 
-	if (pcred->user->user_ns == cred->user->user_ns &&
+	if (pcred->user_ns == cred->user_ns &&
 	    (pcred->uid  == cred->euid ||
 	     pcred->euid == cred->euid))
 		return true;
-	if (ns_capable(pcred->user->user_ns, CAP_SYS_NICE))
+	if (ns_capable(pcred->user_ns, CAP_SYS_NICE))
 		return true;
 	return false;
 }
@@ -1498,7 +1498,7 @@ static int check_prlimit_permission(struct task_struct *task)
 		return 0;
 
 	tcred = __task_cred(task);
-	if (cred->user->user_ns == tcred->user->user_ns &&
+	if (cred->user_ns == tcred->user_ns &&
 	    (cred->uid == tcred->euid &&
 	     cred->uid == tcred->suid &&
 	     cred->uid == tcred->uid  &&
@@ -1506,7 +1506,7 @@ static int check_prlimit_permission(struct task_struct *task)
 	     cred->gid == tcred->sgid &&
 	     cred->gid == tcred->gid))
 		return 0;
-	if (ns_capable(tcred->user->user_ns, CAP_SYS_RESOURCE))
+	if (ns_capable(tcred->user_ns, CAP_SYS_RESOURCE))
 		return 0;
 
 	return -EPERM;
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 3b906e9..f084083 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -90,7 +90,7 @@ uid_t user_ns_map_uid(struct user_namespace *to, const struct cred *cred, uid_t
 {
 	struct user_namespace *tmp;
 
-	if (likely(to == cred->user->user_ns))
+	if (likely(to == cred->user_ns))
 		return uid;
 
 
@@ -112,7 +112,7 @@ gid_t user_ns_map_gid(struct user_namespace *to, const struct cred *cred, gid_t
 {
 	struct user_namespace *tmp;
 
-	if (likely(to == cred->user->user_ns))
+	if (likely(to == cred->user_ns))
 		return gid;
 
 	/* Is cred->user the creator of the target user_ns
diff --git a/kernel/utsname.c b/kernel/utsname.c
index 405caf9..679d97a 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -43,7 +43,7 @@ static struct uts_namespace *clone_uts_ns(struct task_struct *tsk,
 
 	down_read(&uts_sem);
 	memcpy(&ns->name, &old_ns->name, sizeof(ns->name));
-	ns->user_ns = get_user_ns(task_cred_xxx(tsk, user)->user_ns);
+	ns->user_ns = get_user_ns(task_cred_xxx(tsk, user_ns));
 	up_read(&uts_sem);
 	return ns;
 }
diff --git a/security/commoncap.c b/security/commoncap.c
index 0cf4b53..8b3e10e 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -81,7 +81,7 @@ int cap_capable(const struct cred *cred, struct user_namespace *targ_ns,
 			return 0;
 
 		/* Do we have the necessary capabilities? */
-		if (targ_ns == cred->user->user_ns)
+		if (targ_ns == cred->user_ns)
 			return cap_raised(cred->cap_effective, cap) ? 0 : -EPERM;
 
 		/* Have we tried all of the parent namespaces? */
@@ -136,10 +136,10 @@ int cap_ptrace_access_check(struct task_struct *child, unsigned int mode)
 	rcu_read_lock();
 	cred = current_cred();
 	child_cred = __task_cred(child);
-	if (cred->user->user_ns == child_cred->user->user_ns &&
+	if (cred->user_ns == child_cred->user_ns &&
 	    cap_issubset(child_cred->cap_permitted, cred->cap_permitted))
 		goto out;
-	if (ns_capable(child_cred->user->user_ns, CAP_SYS_PTRACE))
+	if (ns_capable(child_cred->user_ns, CAP_SYS_PTRACE))
 		goto out;
 	ret = -EPERM;
 out:
@@ -168,10 +168,10 @@ int cap_ptrace_traceme(struct task_struct *parent)
 	rcu_read_lock();
 	cred = __task_cred(parent);
 	child_cred = current_cred();
-	if (cred->user->user_ns == child_cred->user->user_ns &&
+	if (cred->user_ns == child_cred->user_ns &&
 	    cap_issubset(child_cred->cap_permitted, cred->cap_permitted))
 		goto out;
-	if (has_ns_capability(parent, child_cred->user->user_ns, CAP_SYS_PTRACE))
+	if (has_ns_capability(parent, child_cred->user_ns, CAP_SYS_PTRACE))
 		goto out;
 	ret = -EPERM;
 out:
@@ -214,7 +214,7 @@ static inline int cap_inh_is_capped(void)
 	/* they are so limited unless the current task has the CAP_SETPCAP
 	 * capability
 	 */
-	if (cap_capable(current_cred(), current_cred()->user->user_ns,
+	if (cap_capable(current_cred(), current_cred()->user_ns,
 			CAP_SETPCAP, SECURITY_CAP_AUDIT) == 0)
 		return 0;
 	return 1;
@@ -866,7 +866,7 @@ int cap_task_prctl(int option, unsigned long arg2, unsigned long arg3,
 		    || ((new->securebits & SECURE_ALL_LOCKS & ~arg2))	/*[2]*/
 		    || (arg2 & ~(SECURE_ALL_LOCKS | SECURE_ALL_BITS))	/*[3]*/
 		    || (cap_capable(current_cred(),
-				    current_cred()->user->user_ns, CAP_SETPCAP,
+				    current_cred()->user_ns, CAP_SETPCAP,
 				    SECURITY_CAP_AUDIT) != 0)		/*[4]*/
 			/*
 			 * [1] no changing of bits that are locked
diff --git a/security/keys/key.c b/security/keys/key.c
index 06783cf..7e60347 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -253,7 +253,7 @@ struct key *key_alloc(struct key_type *type, const char *desc,
 	quotalen = desclen + type->def_datalen;
 
 	/* get hold of the key tracking for this user */
-	user = key_user_lookup(uid, cred->user->user_ns);
+	user = key_user_lookup(uid, cred->user_ns);
 	if (!user)
 		goto no_memory_1;
 
diff --git a/security/keys/permission.c b/security/keys/permission.c
index c35b522..e146cbd 100644
--- a/security/keys/permission.c
+++ b/security/keys/permission.c
@@ -36,7 +36,7 @@ int key_task_permission(const key_ref_t key_ref, const struct cred *cred,
 
 	key = key_ref_to_ptr(key_ref);
 
-	if (key->user->user_ns != cred->user->user_ns)
+	if (key->user->user_ns != cred->user_ns)
 		goto use_other_perms;
 
 	/* use the second 8-bits of permissions for keys the caller owns */
diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index be7ecb2..70febff 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -858,7 +858,7 @@ void key_replace_session_keyring(void)
 	new-> sgid	= old-> sgid;
 	new->fsgid	= old->fsgid;
 	new->user	= get_uid(old->user);
-	new->user_ns	= new->user->user_ns;
+	new->user_ns	= new->user_ns;
 	new->group_info	= get_group_info(old->group_info);
 
 	new->securebits	= old->securebits;
-- 
1.7.2.5
