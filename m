From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 1/2] fs: Extend mount_ns with support for a fast namespace to
	vfsmount function
Date: Fri, 23 Mar 2018 16:41:40 -0500
Message-ID: <87fu4qo4ff.fsf_-___1882.03610382534$1521841242$gmane$org@xmission.com>
References: <20180323060457.sxgsd3j2obi33fyw@gordon>
	<87k1u3ti9e.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k1u3ti9e.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Fri, 23 Mar 2018 01:31:41 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


If this function is present use it to lookup up the vfsmount except
when performaning internal kernel mounts.  When performing internal
kernel mounts don't look through the list of superblocks just create a
new one.

After a quick survey it appears all callers of mount_ns are candidates
for this optimization.  So extending the generic helper appears
like the right thing.

The motivation for this change is that this optimization was performed
recently on mqueuefs and a permission check was dropped and
sb->s_user_ns was set incorrectly.

To enable fixing mqueuefs this logic was extracted from mqueuefs and
added to mount_ns which gets the permission check correct and set
sb->s_user_ns properly.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nfsd/nfsctl.c      |  3 ++-
 fs/proc/root.c        |  3 ++-
 fs/super.c            | 18 +++++++++++++++---
 include/linux/fs.h    |  1 +
 net/sunrpc/rpc_pipe.c |  2 +-
 5 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index d107b4426f7e..ffd8d91a68df 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1182,7 +1182,8 @@ static struct dentry *nfsd_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data)
 {
 	struct net *net = current->nsproxy->net_ns;
-	return mount_ns(fs_type, flags, data, net, net->user_ns, nfsd_fill_super);
+	return mount_ns(fs_type, flags, data, net, net->user_ns,
+			NULL, nfsd_fill_super);
 }
 
 static void nfsd_umount(struct super_block *sb)
diff --git a/fs/proc/root.c b/fs/proc/root.c
index ede8e64974be..4111565b6944 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -98,7 +98,8 @@ static struct dentry *proc_mount(struct file_system_type *fs_type,
 		ns = task_active_pid_ns(current);
 	}
 
-	return mount_ns(fs_type, flags, data, ns, ns->user_ns, proc_fill_super);
+	return mount_ns(fs_type, flags, data, ns, ns->user_ns,
+			NULL, proc_fill_super);
 }
 
 static void proc_kill_sb(struct super_block *sb)
diff --git a/fs/super.c b/fs/super.c
index 672538ca9831..4734d423b403 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -1016,18 +1016,30 @@ static int ns_set_super(struct super_block *sb, void *data)
 
 struct dentry *mount_ns(struct file_system_type *fs_type,
 	int flags, void *data, void *ns, struct user_namespace *user_ns,
+	struct vfsmount *(*ns_to_mnt)(void *ns),
 	int (*fill_super)(struct super_block *, void *, int))
 {
 	struct super_block *sb;
-
+	int (*test_super)(struct super_block *, void *) = ns_test_super;
 	/* Don't allow mounting unless the caller has CAP_SYS_ADMIN
 	 * over the namespace.
 	 */
 	if (!(flags & SB_KERNMOUNT) && !ns_capable(user_ns, CAP_SYS_ADMIN))
 		return ERR_PTR(-EPERM);
 
-	sb = sget_userns(fs_type, ns_test_super, ns_set_super, flags,
-			 user_ns, ns);
+	if (ns_to_mnt) {
+		test_super = NULL;
+		if (!(flags & SB_KERNMOUNT)) {
+			struct vfsmount *m = ns_to_mnt(ns);
+			if (IS_ERR(m))
+				return ERR_CAST(m);
+			atomic_inc(&m->mnt_sb->s_active);
+			down_write(&m->mnt_sb->s_umount);
+			return dget(m->mnt_root);
+		}
+	}
+
+	sb = sget_userns(fs_type, test_super, ns_set_super, flags, user_ns, ns);
 	if (IS_ERR(sb))
 		return ERR_CAST(sb);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2a815560fda0..ca7f59ff144c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2091,6 +2091,7 @@ struct file_system_type {
 
 extern struct dentry *mount_ns(struct file_system_type *fs_type,
 	int flags, void *data, void *ns, struct user_namespace *user_ns,
+	struct vfsmount *(*ns_to_mnt)(void *ns),
 	int (*fill_super)(struct super_block *, void *, int));
 #ifdef CONFIG_BLOCK
 extern struct dentry *mount_bdev(struct file_system_type *fs_type,
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index fc97fc3ed637..824e740fe740 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1448,7 +1448,7 @@ rpc_mount(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *data)
 {
 	struct net *net = current->nsproxy->net_ns;
-	return mount_ns(fs_type, flags, data, net, net->user_ns, rpc_fill_super);
+	return mount_ns(fs_type, flags, data, net, net->user_ns, NULL, rpc_fill_super);
 }
 
 static void rpc_kill_sb(struct super_block *sb)
-- 
2.14.1
