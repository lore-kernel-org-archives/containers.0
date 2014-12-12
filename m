From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 08/18] groups: Consolidate the setgroups permission
	checks
Date: Fri, 12 Dec 2014 16:48:19 -0600
Message-ID: <1418424509-22389-8-git-send-email-ebiederm__35035.6232993819$1418424739$gmane$org@xmission.com>
References: <87k31wzehb.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k31wzehb.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Today there are 3 instances of setgroups and due to an oversight their
permission checking has diverged.  Add a common function so that
they may all share the same permission checking code.

This corrects the current oversight in the current permission checks
and adds a helper to avoid this in the future.

A user namespace security fix will update this new helper, shortly.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 arch/s390/kernel/compat_linux.c | 2 +-
 include/linux/cred.h            | 1 +
 kernel/groups.c                 | 9 ++++++++-
 kernel/uid16.c                  | 2 +-
 4 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index ca38139423ae..437e61159279 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -249,7 +249,7 @@ COMPAT_SYSCALL_DEFINE2(s390_setgroups16, int, gidsetsize, u16 __user *, grouplis
 	struct group_info *group_info;
 	int retval;
 
-	if (!capable(CAP_SETGID))
+	if (!may_setgroups())
 		return -EPERM;
 	if ((unsigned)gidsetsize > NGROUPS_MAX)
 		return -EINVAL;
diff --git a/include/linux/cred.h b/include/linux/cred.h
index b2d0820837c4..2fb2ca2127ed 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -68,6 +68,7 @@ extern void groups_free(struct group_info *);
 extern int set_current_groups(struct group_info *);
 extern void set_groups(struct cred *, struct group_info *);
 extern int groups_search(const struct group_info *, kgid_t);
+extern bool may_setgroups(void);
 
 /* access the groups "array" with this macro */
 #define GROUP_AT(gi, i) \
diff --git a/kernel/groups.c b/kernel/groups.c
index 451698f86cfa..02d8a251c476 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -213,6 +213,13 @@ out:
 	return i;
 }
 
+bool may_setgroups(void)
+{
+	struct user_namespace *user_ns = current_user_ns();
+
+	return ns_capable(user_ns, CAP_SETGID);
+}
+
 /*
  *	SMP: Our groups are copy-on-write. We can set them safely
  *	without another task interfering.
@@ -223,7 +230,7 @@ SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)
 	struct group_info *group_info;
 	int retval;
 
-	if (!ns_capable(current_user_ns(), CAP_SETGID))
+	if (!may_setgroups())
 		return -EPERM;
 	if ((unsigned)gidsetsize > NGROUPS_MAX)
 		return -EINVAL;
diff --git a/kernel/uid16.c b/kernel/uid16.c
index 602e5bbbceff..d58cc4d8f0d1 100644
--- a/kernel/uid16.c
+++ b/kernel/uid16.c
@@ -176,7 +176,7 @@ SYSCALL_DEFINE2(setgroups16, int, gidsetsize, old_gid_t __user *, grouplist)
 	struct group_info *group_info;
 	int retval;
 
-	if (!ns_capable(current_user_ns(), CAP_SETGID))
+	if (!may_setgroups())
 		return -EPERM;
 	if ((unsigned)gidsetsize > NGROUPS_MAX)
 		return -EINVAL;
-- 
1.9.1
