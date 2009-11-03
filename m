From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 01/12] define a new set of functions for error and debug
	logging
Date: Tue, 03 Nov 2009 11:58:35 -0500
Message-ID: <4AF0613B.2030804@librato.com>
References: <1257200620-15499-1-git-send-email-serue@us.ibm.com>
	<1257200620-15499-2-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257200620-15499-2-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> The checkpoint context now includes buffers for an expanded
> format and for messages to be written out.  A mutex protects
> these buffers as they are being built up and written out.
> ckpt_msg() will write general informative (debug) messages to
> syslog and an optional user-provided logfile.  ckpt_err() will
> write errors to the same places, and, if it is a checkpoint
> operation, also to the checkpoint image.
> 
> (This is intended to implement Oren's suggestion verbatim)
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

[...]

> +void _ckpt_msg_complete(struct ckpt_ctx *ctx)
> +{
> +	int ret;
> +
> +	if (ctx->kflags & CKPT_CTX_CHECKPOINT) {
> +		ret = ckpt_write_obj_type(ctx, NULL, 0, CKPT_HDR_ERROR);

The _ckpt_msg_... interface is (will be?) used also for non-errors.
So writing and error record should also depend on ctx->errno, to be
set by someone before (ckpt_err ?)

> +		if (!ret)
> +			ret = ckpt_write_string(ctx, ctx->msg, ctx->msglen);
> +		if (ret < 0)
> +			printk(KERN_NOTICE "c/r: error string unsaved (%d): %s\n",
> +			       ret, ctx->msg+1);
> +	}
> +#if 0
> +	if (ctx->logfile) {
> +		mm_segment_t fs = get_fs();
> +		set_fs(KERNEL_DS);
> +		ret = _ckpt_kwrite(ctx->logfile, ctx->msg+1, ctx->msglen-1);
> +		set_fs(fs);
> +	}
> +#endif

This piece perhaps belongs to another patch ?

[...]

Oren.
