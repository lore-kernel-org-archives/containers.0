From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 4/7] proc: Make /proc/net it's own filesystem
Date: Thu, 06 Nov 2008 02:53:08 -0800
Message-ID: <m1y6zx15yj.fsf_-_@frodo.ebiederm.org>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org>
	<m1abcd2kqk.fsf@frodo.ebiederm.org>
	<m163n12ko9.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m163n12ko9.fsf_-_-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org> (Eric W. Biederman's
	message of "Thu, 06 Nov 2008 02:49:58 -0800")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


Make the VFS happy with /proc/net by making it it's own
filesystem avoiding issues with hard links to directories
and other silliness that confuse the vfs today.

We preserve backwards compatibility by automatically
mounting /proc/self/net and marking it as a shrinkable
mount so userspace doesn't need to care about it.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/base.c              |    6 +-
 fs/proc/proc_net.c          |  212 +++++++++++++++++++++++++++++++------------
 include/linux/magic.h       |    1 +
 include/net/net_namespace.h |    1 +
 security/selinux/hooks.c    |   28 +++++-
 5 files changed, 183 insertions(+), 65 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 486cf3f..9a68fa4 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -128,6 +128,10 @@ struct pid_entry {
 	NOD(NAME, (S_IFREG|(MODE)), 			\
 		NULL, &proc_single_file_operations,	\
 		{ .proc_show = &proc_##OTYPE } )
+#define MNT(NAME, MODE, OTYPE) 				\
+	NOD(NAME, (S_IFDIR|(MODE)), 			\
+		&proc_##OTYPE##_inode_operations, NULL,	\
+		{} )
 
 /*
  * Count the number of hardlinks for the pid_entry table, excluding the .
@@ -2453,7 +2457,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 	DIR("fd",         S_IRUSR|S_IXUSR, fd),
 	DIR("fdinfo",     S_IRUSR|S_IXUSR, fdinfo),
 #ifdef CONFIG_NET
-	DIR("net",        S_IRUGO|S_IXUGO, net),
+	MNT("net",        S_IRUGO|S_IXUGO, net),
 #endif
 	REG("environ",    S_IRUSR, environ),
 	INF("auxv",       S_IRUSR, pid_auxv),
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 7bc296f..57e0f22 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -21,11 +21,13 @@
 #include <linux/smp_lock.h>
 #include <linux/mount.h>
 #include <linux/nsproxy.h>
+#include <linux/namei.h>
 #include <net/net_namespace.h>
 #include <linux/seq_file.h>
 
 #include "internal.h"
 
+static struct file_system_type proc_net_fs_type;
 
 static struct net *get_proc_net(const struct inode *inode)
 {
@@ -118,65 +120,60 @@ static struct net *get_proc_task_net(struct inode *dir)
 	return net;
 }
 
-static struct dentry *proc_tgid_net_lookup(struct inode *dir,
-		struct dentry *dentry, struct nameidata *nd)
+void *proc_net_follow_link(struct dentry *dentry, struct nameidata *nd)
 {
-	struct dentry *de;
+	/* Follow to a mount point of the proper network namespace.
+	 */
+	struct vfsmount *mnt;
 	struct net *net;
-
-	de = ERR_PTR(-ENOENT);
-	net = get_proc_task_net(dir);
-	if (net != NULL) {
-		de = proc_lookup_de(net->proc_net, dir, dentry);
-		put_net(net);
+	int err = -ENOENT;
+
+	/* Which network namespace? */
+	net = get_proc_task_net(dentry->d_inode);
+	if (!net)
+		goto out_err;
+
+	/* Create a new mount. */
+	mnt = kern_mount_data(&proc_net_fs_type, net);
+	if (IS_ERR(mnt))
+		goto out_err;
+
+	dput(nd->path.dentry);
+	nd->path.dentry = dget(dentry);
+
+	/* Add mnt the mount namespace */
+	err = do_add_mount(mntget(mnt), &nd->path, MNT_SHRINKABLE,
+			   &proc_automounts);
+	if (err < 0) {
+		mntput(mnt);
+		if (err == -EBUSY)
+			goto out_follow;
+		goto out_err;
 	}
-	return de;
-}
-
-static int proc_tgid_net_getattr(struct vfsmount *mnt, struct dentry *dentry,
-		struct kstat *stat)
-{
-	struct inode *inode = dentry->d_inode;
-	struct net *net;
-
-	net = get_proc_task_net(inode);
-
-	generic_fillattr(inode, stat);
-
-	if (net != NULL) {
-		stat->nlink = net->proc_net->nlink;
-		put_net(net);
-	}
-
-	return 0;
+	/* Place the mnt on path and return it to the caller */
+	err = 0;
+	path_put(&nd->path);
+	nd->path.mnt = mnt;
+	nd->path.dentry = dget(mnt->mnt_root);
+	put_net(net);
+out:
+	return ERR_PTR(err);
+out_err:
+	path_put(&nd->path);
+	goto out;
+out_follow:
+	/* We raced with ourselves so just walk the mounts */
+	while (d_mountpoint(nd->path.dentry) &&
+		follow_down(&nd->path.mnt, &nd->path.dentry))
+		;
+	err = 0;
+	goto out;
 }
 
 const struct inode_operations proc_net_inode_operations = {
-	.lookup		= proc_tgid_net_lookup,
-	.getattr	= proc_tgid_net_getattr,
-};
-
-static int proc_tgid_net_readdir(struct file *filp, void *dirent,
-		filldir_t filldir)
-{
-	int ret;
-	struct net *net;
-
-	ret = -EINVAL;
-	net = get_proc_task_net(filp->f_path.dentry->d_inode);
-	if (net != NULL) {
-		ret = proc_readdir_de(net->proc_net, filp, dirent, filldir);
-		put_net(net);
-	}
-	return ret;
-}
-
-const struct file_operations proc_net_operations = {
-	.read		= generic_read_dir,
-	.readdir	= proc_tgid_net_readdir,
+	.follow_link	= proc_net_follow_link,
 };
 
-
 struct proc_dir_entry *proc_net_fops_create(struct net *net,
 	const char *name, mode_t mode, const struct file_operations *fops)
 {
@@ -190,21 +187,95 @@ void proc_net_remove(struct net *net, const char *name)
 }
 EXPORT_SYMBOL_GPL(proc_net_remove);
 
+
+static int proc_net_fill_super(struct super_block *sb)
+{
+	struct net *net = sb->s_fs_info;
+	struct proc_dir_entry *netd = net->proc_net;
+	struct inode *root_inode = NULL;
+
+	sb->s_flags |= MS_NODIRATIME | MS_NOSUID | MS_NOEXEC;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
+	sb->s_magic = PROC_NET_SUPER_MAGIC;
+	sb->s_op = &proc_sops;
+	sb->s_time_gran = 1;
+
+	de_get(netd);
+	root_inode = proc_get_inode(sb, netd->low_ino, netd);
+	if (!root_inode)
+		goto out_no_root;
+	root_inode->i_uid = 0;
+	root_inode->i_gid = 0;
+	sb->s_root = d_alloc_root(root_inode);
+	if (!sb->s_root)
+		goto out_no_root;
+	return 0;
+
+out_no_root:
+	printk("%s: get root inode failed\n", __func__);
+	iput(root_inode);
+	de_put(netd);
+	return -ENOMEM;
+}
+
+static int proc_net_test_super(struct super_block *sb, void *data)
+{
+	return sb->s_fs_info == data;
+}
+
+static int proc_net_set_super(struct super_block *sb, void *data)
+{
+	sb->s_fs_info = data;
+	return set_anon_super(sb, NULL);
+}
+
+static int proc_net_get_sb(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
+{
+	struct super_block *sb;
+
+	if (!(flags & MS_KERNMOUNT))
+		data = current->nsproxy->net_ns;
+
+	sb = sget(fs_type, proc_net_test_super, proc_net_set_super, data);
+	if (IS_ERR(sb))
+		return PTR_ERR(sb);
+
+	if (!sb->s_root) {
+		int err;
+		sb->s_flags = flags;
+		err = proc_net_fill_super(sb);
+		if (err) {
+			up_write(&sb->s_umount);
+			deactivate_super(sb);
+			return err;
+		}
+
+		sb->s_flags |= MS_ACTIVE;
+	}
+
+	return simple_set_mnt(mnt, sb);
+}
+
+static struct file_system_type proc_net_fs_type = {
+	.name		= "proc/net",
+	.get_sb		= proc_net_get_sb,
+	.kill_sb	= kill_litter_super,
+};
+
 static __net_init int proc_net_ns_init(struct net *net)
 {
 	struct proc_dir_entry *netd, *net_statd;
+	struct vfsmount *mnt;
 	int err;
 
 	err = -ENOMEM;
-	netd = kzalloc(sizeof(*netd), GFP_KERNEL);
+	netd = proc_create_root();
 	if (!netd)
 		goto out;
 
 	netd->data = net;
-	netd->nlink = 2;
-	netd->name = "net";
-	netd->namelen = 3;
-	netd->parent = &proc_root;
 
 	err = -EEXIST;
 	net_statd = proc_net_mkdir(net, "stat", netd);
@@ -213,8 +284,17 @@ static __net_init int proc_net_ns_init(struct net *net)
 
 	net->proc_net = netd;
 	net->proc_net_stat = net_statd;
+
+	mnt = kern_mount_data(&proc_net_fs_type, net);
+	if (IS_ERR(mnt))
+		goto free_stat;
+
+	net->proc_mnt = mnt;
+
 	return 0;
 
+free_stat:
+	remove_proc_entry("stat", netd);
 free_net:
 	kfree(netd);
 out:
@@ -224,7 +304,14 @@ out:
 static __net_exit void proc_net_ns_exit(struct net *net)
 {
 	remove_proc_entry("stat", net->proc_net);
-	kfree(net->proc_net);
+	release_proc_entry(net->proc_net);
+	/* We won't be looking up this super block
+	 * any more so set s_fs_info to NULL to ensure
+	 * it doesn't conflict with network namespaces
+	 * allocated in the future at the same address.
+	 */
+	net->proc_mnt->mnt_sb->s_fs_info = NULL;
+	mntput(net->proc_mnt);
 }
 
 static struct pernet_operations __net_initdata proc_net_ns_ops = {
@@ -234,7 +321,16 @@ static struct pernet_operations __net_initdata proc_net_ns_ops = {
 
 int __init proc_net_init(void)
 {
-	proc_symlink("net", NULL, "self/net");
+	struct proc_dir_entry *ent;
+	int err;
+
+	ent = proc_symlink("net", NULL, "self/net");
+	if (!ent)
+		return -EEXIST;
+
+	err = register_filesystem(&proc_net_fs_type);
+	if (err)
+		return err;
 
 	return register_pernet_subsys(&proc_net_ns_ops);
 }
diff --git a/include/linux/magic.h b/include/linux/magic.h
index f7f3fdd..2b31c02 100644
--- a/include/linux/magic.h
+++ b/include/linux/magic.h
@@ -30,6 +30,7 @@
 #define NFS_SUPER_MAGIC		0x6969
 #define OPENPROM_SUPER_MAGIC	0x9fa1
 #define PROC_SUPER_MAGIC	0x9fa0
+#define PROC_NET_SUPER_MAGIC	0x706e6574
 #define QNX4_SUPER_MAGIC	0x002f		/* qnx4 fs detection */
 
 #define REISERFS_SUPER_MAGIC	0x52654973	/* used by gcc */
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 700c53a..77aba2b 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -40,6 +40,7 @@ struct net {
 
 	struct proc_dir_entry 	*proc_net;
 	struct proc_dir_entry 	*proc_net_stat;
+	struct vfsmount		*proc_mnt;
 
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_set	sysctls;
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index f85597a..b38a2df 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -667,7 +667,7 @@ static int selinux_set_mnt_opts(struct super_block *sb,
 		goto out;
 	}
 
-	if (strcmp(sb->s_type->name, "proc") == 0)
+	if (strncmp(sb->s_type->name, "proc", 4) == 0)
 		sbsec->proc = 1;
 
 	/* Determine the labeling behavior to use for this filesystem type. */
@@ -1116,16 +1116,18 @@ static inline u16 socket_type_to_security_class(int family, int type, int protoc
 }
 
 #ifdef CONFIG_PROC_FS
-static int selinux_proc_get_sid(struct proc_dir_entry *de,
+static int selinux_proc_get_sid(struct super_block *sb,
+				struct proc_dir_entry *de,
 				u16 tclass,
 				u32 *sid)
 {
 	int buflen, rc;
 	char *buffer, *path, *end;
 
+	rc = -ENOMEM;
 	buffer = (char *)__get_free_page(GFP_KERNEL);
 	if (!buffer)
-		return -ENOMEM;
+		goto out;
 
 	buflen = PAGE_SIZE;
 	end = buffer+buflen;
@@ -1136,19 +1138,32 @@ static int selinux_proc_get_sid(struct proc_dir_entry *de,
 	while (de && de != de->parent) {
 		buflen -= de->namelen + 1;
 		if (buflen < 0)
-			break;
+			goto out_free;
 		end -= de->namelen;
 		memcpy(end, de->name, de->namelen);
 		*--end = '/';
 		path = end;
 		de = de->parent;
 	}
+	if (strcmp(sb->type->name, "proc") != 0) {
+		const char *name = sb->type->name + 4;
+		int namelen = strlen(name);
+		buflen -= namelen;
+		if (buflen < 0)
+			goto out_free;
+		end -= namelen;
+		memcpy(end, name);
+		path = end;
+	}
 	rc = security_genfs_sid("proc", path, tclass, sid);
+out_free:
 	free_page((unsigned long)buffer);
+out:
 	return rc;
 }
 #else
-static int selinux_proc_get_sid(struct proc_dir_entry *de,
+static int selinux_proc_get_sid(struct super_block *sb,
+				struct proc_dir_entry *de,
 				u16 tclass,
 				u32 *sid)
 {
@@ -1297,7 +1312,8 @@ static int inode_doinit_with_dentry(struct inode *inode, struct dentry *opt_dent
 			struct proc_inode *proci = PROC_I(inode);
 			if (proci->pde) {
 				isec->sclass = inode_mode_to_security_class(inode->i_mode);
-				rc = selinux_proc_get_sid(proci->pde,
+				rc = selinux_proc_get_sid(inode->i_sb,
+							  proci->pde,
 							  isec->sclass,
 							  &sid);
 				if (rc)
-- 
1.5.3.rc6.17.g1911
