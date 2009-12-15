From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] c/r mounts ns.  Except not really.
Date: Tue, 15 Dec 2009 14:19:28 -0600
Message-ID: <20091215201928.GA20037@us.ibm.com>
References: <20091215023945.GA12100@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091215023945.GA12100-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> We only c/r a mounts ns with objref 0, meaning inherit the existing
> mounts ns.  We do intend to implement c/r of mounts and mounts
> namespaces in the kernel.  It shouldn't be ugly or complicate locking
> to do so.  Just haven't gotten around to it.
> 
> Why did I bother with this?  Because we can't re-create private
> mounts yet, and while I don't expect trouble doing so, I think
> it's more than we want to take on now for v19.  But I'd like
> as much as possible for everything which we don't support, to not
> be checkpointable, since not doing so has in the past invited
> slanderous accusations of being a toy implementation  :)
> 
> Comments?
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/objhash.c           |   26 ++++++++++++++++++++++++++
>  fs/namespace.c                 |   35 +++++++++++++++++++++++++++++++++++
>  include/linux/checkpoint.h     |    2 +-
>  include/linux/checkpoint_hdr.h |   10 ++++++++++
>  include/linux/mnt_namespace.h  |    8 ++++++++
>  kernel/nsproxy.c               |   33 +++++++++++++++++++++++++++++++--
>  6 files changed, 111 insertions(+), 3 deletions(-)
> 
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index 20fd3e9..b379809 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -19,6 +19,7 @@
>  #include <linux/kref.h>
>  #include <linux/ipc_namespace.h>
>  #include <linux/user_namespace.h>
> +#include <linux/mnt_namespace.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
>  #include <net/sock.h>
> @@ -236,6 +237,22 @@ static void obj_groupinfo_drop(void *ptr, int lastref)
>  	put_group_info((struct group_info *) ptr);
>  }
> 
> +static int obj_mntns_grab(void *ptr)
> +{
> +	get_mnt_ns((struct mnt_namespace *) ptr);
> +	return 0;
> +}
> +
> +static void obj_mntns_drop(void *ptr, int lastref)
> +{
> +	put_mnt_ns((struct mnt_namespace *) ptr);
> +}
> +
> +static int obj_mntns_users(void *ptr)
> +{
> +	return atomic_read(&((struct mnt_namespace *) ptr)->count);
> +}
> +
>  static int obj_sock_grab(void *ptr)
>  {
>  	sock_hold((struct sock *) ptr);
> @@ -500,6 +517,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
>  		.checkpoint = checkpoint_lsm_string,
>  		.restore = restore_lsm_string_wrap,
>  	},
> +	{
> +		.obj_name = "MOUNTS NS",
> +		.obj_type = CKPT_OBJ_MNT_NS,
> +		.ref_grab = obj_mntns_grab,
> +		.ref_drop = obj_mntns_drop,
> +		.ref_users = obj_mntns_users,
> +		.checkpoint = checkpoint_mnt_ns,
> +		.restore = restore_mnt_ns,
> +	},
>  };
> 
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index bdc3cb4..3a61197 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -29,6 +29,7 @@
>  #include <linux/log2.h>
>  #include <linux/idr.h>
>  #include <linux/fs_struct.h>
> +#include <linux/checkpoint.h>
>  #include <asm/uaccess.h>
>  #include <asm/unistd.h>
>  #include "pnode.h"
> @@ -2323,3 +2324,37 @@ void put_mnt_ns(struct mnt_namespace *ns)
>  	kfree(ns);
>  }
>  EXPORT_SYMBOL(put_mnt_ns);
> +
> +#ifdef CONFIG_CHECKPOINT
> +int checkpoint_mounts_ns(struct ckpt_ctx *ctx, struct mnt_namespace *mnt_ns)
> +{
> +	if (mnt_ns == ctx->root_nsproxy->mnt_ns)
> +		return 0;

Technically note that this is not even correct.  If the container
being checkpointed had a mnt_ns private from its parents, then
it could have its own mounts which are not checkpointed (and therefore
can't even be generically restored by userspace).  So really this should
be returning 0 (which should be CKPT_MNT_NS_INHERIT) only if mnt_ns
== ctx->root_task->parent->nsproxy->mnt_ns (requiring more careful
dereferencing since we don't have it pinned).

Whatever we do here for v19, I intend to do the same thing for
network devices for v19.  The question is, are we being unprofessional,
or are we being useful+flexible, by simply ignoring these things at
checkpoint when we know we won't restore them?

> +	return checkpoint_obj(ctx, mnt_ns, CKPT_OBJ_MNT_NS);
> +}
> +/*
> + * c/r with private mounts namespaces is unsupported.  We'll need
> + * to also support c/r of mounts to meaningfully do so.
> + */
> +static int do_checkpoint_mnt_ns(struct ckpt_ctx *ctx,
> +				struct mnt_namespace *mnt_ns)
> +{
> +	return -EINVAL;
> +}
> +
> +int checkpoint_mnt_ns(struct ckpt_ctx *ctx, void *ptr)
> +{
> +	return do_checkpoint_mnt_ns(ctx, (struct mnt_namespace *) ptr);
> +}
> +
> +static struct mnt_namespace *do_restore_mnt_ns(struct ckpt_ctx *ctx)
> +{
> +	ckpt_err(ctx, -EINVAL, "private mounts namespace unsupported\n");
> +	return ERR_PTR(-EINVAL);
> +}
> +
> +void *restore_mnt_ns(struct ckpt_ctx *ctx)
> +{
> +	return (void *) do_restore_mnt_ns(ctx);
> +}
> +#endif
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 92d47fa..93bdbdd 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -10,7 +10,7 @@
>   *  distribution for more details.
>   */
> 
> -#define CHECKPOINT_VERSION  5
> +#define CHECKPOINT_VERSION  6
> 
>  /* checkpoint user flags */
>  #define CHECKPOINT_SUBTREE	0x1
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index f07e527..cdc6531 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -117,6 +117,8 @@ enum {
>  #define CKPT_HDR_GROUPINFO CKPT_HDR_GROUPINFO
>  	CKPT_HDR_TASK_CREDS,
>  #define CKPT_HDR_TASK_CREDS CKPT_HDR_TASK_CREDS
> +	CKPT_HDR_MNT_NS,
> +#define CKPT_HDR_MNT_NS CKPT_HDR_MNT_NS
> 
>  	/* 201-299: reserved for arch-dependent */
> 
> @@ -246,6 +248,8 @@ enum obj_type {
>  #define CKPT_OBJ_SECURITY_PTR CKPT_OBJ_SECURITY_PTR
>  	CKPT_OBJ_SECURITY,
>  #define CKPT_OBJ_SECURITY CKPT_OBJ_SECURITY
> +	CKPT_OBJ_MNT_NS,
> +#define CKPT_OBJ_MNT_NS CKPT_OBJ_MNT_NS
>  	CKPT_OBJ_MAX
>  #define CKPT_OBJ_MAX CKPT_OBJ_MAX
>  };
> @@ -428,10 +432,16 @@ struct ckpt_hdr_task_ns {
>  	__s32 ns_objref;
>  } __attribute__((aligned(8)));
> 
> +/*
> + * mnt_objref is 0 if shared with ctx->root_task->parent's mntns
> + * Come up with a better name?
> + */
> +#define CKPT_MNT_NS_INHERIT 0
>  struct ckpt_hdr_ns {
>  	struct ckpt_hdr h;
>  	__s32 uts_objref;
>  	__s32 ipc_objref;
> +	__s32 mnt_objref;
>  } __attribute__((aligned(8)));
> 
>  /* cannot include <linux/tty.h> from userspace, so define: */
> diff --git a/include/linux/mnt_namespace.h b/include/linux/mnt_namespace.h
> index d74785c..ad242bb 100644
> --- a/include/linux/mnt_namespace.h
> +++ b/include/linux/mnt_namespace.h
> @@ -32,6 +32,14 @@ static inline void get_mnt_ns(struct mnt_namespace *ns)
>  	atomic_inc(&ns->count);
>  }
> 
> +#ifdef CONFIG_CHECKPOINT
> +struct ckpt_ctx;
> +extern void *restore_mnt_ns(struct ckpt_ctx *ctx);
> +extern int checkpoint_mnt_ns(struct ckpt_ctx *ctx, void *ptr);
> +extern int checkpoint_mounts_ns(struct ckpt_ctx *ctx,
> +				struct mnt_namespace *mnt_ns);
> +#endif
> +
>  extern const struct seq_operations mounts_op;
>  extern const struct seq_operations mountinfo_op;
>  extern const struct seq_operations mountstats_op;
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index e7aaa00..c91b725 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -282,6 +282,13 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
>  		goto out;
>  	h->ipc_objref = ret;
> 
> +	ret = checkpoint_mounts_ns(ctx, nsproxy->mnt_ns);
> +	if (ret < 0) {
> +		ckpt_err(ctx, ret, "%(T)process mounts ns\n");
> +		goto out;
> +	}
> +	h->mnt_objref = ret;
> +
>  	/* TODO: Write other namespaces here */
> 
>  	ret = ckpt_write_obj(ctx, &h->h);
> @@ -302,6 +309,7 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
>  	struct nsproxy *nsproxy = NULL;
>  	struct uts_namespace *uts_ns;
>  	struct ipc_namespace *ipc_ns;
> +	struct mnt_namespace *mnt_ns = NULL;
>  	int ret;
> 
>  	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_NS);
> @@ -323,6 +331,25 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
>  		ret = PTR_ERR(ipc_ns);
>  		goto out;
>  	}
> +	if (h->mnt_objref == CKPT_MNT_NS_INHERIT)
> +		/* inherit from root task.
> +		 * XXX And right here we come upon a dilemma.  Note that by
> +		 * doing that, we wouldn't allow userspace to recreate mounts
> +		 * namespace and mounts between being cloned() and running
> +		 * sys_restart().
> +		 *
> +		 * SO, we can claim that if userspace does nothing fancy, then
> +		 * current->nsproxy->mnt_ns() will be root task mnt_ns.  If
> +		 * userspace does, then it clearly wants to set up mounts, so
> +		 * we let it.
> +		 */
> +		mnt_ns = current->nsproxy->mnt_ns;
> +	else
> +		mnt_ns = ckpt_obj_fetch(ctx, h->mnt_objref, CKPT_OBJ_MNT_NS);
> +	if (IS_ERR(mnt_ns)) {
> +		ret = PTR_ERR(mnt_ns);
> +		goto out;
> +	}
> 
>  #if defined(COFNIG_UTS_NS) || defined(CONFIG_IPC_NS)
>  	ret = -ENOMEM;
> @@ -335,10 +362,9 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
>  	get_ipc_ns(ipc_ns);
>  	nsproxy->ipc_ns = ipc_ns;
> 
> +	/* unsupported namespaces: */
>  	get_pid_ns(current->nsproxy->pid_ns);
>  	nsproxy->pid_ns = current->nsproxy->pid_ns;
> -	get_mnt_ns(current->nsproxy->mnt_ns);
> -	nsproxy->mnt_ns = current->nsproxy->mnt_ns;
>  	get_net(current->nsproxy->net_ns);
>  	nsproxy->net_ns = current->nsproxy->net_ns;
>  #else
> @@ -349,6 +375,9 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
>  	BUG_ON(nsproxy->ipc_ns != ipc_ns);
>  #endif
> 
> +	get_mnt_ns(mnt_ns);
> +	nsproxy->mnt_ns = mnt_ns;
> +
>  	/* TODO: add more namespaces here */
>  	ret = 0;
>   out:
> -- 
> 1.6.0.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
