From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 2/2] [RFC] Add checkpoint/restart support for epoll files.
Date: Thu, 20 Aug 2009 12:33:38 -0400
Message-ID: <4A8D7AE2.1030705@cs.columbia.edu>
References: <6d896e12f316e5ff5f44bd13ae1482dab7f9253a.1250745409.git.matthltc@us.ibm.com>
	<e820d207a3b1a3228ded29bce9b29f2179ab598b.1250745409.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

Hi Matt,

I like the approach of the patch and use of deferqueue.
See comments below.

Matt Helsley wrote:
> Save/restore epoll items during checkpoint/restart respectively.
> 
> Tests for the cr_tests suite to follow. Tests pass on i386.
> 
> TODOs (search the patch for "TODO") that could probably use some
> comments:
> 
> What to do when there's a "possible checkpoint obj leak"? (search patch
> 	for this string to see what I'm talking about)

Generally, complain with ckpt_write_err() and abort.

> 
> Ensure get_current_user will be correct (a userns question/issue?).
> 
> kmalloc failures should be dealt with more kindly than just error-out
> 	because epoll is made to poll many thousands of file
> 	descriptors.
> 	This seems like a more general problem with some of the
> 	ckpt_hdr* functions than an epoll problem but...

This is handled with pids by writing in chunks (only on checkpoint
side).

There is now better infrastructure to do chunks on restart
side too - first read the header's header (struct ckpt_hdr) without
the buffer, allocate a local buffer, followed by ckpt_read()s.

Or add ckpt_read_chunk() that will also allocate the buffer for
the next chunk. Or even a loop: ckpt_read_chunk_{start,next,end}() ?

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

You can create/destroy the deferqueue once, in ckpt_ctx_alloc()
and ckpt_ctx_free(), respectively. It will also simplify the logic
here.

>  	for (n = 0; n < nfds; n++) {
>  		ret = checkpoint_file_desc(ctx, files, fdtable[n]);
>  		if (ret < 0)
>  			break;

If you s/break/goto out/ here, you can get rid if the 'if' clause
below (assuming ctx->files_deferq is alloc/free in ckpt_ctx_...)

>  	}
> +	if (!ret) {
> +		ret = deferqueue_run(ctx->files_deferq);
> +		if (ret > 0) {
> +			pr_warning("c/r: files deferqueue had %d entries\n", ret);

			ckpt_debug(...);   ?

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

Ditto for alloc/free of ctx->files_deferq.

>  	for (i = 0; i < h->fdt_nfds; i++) {
>  		ret = restore_file_desc(ctx);
>  		if (ret < 0)
>  			break;

Ditto for s/break/goto out/ to simplify logic.

>  	}
> +	if (!ret) {
> +		ret = deferqueue_run(ctx->files_deferq);
> +		if (ret > 0) {
> +			pr_warning("c/r: files deferqueue had %d entries\n", ret);

			ckpt_debug(...);  ?

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

This should never happen, right ?
Perhaps BUG_ON() instead ?

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

I suggest that:

1) Add 'int fd' here,
2) in ckpt_eventpoll_items use the fd (instead of file objref)

The motivation is security: if, on restart, you rely on a file objref,
then malicious user can change the file objref and the restart logic
may end up populating some other process's event poll items.

Instead, by using an fd, we ensure that the restarting process will
only modify a file that it actually owns.


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

You can loop in chunks (a-la pids), all inside the mutex_lock().

> +	h = ckpt_hdr_get_type(ctx, sizeof(*h) + i*sizeof(h->items[0]),
> +			      CKPT_HDR_FILE_EPOLL_ITEMS);
> +	if (!h)
> +		goto out;

		return -ENOMEM;
> +
> +	ret = -ENODEV;
> +	h->num_items = i;
> +	h->epfile_objref = ckpt_obj_lookup(ctx, file, CKPT_OBJ_FILE);
> +	if (h->epfile_objref <= 0)
> +		goto out;

This also should never happen. BUG_ON() here, too ?
(Also, this can go before the allocation of @h)

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

This can probably go away (see next comment), but if it stays, then
call to ckpt_write_err() to explain what happens, and return -EBUSY.

> +			break;
> +		}
> +		h->items[i].fd = epi->ffd.fd;
> +		h->items[i].file_objref = objref;

Is there a reason to also save the file pointer ?  I thought that
the fd suffices.

> +		h->items[i].events = epi->event.events;
> +		h->items[i].data = epi->event.data;
> +	}
> +	mutex_unlock(&ep->mtx);
> +	if (h && !ret)
> +		ret = ckpt_write_obj(ctx, &h->h);

Test for @h is unnecessary.

If you keep only fd (not file_objref) as suggested above, then test
for @ret is also unnecessary.

> +	if (!ret && (i != h->num_items)) {
> +		/* TODO error -- possible checkpoint obj leak */
> +	}

Complain with ckpt_write_err(), return -EBUSY... (btw, this test
may go before ckpt_write_obj above).

> +out:
> +	if (h)

Test for @h is unnecessary (with the change above).

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
		return -ENOMEM;    (save label below)

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

This is really obfuscated :(
How about ((struct epoll_deferq_entry *) data)->ctx ?

Actually, during restart the only data you save is @ctx... why at
all save an epoll_deferq_entry ?  and ctx = (struct ckpt_ctx *) data;

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

Any reason to perfer ckpt_read_obj() over ckpt_read_buf_type() ?
(it will rid the check for type/len below).

Yep.. chunks is probably better. Such a mechanism would also be
useful for pending signals, and for reading in pids array.

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

As suggested above, use h->epfile_fd instead of epfile_objref:
	epfile = fget(h->epfile_fd);
	fput(epfile);	/* safe since it's already in objhash */
or even BUG_ON(!ckpt_obj_fetch ...)

> +	ret = -ENOMSG;

Maybe -EINVAL - data provided by user is invalid... ?  (and the setting
of @ret above remains).

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

This is tested anyway by ep_insert() below. Besides, it's racy here
(user may  have another restart in parallel, and the check-modify isn't
atomic. Unlike with ep_insert(), this check is for a bunch of fd's not
a single one.

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

Get the file from the fd using fget() instead ?

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

These last two tests are already done by epoll_ctl(). It also works
with the fd.

How about reusing epoll_ctl() - e.g. move the copy_from_user() to a
wrapper and the rest in do_epoll_ctl() - instead of using ep_insert()
directly ?

This will save you most of the logic above (including testing that
this is an epoll). It will make it less likely that new checks in
epoll_ctl() be left out from this code.

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

Why is this 'TODO' ?
(FWIW, even the effect of this flag is restored in restore_file_common)

> +	epfd = sys_epoll_create1(h->f_flags & EPOLL_CLOEXEC);
> +	if (epfd < 0)
> +		return ERR_PTR(epfd);
> +	epfile = fget(epfd);
> +	if (!epfile)
> +		return ERR_PTR(-ENOENT); /* TODO pick better error? */

Ughh... I wonder how this can happen ?  Not even if the "bad guys" are
ptracing us...  so this will probably be a BUG_ON() ?

I see in fs/pipe() I return -EBADF, but that one there, too, deserves
at the very least a nasty warning message, or even a BUG_ON.

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

The second part of the comment is a bit confusing.

> +	 */
> +	ret = deferqueue_add(ctx->files_deferq, &ctx, sizeof(ctx),
> +			     ep_items_restore, NULL);
> +	if (ret < 0) {
> +fput_out:
> +		fput(epfile);
> +		epfile = ERR_PTR(ret);
> +	}
> +	sys_close(epfd);
			  /* harmless even if an error occurred */

> +	return epfile;
> +}
> +
> +#endif /* CONFIG_CHECKPOINT */
> +
>  static int __init eventpoll_init(void)
>  {
>  	struct sysinfo si;
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 761cad5..053c6c0 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -69,6 +69,7 @@ extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
>  extern int _ckpt_read_nbuffer(struct ckpt_ctx *ctx, void *ptr, int len);
>  extern int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
>  extern int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len);
> +extern void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max);
>  extern void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type);
>  extern void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type);
>  extern int ckpt_read_payload(struct ckpt_ctx *ctx,
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 4d5c22a..3a3e530 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -76,6 +76,7 @@ enum {
>  	CKPT_HDR_FILE_NAME,
>  	CKPT_HDR_FILE,
>  	CKPT_HDR_PIPE_BUF,
> +	CKPT_HDR_FILE_EPOLL_ITEMS, /* Follows file-table */

Nit:  s/CKPT_HDR_FILE_EPOLL_ITEMS/CKPT_HDR_EPOLL_ITEMS/  ?

>  
>  	CKPT_HDR_MM = 401,
>  	CKPT_HDR_VMA,
> @@ -342,6 +343,7 @@ enum file_type {
>  	CKPT_FILE_PIPE,
>  	CKPT_FILE_FIFO,
>  	CKPT_FILE_SOCKET,
> +	CKPT_FILE_EPOLL,
>  	CKPT_FILE_MAX
>  };
>  
> @@ -426,6 +428,18 @@ struct ckpt_hdr_file_socket {
>  	struct ckpt_hdr_socket socket;
>  } __attribute__((aligned(8)));
>  
> +struct ckpt_eventpoll_items {

Nit: how about 'struct ckpt_hdr_eventpoll' ?

> +	struct ckpt_hdr h;
> +	__s32  epfile_objref;
> +	__u32  num_items;

... also, making this a named struct (e.g. struct ckpt_hdr_eventpoll_item)
will make it friendlier to a 'chunks' implementation as mentioned above.

> +	struct {
> +		__u64 data;
> +		__u32 fd;
> +		__s32 file_objref;
> +		__u32 events;
> +	} items[0];
> +} __attribute__((aligned(8)));

So:

struct ckpt_hdr_eventpoll_item {
	__u64 data;
	__u32 fd;
	__u32 events;
};

struct ckpt_hdr_eventpoll {
	struct ckpt_hdr h;
	__u32 epfile_fd;
	__u32 num_items;
	struct ckpt_hdr_eventpoll_item items[0];
};

> +
>  struct ckpt_hdr_utsns {
>  	struct ckpt_hdr h;
>  	char sysname[__NEW_UTS_LEN + 1];
> diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
> index e98251b..51cdd0c 100644
> --- a/include/linux/checkpoint_types.h
> +++ b/include/linux/checkpoint_types.h
> @@ -48,6 +48,8 @@ struct ckpt_ctx {
>  
>  	struct ckpt_obj_hash *obj_hash;	/* repository for shared objects */
>  	struct deferqueue_head *deferqueue;	/* queue of deferred work */
> +	struct deferqueue_head *files_deferq; /* deferred work to do after
> +						 saving file table */
>  
>  	struct path fs_mnt;     /* container root (FIXME) */
>  
> diff --git a/include/linux/eventpoll.h b/include/linux/eventpoll.h
> index f6856a5..ff3de38 100644
> --- a/include/linux/eventpoll.h
> +++ b/include/linux/eventpoll.h
> @@ -95,11 +95,23 @@ static inline void eventpoll_release(struct file *file)
>  	eventpoll_release_file(file);
>  }
>  
> +#ifdef CONFIG_CHECKPOINT
> +#include <linux/checkpoint_hdr.h>

To avoid dependency on checkpoint_hdr.h, you can instead:

struct ckpt_ctx;
struct ckpt_hdr_file;

> +extern struct file* ep_file_restore(struct ckpt_ctx *ctx,
> +				    struct ckpt_hdr_file *h);
> +#endif
>  #else
>  
>  static inline void eventpoll_init_file(struct file *file) {}
>  static inline void eventpoll_release(struct file *file) {}
> -
> +#ifdef CONFIG_CHECKPOINT
> +#include <linux/checkpoint_hdr.h>

Here too.

> +static inline struct file* ep_file_restore(struct ckpt_ctx *ctx,
> +					   struct ckpt_hdr_file *ptr)
> +{
> +	return NULL;

Hmmm... the caller expects either a valid file pointer or an
error pointer:

	return ERR_PTR(-ENOSYS);


> +}
> +#endif
>  #endif
>  
>  #endif /* #ifdef __KERNEL__ */

Oren.
