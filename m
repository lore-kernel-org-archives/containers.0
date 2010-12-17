From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [RFC 4/5] user namespaces: allow killing tasks in your own or
	child userns
Date: Fri, 17 Dec 2010 15:26:59 +0000
Message-ID: <20101217152659.GD11162__48236.6416989409$1292599810$gmane$org@mail.hallyn.com>
References: <20101217152246.GA8221@mail.hallyn.com>
	<20101217152458.GA11162@mail.hallyn.com>
	<20101217152547.GB11162@mail.hallyn.com>
	<20101217152625.GC11162@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101217152625.GC11162-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michael Kerrisk <michael.kerrisk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Changelog:
	Dec 8: Fixed bug in my check_kill_permission pointed out by
	       Eric Biederman.
	Dec 13: Apply Eric's suggestion to pass target task into kill_ok_by_cred()
	        for clarity

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 kernel/signal.c |   33 ++++++++++++++++++++++++++++-----
 1 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 4e3cff1..499bd36 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -636,6 +636,33 @@ static inline bool si_fromuser(const struct siginfo *info)
 }
 
 /*
+ * called with RCU read lock from check_kill_permission()
+ */
+static inline int kill_ok_by_cred(struct task_struct *t)
+{
+	struct cred *cred = current_cred();
+	struct cred *tcred = __task_cred(t);
+
+	if (cred->user->user_ns != tcred->user->user_ns) {
+		/* userids are not equivalent - either you have the
+		   capability to the target user ns or you don't */
+		if (ns_capable(tcred->user->user_ns, CAP_KILL))
+			return 1;
+		return 0;
+	}
+
+	/* same user namespace - usual credentials checks apply */
+	if ((cred->euid ^ tcred->suid) &&
+	    (cred->euid ^ tcred->uid) &&
+	    (cred->uid  ^ tcred->suid) &&
+	    (cred->uid  ^ tcred->uid) &&
+	    !ns_capable(tcred->user->user_ns, CAP_KILL))
+		return 0;
+
+	return 1;
+}
+
+/*
  * Bad permissions for sending the signal
  * - the caller must hold the RCU read lock
  */
@@ -659,11 +686,7 @@ static int check_kill_permission(int sig, struct siginfo *info,
 	cred = current_cred();
 	tcred = __task_cred(t);
 	if (!same_thread_group(current, t) &&
-	    (cred->euid ^ tcred->suid) &&
-	    (cred->euid ^ tcred->uid) &&
-	    (cred->uid  ^ tcred->suid) &&
-	    (cred->uid  ^ tcred->uid) &&
-	    !capable(CAP_KILL)) {
+	    !kill_ok_by_cred(t)) {
 		switch (sig) {
 		case SIGCONT:
 			sid = task_session(t);
-- 
1.7.0.4
