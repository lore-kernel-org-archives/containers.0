From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add checkpoint/restart support for epoll files.
Date: Fri, 2 Oct 2009 13:27:26 -0700
Message-ID: <20091002202726.GC4189@count0.beaverton.ibm.com>
References: <1254164482-2193-2-git-send-email-matthltc@us.ibm.com>
	<4AC29086.8080407@librato.com>
	<20091002093050.GA4189@count0.beaverton.ibm.com>
	<4AC644C8.2070905@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AC644C8.2070905-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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

On Fri, Oct 02, 2009 at 02:22:00PM -0400, Oren Laadan wrote:
> 
> 
> Matt Helsley wrote:
> > On Tue, Sep 29, 2009 at 06:56:06PM -0400, Oren Laadan wrote:
> >>
> >> Matt Helsley wrote:
> >>> Save/restore epoll items during checkpoint/restart respectively.
> >>> kmalloc failures should be dealt with more kindly than just error-out
> >>> because epoll is made to poll many thousands of file descriptors.
> >>> Subsequent patches will change epoll c/r to "chunk" its output/input
> >>> respectively.
> 
> [...]
> 
> >>> +	for (rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp)) {
> >>> +		struct epitem *epi;
> >>> +
> >>> +		epi = rb_entry(rbp, struct epitem, rbn);
> >>> +		ret = ckpt_obj_collect(ctx, epi->ffd.file, CKPT_OBJ_FILE);
> >> s/ckpt_obj_collect/ckpt_collect_file/
> > 
> > OK. Seems like we might recurse here though if the file is an epoll
> > file and there's a cycle in the epoll sets (e.g. epoll set A includes the fd
> > for epoll set B, epoll set B includes the fd for epoll set A).
> > So I think I'll do:
> 
> I doubt if an epoll file can epoll an epoll file ...
> (eg. see line 1265 in fs/eventpoll.c)

I am certain it can. The testcase I have proves it and the man page mentions
it too. Since it has a poll op I believe it can be epoll'd (line 691 of
fs/eventpoll.c).

I haven't double checked, but I believe the line you cited just prevents the
epoll set from including its own fd.

<snip>

> >>> +		ckpt_write_err(ctx, "ep_items_checkpoint(): checkpoint leak detected.\n", "");
> >> It would be useful (for the user) to know which fd/item caused the
> >> leak, or whether the leak was because i != h->num_items  (You could
> >> use two ckpt_write_err(), one inside the mutex and on here).
> > 
> > That's a good idea. Note the "fd" in the item isn't necessarily what's
> > in the fd table and the index "i" isn't a stable indicator of where we
> > are in the epoll set. So I'm going to have it print out the path to the
> > "file" rather than either of those things.
> > 
> 
> Good point. Then please note both - the (original) fd may be a
> useful fact for the developer trying to understand what failed.

True. I suppose if the fd is inconsistent with the file's path then
they'll have enough information to eventually figure it out.

<snip>

> > I can't help but think there's more improvement possible. Some less
> > well-thought-out ideas:
> > 
> > It might be even better to remove the prefmt string and have ckpt_write_err
> > variants for specialized areas of the code. If area "foo" could use an
> > err, objref, and file flags you might define:
> > 
> > int ckpt_write_foo_err(struct ckpt_ctx *ctx, int err, __s32 objref, int
> > 			flags, char *fmt, ...);
> 
> I thought about it, but wished to avoid proliferation of these
> variants.

Makes sense.

> > Otherwise I wonder if it would be better to join the prefmt and fmt
> > strings by just defining our own, new, conversion specifiers.
> > 
> 
> Thought about it, but that would limit us in the conversion specifiers
> that we can use, because many are used by printf already. Perhaps one
> way to do it is use
> 	"%Zxyz"
> where "%Z" tells the following letters indicate a ckpt_write_err()
> format, and then "xyz" are the letters from the current @prefmt.

Would %( work better? The ( suggests that there's more to it.

<snip>

> > I think I see a bug in either ckpt_read_obj or its kerneldocs:
> > 
> > 	/**
> > 	 * ckpt_read_obj - allocate and read an object (ckpt_hdr followed by
> > 	 * payload)
> > 	 * @ctx: checkpoint context
> > 	 * @h: object descriptor
> > 	 * @len: desired payload length (if 0, flexible)
> > 	 * @max: maximum payload length
> > 	 *
> > 	 * Return: new buffer allocated on success, error pointer otherwise
> > 	 */
> > 	static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
> > 	{
> > 		struct ckpt_hdr hh;
> > 		struct ckpt_hdr *h;
> > 		int ret;
> > 
> > 	 again:
> > 		ret = ckpt_kread(ctx, &hh, sizeof(hh));
> > 		if (ret < 0)
> > 			return ERR_PTR(ret);
> > 		_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
> > 			    hh.type, hh.len, len, max);
> > 		if (hh.len < sizeof(*h))
> > 			return ERR_PTR(-EINVAL);
> > 
> > 		if (hh.type == CKPT_HDR_OBJREF) {
> > 			ret = _ckpt_read_objref(ctx, &hh);
> > 			if (ret < 0)
> > 				return ERR_PTR(ret);
> > 			goto again;
> > 		}
> > 
> > 		/* if len specified, enforce, else if maximum specified, enforce */
> > 		if ((len && hh.len != len) || (!len && max && hh.len > max))
> > 			return ERR_PTR(-EINVAL);
> > 
> > The last test really should be:
> > 
> > 		if ((len && hh.len != len) || 
> > 		   (!len && max && (hh.len - sizeof(*h)) > max))
> > 			return ERR_PTR(-EINVAL);
> > 
> > Otherwise it's not really the maximum payload length and the "bug" is
> > just the comment.
> 
> The bug is in the comment: @max is intended to tell the max (total)
> buffer size returned to the user. Will fix.

OK. That means I need to fix my code too then. Thanks for fixing these
up.

> 
> [...]
> 
> >>> +	ret = 0;
> >>> +	/* Restore the epoll items/watches */
> >>> +	for (i = 0; !ret && i < h->num_items; i++) {
> >>> +		struct epoll_event epev;
> >>> +		struct file *tfile;
> >>> +
> >>> +		/* Get the file* for the target file */
> >>> +		if (h->items[i].file_objref <= 0) {
> >>> +			ret = -EINVAL;
> >>> +			break;
> >>> +		}
> >> I should probably change the code elsewhere too, but this test
> >> is unnecessary because ckpt_obj_fetch() will complain anyway.
> > 
> > I don't think it will complain since I don't see anything in the read or hash
> > code that checks for negative objrefs. However moving this into
> 
> What is "this" that you want to move ?

I thought it would be necessary to move the < 0 test above into the
objhash code because...

> 
> > ckpt_obj_fetch() would get rid of alot of code much like passing NULL into
> > kfree() does, so I'll remove this test.
> 
> ckpt_obj_fetch() won't complain about a negative value a-priori, but
> the search is certain to fail. Nevertheless, I'll tighten the restart
> related calls in objhash to ensure that.

Hmm, I didn't see how it was certain to fail. I guess I'll have to look
again.

Cheers,
	-Matt Helsley
