From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 16/16] proc: Usable inode numbers for the namespace
	file descriptors.
Date: Mon, 19 Nov 2012 07:12:41 -0800
Message-ID: <1353337961-12962-16-git-send-email-ebiederm@xmission.com>
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

Assign a unique proc inode to each namespace, and use that
inode number to ensure we only allocate at most one proc
inode for every namespace in proc.

A single proc inode per namespace allows userspace to test
to see if two processes are in the same namespace.

This has been a long requested feature and only blocked because
a naive implementation would put the id in a global space and
would ultimately require having a namespace for the names of
namespaces, making migration and certain virtualization tricks
impossible.

We still don't have per superblock inode numbers for proc, which
appears necessary for application unaware checkpoint/restart and
migrations (if the application is using namespace file descriptors)
but that is now allowd by the design if it becomes important.

I have preallocated the ipc and uts initial proc inode numbers so
their structures can be statically initialized.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/mount.h                     |    1 +
 fs/namespace.c                 |   14 ++++++++++++++
 fs/proc/namespaces.c           |   24 ++++++++++++++----------
 include/linux/ipc_namespace.h  |    2 ++
 include/linux/pid_namespace.h  |    1 +
 include/linux/proc_fs.h        |    7 ++++++-
 include/linux/user_namespace.h |    1 +
 include/linux/utsname.h        |    1 +
 include/net/net_namespace.h    |    2 ++
 init/version.c                 |    2 ++
 ipc/msgutil.c                  |    2 ++
 ipc/namespace.c                |   16 ++++++++++++++++
 kernel/pid.c                   |    1 +
 kernel/pid_namespace.c         |   12 ++++++++++++
 kernel/user.c                  |    2 ++
 kernel/user_namespace.c        |   15 +++++++++++++++
 kernel/utsname.c               |   17 ++++++++++++++++-
 net/core/net_namespace.c       |   24 ++++++++++++++++++++++++
 18 files changed, 132 insertions(+), 12 deletions(-)

diff --git a/fs/mount.h b/fs/mount.h
index 630fafc..cd50079 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -4,6 +4,7 @@
 
 struct mnt_namespace {
 	atomic_t		count;
+	unsigned int		proc_inum;
 	struct mount *	root;
 	struct list_head	list;
 	struct user_namespace	*user_ns;
diff --git a/fs/namespace.c b/fs/namespace.c
index cab78a7..c1bbe86 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2301,6 +2301,7 @@ dput_out:
 
 static void free_mnt_ns(struct mnt_namespace *ns)
 {
+	proc_free_inum(ns->proc_inum);
 	put_user_ns(ns->user_ns);
 	kfree(ns);
 }
@@ -2317,10 +2318,16 @@ static atomic64_t mnt_ns_seq = ATOMIC64_INIT(1);
 static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *user_ns)
 {
 	struct mnt_namespace *new_ns;
+	int ret;
 
 	new_ns = kmalloc(sizeof(struct mnt_namespace), GFP_KERNEL);
 	if (!new_ns)
 		return ERR_PTR(-ENOMEM);
+	ret = proc_alloc_inum(&new_ns->proc_inum);
+	if (ret) {
+		kfree(new_ns);
+		return ERR_PTR(ret);
+	}
 	new_ns->seq = atomic64_add_return(1, &mnt_ns_seq);
 	atomic_set(&new_ns->count, 1);
 	new_ns->root = NULL;
@@ -2799,10 +2806,17 @@ static int mntns_install(struct nsproxy *nsproxy, void *ns)
 	return 0;
 }
 
+static unsigned int mntns_inum(void *ns)
+{
+	struct mnt_namespace *mnt_ns = ns;
+	return mnt_ns->proc_inum;
+}
+
 const struct proc_ns_operations mntns_operations = {
 	.name		= "mnt",
 	.type		= CLONE_NEWNS,
 	.get		= mntns_get,
 	.put		= mntns_put,
 	.install	= mntns_install,
+	.inum		= mntns_inum,
 };
diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
index 7a6d8d6..b7a4719 100644
--- a/fs/proc/namespaces.c
+++ b/fs/proc/namespaces.c
@@ -82,7 +82,7 @@ static struct dentry *proc_ns_get_dentry(struct super_block *sb,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	inode = new_inode(sb);
+	inode = iget_locked(sb, ns_ops->inum(ns));
 	if (!inode) {
 		dput(dentry);
 		ns_ops->put(ns);
@@ -90,13 +90,17 @@ static struct dentry *proc_ns_get_dentry(struct super_block *sb,
 	}
 
 	ei = PROC_I(inode);
-	inode->i_ino = get_next_ino();
-	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
-	inode->i_op = &ns_inode_operations;
-	inode->i_mode = S_IFREG | S_IRUGO;
-	inode->i_fop = &ns_file_operations;
-	ei->ns_ops = ns_ops;
-	ei->ns = ns;
+	if (inode->i_state & I_NEW) {
+		inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+		inode->i_op = &ns_inode_operations;
+		inode->i_mode = S_IFREG | S_IRUGO;
+		inode->i_fop = &ns_file_operations;
+		ei->ns_ops = ns_ops;
+		ei->ns = ns;
+		unlock_new_inode(inode);
+	} else {
+		ns_ops->put(ns);
+	}
 
 	d_set_d_op(dentry, &ns_dentry_operations);
 	result = d_instantiate_unique(dentry, inode);
@@ -162,12 +166,12 @@ static int proc_ns_readlink(struct dentry *dentry, char __user *buffer, int bufl
 	if (!ns)
 		goto out_put_task;
 
-	snprintf(name, sizeof(name), "%s", ns_ops->name);
+	snprintf(name, sizeof(name), "%s:[%u]", ns_ops->name, ns_ops->inum(ns));
 	len = strlen(name);
 
 	if (len > buflen)
 		len = buflen;
-	if (copy_to_user(buffer, ns_ops->name, len))
+	if (copy_to_user(buffer, name, len))
 		len = -EFAULT;
 
 	ns_ops->put(ns);
diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
index f03af70..fe77197 100644
--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -67,6 +67,8 @@ struct ipc_namespace {
 
 	/* user_ns which owns the ipc ns */
 	struct user_namespace *user_ns;
+
+	unsigned int	proc_inum;
 };
 
 extern struct ipc_namespace init_ipc_ns;
diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index 4c96acd..bf28599 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -37,6 +37,7 @@ struct pid_namespace {
 	kgid_t pid_gid;
 	int hide_pid;
 	int reboot;	/* group exit code if this pidns was rebooted */
+	unsigned int proc_inum;
 };
 
 extern struct pid_namespace init_pid_ns;
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index bf1d000..2e24018 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -28,7 +28,11 @@ struct mm_struct;
  */
 
 enum {
-	PROC_ROOT_INO = 1,
+	PROC_ROOT_INO		= 1,
+	PROC_IPC_INIT_INO	= 0xEFFFFFFFU,
+	PROC_UTS_INIT_INO	= 0xEFFFFFFEU,
+	PROC_USER_INIT_INO	= 0xEFFFFFFDU,
+	PROC_PID_INIT_INO	= 0xEFFFFFFCU,
 };
 
 /*
@@ -263,6 +267,7 @@ struct proc_ns_operations {
 	void *(*get)(struct task_struct *task);
 	void (*put)(void *ns);
 	int (*install)(struct nsproxy *nsproxy, void *ns);
+	unsigned int (*inum)(void *ns);
 };
 extern const struct proc_ns_operations netns_operations;
 extern const struct proc_ns_operations utsns_operations;
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 17651f0..b9bd2e6 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -25,6 +25,7 @@ struct user_namespace {
 	struct user_namespace	*parent;
 	kuid_t			owner;
 	kgid_t			group;
+	unsigned int		proc_inum;
 };
 
 extern struct user_namespace init_user_ns;
diff --git a/include/linux/utsname.h b/include/linux/utsname.h
index 221f4a0..239e277 100644
--- a/include/linux/utsname.h
+++ b/include/linux/utsname.h
@@ -23,6 +23,7 @@ struct uts_namespace {
 	struct kref kref;
 	struct new_utsname name;
 	struct user_namespace *user_ns;
+	unsigned int proc_inum;
 };
 extern struct uts_namespace init_uts_ns;
 
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index c5a43f5..de644bc 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -56,6 +56,8 @@ struct net {
 
 	struct user_namespace   *user_ns;	/* Owning user namespace */
 
+	unsigned int		proc_inum;
+
 	struct proc_dir_entry 	*proc_net;
 	struct proc_dir_entry 	*proc_net_stat;
 
diff --git a/init/version.c b/init/version.c
index 86fe0cc..58170f1 100644
--- a/init/version.c
+++ b/init/version.c
@@ -12,6 +12,7 @@
 #include <linux/utsname.h>
 #include <generated/utsrelease.h>
 #include <linux/version.h>
+#include <linux/proc_fs.h>
 
 #ifndef CONFIG_KALLSYMS
 #define version(a) Version_ ## a
@@ -34,6 +35,7 @@ struct uts_namespace init_uts_ns = {
 		.domainname	= UTS_DOMAINNAME,
 	},
 	.user_ns = &init_user_ns,
+	.proc_inum = PROC_UTS_INIT_INO,
 };
 EXPORT_SYMBOL_GPL(init_uts_ns);
 
diff --git a/ipc/msgutil.c b/ipc/msgutil.c
index 26143d3..6471f1b 100644
--- a/ipc/msgutil.c
+++ b/ipc/msgutil.c
@@ -16,6 +16,7 @@
 #include <linux/msg.h>
 #include <linux/ipc_namespace.h>
 #include <linux/utsname.h>
+#include <linux/proc_fs.h>
 #include <asm/uaccess.h>
 
 #include "util.h"
@@ -30,6 +31,7 @@ DEFINE_SPINLOCK(mq_lock);
 struct ipc_namespace init_ipc_ns = {
 	.count		= ATOMIC_INIT(1),
 	.user_ns = &init_user_ns,
+	.proc_inum = PROC_IPC_INIT_INO,
 };
 
 atomic_t nr_ipc_ns = ATOMIC_INIT(1);
diff --git a/ipc/namespace.c b/ipc/namespace.c
index 72c8682..cf3386a 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -26,9 +26,16 @@ static struct ipc_namespace *create_ipc_ns(struct user_namespace *user_ns,
 	if (ns == NULL)
 		return ERR_PTR(-ENOMEM);
 
+	err = proc_alloc_inum(&ns->proc_inum);
+	if (err) {
+		kfree(ns);
+		return ERR_PTR(err);
+	}
+
 	atomic_set(&ns->count, 1);
 	err = mq_init_ns(ns);
 	if (err) {
+		proc_free_inum(ns->proc_inum);
 		kfree(ns);
 		return ERR_PTR(err);
 	}
@@ -111,6 +118,7 @@ static void free_ipc_ns(struct ipc_namespace *ns)
 	 */
 	ipcns_notify(IPCNS_REMOVED);
 	put_user_ns(ns->user_ns);
+	proc_free_inum(ns->proc_inum);
 	kfree(ns);
 }
 
@@ -172,10 +180,18 @@ static int ipcns_install(struct nsproxy *nsproxy, void *new)
 	return 0;
 }
 
+static unsigned int ipcns_inum(void *vp)
+{
+	struct ipc_namespace *ns = vp;
+
+	return ns->proc_inum;
+}
+
 const struct proc_ns_operations ipcns_operations = {
 	.name		= "ipc",
 	.type		= CLONE_NEWIPC,
 	.get		= ipcns_get,
 	.put		= ipcns_put,
 	.install	= ipcns_install,
+	.inum		= ipcns_inum,
 };
diff --git a/kernel/pid.c b/kernel/pid.c
index 6e8da29..3026dda 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -80,6 +80,7 @@ struct pid_namespace init_pid_ns = {
 	.level = 0,
 	.child_reaper = &init_task,
 	.user_ns = &init_user_ns,
+	.proc_inum = PROC_PID_INIT_INO,
 };
 EXPORT_SYMBOL_GPL(init_pid_ns);
 
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index 68508d3..560da0d 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -107,6 +107,10 @@ static struct pid_namespace *create_pid_namespace(struct user_namespace *user_ns
 	if (ns->pid_cachep == NULL)
 		goto out_free_map;
 
+	err = proc_alloc_inum(&ns->proc_inum);
+	if (err)
+		goto out_free_map;
+
 	kref_init(&ns->kref);
 	ns->level = level;
 	ns->parent = get_pid_ns(parent_pid_ns);
@@ -133,6 +137,7 @@ static void destroy_pid_namespace(struct pid_namespace *ns)
 {
 	int i;
 
+	proc_free_inum(ns->proc_inum);
 	for (i = 0; i < PIDMAP_ENTRIES; i++)
 		kfree(ns->pidmap[i].page);
 	put_user_ns(ns->user_ns);
@@ -345,12 +350,19 @@ static int pidns_install(struct nsproxy *nsproxy, void *ns)
 	return 0;
 }
 
+static unsigned int pidns_inum(void *ns)
+{
+	struct pid_namespace *pid_ns = ns;
+	return pid_ns->proc_inum;
+}
+
 const struct proc_ns_operations pidns_operations = {
 	.name		= "pid",
 	.type		= CLONE_NEWPID,
 	.get		= pidns_get,
 	.put		= pidns_put,
 	.install	= pidns_install,
+	.inum		= pidns_inum,
 };
 
 static __init int pid_namespaces_init(void)
diff --git a/kernel/user.c b/kernel/user.c
index 750acff..33acb5e 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -16,6 +16,7 @@
 #include <linux/interrupt.h>
 #include <linux/export.h>
 #include <linux/user_namespace.h>
+#include <linux/proc_fs.h>
 
 /*
  * userns count is 1 for root user, 1 for init_uts_ns,
@@ -51,6 +52,7 @@ struct user_namespace init_user_ns = {
 	},
 	.owner = GLOBAL_ROOT_UID,
 	.group = GLOBAL_ROOT_GID,
+	.proc_inum = PROC_USER_INIT_INO,
 };
 EXPORT_SYMBOL_GPL(init_user_ns);
 
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 89f6eae..f5975cc 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -58,6 +58,7 @@ int create_user_ns(struct cred *new)
 	struct user_namespace *ns, *parent_ns = new->user_ns;
 	kuid_t owner = new->euid;
 	kgid_t group = new->egid;
+	int ret;
 
 	/* The creator needs a mapping in the parent user namespace
 	 * or else we won't be able to reasonably tell userspace who
@@ -71,6 +72,12 @@ int create_user_ns(struct cred *new)
 	if (!ns)
 		return -ENOMEM;
 
+	ret = proc_alloc_inum(&ns->proc_inum);
+	if (ret) {
+		kmem_cache_free(user_ns_cachep, ns);
+		return ret;
+	}
+
 	kref_init(&ns->kref);
 	/* Leave the new->user_ns reference with the new user namespace. */
 	ns->parent = parent_ns;
@@ -103,6 +110,7 @@ void free_user_ns(struct kref *kref)
 		container_of(kref, struct user_namespace, kref);
 
 	parent = ns->parent;
+	proc_free_inum(ns->proc_inum);
 	kmem_cache_free(user_ns_cachep, ns);
 	put_user_ns(parent);
 }
@@ -808,12 +816,19 @@ static int userns_install(struct nsproxy *nsproxy, void *ns)
 	return commit_creds(cred);
 }
 
+static unsigned int userns_inum(void *ns)
+{
+	struct user_namespace *user_ns = ns;
+	return user_ns->proc_inum;
+}
+
 const struct proc_ns_operations userns_operations = {
 	.name		= "user",
 	.type		= CLONE_NEWUSER,
 	.get		= userns_get,
 	.put		= userns_put,
 	.install	= userns_install,
+	.inum		= userns_inum,
 };
 
 static __init int user_namespaces_init(void)
diff --git a/kernel/utsname.c b/kernel/utsname.c
index fdc619e..f6336d5 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -36,11 +36,18 @@ static struct uts_namespace *clone_uts_ns(struct user_namespace *user_ns,
 					  struct uts_namespace *old_ns)
 {
 	struct uts_namespace *ns;
+	int err;
 
 	ns = create_uts_ns();
 	if (!ns)
 		return ERR_PTR(-ENOMEM);
 
+	err = proc_alloc_inum(&ns->proc_inum);
+	if (err) {
+		kfree(ns);
+		return ERR_PTR(err);
+	}
+
 	down_read(&uts_sem);
 	memcpy(&ns->name, &old_ns->name, sizeof(ns->name));
 	ns->user_ns = get_user_ns(user_ns);
@@ -77,6 +84,7 @@ void free_uts_ns(struct kref *kref)
 
 	ns = container_of(kref, struct uts_namespace, kref);
 	put_user_ns(ns->user_ns);
+	proc_free_inum(ns->proc_inum);
 	kfree(ns);
 }
 
@@ -114,11 +122,18 @@ static int utsns_install(struct nsproxy *nsproxy, void *new)
 	return 0;
 }
 
+static unsigned int utsns_inum(void *vp)
+{
+	struct uts_namespace *ns = vp;
+
+	return ns->proc_inum;
+}
+
 const struct proc_ns_operations utsns_operations = {
 	.name		= "uts",
 	.type		= CLONE_NEWUTS,
 	.get		= utsns_get,
 	.put		= utsns_put,
 	.install	= utsns_install,
+	.inum		= utsns_inum,
 };
-
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index ec2870b..2e9a313 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -381,6 +381,21 @@ struct net *get_net_ns_by_pid(pid_t pid)
 }
 EXPORT_SYMBOL_GPL(get_net_ns_by_pid);
 
+static __net_init int net_ns_net_init(struct net *net)
+{
+	return proc_alloc_inum(&net->proc_inum);
+}
+
+static __net_exit void net_ns_net_exit(struct net *net)
+{
+	proc_free_inum(net->proc_inum);
+}
+
+static struct pernet_operations __net_initdata net_ns_ops = {
+	.init = net_ns_net_init,
+	.exit = net_ns_net_exit,
+};
+
 static int __init net_ns_init(void)
 {
 	struct net_generic *ng;
@@ -412,6 +427,8 @@ static int __init net_ns_init(void)
 
 	mutex_unlock(&net_mutex);
 
+	register_pernet_subsys(&net_ns_ops);
+
 	return 0;
 }
 
@@ -640,11 +657,18 @@ static int netns_install(struct nsproxy *nsproxy, void *ns)
 	return 0;
 }
 
+static unsigned int netns_inum(void *ns)
+{
+	struct net *net = ns;
+	return net->proc_inum;
+}
+
 const struct proc_ns_operations netns_operations = {
 	.name		= "net",
 	.type		= CLONE_NEWNET,
 	.get		= netns_get,
 	.put		= netns_put,
 	.install	= netns_install,
+	.inum		= netns_inum,
 };
 #endif
-- 
1.7.5.4
