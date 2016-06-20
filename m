From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 06/13] fs: Add user namespace member to struct
	super_block
Date: Mon, 20 Jun 2016 12:21:23 -0500
Message-ID: <20160620172130.15712-6-ebiederm@xmission.com>
References: <87fus77pns.fsf@x220.int.ebiederm.org>
	<20160620172130.15712-1-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160620172130.15712-1-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Start marking filesystems with a user namespace owner, s_user_ns.  In
this change this is only used for permission checks of who may mount a
filesystem.  Ultimately s_user_ns will be used for translating ids and
checking capabilities for filesystems mounted from user namespaces.

The default policy for setting s_user_ns is implemented in sget(),
which arranges for s_user_ns to be set to current_user_ns() and to
ensure that the mounter of the filesystem has CAP_SYS_ADMIN in that
user_ns.

The guts of sget are split out into another function sget_userns().
The function sget_userns calls alloc_super with the specified user
namespace or it verifies the existing superblock that was found
has the expected user namespace, and fails with EBUSY when it is not.
This failing prevents users with the wrong privileges mounting a
filesystem.

The reason for the split of sget_userns from sget is that in some
cases such as mount_ns and kernfs_mount_ns a different policy for
permission checking of mounts and setting s_user_ns is necessary, and
the existence of sget_userns() allows those policies to be
implemented.

The helper mount_ns is expected to be used for filesystems such as
proc and mqueuefs which present per namespace information.  The
function mount_ns is modified to call sget_userns instead of sget to
ensure the user namespace owner of the namespace whose information is
presented by the filesystem is used on the superblock.

For sysfs and cgroup the appropriate permission checks are already in
place, and kernfs_mount_ns is modified to call sget_userns so that
the init_user_ns is the only user namespace used.

For the cgroup filesystem cgroup namespace mounts are bind mounts of a
subset of the full cgroup filesystem and as such s_user_ns must be the
same for all of them as there is only a single superblock.

Mounts of sysfs that vary based on the network namespace could in principle
change s_user_ns but it keeps the analysis and implementation of kernfs
simpler if that is not supported, and at present there appear to be no
benefits from supporting a different s_user_ns on any sysfs mount.

Getting the details of setting s_user_ns correct has been
a long process.  Thanks to Pavel Tikhorirorv who spotted a leak
in sget_userns.  Thanks to Seth Forshee who has kept the work alive.

Thanks-to: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Thanks-to: Pavel Tikhomirov <ptikhomirov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Acked-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/kernfs/mount.c  |  3 ++-
 fs/super.c         | 52 ++++++++++++++++++++++++++++++++++++++++++++++------
 include/linux/fs.h | 12 ++++++++++++
 3 files changed, 60 insertions(+), 7 deletions(-)

diff --git a/fs/kernfs/mount.c b/fs/kernfs/mount.c
index 63534f5f9073..d90d574c15a2 100644
--- a/fs/kernfs/mount.c
+++ b/fs/kernfs/mount.c
@@ -241,7 +241,8 @@ struct dentry *kernfs_mount_ns(struct file_system_type *fs_type, int flags,
 	info->root = root;
 	info->ns = ns;
 
-	sb = sget(fs_type, kernfs_test_super, kernfs_set_super, flags, info);
+	sb = sget_userns(fs_type, kernfs_test_super, kernfs_set_super, flags,
+			 &init_user_ns, info);
 	if (IS_ERR(sb) || sb->s_fs_info != info)
 		kfree(info);
 	if (IS_ERR(sb))
diff --git a/fs/super.c b/fs/super.c
index fd65667832e5..874c7e3ebb8f 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -33,6 +33,7 @@
 #include <linux/cleancache.h>
 #include <linux/fsnotify.h>
 #include <linux/lockdep.h>
+#include <linux/user_namespace.h>
 #include "internal.h"
 
 
@@ -165,6 +166,7 @@ static void destroy_super(struct super_block *s)
 	list_lru_destroy(&s->s_inode_lru);
 	security_sb_free(s);
 	WARN_ON(!list_empty(&s->s_mounts));
+	put_user_ns(s->s_user_ns);
 	kfree(s->s_subtype);
 	kfree(s->s_options);
 	call_rcu(&s->rcu, destroy_super_rcu);
@@ -174,11 +176,13 @@ static void destroy_super(struct super_block *s)
  *	alloc_super	-	create new superblock
  *	@type:	filesystem type superblock should belong to
  *	@flags: the mount flags
+ *	@user_ns: User namespace for the super_block
  *
  *	Allocates and initializes a new &struct super_block.  alloc_super()
  *	returns a pointer new superblock or %NULL if allocation had failed.
  */
-static struct super_block *alloc_super(struct file_system_type *type, int flags)
+static struct super_block *alloc_super(struct file_system_type *type, int flags,
+				       struct user_namespace *user_ns)
 {
 	struct super_block *s = kzalloc(sizeof(struct super_block),  GFP_USER);
 	static const struct super_operations default_op;
@@ -188,6 +192,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 		return NULL;
 
 	INIT_LIST_HEAD(&s->s_mounts);
+	s->s_user_ns = get_user_ns(user_ns);
 
 	if (security_sb_alloc(s))
 		goto fail;
@@ -443,17 +448,18 @@ void generic_shutdown_super(struct super_block *sb)
 EXPORT_SYMBOL(generic_shutdown_super);
 
 /**
- *	sget	-	find or create a superblock
+ *	sget_userns -	find or create a superblock
  *	@type:	filesystem type superblock should belong to
  *	@test:	comparison callback
  *	@set:	setup callback
  *	@flags:	mount flags
+ *	@user_ns: User namespace for the super_block
  *	@data:	argument to each of them
  */
-struct super_block *sget(struct file_system_type *type,
+struct super_block *sget_userns(struct file_system_type *type,
 			int (*test)(struct super_block *,void *),
 			int (*set)(struct super_block *,void *),
-			int flags,
+			int flags, struct user_namespace *user_ns,
 			void *data)
 {
 	struct super_block *s = NULL;
@@ -466,6 +472,14 @@ retry:
 		hlist_for_each_entry(old, &type->fs_supers, s_instances) {
 			if (!test(old, data))
 				continue;
+			if (user_ns != old->s_user_ns) {
+				spin_unlock(&sb_lock);
+				if (s) {
+					up_write(&s->s_umount);
+					destroy_super(s);
+				}
+				return ERR_PTR(-EBUSY);
+			}
 			if (!grab_super(old))
 				goto retry;
 			if (s) {
@@ -478,7 +492,7 @@ retry:
 	}
 	if (!s) {
 		spin_unlock(&sb_lock);
-		s = alloc_super(type, flags);
+		s = alloc_super(type, flags, user_ns);
 		if (!s)
 			return ERR_PTR(-ENOMEM);
 		goto retry;
@@ -501,6 +515,31 @@ retry:
 	return s;
 }
 
+EXPORT_SYMBOL(sget_userns);
+
+/**
+ *	sget	-	find or create a superblock
+ *	@type:	  filesystem type superblock should belong to
+ *	@test:	  comparison callback
+ *	@set:	  setup callback
+ *	@flags:	  mount flags
+ *	@data:	  argument to each of them
+ */
+struct super_block *sget(struct file_system_type *type,
+			int (*test)(struct super_block *,void *),
+			int (*set)(struct super_block *,void *),
+			int flags,
+			void *data)
+{
+	struct user_namespace *user_ns = current_user_ns();
+
+	/* Ensure the requestor has permissions over the target filesystem */
+	if (!(flags & MS_KERNMOUNT) && !ns_capable(user_ns, CAP_SYS_ADMIN))
+		return ERR_PTR(-EPERM);
+
+	return sget_userns(type, test, set, flags, user_ns, data);
+}
+
 EXPORT_SYMBOL(sget);
 
 void drop_super(struct super_block *sb)
@@ -930,7 +969,8 @@ struct dentry *mount_ns(struct file_system_type *fs_type,
 	if (!(flags & MS_KERNMOUNT) && !ns_capable(user_ns, CAP_SYS_ADMIN))
 		return ERR_PTR(-EPERM);
 
-	sb = sget(fs_type, ns_test_super, ns_set_super, flags, ns);
+	sb = sget_userns(fs_type, ns_test_super, ns_set_super, flags,
+			 user_ns, ns);
 	if (IS_ERR(sb))
 		return ERR_CAST(sb);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1ce006a24f49..9eef64f23a75 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1433,6 +1433,13 @@ struct super_block {
 	struct hlist_head s_pins;
 
 	/*
+	 * Owning user namespace and default context in which to
+	 * interpret filesystem uids, gids, quotas, device nodes,
+	 * xattrs and security labels.
+	 */
+	struct user_namespace *s_user_ns;
+
+	/*
 	 * Keep the lru lists last in the structure so they always sit on their
 	 * own individual cachelines.
 	 */
@@ -2056,6 +2063,11 @@ void deactivate_locked_super(struct super_block *sb);
 int set_anon_super(struct super_block *s, void *data);
 int get_anon_bdev(dev_t *);
 void free_anon_bdev(dev_t);
+struct super_block *sget_userns(struct file_system_type *type,
+			int (*test)(struct super_block *,void *),
+			int (*set)(struct super_block *,void *),
+			int flags, struct user_namespace *user_ns,
+			void *data);
 struct super_block *sget(struct file_system_type *type,
 			int (*test)(struct super_block *,void *),
 			int (*set)(struct super_block *,void *),
-- 
2.8.3
