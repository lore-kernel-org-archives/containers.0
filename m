From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 014/100] c/r: split core function out of some set*{u,
	g}id functions
Date: Sat,  1 May 2010 10:14:56 -0400
Message-ID: <1272723382-19470-15-git-send-email-orenl__42517.8896905438$1272728559$gmane$org@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

When restarting tasks, we want to be able to change xuid and
xgid in a struct cred, and do so with security checks.  Break
the core functionality of set{fs,res}{u,g}id into cred_setX
which performs the access checks based on current_cred(),
but performs the requested change on a passed-in cred.

This will allow us to securely construct struct creds based
on a checkpoint image, constrained by the caller's permissions,
and apply them to the caller at the end of sys_restart().

Changelog [v21]:
  - Address dhowells feedback

Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 Documentation/credentials.txt |   14 ++++
 include/linux/cred.h          |    8 +++
 kernel/cred.c                 |  114 ++++++++++++++++++++++++++++++++++
 kernel/sys.c                  |  134 +++++++----------------------------------
 4 files changed, 157 insertions(+), 113 deletions(-)

diff --git a/Documentation/credentials.txt b/Documentation/credentials.txt
index df03169..55dd589 100644
--- a/Documentation/credentials.txt
+++ b/Documentation/credentials.txt
@@ -530,6 +530,20 @@ A typical credentials alteration function would look something like this:
 	}
 
 
+SETUID/SETGID HELPERS
+---------------------
+
+Helpers exist to perform the core of uid and gid alterations:
+
+cred_setresuid(struct cred *new, uid_t ruid, uid_t euid, uid_t suid);
+cred_setresgid(struct cred *new, gid_t rgid, gid_t egid, gid_t sgid);
+cred_setfsuid(struct cred *new, uid_t uid, uid_t *old_fsuid);
+cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid);
+
+These helpers are used in kernel/sys.c for the analogous syscalls.
+As can be seen in those examples, these helpers are to be wrapped
+between calls to prepare_creds() and commit_creds() or abort_creds().
+
 MANAGING CREDENTIALS
 --------------------
 
diff --git a/include/linux/cred.h b/include/linux/cred.h
index 52507c3..8558bec 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -22,6 +22,9 @@ struct user_struct;
 struct cred;
 struct inode;
 
+/* defined in sys.c, used in cred_setresuid */
+extern int set_user(struct cred *new);
+
 /*
  * COW Supplementary groups list
  */
@@ -396,4 +399,9 @@ do {						\
 	*(_fsgid) = __cred->fsgid;		\
 } while(0)
 
+extern int cred_setresuid(struct cred *new, uid_t ruid, uid_t euid, uid_t suid);
+extern int cred_setresgid(struct cred *new, gid_t rgid, gid_t egid, gid_t sgid);
+extern int cred_setfsuid(struct cred *new, uid_t uid, uid_t *old_fsuid);
+extern int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid);
+
 #endif /* _LINUX_CRED_H */
diff --git a/kernel/cred.c b/kernel/cred.c
index e1dbe9e..fbd1750 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -895,3 +895,117 @@ void validate_creds_for_do_exit(struct task_struct *tsk)
 }
 
 #endif /* CONFIG_DEBUG_CREDENTIALS */
+
+int cred_setresuid(struct cred *new, uid_t ruid, uid_t euid, uid_t suid)
+{
+	int retval;
+	const struct cred *old;
+
+	retval = security_task_setuid(ruid, euid, suid, LSM_SETID_RES);
+	if (retval)
+		return retval;
+	old = current_cred();
+
+	if (!capable(CAP_SETUID)) {
+		if (ruid != (uid_t) -1 && ruid != old->uid &&
+		    ruid != old->euid  && ruid != old->suid)
+			return -EPERM;
+		if (euid != (uid_t) -1 && euid != old->uid &&
+		    euid != old->euid  && euid != old->suid)
+			return -EPERM;
+		if (suid != (uid_t) -1 && suid != old->uid &&
+		    suid != old->euid  && suid != old->suid)
+			return -EPERM;
+	}
+
+	if (ruid != (uid_t) -1) {
+		new->uid = ruid;
+		if (ruid != old->uid) {
+			retval = set_user(new);
+			if (retval < 0)
+				return retval;
+		}
+	}
+	if (euid != (uid_t) -1)
+		new->euid = euid;
+	if (suid != (uid_t) -1)
+		new->suid = suid;
+	new->fsuid = new->euid;
+
+	return security_task_fix_setuid(new, old, LSM_SETID_RES);
+}
+
+int cred_setresgid(struct cred *new, gid_t rgid, gid_t egid,
+			gid_t sgid)
+{
+	const struct cred *old = current_cred();
+	int retval;
+
+	retval = security_task_setgid(rgid, egid, sgid, LSM_SETID_RES);
+	if (retval)
+		return retval;
+
+	if (!capable(CAP_SETGID)) {
+		if (rgid != (gid_t) -1 && rgid != old->gid &&
+		    rgid != old->egid  && rgid != old->sgid)
+			return -EPERM;
+		if (egid != (gid_t) -1 && egid != old->gid &&
+		    egid != old->egid  && egid != old->sgid)
+			return -EPERM;
+		if (sgid != (gid_t) -1 && sgid != old->gid &&
+		    sgid != old->egid  && sgid != old->sgid)
+			return -EPERM;
+	}
+
+	if (rgid != (gid_t) -1)
+		new->gid = rgid;
+	if (egid != (gid_t) -1)
+		new->egid = egid;
+	if (sgid != (gid_t) -1)
+		new->sgid = sgid;
+	new->fsgid = new->egid;
+	return 0;
+}
+
+int cred_setfsuid(struct cred *new, uid_t uid, uid_t *old_fsuid)
+{
+	const struct cred *old;
+
+	old = current_cred();
+	*old_fsuid = old->fsuid;
+
+	if (security_task_setuid(uid, (uid_t)-1, (uid_t)-1, LSM_SETID_FS) < 0)
+		return -EPERM;
+
+	if (uid == old->uid  || uid == old->euid  ||
+	    uid == old->suid || uid == old->fsuid ||
+	    capable(CAP_SETUID)) {
+		if (uid != *old_fsuid) {
+			new->fsuid = uid;
+			if (security_task_fix_setuid(new, old, LSM_SETID_FS) == 0)
+				return 0;
+		}
+	}
+	return -EPERM;
+}
+
+int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid)
+{
+	const struct cred *old;
+
+	old = current_cred();
+	*old_fsgid = old->fsgid;
+
+	if (security_task_setgid(gid, (gid_t)-1, (gid_t)-1, LSM_SETID_FS))
+		return -EPERM;
+
+	if (gid == old->gid  || gid == old->egid  ||
+	    gid == old->sgid || gid == old->fsgid ||
+	    capable(CAP_SETGID)) {
+		if (gid != *old_fsgid) {
+			new->fsgid = gid;
+			return 0;
+		}
+	}
+	return -EPERM;
+}
diff --git a/kernel/sys.c b/kernel/sys.c
index 6d1a7e0..ec11a3f 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -565,11 +565,12 @@ error:
 /*
  * change the user struct in a credentials set to match the new UID
  */
-static int set_user(struct cred *new)
+int set_user(struct cred *new)
 {
 	struct user_struct *new_user;
 
-	new_user = alloc_uid(current_user_ns(), new->uid);
+	/* is this ok? */
+	new_user = alloc_uid(new->user->user_ns, new->uid);
 	if (!new_user)
 		return -EAGAIN;
 
@@ -704,14 +705,12 @@ error:
 	return retval;
 }
 
-
 /*
  * This function implements a generic ability to update ruid, euid,
  * and suid.  This allows you to implement the 4.4 compatible seteuid().
  */
 SYSCALL_DEFINE3(setresuid, uid_t, ruid, uid_t, euid, uid_t, suid)
 {
-	const struct cred *old;
 	struct cred *new;
 	int retval;
 
@@ -719,45 +718,10 @@ SYSCALL_DEFINE3(setresuid, uid_t, ruid, uid_t, euid, uid_t, suid)
 	if (!new)
 		return -ENOMEM;
 
-	retval = security_task_setuid(ruid, euid, suid, LSM_SETID_RES);
-	if (retval)
-		goto error;
-	old = current_cred();
-
-	retval = -EPERM;
-	if (!capable(CAP_SETUID)) {
-		if (ruid != (uid_t) -1 && ruid != old->uid &&
-		    ruid != old->euid  && ruid != old->suid)
-			goto error;
-		if (euid != (uid_t) -1 && euid != old->uid &&
-		    euid != old->euid  && euid != old->suid)
-			goto error;
-		if (suid != (uid_t) -1 && suid != old->uid &&
-		    suid != old->euid  && suid != old->suid)
-			goto error;
-	}
-
-	if (ruid != (uid_t) -1) {
-		new->uid = ruid;
-		if (ruid != old->uid) {
-			retval = set_user(new);
-			if (retval < 0)
-				goto error;
-		}
-	}
-	if (euid != (uid_t) -1)
-		new->euid = euid;
-	if (suid != (uid_t) -1)
-		new->suid = suid;
-	new->fsuid = new->euid;
-
-	retval = security_task_fix_setuid(new, old, LSM_SETID_RES);
-	if (retval < 0)
-		goto error;
-
-	return commit_creds(new);
+	retval = cred_setresuid(new, ruid, euid, suid);
+	if (retval == 0)
+		return commit_creds(new);
 
-error:
 	abort_creds(new);
 	return retval;
 }
@@ -779,43 +743,17 @@ SYSCALL_DEFINE3(getresuid, uid_t __user *, ruid, uid_t __user *, euid, uid_t __u
  */
 SYSCALL_DEFINE3(setresgid, gid_t, rgid, gid_t, egid, gid_t, sgid)
 {
-	const struct cred *old;
 	struct cred *new;
 	int retval;
 
 	new = prepare_creds();
 	if (!new)
 		return -ENOMEM;
-	old = current_cred();
 
-	retval = security_task_setgid(rgid, egid, sgid, LSM_SETID_RES);
-	if (retval)
-		goto error;
+	retval = cred_setresgid(new, rgid, egid, sgid);
+	if (retval == 0)
+		return commit_creds(new);
 
-	retval = -EPERM;
-	if (!capable(CAP_SETGID)) {
-		if (rgid != (gid_t) -1 && rgid != old->gid &&
-		    rgid != old->egid  && rgid != old->sgid)
-			goto error;
-		if (egid != (gid_t) -1 && egid != old->gid &&
-		    egid != old->egid  && egid != old->sgid)
-			goto error;
-		if (sgid != (gid_t) -1 && sgid != old->gid &&
-		    sgid != old->egid  && sgid != old->sgid)
-			goto error;
-	}
-
-	if (rgid != (gid_t) -1)
-		new->gid = rgid;
-	if (egid != (gid_t) -1)
-		new->egid = egid;
-	if (sgid != (gid_t) -1)
-		new->sgid = sgid;
-	new->fsgid = new->egid;
-
-	return commit_creds(new);
-
-error:
 	abort_creds(new);
 	return retval;
 }
@@ -832,7 +770,6 @@ SYSCALL_DEFINE3(getresgid, gid_t __user *, rgid, gid_t __user *, egid, gid_t __u
 	return retval;
 }
 
-
 /*
  * "setfsuid()" sets the fsuid - the uid used for filesystem checks. This
  * is used for "access()" and for the NFS daemon (letting nfsd stay at
@@ -841,35 +778,20 @@ SYSCALL_DEFINE3(getresgid, gid_t __user *, rgid, gid_t __user *, egid, gid_t __u
  */
 SYSCALL_DEFINE1(setfsuid, uid_t, uid)
 {
-	const struct cred *old;
 	struct cred *new;
 	uid_t old_fsuid;
+	int retval;
 
 	new = prepare_creds();
 	if (!new)
 		return current_fsuid();
-	old = current_cred();
-	old_fsuid = old->fsuid;
-
-	if (security_task_setuid(uid, (uid_t)-1, (uid_t)-1, LSM_SETID_FS) < 0)
-		goto error;
-
-	if (uid == old->uid  || uid == old->euid  ||
-	    uid == old->suid || uid == old->fsuid ||
-	    capable(CAP_SETUID)) {
-		if (uid != old_fsuid) {
-			new->fsuid = uid;
-			if (security_task_fix_setuid(new, old, LSM_SETID_FS) == 0)
-				goto change_okay;
-		}
-	}
 
-error:
-	abort_creds(new);
-	return old_fsuid;
+	retval = cred_setfsuid(new, uid, &old_fsuid);
+	if (retval == 0)
+		commit_creds(new);
+	else
+		abort_creds(new);
 
-change_okay:
-	commit_creds(new);
 	return old_fsuid;
 }
 
@@ -878,34 +800,20 @@ change_okay:
  */
 SYSCALL_DEFINE1(setfsgid, gid_t, gid)
 {
-	const struct cred *old;
 	struct cred *new;
 	gid_t old_fsgid;
+	int retval;
 
 	new = prepare_creds();
 	if (!new)
 		return current_fsgid();
-	old = current_cred();
-	old_fsgid = old->fsgid;
-
-	if (security_task_setgid(gid, (gid_t)-1, (gid_t)-1, LSM_SETID_FS))
-		goto error;
-
-	if (gid == old->gid  || gid == old->egid  ||
-	    gid == old->sgid || gid == old->fsgid ||
-	    capable(CAP_SETGID)) {
-		if (gid != old_fsgid) {
-			new->fsgid = gid;
-			goto change_okay;
-		}
-	}
 
-error:
-	abort_creds(new);
-	return old_fsgid;
+	retval = cred_setfsgid(new, gid, &old_fsgid);
+	if (retval == 0)
+		commit_creds(new);
+	else
+		abort_creds(new);
 
-change_okay:
-	commit_creds(new);
 	return old_fsgid;
 }
 
-- 
1.6.3.3
