From: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Subject: Re: [PATCH 2/3] c/r: Add AF_UNIX support (v4)
Date: Wed, 01 Jul 2009 16:06:36 -0400
Message-ID: <4A4BC1CC.5020900@hp.com>
References: <1246472414-23105-1-git-send-email-danms@us.ibm.com>
	<1246472414-23105-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246472414-23105-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Dan,

> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1482,4 +1482,13 @@ extern int sysctl_optmem_max;
>  extern __u32 sysctl_wmem_default;
>  extern __u32 sysctl_rmem_default;
>  
> +/* Checkpoint/Restart Functions */
> +struct ckpt_ctx;
> +struct ckpt_hdr_socket;
> +extern int sock_file_checkpoint(struct ckpt_ctx *, void *);
> +extern void *sock_file_restore(struct ckpt_ctx *);
> +extern struct socket *do_sock_file_restore(struct ckpt_ctx *,
> +					   struct ckpt_hdr_socket *);
> +extern int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);

Should this all be under #ifdef CONFIG_CHECKPOINT?

> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -96,6 +96,9 @@
>  #include <net/sock.h>
>  #include <linux/netfilter.h>
>  
> +#include <linux/checkpoint.h>
> +#include <linux/checkpoint_hdr.h>
> +
>  static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
>  static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
>  			 unsigned long nr_segs, loff_t pos);
> @@ -140,6 +143,9 @@ static const struct file_operations socket_file_ops = {
>  	.sendpage =	sock_sendpage,
>  	.splice_write = generic_splice_sendpage,
>  	.splice_read =	sock_splice_read,
> +#ifdef CONFIG_CHECKPOINT
> +	.checkpoint =   sock_file_checkpoint,
> +#endif
>  };
>  
>  /*
> @@ -415,6 +421,84 @@ int sock_map_fd(struct socket *sock, int flags)
>  	return fd;
>  }
>  
> +int sock_file_checkpoint(struct ckpt_ctx *ctx, void *ptr)
> +{
> +	struct ckpt_hdr_file_socket *h;
> +	int ret;
> +	struct file *file = ptr;
<snip>

And the corresponding code in socket.c too, since you're only assigning
.checkpoint above in that case.

-Brian
