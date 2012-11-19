From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 3/6] vfs: Add a user namespace reference from struct
	mnt_namespace
Date: Mon, 19 Nov 2012 02:50:19 -0800
Message-ID: <1353322222-27060-3-git-send-email-ebiederm@xmission.com>
References: <87k3thc1h3.fsf@xmission.com>
	<1353322222-27060-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353322222-27060-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

This will allow for support for unprivileged mounts in a new user namespace.

Acked-by: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/mount.h                    |    1 +
 fs/namespace.c                |   24 ++++++++++++++++--------
 include/linux/mnt_namespace.h |    3 ++-
 kernel/nsproxy.c              |    2 +-
 4 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/fs/mount.h b/fs/mount.h
index e9c37dd..630fafc 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -6,6 +6,7 @@ struct mnt_namespace {
 	atomic_t		count;
 	struct mount *	root;
 	struct list_head	list;
+	struct user_namespace	*user_ns;
 	u64			seq;	/* Sequence number to prevent loops */
 	wait_queue_head_t poll;
 	int event;
diff --git a/fs/namespace.c b/fs/namespace.c
index d287e7e..207c7ba 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -12,6 +12,7 @@
 #include <linux/export.h>
 #include <linux/capability.h>
 #include <linux/mnt_namespace.h>
+#include <linux/user_namespace.h>
 #include <linux/namei.h>
 #include <linux/security.h>
 #include <linux/idr.h>
@@ -2286,6 +2287,12 @@ dput_out:
 	return retval;
 }
 
+static void free_mnt_ns(struct mnt_namespace *ns)
+{
+	put_user_ns(ns->user_ns);
+	kfree(ns);
+}
+
 /*
  * Assign a sequence number so we can detect when we attempt to bind
  * mount a reference to an older mount namespace into the current
@@ -2295,7 +2302,7 @@ dput_out:
  */
 static atomic64_t mnt_ns_seq = ATOMIC64_INIT(1);
 
-static struct mnt_namespace *alloc_mnt_ns(void)
+static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *user_ns)
 {
 	struct mnt_namespace *new_ns;
 
@@ -2308,6 +2315,7 @@ static struct mnt_namespace *alloc_mnt_ns(void)
 	INIT_LIST_HEAD(&new_ns->list);
 	init_waitqueue_head(&new_ns->poll);
 	new_ns->event = 0;
+	new_ns->user_ns = get_user_ns(user_ns);
 	return new_ns;
 }
 
@@ -2316,7 +2324,7 @@ static struct mnt_namespace *alloc_mnt_ns(void)
  * copied from the namespace of the passed in task structure.
  */
 static struct mnt_namespace *dup_mnt_ns(struct mnt_namespace *mnt_ns,
-		struct fs_struct *fs)
+		struct user_namespace *user_ns, struct fs_struct *fs)
 {
 	struct mnt_namespace *new_ns;
 	struct vfsmount *rootmnt = NULL, *pwdmnt = NULL;
@@ -2324,7 +2332,7 @@ static struct mnt_namespace *dup_mnt_ns(struct mnt_namespace *mnt_ns,
 	struct mount *old = mnt_ns->root;
 	struct mount *new;
 
-	new_ns = alloc_mnt_ns();
+	new_ns = alloc_mnt_ns(user_ns);
 	if (IS_ERR(new_ns))
 		return new_ns;
 
@@ -2333,7 +2341,7 @@ static struct mnt_namespace *dup_mnt_ns(struct mnt_namespace *mnt_ns,
 	new = copy_tree(old, old->mnt.mnt_root, CL_COPY_ALL | CL_EXPIRE);
 	if (IS_ERR(new)) {
 		up_write(&namespace_sem);
-		kfree(new_ns);
+		free_mnt_ns(new_ns);
 		return ERR_CAST(new);
 	}
 	new_ns->root = new;
@@ -2374,7 +2382,7 @@ static struct mnt_namespace *dup_mnt_ns(struct mnt_namespace *mnt_ns,
 }
 
 struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
-		struct fs_struct *new_fs)
+		struct user_namespace *user_ns, struct fs_struct *new_fs)
 {
 	struct mnt_namespace *new_ns;
 
@@ -2384,7 +2392,7 @@ struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
 	if (!(flags & CLONE_NEWNS))
 		return ns;
 
-	new_ns = dup_mnt_ns(ns, new_fs);
+	new_ns = dup_mnt_ns(ns, user_ns, new_fs);
 
 	put_mnt_ns(ns);
 	return new_ns;
@@ -2396,7 +2404,7 @@ struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
  */
 static struct mnt_namespace *create_mnt_ns(struct vfsmount *m)
 {
-	struct mnt_namespace *new_ns = alloc_mnt_ns();
+	struct mnt_namespace *new_ns = alloc_mnt_ns(&init_user_ns);
 	if (!IS_ERR(new_ns)) {
 		struct mount *mnt = real_mount(m);
 		mnt->mnt_ns = new_ns;
@@ -2682,7 +2690,7 @@ void put_mnt_ns(struct mnt_namespace *ns)
 	br_write_unlock(&vfsmount_lock);
 	up_write(&namespace_sem);
 	release_mounts(&umount_list);
-	kfree(ns);
+	free_mnt_ns(ns);
 }
 
 struct vfsmount *kern_mount_data(struct file_system_type *type, void *data)
diff --git a/include/linux/mnt_namespace.h b/include/linux/mnt_namespace.h
index 5a8e390..12b2ab5 100644
--- a/include/linux/mnt_namespace.h
+++ b/include/linux/mnt_namespace.h
@@ -4,9 +4,10 @@
 
 struct mnt_namespace;
 struct fs_struct;
+struct user_namespace;
 
 extern struct mnt_namespace *copy_mnt_ns(unsigned long, struct mnt_namespace *,
-		struct fs_struct *);
+		struct user_namespace *, struct fs_struct *);
 extern void put_mnt_ns(struct mnt_namespace *ns);
 
 extern const struct file_operations proc_mounts_operations;
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index b576f7f..5b6ce19 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -66,7 +66,7 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 	if (!new_nsp)
 		return ERR_PTR(-ENOMEM);
 
-	new_nsp->mnt_ns = copy_mnt_ns(flags, tsk->nsproxy->mnt_ns, new_fs);
+	new_nsp->mnt_ns = copy_mnt_ns(flags, tsk->nsproxy->mnt_ns, task_cred_xxx(tsk, user_ns), new_fs);
 	if (IS_ERR(new_nsp->mnt_ns)) {
 		err = PTR_ERR(new_nsp->mnt_ns);
 		goto out_ns;
-- 
1.7.5.4
