From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] ipc namespaces: implement support for posix
 msqueues
Date: Mon, 26 Jan 2009 15:28:39 -0800
Message-ID: <20090126152839.b35dbb45.akpm@linux-foundation.org>
References: <20090117020248.GA8615@us.ibm.com>
	<20090117020332.GB8708@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755485AbZAZX3u@vger.kernel.org>
In-Reply-To: <20090117020332.GB8708@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Fri, 16 Jan 2009 20:03:32 -0600
"Serge E. Hallyn" <serue@us.ibm.com> wrote:

> Implement multiple mounts of the mqueue file system, and
> link it to usage of CLONE_NEWIPC.
> 
> Each ipc ns has a corresponding mqueuefs superblock.  When
> a user does clone(CLONE_NEWIPC) or unshare(CLONE_NEWIPC), the
> unshare will cause an internal mount of a new mqueuefs sb
> linked to the new ipc ns.
> 
> When a user does 'mount -t mqueue mqueue /dev/mqueue', he
> mounts the mqueuefs superblock.
> 
> Posix message queues can be worked with both through the
> mq_* system calls (see mq_overview(7)), and through the VFS
> through the mqueue mount.  Any usage of mq_open() and friends
> will work with the acting task's ipc namespace.  Any actions
> through the VFS will work with the mqueuefs in which the
> file was created.  So if a user doesn't remount mqueuefs
> after unshare(CLONE_NEWIPC), mq_open("/ab") will not be
> reflected in "ls /dev/mqueue".
> 
> If task a mounts mqueue for ipc_ns:1, then clones task b with
> a new ipcns, ipcns:2, and then task a is the last task in
> ipc_ns:1 to exit, then (1) ipc_ns:1 will be freed, (2) it's
> superblock will live on until task b umounts the corresponding
> mqueuefs, and vfs actions will continue to succeed, but (3)
> sb->s_fs_info will be NULL for the sb corresponding to the
> deceased ipc_ns:1.

I suppose that stuff like this should find its way into a manpage one
day.  That'll be fun for someone.

>
> ...
>
> --- a/include/linux/ipc_namespace.h
> +++ b/include/linux/ipc_namespace.h
> @@ -25,7 +25,7 @@ struct ipc_ids {
>  };
>  
>  struct ipc_namespace {
> -	struct kref	kref;
> +	atomic_t	count;
>  	struct ipc_ids	ids[3];
>  
>  	int		sem_ctls[4];
> @@ -56,6 +56,7 @@ struct ipc_namespace {
>  extern struct ipc_namespace init_ipc_ns;
>  extern atomic_t nr_ipc_ns;
>  
> +extern spinlock_t mq_lock;
>  #if defined(CONFIG_POSIX_MQUEUE) || defined(CONFIG_SYSVIPC)
>  #define INIT_IPC_NS(ns)		.ns		= &init_ipc_ns,
>  #else
> @@ -75,18 +76,18 @@ extern int ipcns_notify(unsigned long);
>  #endif /* CONFIG_SYSVIPC */
>  
>  #ifdef CONFIG_POSIX_MQUEUE
> -extern void mq_init_ns(struct ipc_namespace *ns);
> +extern int mq_init_ns(struct ipc_namespace *ns);
>  /* default values */
>  #define DFLT_QUEUESMAX 256     /* max number of message queues */
>  #define DFLT_MSGMAX    10      /* max number of messages in each queue */
>  #define HARD_MSGMAX    (131072/sizeof(void *))
>  #define DFLT_MSGSIZEMAX 8192   /* max message size */
>  #else
> -#define mq_init_ns(ns) ((void) 0)
> +#define mq_init_ns(ns) (0)

argh

>  #endif
>  
>  #if defined(CONFIG_IPC_NS)
> -extern void free_ipc_ns(struct kref *kref);
> +extern void free_ipc_ns(struct ipc_namespace *ns);
>  extern struct ipc_namespace *copy_ipcs(unsigned long flags,
>  				       struct ipc_namespace *ns);
>  extern void free_ipcs(struct ipc_namespace *ns, struct ipc_ids *ids,
>
> ...
>
> +/*
> + * This routine should be called with the mq_lock held.
> + */
> +static inline struct ipc_namespace *__get_ns_from_inode(struct inode *inode)
> +{
> +	return get_ipc_ns(inode->i_sb->s_fs_info);
>  }
>  
> -void mq_exit_ns(struct ipc_namespace *ns) {
> -	/* will need to clear out ns->mq_mnt->mnt_sb->s_fs_info here */
> -	mntput(ns->mq_mnt);
> +static inline struct ipc_namespace *get_ns_from_inode(struct inode *inode)
> +{
> +	struct ipc_namespace *ns;
> +
> +	spin_lock(&mq_lock);
> +	ns = __get_ns_from_inode(inode);
> +	spin_unlock(&mq_lock);
> +	return ns;
>  }

No need for the explicit inlining here.

>
> ...
>
> +static int compare_sb_single_ns(struct super_block *sb, void *data)
> +{
> +	return sb->s_fs_info == data;
> +}
> +
> +static int set_sb_single_ns(struct super_block *sb, void *data)
> +{
> +	sb->s_fs_info = data;
> +	return set_anon_super(sb, NULL);
> +}
> +
> +static int get_sb_single_ns(struct file_system_type *fs_type,
> +		int flags, void *data,
> +		int (*fill_super)(struct super_block *, void *, int),
> +		struct vfsmount *mnt)
> +{
> +	struct super_block *s;
> +	int error;
> +
> +	s = sget(fs_type, compare_sb_single_ns, set_sb_single_ns, data);
> +	if (IS_ERR(s))
> +		return PTR_ERR(s);
> +	if (!s->s_root) {
> +		s->s_flags = flags;
> +		error = fill_super(s, data, flags & MS_SILENT ? 1 : 0);
> +		if (error) {
> +			up_write(&s->s_umount);
> +			deactivate_super(s);
> +			return error;
> +		}
> +		s->s_flags |= MS_ACTIVE;
> +	}
> +	do_remount_sb(s, flags, data, 0);
> +	return simple_set_mnt(mnt, s);
>  }

The above doesn't seem specific to mqueue.  Is it in the best place?

>  static int mqueue_get_sb(struct file_system_type *fs_type,
>  			 int flags, const char *dev_name,
>  			 void *data, struct vfsmount *mnt)
>  {
> -	return get_sb_single(fs_type, flags, data, mqueue_fill_super, mnt);
> +	struct ipc_namespace *ns = data;
> +
> +	if (!(flags & MS_KERNMOUNT))
> +		ns = current->nsproxy->ipc_ns;
> +	return get_sb_single_ns(fs_type, flags, ns, mqueue_fill_super, mnt);
>  }
>  
>  static void init_once(void *foo)
> @@ -245,12 +295,13 @@ static void mqueue_delete_inode(struct inode *inode)
>  	struct user_struct *user;
>  	unsigned long mq_bytes;
>  	int i;
> -	struct ipc_namespace *ipc_ns = &init_ipc_ns;
> +	struct ipc_namespace *ipc_ns;
>  
>  	if (S_ISDIR(inode->i_mode)) {
>  		clear_inode(inode);
>  		return;
>  	}
> +	ipc_ns = get_ns_from_inode(inode);
>  	info = MQUEUE_I(inode);
>  	spin_lock(&info->lock);
>  	for (i = 0; i < info->attr.mq_curmsgs; i++)
> @@ -266,10 +317,12 @@ static void mqueue_delete_inode(struct inode *inode)
>  	if (user) {
>  		spin_lock(&mq_lock);
>  		user->mq_bytes -= mq_bytes;
> -		ipc_ns->mq_queues_count--;
> +		if (ipc_ns)

The reader might be wondering why ipc_ns==NULL is an acceptable state,
and what that state actually means.  This reader is wondering that.

> +			ipc_ns->mq_queues_count--;
>  		spin_unlock(&mq_lock);
>  		free_uid(user);
>  	}
> +	put_ipc_ns(ipc_ns);
>  }
>  
>
> ...
>
> +int mq_init_ns(struct ipc_namespace *ns)
> +{
> +	ns->mq_queues_count  = 0;
> +	ns->mq_queues_max    = DFLT_QUEUESMAX;
> +	ns->mq_msg_max       = DFLT_MSGMAX;
> +	ns->mq_msgsize_max   = DFLT_MSGSIZEMAX;
> +
> +	ns->mq_mnt = kern_mount_data(&mqueue_fs_type, ns);
> +	if (IS_ERR(ns->mq_mnt))
> +		return PTR_ERR(ns->mq_mnt);

It seems dangerous to leave an IS_ERR() pointer sitting in ns->mq_mnt
for someone else to trip over.

> +	return 0;
> +}
> +
> +void mq_clear_sbinfo(struct ipc_namespace *ns)
> +{
> +	ns->mq_mnt->mnt_sb->s_fs_info = NULL;
> +}
> +
> +void mq_put_mnt(struct ipc_namespace *ns)
> +{
> +	mntput(ns->mq_mnt);
> +}
> +
>  static int msg_max_limit_min = MIN_MSGMAX;
>  static int msg_max_limit_max = MAX_MSGMAX;
>  
> @@ -1284,15 +1367,14 @@ static int __init init_mqueue_fs(void)
>  	if (error)
>  		goto out_sysctl;
>  
> -	init_ipc_ns.mq_mnt = kern_mount(&mqueue_fs_type);
> +	spin_lock_init(&mq_lock);
> +
> +	init_ipc_ns.mq_mnt = kern_mount_data(&mqueue_fs_type, &init_ipc_ns);
>  	if (IS_ERR(init_ipc_ns.mq_mnt)) {
>  		error = PTR_ERR(init_ipc_ns.mq_mnt);
>  		goto out_filesystem;
>  	}
>  
> -	/* internal initialization - not common for vfs */
> -	spin_lock_init(&mq_lock);
> -
>  	return 0;
>  
>  out_filesystem:
> diff --git a/ipc/msgutil.c b/ipc/msgutil.c
> index c197cd1..21475b0 100644
> --- a/ipc/msgutil.c
> +++ b/ipc/msgutil.c
> @@ -18,18 +18,16 @@
>  
>  #include "util.h"
>  
> +spinlock_t mq_lock;

DEFINE_SPINLOCK(), please.  For lockdep reasons.

>
> ...
>
> +/*
> + * put_ipc_ns - drop a reference to an ipc namespace.
> + * @ns: the namespace to put
> + *
> + * If this is the last task in the namespace exiting, and
> + * it is dropping the refcount to 0, then it can race with
> + * a task in another ipc namespace but in a mounts namespace
> + * which has this ipcns's mqueuefs mounted, doing some action
> + * with one of the mqueuefs files.  That can raise the refcount.
> + * So dropping the refcount, and raising the refcount when
> + * accessing it through the VFS, are protected with mq_lock.
> + *
> + * (Clearly, a task raising the refcount on its own ipc_ns
> + * needn't take mq_lock since it can't race with the last task
> + * in the ipcns exiting).
> + */
> +void put_ipc_ns(struct ipc_namespace *ns)
>  {
> -	struct ipc_namespace *ns;
> +	if (ns && atomic_dec_and_lock(&ns->count, &mq_lock)) {
> +		mq_clear_sbinfo(ns);
> +		spin_unlock(&mq_lock);
> +		mq_put_mnt(ns);
> +		free_ipc_ns(ns);
> +	}
> +}

Why are we supporting calls with a NULL arg here?

> -	ns = container_of(kref, struct ipc_namespace, kref);
> +void free_ipc_ns(struct ipc_namespace *ns)
> +{
>  	/*
>  	 * Unregistering the hotplug notifier at the beginning guarantees
>  	 * that the ipc namespace won't be freed while we are inside the
> @@ -102,7 +132,6 @@ void free_ipc_ns(struct kref *kref)
>  	sem_exit_ns(ns);
>  	msg_exit_ns(ns);
>  	shm_exit_ns(ns);
> -	mq_exit_ns(ns);
>  	kfree(ns);
>  	atomic_dec(&nr_ipc_ns);
>  
> diff --git a/ipc/util.h b/ipc/util.h
> index 9b6cc33..236e4ed 100644
> --- a/ipc/util.h
> +++ b/ipc/util.h
> @@ -21,9 +21,11 @@ void shm_init (void);
>  struct ipc_namespace;
>  
>  #ifdef CONFIG_POSIX_MQUEUE
> -void mq_exit_ns(struct ipc_namespace *ns);
> +extern void mq_clear_sbinfo(struct ipc_namespace *ns);
> +extern void mq_put_mnt(struct ipc_namespace *ns);
>  #else
> -#define mq_exit_ns(ns) ((void) 0)
> +#define mq_clear_sbinfo(ns) ((void) 0)
> +#define mq_put_mnt(ns) ((void) 0)

argh.

>  #endif
>  
