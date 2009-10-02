From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add checkpoint/restart support for epoll files.
Date: Fri, 2 Oct 2009 02:30:50 -0700
Message-ID: <20091002093050.GA4189@count0.beaverton.ibm.com>
References: <1254164482-2193-2-git-send-email-matthltc@us.ibm.com>
	<4AC29086.8080407@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AC29086.8080407-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Sep 29, 2009 at 06:56:06PM -0400, Oren Laadan wrote:
> 
> 
> Matt Helsley wrote:
> > Save/restore epoll items during checkpoint/restart respectively.
> > kmalloc failures should be dealt with more kindly than just error-out
> > because epoll is made to poll many thousands of file descriptors.
> > Subsequent patches will change epoll c/r to "chunk" its output/input
> > respectively.
> 
> [...]
> 
> >  
> > @@ -311,9 +313,11 @@ static int do_checkpoint_file_table(struct ckpt_ctx *ctx,
> >  	}
> >  
> >  	ret = deferqueue_run(ctx->files_deferq);
> > -	ckpt_debug("files_deferq ran %d entries\n", ret);
> > -	if (ret > 0)
> > +	if (ret > 0) {
> > +		ckpt_debug("file checkpoint deferred %d work items\n", ret);
> >  		ret = 0;
> > +	}
> > +
> 
> With your permission, I'll do this hunk as a separate patch (and
> the restore counterpart too). So you can remove from your patch.

Removed.

<snip>

> >  
> > +#ifdef CONFIG_CHECKPOINT
> > +static int ep_file_collect(struct ckpt_ctx *ctx, struct file *file)
> > +{
> > +	struct rb_node *rbp;
> > +	struct eventpoll *ep;
> > +	int ret = 0;
> > +
> > +	ep = file->private_data;
> > +	mutex_lock(&ep->mtx);
> > +	for (rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp)) {
> > +		struct epitem *epi;
> > +
> > +		epi = rb_entry(rbp, struct epitem, rbn);
> > +		ret = ckpt_obj_collect(ctx, epi->ffd.file, CKPT_OBJ_FILE);
> 
> s/ckpt_obj_collect/ckpt_collect_file/

OK. Seems like we might recurse here though if the file is an epoll
file and there's a cycle in the epoll sets (e.g. epoll set A includes the fd
for epoll set B, epoll set B includes the fd for epoll set A).
So I think I'll do:

                if (is_file_epoll(epi->ffd.file))
                        continue; /* Don't recurse */
                ret = ckpt_collect_file(ctx, epi->ffd.file);

That works properly since epoll files are anonymous, can't be mmap'd, and
hence must be reachable from the file descriptor table.

I've also started a testcase to cover this scenario.

> 
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
> > +	struct ckpt_hdr_eventpoll_items *h;
> > +	struct rb_node *rbp;
> > +	struct eventpoll *ep;
> > +	__s32 epfile_objref;
> > +	int i, ret;
> > +
> > +	file = ep_dq_entry->epfile;
> > +	ctx = ep_dq_entry->ctx;
> > +
> > +	epfile_objref = ckpt_obj_lookup(ctx, file, CKPT_OBJ_FILE);
> > +	BUG_ON(epfile_objref <= 0);
> > +
> > +
> 
> Nit: extraneous newline :p

Removed

> 
> > +	ep = file->private_data;
> > +	mutex_lock(&ep->mtx);
> > +	for (i = 0, rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp), i++) {}
> > +	mutex_unlock(&ep->mtx);
> > +
> > +	h = ckpt_hdr_get_type(ctx, sizeof(*h) + i*sizeof(h->items[0]),
> > +			      CKPT_HDR_EPOLL_ITEMS);
> > +	if (!h)
> > +		return -ENOMEM;
> > +
> > +	h->num_items = i;
> > +	h->epfile_objref = epfile_objref;
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
> 
> (Should never return 0)

So? I don't think that implies the test should be changed.

> 
> > +			ret = -EBUSY; /* checkpoint obj leak */
> > +			break;
> > +		}
> > +		h->items[i].fd = epi->ffd.fd;
> > +		h->items[i].file_objref = objref;
> > +		h->items[i].events = epi->event.events;
> > +		h->items[i].data = epi->event.data;
> > +	}
> > +	mutex_unlock(&ep->mtx);
> > +	if (!ret && (i != h->num_items))
> > +		/*
> > +		 * We raced with another thread between our first and second
> 
> Not a thread (cannot be a thread, because we checkpoint whole thread
> groups). Any process who shared access to this file pointer.

Good point I'll s/thread/task/ here.

> 
> > +		 * walks of the rbtree such that there weren't the same number
> > +		 * of items. This means there is a checkpoint "leak".
> > +		 */
> > +		ret = -EBUSY;
> > +	if (ret == -EBUSY)
> > +		ckpt_write_err(ctx, "ep_items_checkpoint(): checkpoint leak detected.\n", "");
> 
> It would be useful (for the user) to know which fd/item caused the
> leak, or whether the leak was because i != h->num_items  (You could
> use two ckpt_write_err(), one inside the mutex and on here).

That's a good idea. Note the "fd" in the item isn't necessarily what's
in the fd table and the index "i" isn't a stable indicator of where we
are in the epoll set. So I'm going to have it print out the path to the
"file" rather than either of those things.

> 
> Also, the prototype of ckpt_write_err() has changed, see the code.

I noticed that -- that's why I put in the "". However I see that it's
much more complicated than the prototype implied. Here's my idiotic
thought process:

extern int ckpt_write_err(struct ckpt_ctx *ctx, char *ptr, char *fmt,
...);

Gosh it looks like an arbitrary string with the incredibly redundant
name "ptr" which tells me absolutely nothing about what goes there.

Now that you've pointed this out I've dug a little deeper. Calling it the
"pre-format" string is also not very informative -- I can guess that it
goes before "fmt" based on its position in the arguments. The
best information comes from the comment above __ckpt_generate_fmt():

	 * PREFMT is constructed from @prefmt by subtituting format snippets
	 * according to the contents of @prefmt.  The format characters in
	 * @prefmt can be E (error), O (objref), P (pointer), S (string) and
	 * V (variable/symbol). For example, E will generate a "err %d" in
	 * PREFMT (see prefmt_array below).
	...

In other words it has a very specific encoding which neither the
prototype nor the function itself hint at or bother to describe. I had to
dig down through the vararg layers to find that description.

There needs to be information near the prototype in checkpoint.h and near
the function itself which shouts to anyone reading it that "ptr" is some
oddly-encoded string.

It would also be better if each prefmt element required a % before it -- then
reviewers would probably recognize it as a "second" format string with
strange conversion specifications (%E, %O, %P, %V, %S).

I can't help but think there's more improvement possible. Some less
well-thought-out ideas:

It might be even better to remove the prefmt string and have ckpt_write_err
variants for specialized areas of the code. If area "foo" could use an
err, objref, and file flags you might define:

int ckpt_write_foo_err(struct ckpt_ctx *ctx, int err, __s32 objref, int
			flags, char *fmt, ...);

Otherwise I wonder if it would be better to join the prefmt and fmt
strings by just defining our own, new, conversion specifiers.

> 
> > +	else if (!ret)
> > +		ret = ckpt_write_obj(ctx, &h->h);
> 
> What other value could @ret have ?

None as the code stands right now. Maybe I should change it to something
like:

if (ret) {
	ckpt_write_err(...);
} else
	ckpt_write_obj(...);

That should handle any errors -- not just -EBUSY -- and avoid an extra
test. Actually I've looked into the error paths and done a complete
rewrite of them to use ckpt_write_err() properly and more verbosely.
It's more expensive and complex though.

> 
> > +	ckpt_hdr_put(ctx, &h->h);
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
> > +		return -ENOMEM;
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
> > + 	 * have an objref; after the file table has been checkpointed.
> > +	 */
> > +	ep_dq_entry.ctx = ctx;
> > +	ep_dq_entry.epfile = file;
> > +	ret = deferqueue_add(ctx->files_deferq, &ep_dq_entry,
> > +			     sizeof(ep_dq_entry), ep_items_checkpoint, NULL);
> > +out:
> > +	ckpt_hdr_put(ctx, h);
> > +	return ret;
> > +}
> > +
> > +static int ep_items_restore(void *data)
> > +{
> > +	struct ckpt_ctx *ctx = deferqueue_data_ptr(data);
> > +	struct ckpt_hdr_eventpoll_items *h;
> > +	struct eventpoll *ep;
> > +	struct file *epfile = NULL;
> > +	int ret, i = 0, remaining_watches;
> > +
> > +	h = ckpt_read_obj(ctx, 0,
> > +			  sizeof(*h) + max_user_watches*sizeof(h->items[0]));
> 
> s/ckpt_read_obj/ckpt_read_buf_type/
> Saves you the @type and @len test below.

Good. That means I can get rid of the portion of the patch that removed
"static" from ckpt_read_obj too...

Again, the prototype in checkpoint.h is misleading. It says the second
argument is "len", not "max" (or better: "maxlen"). Naming is critical --
even for prototype parameters in headers.

I think I see a bug in either ckpt_read_obj or its kerneldocs:

	/**
	 * ckpt_read_obj - allocate and read an object (ckpt_hdr followed by
	 * payload)
	 * @ctx: checkpoint context
	 * @h: object descriptor
	 * @len: desired payload length (if 0, flexible)
	 * @max: maximum payload length
	 *
	 * Return: new buffer allocated on success, error pointer otherwise
	 */
	static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
	{
		struct ckpt_hdr hh;
		struct ckpt_hdr *h;
		int ret;

	 again:
		ret = ckpt_kread(ctx, &hh, sizeof(hh));
		if (ret < 0)
			return ERR_PTR(ret);
		_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
			    hh.type, hh.len, len, max);
		if (hh.len < sizeof(*h))
			return ERR_PTR(-EINVAL);

		if (hh.type == CKPT_HDR_OBJREF) {
			ret = _ckpt_read_objref(ctx, &hh);
			if (ret < 0)
				return ERR_PTR(ret);
			goto again;
		}

		/* if len specified, enforce, else if maximum specified, enforce */
		if ((len && hh.len != len) || (!len && max && hh.len > max))
			return ERR_PTR(-EINVAL);

The last test really should be:

		if ((len && hh.len != len) || 
		   (!len && max && (hh.len - sizeof(*h)) > max))
			return ERR_PTR(-EINVAL);

Otherwise it's not really the maximum payload length and the "bug" is
just the comment.

> 
> > +	if (IS_ERR(h))
> > +		return PTR_ERR(h);
> > +
> > +	ret = -EINVAL;
> > +	if ((h->h.type != CKPT_HDR_EPOLL_ITEMS) ||
> > +	    (h->h.len < sizeof(*h)))
> > +		goto out;
> > +
> > +	/* Make sure the items match the size we expect */
> > +	if (h->num_items != ((h->h.len - sizeof(*h)) / sizeof(h->items[0])))
> > +		goto out;
> > +
> > +	epfile = ckpt_obj_fetch(ctx, h->epfile_objref, CKPT_OBJ_FILE);
> > +	BUG_ON(IS_ERR(epfile));
> > +	BUG_ON(!is_file_epoll(epfile));
> > +
> > +	/* Make sure there are enough watches left. */
> > +	ret = -ENOSPC;
> > +	ep = epfile->private_data;
> > +	remaining_watches = (max_user_watches -
> > +			     atomic_read(&ep->user->epoll_watches));
> > +	if (h->num_items > remaining_watches)
> > +		goto out;
> 
> I unsure if this is necessary: running out of watches will be
> detected anyway later on. I wouldn't worry about early detection.

I'm tired of arguing over this one so OK, I've removed it.

> 
> > +
> > +	ret = 0;
> > +	/* Restore the epoll items/watches */
> > +	for (i = 0; !ret && i < h->num_items; i++) {
> > +		struct epoll_event epev;
> > +		struct file *tfile;
> > +
> > +		/* Get the file* for the target file */
> > +		if (h->items[i].file_objref <= 0) {
> > +			ret = -EINVAL;
> > +			break;
> > +		}
> 
> I should probably change the code elsewhere too, but this test
> is unnecessary because ckpt_obj_fetch() will complain anyway.

I don't think it will complain since I don't see anything in the read or hash
code that checks for negative objrefs. However moving this into
ckpt_obj_fetch() would get rid of alot of code much like passing NULL into
kfree() does, so I'll remove this test.

> 
> > +		tfile = ckpt_obj_fetch(ctx, h->items[i].file_objref,
> > +				       CKPT_OBJ_FILE);
> > +		if (IS_ERR(tfile)) {
> > +			ret = PTR_ERR(tfile);
> > +			break;
> > +		}
> > +
> > +		epev.events = h->items[i].events;
> > +		epev.data = h->items[i].data;
> > +
> > +		ret = do_epoll_ctl(EPOLL_CTL_ADD, h->items[i].fd,
> > +				   epfile, tfile, &epev);
> > +	}
> > +out:
> > +	ckpt_hdr_put(ctx, h);
> > +	return ret;
> > +}
> > +
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
> > +	epfd = sys_epoll_create1(h->f_flags & EPOLL_CLOEXEC);
> > +	if (epfd < 0)
> > +		return ERR_PTR(epfd);
> > +	epfile = fget(epfd);
> > +	BUG_ON(!epfile);
> > +
> > +	/*
> > +	 * Needed before we can properly restore the watches and enforce the
> > +	 * limit on watch numbers.
> > +	 */
> > +	ret = restore_file_common(ctx, epfile, h);
> > +	if (ret < 0)
> > +		goto fput_out;
> > +
> > +	/*
> > +	 * Defer restoring the epoll items until the file table is
> > +	 * fully restored. Ensures that valid file objrefs will resolve.
> > +	 */
> > +	ret = deferqueue_add_ptr(ctx->files_deferq, ctx, ep_items_restore, NULL);
> > +	if (ret < 0) {
> > +fput_out:
> > +		fput(epfile);
> > +		epfile = ERR_PTR(ret);
> > +	}
> > +	sys_close(epfd); /* harmless even if an error occured */
> 
> Nit: you can move this up to right after fget().

Good idea.

Thanks for the review.

Cheers,
	-Matt Helsley
