From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] ipc namespaces: implement support for posix
	msqueues
Date: Wed, 17 Dec 2008 13:25:21 -0800
Message-ID: <20081217212521.GA14740@us.ibm.com>
References: <20081217175513.GA23291@us.ibm.com> <20081217175549.GB23331@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752693AbYLQV0l@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081217175549.GB23331@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Just a couple of nits.

Serge E. Hallyn [serue@us.ibm.com] wrote:
| Implement multiple mounts of the mqueue file system, and
| link it to usage of CLONE_NEWIPC.
| 
| Each ipc ns has a corresponding mqueuefs superblock.  When
| a user does clone(CLONE_NEWIPC) or unshare(CLONE_NEWIPC), the
| unshare will cause an internal mount of a new mqueuefs sb
| linked to the new ipc ns.
| 
| When a user does 'mount -t mqueue mqueue /dev/mqueue', he
| mounts the mqueuefs superblock.
| 
| Posix message queues can be worked with both through the
| mq_* system calls (see mq_overview(7)), and through the VFS
| through the mqueue mount.  Any usage of mq_open() and friends
| will work with the acting task's ipc namespace.  Any actions
| through the VFS will work with the mqueuefs in which the
| file was created.  So if a user doesn't remount mqueuefs
| after unshare(CLONE_NEWIPC), mq_open("/ab") will not be
| reflected in "ls /dev/mqueue".
| 
| If task a mounts mqueue for ipc_ns:1, then clones task b with
| a new ipcns, ipcns:2, and then task a is the last task in
| ipc_ns:1 to exit, then (1) ipc_ns:1 will be freed, (2) it's
| superblock will live on until task b umounts the corresponding
| mqueuefs, and vfs actions will continue to succeed, but (3)
| sb->s_fs_info will be NULL for the sb corresponding to the
| deceased ipc_ns:1.
| 
| Changelog:
| 	Dec 17: removed unused static fn (get_ipcns_from_sb)
| 
| Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
| Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
| ---
|  include/linux/ipc_namespace.h |   16 ++---
|  ipc/mqueue.c                  |  140 ++++++++++++++++++++++++++++++++---------
|  ipc/msgutil.c                 |    8 +--
|  ipc/namespace.c               |   25 ++++++--
|  ipc/util.h                    |    6 +-
|  5 files changed, 144 insertions(+), 51 deletions(-)
| 
| diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
| index 532598f..74f1ae2 100644
| --- a/include/linux/ipc_namespace.h
| +++ b/include/linux/ipc_namespace.h
| @@ -25,7 +25,7 @@ struct ipc_ids {
|  };
| 
|  struct ipc_namespace {
| -	struct kref	kref;
| +	atomic_t	count;
|  	struct ipc_ids	ids[3];
| 
|  	int		sem_ctls[4];
| @@ -56,6 +56,7 @@ struct ipc_namespace {
|  extern struct ipc_namespace init_ipc_ns;
|  extern atomic_t nr_ipc_ns;
| 
| +extern spinlock_t mq_lock;
|  #if defined(CONFIG_POSIX_MQUEUE) || defined(CONFIG_SYSVIPC)
|  #define INIT_IPC_NS(ns)		.ns		= &init_ipc_ns,
|  #else
| @@ -75,18 +76,18 @@ extern int ipcns_notify(unsigned long);
|  #endif /* CONFIG_SYSVIPC */
| 
|  #ifdef CONFIG_POSIX_MQUEUE
| -extern void mq_init_ns(struct ipc_namespace *ns);
| +extern int mq_init_ns(struct ipc_namespace *ns);
|  /* default values */
|  #define DFLT_QUEUESMAX 256     /* max number of message queues */
|  #define DFLT_MSGMAX    10      /* max number of messages in each queue */
|  #define HARD_MSGMAX    (131072/sizeof(void *))
|  #define DFLT_MSGSIZEMAX 8192   /* max message size */
|  #else
| -#define mq_init_ns(ns)
| +#define mq_init_ns(ns) (0)
|  #endif
| 
|  #if defined(CONFIG_IPC_NS)
| -extern void free_ipc_ns(struct kref *kref);
| +extern void free_ipc_ns(struct ipc_namespace *ns);
|  extern struct ipc_namespace *copy_ipcs(unsigned long flags,
|  				       struct ipc_namespace *ns);
|  extern void free_ipcs(struct ipc_namespace *ns, struct ipc_ids *ids,
| @@ -96,14 +97,11 @@ extern void free_ipcs(struct ipc_namespace *ns, struct ipc_ids *ids,
|  static inline struct ipc_namespace *get_ipc_ns(struct ipc_namespace *ns)
|  {
|  	if (ns)
| -		kref_get(&ns->kref);
| +		atomic_inc(&ns->count);
|  	return ns;
|  }
| 
| -static inline void put_ipc_ns(struct ipc_namespace *ns)
| -{
| -	kref_put(&ns->kref, free_ipc_ns);
| -}
| +extern void put_ipc_ns(struct ipc_namespace *ns);
|  #else
|  static inline struct ipc_namespace *copy_ipcs(unsigned long flags,
|  		struct ipc_namespace *ns)
| diff --git a/ipc/mqueue.c b/ipc/mqueue.c
| index 01d64a0..6b235c1 100644
| --- a/ipc/mqueue.c
| +++ b/ipc/mqueue.c
| @@ -88,7 +88,6 @@ static const struct file_operations mqueue_file_operations;
|  static struct super_operations mqueue_super_ops;
|  static void remove_notification(struct mqueue_inode_info *info);
| 
| -static spinlock_t mq_lock;
|  static struct kmem_cache *mqueue_inode_cachep;
| 
|  static struct ctl_table_header * mq_sysctl_table;
| @@ -98,25 +97,30 @@ static inline struct mqueue_inode_info *MQUEUE_I(struct inode *inode)
|  	return container_of(inode, struct mqueue_inode_info, vfs_inode);
|  }
| 
| -void mq_init_ns(struct ipc_namespace *ns) {
| -	ns->mq_queues_count  = 0;
| -	ns->mq_queues_max    = DFLT_QUEUESMAX;
| -	ns->mq_msg_max       = DFLT_MSGMAX;
| -	ns->mq_msgsize_max   = DFLT_MSGSIZEMAX;
| -	ns->mq_mnt           = mntget(init_ipc_ns.mq_mnt);
| +/*
| + * This routine should be called with the mq_lock held.
| + */
| +static inline struct ipc_namespace *__get_ns_from_ino(struct inode *inode)

Nit. Lot of places in kernel use 'ino' to represent the numeric inode number.
Maybe better to name get_ns_from_inode().

| +{
| +	return get_ipc_ns(inode->i_sb->s_fs_info);
|  }
| 
| -void mq_exit_ns(struct ipc_namespace *ns) {
| -	/* will need to clear out ns->mq_mnt->mnt_sb->s_fs_info here */
| -	mntput(ns->mq_mnt);
| +static inline struct ipc_namespace *get_ns_from_ino(struct inode *inode)


| +{
| +	struct ipc_namespace *ns;
| +
| +	spin_lock(&mq_lock);
| +	ns = __get_ns_from_ino(inode);
| +	spin_unlock(&mq_lock);
| +	return ns;
|  }
| 
| -static struct inode *mqueue_get_inode(struct super_block *sb, int mode,
| -							struct mq_attr *attr)
| +static struct inode *mqueue_get_inode(struct super_block *sb,
| +		struct ipc_namespace *ipc_ns, int mode,
| +		struct mq_attr *attr)
|  {
|  	struct user_struct *u = current_user();
|  	struct inode *inode;
| -	struct ipc_namespace *ipc_ns = &init_ipc_ns;
| 
|  	inode = new_inode(sb);
|  	if (inode) {
| @@ -192,30 +196,76 @@ out_inode:
|  static int mqueue_fill_super(struct super_block *sb, void *data, int silent)
|  {
|  	struct inode *inode;
| +	struct ipc_namespace *ns = data;
| +	int error = 0;
| 
|  	sb->s_blocksize = PAGE_CACHE_SIZE;
|  	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
|  	sb->s_magic = MQUEUE_MAGIC;
|  	sb->s_op = &mqueue_super_ops;
| 
| -	inode = mqueue_get_inode(sb, S_IFDIR | S_ISVTX | S_IRWXUGO, NULL);
| -	if (!inode)
| -		return -ENOMEM;
| +	inode = mqueue_get_inode(sb, ns, S_IFDIR | S_ISVTX | S_IRWXUGO,
| +				NULL);
| +	if (!inode) {
| +		error = -ENOMEM;
| +		goto out;
| +	}
| 
|  	sb->s_root = d_alloc_root(inode);
|  	if (!sb->s_root) {
|  		iput(inode);
| -		return -ENOMEM;
| +		error = -ENOMEM;
|  	}
| 
| -	return 0;
| +out:
| +	return error;
| +}
| +
| +static int compare_sb_single_ns(struct super_block *sb, void *data)
| +{
| +	return sb->s_fs_info == data;
| +}
| +
| +static int set_sb_single_ns(struct super_block *sb, void *data)
| +{
| +	sb->s_fs_info = data;
| +	return set_anon_super(sb, NULL);
| +}
| +
| +static int get_sb_single_ns(struct file_system_type *fs_type,
| +		int flags, void *data,
| +		int (*fill_super)(struct super_block *, void *, int),
| +		struct vfsmount *mnt)
| +{
| +	struct super_block *s;
| +	int error;
| +
| +	s = sget(fs_type, compare_sb_single_ns, set_sb_single_ns, data);
| +	if (IS_ERR(s))
| +		return PTR_ERR(s);
| +	if (!s->s_root) {
| +		s->s_flags = flags;
| +		error = fill_super(s, data, flags & MS_SILENT ? 1 : 0);
| +		if (error) {
| +			up_write(&s->s_umount);
| +			deactivate_super(s);
| +			return error;
| +		}
| +		s->s_flags |= MS_ACTIVE;
| +	}
| +	do_remount_sb(s, flags, data, 0);
| +	return simple_set_mnt(mnt, s);
|  }
| 
|  static int mqueue_get_sb(struct file_system_type *fs_type,
|  			 int flags, const char *dev_name,
|  			 void *data, struct vfsmount *mnt)
|  {
| -	return get_sb_single(fs_type, flags, data, mqueue_fill_super, mnt);
| +	if (flags & MS_KERNMOUNT)
| +		return get_sb_single_ns(fs_type, flags, data,
| +					mqueue_fill_super, mnt);
| +	return get_sb_single_ns(fs_type, flags, current->nsproxy->ipc_ns,
| +				mqueue_fill_super, mnt);

nit. This maybe easier to read with an ns local variable and a single
call to get_sb_single_ns().

Suka
