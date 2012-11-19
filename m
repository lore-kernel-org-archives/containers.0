From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 09/16] userns: Implent proc namespace operations
Date: Mon, 19 Nov 2012 07:12:34 -0800
Message-ID: <1353337961-12962-9-git-send-email-ebiederm@xmission.com>
References: <87lidx8wbo.fsf@xmission.com>
	<1353337961-12962-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353337961-12962-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

This allows entering a user namespace, and the ability
to store a reference to a user namespace with a bind
mount.

Addition of missing userns_ns_put in userns_install
from Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/namespaces.c    |    4 ++
 include/linux/proc_fs.h |    1 +
 kernel/user_namespace.c |   90 ++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 78 insertions(+), 17 deletions(-)

diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
index 2a17fd9..030250c 100644
--- a/fs/proc/namespaces.c
+++ b/fs/proc/namespaces.c
@@ -11,6 +11,7 @@
 #include <net/net_namespace.h>
 #include <linux/ipc_namespace.h>
 #include <linux/pid_namespace.h>
+#include <linux/user_namespace.h>
 #include "internal.h"
 
 
@@ -27,6 +28,9 @@ static const struct proc_ns_operations *ns_entries[] = {
 #ifdef CONFIG_PID_NS
 	&pidns_operations,
 #endif
+#ifdef CONFIG_USER_NS
+	&userns_operations,
+#endif
 	&mntns_operations,
 };
 
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 9014c04..3144781 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -258,6 +258,7 @@ extern const struct proc_ns_operations netns_operations;
 extern const struct proc_ns_operations utsns_operations;
 extern const struct proc_ns_operations ipcns_operations;
 extern const struct proc_ns_operations pidns_operations;
+extern const struct proc_ns_operations userns_operations;
 extern const struct proc_ns_operations mntns_operations;
 
 union proc_op {
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 49096d5..a946077 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -9,6 +9,7 @@
 #include <linux/nsproxy.h>
 #include <linux/slab.h>
 #include <linux/user_namespace.h>
+#include <linux/proc_fs.h>
 #include <linux/highuid.h>
 #include <linux/cred.h>
 #include <linux/securebits.h>
@@ -26,6 +27,24 @@ static struct kmem_cache *user_ns_cachep __read_mostly;
 static bool new_idmap_permitted(struct user_namespace *ns, int cap_setid,
 				struct uid_gid_map *map);
 
+static void set_cred_user_ns(struct cred *cred, struct user_namespace *user_ns)
+{
+	/* Start with the same capabilities as init but useless for doing
+	 * anything as the capabilities are bound to the new user namespace.
+	 */
+	cred->securebits = SECUREBITS_DEFAULT;
+	cred->cap_inheritable = CAP_EMPTY_SET;
+	cred->cap_permitted = CAP_FULL_SET;
+	cred->cap_effective = CAP_FULL_SET;
+	cred->cap_bset = CAP_FULL_SET;
+#ifdef CONFIG_KEYS
+	key_put(cred->request_key_auth);
+	cred->request_key_auth = NULL;
+#endif
+	/* tgcred will be cleared in our caller bc CLONE_THREAD won't be set */
+	cred->user_ns = user_ns;
+}
+
 /*
  * Create a new user namespace, deriving the creator from the user in the
  * passed credentials, and replacing that user with the new root user for the
@@ -53,27 +72,12 @@ int create_user_ns(struct cred *new)
 		return -ENOMEM;
 
 	kref_init(&ns->kref);
+	/* Leave the new->user_ns reference with the new user namespace. */
 	ns->parent = parent_ns;
 	ns->owner = owner;
 	ns->group = group;
 
-	/* Start with the same capabilities as init but useless for doing
-	 * anything as the capabilities are bound to the new user namespace.
-	 */
-	new->securebits = SECUREBITS_DEFAULT;
-	new->cap_inheritable = CAP_EMPTY_SET;
-	new->cap_permitted = CAP_FULL_SET;
-	new->cap_effective = CAP_FULL_SET;
-	new->cap_bset = CAP_FULL_SET;
-#ifdef CONFIG_KEYS
-	key_put(new->request_key_auth);
-	new->request_key_auth = NULL;
-#endif
-	/* tgcred will be cleared in our caller bc CLONE_THREAD won't be set */
-
-	/* Leave the new->user_ns reference with the new user namespace. */
-	/* Leave the reference to our user_ns with the new cred. */
-	new->user_ns = ns;
+	set_cred_user_ns(new, ns);
 
 	return 0;
 }
@@ -737,6 +741,58 @@ static bool new_idmap_permitted(struct user_namespace *ns, int cap_setid,
 	return false;
 }
 
+static void *userns_get(struct task_struct *task)
+{
+	struct user_namespace *user_ns;
+
+	rcu_read_lock();
+	user_ns = get_user_ns(__task_cred(task)->user_ns);
+	rcu_read_unlock();
+
+	return user_ns;
+}
+
+static void userns_put(void *ns)
+{
+	put_user_ns(ns);
+}
+
+static int userns_install(struct nsproxy *nsproxy, void *ns)
+{
+	struct user_namespace *user_ns = ns;
+	struct cred *cred;
+
+	/* Don't allow gaining capabilities by reentering
+	 * the same user namespace.
+	 */
+	if (user_ns == current_user_ns())
+		return -EINVAL;
+
+	/* Threaded many not enter a different user namespace */
+	if (atomic_read(&current->mm->mm_users) > 1)
+		return -EINVAL;
+
+	if (!ns_capable(user_ns, CAP_SYS_ADMIN))
+		return -EPERM;
+
+	cred = prepare_creds();
+	if (!cred)
+		return -ENOMEM;
+
+	put_user_ns(cred->user_ns);
+	set_cred_user_ns(cred, get_user_ns(user_ns));
+
+	return commit_creds(cred);
+}
+
+const struct proc_ns_operations userns_operations = {
+	.name		= "user",
+	.type		= CLONE_NEWUSER,
+	.get		= userns_get,
+	.put		= userns_put,
+	.install	= userns_install,
+};
+
 static __init int user_namespaces_init(void)
 {
 	user_ns_cachep = KMEM_CACHE(user_namespace, SLAB_PANIC);
-- 
1.7.5.4
