From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 6/9] user namespaces: convert all capable checks in
	kernel/sys.c
Date: Thu, 17 Feb 2011 15:03:42 +0000
Message-ID: <20110217150342.GF26395__2541.36266089535$1297956046$gmane$org@mail.hallyn.com>
References: <20110217150224.GA26334@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110217150224.GA26334-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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

This allows setuid/setgid in containers.  It also fixes some
corner cases where kernel logic foregoes capability checks when
uids are equivalent.  The latter will need to be done throughout
the whole kernel.

Changelog:
	Jan 11: Use nsown_capable() as suggested by Bastian Blank.
	Jan 11: Fix logic errors in uid checks pointed out by Bastian.
	Feb 15: allow prlimit to current (was regression in previous version)

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 kernel/sys.c |   74 ++++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 47 insertions(+), 27 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index 7a1bbad..075370d 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -118,17 +118,29 @@ EXPORT_SYMBOL(cad_pid);
 
 void (*pm_power_off_prepare)(void);
 
+/* called with rcu_read_lock, creds are safe */
+static inline int set_one_prio_perm(struct task_struct *p)
+{
+	const struct cred *cred = current_cred(), *pcred = __task_cred(p);
+
+	if (pcred->user->user_ns == cred->user->user_ns &&
+	    (pcred->uid  == cred->euid ||
+	     pcred->euid == cred->euid))
+		return 1;
+	if (ns_capable(pcred->user->user_ns, CAP_SYS_NICE))
+		return 1;
+	return 0;
+}
+
 /*
  * set the priority of a task
  * - the caller must hold the RCU read lock
  */
 static int set_one_prio(struct task_struct *p, int niceval, int error)
 {
-	const struct cred *cred = current_cred(), *pcred = __task_cred(p);
 	int no_nice;
 
-	if (pcred->uid  != cred->euid &&
-	    pcred->euid != cred->euid && !capable(CAP_SYS_NICE)) {
+	if (!set_one_prio_perm(p)) {
 		error = -EPERM;
 		goto out;
 	}
@@ -502,7 +514,7 @@ SYSCALL_DEFINE2(setregid, gid_t, rgid, gid_t, egid)
 	if (rgid != (gid_t) -1) {
 		if (old->gid == rgid ||
 		    old->egid == rgid ||
-		    capable(CAP_SETGID))
+		    nsown_capable(CAP_SETGID))
 			new->gid = rgid;
 		else
 			goto error;
@@ -511,7 +523,7 @@ SYSCALL_DEFINE2(setregid, gid_t, rgid, gid_t, egid)
 		if (old->gid == egid ||
 		    old->egid == egid ||
 		    old->sgid == egid ||
-		    capable(CAP_SETGID))
+		    nsown_capable(CAP_SETGID))
 			new->egid = egid;
 		else
 			goto error;
@@ -546,7 +558,7 @@ SYSCALL_DEFINE1(setgid, gid_t, gid)
 	old = current_cred();
 
 	retval = -EPERM;
-	if (capable(CAP_SETGID))
+	if (nsown_capable(CAP_SETGID))
 		new->gid = new->egid = new->sgid = new->fsgid = gid;
 	else if (gid == old->gid || gid == old->sgid)
 		new->egid = new->fsgid = gid;
@@ -613,7 +625,7 @@ SYSCALL_DEFINE2(setreuid, uid_t, ruid, uid_t, euid)
 		new->uid = ruid;
 		if (old->uid != ruid &&
 		    old->euid != ruid &&
-		    !capable(CAP_SETUID))
+		    !nsown_capable(CAP_SETUID))
 			goto error;
 	}
 
@@ -622,7 +634,7 @@ SYSCALL_DEFINE2(setreuid, uid_t, ruid, uid_t, euid)
 		if (old->uid != euid &&
 		    old->euid != euid &&
 		    old->suid != euid &&
-		    !capable(CAP_SETUID))
+		    !nsown_capable(CAP_SETUID))
 			goto error;
 	}
 
@@ -670,7 +682,7 @@ SYSCALL_DEFINE1(setuid, uid_t, uid)
 	old = current_cred();
 
 	retval = -EPERM;
-	if (capable(CAP_SETUID)) {
+	if (nsown_capable(CAP_SETUID)) {
 		new->suid = new->uid = uid;
 		if (uid != old->uid) {
 			retval = set_user(new);
@@ -712,7 +724,7 @@ SYSCALL_DEFINE3(setresuid, uid_t, ruid, uid_t, euid, uid_t, suid)
 	old = current_cred();
 
 	retval = -EPERM;
-	if (!capable(CAP_SETUID)) {
+	if (!nsown_capable(CAP_SETUID)) {
 		if (ruid != (uid_t) -1 && ruid != old->uid &&
 		    ruid != old->euid  && ruid != old->suid)
 			goto error;
@@ -776,7 +788,7 @@ SYSCALL_DEFINE3(setresgid, gid_t, rgid, gid_t, egid, gid_t, sgid)
 	old = current_cred();
 
 	retval = -EPERM;
-	if (!capable(CAP_SETGID)) {
+	if (!nsown_capable(CAP_SETGID)) {
 		if (rgid != (gid_t) -1 && rgid != old->gid &&
 		    rgid != old->egid  && rgid != old->sgid)
 			goto error;
@@ -836,7 +848,7 @@ SYSCALL_DEFINE1(setfsuid, uid_t, uid)
 
 	if (uid == old->uid  || uid == old->euid  ||
 	    uid == old->suid || uid == old->fsuid ||
-	    capable(CAP_SETUID)) {
+	    nsown_capable(CAP_SETUID)) {
 		if (uid != old_fsuid) {
 			new->fsuid = uid;
 			if (security_task_fix_setuid(new, old, LSM_SETID_FS) == 0)
@@ -869,7 +881,7 @@ SYSCALL_DEFINE1(setfsgid, gid_t, gid)
 
 	if (gid == old->gid  || gid == old->egid  ||
 	    gid == old->sgid || gid == old->fsgid ||
-	    capable(CAP_SETGID)) {
+	    nsown_capable(CAP_SETGID)) {
 		if (gid != old_fsgid) {
 			new->fsgid = gid;
 			goto change_okay;
@@ -1177,8 +1189,11 @@ SYSCALL_DEFINE2(sethostname, char __user *, name, int, len)
 	int errno;
 	char tmp[__NEW_UTS_LEN];
 
-	if (!ns_capable(current->nsproxy->uts_ns->user_ns, CAP_SYS_ADMIN))
+	if (!ns_capable(current->nsproxy->uts_ns->user_ns, CAP_SYS_ADMIN)) {
+		printk(KERN_NOTICE "%s: did not have CAP_SYS_ADMIN\n", __func__);
 		return -EPERM;
+	}
+	printk(KERN_NOTICE "%s: did have CAP_SYS_ADMIN\n", __func__);
 	if (len < 0 || len > __NEW_UTS_LEN)
 		return -EINVAL;
 	down_write(&uts_sem);
@@ -1226,7 +1241,7 @@ SYSCALL_DEFINE2(setdomainname, char __user *, name, int, len)
 	int errno;
 	char tmp[__NEW_UTS_LEN];
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!ns_capable(current->nsproxy->uts_ns->user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
 	if (len < 0 || len > __NEW_UTS_LEN)
 		return -EINVAL;
@@ -1341,6 +1356,8 @@ int do_prlimit(struct task_struct *tsk, unsigned int resource,
 	rlim = tsk->signal->rlim + resource;
 	task_lock(tsk->group_leader);
 	if (new_rlim) {
+		/* Keep the capable check against init_user_ns until
+		   cgroups can contain all limits */
 		if (new_rlim->rlim_max > rlim->rlim_max &&
 				!capable(CAP_SYS_RESOURCE))
 			retval = -EPERM;
@@ -1384,19 +1401,22 @@ static int check_prlimit_permission(struct task_struct *task)
 {
 	const struct cred *cred = current_cred(), *tcred;
 
-	tcred = __task_cred(task);
-	if (current != task &&
-	    (cred->uid != tcred->euid ||
-	     cred->uid != tcred->suid ||
-	     cred->uid != tcred->uid  ||
-	     cred->gid != tcred->egid ||
-	     cred->gid != tcred->sgid ||
-	     cred->gid != tcred->gid) &&
-	     !capable(CAP_SYS_RESOURCE)) {
-		return -EPERM;
-	}
+	if (current == task)
+		return 0;
 
-	return 0;
+	tcred = __task_cred(task);
+	if (cred->user->user_ns == tcred->user->user_ns &&
+	    (cred->uid == tcred->euid &&
+	     cred->uid == tcred->suid &&
+	     cred->uid == tcred->uid  &&
+	     cred->gid == tcred->egid &&
+	     cred->gid == tcred->sgid &&
+	     cred->gid == tcred->gid))
+		return 0;
+	if (ns_capable(tcred->user->user_ns, CAP_SYS_RESOURCE))
+		return 0;
+
+	return -EPERM;
 }
 
 SYSCALL_DEFINE4(prlimit64, pid_t, pid, unsigned int, resource,
-- 
1.7.0.4
