From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 08/10] user namespaces: convert several capable() calls
Date: Thu, 24 Feb 2011 15:03:08 +0000
Message-ID: <20110224150308.GH8262__44835.9624170282$1298560533$gmane$org@mail.hallyn.com>
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

CAP_IPC_OWNER and CAP_IPC_LOCK can be checked against current_user_ns(),
because the resource comes from current's own ipc namespace.

setuid/setgid are to uids in own namespace, so again checks can be
against current_user_ns().

Changelog:
	Jan 11: Use task_ns_capable() in place of sched_capable().
	Jan 11: Use nsown_capable() as suggested by Bastian Blank.
	Jan 11: Clarify (hopefully) some logic in futex and sched.c
	Feb 15: use ns_capable for ipc, not nsown_capable
	Feb 23: let copy_ipcs handle setting ipc_ns->user_ns
	Feb 23: pass ns down rather than taking it from current

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Acked-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
---
 include/linux/ipc_namespace.h |    7 ++++---
 ipc/msg.c                     |    8 ++++----
 ipc/namespace.c               |   13 ++++++++-----
 ipc/sem.c                     |    9 +++++----
 ipc/shm.c                     |    9 +++++----
 ipc/util.c                    |   22 +++++++++++++---------
 ipc/util.h                    |    5 +++--
 kernel/futex.c                |   11 ++++++++++-
 kernel/futex_compat.c         |   11 ++++++++++-
 kernel/groups.c               |    2 +-
 kernel/nsproxy.c              |    7 +------
 kernel/sched.c                |    9 ++++++---
 kernel/uid16.c                |    2 +-
 13 files changed, 71 insertions(+), 44 deletions(-)

diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
index c8cdf0e..9ce8bf7 100644
--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -5,6 +5,7 @@
 #include <linux/idr.h>
 #include <linux/rwsem.h>
 #include <linux/notifier.h>
+#include <linux/nsproxy.h>
 
 /*
  * ipc namespace events
@@ -94,7 +95,7 @@ static inline int mq_init_ns(struct ipc_namespace *ns) { return 0; }
 
 #if defined(CONFIG_IPC_NS)
 extern struct ipc_namespace *copy_ipcs(unsigned long flags,
-				       struct ipc_namespace *ns);
+				       struct task_struct *tsk);
 static inline struct ipc_namespace *get_ipc_ns(struct ipc_namespace *ns)
 {
 	if (ns)
@@ -105,12 +106,12 @@ static inline struct ipc_namespace *get_ipc_ns(struct ipc_namespace *ns)
 extern void put_ipc_ns(struct ipc_namespace *ns);
 #else
 static inline struct ipc_namespace *copy_ipcs(unsigned long flags,
-		struct ipc_namespace *ns)
+					      struct task_struct *tsk)
 {
 	if (flags & CLONE_NEWIPC)
 		return ERR_PTR(-EINVAL);
 
-	return ns;
+	return tsk->nsproxy->ipc_ns;
 }
 
 static inline struct ipc_namespace *get_ipc_ns(struct ipc_namespace *ns)
diff --git a/ipc/msg.c b/ipc/msg.c
index 747b655..0e732e9 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -421,7 +421,7 @@ static int msgctl_down(struct ipc_namespace *ns, int msqid, int cmd,
 			return -EFAULT;
 	}
 
-	ipcp = ipcctl_pre_down(&msg_ids(ns), msqid, cmd,
+	ipcp = ipcctl_pre_down(ns, &msg_ids(ns), msqid, cmd,
 			       &msqid64.msg_perm, msqid64.msg_qbytes);
 	if (IS_ERR(ipcp))
 		return PTR_ERR(ipcp);
@@ -539,7 +539,7 @@ SYSCALL_DEFINE3(msgctl, int, msqid, int, cmd, struct msqid_ds __user *, buf)
 			success_return = 0;
 		}
 		err = -EACCES;
-		if (ipcperms(&msq->q_perm, S_IRUGO))
+		if (ipcperms(ns, &msq->q_perm, S_IRUGO))
 			goto out_unlock;
 
 		err = security_msg_queue_msgctl(msq, cmd);
@@ -664,7 +664,7 @@ long do_msgsnd(int msqid, long mtype, void __user *mtext,
 		struct msg_sender s;
 
 		err = -EACCES;
-		if (ipcperms(&msq->q_perm, S_IWUGO))
+		if (ipcperms(ns, &msq->q_perm, S_IWUGO))
 			goto out_unlock_free;
 
 		err = security_msg_queue_msgsnd(msq, msg, msgflg);
@@ -774,7 +774,7 @@ long do_msgrcv(int msqid, long *pmtype, void __user *mtext,
 		struct list_head *tmp;
 
 		msg = ERR_PTR(-EACCES);
-		if (ipcperms(&msq->q_perm, S_IRUGO))
+		if (ipcperms(ns, &msq->q_perm, S_IRUGO))
 			goto out_unlock;
 
 		msg = ERR_PTR(-EAGAIN);
diff --git a/ipc/namespace.c b/ipc/namespace.c
index aa18899..3c3e522 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -15,7 +15,8 @@
 
 #include "util.h"
 
-static struct ipc_namespace *create_ipc_ns(struct ipc_namespace *old_ns)
+static struct ipc_namespace *create_ipc_ns(struct task_struct *tsk,
+					   struct ipc_namespace *old_ns)
 {
 	struct ipc_namespace *ns;
 	int err;
@@ -44,17 +45,19 @@ static struct ipc_namespace *create_ipc_ns(struct ipc_namespace *old_ns)
 	ipcns_notify(IPCNS_CREATED);
 	register_ipcns_notifier(ns);
 
-	ns->user_ns = old_ns->user_ns;
-	get_user_ns(ns->user_ns);
+	ns->user_ns = get_user_ns(task_cred_xxx(tsk, user)->user_ns);
 
 	return ns;
 }
 
-struct ipc_namespace *copy_ipcs(unsigned long flags, struct ipc_namespace *ns)
+struct ipc_namespace *copy_ipcs(unsigned long flags,
+				struct task_struct *tsk)
 {
+	struct ipc_namespace *ns = tsk->nsproxy->ipc_ns;
+
 	if (!(flags & CLONE_NEWIPC))
 		return get_ipc_ns(ns);
-	return create_ipc_ns(ns);
+	return create_ipc_ns(tsk, ns);
 }
 
 /*
diff --git a/ipc/sem.c b/ipc/sem.c
index 0e0d49b..34540f1 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -817,7 +817,7 @@ static int semctl_nolock(struct ipc_namespace *ns, int semid,
 		}
 
 		err = -EACCES;
-		if (ipcperms (&sma->sem_perm, S_IRUGO))
+		if (ipcperms (ns, &sma->sem_perm, S_IRUGO))
 			goto out_unlock;
 
 		err = security_sem_semctl(sma, cmd);
@@ -862,7 +862,7 @@ static int semctl_main(struct ipc_namespace *ns, int semid, int semnum,
 	nsems = sma->sem_nsems;
 
 	err = -EACCES;
-	if (ipcperms (&sma->sem_perm, (cmd==SETVAL||cmd==SETALL)?S_IWUGO:S_IRUGO))
+	if (ipcperms (ns, &sma->sem_perm, (cmd==SETVAL||cmd==SETALL)?S_IWUGO:S_IRUGO))
 		goto out_unlock;
 
 	err = security_sem_semctl(sma, cmd);
@@ -1047,7 +1047,8 @@ static int semctl_down(struct ipc_namespace *ns, int semid,
 			return -EFAULT;
 	}
 
-	ipcp = ipcctl_pre_down(&sem_ids(ns), semid, cmd, &semid64.sem_perm, 0);
+	ipcp = ipcctl_pre_down(ns, &sem_ids(ns), semid, cmd,
+			       &semid64.sem_perm, 0);
 	if (IS_ERR(ipcp))
 		return PTR_ERR(ipcp);
 
@@ -1386,7 +1387,7 @@ SYSCALL_DEFINE4(semtimedop, int, semid, struct sembuf __user *, tsops,
 		goto out_unlock_free;
 
 	error = -EACCES;
-	if (ipcperms(&sma->sem_perm, alter ? S_IWUGO : S_IRUGO))
+	if (ipcperms(ns, &sma->sem_perm, alter ? S_IWUGO : S_IRUGO))
 		goto out_unlock_free;
 
 	error = security_sem_semop(sma, sops, nsops, alter);
diff --git a/ipc/shm.c b/ipc/shm.c
index 7d3bb22..36369e0 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -623,7 +623,8 @@ static int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
 			return -EFAULT;
 	}
 
-	ipcp = ipcctl_pre_down(&shm_ids(ns), shmid, cmd, &shmid64.shm_perm, 0);
+	ipcp = ipcctl_pre_down(ns, &shm_ids(ns), shmid, cmd,
+			       &shmid64.shm_perm, 0);
 	if (IS_ERR(ipcp))
 		return PTR_ERR(ipcp);
 
@@ -737,7 +738,7 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int, cmd, struct shmid_ds __user *, buf)
 			result = 0;
 		}
 		err = -EACCES;
-		if (ipcperms (&shp->shm_perm, S_IRUGO))
+		if (ipcperms (ns, &shp->shm_perm, S_IRUGO))
 			goto out_unlock;
 		err = security_shm_shmctl(shp, cmd);
 		if (err)
@@ -773,7 +774,7 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int, cmd, struct shmid_ds __user *, buf)
 
 		audit_ipc_obj(&(shp->shm_perm));
 
-		if (!capable(CAP_IPC_LOCK)) {
+		if (!ns_capable(ns->user_ns, CAP_IPC_LOCK)) {
 			uid_t euid = current_euid();
 			err = -EPERM;
 			if (euid != shp->shm_perm.uid &&
@@ -888,7 +889,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
 	}
 
 	err = -EACCES;
-	if (ipcperms(&shp->shm_perm, acc_mode))
+	if (ipcperms(ns, &shp->shm_perm, acc_mode))
 		goto out_unlock;
 
 	err = security_shm_shmat(shp, shmaddr, shmflg);
diff --git a/ipc/util.c b/ipc/util.c
index 69a0cc1..267bb35 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -329,12 +329,14 @@ retry:
  *
  *	It is called with ipc_ids.rw_mutex and ipcp->lock held.
  */
-static int ipc_check_perms(struct kern_ipc_perm *ipcp, struct ipc_ops *ops,
-			struct ipc_params *params)
+static int ipc_check_perms(struct ipc_namespace *ns,
+			   struct kern_ipc_perm *ipcp,
+			   struct ipc_ops *ops,
+			   struct ipc_params *params)
 {
 	int err;
 
-	if (ipcperms(ipcp, params->flg))
+	if (ipcperms(ns, ipcp, params->flg))
 		err = -EACCES;
 	else {
 		err = ops->associate(ipcp, params->flg);
@@ -396,7 +398,7 @@ retry:
 				 * ipc_check_perms returns the IPC id on
 				 * success
 				 */
-				err = ipc_check_perms(ipcp, ops, params);
+				err = ipc_check_perms(ns, ipcp, ops, params);
 		}
 		ipc_unlock(ipcp);
 	}
@@ -612,7 +614,7 @@ void ipc_rcu_putref(void *ptr)
  *	to ipc resources. return 0 if allowed
  */
  
-int ipcperms (struct kern_ipc_perm *ipcp, short flag)
+int ipcperms (struct ipc_namespace *ns, struct kern_ipc_perm *ipcp, short flag)
 {	/* flag will most probably be 0 or S_...UGO from <linux/stat.h> */
 	uid_t euid = current_euid();
 	int requested_mode, granted_mode;
@@ -627,7 +629,7 @@ int ipcperms (struct kern_ipc_perm *ipcp, short flag)
 		granted_mode >>= 3;
 	/* is there some bit set in requested_mode but not in granted_mode? */
 	if ((requested_mode & ~granted_mode & 0007) && 
-	    !capable(CAP_IPC_OWNER))
+	    !ns_capable(ns->user_ns, CAP_IPC_OWNER))
 		return -1;
 
 	return security_ipc_permission(ipcp, flag);
@@ -765,6 +767,7 @@ void ipc_update_perm(struct ipc64_perm *in, struct kern_ipc_perm *out)
 
 /**
  * ipcctl_pre_down - retrieve an ipc and check permissions for some IPC_XXX cmd
+ * @ids:  the ipc namespace
  * @ids:  the table of ids where to look for the ipc
  * @id:   the id of the ipc to retrieve
  * @cmd:  the cmd to check
@@ -779,7 +782,8 @@ void ipc_update_perm(struct ipc64_perm *in, struct kern_ipc_perm *out)
  *  - returns the ipc with both ipc and rw_mutex locks held in case of success
  *    or an err-code without any lock held otherwise.
  */
-struct kern_ipc_perm *ipcctl_pre_down(struct ipc_ids *ids, int id, int cmd,
+struct kern_ipc_perm *ipcctl_pre_down(struct ipc_namespace *ns,
+				      struct ipc_ids *ids, int id, int cmd,
 				      struct ipc64_perm *perm, int extra_perm)
 {
 	struct kern_ipc_perm *ipcp;
@@ -799,8 +803,8 @@ struct kern_ipc_perm *ipcctl_pre_down(struct ipc_ids *ids, int id, int cmd,
 					 perm->gid, perm->mode);
 
 	euid = current_euid();
-	if (euid == ipcp->cuid ||
-	    euid == ipcp->uid  || capable(CAP_SYS_ADMIN))
+	if (euid == ipcp->cuid || euid == ipcp->uid  ||
+	    ns_capable(ns->user_ns, CAP_SYS_ADMIN))
 		return ipcp;
 
 	err = -EPERM;
diff --git a/ipc/util.h b/ipc/util.h
index 764b51a..6f5c20b 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -103,7 +103,7 @@ int ipc_get_maxid(struct ipc_ids *);
 void ipc_rmid(struct ipc_ids *, struct kern_ipc_perm *);
 
 /* must be called with ipcp locked */
-int ipcperms(struct kern_ipc_perm *ipcp, short flg);
+int ipcperms(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp, short flg);
 
 /* for rare, potentially huge allocations.
  * both function can sleep
@@ -126,7 +126,8 @@ struct kern_ipc_perm *ipc_lock(struct ipc_ids *, int);
 void kernel_to_ipc64_perm(struct kern_ipc_perm *in, struct ipc64_perm *out);
 void ipc64_perm_to_ipc_perm(struct ipc64_perm *in, struct ipc_perm *out);
 void ipc_update_perm(struct ipc64_perm *in, struct kern_ipc_perm *out);
-struct kern_ipc_perm *ipcctl_pre_down(struct ipc_ids *ids, int id, int cmd,
+struct kern_ipc_perm *ipcctl_pre_down(struct ipc_namespace *ns,
+				      struct ipc_ids *ids, int id, int cmd,
 				      struct ipc64_perm *perm, int extra_perm);
 
 #ifndef __ARCH_WANT_IPC_PARSE_VERSION
diff --git a/kernel/futex.c b/kernel/futex.c
index b766d28..1e876f1 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -2421,10 +2421,19 @@ SYSCALL_DEFINE3(get_robust_list, int, pid,
 			goto err_unlock;
 		ret = -EPERM;
 		pcred = __task_cred(p);
+		/* If victim is in different user_ns, then uids are not
+		   comparable, so we must have CAP_SYS_PTRACE */
+		if (cred->user->user_ns != pcred->user->user_ns) {
+			if (!ns_capable(pcred->user->user_ns, CAP_SYS_PTRACE))
+				goto err_unlock;
+			goto ok;
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
index a7934ac..5f9e689 100644
--- a/kernel/futex_compat.c
+++ b/kernel/futex_compat.c
@@ -153,10 +153,19 @@ compat_sys_get_robust_list(int pid, compat_uptr_t __user *head_ptr,
 			goto err_unlock;
 		ret = -EPERM;
 		pcred = __task_cred(p);
+		/* If victim is in different user_ns, then uids are not
+		   comparable, so we must have CAP_SYS_PTRACE */
+		if (cred->user->user_ns != pcred->user->user_ns) {
+			if (!ns_capable(pcred->user->user_ns, CAP_SYS_PTRACE))
+				goto err_unlock;
+			goto ok;
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
index 253dc0f..1cc476d 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -233,7 +233,7 @@ SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)
 	struct group_info *group_info;
 	int retval;
 
-	if (!capable(CAP_SETGID))
+	if (!nsown_capable(CAP_SETGID))
 		return -EPERM;
 	if ((unsigned)gidsetsize > NGROUPS_MAX)
 		return -EINVAL;
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index ac8a56e..a05d191 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -75,16 +75,11 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		goto out_uts;
 	}
 
-	new_nsp->ipc_ns = copy_ipcs(flags, tsk->nsproxy->ipc_ns);
+	new_nsp->ipc_ns = copy_ipcs(flags, tsk);
 	if (IS_ERR(new_nsp->ipc_ns)) {
 		err = PTR_ERR(new_nsp->ipc_ns);
 		goto out_ipc;
 	}
-	if (new_nsp->ipc_ns != tsk->nsproxy->ipc_ns) {
-		put_user_ns(new_nsp->ipc_ns->user_ns);
-		new_nsp->ipc_ns->user_ns = task_cred_xxx(tsk, user)->user_ns;
-		get_user_ns(new_nsp->ipc_ns->user_ns);
-	}
 
 	new_nsp->pid_ns = copy_pid_ns(flags, task_active_pid_ns(tsk));
 	if (IS_ERR(new_nsp->pid_ns)) {
diff --git a/kernel/sched.c b/kernel/sched.c
index 18d38e4..dc12bc2 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -4761,8 +4761,11 @@ static bool check_same_owner(struct task_struct *p)
 
 	rcu_read_lock();
 	pcred = __task_cred(p);
-	match = (cred->euid == pcred->euid ||
-		 cred->euid == pcred->uid);
+	if (cred->user->user_ns == pcred->user->user_ns)
+		match = (cred->euid == pcred->euid ||
+			 cred->euid == pcred->uid);
+	else
+		match = false;
 	rcu_read_unlock();
 	return match;
 }
@@ -5088,7 +5091,7 @@ long sched_setaffinity(pid_t pid, const struct cpumask *in_mask)
 		goto out_free_cpus_allowed;
 	}
 	retval = -EPERM;
-	if (!check_same_owner(p) && !capable(CAP_SYS_NICE))
+	if (!check_same_owner(p) && !task_ns_capable(p, CAP_SYS_NICE))
 		goto out_unlock;
 
 	retval = security_task_setscheduler(p);
diff --git a/kernel/uid16.c b/kernel/uid16.c
index 4192098..51c6e89 100644
--- a/kernel/uid16.c
+++ b/kernel/uid16.c
@@ -189,7 +189,7 @@ SYSCALL_DEFINE2(setgroups16, int, gidsetsize, old_gid_t __user *, grouplist)
 	struct group_info *group_info;
 	int retval;
 
-	if (!capable(CAP_SETGID))
+	if (!nsown_capable(CAP_SETGID))
 		return -EPERM;
 	if ((unsigned)gidsetsize > NGROUPS_MAX)
 		return -EINVAL;
-- 
1.7.0.4
