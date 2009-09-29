From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] Add checkpoint/restart support for epoll files.
Date: Tue, 29 Sep 2009 18:56:06 -0400
Message-ID: <4AC29086.8080407@librato.com>
References: <1254164482-2193-2-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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



Matt Helsley wrote:
> Save/restore epoll items during checkpoint/restart respectively.
> kmalloc failures should be dealt with more kindly than just error-out
> because epoll is made to poll many thousands of file descriptors.
> Subsequent patches will change epoll c/r to "chunk" its output/input
> respectively.

[...]

>  
> @@ -311,9 +313,11 @@ static int do_checkpoint_file_table(struct ckpt_ctx *ctx,
>  	}
>  
>  	ret = deferqueue_run(ctx->files_deferq);
> -	ckpt_debug("files_deferq ran %d entries\n", ret);
> -	if (ret > 0)
> +	if (ret > 0) {
> +		ckpt_debug("file checkpoint deferred %d work items\n", ret);
>  		ret = 0;
> +	}
> +

With your permission, I'll do this hunk as a separate patch (and
the restore counterpart too). So you can remove from your patch.

>   out:
>  	kfree(fdtable);
>  	return ret;
> @@ -604,6 +608,13 @@ static struct restore_file_ops restore_file_ops[] = {
>  		.file_type = CKPT_FILE_TTY,
>  		.restore = tty_file_restore,
>  	},
> +#ifdef CONFIG_EPOLL
> +	{
> +		.file_name = "EPOLL",
> +		.file_type = CKPT_FILE_EPOLL,
> +		.restore = ep_file_restore,
> +	},
> +#endif
>  };
>  
>  static struct file *do_restore_file(struct ckpt_ctx *ctx)
> @@ -731,9 +742,11 @@ static struct files_struct *do_restore_file_table(struct ckpt_ctx *ctx)
>  	}
>  
>  	ret = deferqueue_run(ctx->files_deferq);
> -	ckpt_debug("files_deferq ran %d entries\n", ret);
> -	if (ret > 0)
> +	if (ret > 0) {
> +		ckpt_debug("file restore deferred %d work items\n", ret);
>  		ret = 0;
> +	}
> +

(This part too).

>   out:
>  	ckpt_hdr_put(ctx, h);
>  	if (!ret) {

[...]

>  
> +#ifdef CONFIG_CHECKPOINT
> +static int ep_file_collect(struct ckpt_ctx *ctx, struct file *file)
> +{
> +	struct rb_node *rbp;
> +	struct eventpoll *ep;
> +	int ret = 0;
> +
> +	ep = file->private_data;
> +	mutex_lock(&ep->mtx);
> +	for (rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp)) {
> +		struct epitem *epi;
> +
> +		epi = rb_entry(rbp, struct epitem, rbn);
> +		ret = ckpt_obj_collect(ctx, epi->ffd.file, CKPT_OBJ_FILE);

s/ckpt_obj_collect/ckpt_collect_file/

> +		if (ret < 0)
> +			break;
> +	}
> +	mutex_unlock(&ep->mtx);
> +	return ret;
> +}
> +
> +struct epoll_deferq_entry {
> +	struct ckpt_ctx *ctx;
> +	struct file *epfile;
> +};
> +
> +static int ep_items_checkpoint(void *data)
> +{
> +	struct epoll_deferq_entry *ep_dq_entry = data;
> +	struct ckpt_ctx *ctx;
> +	struct file *file;
> +	struct ckpt_hdr_eventpoll_items *h;
> +	struct rb_node *rbp;
> +	struct eventpoll *ep;
> +	__s32 epfile_objref;
> +	int i, ret;
> +
> +	file = ep_dq_entry->epfile;
> +	ctx = ep_dq_entry->ctx;
> +
> +	epfile_objref = ckpt_obj_lookup(ctx, file, CKPT_OBJ_FILE);
> +	BUG_ON(epfile_objref <= 0);
> +
> +

Nit: extraneous newline :p

> +	ep = file->private_data;
> +	mutex_lock(&ep->mtx);
> +	for (i = 0, rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp), i++) {}
> +	mutex_unlock(&ep->mtx);
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h) + i*sizeof(h->items[0]),
> +			      CKPT_HDR_EPOLL_ITEMS);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	h->num_items = i;
> +	h->epfile_objref = epfile_objref;
> +
> +	ret = 0;
> +	mutex_lock(&ep->mtx);
> +	for (i = 0, rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp), i++) {
> +		struct epitem *epi;
> +		int objref;
> +
> +		epi = rb_entry(rbp, struct epitem, rbn);
> +		objref = ckpt_obj_lookup(ctx, epi->ffd.file, CKPT_OBJ_FILE);
> +		if (objref <= 0) {

(Should never return 0)

> +			ret = -EBUSY; /* checkpoint obj leak */
> +			break;
> +		}
> +		h->items[i].fd = epi->ffd.fd;
> +		h->items[i].file_objref = objref;
> +		h->items[i].events = epi->event.events;
> +		h->items[i].data = epi->event.data;
> +	}
> +	mutex_unlock(&ep->mtx);
> +	if (!ret && (i != h->num_items))
> +		/*
> +		 * We raced with another thread between our first and second

Not a thread (cannot be a thread, because we checkpoint whole thread
groups). Any process who shared access to this file pointer.

> +		 * walks of the rbtree such that there weren't the same number
> +		 * of items. This means there is a checkpoint "leak".
> +		 */
> +		ret = -EBUSY;
> +	if (ret == -EBUSY)
> +		ckpt_write_err(ctx, "ep_items_checkpoint(): checkpoint leak detected.\n", "");

It would be useful (for the user) to know which fd/item caused the
leak, or whether the leak was because i != h->num_items  (You could
use two ckpt_write_err(), one inside the mutex and on here).

Also, the prototype of ckpt_write_err() has changed, see the code.

> +	else if (!ret)
> +		ret = ckpt_write_obj(ctx, &h->h);

What other value could @ret have ?

> +	ckpt_hdr_put(ctx, &h->h);
> +	return ret;
> +}
> +
> +static int ep_eventpoll_checkpoint(struct ckpt_ctx *ctx, struct file *file)
> +{
> +	struct ckpt_hdr_file *h;
> +	struct epoll_deferq_entry ep_dq_entry;
> +	int ret = -ENOMEM;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
> +	if (!h)
> +		return -ENOMEM;
> +	h->f_type = CKPT_FILE_EPOLL;
> +	ret = checkpoint_file_common(ctx, file, h);
> +	if (ret < 0)
> +		goto out;
> +	ret = ckpt_write_obj(ctx, &h->h);
> +	if (ret < 0)
> +		goto out;
> +
> +	/*
> +	 * Defer saving the epoll items until all of the ffd.file pointers
> + 	 * have an objref; after the file table has been checkpointed.
> +	 */
> +	ep_dq_entry.ctx = ctx;
> +	ep_dq_entry.epfile = file;
> +	ret = deferqueue_add(ctx->files_deferq, &ep_dq_entry,
> +			     sizeof(ep_dq_entry), ep_items_checkpoint, NULL);
> +out:
> +	ckpt_hdr_put(ctx, h);
> +	return ret;
> +}
> +
> +static int ep_items_restore(void *data)
> +{
> +	struct ckpt_ctx *ctx = deferqueue_data_ptr(data);
> +	struct ckpt_hdr_eventpoll_items *h;
> +	struct eventpoll *ep;
> +	struct file *epfile = NULL;
> +	int ret, i = 0, remaining_watches;
> +
> +	h = ckpt_read_obj(ctx, 0,
> +			  sizeof(*h) + max_user_watches*sizeof(h->items[0]));

s/ckpt_read_obj/ckpt_read_buf_type/
Saves you the @type and @len test below.

> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	ret = -EINVAL;
> +	if ((h->h.type != CKPT_HDR_EPOLL_ITEMS) ||
> +	    (h->h.len < sizeof(*h)))
> +		goto out;
> +
> +	/* Make sure the items match the size we expect */
> +	if (h->num_items != ((h->h.len - sizeof(*h)) / sizeof(h->items[0])))
> +		goto out;
> +
> +	epfile = ckpt_obj_fetch(ctx, h->epfile_objref, CKPT_OBJ_FILE);
> +	BUG_ON(IS_ERR(epfile));
> +	BUG_ON(!is_file_epoll(epfile));
> +
> +	/* Make sure there are enough watches left. */
> +	ret = -ENOSPC;
> +	ep = epfile->private_data;
> +	remaining_watches = (max_user_watches -
> +			     atomic_read(&ep->user->epoll_watches));
> +	if (h->num_items > remaining_watches)
> +		goto out;

I unsure if this is necessary: running out of watches will be
detected anyway later on. I wouldn't worry about early detection.

> +
> +	ret = 0;
> +	/* Restore the epoll items/watches */
> +	for (i = 0; !ret && i < h->num_items; i++) {
> +		struct epoll_event epev;
> +		struct file *tfile;
> +
> +		/* Get the file* for the target file */
> +		if (h->items[i].file_objref <= 0) {
> +			ret = -EINVAL;
> +			break;
> +		}

I should probably change the code elsewhere too, but this test
is unnecessary because ckpt_obj_fetch() will complain anyway.

> +		tfile = ckpt_obj_fetch(ctx, h->items[i].file_objref,
> +				       CKPT_OBJ_FILE);
> +		if (IS_ERR(tfile)) {
> +			ret = PTR_ERR(tfile);
> +			break;
> +		}
> +
> +		epev.events = h->items[i].events;
> +		epev.data = h->items[i].data;
> +
> +		ret = do_epoll_ctl(EPOLL_CTL_ADD, h->items[i].fd,
> +				   epfile, tfile, &epev);
> +	}
> +out:
> +	ckpt_hdr_put(ctx, h);
> +	return ret;
> +}
> +
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
> +		fput(epfile);
> +		epfile = ERR_PTR(ret);
> +	}
> +	sys_close(epfd); /* harmless even if an error occured */

Nit: you can move this up to right after fget().

[...]

Oren.
