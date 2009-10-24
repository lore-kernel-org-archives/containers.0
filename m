From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] epoll: Add support for checkpointing large numbers
	of epoll items
Date: Fri, 23 Oct 2009 21:32:31 -0700
Message-ID: <20091024043231.GF15092@count0.beaverton.ibm.com>
References: <ce2e15faf44e254b80578c6c62e71d8685516896.1255971848.git.matthltc@us.ibm.com>
	<d0fd1f3eb4eaa326488f59955e5b4790080f3073.1255971848.git.matthltc@us.ibm.com>
	<4AE24340.9030203@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AE24340.9030203-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
Cc: Andy Whitcroft <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Oct 23, 2009 at 07:58:56PM -0400, Oren Laadan wrote:
> 
> 
> Matt Helsley wrote:
> > Currently we allocate memory to output all of the epoll items in one
> > big chunk. At 20 bytes per item, and since epoll was designed to
> > support on the order of 10,000 items, we may find ourselves kmalloc'ing
> > 200,000 bytes. That's an order 7 allocation whereas the heuristic for
> > difficult allocations, PAGE_ALLOC_COST_ORDER, is 3.
> > 
> > Instead, output the epoll header and items separately. Chunk the output
> > much like the pid array gets chunked. This ensures that even sub-order 0
> > allocations will enable checkpoint of large epoll sets. A subsequent
> > patch will do something similar for the restore path.
> > 
> > Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> 
> BTW, In the future, please use checkpatch.pl before sending;

OK, I'll add it to my script.

> Otherwise eventually I get yelled at ... :p

Hmm, I was suprised this triggered anything from checkpatch.
Some of the checkpatch.pl complaints look OK (omitted). Others don't
seem right.

	WARNING: braces {} are not necessary for single statement blocks
	#296: FILE: fs/eventpoll.c:1492:
	+	for (i = 0, rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp),
	i++) {}

This looks like a checkpatch bug. It's a zero statement block. The
braces prevent the compiler from putting the next statement in the loop body.
Cc'ing Andy Whitcroft.

	ERROR: "(foo**)" should be "(foo **)"
	#397: FILE: fs/eventpoll.c:1593:
	+	ret = ckpt_read_payload(ctx, (void**)&items,
	num_items*sizeof(*items),

Now that just seems dumb. ) is not an identifier so the "foo *bar" pattern
which seems to inspire this pattern does not apply. The only spaces in
typecasts should be like (struct foo*) IMHO. This looks weird since typecast
is a unary operator and there should be no space between a unary
operator and its argument. Imagine:

	if (! x)
		do_something()

This looks just as absurd to me:

	(foo **)x   Or worse:   (foo **) x

Also CondingStyle says nothing about this from what I could see. So it
shouldn't be an ERROR IMHO. Ignoring this one in protest.

	WARNING: line over 80 characters
	#462: FILE: fs/eventpoll.c:1658:
	+	ret = deferqueue_add_ptr(ctx->files_deferq, ctx,
	ep_items_restore, NULL);

Over by one. My understanding is it's a warning for cases like this.
Ignoring.

	...
	total: 5 errors, 2 warnings, 457 lines checked

	./checkpatchme.patch has style problems, please review.  If any of these
	errors
	are false positives report them to the maintainer, see
	CHECKPATCH in MAINTAINERS.

Done.

> I'll also change the auto-tune-magic to fixed chunk, unless
> somebody screams.

*grumble* OK.

Cheers,
	-Matt Helsley
