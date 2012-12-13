From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [RFC][PATCH] Fix cap_capable to only allow owners in the parent user
	namespace to have caps.
Date: Thu, 13 Dec 2012 14:39:20 -0800
Message-ID: <87zk1hshk7.fsf_-___13040.3466093869$1355438389$gmane$org@xmission.com>
References: <87ip88uw4n.fsf@xmission.com> <50CA2B55.5070402@amacapital.net>
	<87mwxhtxve.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87mwxhtxve.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Thu, 13 Dec 2012 14:01:41 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org


Andy Lutomirski pointed out that the current behavior of allowing the
owner of a user namespace to have all caps when that owner is not in a
parent user namespace is wrong.

This is a bug introduced by the kuid conversion which made it possible
for the owner of a user namespace to live in a child user namespace.  I
goofed and totally missed this implication.

Serge and can you please take a look and see if my corrected cap_capable
reads correctly to you.

Andy or anyone else that wants to give me a second eyeball and double
check me on this I would appreciate it.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

---

diff --git a/security/commoncap.c b/security/commoncap.c
index 6dbae46..4639f44 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -70,37 +70,44 @@ int cap_netlink_send(struct sock *sk, struct sk_buff *skb)
  *
  * NOTE WELL: cap_has_capability() cannot be used like the kernel's capable()
  * and has_capability() functions.  That is, it has the reverse semantics:
  * cap_has_capability() returns 0 when a task has a capability, but the
  * kernel's capable() and has_capability() returns 1 for this case.
  */
 int cap_capable(const struct cred *cred, struct user_namespace *targ_ns,
 		int cap, int audit)
 {
 	for (;;) {
-		/* The owner of the user namespace has all caps. */
-		if (targ_ns != &init_user_ns && uid_eq(targ_ns->owner, cred->euid))
-			return 0;
+		struct user_namespace *parent_ns;
 
 		/* Do we have the necessary capabilities? */
 		if (targ_ns == cred->user_ns)
 			return cap_raised(cred->cap_effective, cap) ? 0 : -EPERM;
 
 		/* Have we tried all of the parent namespaces? */
 		if (targ_ns == &init_user_ns)
 			return -EPERM;
 
+		parent_ns = targ_ns->parent;
+
+		/* 
+		 * The owner of the user namespace in the parent user
+		 * namespace has all caps.
+		 */
+		if ((parent_ns == cred->user_ns) && uid_eq(targ_ns->owner, cred->euid))
+			return 0;
+
 		/*
-		 *If you have a capability in a parent user ns, then you have
+		 * If you have a capability in a parent user ns, then you have
 		 * it over all children user namespaces as well.
 		 */
-		targ_ns = targ_ns->parent;
+		targ_ns = parent_ns;
 	}
 
 	/* We never get here */
 }
 
 /**
  * cap_settime - Determine whether the current process may set the system clock
  * @ts: The time to set
  * @tz: The timezone to set
  *
