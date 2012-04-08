From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 24/43] userns: Convert ptrace, kill,
	set_priority permission checks to work with kuids and kgids
Date: Sat,  7 Apr 2012 22:15:20 -0700
Message-ID: <1333862139-31737-24-git-send-email-ebiederm@xmission.com>
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

Update the permission checks to use the new uid_eq and gid_eq helpers
and remove the now unnecessary user_ns equality comparison.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/ptrace.c |   13 ++++++-------
 kernel/signal.c |   15 ++++++---------
 kernel/sys.c    |   18 ++++++++----------
 3 files changed, 20 insertions(+), 26 deletions(-)

diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 24e0a5a..a232bb5 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -198,13 +198,12 @@ int __ptrace_may_access(struct task_struct *task, unsigned int mode)
 		return 0;
 	rcu_read_lock();
 	tcred = __task_cred(task);
-	if (cred->user_ns == tcred->user_ns &&
-	    (cred->uid == tcred->euid &&
-	     cred->uid == tcred->suid &&
-	     cred->uid == tcred->uid  &&
-	     cred->gid == tcred->egid &&
-	     cred->gid == tcred->sgid &&
-	     cred->gid == tcred->gid))
+	if (uid_eq(cred->uid, tcred->euid) &&
+	    uid_eq(cred->uid, tcred->suid) &&
+	    uid_eq(cred->uid, tcred->uid)  &&
+	    gid_eq(cred->gid, tcred->egid) &&
+	    gid_eq(cred->gid, tcred->sgid) &&
+	    gid_eq(cred->gid, tcred->gid))
 		goto ok;
 	if (ptrace_has_cap(tcred->user_ns, mode))
 		goto ok;
diff --git a/kernel/signal.c b/kernel/signal.c
index d630327..9797939 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -767,11 +767,10 @@ static int kill_ok_by_cred(struct task_struct *t)
 	const struct cred *cred = current_cred();
 	const struct cred *tcred = __task_cred(t);
 
-	if (cred->user_ns == tcred->user_ns &&
-	    (cred->euid == tcred->suid ||
-	     cred->euid == tcred->uid ||
-	     cred->uid  == tcred->suid ||
-	     cred->uid  == tcred->uid))
+	if (uid_eq(cred->euid, tcred->suid) ||
+	    uid_eq(cred->euid, tcred->uid)  ||
+	    uid_eq(cred->uid,  tcred->suid) ||
+	    uid_eq(cred->uid,  tcred->uid))
 		return 1;
 
 	if (ns_capable(tcred->user_ns, CAP_KILL))
@@ -1389,10 +1388,8 @@ static int kill_as_cred_perm(const struct cred *cred,
 			     struct task_struct *target)
 {
 	const struct cred *pcred = __task_cred(target);
-	if (cred->user_ns != pcred->user_ns)
-		return 0;
-	if (cred->euid != pcred->suid && cred->euid != pcred->uid &&
-	    cred->uid  != pcred->suid && cred->uid  != pcred->uid)
+	if (uid_eq(cred->euid, pcred->suid) && uid_eq(cred->euid, pcred->uid) &&
+	    uid_eq(cred->uid,  pcred->suid) && uid_eq(cred->uid,  pcred->uid))
 		return 0;
 	return 1;
 }
diff --git a/kernel/sys.c b/kernel/sys.c
index aff09f2..f484077 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -131,9 +131,8 @@ static bool set_one_prio_perm(struct task_struct *p)
 {
 	const struct cred *cred = current_cred(), *pcred = __task_cred(p);
 
-	if (pcred->user_ns == cred->user_ns &&
-	    (pcred->uid  == cred->euid ||
-	     pcred->euid == cred->euid))
+	if (uid_eq(pcred->uid,  cred->euid) ||
+	    uid_eq(pcred->euid, cred->euid))
 		return true;
 	if (ns_capable(pcred->user_ns, CAP_SYS_NICE))
 		return true;
@@ -1582,13 +1581,12 @@ static int check_prlimit_permission(struct task_struct *task)
 		return 0;
 
 	tcred = __task_cred(task);
-	if (cred->user_ns == tcred->user_ns &&
-	    (cred->uid == tcred->euid &&
-	     cred->uid == tcred->suid &&
-	     cred->uid == tcred->uid &&
-	     cred->gid == tcred->egid &&
-	     cred->gid == tcred->sgid &&
-		    cred->gid == tcred->gid))
+	if (uid_eq(cred->uid, tcred->euid) &&
+	    uid_eq(cred->uid, tcred->suid) &&
+	    uid_eq(cred->uid, tcred->uid)  &&
+	    gid_eq(cred->gid, tcred->egid) &&
+	    gid_eq(cred->gid, tcred->sgid) &&
+	    gid_eq(cred->gid, tcred->gid))
 		return 0;
 	if (ns_capable(tcred->user_ns, CAP_SYS_RESOURCE))
 		return 0;
-- 
1.7.2.5
