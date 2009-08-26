From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] [RFC] Add checkpoint/restart support for epoll files.
Date: Wed, 26 Aug 2009 02:00:43 -0700
Message-ID: <20090826090043.GI8078@count0.beaverton.ibm.com>
References: <6d896e12f316e5ff5f44bd13ae1482dab7f9253a.1250745409.git.matthltc@us.ibm.com>
	<e820d207a3b1a3228ded29bce9b29f2179ab598b.1250745409.git.matthltc@us.ibm.com>
	<4A8D7AE2.1030705@cs.columbia.edu>
	<20090825051723.GD8078@count0.beaverton.ibm.com>
	<4A94227C.9050101@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A94227C.9050101-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Aug 25, 2009 at 01:42:20PM -0400, Oren Laadan wrote:
> 
> 
> Matt Helsley wrote:
> > On Thu, Aug 20, 2009 at 12:33:38PM -0400, Oren Laadan wrote:
> >> Hi Matt,
> >>
> >> I like the approach of the patch and use of deferqueue.
> >> See comments below.
> >>
> >> Matt Helsley wrote:
> >>> Save/restore epoll items during checkpoint/restart respectively.
> >>>
> >>> Tests for the cr_tests suite to follow. Tests pass on i386.
> >>>
> >>> TODOs (search the patch for "TODO") that could probably use some
> >>> comments:
> >>>
> 
> [...]
> 
> >>> +
> >>> +struct epoll_deferq_entry {
> >>> +	struct ckpt_ctx *ctx;
> >>> +	struct file *epfile;
> >>> +};
> >> I suggest that:
> >>
> >> 1) Add 'int fd' here,
> >> 2) in ckpt_eventpoll_items use the fd (instead of file objref)
> >>
> >> The motivation is security: if, on restart, you rely on a file objref,
> >> then malicious user can change the file objref and the restart logic
> >> may end up populating some other process's event poll items.
> >>
> >> Instead, by using an fd, we ensure that the restarting process will
> >> only modify a file that it actually owns.
> > 
> > The fd saved with the items is not necessarily matched with the file*
> > anymore. For example userspace could do:
> > 
> > fda = open("/dev/null", O_RDONLY);
> > epoll_ctl(efd, EPOLL_CTL_ADD, fda, ...);
> > fdb = dup(fda);
> > dup2(0, fda);
> > <checkpoint here>
> > epoll_ctl(efd, EPOLL_CTL_MOD, fda, ...);
> > 
> > Saving the fd would associate stdin with the epoll item and not
> > /dev/null.
> > 
> > So we can't use the fd in place of the file reference.
> 
> You are totally right. I was confused by the fact that epoll data
> does save the original fd, and assumed it was "updated" at close()
> and dup() time. But not...
> 
> ... which makes me wonder: is it impossible for a user to delete
> the original fd from the epoll using epoll_ctl(.., EPOLL_CTL_DEL...) ?
> 
> This is related to my concern during restart: the input can provide
> _any_ file objref that is valid at that time during restart, and
> plug in files owned by different processes than intended.
> 
> I'm unsure to what extent this is a security concern, and what's
> the right approach to solve it.

If it is a security concern (and I don't think it's any more a concern
than the other objrefs) then my hunch is that namespaces ought to be
able to help somehow, but I haven't really thought that through.

> Looking at ep_cmp_ffd(), it uses both the file pointer and the fd
> to find a matching entry in the RB tree; So I'd think that in that
> case you need to save both the original FD and the objref of the
> file, no ?

Yup. I believe that's what's in the patch I posted.  Each item has the
fd, events, and data that it was registered with plus a file objref.

> 
> >>> +static int ep_items_restore(void *data)
> >>> +{
> >>> +	struct ckpt_ctx *ctx = *((struct ckpt_ctx**)data);
> >> This is really obfuscated :(
> > 
> > Tell that to the author of deferqueue. ;) Since deferqueue does memcpy()
> > there's really not a better way to pass the ctx pointer.
> 
> Next time I'll use my right to remain silent :p
> 
> Seriously, maybe we can add a wrapper for this (common ?) case of
> a passing a single pointer as data. Do you think this interface
> may be usedful:
> 
> deferqueue_add_ptr(head, ptr, func, dtor)
> {
> 	return deferqueue(head, &ptr, sizeof(ptr), func, dtor);
> }
> 
> and
> 
> void *deferqueue_data_ptr(void *data)
> {
> 	return *((void **) data);
> }
> 
> [...]

Seems like a great idea to me.

> >>> +	struct ckpt_eventpoll_items *h;
> >>> +	struct eventpoll *ep;
> >>> +	struct file *epfile = NULL;
> >>> +	int ret, i = 0, remaining_watches;
> >>> +
> >>> +	/*
> >>> +	 * TODO possible kmalloc failure due to too many watches.
> >>> +	 */
> >>> +	h = ckpt_read_obj(ctx, 0,
> >>> +			  sizeof(*h) + max_user_watches*sizeof(h->items[0]));
> >> Any reason to perfer ckpt_read_obj() over ckpt_read_buf_type() ?
> >> (it will rid the check for type/len below).
> > 
> > So I could read it all at once rather than fiddle with reading the
> > header and chunking all of the input. I wanted to get something simple
> > working first and then make it work with thousands of watches.
> 
> Hmm.. ckpt_read_buf_type() calls ckpt_read_obj() like you do, then
> checks that the type matches.  So you are left with the h->h.len sanity
> check only.
> 
> [...]

So I looked at how pids are handled again. There's a slight difference
in that I also record the epfile objref and number of "items", so I
found I couldn't use similar code. I'm still working on this part of the
patch but I've already incorporated your suggestions for the next post.

> >>> +	if (!is_file_epoll(epfile))
> >>> +		goto out;
> >>> +
> >>> +	ep = epfile->private_data;
> >>> +
> >>> +	ret = -ENOSPC;
> >>> +	remaining_watches = (max_user_watches -
> >>> +			     atomic_read(&ep->user->epoll_watches));
> >>> +	if (h->num_items > remaining_watches)
> >>> +		goto out;
> >> This is tested anyway by ep_insert() below. Besides, it's racy here
> >> (user may  have another restart in parallel, and the check-modify isn't
> >> atomic. Unlike with ep_insert(), this check is for a bunch of fd's not
> >> a single one.
> > 
> > Yes, it's racy. However, we're restarting so we're primarily adding watches.
> > It's also possible we're restarting thousands of watches only to fail
> > when we add the last few. This avoids all that useless work when possible.
> 
> Is this concern worth taking the code out of its "usual" place (the
> common epoll code) and making a special case here ?

I don't think it's worth that.

Incidentally, the next version will factor out and re-use half of epoll_ctl().
The main benefit will be maintenance since it saves only about 5 lines.

> >>
> >> struct ckpt_hdr_eventpoll_item {
> > 	     ^^^^^
> > I strongly dislike this name change idea. There's no header for each item and 
> > it's obviously part of the checkpoint image. If anything, too many
> > things have "_hdr_" in their names when they lack a ckpt_hdr or don't
> > need one: ckpt_hdr_const, ckpt_hdr_pids, ckpt_hdr_socket, ckpt_hdr_sigset,
> > ckpt_hdr_sigaction, ckpt_hdr_siginfo, ckpt_hdr_rlimit, ckpt_hdr_ipc_perms*)
> 
> I have no strong opinion in either way, and what you say makes sense.
> I do strongly prefer a single common convention to all "ckpt_hdr"-less
> structures (and one to all "ckpt_hdr"-full ones). When the patches for
> this show up, I'll pull them :)

OK, I think this might deserve a code comment in the patches:

/*
 * All struct ckpt_hdr_* structs have a struct ckpt_hdr (usually as
 * their first member).
 */

> 
> > 
> > (*We shouldn't need two adjacent headers for ckpt_hdr_ipc_{shm,msg,sem}.)
> 
> Right. I'll remove the ckpt-hdr from ckpt_{hdr_}ipc_perms.

Great, thanks.

Cheers,
	-Matt Helsley
