From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Preliminary and minimal c/r of mounts namespace
Date: Mon, 25 Jan 2010 23:48:01 -0600
Message-ID: <20100126054801.GC27763@us.ibm.com>
References: <1264480647-30375-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1264480647-30375-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> We only allow c/r when all processes shared a single mounts ns.
> 
> We do intend to implement c/r of mounts and mounts namespaces in the
> kernel.  It shouldn't be ugly or complicate locking to do so.  Just
> haven't gotten around to it. A more complete solution is more than we
> want to take on now for v19.
> 
> But we'd like as much as possible for everything which we don't
> support, to not be checkpointable, since not doing so has in the past
> invited slanderous accusations of being a toy implementation :)
> 
> Meanwhile, we get the following:
> 1) Checkpoint bails if not all tasks share the same mnt-ns
> 2) Leak detection works for full container checkpoint
> 
> On restart, all tasks inherit the same mnt-ns of the coordinator, by
> default. A follow-up patch to user-cr will add a new switch to the
> 'restart' to request a CLONE_NEWMNT flag when creating the root-task
> of the restart.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Looks good.

thanks,
-serge

> ---
>  checkpoint/objhash.c           |   25 +++++++++++++++++++++++++
>  include/linux/checkpoint.h     |    2 +-
>  include/linux/checkpoint_hdr.h |    4 ++++
>  kernel/nsproxy.c               |   19 +++++++++++++++----
>  4 files changed, 45 insertions(+), 5 deletions(-)
> 
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index 295d02d..d689d66 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -20,6 +20,7 @@
>  #include <linux/kref.h>
>  #include <linux/ipc_namespace.h>
>  #include <linux/user_namespace.h>
> +#include <linux/mnt_namespace.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
>  #include <net/sock.h>
> @@ -221,6 +222,22 @@ static int obj_cred_grab(void *ptr)
>  	return 0;
>  }
> 
> +static int obj_mnt_ns_grab(void *ptr)
> +{
> +	get_mnt_ns((struct mnt_namespace *) ptr);
> +	return 0;
> +}
> +
> +static void obj_mnt_ns_drop(void *ptr, int lastref)
> +{
> +	put_mnt_ns((struct mnt_namespace *) ptr);
> +}
> +
> +static int obj_mnt_ns_users(void *ptr)
> +{
> +	return atomic_read(&((struct mnt_namespace *) ptr)->count);
> +}
> +
>  static void obj_cred_drop(void *ptr, int lastref)
>  {
>  	put_cred((struct cred *) ptr);
> @@ -442,6 +459,14 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
>  		.checkpoint = checkpoint_ipc_ns,
>  		.restore = restore_ipc_ns,
>  	},
> +	/* mnt_ns object */
> +	{
> +		.obj_name = "MOUNTS NS",
> +		.obj_type = CKPT_OBJ_MNT_NS,
> +		.ref_grab = obj_mnt_ns_grab,
> +		.ref_drop = obj_mnt_ns_drop,
> +		.ref_users = obj_mnt_ns_users,
> +	},
>  	/* user_ns object */
>  	{
>  		.obj_name = "USER_NS",
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index b2cbd30..616795c 100644
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
> index 53ae8bf..343f737 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -103,6 +103,8 @@ enum {
>  #define CKPT_HDR_UTS_NS CKPT_HDR_UTS_NS
>  	CKPT_HDR_IPC_NS,
>  #define CKPT_HDR_IPC_NS CKPT_HDR_IPC_NS
> +	CKPT_HDR_MNT_NS,
> +#define CKPT_HDR_MNT_NS CKPT_HDR_MNT_NS
>  	CKPT_HDR_CAPABILITIES,
>  #define CKPT_HDR_CAPABILITIES CKPT_HDR_CAPABILITIES
>  	CKPT_HDR_USER_NS,
> @@ -233,6 +235,8 @@ enum obj_type {
>  #define CKPT_OBJ_UTS_NS CKPT_OBJ_UTS_NS
>  	CKPT_OBJ_IPC_NS,
>  #define CKPT_OBJ_IPC_NS CKPT_OBJ_IPC_NS
> +	CKPT_OBJ_MNT_NS,
> +#define CKPT_OBJ_MNT_NS CKPT_OBJ_MNT_NS
>  	CKPT_OBJ_USER_NS,
>  #define CKPT_OBJ_USER_NS CKPT_OBJ_USER_NS
>  	CKPT_OBJ_CRED,
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index 7a513a6..35089cb 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -255,10 +255,17 @@ int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
>  	 * ipc_ns (shm) may keep references to files: if this is the
>  	 * first time we see this ipc_ns (ret > 0), proceed inside.
>  	 */
> -	if (ret)
> +	if (ret) {
>  		ret = ckpt_collect_ipc_ns(ctx, nsproxy->ipc_ns);
> +		if (ret < 0)
> +			goto out;
> +	}
> 
> -	/* TODO: collect other namespaces here */
> +	ret = ckpt_obj_collect(ctx, nsproxy->mnt_ns, CKPT_OBJ_MNT_NS);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = 0;
>   out:
>  	put_nsproxy(nsproxy);
>  	return ret;
> @@ -282,8 +289,12 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
>  		goto out;
>  	h->ipc_objref = ret;
> 
> -	/* TODO: Write other namespaces here */
> -
> +	/* We do not support >1 private mntns */
> +	ret = -EINVAL;
> +	if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns) {
> +		ckpt_err(ctx, ret, "%(T)Nested mnt_ns unsupported\n");
> +		goto out;
> +	}
>  	/* We do not support >1 private netns */
>  	ret = -EINVAL;
>  	if (nsproxy->net_ns != ctx->root_nsproxy->net_ns) {
> -- 
> 1.6.3.3
