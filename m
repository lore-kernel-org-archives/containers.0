From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v2][PATCH 2/9] General infrastructure for checkpoint	restart
Date: Sun, 24 Aug 2008 01:58:36 -0400
Message-ID: <48B0F88C.2090403__38281.8518243313$1219557904$gmane$org@cs.columbia.edu>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0808202303460.17436@takamine.ncl.cs.columbia.edu>
	<20080821093529.GG581@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080821093529.GG581-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org



Louis Rilling wrote:
> On Wed, Aug 20, 2008 at 11:04:13PM -0400, Oren Laadan wrote:
>> Add those interfaces, as well as helpers needed to easily manage the
>> file format. The code is roughly broken out as follows:
>>
>> ckpt/sys.c - user/kernel data transfer, as well as setup of the
>> checkpoint/restart context (a per-checkpoint data structure for
>> housekeeping)
>>
>> ckpt/checkpoint.c - output wrappers and basic checkpoint handling
>>
>> ckpt/restart.c - input wrappers and basic restart handling
>>
>> Patches to add the per-architecture support as well as the actual
>> work to do the memory checkpoint follow in subsequent patches.
>>
> 
> [...]
> 
>> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
>> new file mode 100644
>> index 0000000..2891c48
>> --- /dev/null
>> +++ b/checkpoint/sys.c
> 
> [...]
> 
>> +/*
>> + * helpers to manage CR contexts: allocated for each checkpoint and/or
>> + * restart operation, and persists until the operation is completed.
>> + */
>> +
>> +static atomic_t cr_ctx_count;	/* unique checkpoint identifier */
> 
> I thought we agreed that this counter should be per-container. Perhaps add a
> TODO here?

True.

> 
>> +
>> +void cr_ctx_free(struct cr_ctx *ctx)
>> +{
>> +
>> +	if (ctx->file)
>> +		fput(ctx->file);
>> +	if (ctx->vfsroot)
>> +		path_put(ctx->vfsroot);
>> +
>> +	free_pages((unsigned long) ctx->tbuf, CR_TBUF_ORDER);
>> +	free_pages((unsigned long) ctx->hbuf, CR_HBUF_ORDER);
>> +
>> +	kfree(ctx);
>> +}
>> +
>> +struct cr_ctx *cr_ctx_alloc(pid_t pid, struct file *file, unsigned long flags)
>> +{
>> +	struct cr_ctx *ctx;
>> +
>> +	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
>> +	if (!ctx)
>> +		return NULL;
>> +
>> +	ctx->tbuf = (void *) __get_free_pages(GFP_KERNEL, CR_TBUF_ORDER);
>> +	ctx->hbuf = (void *) __get_free_pages(GFP_KERNEL, CR_HBUF_ORDER);
>> +	if (!ctx->tbuf || !ctx->hbuf)
>> +		goto nomem;
>> +
>> +	ctx->pid = pid;
>> +	ctx->flags = flags;
>> +
>> +	ctx->file = file;
>> +	get_file(file);
>> +
>> +	/* assume checkpointer is in container's root vfs */
> 
> I'm a bit puzzled by this assumption. I would say: either this is a
> self-checkpoint (only current process), or this is a container checkpoint. In
> the latter case, I expect that in the general case the checkpointer lives
> outside the container (and the interface of sys_checkpoint() below confirms
> this), so it's root fs is probably not the container's one.
> 
> Does it differ from what you're planning?

You are correct. We lack infrastructure for what I'd call "container-object",
and the patchset does not yet tackle a container and multiple tasks, so this
is an interim solution. Will add a FIXME comment.

Thanks,

Oren.
