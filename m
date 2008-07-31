From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Thu, 31 Jul 2008 16:25:35 -0500
Message-ID: <20080731212534.GA7858@us.ibm.com>
References: <Pine.LNX.4.64.0807292325290.9868@takamine.ncl.cs.columbia.edu>
	<20080730220752.GA3518@us.ibm.com>
	<4890E930.9090204@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4890E930.9090204-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>
>
> Serge E. Hallyn wrote:
>> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>> +int do_checkpoint(struct cr_ctx *ctx)
>>> +{
>>> +	int ret;
>>> +
>>> +	/* FIX: need to test whether container is checkpointable */
>>> +
>>> +	ret = cr_write_hdr(ctx);
>>> +	if (!ret)
>>> +		ret = cr_write_task(ctx, current);
>>> +	if (!ret)
>>> +		ret = cr_write_tail(ctx);
>>> +
>>> +	/* on success, return (unique) checkpoint identifier */
>>> +	if (!ret)
>>> +		ret = ctx->crid;
>>
>> Does this crid have a purpose?
>
> yes, at least three; both are for the future, but important to set the
> meaning of the return value of the syscall already now. The "crid" is
> the CR-identifier that identifies the checkpoint. Every checkpoint is
> assigned a unique number (using an atomic counter).
>
> 1) if a checkpoint is taken and kept in memory (instead of to a file) then
> this will be the identifier with which the restart (or cleanup) would refer
> to the (in memory) checkpoint image
>
> 2) to reduce downtime of the checkpoint, data will be aggregated on the
> checkpoint context, as well as referenced to (cow-ed) pages. This data can
> persist between calls to sys_checkpoint(), and the 'crid', again, will be
> used to identify the (in-memory-to-be-dumped-to-storage) context.
>
> 3) for incremental checkpoint (where a successive checkpoint will only
> save what has changed since the previous checkpoint) there will be a need
> to identify the previous checkpoints (to be able to know where to take
> data from during restart). Again, a 'crid' is handy.
>
> [in fact, for the 3rd use, it will make sense to write that number as
> part of the checkpoint image header]
>
> Note that by doing so, a process that checkpoints itself (in its own
> context), can use code that is similar to the logic of fork():
>
> 	...
> 	crid = checkpoint(...);
> 	switch (crid) {
> 	case -1:
> 		perror("checkpoint failed");
> 		break;
> 	default:
> 		fprintf(stderr, "checkpoint succeeded, CRID=%d\n", ret);
> 		/* proceed with execution after checkpoint */
> 		...
> 		break;
> 	case 0:
> 		fprintf(stderr, "returned after restart\n");
> 		/* proceed with action required following a restart */
> 		...
> 		break;
> 	}
> 	...

Thanks - for this and the later explanations in replies to Louis.

Really I had no doubt it had a purpose :)  but wasn't sure what it was.
Quite clear now.  Thanks.

-serge
