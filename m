From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] [RFC] Add checkpoint/restart support for epoll files.
Date: Mon, 24 Aug 2009 16:27:25 -0500
Message-ID: <20090824212725.GA25030@us.ibm.com>
References: <6d896e12f316e5ff5f44bd13ae1482dab7f9253a.1250745409.git.matthltc@us.ibm.com>
	<e820d207a3b1a3228ded29bce9b29f2179ab598b.1250745409.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e820d207a3b1a3228ded29bce9b29f2179ab598b.1250745409.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Save/restore epoll items during checkpoint/restart respectively.
> 
> Tests for the cr_tests suite to follow. Tests pass on i386.
> 
> TODOs (search the patch for "TODO") that could probably use some
> comments:
> 
> What to do when there's a "possible checkpoint obj leak"? (search patch
> 	for this string to see what I'm talking about)
> 
> Ensure get_current_user will be correct (a userns question/issue?).
> 
> kmalloc failures should be dealt with more kindly than just error-out
> 	because epoll is made to poll many thousands of file
> 	descriptors.
> 	This seems like a more general problem with some of the
> 	ckpt_hdr* functions than an epoll problem but...
> 
> Pick better errnos for some cases.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
> ---
>  checkpoint/files.c               |   35 +++++
>  checkpoint/restart.c             |    2 +-
>  fs/eventpoll.c                   |  280 +++++++++++++++++++++++++++++++++++++-
>  include/linux/checkpoint.h       |    1 +
>  include/linux/checkpoint_hdr.h   |   14 ++
>  include/linux/checkpoint_types.h |    2 +
>  include/linux/eventpoll.h        |   14 ++-
>  7 files changed, 345 insertions(+), 3 deletions(-)
> 
> diff --git a/checkpoint/files.c b/checkpoint/files.c
> index 204055b..8f86dcc 100644
> --- a/checkpoint/files.c
> +++ b/checkpoint/files.c
> @@ -21,6 +21,8 @@
>  #include <linux/syscalls.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
> +#include <linux/deferqueue.h>
> +#include <linux/eventpoll.h>
>  #include <net/sock.h>
> 
> 
> @@ -289,11 +291,24 @@ static int do_checkpoint_file_table(struct ckpt_ctx *ctx,
>  		goto out;
> 
>  	ckpt_debug("nfds %d\n", nfds);
> +	ctx->files_deferq = deferqueue_create();
> +	if (!ctx->files_deferq) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
>  	for (n = 0; n < nfds; n++) {
>  		ret = checkpoint_file_desc(ctx, files, fdtable[n]);
>  		if (ret < 0)
>  			break;
>  	}
> +	if (!ret) {
> +		ret = deferqueue_run(ctx->files_deferq);
> +		if (ret > 0) {
> +			pr_warning("c/r: files deferqueue had %d entries\n", ret);
> +			ret = 0;
> +		}
> +	}
> +	deferqueue_destroy(ctx->files_deferq);
>   out:
>  	kfree(fdtable);
>  	return ret;
> @@ -572,6 +587,14 @@ static struct restore_file_ops restore_file_ops[] = {
>  		.file_type = CKPT_FILE_SOCKET,
>  		.restore = sock_file_restore,
>  	},
> +#ifdef CONFIG_EPOLL
> +	/* epoll */
> +	{
> +		.file_name = "EPOLL",
> +		.file_type = CKPT_FILE_EPOLL,
> +		.restore = ep_file_restore,
> +	},
> +#endif
>  };
> 
>  static struct file *do_restore_file(struct ckpt_ctx *ctx)
> @@ -692,11 +715,23 @@ static struct files_struct *do_restore_file_table(struct ckpt_ctx *ctx)
>  	if (ret < 0)
>  		goto out;
> 
> +	ret = -ENOMEM;
> +	ctx->files_deferq = deferqueue_create();
> +	if (!ctx->files_deferq)
> +		goto out;
>  	for (i = 0; i < h->fdt_nfds; i++) {
>  		ret = restore_file_desc(ctx);
>  		if (ret < 0)
>  			break;
>  	}
> +	if (!ret) {
> +		ret = deferqueue_run(ctx->files_deferq);
> +		if (ret > 0) {
> +			pr_warning("c/r: files deferqueue had %d entries\n", ret);
> +			ret = 0;
> +		}
> +	}
> +	deferqueue_destroy(ctx->files_deferq);
>   out:
>  	ckpt_hdr_put(ctx, h);
>  	if (!ret) {
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index 4fdae78..3a7d914 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -164,7 +164,7 @@ int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len)
>   *
>   * Return: new buffer allocated on success, error pointer otherwise
>   */
> -static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
> +void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
>  {
>  	struct ckpt_hdr hh;
>  	struct ckpt_hdr *h;
> diff --git a/fs/eventpoll.c b/fs/eventpoll.c
> index 085c5c0..7f7070f 100644
> --- a/fs/eventpoll.c
> +++ b/fs/eventpoll.c
> @@ -671,10 +671,19 @@ static unsigned int ep_eventpoll_poll(struct file *file, poll_table *wait)
>  	return pollflags != -1 ? pollflags : 0;
>  }
> 
> +#ifdef CONFIG_CHECKPOINT
> +static int ep_eventpoll_checkpoint(struct ckpt_ctx *ctx, struct file *file);
> +static int ep_file_collect(struct ckpt_ctx *ctx, struct file *file);
> +#else
> +#define ep_eventpoll_checkpoint NULL

Don't forget ep_file_collect here.

> +#endif
> +
>  /* File callbacks that implement the eventpoll file behaviour */
>  static const struct file_operations eventpoll_fops = {
>  	.release	= ep_eventpoll_release,
> -	.poll		= ep_eventpoll_poll
> +	.poll		= ep_eventpoll_poll,
> +	.checkpoint 	= ep_eventpoll_checkpoint,
> +	.collect 	= ep_file_collect,
>  };
> 
>  /* Fast test to see if the file is an evenpoll file */
> @@ -1413,6 +1422,275 @@ SYSCALL_DEFINE6(epoll_pwait, int, epfd, struct epoll_event __user *, events,
> 
>  #endif /* HAVE_SET_RESTORE_SIGMASK */
> 
> +#ifdef CONFIG_CHECKPOINT
> +#include <linux/checkpoint.h>
> +#include <linux/checkpoint_hdr.h>
> +#include <linux/deferqueue.h>
> +
> +static int ep_file_collect(struct ckpt_ctx *ctx, struct file *file)
> +{
> +	struct rb_node *rbp;
> +	struct eventpoll *ep;
> +	int ret = 0;
> +
> +	if (!is_file_epoll(file))
> +		return 0;
> +
> +	ep = file->private_data;
> +	mutex_lock(&ep->mtx);
> +	for (rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp)) {
> +		struct epitem *epi;
> +
> +		epi = rb_entry(rbp, struct epitem, rbn);
> +		ret = ckpt_obj_collect(ctx, epi->ffd.file, CKPT_OBJ_FILE);
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
> +	struct ckpt_eventpoll_items *h;
> +	struct rb_node *rbp;
> +	struct eventpoll *ep;
> +	int i, ret = -ENOMEM;
> +
> +	file = ep_dq_entry->epfile;
> +	ctx = ep_dq_entry->ctx;
> +
> +	ep = file->private_data;
> +	mutex_lock(&ep->mtx);
> +	for (i = 0, rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp), i++) {}
> +	mutex_unlock(&ep->mtx);
> +
> +	/* TODO likely allocation failure when lots of epoll items */
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h) + i*sizeof(h->items[0]),
> +			      CKPT_HDR_FILE_EPOLL_ITEMS);
> +	if (!h)
> +		goto out;
> +
> +	ret = -ENODEV;
> +	h->num_items = i;
> +	h->epfile_objref = ckpt_obj_lookup(ctx, file, CKPT_OBJ_FILE);
> +	if (h->epfile_objref <= 0)
> +		goto out;
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
> +			/* TODO error -- possible checkpoint obj leak */
> +			ret = -ENODEV;
> +			break;
> +		}
> +		h->items[i].fd = epi->ffd.fd;
> +		h->items[i].file_objref = objref;
> +		h->items[i].events = epi->event.events;
> +		h->items[i].data = epi->event.data;
> +	}
> +	mutex_unlock(&ep->mtx);
> +	if (h && !ret)
> +		ret = ckpt_write_obj(ctx, &h->h);
> +	if (!ret && (i != h->num_items)) {
> +		/* TODO error -- possible checkpoint obj leak */
> +	}
> +out:
> +	if (h)
> +		ckpt_hdr_put(ctx, &h->h);
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
> +		goto out_print;
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
> +	 * have an objref; after the file table has been checkpointed.
> +	 */
> +	ep_dq_entry.ctx = ctx;
> +	ep_dq_entry.epfile = file;
> +	ret = deferqueue_add(ctx->files_deferq, &ep_dq_entry,
> +			     sizeof(ep_dq_entry), ep_items_checkpoint, NULL);
> +out:
> +	ckpt_hdr_put(ctx, h);
> +out_print:
> +	return ret;
> +}
> +
> +static int ep_items_restore(void *data)
> +{
> +	struct ckpt_ctx *ctx = *((struct ckpt_ctx**)data);
> +	struct ckpt_eventpoll_items *h;
> +	struct eventpoll *ep;
> +	struct file *epfile = NULL;
> +	int ret, i = 0, remaining_watches;
> +
> +	/*
> +	 * TODO possible kmalloc failure due to too many watches.
> +	 */
> +	h = ckpt_read_obj(ctx, 0,
> +			  sizeof(*h) + max_user_watches*sizeof(h->items[0]));
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	ret = -EINVAL;
> +	if ((h->h.type != CKPT_HDR_FILE_EPOLL_ITEMS) ||
> +	    (h->h.len < sizeof(*h)))
> +		goto out;
> +
> +	/* Make sure the items match the size we expect */
> +	if (h->num_items != ((h->h.len - sizeof(*h)) / sizeof(h->items[0])))
> +		goto out;
> +
> +	epfile = ckpt_obj_fetch(ctx, h->epfile_objref, CKPT_OBJ_FILE);
> +	if (IS_ERR(epfile)) {
> +		ret = PTR_ERR(epfile);
> +		goto out;
> +	}
> +	ret = -ENOMSG;
> +	if (!is_file_epoll(epfile))
> +		goto out;
> +
> +	ep = epfile->private_data;
> +
> +	ret = -ENOSPC;
> +	remaining_watches = (max_user_watches -
> +			     atomic_read(&ep->user->epoll_watches));
> +	if (h->num_items > remaining_watches)
> +		goto out;
> +
> +	ret = 0;
> +	/* Restore the epoll items/watches */
> +	for (i = 0; !ret && i < h->num_items; i++) {
> +		/*
> +		 * Loop body like multiple epoll_ctl(ep, ADD, event)
> +		 * calls except we've already done much of the checking.
> +		 */
> +		struct epoll_event epev;
> +		struct epitem *epi;
> +		struct file *tfile;
> +
> +		epev.events = h->items[i].events;
> +		epev.data = h->items[i].data;
> +
> +		/* Get the file* for the target file */
> +		if (h->items[i].file_objref <= 0) {
> +			ret = -EINVAL;
> +			break;
> +		}
> +
> +		tfile = ckpt_obj_fetch(ctx, h->items[i].file_objref,
> +				       CKPT_OBJ_FILE);
> +		if (IS_ERR(tfile)) {
> +			ret = PTR_ERR(tfile);
> +			break;
> +		}
> +
> +		/* The target file must support poll */
> +		if (!tfile->f_op || !tfile->f_op->poll) {
> +			ret = -EPERM;
> +			break;
> +		}
> +
> +		/* Cannot add an epoll file descriptor inside itself. */
> +		if (epfile == tfile) {
> +			ret = -EINVAL;
> +			break;
> +		}
> +
> +		mutex_lock(&ep->mtx);
> +		epi = ep_find(ep, tfile, h->items[i].fd);
> +		if (!epi) {
> +			epev.events |= POLLERR | POLLHUP;
> +			ret = ep_insert(ep, &epev, tfile, h->items[i].fd);
> +		} else
> +			ret = -EEXIST;
> +		mutex_unlock(&ep->mtx);
> +	}
> +out:
> +	ckpt_hdr_put(ctx, h);
> +	return ret;
> +}
> +
> +/* TODO confirm that get_current_user() has been restored */

Not sure what you mean.  At this point, the task's credentials
are still the ones used when it called sys_restart().  We won't
update them until the end of the restart operation.  However the
normal file restore operations should have reset the file->f_cred
to the checkpointed value - including hierarchical user namespaces.

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
> +	/*
> +	 * TODO Normally h->f_flags contains flags that epoll_create() won't
> +	 * accept. Right now we pass only those flags it will accept here
> +	 * and restore the rest during the "common" file restore. Check
> +	 * to make sure we're not missing anything.
> +	 */
> +	epfd = sys_epoll_create1(h->f_flags & EPOLL_CLOEXEC);
> +	if (epfd < 0)
> +		return ERR_PTR(epfd);
> +	epfile = fget(epfd);
> +	if (!epfile)
> +		return ERR_PTR(-ENOENT); /* TODO pick better error? */
> +
> +	ret = restore_file_common(ctx, epfile, h);
> +	if (ret < 0)
> +		goto fput_out;
> +
> +	/*
> +	 * Now we have the file and file descriptor but the epoll set is empty.
> +	 * Defer restoring the epoll set until we encounter its corresponding
> +	 * items. Note that this effectively counts the number of
> +	 * ckpt_eventpoll_items blocks we should expect -- we rely on the
> +	 * epfile_objref of those blocks to associate them with the proper
> +	 * file.
> +	 */
> +	ret = deferqueue_add(ctx->files_deferq, &ctx, sizeof(ctx),
> +			     ep_items_restore, NULL);
> +	if (ret < 0) {
> +fput_out:
> +		fput(epfile);
> +		epfile = ERR_PTR(ret);
> +	}
> +	sys_close(epfd);
> +	return epfile;
> +}
> +
> +#endif /* CONFIG_CHECKPOINT */
> +
