From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add checkpoint/restart support for epoll files.
Date: Tue, 29 Sep 2009 15:33:15 -0500
Message-ID: <20090929203314.GC14956@us.ibm.com>
References: <1254164482-2193-2-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1254164482-2193-2-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Save/restore epoll items during checkpoint/restart respectively.
> kmalloc failures should be dealt with more kindly than just error-out
> because epoll is made to poll many thousands of file descriptors.
> Subsequent patches will change epoll c/r to "chunk" its output/input
> respectively.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Haven't looked much at epoll, but it looks good...

> +struct file* ep_file_restore(struct ckpt_ctx *ctx,
> +			     struct ckpt_hdr_file *h)
> +{
> +	struct file *epfile;
> +	int epfd, ret;
> +
> +	if (h->h.type != CKPT_HDR_FILE ||
> +	    h->h.len  != sizeof(*h) ||
> +	    h->f_type != CKPT_FILE_EPOLL)
> +		return ERR_PTR(-EINVAL);
> +
> +	epfd = sys_epoll_create1(h->f_flags & EPOLL_CLOEXEC);
> +	if (epfd < 0)
> +		return ERR_PTR(epfd);
> +	epfile = fget(epfd);
> +	BUG_ON(!epfile);
> +
> +	/*
> +	 * Needed before we can properly restore the watches and enforce the
> +	 * limit on watch numbers.
> +	 */
> +	ret = restore_file_common(ctx, epfile, h);
> +	if (ret < 0)
> +		goto fput_out;
> +
> +	/*
> +	 * Defer restoring the epoll items until the file table is
> +	 * fully restored. Ensures that valid file objrefs will resolve.
> +	 */
> +	ret = deferqueue_add_ptr(ctx->files_deferq, ctx, ep_items_restore, NULL);
> +	if (ret < 0) {
> +fput_out:

I've heard complaints before about labels in the middle of an
if block.  Since we know ret < 0 at the goto, the label could
just as well go up one line...

> +		fput(epfile);
> +		epfile = ERR_PTR(ret);
> +	}
> +	sys_close(epfd); /* harmless even if an error occured */
> +	return epfile;
> +}
> +
> +#endif /* CONFIG_CHECKPOINT */
> +
>  static int __init eventpoll_init(void)
>  {
>  	struct sysinfo si;
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index e00dd70..a8594cc 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -72,6 +72,7 @@ extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
>  			       void *ptr, int len, int type);
>  extern int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
>  extern int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len);
> +extern void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max);
>  extern void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type);
>  extern void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type);
>  extern int ckpt_read_payload(struct ckpt_ctx *ctx,
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 2ed523f..48736bd 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -85,6 +85,7 @@ enum {
>  	CKPT_HDR_PIPE_BUF,
>  	CKPT_HDR_TTY,
>  	CKPT_HDR_TTY_LDISC,
> +	CKPT_HDR_EPOLL_ITEMS = 391, /* Follows file-table */

Hmm, why are you specifying the number here?  That's just
begging for conflicts with other people's patches...

> 
>  	CKPT_HDR_MM = 401,
>  	CKPT_HDR_VMA,
> @@ -380,6 +381,7 @@ enum file_type {
>  	CKPT_FILE_FIFO,
>  	CKPT_FILE_SOCKET,
>  	CKPT_FILE_TTY,
> +	CKPT_FILE_EPOLL,
>  	CKPT_FILE_MAX
>  };
> 
> @@ -475,6 +477,18 @@ struct ckpt_hdr_file_socket {
>  	__s32 sock_objref;
>  } __attribute__((aligned(8)));
> 
