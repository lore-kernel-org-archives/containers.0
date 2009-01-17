From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 1/3] mqueue ns: move mqueue_mnt into struct ipc_namespace
Date: Fri, 16 Jan 2009 20:03:22 -0600
Message-ID: <20090117020322.GA8708@us.ibm.com>
References: <20090117020248.GA8615@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933719AbZAQCDm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090117020248.GA8615@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Cc: Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Move mqueue vfsmount plus a few tunables into the
ipc_namespace struct.  The CONFIG_IPC_NS boolean
and the ipc_namespace struct will serve both the
posix message queue namespaces and the SYSV ipc
namespaces.

Changelog:
	Dec 18: fix dummy fn #defines

Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/linux/ipc_namespace.h |   32 ++++++++++--
 init/Kconfig                  |    4 +-
 ipc/mqueue.c                  |  116 ++++++++++++++++++++++-------------------
 ipc/msgutil.c                 |   21 +++++++
 ipc/namespace.c               |    2 +
 ipc/util.c                    |    9 ---
 ipc/util.h                    |   15 +++++
 7 files changed, 131 insertions(+), 68 deletions(-)

diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
index ea330f9..2994eac 100644
--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -44,24 +44,48 @@ struct ipc_namespace {
 	int		shm_tot;
 
 	struct notifier_block ipcns_nb;
+
+	struct vfsmount	*mq_mnt;
+	unsigned int    mq_queues_count;
+	unsigned int    mq_queues_max;
+	unsigned int    mq_msg_max;
+	unsigned int    mq_msgsize_max;
+
 };
 
 extern struct ipc_namespace init_ipc_ns;
 extern atomic_t nr_ipc_ns;
 
-#ifdef CONFIG_SYSVIPC
+#if defined(CONFIG_POSIX_MQUEUE) || defined(CONFIG_SYSVIPC)
 #define INIT_IPC_NS(ns)		.ns		= &init_ipc_ns,
+#else
+#define INIT_IPC_NS(ns)
+#endif
 
+#ifdef CONFIG_SYSVIPC
 extern int register_ipcns_notifier(struct ipc_namespace *);
 extern int cond_register_ipcns_notifier(struct ipc_namespace *);
 extern void unregister_ipcns_notifier(struct ipc_namespace *);
 extern int ipcns_notify(unsigned long);
-
 #else /* CONFIG_SYSVIPC */
-#define INIT_IPC_NS(ns)
+#define register_ipcns_notifier(ns) (0)
+#define cond_register_ipcns_notifier(ns) (0)
+#define unregister_ipcns_notifier(ns) ((void) 0)
+#define ipcns_notify(l) (0)
 #endif /* CONFIG_SYSVIPC */
 
-#if defined(CONFIG_SYSVIPC) && defined(CONFIG_IPC_NS)
+#ifdef CONFIG_POSIX_MQUEUE
+extern void mq_init_ns(struct ipc_namespace *ns);
+/* default values */
+#define DFLT_QUEUESMAX 256     /* max number of message queues */
+#define DFLT_MSGMAX    10      /* max number of messages in each queue */
+#define HARD_MSGMAX    (131072/sizeof(void *))
+#define DFLT_MSGSIZEMAX 8192   /* max message size */
+#else
+#define mq_init_ns(ns) ((void) 0)
+#endif
+
+#if defined(CONFIG_IPC_NS)
 extern void free_ipc_ns(struct kref *kref);
 extern struct ipc_namespace *copy_ipcs(unsigned long flags,
 				       struct ipc_namespace *ns);
diff --git a/init/Kconfig b/init/Kconfig
index 0e99247..8084385 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -517,10 +517,10 @@ config UTS_NS
 
 config IPC_NS
 	bool "IPC namespace"
-	depends on NAMESPACES && SYSVIPC
+	depends on NAMESPACES && (SYSVIPC || POSIX_MQUEUE)
 	help
 	  In this namespace tasks work with IPC ids which correspond to
-	  different IPC objects in different namespaces
+	  different IPC objects in different namespaces.
 
 config USER_NS
 	bool "User namespace (EXPERIMENTAL)"
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 54b4077..50c0658 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -31,6 +31,7 @@
 #include <linux/mutex.h>
 #include <linux/nsproxy.h>
 #include <linux/pid.h>
+#include <linux/ipc_namespace.h>
 
 #include <net/sock.h>
 #include "util.h"
@@ -46,12 +47,6 @@
 #define STATE_PENDING	1
 #define STATE_READY	2
 
-/* default values */
-#define DFLT_QUEUESMAX	256	/* max number of message queues */
-#define DFLT_MSGMAX 	10	/* max number of messages in each queue */
-#define HARD_MSGMAX 	(131072/sizeof(void*))
-#define DFLT_MSGSIZEMAX 8192	/* max message size */
-
 /*
  * Define the ranges various user-specified maximum values can
  * be set to.
@@ -95,12 +90,6 @@ static void remove_notification(struct mqueue_inode_info *info);
 
 static spinlock_t mq_lock;
 static struct kmem_cache *mqueue_inode_cachep;
-static struct vfsmount *mqueue_mnt;
-
-static unsigned int queues_count;
-static unsigned int queues_max 	= DFLT_QUEUESMAX;
-static unsigned int msg_max 	= DFLT_MSGMAX;
-static unsigned int msgsize_max = DFLT_MSGSIZEMAX;
 
 static struct ctl_table_header * mq_sysctl_table;
 
@@ -109,11 +98,25 @@ static inline struct mqueue_inode_info *MQUEUE_I(struct inode *inode)
 	return container_of(inode, struct mqueue_inode_info, vfs_inode);
 }
 
+void mq_init_ns(struct ipc_namespace *ns) {
+	ns->mq_queues_count  = 0;
+	ns->mq_queues_max    = DFLT_QUEUESMAX;
+	ns->mq_msg_max       = DFLT_MSGMAX;
+	ns->mq_msgsize_max   = DFLT_MSGSIZEMAX;
+	ns->mq_mnt           = mntget(init_ipc_ns.mq_mnt);
+}
+
+void mq_exit_ns(struct ipc_namespace *ns) {
+	/* will need to clear out ns->mq_mnt->mnt_sb->s_fs_info here */
+	mntput(ns->mq_mnt);
+}
+
 static struct inode *mqueue_get_inode(struct super_block *sb, int mode,
 							struct mq_attr *attr)
 {
 	struct user_struct *u = current_user();
 	struct inode *inode;
+	struct ipc_namespace *ipc_ns = &init_ipc_ns;
 
 	inode = new_inode(sb);
 	if (inode) {
@@ -141,8 +144,8 @@ static struct inode *mqueue_get_inode(struct super_block *sb, int mode,
 			info->qsize = 0;
 			info->user = NULL;	/* set when all is ok */
 			memset(&info->attr, 0, sizeof(info->attr));
-			info->attr.mq_maxmsg = msg_max;
-			info->attr.mq_msgsize = msgsize_max;
+			info->attr.mq_maxmsg = ipc_ns->mq_msg_max;
+			info->attr.mq_msgsize = ipc_ns->mq_msgsize_max;
 			if (attr) {
 				info->attr.mq_maxmsg = attr->mq_maxmsg;
 				info->attr.mq_msgsize = attr->mq_msgsize;
@@ -242,6 +245,7 @@ static void mqueue_delete_inode(struct inode *inode)
 	struct user_struct *user;
 	unsigned long mq_bytes;
 	int i;
+	struct ipc_namespace *ipc_ns = &init_ipc_ns;
 
 	if (S_ISDIR(inode->i_mode)) {
 		clear_inode(inode);
@@ -262,7 +266,7 @@ static void mqueue_delete_inode(struct inode *inode)
 	if (user) {
 		spin_lock(&mq_lock);
 		user->mq_bytes -= mq_bytes;
-		queues_count--;
+		ipc_ns->mq_queues_count--;
 		spin_unlock(&mq_lock);
 		free_uid(user);
 	}
@@ -274,20 +278,22 @@ static int mqueue_create(struct inode *dir, struct dentry *dentry,
 	struct inode *inode;
 	struct mq_attr *attr = dentry->d_fsdata;
 	int error;
+	struct ipc_namespace *ipc_ns = &init_ipc_ns;
 
 	spin_lock(&mq_lock);
-	if (queues_count >= queues_max && !capable(CAP_SYS_RESOURCE)) {
+	if (ipc_ns->mq_queues_count >= ipc_ns->mq_queues_max &&
+			!capable(CAP_SYS_RESOURCE)) {
 		error = -ENOSPC;
 		goto out_lock;
 	}
-	queues_count++;
+	ipc_ns->mq_queues_count++;
 	spin_unlock(&mq_lock);
 
 	inode = mqueue_get_inode(dir->i_sb, mode, attr);
 	if (!inode) {
 		error = -ENOMEM;
 		spin_lock(&mq_lock);
-		queues_count--;
+		ipc_ns->mq_queues_count--;
 		goto out_lock;
 	}
 
@@ -562,7 +568,7 @@ static void remove_notification(struct mqueue_inode_info *info)
 	info->notify_owner = NULL;
 }
 
-static int mq_attr_ok(struct mq_attr *attr)
+static int mq_attr_ok(struct ipc_namespace *ipc_ns, struct mq_attr *attr)
 {
 	if (attr->mq_maxmsg <= 0 || attr->mq_msgsize <= 0)
 		return 0;
@@ -570,8 +576,8 @@ static int mq_attr_ok(struct mq_attr *attr)
 		if (attr->mq_maxmsg > HARD_MSGMAX)
 			return 0;
 	} else {
-		if (attr->mq_maxmsg > msg_max ||
-				attr->mq_msgsize > msgsize_max)
+		if (attr->mq_maxmsg > ipc_ns->mq_msg_max ||
+				attr->mq_msgsize > ipc_ns->mq_msgsize_max)
 			return 0;
 	}
 	/* check for overflow */
@@ -587,8 +593,9 @@ static int mq_attr_ok(struct mq_attr *attr)
 /*
  * Invoked when creating a new queue via sys_mq_open
  */
-static struct file *do_create(struct dentry *dir, struct dentry *dentry,
-			int oflag, mode_t mode, struct mq_attr *attr)
+static struct file *do_create(struct ipc_namespace *ipc_ns, struct dentry *dir,
+			struct dentry *dentry, int oflag, mode_t mode,
+			struct mq_attr *attr)
 {
 	const struct cred *cred = current_cred();
 	struct file *result;
@@ -596,14 +603,14 @@ static struct file *do_create(struct dentry *dir, struct dentry *dentry,
 
 	if (attr) {
 		ret = -EINVAL;
-		if (!mq_attr_ok(attr))
+		if (!mq_attr_ok(ipc_ns, attr))
 			goto out;
 		/* store for use during create */
 		dentry->d_fsdata = attr;
 	}
 
 	mode &= ~current->fs->umask;
-	ret = mnt_want_write(mqueue_mnt);
+	ret = mnt_want_write(ipc_ns->mq_mnt);
 	if (ret)
 		goto out;
 	ret = vfs_create(dir->d_inode, dentry, mode, NULL);
@@ -611,24 +618,25 @@ static struct file *do_create(struct dentry *dir, struct dentry *dentry,
 	if (ret)
 		goto out_drop_write;
 
-	result = dentry_open(dentry, mqueue_mnt, oflag, cred);
+	result = dentry_open(dentry, ipc_ns->mq_mnt, oflag, cred);
 	/*
 	 * dentry_open() took a persistent mnt_want_write(),
 	 * so we can now drop this one.
 	 */
-	mnt_drop_write(mqueue_mnt);
+	mnt_drop_write(ipc_ns->mq_mnt);
 	return result;
 
 out_drop_write:
-	mnt_drop_write(mqueue_mnt);
+	mnt_drop_write(ipc_ns->mq_mnt);
 out:
 	dput(dentry);
-	mntput(mqueue_mnt);
+	mntput(ipc_ns->mq_mnt);
 	return ERR_PTR(ret);
 }
 
 /* Opens existing queue */
-static struct file *do_open(struct dentry *dentry, int oflag)
+static struct file *do_open(struct ipc_namespace *ipc_ns,
+				struct dentry *dentry, int oflag)
 {
 	const struct cred *cred = current_cred();
 
@@ -637,17 +645,17 @@ static struct file *do_open(struct dentry *dentry, int oflag)
 
 	if ((oflag & O_ACCMODE) == (O_RDWR | O_WRONLY)) {
 		dput(dentry);
-		mntput(mqueue_mnt);
+		mntput(ipc_ns->mq_mnt);
 		return ERR_PTR(-EINVAL);
 	}
 
 	if (inode_permission(dentry->d_inode, oflag2acc[oflag & O_ACCMODE])) {
 		dput(dentry);
-		mntput(mqueue_mnt);
+		mntput(ipc_ns->mq_mnt);
 		return ERR_PTR(-EACCES);
 	}
 
-	return dentry_open(dentry, mqueue_mnt, oflag, cred);
+	return dentry_open(dentry, ipc_ns->mq_mnt, oflag, cred);
 }
 
 SYSCALL_DEFINE4(mq_open, const char __user *, u_name, int, oflag, mode_t, mode,
@@ -658,6 +666,7 @@ SYSCALL_DEFINE4(mq_open, const char __user *, u_name, int, oflag, mode_t, mode,
 	char *name;
 	struct mq_attr attr;
 	int fd, error;
+	struct ipc_namespace *ipc_ns = &init_ipc_ns;
 
 	if (u_attr && copy_from_user(&attr, u_attr, sizeof(struct mq_attr)))
 		return -EFAULT;
@@ -671,13 +680,13 @@ SYSCALL_DEFINE4(mq_open, const char __user *, u_name, int, oflag, mode_t, mode,
 	if (fd < 0)
 		goto out_putname;
 
-	mutex_lock(&mqueue_mnt->mnt_root->d_inode->i_mutex);
-	dentry = lookup_one_len(name, mqueue_mnt->mnt_root, strlen(name));
+	mutex_lock(&ipc_ns->mq_mnt->mnt_root->d_inode->i_mutex);
+	dentry = lookup_one_len(name, ipc_ns->mq_mnt->mnt_root, strlen(name));
 	if (IS_ERR(dentry)) {
 		error = PTR_ERR(dentry);
 		goto out_err;
 	}
-	mntget(mqueue_mnt);
+	mntget(ipc_ns->mq_mnt);
 
 	if (oflag & O_CREAT) {
 		if (dentry->d_inode) {	/* entry already exists */
@@ -685,10 +694,10 @@ SYSCALL_DEFINE4(mq_open, const char __user *, u_name, int, oflag, mode_t, mode,
 			error = -EEXIST;
 			if (oflag & O_EXCL)
 				goto out;
-			filp = do_open(dentry, oflag);
+			filp = do_open(ipc_ns, dentry, oflag);
 		} else {
-			filp = do_create(mqueue_mnt->mnt_root, dentry,
-						oflag, mode,
+			filp = do_create(ipc_ns, ipc_ns->mq_mnt->mnt_root,
+						dentry, oflag, mode,
 						u_attr ? &attr : NULL);
 		}
 	} else {
@@ -696,7 +705,7 @@ SYSCALL_DEFINE4(mq_open, const char __user *, u_name, int, oflag, mode_t, mode,
 		if (!dentry->d_inode)
 			goto out;
 		audit_inode(name, dentry);
-		filp = do_open(dentry, oflag);
+		filp = do_open(ipc_ns, dentry, oflag);
 	}
 
 	if (IS_ERR(filp)) {
@@ -709,13 +718,13 @@ SYSCALL_DEFINE4(mq_open, const char __user *, u_name, int, oflag, mode_t, mode,
 
 out:
 	dput(dentry);
-	mntput(mqueue_mnt);
+	mntput(ipc_ns->mq_mnt);
 out_putfd:
 	put_unused_fd(fd);
 out_err:
 	fd = error;
 out_upsem:
-	mutex_unlock(&mqueue_mnt->mnt_root->d_inode->i_mutex);
+	mutex_unlock(&ipc_ns->mq_mnt->mnt_root->d_inode->i_mutex);
 out_putname:
 	putname(name);
 	return fd;
@@ -727,14 +736,15 @@ SYSCALL_DEFINE1(mq_unlink, const char __user *, u_name)
 	char *name;
 	struct dentry *dentry;
 	struct inode *inode = NULL;
+	struct ipc_namespace *ipc_ns = &init_ipc_ns;
 
 	name = getname(u_name);
 	if (IS_ERR(name))
 		return PTR_ERR(name);
 
-	mutex_lock_nested(&mqueue_mnt->mnt_root->d_inode->i_mutex,
+	mutex_lock_nested(&ipc_ns->mq_mnt->mnt_root->d_inode->i_mutex,
 			I_MUTEX_PARENT);
-	dentry = lookup_one_len(name, mqueue_mnt->mnt_root, strlen(name));
+	dentry = lookup_one_len(name, ipc_ns->mq_mnt->mnt_root, strlen(name));
 	if (IS_ERR(dentry)) {
 		err = PTR_ERR(dentry);
 		goto out_unlock;
@@ -748,16 +758,16 @@ SYSCALL_DEFINE1(mq_unlink, const char __user *, u_name)
 	inode = dentry->d_inode;
 	if (inode)
 		atomic_inc(&inode->i_count);
-	err = mnt_want_write(mqueue_mnt);
+	err = mnt_want_write(ipc_ns->mq_mnt);
 	if (err)
 		goto out_err;
 	err = vfs_unlink(dentry->d_parent->d_inode, dentry);
-	mnt_drop_write(mqueue_mnt);
+	mnt_drop_write(ipc_ns->mq_mnt);
 out_err:
 	dput(dentry);
 
 out_unlock:
-	mutex_unlock(&mqueue_mnt->mnt_root->d_inode->i_mutex);
+	mutex_unlock(&ipc_ns->mq_mnt->mnt_root->d_inode->i_mutex);
 	putname(name);
 	if (inode)
 		iput(inode);
@@ -1212,14 +1222,14 @@ static int msg_maxsize_limit_max = MAX_MSGSIZEMAX;
 static ctl_table mq_sysctls[] = {
 	{
 		.procname	= "queues_max",
-		.data		= &queues_max,
+		.data		= &init_ipc_ns.mq_queues_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
 	{
 		.procname	= "msg_max",
-		.data		= &msg_max,
+		.data		= &init_ipc_ns.mq_msg_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
@@ -1228,7 +1238,7 @@ static ctl_table mq_sysctls[] = {
 	},
 	{
 		.procname	= "msgsize_max",
-		.data		= &msgsize_max,
+		.data		= &init_ipc_ns.mq_msgsize_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
@@ -1274,13 +1284,13 @@ static int __init init_mqueue_fs(void)
 	if (error)
 		goto out_sysctl;
 
-	if (IS_ERR(mqueue_mnt = kern_mount(&mqueue_fs_type))) {
-		error = PTR_ERR(mqueue_mnt);
+	init_ipc_ns.mq_mnt = kern_mount(&mqueue_fs_type);
+	if (IS_ERR(init_ipc_ns.mq_mnt)) {
+		error = PTR_ERR(init_ipc_ns.mq_mnt);
 		goto out_filesystem;
 	}
 
 	/* internal initialization - not common for vfs */
-	queues_count = 0;
 	spin_lock_init(&mq_lock);
 
 	return 0;
diff --git a/ipc/msgutil.c b/ipc/msgutil.c
index c82c215..c197cd1 100644
--- a/ipc/msgutil.c
+++ b/ipc/msgutil.c
@@ -13,10 +13,31 @@
 #include <linux/security.h>
 #include <linux/slab.h>
 #include <linux/ipc.h>
+#include <linux/ipc_namespace.h>
 #include <asm/uaccess.h>
 
 #include "util.h"
 
+/*
+ * The next 2 defines are here bc this is the only file
+ * compiled when either CONFIG_SYSVIPC and CONFIG_POSIX_MQUEUE
+ * and not CONFIG_IPC_NS.
+ */
+struct ipc_namespace init_ipc_ns = {
+	.kref = {
+		.refcount	= ATOMIC_INIT(2),
+	},
+#ifdef CONFIG_POSIX_MQUEUE
+	.mq_mnt          = NULL,
+	.mq_queues_count = 0,
+	.mq_queues_max   = DFLT_QUEUESMAX,
+	.mq_msg_max      = DFLT_MSGMAX,
+	.mq_msgsize_max  = DFLT_MSGSIZEMAX,
+#endif
+};
+
+atomic_t nr_ipc_ns = ATOMIC_INIT(1);
+
 struct msg_msgseg {
 	struct msg_msgseg* next;
 	/* the next part of the message follows immediately */
diff --git a/ipc/namespace.c b/ipc/namespace.c
index 9171d94..4b4dc6d 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -25,6 +25,7 @@ static struct ipc_namespace *clone_ipc_ns(struct ipc_namespace *old_ns)
 	sem_init_ns(ns);
 	msg_init_ns(ns);
 	shm_init_ns(ns);
+	mq_init_ns(ns);
 
 	/*
 	 * msgmni has already been computed for the new ipc ns.
@@ -101,6 +102,7 @@ void free_ipc_ns(struct kref *kref)
 	sem_exit_ns(ns);
 	msg_exit_ns(ns);
 	shm_exit_ns(ns);
+	mq_exit_ns(ns);
 	kfree(ns);
 	atomic_dec(&nr_ipc_ns);
 
diff --git a/ipc/util.c b/ipc/util.c
index 7585a72..b8e4ba9 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -47,15 +47,6 @@ struct ipc_proc_iface {
 	int (*show)(struct seq_file *, void *);
 };
 
-struct ipc_namespace init_ipc_ns = {
-	.kref = {
-		.refcount	= ATOMIC_INIT(2),
-	},
-};
-
-atomic_t nr_ipc_ns = ATOMIC_INIT(1);
-
-
 #ifdef CONFIG_MEMORY_HOTPLUG
 
 static void ipc_memory_notifier(struct work_struct *work)
diff --git a/ipc/util.h b/ipc/util.h
index 3646b45..9b6cc33 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -20,6 +20,13 @@ void shm_init (void);
 
 struct ipc_namespace;
 
+#ifdef CONFIG_POSIX_MQUEUE
+void mq_exit_ns(struct ipc_namespace *ns);
+#else
+#define mq_exit_ns(ns) ((void) 0)
+#endif
+
+#ifdef CONFIG_SYSVIPC
 void sem_init_ns(struct ipc_namespace *ns);
 void msg_init_ns(struct ipc_namespace *ns);
 void shm_init_ns(struct ipc_namespace *ns);
@@ -27,6 +34,14 @@ void shm_init_ns(struct ipc_namespace *ns);
 void sem_exit_ns(struct ipc_namespace *ns);
 void msg_exit_ns(struct ipc_namespace *ns);
 void shm_exit_ns(struct ipc_namespace *ns);
+#else
+#define sem_init_ns(ns) ((void) 0)
+#define msg_init_ns(ns) ((void) 0)
+#define shm_init_ns(ns) ((void) 0)
+#define sem_exit_ns(ns) ((void) 0)
+#define msg_exit_ns(ns) ((void) 0)
+#define shm_exit_ns(ns) ((void) 0)
+#endif
 
 /*
  * Structure that holds the parameters needed by the ipc operations
-- 
1.5.4.3
