From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/12] define a new set of functions for error and
	debug logging
Date: Mon, 2 Nov 2009 20:39:59 -0600
Message-ID: <20091103023959.GA19697@us.ibm.com>
References: <1257200620-15499-1-git-send-email-serue@us.ibm.com>
	<1257200620-15499-2-git-send-email-serue@us.ibm.com>
	<20091102232439.GK14023@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091102232439.GK14023-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> On Mon, Nov 02, 2009 at 04:23:29PM -0600, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
...
> I haven't gotten through the series but this looks like either a stale
> comment (re: "ctx->fmt_buf_lock"), or it's premature -- I don't see you
> introduce or use this lock in this patch.

Yup, stale comment, thanks.  No fmt_buf_lock this time around.

> > + */
> > +void _ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
> > +{
> > +	char *s = ctx->fmt;
> > +	int len = 0;
> > +	int first = 1;
> > +
> > +	for (; *fmt && len < CKPT_MSG_LEN; fmt++) {
> > +		if (!is_special_flag(fmt)) {
> > +			s[len++] = *fmt;
> > +			continue;
> > +		}
> > +		if (!first)
> > +			s[len++] = ' ';
> > +		else
> > +			first = 0;
> 
> I'm tempted to say leave the space out. The square brackets delimit
> these enough. And if the caller really needs the space then it can be
> done: "%(E) %(O)foo".

Works for me.

> > +void _ckpt_msg_append(struct ckpt_ctx *ctx, char *fmt, ...)
> > +{
> > +	va_list ap;
> > +
> > +	va_start(ap, fmt);
> > +	_ckpt_msg_appendv(ctx, fmt, ap);
> > +	va_end(ap);
> > +}
> > +
> > +void _ckpt_msg_complete(struct ckpt_ctx *ctx)
> > +{
> > +	int ret;
> 
> In the case of do_ckpt_msg() it's clear this won't happen. However
> since _do_ckpt_msg() is separate from _ckpt_msg_complete() (looking
> at the second patch) it's not clear that this will always be maintained
> correctly.
> 
> BUG_ON(ctx->msglen < 1); /* detect msg_complete calls without any
> 				messages */

Well, just return if ctx->msglen < 1, but point taken, will fix.

> 
> > +
> > +	if (ctx->kflags & CKPT_CTX_CHECKPOINT) {
> > +		ret = ckpt_write_obj_type(ctx, NULL, 0, CKPT_HDR_ERROR);
> > +		if (!ret)
> > +			ret = ckpt_write_string(ctx, ctx->msg, ctx->msglen);
> > +		if (ret < 0)
> > +			printk(KERN_NOTICE "c/r: error string unsaved (%d): %s\n",
> > +			       ret, ctx->msg+1);
> > +	}
> > +#if 0
> > +	if (ctx->logfile) {
> > +		mm_segment_t fs = get_fs();
> > +		set_fs(KERNEL_DS);
> > +		ret = _ckpt_kwrite(ctx->logfile, ctx->msg+1, ctx->msglen-1);
> > +		set_fs(fs);
> > +	}
> > +#endif
> > +#ifdef CONFIG_CHECKPOINT_DEBUG
> > +	printk(KERN_DEBUG "%s", ctx->msg+1);
> > +#endif
> 
> Then clear:
> 
> 	ctx->msglen = 0;
> 
> <snip>
> 
> > +/*
> > + * Expand fmt into ctx->fmt.
> > + * This expands enhanced format flags such as %(T), which takes no
> > + * arguments, and %(E), which will require a properly positioned
> > + * int error argument.  Flags include:
> > + *   T: Task
> > + *   E: Errno
> > + *   O: Objref
> > + *   P: Pointer
> > + *   S: string
> > + *   V: Variable (symbol)
> > + * May be called under spinlock.
> > + * Must be called under ckpt_msg_lock.
> > + */
> > +extern void _ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt);
> 
> I'm not seeing why this is needed outside checkpoint/sys.c. In a future
> patch?

Hmm, no...  in an earlier patchset.  I don't think there will be any
external callers of this fn.  Should be static.

> > +#define _ckpt_err(ctx, fmt, args...) do { \
> > +	_do_ckpt_msg(ctx, "[ error %s:%d]" fmt, __func__, __LINE__, ##args);	\
> > +} while (0)
> > +
> > +/* ckpt_logmsg() or ckpt_msg() will do do_ckpt_msg with an added
> > + * prefix */
> 
> nit: This comment is about future code. It should perhaps be part of
> 	the patch description rather than in the code as comment.

Sure - and if there are no basic objectiosn then apart from addressing
these I'll also aim to put some meaningful ckpt_errs() on restart failure
paths tomorrow.

thanks,
-serge
