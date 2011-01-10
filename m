From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 6/7] user namespaces: convert all capable checks in
	kernel/sys.c
Date: Mon, 10 Jan 2011 21:14:07 +0000
Message-ID: <20110110211406.GF22564__41230.9553394609$1294694171$gmane$org@mail.hallyn.com>
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

This allows setuid/setgid in containers.  It also fixes some
corner cases where kernel logic foregoes capability checks when
uids are equivalent.  The latter will need to be done throughout
the whole kernel.

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 kernel/sys.c |   35 ++++++++++++++++++++---------------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index 9b9b03b..2278e87 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -125,8 +125,10 @@ static int set_one_prio(struct task_struct *p, int niceval, int error)
 	const struct cred *cred = current_cred(), *pcred = __task_cred(p);
 	int no_nice;
 
-	if (pcred->uid  != cred->euid &&
-	    pcred->euid != cred->euid && !capable(CAP_SYS_NICE)) {
+	if (pcred->user->user_ns != cred->user->user_ns &&
+	    pcred->uid  != cred->euid &&
+	    pcred->euid != cred->euid &&
+	    !ns_capable(pcred->user->user_ns, CAP_SYS_NICE)) {
 		error = -EPERM;
 		goto out;
 	}
@@ -496,7 +498,7 @@ SYSCALL_DEFINE2(setregid, gid_t, rgid, gid_t, egid)
 	if (rgid != (gid_t) -1) {
 		if (old->gid == rgid ||
 		    old->egid == rgid ||
-		    capable(CAP_SETGID))
+		    ns_capable(current_user_ns(), CAP_SETGID))
 			new->gid = rgid;
 		else
 			goto error;
@@ -505,7 +507,7 @@ SYSCALL_DEFINE2(setregid, gid_t, rgid, gid_t, egid)
 		if (old->gid == egid ||
 		    old->egid == egid ||
 		    old->sgid == egid ||
-		    capable(CAP_SETGID))
+		    ns_capable(current_user_ns(), CAP_SETGID))
 			new->egid = egid;
 		else
 			goto error;
@@ -540,7 +542,7 @@ SYSCALL_DEFINE1(setgid, gid_t, gid)
 	old = current_cred();
 
 	retval = -EPERM;
-	if (capable(CAP_SETGID))
+	if (ns_capable(current_user_ns(), CAP_SETGID))
 		new->gid = new->egid = new->sgid = new->fsgid = gid;
 	else if (gid == old->gid || gid == old->sgid)
 		new->egid = new->fsgid = gid;
@@ -607,7 +609,7 @@ SYSCALL_DEFINE2(setreuid, uid_t, ruid, uid_t, euid)
 		new->uid = ruid;
 		if (old->uid != ruid &&
 		    old->euid != ruid &&
-		    !capable(CAP_SETUID))
+		    !ns_capable(current_user_ns(), CAP_SETUID))
 			goto error;
 	}
 
@@ -616,7 +618,7 @@ SYSCALL_DEFINE2(setreuid, uid_t, ruid, uid_t, euid)
 		if (old->uid != euid &&
 		    old->euid != euid &&
 		    old->suid != euid &&
-		    !capable(CAP_SETUID))
+		    !ns_capable(current_user_ns(), CAP_SETUID))
 			goto error;
 	}
 
@@ -664,7 +666,7 @@ SYSCALL_DEFINE1(setuid, uid_t, uid)
 	old = current_cred();
 
 	retval = -EPERM;
-	if (capable(CAP_SETUID)) {
+	if (ns_capable(current_user_ns(), CAP_SETUID)) {
 		new->suid = new->uid = uid;
 		if (uid != old->uid) {
 			retval = set_user(new);
@@ -706,7 +708,7 @@ SYSCALL_DEFINE3(setresuid, uid_t, ruid, uid_t, euid, uid_t, suid)
 	old = current_cred();
 
 	retval = -EPERM;
-	if (!capable(CAP_SETUID)) {
+	if (!ns_capable(current_user_ns(), CAP_SETUID)) {
 		if (ruid != (uid_t) -1 && ruid != old->uid &&
 		    ruid != old->euid  && ruid != old->suid)
 			goto error;
@@ -770,7 +772,7 @@ SYSCALL_DEFINE3(setresgid, gid_t, rgid, gid_t, egid, gid_t, sgid)
 	old = current_cred();
 
 	retval = -EPERM;
-	if (!capable(CAP_SETGID)) {
+	if (!ns_capable(current_user_ns(), CAP_SETGID)) {
 		if (rgid != (gid_t) -1 && rgid != old->gid &&
 		    rgid != old->egid  && rgid != old->sgid)
 			goto error;
@@ -830,7 +832,7 @@ SYSCALL_DEFINE1(setfsuid, uid_t, uid)
 
 	if (uid == old->uid  || uid == old->euid  ||
 	    uid == old->suid || uid == old->fsuid ||
-	    capable(CAP_SETUID)) {
+	    ns_capable(current_user_ns(), CAP_SETUID)) {
 		if (uid != old_fsuid) {
 			new->fsuid = uid;
 			if (security_task_fix_setuid(new, old, LSM_SETID_FS) == 0)
@@ -863,7 +865,7 @@ SYSCALL_DEFINE1(setfsgid, gid_t, gid)
 
 	if (gid == old->gid  || gid == old->egid  ||
 	    gid == old->sgid || gid == old->fsgid ||
-	    capable(CAP_SETGID)) {
+	    ns_capable(current_user_ns(), CAP_SETGID)) {
 		if (gid != old_fsgid) {
 			new->fsgid = gid;
 			goto change_okay;
@@ -1220,7 +1222,7 @@ SYSCALL_DEFINE2(setdomainname, char __user *, name, int, len)
 	int errno;
 	char tmp[__NEW_UTS_LEN];
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!ns_capable(current->nsproxy->uts_ns->user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
 	if (len < 0 || len > __NEW_UTS_LEN)
 		return -EINVAL;
@@ -1335,6 +1337,8 @@ int do_prlimit(struct task_struct *tsk, unsigned int resource,
 	rlim = tsk->signal->rlim + resource;
 	task_lock(tsk->group_leader);
 	if (new_rlim) {
+		/* Keep the capable check against init_user_ns until
+		   cgroups can contain all limits */
 		if (new_rlim->rlim_max > rlim->rlim_max &&
 				!capable(CAP_SYS_RESOURCE))
 			retval = -EPERM;
@@ -1379,13 +1383,14 @@ static int check_prlimit_permission(struct task_struct *task)
 	const struct cred *cred = current_cred(), *tcred;
 
 	tcred = __task_cred(task);
-	if ((cred->uid != tcred->euid ||
+	if ((cred->user->user_ns != tcred->user->user_ns ||
+	     cred->uid != tcred->euid ||
 	     cred->uid != tcred->suid ||
 	     cred->uid != tcred->uid  ||
 	     cred->gid != tcred->egid ||
 	     cred->gid != tcred->sgid ||
 	     cred->gid != tcred->gid) &&
-	     !capable(CAP_SYS_RESOURCE)) {
+	     !ns_capable(tcred->user->user_ns, CAP_SYS_RESOURCE)) {
 		return -EPERM;
 	}
 
-- 
1.7.0.4
