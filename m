From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 04/13] vfs: Pass data, ns, and ns->userns to mount_ns
Date: Mon, 20 Jun 2016 12:21:21 -0500
Message-ID: <20160620172130.15712-4-ebiederm@xmission.com>
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

Today what is normally called data (the mount options) is not passed
to fill_super through mount_ns.

Pass the mount options and the namespace separately to mount_ns so
that filesystems such as proc that have mount options, can use
mount_ns.

Pass the user namespace to mount_ns so that the standard permission
check that verifies the mounter has permissions over the namespace can
be performed in mount_ns instead of in each filesystems .mount method.
Thus removing the duplication between mqueuefs and proc in terms of
permission checks.  The extra permission check does not currently
affect the rpc_pipefs filesystem and the nfsd filesystem as those
filesystems do not currently allow unprivileged mounts.  Without
unpvileged mounts it is guaranteed that the caller has already passed
capable(CAP_SYS_ADMIN) which guarantees extra permission check will
pass.

Update rpc_pipefs and the nfsd filesystem to ensure that the network
namespace reference is always taken in fill_super and always put in kill_sb
so that the logic is simpler and so that errors originating inside of
fill_super do not cause a network namespace leak.

Acked-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nfsd/nfsctl.c      | 13 ++++---------
 fs/super.c            | 13 ++++++++++---
 include/linux/fs.h    |  5 +++--
 ipc/mqueue.c          | 19 ++++++++-----------
 net/sunrpc/rpc_pipe.c |  8 ++++----
 5 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 9690cb4dd588..5a6ae2522266 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1154,20 +1154,15 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 #endif
 		/* last one */ {""}
 	};
-	struct net *net = data;
-	int ret;
-
-	ret = simple_fill_super(sb, 0x6e667364, nfsd_files);
-	if (ret)
-		return ret;
-	sb->s_fs_info = get_net(net);
-	return 0;
+	get_net(sb->s_fs_info);
+	return simple_fill_super(sb, 0x6e667364, nfsd_files);
 }
 
 static struct dentry *nfsd_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data)
 {
-	return mount_ns(fs_type, flags, current->nsproxy->net_ns, nfsd_fill_super);
+	struct net *net = current->nsproxy->net_ns;
+	return mount_ns(fs_type, flags, data, net, net->user_ns, nfsd_fill_super);
 }
 
 static void nfsd_umount(struct super_block *sb)
diff --git a/fs/super.c b/fs/super.c
index d78b9847e6cb..fd65667832e5 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -918,12 +918,19 @@ static int ns_set_super(struct super_block *sb, void *data)
 	return set_anon_super(sb, NULL);
 }
 
-struct dentry *mount_ns(struct file_system_type *fs_type, int flags,
-	void *data, int (*fill_super)(struct super_block *, void *, int))
+struct dentry *mount_ns(struct file_system_type *fs_type,
+	int flags, void *data, void *ns, struct user_namespace *user_ns,
+	int (*fill_super)(struct super_block *, void *, int))
 {
 	struct super_block *sb;
 
-	sb = sget(fs_type, ns_test_super, ns_set_super, flags, data);
+	/* Don't allow mounting unless the caller has CAP_SYS_ADMIN
+	 * over the namespace.
+	 */
+	if (!(flags & MS_KERNMOUNT) && !ns_capable(user_ns, CAP_SYS_ADMIN))
+		return ERR_PTR(-EPERM);
+
+	sb = sget(fs_type, ns_test_super, ns_set_super, flags, ns);
 	if (IS_ERR(sb))
 		return ERR_CAST(sb);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 71988dd3af95..1ce006a24f49 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2034,8 +2034,9 @@ struct file_system_type {
 
 #define MODULE_ALIAS_FS(NAME) MODULE_ALIAS("fs-" NAME)
 
-extern struct dentry *mount_ns(struct file_system_type *fs_type, int flags,
-	void *data, int (*fill_super)(struct super_block *, void *, int));
+extern struct dentry *mount_ns(struct file_system_type *fs_type,
+	int flags, void *data, void *ns, struct user_namespace *user_ns,
+	int (*fill_super)(struct super_block *, void *, int));
 extern struct dentry *mount_bdev(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data,
 	int (*fill_super)(struct super_block *, void *, int));
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index ade739f67f1d..60d97082f4dc 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -305,7 +305,7 @@ err:
 static int mqueue_fill_super(struct super_block *sb, void *data, int silent)
 {
 	struct inode *inode;
-	struct ipc_namespace *ns = data;
+	struct ipc_namespace *ns = sb->s_fs_info;
 
 	sb->s_blocksize = PAGE_SIZE;
 	sb->s_blocksize_bits = PAGE_SHIFT;
@@ -326,17 +326,14 @@ static struct dentry *mqueue_mount(struct file_system_type *fs_type,
 			 int flags, const char *dev_name,
 			 void *data)
 {
-	if (!(flags & MS_KERNMOUNT)) {
-		struct ipc_namespace *ns = current->nsproxy->ipc_ns;
-		/* Don't allow mounting unless the caller has CAP_SYS_ADMIN
-		 * over the ipc namespace.
-		 */
-		if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN))
-			return ERR_PTR(-EPERM);
-
-		data = ns;
+	struct ipc_namespace *ns;
+	if (flags & MS_KERNMOUNT) {
+		ns = data;
+		data = NULL;
+	} else {
+		ns = current->nsproxy->ipc_ns;
 	}
-	return mount_ns(fs_type, flags, data, mqueue_fill_super);
+	return mount_ns(fs_type, flags, data, ns, ns->user_ns, mqueue_fill_super);
 }
 
 static void init_once(void *foo)
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index fc48eca21fd2..84f98cbe31c3 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1386,7 +1386,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 {
 	struct inode *inode;
 	struct dentry *root, *gssd_dentry;
-	struct net *net = data;
+	struct net *net = get_net(sb->s_fs_info);
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 	int err;
 
@@ -1419,7 +1419,6 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 					   sb);
 	if (err)
 		goto err_depopulate;
-	sb->s_fs_info = get_net(net);
 	mutex_unlock(&sn->pipefs_sb_lock);
 	return 0;
 
@@ -1448,7 +1447,8 @@ static struct dentry *
 rpc_mount(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *data)
 {
-	return mount_ns(fs_type, flags, current->nsproxy->net_ns, rpc_fill_super);
+	struct net *net = current->nsproxy->net_ns;
+	return mount_ns(fs_type, flags, data, net, net->user_ns, rpc_fill_super);
 }
 
 static void rpc_kill_sb(struct super_block *sb)
@@ -1468,9 +1468,9 @@ static void rpc_kill_sb(struct super_block *sb)
 					   RPC_PIPEFS_UMOUNT,
 					   sb);
 	mutex_unlock(&sn->pipefs_sb_lock);
-	put_net(net);
 out:
 	kill_litter_super(sb);
+	put_net(net);
 }
 
 static struct file_system_type rpc_pipe_fs_type = {
-- 
2.8.3
