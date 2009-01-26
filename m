From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mqueue ns: move mqueue_mnt into struct
 ipc_namespace
Date: Mon, 26 Jan 2009 15:28:35 -0800
Message-ID: <20090126152835.c13f97d9.akpm@linux-foundation.org>
References: <20090117020248.GA8615@us.ibm.com>
	<20090117020322.GA8708@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755281AbZAZX3d@vger.kernel.org>
In-Reply-To: <20090117020322.GA8708@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Fri, 16 Jan 2009 20:03:22 -0600
"Serge E. Hallyn" <serue@us.ibm.com> wrote:

> Move mqueue vfsmount plus a few tunables into the
> ipc_namespace struct.  The CONFIG_IPC_NS boolean
> and the ipc_namespace struct will serve both the
> posix message queue namespaces and the SYSV ipc
> namespaces.
> 
>
> ...
>
> --- a/include/linux/ipc_namespace.h
> +++ b/include/linux/ipc_namespace.h
> @@ -44,24 +44,48 @@ struct ipc_namespace {
>  	int		shm_tot;
>  
>  	struct notifier_block ipcns_nb;
> +
> +	struct vfsmount	*mq_mnt;
> +	unsigned int    mq_queues_count;
> +	unsigned int    mq_queues_max;
> +	unsigned int    mq_msg_max;
> +	unsigned int    mq_msgsize_max;
> +
>  };

Some documentation for the new fields would be nice.  It should mention
the locking protocol for those fields.

>  extern struct ipc_namespace init_ipc_ns;
>  extern atomic_t nr_ipc_ns;
>  
> -#ifdef CONFIG_SYSVIPC
> +#if defined(CONFIG_POSIX_MQUEUE) || defined(CONFIG_SYSVIPC)
>  #define INIT_IPC_NS(ns)		.ns		= &init_ipc_ns,
> +#else
> +#define INIT_IPC_NS(ns)
> +#endif
>  
> +#ifdef CONFIG_SYSVIPC
>  extern int register_ipcns_notifier(struct ipc_namespace *);
>  extern int cond_register_ipcns_notifier(struct ipc_namespace *);
>  extern void unregister_ipcns_notifier(struct ipc_namespace *);
>  extern int ipcns_notify(unsigned long);
> -
>  #else /* CONFIG_SYSVIPC */
> -#define INIT_IPC_NS(ns)
> +#define register_ipcns_notifier(ns) (0)
> +#define cond_register_ipcns_notifier(ns) (0)
> +#define unregister_ipcns_notifier(ns) ((void) 0)
> +#define ipcns_notify(l) (0)

Can we use inlines here?  We get typechecking..

>  #endif /* CONFIG_SYSVIPC */
>  
> -#if defined(CONFIG_SYSVIPC) && defined(CONFIG_IPC_NS)
> +#ifdef CONFIG_POSIX_MQUEUE
> +extern void mq_init_ns(struct ipc_namespace *ns);
> +/* default values */
> +#define DFLT_QUEUESMAX 256     /* max number of message queues */
> +#define DFLT_MSGMAX    10      /* max number of messages in each queue */
> +#define HARD_MSGMAX    (131072/sizeof(void *))
> +#define DFLT_MSGSIZEMAX 8192   /* max message size */
> +#else
> +#define mq_init_ns(ns) ((void) 0)
> +#endif
> +
>
> ...
>
> +void mq_init_ns(struct ipc_namespace *ns) {
> +	ns->mq_queues_count  = 0;
> +	ns->mq_queues_max    = DFLT_QUEUESMAX;
> +	ns->mq_msg_max       = DFLT_MSGMAX;
> +	ns->mq_msgsize_max   = DFLT_MSGSIZEMAX;
> +	ns->mq_mnt           = mntget(init_ipc_ns.mq_mnt);
> +}
> +
> +void mq_exit_ns(struct ipc_namespace *ns) {
> +	/* will need to clear out ns->mq_mnt->mnt_sb->s_fs_info here */
> +	mntput(ns->mq_mnt);
> +}

You might want to ask checkpatch about this, please.

>  static struct inode *mqueue_get_inode(struct super_block *sb, int mode,
>  							struct mq_attr *attr)
>  {
>  	struct user_struct *u = current_user();
>  	struct inode *inode;
> +	struct ipc_namespace *ipc_ns = &init_ipc_ns;
>  
>  	inode = new_inode(sb);
>  	if (inode) {
> @@ -141,8 +144,8 @@ static struct inode *mqueue_get_inode(struct super_block *sb, int mode,
>  			info->qsize = 0;
>  			info->user = NULL;	/* set when all is ok */
>  			memset(&info->attr, 0, sizeof(info->attr));
> -			info->attr.mq_maxmsg = msg_max;
> -			info->attr.mq_msgsize = msgsize_max;
> +			info->attr.mq_maxmsg = ipc_ns->mq_msg_max;
> +			info->attr.mq_msgsize = ipc_ns->mq_msgsize_max;
>  			if (attr) {
>  				info->attr.mq_maxmsg = attr->mq_maxmsg;
>  				info->attr.mq_msgsize = attr->mq_msgsize;
> @@ -242,6 +245,7 @@ static void mqueue_delete_inode(struct inode *inode)
>  	struct user_struct *user;
>  	unsigned long mq_bytes;
>  	int i;
> +	struct ipc_namespace *ipc_ns = &init_ipc_ns;
>  
>  	if (S_ISDIR(inode->i_mode)) {
>  		clear_inode(inode);
> @@ -262,7 +266,7 @@ static void mqueue_delete_inode(struct inode *inode)
>  	if (user) {
>  		spin_lock(&mq_lock);
>  		user->mq_bytes -= mq_bytes;
> -		queues_count--;
> +		ipc_ns->mq_queues_count--;

ah-hah.  mqueue_lock!

>  		spin_unlock(&mq_lock);
>  		free_uid(user);
>  	}
> @@ -274,20 +278,22 @@ static int mqueue_create(struct inode *dir, struct dentry *dentry,
>  	struct inode *inode;
>  	struct mq_attr *attr = dentry->d_fsdata;
>  	int error;
> +	struct ipc_namespace *ipc_ns = &init_ipc_ns;
>  
>  	spin_lock(&mq_lock);
> -	if (queues_count >= queues_max && !capable(CAP_SYS_RESOURCE)) {
> +	if (ipc_ns->mq_queues_count >= ipc_ns->mq_queues_max &&
> +			!capable(CAP_SYS_RESOURCE)) {
>  		error = -ENOSPC;
>  		goto out_lock;
>  	}
> -	queues_count++;
> +	ipc_ns->mq_queues_count++;
>  	spin_unlock(&mq_lock);
>  
>  	inode = mqueue_get_inode(dir->i_sb, mode, attr);
>  	if (!inode) {
>  		error = -ENOMEM;
>  		spin_lock(&mq_lock);
> -		queues_count--;
> +		ipc_ns->mq_queues_count--;
>  		goto out_lock;

hm.  That should have been called out_unlock, conventionally.

>  	}
>  
> @@ -562,7 +568,7 @@ static void remove_notification(struct mqueue_inode_info *info)
>  	info->notify_owner = NULL;
>  }
>  
>
> ...
>
> @@ -1212,14 +1222,14 @@ static int msg_maxsize_limit_max = MAX_MSGSIZEMAX;
>  static ctl_table mq_sysctls[] = {
>  	{
>  		.procname	= "queues_max",
> -		.data		= &queues_max,
> +		.data		= &init_ipc_ns.mq_queues_max,
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec,
>  	},
>  	{
>  		.procname	= "msg_max",
> -		.data		= &msg_max,
> +		.data		= &init_ipc_ns.mq_msg_max,
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec_minmax,
> @@ -1228,7 +1238,7 @@ static ctl_table mq_sysctls[] = {
>  	},
>  	{
>  		.procname	= "msgsize_max",
> -		.data		= &msgsize_max,
> +		.data		= &init_ipc_ns.mq_msgsize_max,
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec_minmax,

So the sysctl has new semantics.  Some description of the designed
decisions here would be appropriate.

If I'm running in IPC namespace "foo" and I modify msg_max, it seems
that this will alter the tunable on the top-level namespace but will
leave my namespace unaltered.  Surprise?

(comes back after reading patch #3)

Ah.  This seems to have been secretly fixed in that patch?

>
> ...
>
> +/*
> + * The next 2 defines are here bc this is the only file
> + * compiled when either CONFIG_SYSVIPC and CONFIG_POSIX_MQUEUE
> + * and not CONFIG_IPC_NS.
> + */
> +struct ipc_namespace init_ipc_ns = {
> +	.kref = {
> +		.refcount	= ATOMIC_INIT(2),

2?   How come?  Needs a comment?

> +	},
> +#ifdef CONFIG_POSIX_MQUEUE
> +	.mq_mnt          = NULL,
> +	.mq_queues_count = 0,
> +	.mq_queues_max   = DFLT_QUEUESMAX,
> +	.mq_msg_max      = DFLT_MSGMAX,
> +	.mq_msgsize_max  = DFLT_MSGSIZEMAX,
> +#endif
> +};
> +
> +atomic_t nr_ipc_ns = ATOMIC_INIT(1);
> +
>  struct msg_msgseg {
>  	struct msg_msgseg* next;
>  	/* the next part of the message follows immediately */
> diff --git a/ipc/namespace.c b/ipc/namespace.c
> index 9171d94..4b4dc6d 100644
> --- a/ipc/namespace.c
> +++ b/ipc/namespace.c
> @@ -25,6 +25,7 @@ static struct ipc_namespace *clone_ipc_ns(struct ipc_namespace *old_ns)
>  	sem_init_ns(ns);
>  	msg_init_ns(ns);
>  	shm_init_ns(ns);
> +	mq_init_ns(ns);
>  
>  	/*
>  	 * msgmni has already been computed for the new ipc ns.
> @@ -101,6 +102,7 @@ void free_ipc_ns(struct kref *kref)
>  	sem_exit_ns(ns);
>  	msg_exit_ns(ns);
>  	shm_exit_ns(ns);
> +	mq_exit_ns(ns);
>  	kfree(ns);
>  	atomic_dec(&nr_ipc_ns);
>  
> diff --git a/ipc/util.c b/ipc/util.c
> index 7585a72..b8e4ba9 100644
> --- a/ipc/util.c
> +++ b/ipc/util.c
> @@ -47,15 +47,6 @@ struct ipc_proc_iface {
>  	int (*show)(struct seq_file *, void *);
>  };
>  
> -struct ipc_namespace init_ipc_ns = {
> -	.kref = {
> -		.refcount	= ATOMIC_INIT(2),

OK, I missed that last time ;)

> -	},
> -};
> -
> -atomic_t nr_ipc_ns = ATOMIC_INIT(1);
> -
> -
>  #ifdef CONFIG_MEMORY_HOTPLUG
>  
>  static void ipc_memory_notifier(struct work_struct *work)
> diff --git a/ipc/util.h b/ipc/util.h
> index 3646b45..9b6cc33 100644
> --- a/ipc/util.h
> +++ b/ipc/util.h
> @@ -20,6 +20,13 @@ void shm_init (void);
>  
>  struct ipc_namespace;
>  
> +#ifdef CONFIG_POSIX_MQUEUE
> +void mq_exit_ns(struct ipc_namespace *ns);
> +#else
> +#define mq_exit_ns(ns) ((void) 0)
> +#endif
> +
> +#ifdef CONFIG_SYSVIPC
>  void sem_init_ns(struct ipc_namespace *ns);
>  void msg_init_ns(struct ipc_namespace *ns);
>  void shm_init_ns(struct ipc_namespace *ns);
> @@ -27,6 +34,14 @@ void shm_init_ns(struct ipc_namespace *ns);
>  void sem_exit_ns(struct ipc_namespace *ns);
>  void msg_exit_ns(struct ipc_namespace *ns);
>  void shm_exit_ns(struct ipc_namespace *ns);
> +#else
> +#define sem_init_ns(ns) ((void) 0)
> +#define msg_init_ns(ns) ((void) 0)
> +#define shm_init_ns(ns) ((void) 0)
> +#define sem_exit_ns(ns) ((void) 0)
> +#define msg_exit_ns(ns) ((void) 0)
> +#define shm_exit_ns(ns) ((void) 0)

Again, could be written in C.

> +#endif
