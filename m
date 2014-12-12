From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 10/18] userns: Don't allow setgroups until a gid
	mapping has been setablished
Date: Fri, 12 Dec 2014 16:48:21 -0600
Message-ID: <1418424509-22389-10-git-send-email-ebiederm__18954.5155190446$1418424752$gmane$org@xmission.com>
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

setgroups is unique in not needing a valid mapping before it can be called,
in the case of setgroups(0, NULL) which drops all supplemental groups.

The design of the user namespace assumes that CAP_SETGID can not actually
be used until a gid mapping is established.  Therefore add a helper function
to see if the user namespace gid mapping has been established and call
that function in the setgroups permission check.

This is part of the fix for CVE-2014-8989, being able to drop groups
without privilege using user namespaces.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Reviewed-by: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/user_namespace.h |  5 +++++
 kernel/groups.c                |  4 +++-
 kernel/user_namespace.c        | 14 ++++++++++++++
 3 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index e95372654f09..8d493083486a 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -63,6 +63,7 @@ extern const struct seq_operations proc_projid_seq_operations;
 extern ssize_t proc_uid_map_write(struct file *, const char __user *, size_t, loff_t *);
 extern ssize_t proc_gid_map_write(struct file *, const char __user *, size_t, loff_t *);
 extern ssize_t proc_projid_map_write(struct file *, const char __user *, size_t, loff_t *);
+extern bool userns_may_setgroups(const struct user_namespace *ns);
 #else
 
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
@@ -87,6 +88,10 @@ static inline void put_user_ns(struct user_namespace *ns)
 {
 }
 
+static inline bool userns_may_setgroups(const struct user_namespace *ns)
+{
+	return true;
+}
 #endif
 
 #endif /* _LINUX_USER_H */
diff --git a/kernel/groups.c b/kernel/groups.c
index 02d8a251c476..664411f171b5 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -6,6 +6,7 @@
 #include <linux/slab.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
+#include <linux/user_namespace.h>
 #include <asm/uaccess.h>
 
 /* init to 2 - one for init_task, one to ensure it is never freed */
@@ -217,7 +218,8 @@ bool may_setgroups(void)
 {
 	struct user_namespace *user_ns = current_user_ns();
 
-	return ns_capable(user_ns, CAP_SETGID);
+	return ns_capable(user_ns, CAP_SETGID) &&
+		userns_may_setgroups(user_ns);
 }
 
 /*
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index b99c862a2e3f..27c8dab48c07 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -843,6 +843,20 @@ static bool new_idmap_permitted(const struct file *file,
 	return false;
 }
 
+bool userns_may_setgroups(const struct user_namespace *ns)
+{
+	bool allowed;
+
+	mutex_lock(&id_map_mutex);
+	/* It is not safe to use setgroups until a gid mapping in
+	 * the user namespace has been established.
+	 */
+	allowed = ns->gid_map.nr_extents != 0;
+	mutex_unlock(&id_map_mutex);
+
+	return allowed;
+}
+
 static void *userns_get(struct task_struct *task)
 {
 	struct user_namespace *user_ns;
-- 
1.9.1
