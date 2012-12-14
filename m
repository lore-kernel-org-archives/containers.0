From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 3/4] userns: Add a more complete capability subset test to
	commit_creds
Date: Fri, 14 Dec 2012 14:04:31 -0800
Message-ID: <87bodwxpcg.fsf__27760.9139717699$1355522703$gmane$org@xmission.com>
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


When unsharing a user namespace we reduce our credentials to just what
can be done in that user namespace.  This is a subset of the credentials
we previously had.  Teach commit_creds to recognize this is a subset
of the credentials we have had before and don't clear the dumpability flag.

This allows an unprivileged  program to do:
unshare(CLONE_NEWUSER);
fd = open("/proc/self/uid_map", O_RDWR);

Where previously opening the uid_map writable would fail because
the the task had been made non-dumpable.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/cred.c |   26 +++++++++++++++++++++++++-
 1 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/kernel/cred.c b/kernel/cred.c
index 48cea3d..993a7ea41 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -455,6 +455,30 @@ error_put:
 	return ret;
 }
 
+static bool cred_cap_issubset(const struct cred *set, const struct cred *subset)
+{
+	const struct user_namespace *set_ns = set->user_ns;
+	const struct user_namespace *subset_ns = subset->user_ns;
+
+	/* If the two credentials are in the same user namespace see if
+	 * the capabilities of subset are a subset of set.
+	 */
+	if (set_ns == subset_ns)
+		return cap_issubset(subset->cap_permitted, set->cap_permitted);
+
+	/* The credentials are in a different user namespaces
+	 * therefore one is a subset of the other only if a set is an
+	 * ancestor of subset.
+	 */
+	while (subset_ns != &init_user_ns) {
+		if (set_ns == subset_ns->parent)
+			return true;
+		subset_ns = subset_ns->parent;
+	}
+
+	return false;
+}
+
 /**
  * commit_creds - Install new credentials upon the current task
  * @new: The credentials to be assigned
@@ -493,7 +517,7 @@ int commit_creds(struct cred *new)
 	    !gid_eq(old->egid, new->egid) ||
 	    !uid_eq(old->fsuid, new->fsuid) ||
 	    !gid_eq(old->fsgid, new->fsgid) ||
-	    !cap_issubset(new->cap_permitted, old->cap_permitted)) {
+	    !cred_cap_issubset(old, new)) {
 		if (task->mm)
 			set_dumpable(task->mm, suid_dumpable);
 		task->pdeath_signal = 0;
-- 
1.7.5.4
