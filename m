From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] Checkpoint/restart epoll sets
Date: Tue, 20 Oct 2009 19:31:28 -0500
Message-ID: <20091021003128.GA23721@us.ibm.com>
References: <ce2e15faf44e254b80578c6c62e71d8685516896.1255971848.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <ce2e15faf44e254b80578c6c62e71d8685516896.1255971848.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> @@ -1226,35 +1242,18 @@ SYSCALL_DEFINE1(epoll_create, int, size)
>   * the eventpoll file that enables the insertion/removal/change of
>   * file descriptors inside the interest set.
>   */
> -SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
> -		struct epoll_event __user *, event)
> +int do_epoll_ctl(int op, int fd,
> +		 struct file *file, struct file *tfile,
> +		 struct epoll_event *epds)
>  {
>  	int error;
> -	struct file *file, *tfile;
>  	struct eventpoll *ep;
>  	struct epitem *epi;
> -	struct epoll_event epds;
> -
> -	error = -EFAULT;
> -	if (ep_op_has_event(op) &&
> -	    copy_from_user(&epds, event, sizeof(struct epoll_event)))
> -		goto error_return;
> -
> -	/* Get the "struct file *" for the eventpoll file */
> -	error = -EBADF;
> -	file = fget(epfd);
> -	if (!file)
> -		goto error_return;
> -
> -	/* Get the "struct file *" for the target file */
> -	tfile = fget(fd);
> -	if (!tfile)
> -		goto error_fput;
> 
>  	/* The target file descriptor must support poll */
>  	error = -EPERM;
>  	if (!tfile->f_op || !tfile->f_op->poll)
> -		goto error_tgt_fput;
> +		return error;
> 
>  	/*
>  	 * We have to check that the file structure underneath the file descriptor
> @@ -1263,7 +1262,7 @@ SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
>  	 */
>  	error = -EINVAL;
>  	if (file == tfile || !is_file_epoll(file))
> -		goto error_tgt_fput;
> +		return error;
> 
>  	/*
>  	 * At this point it is safe to assume that the "private_data" contains
> @@ -1284,8 +1283,8 @@ SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
>  	switch (op) {
>  	case EPOLL_CTL_ADD:
>  		if (!epi) {
> -			epds.events |= POLLERR | POLLHUP;
> -			error = ep_insert(ep, &epds, tfile, fd);
> +			epds->events |= POLLERR | POLLHUP;
> +			error = ep_insert(ep, epds, tfile, fd);
>  		} else
>  			error = -EEXIST;
>  		break;
> @@ -1297,15 +1296,46 @@ SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
>  		break;
>  	case EPOLL_CTL_MOD:
>  		if (epi) {
> -			epds.events |= POLLERR | POLLHUP;
> -			error = ep_modify(ep, epi, &epds);
> +			epds->events |= POLLERR | POLLHUP;
> +			error = ep_modify(ep, epi, epds);
>  		} else
>  			error = -ENOENT;
>  		break;
>  	}
>  	mutex_unlock(&ep->mtx);
> 
> -error_tgt_fput:
> +	return error;
> +}
> +
> +/*
> + * The following function implements the controller interface for
> + * the eventpoll file that enables the insertion/removal/change of
> + * file descriptors inside the interest set.
> + */
> +SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
> +		struct epoll_event __user *, event)
> +{
> +	int error;
> +	struct file *file, *tfile;
> +	struct epoll_event epds;
> +
> +	error = -EFAULT;
> +	if (ep_op_has_event(op) &&
> +	    copy_from_user(&epds, event, sizeof(struct epoll_event)))
> +		goto error_return;
> +
> +	/* Get the "struct file *" for the eventpoll file */
> +	error = -EBADF;
> +	file = fget(epfd);
> +	if (!file)
> +		goto error_return;
> +
> +	/* Get the "struct file *" for the target file */
> +	tfile = fget(fd);
> +	if (!tfile)
> +		goto error_fput;
> +
> +	error = do_epoll_ctl(op, fd, file, tfile, &epds);
>  	fput(tfile);
>  error_fput:
>  	fput(file);

(Just figured I'd do a sanity check of this code)  looks ok to me

...

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
> +	sys_close(epfd); /* harmless even if an error occured */
> +	BUG_ON(!epfile);

Would perhaps return ERR_PTR(-ENOENT) be nicer?  (And maybe safer - I'm
not quite clear on under which arches BUG_ON does nothing).

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
> +		fput(epfile);
> +		epfile = ERR_PTR(ret);
> +	}
> +	return epfile;
> +}
> +
> +#endif /* CONFIG_CHECKPOINT */
> +
>  static int __init eventpoll_init(void)
>  {
>  	struct sysinfo si;
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index ca2500d..1a3edab 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -119,6 +119,8 @@ enum {
>  #define CKPT_HDR_TTY CKPT_HDR_TTY
>  	CKPT_HDR_TTY_LDISC,
>  #define CKPT_HDR_TTY_LDISC CKPT_HDR_TTY_LDISC
> +	CKPT_HDR_EPOLL_ITEMS = 391, /* Follows file-table */

What is the comment supposed to mean (other than that such
comments inevitably become stale :)?

-serge
