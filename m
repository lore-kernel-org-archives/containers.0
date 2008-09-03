From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/9] Introduce context structure needed
	=?iso-8859-1?q?during=09checkpointing/restart?=
Date: Wed, 3 Sep 2008 18:29:52 +0400
Message-ID: <200809031829.53266.major@openvz.org>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<1220439476-16465-4-git-send-email-major@openvz.org>
	<48BE9B74.7010600@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48BE9B74.7010600-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wednesday 03 September 2008 18:13 Cedric Le Goater wrote:
> > +void context_release(struct cpt_context *ctx)
> > +{
> > +	ctx->ctx_state = CPT_CTX_ERROR;
> > +
> > +	if (ctx->file)
> > +		fput(ctx->file);
> > +	kfree(ctx);
> > +}
> > +
> > +static void context_put(struct cpt_context *ctx)
> > +{
> > +	if (!--ctx->refcount)
> > +		context_release(ctx);
> > +}
> > +
> >  static int checkpoint(pid_t pid, int fd, unsigned long flags)
> >  {
> > -	return -ENOSYS;
> > +	struct file *file;
> > +	struct cpt_context *ctx;
> > +	int err;
> > +
> > +	err = -EBADF;
> > +	file = fget(fd);
> > +	if (!file)
> > +		goto out;
> > +
> > +	err = -ENOMEM;
> > +	ctx = context_alloc();
> > +	if (!ctx)
> > +		goto out_file;
> > +
> > +	ctx->file = file;
> > +	ctx->ctx_state = CPT_CTX_DUMPING;
> > +
> > +	/* checkpoint */
> > +	err = -ENOSYS;
> > +
> > +	context_put(ctx);
> > +
> > +out_file:
> > +	fput(file);
> > +out:
> > +	return err;
> >  }
>
> it looks like fput(file) is done twice in checkpoint() and
> context_release() ?

Oh, you are right. I'm sorry, I was in rush and sent an outdated version.
Will resend correct patch shortly.

Thanks,
Andrey
