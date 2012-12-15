From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 3/4] userns: Add a more complete capability subset test to
	commit_creds
Date: Fri, 14 Dec 2012 16:48:34 -0800
Message-ID: <87lid0rvh9.fsf@xmission.com>
References: <87txroxpgq.fsf@xmission.com> <87bodwxpcg.fsf@xmission.com>
	<20121215000338.GC13659@mail.hallyn.com> <87r4msrx6t.fsf@xmission.com>
	<20121215004735.GA14295@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121215004735.GA14295-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Sat, 15 Dec 2012 00:47:35 +0000")
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
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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
 kernel/cred.c |   27 ++++++++++++++++++++++++++-
 1 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/kernel/cred.c b/kernel/cred.c
index 48cea3d..709d521 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -455,6 +455,31 @@ error_put:
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
+	 * ancestor of subset and set->euid is owner of subset or one
+	 * of subsets ancestors.
+	 */
+	for (;subset_ns != &init_user_ns; subset_ns = subset_ns->parent) {
+		if ((set_ns == subset_ns->parent)  &&
+		    uid_eq(subset_ns->owner, set->euid))
+			return true;
+	}
+
+	return false;
+}
+
 /**
  * commit_creds - Install new credentials upon the current task
  * @new: The credentials to be assigned
@@ -493,7 +518,7 @@ int commit_creds(struct cred *new)
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
