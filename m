From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v2][PATCH 2/9] General infrastructure for checkpoint	restart
Date: Sun, 24 Aug 2008 22:47:24 -0400
Message-ID: <48B21D3C.8090601__48575.4909147092$1219632573$gmane$org@cs.columbia.edu>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>	
	<Pine.LNX.4.64.0808202303460.17436@takamine.ncl.cs.columbia.edu>
	<1219435302.20559.121.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1219435302.20559.121.camel@nimitz>
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
> On Wed, 2008-08-20 at 23:04 -0400, Oren Laadan wrote:
>> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
>> new file mode 100644
>> index 0000000..25343f5
>> --- /dev/null
>> +++ b/checkpoint/checkpoint.c

[...]

>> +/* write the checkpoint header */
>> +static int cr_write_hdr(struct cr_ctx *ctx)
>> +{
>> +	struct cr_hdr h;
>> +	struct cr_hdr_head *hh = ctx->hbuf;
>> +	struct new_utsname *uts;
>> +	struct timeval ktv;
>> +
>> +	h.type = CR_HDR_HEAD;
>> +	h.len = sizeof(*hh);
>> +	h.ptag = 0;
>> +
>> +	do_gettimeofday(&ktv);
>> +
>> +	hh->magic = CR_MAGIC_HEAD;
>> +	hh->major = (LINUX_VERSION_CODE >> 16) & 0xff;
>> +	hh->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
>> +	hh->patch = (LINUX_VERSION_CODE) & 0xff;
> 
> We at least neex EXTRAVERSION in there if we're going to even pretend
> this is useful, right?  is this redundant with utsname() below?

It isn't clear exactly what we need in the header in terms of version, config,
and compile information. I put this as a starter, because it's obvious and
because this info is likely to be useful even at the user/admin level. I don't
expect this to remain as is as we continue development.

[...]

>> +struct cr_ctx {
>> +	pid_t pid;		/* container identifier */
>> +	int crid;		/* unique checkpoint id */
>> +
>> +	unsigned long flags;
>> +	unsigned long oflags;	/* restart: old flags */
>> +
>> +	struct file *file;
>> +	int total;		/* total read/written */
>> +
>> +	void *tbuf;		/* temp: to avoid many alloc/dealloc */
>> +	void *hbuf;		/* header: to avoid many alloc/dealloc */
>> +	int hpos;
> 
> alloc/delloc is not a bad thing. :)  I think at least a few of these
> should be moved over to stack or kmalloc()/kfree().

Definitely the comment is misleading. See comment below.

> 
>> +	struct path *vfsroot;	/* container root */
>> +};
> 
> Can a container only have one vfsroot?

This is a temporary solution since this patchset doesn't really handle real
containers yet. Will add a FIXME comment.

> 
>> +
>> +/* cr_ctx: flags */
>> +#define CR_CTX_CKPT	0x1
>> +#define CR_CTX_RSTR	0x2
> 
> enum?

These are flags (more will come later).

[...]

>> +struct cr_hdr_task {
>> +	__u64 state;
>> +	__u32 exit_state;
>> +	__u32 exit_code, exit_signal;
>> +
>> +	__u64 utime, stime, utimescaled, stimescaled;
>> +	__u64 gtime;
>> +	__u64 prev_utime, prev_stime;
>> +	__u64 nvcsw, nivcsw;
>> +	__u64 start_time_sec, start_time_nsec;
>> +	__u64 real_start_time_sec, real_start_time_nsec;
>> +	__u64 min_flt, maj_flt;
>> +
>> +	__s16 task_comm_len;
>> +	char comm[TASK_COMM_LEN];
>> +} __attribute__ ((aligned (8)));
> 
> TASK_COMM_LEN might be subject to changing.  Can it be part of the
> user<->kernel ABI?

Good point. Having the 'task_comm_len' field there isn't enough because the
size of the entire struct changes anyways.

[...]

> 
> ...
>> +/*
>> + * During restart the code reads in data from the chekcpoint image into a
>> + * temporary buffer (ctx->hbuf). Because operations can be nested, one
>> + * should call cr_hbuf_get() to reserve space in the buffer, and then
>> + * cr_hbuf_put() when it no longer needs that space
>> + */
>> +
>> +#include <linux/version.h>
>> +#include <linux/sched.h>
>> +#include <linux/file.h>
>> +
>> +#include "ckpt.h"
>> +#include "ckpt_hdr.h"
>> +
>> +/**
>> + * cr_hbuf_get - reserve space on the hbuf
>> + * @ctx: checkpoint context
>> + * @n: number of bytes to reserve
>> + */
>> +void *cr_hbuf_get(struct cr_ctx *ctx, int n)
>> +{
>> +	void *ptr;
>> +
>> +	BUG_ON(ctx->hpos + n > CR_HBUF_TOTAL);
>> +	ptr = (void *) (((char *) ctx->hbuf) + ctx->hpos);
>> +	ctx->hpos += n;
>> +	return ptr;
>> +}
>> +
>> +/**
>> + * cr_hbuf_put - unreserve space on the hbuf
>> + * @ctx: checkpoint context
>> + * @n: number of bytes to reserve
>> + */
>> +void cr_hbuf_put(struct cr_ctx *ctx, int n)
>> +{
>> +	BUG_ON(ctx->hpos < n);
>> +	ctx->hpos -= n;
>> +}
> 
> I replaced all of the uses of these with kmalloc()/kfree() and stack
> allocations.  I'm really not sure what these buy us since our allocators
> are already so fast.  tbuf, especially, worries me if it gets used in
> any kind of nested manner we're going to get some really fun bugs.

I disagree with putting some of the cr_hdr_... on the stack: first, if they
grow in size, it's easy to forget to change the allocation to stack. Second,
using a standard code/handling for all cr_hdr_... makes the code more readable
and easier for others to extend by simply following existing code.

The main argument for ->hbuf is that eventually we would like to buffer
data in the kernel to avoid potentially slow writing/reading when processes
are frozen during checkpoint/restart. By using the simple cr_get_hbuf() and
cr_put_hbuf() we prepare for that: now they just allocate room in ->hbuf,
but later they will provide a pointer directly in the data buffer. Moreover,
it simplifies the error path since cleanup (of ->hbuf) is implicit. Also,
it is designed to allow checkpoint and restart function to be called in a
nested manner, again simplifying the code. Finally, my experience was that
it can impact performance if you are after very short downtimes, especially
for the checkpoint.

The use of ->tbuf is less critical and is mainly for performance and to
simplify the error path, never to be called nested. I'm ok with removing
it for now.

[...]

>> +/* read the checkpoint header */
>> +static int cr_read_hdr(struct cr_ctx *ctx)
>> +{
>> +	struct cr_hdr_head *hh = cr_hbuf_get(ctx, sizeof(*hh));
>> +	int ret;
>> +
>> +	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_HEAD);
>> +	if (ret < 0)
>> +		return ret;
>> +	else if (ret != 0)
>> +		return -EINVAL;
> 
> How about just making cr_read_obj_type() stop returning positive values?
> Is it ever valid for it to return >0?

The idea with cr_read_obj_type() is that it returns the 'ptag' - parent tag -
field of the object that it reads in. The 'ptag' is the tag of the parent
object, and is useful in several places. For instance, the 'ptag' of an MM
header identifies (is equal to) the 'tag' of TASK to which it belongs. In
this case, the 'ptag' should be zero because it has no parent object.

I'll change the variable name from 'ret' to 'ptag' to make it more obvious.

[...]

> 
> -- Dave
> 

Oren.
