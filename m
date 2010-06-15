From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] cr: pts (v2): detect use of multiple devpts mounts in
	container
Date: Mon, 14 Jun 2010 22:22:54 -0400
Message-ID: <4C16E3FE.5000209@cs.columbia.edu>
References: <20100429224324.GA1982@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100429224324.GA1982-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

I have three questions:

1) I read the comment (further below):
   ...
   + * is.  Note that means that when we start checkpointing mounts
   + * and filesystems we'll need to change this.
   ...
and I wonder if this is only temporary until checkpoint mounts
work, and then there will be something completely different ?

2) If so, then would the following work instead: we could keep a
pointer (to SB) on the ckpt_ctx. which will start NULL and will be
set to the SB when we first see one, and compared against additional
ones.

It's safe because the SB is pinned down by the pty, and it's much
less logic/code considering that this is purely temporary.

3) Does this alert us when a (single) pty namespace in the container
is shared with the parent container ?

Oren.



On 04/29/2010 06:43 PM, Serge E. Hallyn wrote:
> We don't support multiple devpts mounts in a container.  So
> bail on checkpoint if a container has them.  This will cause
> checkpoint to fail of a container which still has a pty from
> parent container in use.
> 
> Since I don't actually need any methods in the ckpt_ops for
> ptsns, I just register the ckpt_ops in tty_io.c which is never
> a module.  We will presumably have to deal with modular ckpt_ops
> after the next submission, and we've talked about how to do it,
> but it's kind of late in this cycle to do that now.
> 
> checkpointing a task with open fd to pty from parent ns results
> in a message like:
> 
> [err -16][pos 3382][E @ tty_file_checkpoint:2760]Open pty from alien ptsns
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/char/tty_io.c            |   32 ++++++++++++++++++++++++++++++++
>  include/linux/checkpoint_hdr.h   |   18 ++++++++++++++++++
>  include/linux/checkpoint_types.h |    2 ++
>  3 files changed, 52 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
> index d264000..999317c 100644
> --- a/drivers/char/tty_io.c
> +++ b/drivers/char/tty_io.c
> @@ -96,6 +96,7 @@
>  #include <linux/bitops.h>
>  #include <linux/delay.h>
>  #include <linux/seq_file.h>
> +#include <linux/mount.h>
>  
>  #include <linux/uaccess.h>
>  #include <asm/system.h>
> @@ -2687,6 +2688,27 @@ static int tty_can_checkpoint(struct ckpt_ctx *ctx, struct tty_struct *tty)
>  	return 1;
>  }
>  
> +/*
> + * If tty_file_checkpoint() ever supports more than unix98 ptys we'll have
> + * to check for that
> + */
> +static int detect_multiple_ptsns(struct ckpt_ctx *ctx, struct file *file)
> +{
> +	int objref;
> +	int new;
> +
> +	objref = ckpt_obj_lookup_add(ctx, file->f_path.mnt->mnt_sb,
> +				  CKPT_OBJ_PTS_NS, &new);
> +	if (objref < 0)
> +		return objref;
> +	if (new && ctx->num_devpts_ns)
> +		return -EBUSY;
> +	if (file->f_path.mnt->mnt_ns != ctx->root_nsproxy->mnt_ns)
> +		return -EBUSY;
> +	ctx->num_devpts_ns++;
> +	return 0;
> +}
> +
>  static int tty_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
>  {
>  	struct ckpt_hdr_file_tty *h;
> @@ -2732,6 +2754,11 @@ static int tty_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
>  		ret = ckpt_write_obj(ctx, &h->common.h);
>  
>  	ckpt_hdr_put(ctx, h);
> +
> +	ret = detect_multiple_ptsns(ctx, file);
> +	if (ret)
> +		ckpt_err(ctx, ret, "Open pty from alien ptsns\n");
> +
>  	return ret;
>  }
>  
> @@ -3680,6 +3707,8 @@ static struct cdev tty_cdev, console_cdev;
>   */
>  static int __init tty_init(void)
>  {
> +	int err;
> +
>  	cdev_init(&tty_cdev, &tty_fops);
>  	if (cdev_add(&tty_cdev, MKDEV(TTYAUX_MAJOR, 0), 1) ||
>  	    register_chrdev_region(MKDEV(TTYAUX_MAJOR, 0), 1, "/dev/tty") < 0)
> @@ -3698,6 +3727,9 @@ static int __init tty_init(void)
>  	vty_init(&console_fops);
>  #endif
>  #ifdef CONFIG_CHECKPOINT
> +	err = register_checkpoint_obj(&ckpt_obj_ptsns_ops);
> +	if (err)
> +		return err;
>  	return checkpoint_register_tty();
>  #else
>  	return 0;
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index eb5e1b4..27113ca 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -271,6 +271,8 @@ enum obj_type {
>  #define CKPT_OBJ_NET_NS CKPT_OBJ_NET_NS
>  	CKPT_OBJ_NETDEV,
>  #define CKPT_OBJ_NETDEV CKPT_OBJ_NETDEV
> +	CKPT_OBJ_PTS_NS,
> +#define CKPT_OBJ_PTS_NS CKPT_OBJ_PTS_NS
>  	CKPT_OBJ_MAX
>  #define CKPT_OBJ_MAX CKPT_OBJ_MAX
>  };
> @@ -1142,5 +1144,21 @@ struct ckpt_hdr_ldisc_n_tty {
>  #define CKPT_TST_OVERFLOW_64(a, b) \
>  	((sizeof(a) > sizeof(b)) && ((a) > LONG_MAX))
>  
> +#if defined(CONFIG_UNIX98_PTYS) || defined(CONFIG_UNIX98_PTYS_MODULE)
> +/*
> + * We don't yet support multiple pts mounts in a container, so
> + * all we're doing here is detecting pty's in >1 ptsns.  We'll
> + * actually stick the sb on the objhash because that's all there
> + * is.  Note that means that when we start checkpointing mounts
> + * and filesystems we'll need to change this.
> + *
> + * We don't need to pin these bc they are pinned by the pty,
> + * which we do have pinned.
> + */
> +static const struct ckpt_obj_ops ckpt_obj_ptsns_ops = {
> +	.obj_name = "PTS NS",
> +	.obj_type = CKPT_OBJ_PTS_NS,
> +};
> +#endif /* CONFIG_UNIX98_PTYS */
>  
>  #endif /* _CHECKPOINT_CKPT_HDR_H_ */
> diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
> index eb3fdac..84782b0 100644
> --- a/include/linux/checkpoint_types.h
> +++ b/include/linux/checkpoint_types.h
> @@ -86,6 +86,8 @@ struct ckpt_ctx {
>  	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
>  	struct list_head listen_sockets;/* listening parent sockets */
>  
> +	int num_devpts_ns;		/* must not become > 1 at the moment */
> +
>  	struct ckpt_stats stats;	/* statistics */
>  
>  #define CKPT_MSG_LEN 1024
