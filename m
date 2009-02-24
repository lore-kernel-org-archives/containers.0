From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 2/4] mqueue ns: move mqueue_mnt into struct ipc_namespace
Date: Mon, 23 Feb 2009 21:09:14 -0600
Message-ID: <20090224030914.GA11441@us.ibm.com>
References: <20090224030347.GA10913@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755726AbZBXDJa@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090224030347.GA10913@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Move mqueue vfsmount plus a few tunables into the
ipc_namespace struct.  The CONFIG_IPC_NS boolean
and the ipc_namespace struct will serve both the
posix message queue namespaces and the SYSV ipc
namespaces.

The sysctl code will be fixed separately in patch 3.
After just this patch, making a change to posix mqueue
tunables always changes the values in the initial
ipc namespace.

Changelog:
	Feb 10: Address Andrew Morton feedback, including:
		1. turn #defines into fns for type safety
		2. document new ipc_namespace fields
	Dec 18: fix dummy fn #defines

Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/linux/ipc_namespace.h |   39 ++++++++++++-
 init/Kconfig                  |    4 +-
 ipc/mqueue.c                  |  124 ++++++++++++++++++++++------------------
 ipc/msgutil.c                 |   22 +++++++
 ipc/namespace.c               |    2 +
 ipc/util.c                    |    9 ---
 ipc/util.h                    |   16 +++++
 7 files changed, 145 insertions(+), 71 deletions(-)

diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
index ea330f9..3e6fcac 100644
--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -44,24 +44,55 @@ struct ipc_namespace {
 	int		shm_tot;
 
 	struct notifier_block ipcns_nb;
+
+	/* The kern_mount of the mqueuefs sb.  We take a ref on it */
+	struct vfsmount	*mq_mnt;
+
+	/* # queues in this ns, protected by mq_lock */
+	unsigned int    mq_queues_count;
+
+	/* next fields are set through sysctl */
+	unsigned int    mq_queues_max;   /* initialized to DFLT_QUEUESMAX */
+	unsigned int    mq_msg_max;      /* initialized to DFLT_MSGMAX */
+	unsigned int    mq_msgsize_max;  /* initialized to DFLT_MSGSIZEMAX */
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
+static inline int register_ipcns_notifier(struct ipc_namespace *ns)
+{ return 0; }
+static inline int cond_register_ipcns_notifier(struct ipc_namespace *ns)
+{ return 0; }
+static inline void unregister_ipcns_notifier(struct ipc_namespace *ns) { }
+static inline int ipcns_notify(unsigned long l) { return 0; }
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
index 0f34c50..2fd6518 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -608,10 +608,10 @@ config UTS_NS
 
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
index 54b4077..edaeeca 100644
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
 
@@ -109,11 +98,27 @@ static inline struct mqueue_inode_info *MQUEUE_I(struct inode *inode)
 	return container_of(inode, struct mqueue_inode_info, vfs_inode);
 }
 
+void mq_init_ns(struct ipc_namespace *ns)
+{
+	ns->mq_queues_count  = 0;
+	ns->mq_queues_max    = DFLT_QUEUESMAX;
+	ns->mq_msg_max       = DFLT_MSGMAX;
+	ns->mq_msgsize_max   = DFLT_MSGSIZEMAX;
+	ns->mq_mnt           = mntget(init_ipc_ns.mq_mnt);
+}
+
+void mq_exit_ns(struct ipc_namespace *ns)
+{
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
@@ -141,8 +146,8 @@ static struct inode *mqueue_get_inode(struct super_block *sb, int mode,
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
@@ -242,6 +247,7 @@ static void mqueue_delete_inode(struct inode *inode)
 	struct user_struct *user;
 	unsigned long mq_bytes;
 	int i;
+	struct ipc_namespace *ipc_ns = &init_ipc_ns;
 
 	if (S_ISDIR(inode->i_mode)) {
 		clear_inode(inode);
@@ -262,7 +268,7 @@ static void mqueue_delete_inode(struct inode *inode)
 	if (user) {
 		spin_lock(&mq_lock);
 		user->mq_bytes -= mq_bytes;
-		queues_count--;
+		ipc_ns->mq_queues_count--;
 		spin_unlock(&mq_lock);
 		free_uid(user);
 	}
@@ -274,21 +280,23 @@ static int mqueue_create(struct inode *dir, struct dentry *dentry,
 	struct inode *inode;
 	struct mq_attr *attr = dentry->d_fsdata;
 	int error;
+	struct ipc_namespace *ipc_ns = &init_ipc_ns;
 
 	spin_lock(&mq_lock);
-	if (queues_count >= queues_max && !capable(CAP_SYS_RESOURCE)) {
+	if (ipc_ns->mq_queues_count >= ipc_ns->mq_queues_max &&
+			!capable(CAP_SYS_RESOURCE)) {
 		error = -ENOSPC;
-		goto out_lock;
+		goto out_unlock;
 	}
-	queues_count++;
+	ipc_ns->mq_queues_count++;
 	spin_unlock(&mq_lock);
 
 	inode = mqueue_get_inode(dir->i_sb, mode, attr);
 	if (!inode) {
 		error = -ENOMEM;
 		spin_lock(&mq_lock);
-		queues_count--;
-		goto out_lock;
+		ipc_ns->mq_queues_count--;
+		goto out_unlock;
 	}
 
 	dir->i_size += DIRENT_SIZE;
@@ -297,7 +305,7 @@ static int mqueue_create(struct inode *dir, struct dentry *dentry,
 	d_instantiate(dentry, inode);
 	dget(dentry);
 	return 0;
-out_lock:
+out_unlock:
 	spin_unlock(&mq_lock);
 	return error;
 }
@@ -562,7 +570,7 @@ static void remove_notification(struct mqueue_inode_info *info)
 	info->notify_owner = NULL;
 }
 
-static int mq_attr_ok(struct mq_attr *attr)
+static int mq_attr_ok(struct ipc_namespace *ipc_ns, struct mq_attr *attr)
 {
 	if (attr->mq_maxmsg <= 0 || attr->mq_msgsize <= 0)
 		return 0;
@@ -570,8 +578,8 @@ static int mq_attr_ok(struct mq_attr *attr)
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
@@ -587,8 +595,9 @@ static int mq_attr_ok(struct mq_attr *attr)
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
@@ -596,14 +605,14 @@ static struct file *do_create(struct dentry *dir, struct dentry *dentry,
 
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
@@ -611,24 +620,25 @@ static struct file *do_create(struct dentry *dir, struct dentry *dentry,
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
 
@@ -637,17 +647,17 @@ static struct file *do_open(struct dentry *dentry, int oflag)
 
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
@@ -658,6 +668,7 @@ SYSCALL_DEFINE4(mq_open, const char __user *, u_name, int, oflag, mode_t, mode,
 	char *name;
 	struct mq_attr attr;
 	int fd, error;
+	struct ipc_namespace *ipc_ns = &init_ipc_ns;
 
 	if (u_attr && copy_from_user(&attr, u_attr, sizeof(struct mq_attr)))
 		return -EFAULT;
@@ -671,13 +682,13 @@ SYSCALL_DEFINE4(mq_open, const char __user *, u_name, int, oflag, mode_t, mode,
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
@@ -685,10 +696,10 @@ SYSCALL_DEFINE4(mq_open, const char __user *, u_name, int, oflag, mode_t, mode,
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
@@ -696,7 +707,7 @@ SYSCALL_DEFINE4(mq_open, const char __user *, u_name, int, oflag, mode_t, mode,
 		if (!dentry->d_inode)
 			goto out;
 		audit_inode(name, dentry);
-		filp = do_open(dentry, oflag);
+		filp = do_open(ipc_ns, dentry, oflag);
 	}
 
 	if (IS_ERR(filp)) {
@@ -709,13 +720,13 @@ SYSCALL_DEFINE4(mq_open, const char __user *, u_name, int, oflag, mode_t, mode,
 
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
@@ -727,14 +738,15 @@ SYSCALL_DEFINE1(mq_unlink, const char __user *, u_name)
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
@@ -748,16 +760,16 @@ SYSCALL_DEFINE1(mq_unlink, const char __user *, u_name)
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
@@ -1212,14 +1224,14 @@ static int msg_maxsize_limit_max = MAX_MSGSIZEMAX;
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
@@ -1228,7 +1240,7 @@ static ctl_table mq_sysctls[] = {
 	},
 	{
 		.procname	= "msgsize_max",
-		.data		= &msgsize_max,
+		.data		= &init_ipc_ns.mq_msgsize_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
@@ -1274,13 +1286,13 @@ static int __init init_mqueue_fs(void)
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
index c82c215..73c316c 100644
--- a/ipc/msgutil.c
+++ b/ipc/msgutil.c
@@ -13,10 +13,32 @@
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
+		/* It's not for this patch to change, but should this be 1? */
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
index 3646b45..0e7d922 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -20,6 +20,13 @@ void shm_init (void);
 
 struct ipc_namespace;
 
+#ifdef CONFIG_POSIX_MQUEUE
+void mq_exit_ns(struct ipc_namespace *ns);
+#else
+static inline void mq_exit_ns(struct ipc_namespace *ns) { }
+#endif
+
+#ifdef CONFIG_SYSVIPC
 void sem_init_ns(struct ipc_namespace *ns);
 void msg_init_ns(struct ipc_namespace *ns);
 void shm_init_ns(struct ipc_namespace *ns);
@@ -27,6 +34,15 @@ void shm_init_ns(struct ipc_namespace *ns);
 void sem_exit_ns(struct ipc_namespace *ns);
 void msg_exit_ns(struct ipc_namespace *ns);
 void shm_exit_ns(struct ipc_namespace *ns);
+#else
+static inline void sem_init_ns(struct ipc_namespace *ns) { }
+static inline void msg_init_ns(struct ipc_namespace *ns) { }
+static inline void shm_init_ns(struct ipc_namespace *ns) { }
+
+static inline void sem_exit_ns(struct ipc_namespace *ns) { }
+static inline void msg_exit_ns(struct ipc_namespace *ns) { }
+static inline void shm_exit_ns(struct ipc_namespace *ns) { }
+#endif
 
 /*
  * Structure that holds the parameters needed by the ipc operations
-- 
1.5.4.3
