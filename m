From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cred_to_ucred: use the creator of the right namespace
Date: Fri, 7 May 2010 17:02:48 -0500
Message-ID: <20100507220248.GA2075@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hey Eric,

I ported a subset of your nsfd-v5 patchset to current git (took no
tweaking at all) and tested the received values of SCM_CREDENTIALS
ancillary msgs.  You'd asked me if it looked right before and I said
it did, but in fact there is a little bug, fixed by the below patch.

thanks,
-serge

From c99daef4d7927bf002b493039c86e3de70d7b8b1 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Fri, 7 May 2010 17:35:50 -0400
Subject: [PATCH 1/1] cred_to_ucred: use the creator of the right namespace

If cred->creator->user_ns == current->user_ns, then it is the
cred->creator>uid, not the current->user_ns->creator->uid which
we are interested in.

Tested with SCM_CREDENTIALS test program.  Without this patch,
if uid 1001 clones a task with clone(CLONE_NEWUSER), which
then does setresuid(25,25,25) and sends a SCM_CREDENTIALS msg
back to the parent, then the parent gets uid 0 and gid overflowgid.
The reason is that we were returning the uid of the creator of
the *parent*'s userns.

With this patch, the uid, gid, and pid are all correct.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/core/sock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index b5b5929..d3e2077 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -753,9 +753,10 @@ void cred_to_ucred(struct pid *pid, const struct cred *cred,
 			/* Is cred in a child user namespace */
 			tmp = cred_ns;
 			do {
+				struct user_namespace *p = tmp;
 				tmp = tmp->creator->user_ns;
 				if (tmp == current_ns) {
-					ucred->uid = tmp->creator->uid;
+					ucred->uid = p->creator->uid;
 					ucred->gid = overflowgid;
 					return;
 				}
-- 
1.7.0.4
