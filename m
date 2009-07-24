From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH] checkpoint/restart: Add support for epoll
Date: Fri, 24 Jul 2009 13:22:40 -0400
Message-ID: <4A69EDE0.4090205@librato.com>
References: <20090714235405.GH5213@count0.beaverton.ibm.com>	<4A697242.60606@cs.columbia.edu>
	<20090724170401.GG5878@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090724170401.GG5878-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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



Matt Helsley wrote:
> On Fri, Jul 24, 2009 at 04:35:14AM -0400, Oren Laadan wrote:
>>
>> Matt Helsley wrote:
>>>  Add checkpoint/restart support for epoll files. This is the minimum
>>>  support necessary to recreate the epoll item sets without any pending
>>>  events.
>>>
>>>  This is an RFC to show where I'm going with the patch and give an idea
>>>  of how much code I expect it will take. Compiles and boots on x86 but
>>>  I haven't tested it.
>>>
>>>  Caveats: Does not correctly support restoring epoll fds to epoll sets
>>> 	  as this requires some recursion detection/avoidance. See the
>>> 	  "TODO" that mentions deferqueues.
>>>
>>> 	  Does not attempt to save pending event information for
>>> 	  delivery during restart.
>>>
>>> 	  TODO: Look into if we need a restart block for epoll_wait().
>> Since epoll restore can only complete after all fd's of a task have
>> been restores, there is little advantage to even attempt restore
>> earlier, on the fly.
>>
>> Instead, I suggest that first epoll fd's be created (like all other
>> files), and after all fd's are in place, the epoll state be restored.
>>
>> To avoid keeping potentially large data describing this state in the
>> kernel, modify checkpoint to only dump the internal state of epoll
>> fd's after all other fd's of the task have been dumped.
>>
>> In both cases deferqueue is our friend:
>>
>> At checkpoint, have do_checkpoint_file_table() setup a deferqueue
>> to which checkpoint_file_desc() may add work. The deferqueue will
>> be executed at the end of do_checkpoint_file_table(), and dump the
>> state of each epoll fd.
>>
>> At restart, do_restore_file_table() will do the same: setup a
>> deferqueue and use it to restore the state of all epoll fd's.
>>
>>> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>> ---
>>>  checkpoint/files.c             |   13 +++
>>>  fs/eventpoll.c                 |  181 +++++++++++++++++++++++++++++++++++++++-
>>>  include/linux/checkpoint_hdr.h |   15 ++++
>>>  include/linux/eventpoll.h      |   14 +++-
>>>  4 files changed, 221 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/checkpoint/files.c b/checkpoint/files.c
>>> index 5ca2e6c..7233a9b 100644
>>> --- a/checkpoint/files.c
>>> +++ b/checkpoint/files.c
>>> @@ -484,6 +484,11 @@ struct restore_file_ops {
>>>  				  struct ckpt_hdr_file *ptr);
>>>  };
>>>  
>>> +#ifdef CONFIG_EPOLL
>>> +extern struct file* ep_file_restore(struct ckpt_ctx *ctx,
>>> +				    struct ckpt_hdr_file *ptr);
>>> +#endif
>>> +
>> Already in eventpoll.h ?
> 
> Yup, good point. Fixed.
> 
>>>  static struct restore_file_ops restore_file_ops[] = {
>>>  	/* ignored file */
>>>  	{
>>> @@ -503,6 +508,14 @@ static struct restore_file_ops restore_file_ops[] = {
>>>  		.file_type = CKPT_FILE_PIPE,
>>>  		.restore = pipe_file_restore,
>>>  	},
>>> +#ifdef CONFIG_EPOLL
>>> +	/* epoll */
>>> +	{
>>> +		.file_name = "EPOLL",
>>> +		.file_type = CKPT_FILE_EPOLL,
>>> +		.restore = ep_file_restore,
>>> +	},
>>> +#endif
>>>  };
>>>  
>>>  static struct file *do_restore_file(struct ckpt_ctx *ctx)
>>> diff --git a/fs/eventpoll.c b/fs/eventpoll.c
>>> index 5458e80..9b2414b 100644
>>> --- a/fs/eventpoll.c
>>> +++ b/fs/eventpoll.c
>>> @@ -668,10 +668,17 @@ static unsigned int ep_eventpoll_poll(struct file *file, poll_table *wait)
>>>  	return pollflags != -1 ? pollflags : 0;
>>>  }
>>>  
>>> +#ifdef CONFIG_CHECKPOINT
>>> +static int ep_eventpoll_checkpoint(struct ckpt_ctx *ctx, struct file *file);
>>> +#else
>>> +#define ep_eventpoll_checkpoint NULL
>>> +#endif
>>> +
>>>  /* File callbacks that implement the eventpoll file behaviour */
>>>  static const struct file_operations eventpoll_fops = {
>>>  	.release	= ep_eventpoll_release,
>>> -	.poll		= ep_eventpoll_poll
>>> +	.poll		= ep_eventpoll_poll,
>>> +	.checkpoint 	= ep_eventpoll_checkpoint,
>>>  };
>>>  
>>>  /* Fast test to see if the file is an evenpoll file */
>>> @@ -1410,6 +1417,178 @@ SYSCALL_DEFINE6(epoll_pwait, int, epfd, struct epoll_event __user *, events,
>>>  
>>>  #endif /* HAVE_SET_RESTORE_SIGMASK */
>>>  
>>> +#ifdef CONFIG_CHECKPOINT
>>> +#include <linux/checkpoint.h>
>>> +#include <linux/checkpoint_hdr.h>
>>> +
>> Each file/fd registered in an epoll fd produces a reference count
>> to the target file, this needs to be taken into account for leak
>> detection when collecting references.
>>
>> I'm thinking of adding a new fops method for files for this purpose:
>> e.g. collect(), such that collect_file_desc() will invoke this method
>> on the file if that method is non-NULL.
>>
>> (Turns out that it's useful also for ptys/ttys, since the underlying
>> tty also needs to be counted for leaks).
>>
>> For epoll, the collect() method will add all those files that are
>> being tracked.
> 
> Sounds good to me -- it was on my TODO list. Here's a rough draft of the
> collect routine that I've got:
> 
> static int ep_file_collect(struct ckpt_ctx *ctx, struct file *file)
> {
>         struct rb_node *rbp;
>         struct eventpoll *ep;
>         int rc = 0;
> 
> #if 0
> 	/* Not needed if we have a "collect" function ptr, otherwise
> 	   can be called unconditionally from ckpt collect files path
> 	   and this will exit early.. */
>         if (!is_file_epoll(file))
>                 return rc;
> #endif
> 
>         ep = file->private_data;
>         mutex_lock(&ep->mtx);
>         for (rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp), nitems++) {
>                 struct epitem *epi;
> 
>                 epi = rb_entry(rbp, struct epitem, rbn);
>                 rc = ckpt_obj_collect(ctx, epi->ffd.file, CKPT_OBJ_FILE);
>                 if (rc < 0)
> 			break;
>         }
>         mutex_unlock(&ep->mtx);
> 	return rc;
> }

Looks ok to me.

> 
> 
>>> +static int ep_eventpoll_checkpoint(struct ckpt_ctx *ctx, struct file *file)
>>> +{
>>> +	struct ckpt_hdr_file_eventpoll *h;
>>> +	struct ckpt_eventpoll_item *cepi;
>>> +	struct rb_node *rbp;
>>> +	struct eventpoll *ep;
>>> +	int nitems = 0, rc = -ENOMEM;
>>> +
>>> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_EPOLL);
>>> +	if (!h)
>>> +		return rc;
>>> +
>>> +	ep = file->private_data;
>>> +	/* TODO see if we need mutex_lock(&ep->mtx);*/
>> Yes we do, especially for subtree (non-full-container) checkpoints
>> where another, not-checkpointed process, may modify it concurrently.
> 
> OK.
> 
>>> +	for (rbp = rb_first(&ep->rbr); rbp && nitems++; rbp = rb_next(rbp)) {}
>>> +	h->num_items = nitems;
>>> +	h->common.f_type = CKPT_FILE_EPOLL;
>>> +	rc = checkpoint_file_common(ctx, file, &h->common);
>>> +	if (!rc) {
>>> +		/*
>>> +		 * We write this in such a weird way! The problem is we want
>>> +		 * to use the common file checkpoint code above but we also
>>> +		 * want a variable number of saved epitems to follow the
>>> +		 * num_items field. So we write out the header type and length,
>>> +		 * then we write the remaining, fixed-size part of the struct.
>>> +		 * Finally we'll write each epitem by walking the rbtree.
>>> +		 */
>> If we write the epoll-specific state later (as suggested above),
>> then this weirdness disappears.
>>
>> And if not, I suggest that you separate this header from the actual
>> epoll-specific state, namely the array of epoll elements. The latter
>> should go into its own object.
>>
>> Besides, during restart, the entire object will be read into memory,
>> and the array can be (or be made) very large.
> 
> Sure.
> 
>>> +		h->common.h.len += nitems*sizeof(*cepi);
>>> +		rc = ckpt_write_obj_type(ctx, NULL, h->common.h.len,
>>> +					 h->common.h.type);
>>> +		ckpt_kwrite(ctx, ((void*)&h->common.h) + sizeof(h->common.h),
>>> +			    sizeof(*h) - sizeof(h->common.h));
>>> +	}
>>> +	ckpt_hdr_put(ctx, h);
>>> +	if (rc)
>>> +		goto out;
>>> +
>>> +	/* 
>>> +	 * FIXME for now we do it one at a time. Later we might do it like
>>> +	 * checkpoint_pids() for better performance since there can be many
>>> +	 * more epoll items than pids.
>>> +	 */
>> Defer the writing below ...
> 
> OK
> 
>>> +	cepi = ckpt_hdr_get(ctx, sizeof(*cepi));
>>> +	for (rbp = rb_first(&ep->rbr); rbp; rbp = rb_next(rbp)) {
>>> +		struct epitem *epi = rb_entry(rbp, struct epitem, rbn);
>>> +		cepi->fd = epi->ffd.fd;
>>> +		cepi->events = epi->event.events;
>>> +		cepi->data = epi->event.data;
>>> +		if (ckpt_kwrite(ctx, cepi, sizeof(*cepi)) < 0)
>>> +			break;
>>> +	}
>>> +	_ckpt_hdr_put(ctx, cepi, sizeof(*cepi));
>>> +out:
>>> +	/*mutex_unlock(&ep->mtx);*/
>>> +	return rc;
>>> +}
>>> +
>>> +struct file* ep_file_restore(struct ckpt_ctx *ctx,
>>> +			     struct ckpt_hdr_file *ptr)
>>> +{
>>> +	struct ckpt_hdr_file_eventpoll *h;
>>> +	struct eventpoll *ep;
>>> +	struct file *epfile;
>>> +	int epfd, error, i;
>>> +
>>> +	h = container_of(ptr, struct ckpt_hdr_file_eventpoll, common);
>>> +	if (h->common.h.type != CKPT_HDR_FILE_EPOLL ||
>>> +	    h->common.h.len < sizeof(*h) ||
>>> +	    h->common.f_type != CKPT_FILE_EPOLL)
>>> +		return ERR_PTR(-EINVAL);
>>> +
>>> +	/* limit max ep watches and the use of flags */
>>> +	if (h->num_items >= max_user_watches)
>>> +		return ERR_PTR(-ENOSPC);
>> This check should be against the sum of all epoll fd's per user.
>> It will take place elsewhere, and here it's incomplete and doesn't
>> add much.
> 
> Yeah, I noticed that too. Currently, I've got:
> 
>        /* Limit max ep watches. */
>         user = get_current_user();
>         remaining_watches = (max_user_watches -
>                              atomic_read(&user->epoll_watches));
>         free_uid(user);
>         if (h->num_items > remaining_watches)
>                 return ERR_PTR(-ENOSPC);
> 
> ep_insert() checks user->epoll_watches too. So even the original version
> would have failed eventually if the number of watches would have been
> exceeded.
> 
> The check in ep_insert() also means we'll properly enforce the limit even
> if we're running in parallel with other epoll file restores.
> 
> So really this check is redundant. I added it originally with the idea
> that I might not be able to use ep_insert() directly. Now I'm thinking
> it might be better to remove it entirely.

Note that by reusing code from epoll_ctl() (after refactoring),
you'll get all the standard checks, including this one, for free.

> 
>>> +	if (h->common.f_flags & ~EPOLL_CLOEXEC)
>>> +		return ERR_PTR(-EINVAL);
>>> +
>>> +	/* similar to epoll_create() */
>>> +	error = ep_alloc(&ep);
>>> +	if (error < 0)
>>> +		return ERR_PTR(error);
>>> +	error = anon_inode_getfd("[eventpoll]", &eventpoll_fops, ep,
>>> +				 ptr->f_flags & O_CLOEXEC);
>>> +	if (error < 0) {
>>> +		ep_free(ep);
>>> +		return ERR_PTR(error);
>>> +	}
>>> +
>>> +	/* Everything's allocated, we just need a file* */
>>> +	epfd = error;
>>> +	epfile = fget(epfd);
>>> +	BUG_ON(!epfile);
>> Is there a reason not to use sys_epoll_create(), or refactor it
>> and use the common code ?
> 
> Yeah, I'll reuse it.
> 
>>> +
>>> +	/* Restore the common file bits */
>>> +	i = 0;
>>> +	error = restore_file_common(ctx, epfile, ptr);
>>> +	if (error < 0)
>>> +		goto error_return;
>>> +
>>> +	/* Restore the epoll items/watches */
>>> +	for (; i < h->num_items; i++) {
>> Defer these ...
> 
> OK.
> 
>>> +		/* 
>>> +		 * Loop body like multiple epoll_ctl(ep, ADD, event)
>>> +		 * calls except we've already done much of the checking.
>>> +		 */
>>> +		struct ckpt_eventpoll_item cepi;
>>> +		struct epoll_event epev;
>>> +		struct epitem *epi;
>>> +		struct file *tfile;
>>> +
>>> +		error = ckpt_kread(ctx, &cepi, sizeof(cepi));
>>> +		if (error < 0) {
>>> +			i++;
>>> +			break;
>>> +		}
>>> +		epev.events = cepi.events;
>>> +		epev.data = cepi.data;
>> The code below is a duplicate of sys_epoll_ctl(). Is there a reason
>> not to use that code, or refactor it and share the common code ?
> 
> I certainly can't reuse it directly since it does a copy_from_user().
> Also I've already got the epoll file* and know the op. I'll look for a
> good way to factor common pieces from both sys_epoll_ctl() and
> ep_file_restore().
> 
>>> +
>>> +		/* Get the file* for the target file */
>>> +		error = -EFAULT;
>>> +		tfile = fget(cepi.fd);
>>> +		if (!tfile) {
>>> +			/*
>>> +			 * TODO delayed addition of epitem because 
>>> +			 * tfile hasn't been restored yet.
>>> +			 */
>>> +			continue;
>>> +		}
>>> +
>>> +		/* The target file descriptor must support poll */
>>> +		error = -EPERM;
>>> +		if (!tfile->f_op || !tfile->f_op->poll)
>>> +			goto error_tgt_fput;
>>> +
>>> +		/* Cannot add an epoll file descriptor inside itself. */
>>> +		error = -EINVAL;
>>> +		if (epfile == tfile)
>>> +			goto error_tgt_fput;
>>> +
>>> +		/* mutex_lock(&ep->mtx); TODO check if we need */
>> Yes, please.
> 
> OK.
> 
>>> +		epi = ep_find(ep, tfile, cepi.fd);
>>> +		if (!epi) {
>>> +			epev.events |= POLLERR | POLLHUP;
>>> +			error = ep_insert(ep, &epev, tfile, cepi.fd);
>>> +		} else
>>> +			error = -EEXIST;
>>> +		/* mutex_unlock(&ep->mtx); */
>>> +error_tgt_fput:
>>> +		fput(tfile);
>>> +		if (error < 0)
>>> +			break;
>>> +	}
>>> +error_return:
>>> +	/* Read the remaining number of items. */
>>> +	for (; i < h->num_items; i++) {
>>> +		struct ckpt_eventpoll_item cepi;
>>> +		ckpt_kread(ctx, &cepi, sizeof(cepi));
>>> +	}
>> What's the purpose of this ?
> 
> If we encounter an error we're left in the middle of the epoll item
> array. This effectively seeks to the end of the array. Not needed
> when deferring as you suggested since it changes the way we read the
> ckpt image..

Ok. I actually wondered what is the purpose of seeking to the end
of the array after you detect an error that would clearly abort the
restart ...

Thanks,

Oren.

> 
>>> +	if (error < 0) {
>>> +		/* TODO closeup epfile and epfd */
>>> +		fput(epfile);
>>> +		sys_close(epfd);
>> sys_close() should happen regardless of whether we succeeded or
>> failed.
> 
> OK, for some reason I thought restore_file_desc() tried fget() before
> resorting to attach_file()...
> 
> Thanks for the review.
> 
> Cheers,
> 	-Matt Helsley
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
