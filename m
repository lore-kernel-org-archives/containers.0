From: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 10/14] net/core/scm.c: target capable() calls to user_ns
	owning the net_ns
Date: Tue, 12 Jul 2011 23:30:48 +0000
Message-ID: <1310513452-13397-11-git-send-email-serge__6596.9074647457$1310514079$gmane$org@hallyn.com>
References: <1310513452-13397-1-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1310513452-13397-1-git-send-email-serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

The uid/gid comparisons don't have to be pulled out.  This just seemed
more easily proved correct.

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/core/scm.c |   41 ++++++++++++++++++++++++++++++++++-------
 1 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/net/core/scm.c b/net/core/scm.c
index 4c1ef02..21b5d0b 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -43,17 +43,44 @@
  *	setu(g)id.
  */
 
-static __inline__ int scm_check_creds(struct ucred *creds)
+static __inline__ bool uidequiv(struct cred *src, struct ucred *tgt,
+			       struct user_namespace *ns)
+{
+	if (src->user_ns != ns)
+		goto check_capable;
+	if (src->uid == tgt->uid || src->euid == tgt->uid ||
+	    src->suid == tgt->uid)
+		return true;
+check_capable:
+	if (ns_capable(ns, CAP_SETUID))
+		return true;
+	return false;
+}
+
+static __inline__ bool gidequiv(struct cred *src, struct ucred *tgt,
+			       struct user_namespace *ns)
+{
+	if (src->user_ns != ns)
+		goto check_capable;
+	if (src->gid == tgt->gid || src->egid == tgt->gid ||
+	    src->sgid == tgt->gid)
+		return true;
+check_capable:
+	if (ns_capable(ns, CAP_SETGID))
+		return true;
+	return false;
+}
+
+static __inline__ int scm_check_creds(struct ucred *creds, struct socket *sock)
 {
 	const struct cred *cred = current_cred();
+	struct user_namespace *ns = sock_net(sock->sk)->user_ns;
 
-	if ((creds->pid == task_tgid_vnr(current) || capable(CAP_SYS_ADMIN)) &&
-	    ((creds->uid == cred->uid   || creds->uid == cred->euid ||
-	      creds->uid == cred->suid) || capable(CAP_SETUID)) &&
-	    ((creds->gid == cred->gid   || creds->gid == cred->egid ||
-	      creds->gid == cred->sgid) || capable(CAP_SETGID))) {
+	if ((creds->pid == task_tgid_vnr(current) || ns_capable(ns, CAP_SYS_ADMIN)) &&
+	     uidequiv(cred, creds, ns) && gidequiv(cred, creds, ns)) {
 	       return 0;
 	}
+
 	return -EPERM;
 }
 
@@ -169,7 +196,7 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 			if (cmsg->cmsg_len != CMSG_LEN(sizeof(struct ucred)))
 				goto error;
 			memcpy(&p->creds, CMSG_DATA(cmsg), sizeof(struct ucred));
-			err = scm_check_creds(&p->creds);
+			err = scm_check_creds(&p->creds, sock);
 			if (err)
 				goto error;
 
-- 
1.7.4.1
