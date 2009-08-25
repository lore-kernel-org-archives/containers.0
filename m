From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] [RFC] Add checkpoint/restart support for epoll files.
Date: Mon, 24 Aug 2009 19:01:46 -0700
Message-ID: <20090825020146.GC8078@count0.beaverton.ibm.com>
References: <6d896e12f316e5ff5f44bd13ae1482dab7f9253a.1250745409.git.matthltc@us.ibm.com>
	<e820d207a3b1a3228ded29bce9b29f2179ab598b.1250745409.git.matthltc@us.ibm.com>
	<20090824212725.GA25030@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090824212725.GA25030-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Aug 24, 2009 at 04:27:25PM -0500, Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > Save/restore epoll items during checkpoint/restart respectively.

<snip>

> > diff --git a/fs/eventpoll.c b/fs/eventpoll.c
> > index 085c5c0..7f7070f 100644
> > --- a/fs/eventpoll.c
> > +++ b/fs/eventpoll.c
> > @@ -671,10 +671,19 @@ static unsigned int ep_eventpoll_poll(struct file *file, poll_table *wait)
> >  	return pollflags != -1 ? pollflags : 0;
> >  }
> > 
> > +#ifdef CONFIG_CHECKPOINT
> > +static int ep_eventpoll_checkpoint(struct ckpt_ctx *ctx, struct file *file);
> > +static int ep_file_collect(struct ckpt_ctx *ctx, struct file *file);
> > +#else
> > +#define ep_eventpoll_checkpoint NULL
> 
> Don't forget ep_file_collect here.

Oops, good catch.

> 
> > +#endif
> > +
> >  /* File callbacks that implement the eventpoll file behaviour */
> >  static const struct file_operations eventpoll_fops = {
> >  	.release	= ep_eventpoll_release,
> > -	.poll		= ep_eventpoll_poll
> > +	.poll		= ep_eventpoll_poll,
> > +	.checkpoint 	= ep_eventpoll_checkpoint,
> > +	.collect 	= ep_file_collect,
> >  };
> > 
> >  /* Fast test to see if the file is an evenpoll file */
> > @@ -1413,6 +1422,275 @@ SYSCALL_DEFINE6(epoll_pwait, int, epfd, struct epoll_event __user *, events,
> > 
> >  #endif /* HAVE_SET_RESTORE_SIGMASK */
> > 
> > +#ifdef CONFIG_CHECKPOINT
> > +#include <linux/checkpoint.h>
> > +#include <linux/checkpoint_hdr.h>
> > +#include <linux/deferqueue.h>
> > +
> > +static int ep_file_collect(struct ckpt_ctx *ctx, struct file *file)
> > +{
> > +	struct rb_node *rbp;
> > +	struct eventpoll *ep;
> > +	int ret = 0;
> > +
> > +	if (!is_file_epoll(file))
> > +		return 0;
> > +
> > +	ep = file->private_data;
> > +	mutex_lock(&ep->mtx);
> > +	for (rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp)) {
> > +		struct epitem *epi;
> > +
> > +		epi = rb_entry(rbp, struct epitem, rbn);
> > +		ret = ckpt_obj_collect(ctx, epi->ffd.file, CKPT_OBJ_FILE);
> > +		if (ret < 0)
> > +			break;
> > +	}
> > +	mutex_unlock(&ep->mtx);
> > +	return ret;
> > +}
> > +
> > +struct epoll_deferq_entry {
> > +	struct ckpt_ctx *ctx;
> > +	struct file *epfile;
> > +};
> > +
> > +static int ep_items_checkpoint(void *data)
> > +{
> > +	struct epoll_deferq_entry *ep_dq_entry = data;
> > +	struct ckpt_ctx *ctx;
> > +	struct file *file;
> > +	struct ckpt_eventpoll_items *h;
> > +	struct rb_node *rbp;
> > +	struct eventpoll *ep;
> > +	int i, ret = -ENOMEM;
> > +
> > +	file = ep_dq_entry->epfile;
> > +	ctx = ep_dq_entry->ctx;
> > +
> > +	ep = file->private_data;
> > +	mutex_lock(&ep->mtx);
> > +	for (i = 0, rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp), i++) {}
> > +	mutex_unlock(&ep->mtx);
> > +
> > +	/* TODO likely allocation failure when lots of epoll items */
> > +	h = ckpt_hdr_get_type(ctx, sizeof(*h) + i*sizeof(h->items[0]),
> > +			      CKPT_HDR_FILE_EPOLL_ITEMS);
> > +	if (!h)
> > +		goto out;
> > +
> > +	ret = -ENODEV;
> > +	h->num_items = i;
> > +	h->epfile_objref = ckpt_obj_lookup(ctx, file, CKPT_OBJ_FILE);
> > +	if (h->epfile_objref <= 0)
> > +		goto out;
> > +
> > +	ret = 0;
> > +	mutex_lock(&ep->mtx);
> > +	for (i = 0, rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp), i++) {
> > +		struct epitem *epi;
> > +		int objref;
> > +
> > +		epi = rb_entry(rbp, struct epitem, rbn);
> > +		objref = ckpt_obj_lookup(ctx, epi->ffd.file, CKPT_OBJ_FILE);
> > +		if (objref <= 0) {
> > +			/* TODO error -- possible checkpoint obj leak */
> > +			ret = -ENODEV;
> > +			break;
> > +		}
> > +		h->items[i].fd = epi->ffd.fd;
> > +		h->items[i].file_objref = objref;
> > +		h->items[i].events = epi->event.events;
> > +		h->items[i].data = epi->event.data;
> > +	}
> > +	mutex_unlock(&ep->mtx);
> > +	if (h && !ret)
> > +		ret = ckpt_write_obj(ctx, &h->h);
> > +	if (!ret && (i != h->num_items)) {
> > +		/* TODO error -- possible checkpoint obj leak */
> > +	}
> > +out:
> > +	if (h)
> > +		ckpt_hdr_put(ctx, &h->h);
> > +	return ret;
> > +}
> > +
> > +static int ep_eventpoll_checkpoint(struct ckpt_ctx *ctx, struct file *file)
> > +{
> > +	struct ckpt_hdr_file *h;
> > +	struct epoll_deferq_entry ep_dq_entry;
> > +	int ret = -ENOMEM;
> > +
> > +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
> > +	if (!h)
> > +		goto out_print;
> > +	h->f_type = CKPT_FILE_EPOLL;
> > +	ret = checkpoint_file_common(ctx, file, h);
> > +	if (ret < 0)
> > +		goto out;
> > +	ret = ckpt_write_obj(ctx, &h->h);
> > +	if (ret < 0)
> > +		goto out;
> > +
> > +	/*
> > +	 * Defer saving the epoll items until all of the ffd.file pointers
> > +	 * have an objref; after the file table has been checkpointed.
> > +	 */
> > +	ep_dq_entry.ctx = ctx;
> > +	ep_dq_entry.epfile = file;
> > +	ret = deferqueue_add(ctx->files_deferq, &ep_dq_entry,
> > +			     sizeof(ep_dq_entry), ep_items_checkpoint, NULL);
> > +out:
> > +	ckpt_hdr_put(ctx, h);
> > +out_print:
> > +	return ret;
> > +}
> > +
> > +static int ep_items_restore(void *data)
> > +{
> > +	struct ckpt_ctx *ctx = *((struct ckpt_ctx**)data);
> > +	struct ckpt_eventpoll_items *h;
> > +	struct eventpoll *ep;
> > +	struct file *epfile = NULL;
> > +	int ret, i = 0, remaining_watches;
> > +
> > +	/*
> > +	 * TODO possible kmalloc failure due to too many watches.
> > +	 */
> > +	h = ckpt_read_obj(ctx, 0,
> > +			  sizeof(*h) + max_user_watches*sizeof(h->items[0]));
> > +	if (IS_ERR(h))
> > +		return PTR_ERR(h);
> > +
> > +	ret = -EINVAL;
> > +	if ((h->h.type != CKPT_HDR_FILE_EPOLL_ITEMS) ||
> > +	    (h->h.len < sizeof(*h)))
> > +		goto out;
> > +
> > +	/* Make sure the items match the size we expect */
> > +	if (h->num_items != ((h->h.len - sizeof(*h)) / sizeof(h->items[0])))
> > +		goto out;
> > +
> > +	epfile = ckpt_obj_fetch(ctx, h->epfile_objref, CKPT_OBJ_FILE);
> > +	if (IS_ERR(epfile)) {
> > +		ret = PTR_ERR(epfile);
> > +		goto out;
> > +	}
> > +	ret = -ENOMSG;
> > +	if (!is_file_epoll(epfile))
> > +		goto out;
> > +
> > +	ep = epfile->private_data;
> > +
> > +	ret = -ENOSPC;
> > +	remaining_watches = (max_user_watches -
> > +			     atomic_read(&ep->user->epoll_watches));
> > +	if (h->num_items > remaining_watches)
> > +		goto out;
> > +
> > +	ret = 0;
> > +	/* Restore the epoll items/watches */
> > +	for (i = 0; !ret && i < h->num_items; i++) {
> > +		/*
> > +		 * Loop body like multiple epoll_ctl(ep, ADD, event)
> > +		 * calls except we've already done much of the checking.
> > +		 */
> > +		struct epoll_event epev;
> > +		struct epitem *epi;
> > +		struct file *tfile;
> > +
> > +		epev.events = h->items[i].events;
> > +		epev.data = h->items[i].data;
> > +
> > +		/* Get the file* for the target file */
> > +		if (h->items[i].file_objref <= 0) {
> > +			ret = -EINVAL;
> > +			break;
> > +		}
> > +
> > +		tfile = ckpt_obj_fetch(ctx, h->items[i].file_objref,
> > +				       CKPT_OBJ_FILE);
> > +		if (IS_ERR(tfile)) {
> > +			ret = PTR_ERR(tfile);
> > +			break;
> > +		}
> > +
> > +		/* The target file must support poll */
> > +		if (!tfile->f_op || !tfile->f_op->poll) {
> > +			ret = -EPERM;
> > +			break;
> > +		}
> > +
> > +		/* Cannot add an epoll file descriptor inside itself. */
> > +		if (epfile == tfile) {
> > +			ret = -EINVAL;
> > +			break;
> > +		}
> > +
> > +		mutex_lock(&ep->mtx);
> > +		epi = ep_find(ep, tfile, h->items[i].fd);
> > +		if (!epi) {
> > +			epev.events |= POLLERR | POLLHUP;
> > +			ret = ep_insert(ep, &epev, tfile, h->items[i].fd);
> > +		} else
> > +			ret = -EEXIST;
> > +		mutex_unlock(&ep->mtx);
> > +	}
> > +out:
> > +	ckpt_hdr_put(ctx, h);
> > +	return ret;
> > +}
> > +
> > +/* TODO confirm that get_current_user() has been restored */
> 
> Not sure what you mean.  At this point, the task's credentials
> are still the ones used when it called sys_restart().  We won't
> update them until the end of the restart operation.  However the
> normal file restore operations should have reset the file->f_cred
> to the checkpointed value - including hierarchical user namespaces.

I wanted to check to ensure that we're properly enforcing the epoll
watch limits for the restarted tasks. So the patch looks good because
it restore the "common" file pieces before the epoll items/watches.
See below if you're curious where/how that happens. I think I can
remove this TODO now.

> > +struct file* ep_file_restore(struct ckpt_ctx *ctx,
> > +			     struct ckpt_hdr_file *h)
> > +{
> > +	struct file *epfile;
> > +	int epfd, ret;
> > +
> > +	if (h->h.type != CKPT_HDR_FILE ||
> > +	    h->h.len  != sizeof(*h) ||
> > +	    h->f_type != CKPT_FILE_EPOLL)
> > +		return ERR_PTR(-EINVAL);
> > +
> > +	/*
> > +	 * TODO Normally h->f_flags contains flags that epoll_create() won't
> > +	 * accept. Right now we pass only those flags it will accept here
> > +	 * and restore the rest during the "common" file restore. Check
> > +	 * to make sure we're not missing anything.
> > +	 */
> > +	epfd = sys_epoll_create1(h->f_flags & EPOLL_CLOEXEC);
> > +	if (epfd < 0)
> > +		return ERR_PTR(epfd);
> > +	epfile = fget(epfd);
> > +	if (!epfile)
> > +		return ERR_PTR(-ENOENT); /* TODO pick better error? */
> > +
> > +	ret = restore_file_common(ctx, epfile, h);

	^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This should restore epfile->f_cred and...

> > +	if (ret < 0)
> > +		goto fput_out;
> > +
> > +	/*
> > +	 * Now we have the file and file descriptor but the epoll set is empty.
> > +	 * Defer restoring the epoll set until we encounter its corresponding
> > +	 * items. Note that this effectively counts the number of
> > +	 * ckpt_eventpoll_items blocks we should expect -- we rely on the
> > +	 * epfile_objref of those blocks to associate them with the proper
> > +	 * file.
> > +	 */
> > +	ret = deferqueue_add(ctx->files_deferq, &ctx, sizeof(ctx),
> > +			     ep_items_restore, NULL);

This defers restoration of the items/watches.

> > +	if (ret < 0) {
> > +fput_out:
> > +		fput(epfile);
> > +		epfile = ERR_PTR(ret);
> > +	}
> > +	sys_close(epfd);
> > +	return epfile;
> > +}
> > +
> > +#endif /* CONFIG_CHECKPOINT */
> > +

Thanks for the review!

Cheers,
	-Matt Helsley
