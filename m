From: Dave Hansen <dave@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mqueue ns: move mqueue_mnt into struct
	ipc_namespace
Date: Wed, 17 Dec 2008 10:36:04 -0800
Message-ID: <1229538964.17206.421.camel@nimitz>
References: <20081217175513.GA23291@us.ibm.com>
	 <20081217175531.GA23331@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752122AbYLQSgY@vger.kernel.org>
In-Reply-To: <20081217175531.GA23331@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Wed, 2008-12-17 at 11:55 -0600, Serge E. Hallyn wrote:
> Move mqueue vfsmount plus a few tunables into the
> ipc_namespace struct.  The CONFIG_IPC_NS boolean
> and the ipc_namespace struct will serve both the
> posix message queue namespaces and the SYSV ipc
> namespaces.
> 
> Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
> Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
> ---
>  include/linux/ipc_namespace.h |   32 ++++++++++--
>  init/Kconfig                  |    4 +-
>  ipc/mqueue.c                  |  116 ++++++++++++++++++++++-------------------
>  ipc/msgutil.c                 |   21 +++++++
>  ipc/namespace.c               |    2 +
>  ipc/util.c                    |    9 ---
>  ipc/util.h                    |   15 +++++
>  7 files changed, 131 insertions(+), 68 deletions(-)
> 
> diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
> index ea330f9..532598f 100644
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
> 
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
> +#define register_ipcns_notifier(ns)
> +#define cond_register_ipcns_notifier(ns)
> +#define unregister_ipcns_notifier(ns)
> +#define ipcns_notify(l)
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
> +#define mq_init_ns(ns)
> +#endif

Do all these empty suckers need do{}while(0)'s?

> +#if defined(CONFIG_IPC_NS)
>  extern void free_ipc_ns(struct kref *kref);
>  extern struct ipc_namespace *copy_ipcs(unsigned long flags,
>  				       struct ipc_namespace *ns);
> diff --git a/init/Kconfig b/init/Kconfig
> index ce75d2d..32c6315 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -489,10 +489,10 @@ config UTS_NS
> 
>  config IPC_NS
>  	bool "IPC namespace"
> -	depends on NAMESPACES && SYSVIPC
> +	depends on NAMESPACES && (SYSVIPC || POSIX_MQUEUE)
>  	help
>  	  In this namespace tasks work with IPC ids which correspond to
> -	  different IPC objects in different namespaces
> +	  different IPC objects in different namespaces.
> 
>  config USER_NS
>  	bool "User namespace (EXPERIMENTAL)"
> diff --git a/ipc/mqueue.c b/ipc/mqueue.c
> index d9393f8..01d64a0 100644
> --- a/ipc/mqueue.c
> +++ b/ipc/mqueue.c
> @@ -31,6 +31,7 @@
>  #include <linux/mutex.h>
>  #include <linux/nsproxy.h>
>  #include <linux/pid.h>
> +#include <linux/ipc_namespace.h>
> 
>  #include <net/sock.h>
>  #include "util.h"
> @@ -46,12 +47,6 @@
>  #define STATE_PENDING	1
>  #define STATE_READY	2
> 
> -/* default values */
> -#define DFLT_QUEUESMAX	256	/* max number of message queues */
> -#define DFLT_MSGMAX 	10	/* max number of messages in each queue */
> -#define HARD_MSGMAX 	(131072/sizeof(void*))
> -#define DFLT_MSGSIZEMAX 8192	/* max message size */
> -
>  /*
>   * Define the ranges various user-specified maximum values can
>   * be set to.
> @@ -95,12 +90,6 @@ static void remove_notification(struct mqueue_inode_info *info);
> 
>  static spinlock_t mq_lock;
>  static struct kmem_cache *mqueue_inode_cachep;
> -static struct vfsmount *mqueue_mnt;
> -
> -static unsigned int queues_count;
> -static unsigned int queues_max 	= DFLT_QUEUESMAX;
> -static unsigned int msg_max 	= DFLT_MSGMAX;
> -static unsigned int msgsize_max = DFLT_MSGSIZEMAX;
> 
>  static struct ctl_table_header * mq_sysctl_table;
> 
> @@ -109,11 +98,25 @@ static inline struct mqueue_inode_info *MQUEUE_I(struct inode *inode)
>  	return container_of(inode, struct mqueue_inode_info, vfs_inode);
>  }
> 
> +void mq_init_ns(struct ipc_namespace *ns) {
> +	ns->mq_queues_count  = 0;
> +	ns->mq_queues_max    = DFLT_QUEUESMAX;
> +	ns->mq_msg_max       = DFLT_MSGMAX;
> +	ns->mq_msgsize_max   = DFLT_MSGSIZEMAX;
> +	ns->mq_mnt           = mntget(init_ipc_ns.mq_mnt);
> +}

Heh, I read that as a structure definition at first!  Could you put that
bracket on a new line.

This part of the patch is nice.  The -'s are next to the +'s and it is
easy to audit.

The rest of the patch looks good.  Mostly simple substitutions, and it
is pretty obvious what is going on.

-- Dave
