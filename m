From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v2][PATCH 2/9] General infrastructure for checkpoint	restart
Date: Tue, 26 Aug 2008 20:38:07 -0400
Message-ID: <48B4A1EF.2090606__45147.3072557293$1219797605$gmane$org@cs.columbia.edu>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>	
	<Pine.LNX.4.64.0808202303460.17436@takamine.ncl.cs.columbia.edu>	
	<1219435302.20559.121.camel@nimitz>
	<48B21D3C.8090601@cs.columbia.edu>
	<1219768949.8680.26.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1219768949.8680.26.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Sun, 2008-08-24 at 22:47 -0400, Oren Laadan wrote:
>>> I replaced all of the uses of these with kmalloc()/kfree() and stack
>>> allocations.  I'm really not sure what these buy us since our allocators
>>> are already so fast.  tbuf, especially, worries me if it gets used in
>>> any kind of nested manner we're going to get some really fun bugs.
>> I disagree with putting some of the cr_hdr_... on the stack: first, if they
>> grow in size, it's easy to forget to change the allocation to stack.
> 
> I can buy that. 
> 
>> Second,
>> using a standard code/handling for all cr_hdr_... makes the code more readable
>> and easier for others to extend by simply following existing code.
> 
> It actually makes it harder for others to jump into because they see
> something which is basically a kmalloc() to the rest of the kernel.  We
> don't have ext2_alloc() or usb_alloc(), so I'm not sure we should have
> cr_alloc(), effectively.

I disagree. It's more than "allocate memory", it's: "give me some room on
the buffer". When we don't care about downtime (like now), it's enough to
kmalloc a temporary buffer and flush (write to the FD) immediately.

But when we will care about downtime, "the buffer" will be memory in kernel
where the entire checkpoint image data will be kept while the container is
frozen (memory contents need only be marked copy-on-write, not explicitly
buffered).

In this setting, cr_kwrite() will not really write the data to the FD, but
only record somewhere that the data exists. Only after the container resumes
execution will we eventually write the data to the FD and free the buffer.

(This is also useful in case you want to keep the checkpoint image entirely
in memory without flushing to any FD; and yes, there are use-cases for that).

So for this, instead of using kmalloc() to allocate a temp-buf, fill it with
data, and then copy that data to the actual (big) buffer, the mechanism
provides a shortcut to allocate space directly on the buffer, and save the
copy.

> 
>> The main argument for ->hbuf is that eventually we would like to buffer
>> data in the kernel to avoid potentially slow writing/reading when processes
>> are frozen during checkpoint/restart.
> 
> Um, we're writing to a file descriptor and kmap()'ing.  Those can both
> potentially be very, very slow.  I don't think that a few kmalloc()s
> thrown in there are going to be noticeable.

But you miss the point: the writing to the file descriptor in the (future)
optimized version will _not_ happen while the container is frozen. Only
much later after the container resumes, so at the end it will be:
(1) freeze container (2) dump data to in-kernel buffer (mark dirty pages
copy-on-write) (3) unfreeze container (4) write in-kernel buffer to FD.

By deferring step #4 until after the freeze-period, you can save tens and
hundreds of milliseconds, and seconds. Now the goal is to make step #2 be
as fast as possible, and every millisecond (and less) counts, e.g. to take
fast checkpoints of interactive desktops. And my experience is that in
such "workload" repetitive kmalloc/kfree inside that dump loop has a
measurable impact on performance (of course, for those objects which are
abundant).

> 
>> By using the simple cr_get_hbuf() and
>> cr_put_hbuf() we prepare for that: now they just allocate room in ->hbuf,
>> but later they will provide a pointer directly in the data buffer. Moreover,
>> it simplifies the error path since cleanup (of ->hbuf) is implicit.
> 
> It simplifies *one* error path.  But, it complicates the ctx creation
> and makes *that* error path more complex.  Pick your poison, I guess.

Actually it simplifies *many* error paths -- in *all* cr_write_...()
functions - including the future ones (and there are many to come).

> 
>> Also,
>> it is designed to allow checkpoint and restart function to be called in a
>> nested manner, again simplifying the code. Finally, my experience was that
>> it can impact performance if you are after very short downtimes, especially
>> for the checkpoint.
> 
> Right, but I'm comparing it to kmalloc()  Certainly kmalloc()s can be
> used in a nested manner.
> 
>>>> +/* read the checkpoint header */
>>>> +static int cr_read_hdr(struct cr_ctx *ctx)
>>>> +{
>>>> +	struct cr_hdr_head *hh = cr_hbuf_get(ctx, sizeof(*hh));
>>>> +	int ret;
>>>> +
>>>> +	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_HEAD);
>>>> +	if (ret < 0)
>>>> +		return ret;
>>>> +	else if (ret != 0)
>>>> +		return -EINVAL;
>>> How about just making cr_read_obj_type() stop returning positive values?
>>> Is it ever valid for it to return >0?
>> The idea with cr_read_obj_type() is that it returns the 'ptag' - parent tag -
>> field of the object that it reads in. The 'ptag' is the tag of the parent
>> object, and is useful in several places. For instance, the 'ptag' of an MM
>> header identifies (is equal to) the 'tag' of TASK to which it belongs. In
>> this case, the 'ptag' should be zero because it has no parent object.
>>
>> I'll change the variable name from 'ret' to 'ptag' to make it more obvious.
> 
> Since this ptag isn't actually used, I can't really offer a suggestion.
> I don't see the whole picture.

You can see how it's used in the code that dumps files. Or look at the next
incarnation of the patch.

Oren.
