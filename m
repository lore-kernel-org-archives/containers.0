From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] Add checkpoint/restart support for epoll files.
Date: Fri, 02 Oct 2009 14:22:00 -0400
Message-ID: <4AC644C8.2070905@librato.com>
References: <1254164482-2193-2-git-send-email-matthltc@us.ibm.com>
	<4AC29086.8080407@librato.com>
	<20091002093050.GA4189@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091002093050.GA4189-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
> On Tue, Sep 29, 2009 at 06:56:06PM -0400, Oren Laadan wrote:
>>
>> Matt Helsley wrote:
>>> Save/restore epoll items during checkpoint/restart respectively.
>>> kmalloc failures should be dealt with more kindly than just error-out
>>> because epoll is made to poll many thousands of file descriptors.
>>> Subsequent patches will change epoll c/r to "chunk" its output/input
>>> respectively.

[...]

>>> +	for (rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp)) {
>>> +		struct epitem *epi;
>>> +
>>> +		epi = rb_entry(rbp, struct epitem, rbn);
>>> +		ret = ckpt_obj_collect(ctx, epi->ffd.file, CKPT_OBJ_FILE);
>> s/ckpt_obj_collect/ckpt_collect_file/
> 
> OK. Seems like we might recurse here though if the file is an epoll
> file and there's a cycle in the epoll sets (e.g. epoll set A includes the fd
> for epoll set B, epoll set B includes the fd for epoll set A).
> So I think I'll do:

I doubt if an epoll file can epoll an epoll file ...
(eg. see line 1265 in fs/eventpoll.c)

> 
>                 if (is_file_epoll(epi->ffd.file))
>                         continue; /* Don't recurse */
>                 ret = ckpt_collect_file(ctx, epi->ffd.file);
> 
> That works properly since epoll files are anonymous, can't be mmap'd, and
> hence must be reachable from the file descriptor table.
> 
> I've also started a testcase to cover this scenario.
> 

[...]

>>> +		 * walks of the rbtree such that there weren't the same number
>>> +		 * of items. This means there is a checkpoint "leak".
>>> +		 */
>>> +		ret = -EBUSY;
>>> +	if (ret == -EBUSY)
>>> +		ckpt_write_err(ctx, "ep_items_checkpoint(): checkpoint leak detected.\n", "");
>> It would be useful (for the user) to know which fd/item caused the
>> leak, or whether the leak was because i != h->num_items  (You could
>> use two ckpt_write_err(), one inside the mutex and on here).
> 
> That's a good idea. Note the "fd" in the item isn't necessarily what's
> in the fd table and the index "i" isn't a stable indicator of where we
> are in the epoll set. So I'm going to have it print out the path to the
> "file" rather than either of those things.
> 

Good point. Then please note both - the (original) fd may be a
useful fact for the developer trying to understand what failed.

>> Also, the prototype of ckpt_write_err() has changed, see the code.
> 
> I noticed that -- that's why I put in the "". However I see that it's
> much more complicated than the prototype implied. Here's my idiotic
> thought process:
> 
> extern int ckpt_write_err(struct ckpt_ctx *ctx, char *ptr, char *fmt,
> ...);
> 
> Gosh it looks like an arbitrary string with the incredibly redundant
> name "ptr" which tells me absolutely nothing about what goes there.
> 
> Now that you've pointed this out I've dug a little deeper. Calling it the
> "pre-format" string is also not very informative -- I can guess that it
> goes before "fmt" based on its position in the arguments. The
> best information comes from the comment above __ckpt_generate_fmt():
> 
> 	 * PREFMT is constructed from @prefmt by subtituting format snippets
> 	 * according to the contents of @prefmt.  The format characters in
> 	 * @prefmt can be E (error), O (objref), P (pointer), S (string) and
> 	 * V (variable/symbol). For example, E will generate a "err %d" in
> 	 * PREFMT (see prefmt_array below).
> 	...
> 
> In other words it has a very specific encoding which neither the
> prototype nor the function itself hint at or bother to describe. I had to
> dig down through the vararg layers to find that description.
> 
> There needs to be information near the prototype in checkpoint.h and near
> the function itself which shouts to anyone reading it that "ptr" is some
> oddly-encoded string.

You are correct. Will add.

> 
> It would also be better if each prefmt element required a % before it -- then
> reviewers would probably recognize it as a "second" format string with
> strange conversion specifications (%E, %O, %P, %V, %S).

Adding "%" sounds useful. I'll do that.

> 
> I can't help but think there's more improvement possible. Some less
> well-thought-out ideas:
> 
> It might be even better to remove the prefmt string and have ckpt_write_err
> variants for specialized areas of the code. If area "foo" could use an
> err, objref, and file flags you might define:
> 
> int ckpt_write_foo_err(struct ckpt_ctx *ctx, int err, __s32 objref, int
> 			flags, char *fmt, ...);

I thought about it, but wished to avoid proliferation of these
variants.

> 
> Otherwise I wonder if it would be better to join the prefmt and fmt
> strings by just defining our own, new, conversion specifiers.
> 

Thought about it, but that would limit us in the conversion specifiers
that we can use, because many are used by printf already. Perhaps one
way to do it is use
	"%Zxyz"
where "%Z" tells the following letters indicate a ckpt_write_err()
format, and then "xyz" are the letters from the current @prefmt.

Thoughts ?

[...]

>>> +
>>> +	h = ckpt_read_obj(ctx, 0,
>>> +			  sizeof(*h) + max_user_watches*sizeof(h->items[0]));
>> s/ckpt_read_obj/ckpt_read_buf_type/
>> Saves you the @type and @len test below.
> 
> Good. That means I can get rid of the portion of the patch that removed
> "static" from ckpt_read_obj too...
> 
> Again, the prototype in checkpoint.h is misleading. It says the second
> argument is "len", not "max" (or better: "maxlen"). Naming is critical --
> even for prototype parameters in headers.

Yes, I forgot to update the prototype in the header.

> 
> I think I see a bug in either ckpt_read_obj or its kerneldocs:
> 
> 	/**
> 	 * ckpt_read_obj - allocate and read an object (ckpt_hdr followed by
> 	 * payload)
> 	 * @ctx: checkpoint context
> 	 * @h: object descriptor
> 	 * @len: desired payload length (if 0, flexible)
> 	 * @max: maximum payload length
> 	 *
> 	 * Return: new buffer allocated on success, error pointer otherwise
> 	 */
> 	static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
> 	{
> 		struct ckpt_hdr hh;
> 		struct ckpt_hdr *h;
> 		int ret;
> 
> 	 again:
> 		ret = ckpt_kread(ctx, &hh, sizeof(hh));
> 		if (ret < 0)
> 			return ERR_PTR(ret);
> 		_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
> 			    hh.type, hh.len, len, max);
> 		if (hh.len < sizeof(*h))
> 			return ERR_PTR(-EINVAL);
> 
> 		if (hh.type == CKPT_HDR_OBJREF) {
> 			ret = _ckpt_read_objref(ctx, &hh);
> 			if (ret < 0)
> 				return ERR_PTR(ret);
> 			goto again;
> 		}
> 
> 		/* if len specified, enforce, else if maximum specified, enforce */
> 		if ((len && hh.len != len) || (!len && max && hh.len > max))
> 			return ERR_PTR(-EINVAL);
> 
> The last test really should be:
> 
> 		if ((len && hh.len != len) || 
> 		   (!len && max && (hh.len - sizeof(*h)) > max))
> 			return ERR_PTR(-EINVAL);
> 
> Otherwise it's not really the maximum payload length and the "bug" is
> just the comment.

The bug is in the comment: @max is intended to tell the max (total)
buffer size returned to the user. Will fix.

[...]

>>> +	ret = 0;
>>> +	/* Restore the epoll items/watches */
>>> +	for (i = 0; !ret && i < h->num_items; i++) {
>>> +		struct epoll_event epev;
>>> +		struct file *tfile;
>>> +
>>> +		/* Get the file* for the target file */
>>> +		if (h->items[i].file_objref <= 0) {
>>> +			ret = -EINVAL;
>>> +			break;
>>> +		}
>> I should probably change the code elsewhere too, but this test
>> is unnecessary because ckpt_obj_fetch() will complain anyway.
> 
> I don't think it will complain since I don't see anything in the read or hash
> code that checks for negative objrefs. However moving this into

What is "this" that you want to move ?

> ckpt_obj_fetch() would get rid of alot of code much like passing NULL into
> kfree() does, so I'll remove this test.

ckpt_obj_fetch() won't complain about a negative value a-priori, but
the search is certain to fail. Nevertheless, I'll tighten the restart
related calls in objhash to ensure that.

[...]

> 
> Thanks for the review.

Thanks for the cross-review :)

Oren.
