From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 1/4] Fix cap_capable to only allow owners in the parent user
	namespace to have caps.
Date: Fri, 14 Dec 2012 14:03:05 -0800
Message-ID: <87obhwxpeu.fsf__25506.5144425773$1355522617$gmane$org@xmission.com>
References: <87txroxpgq.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87txroxpgq.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Fri, 14 Dec 2012 14:01:57 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Andy Lutomirski pointed out that the current behavior of allowing the
owner of a user namespace to have all caps when that owner is not in a
parent user namespace is wrong.  Add a test to ensure the owner of a user
namespace is in the parent of the user namespace to fix this bug.

Thankfully this bug did not apply to the initial user namespace, keeping
the mischief that can be caused by this bug quite small.

This is bug was introduced in v3.5 by commit 783291e6900
"Simplify the user_namespace by making userns->creator a kuid."
But did not matter until the permisions required to create
a user namespace were relaxed allowing a user namespace to be created
inside of a user namespace.

The bug made it possible for the owner of a user namespace to be
present in a child user namespace.  Since the owner of a user nameapce
is granted all capabilities it became possible for users in a
grandchild user namespace to have all privilges over their parent user
namspace.

Reorder the checks in cap_capable.  This should make the common case
faster and make it clear that nothing magic happens in the initial
user namespace.  The reordering is safe because cred->user_ns
can only be in targ_ns or targ_ns->parent but not both.

Add a comment a the top of the loop to make the logic of
the code clear.

Add a distinct variable ns that changes as we walk up
the user namespace hierarchy to make it clear which variable
is changing.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 security/commoncap.c |   25 +++++++++++++++++--------
 1 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/security/commoncap.c b/security/commoncap.c
index 6dbae46..7ee08c7 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -76,24 +76,33 @@ int cap_netlink_send(struct sock *sk, struct sk_buff *skb)
 int cap_capable(const struct cred *cred, struct user_namespace *targ_ns,
 		int cap, int audit)
 {
-	for (;;) {
-		/* The owner of the user namespace has all caps. */
-		if (targ_ns != &init_user_ns && uid_eq(targ_ns->owner, cred->euid))
-			return 0;
+	struct user_namespace *ns = targ_ns;
 
+	/* See if cred has the capability in the target user namespace
+	 * by examining the target user namespace and all of the target
+	 * user namespace's parents.
+	 */
+	for (;;) {
 		/* Do we have the necessary capabilities? */
-		if (targ_ns == cred->user_ns)
+		if (ns == cred->user_ns)
 			return cap_raised(cred->cap_effective, cap) ? 0 : -EPERM;
 
 		/* Have we tried all of the parent namespaces? */
-		if (targ_ns == &init_user_ns)
+		if (ns == &init_user_ns)
 			return -EPERM;
 
+		/* 
+		 * The owner of the user namespace in the parent of the
+		 * user namespace has all caps.
+		 */
+		if ((ns->parent == cred->user_ns) && uid_eq(ns->owner, cred->euid))
+			return 0;
+
 		/*
-		 *If you have a capability in a parent user ns, then you have
+		 * If you have a capability in a parent user ns, then you have
 		 * it over all children user namespaces as well.
 		 */
-		targ_ns = targ_ns->parent;
+		ns = ns->parent;
 	}
 
 	/* We never get here */
-- 
1.7.5.4
