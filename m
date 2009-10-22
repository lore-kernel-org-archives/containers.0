From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] Checkpoint/restart epoll sets
Date: Wed, 21 Oct 2009 23:29:09 -0700
Message-ID: <20091022062909.GF7757@count0.beaverton.ibm.com>
References: <ce2e15faf44e254b80578c6c62e71d8685516896.1255971848.git.matthltc@us.ibm.com>
	<20091021003128.GA23721@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091021003128.GA23721-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 20, 2009 at 07:31:28PM -0500, Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):

<snip>

> > +struct file* ep_file_restore(struct ckpt_ctx *ctx,
> > +			     struct ckpt_hdr_file *h)
> > +{
> > +	struct file *epfile;
> > +	int epfd, ret;
> > +
> > +	if (h->h.type != CKPT_HDR_FILE ||
> > +	    h->h.len  != sizeof(*h) ||
> > +	    h->f_type != CKPT_FILE_EPOLL)
> > +		return ERR_PTR(-EINVAL);
> > +
> > +	epfd = sys_epoll_create1(h->f_flags & EPOLL_CLOEXEC);
> > +	if (epfd < 0)
> > +		return ERR_PTR(epfd);
> > +	epfile = fget(epfd);
> > +	sys_close(epfd); /* harmless even if an error occured */
> > +	BUG_ON(!epfile);
> 
> Would perhaps return ERR_PTR(-ENOENT) be nicer?  (And maybe safer - I'm
> not quite clear on under which arches BUG_ON does nothing).

OK, good idea. Mind if I post it as a separate patch to be merged with
this series?

> 
> > +
> > +	/*
> > +	 * Needed before we can properly restore the watches and enforce the
> > +	 * limit on watch numbers.
> > +	 */
> > +	ret = restore_file_common(ctx, epfile, h);
> > +	if (ret < 0)
> > +		goto fput_out;
> > +
> > +	/*
> > +	 * Defer restoring the epoll items until the file table is
> > +	 * fully restored. Ensures that valid file objrefs will resolve.
> > +	 */
> > +	ret = deferqueue_add_ptr(ctx->files_deferq, ctx, ep_items_restore, NULL);
> > +	if (ret < 0) {
> > +fput_out:
> > +		fput(epfile);
> > +		epfile = ERR_PTR(ret);
> > +	}
> > +	return epfile;
> > +}
> > +
> > +#endif /* CONFIG_CHECKPOINT */
> > +
> >  static int __init eventpoll_init(void)
> >  {
> >  	struct sysinfo si;
> > diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> > index ca2500d..1a3edab 100644
> > --- a/include/linux/checkpoint_hdr.h
> > +++ b/include/linux/checkpoint_hdr.h
> > @@ -119,6 +119,8 @@ enum {
> >  #define CKPT_HDR_TTY CKPT_HDR_TTY
> >  	CKPT_HDR_TTY_LDISC,
> >  #define CKPT_HDR_TTY_LDISC CKPT_HDR_TTY_LDISC
> > +	CKPT_HDR_EPOLL_ITEMS = 391, /* Follows file-table */
> 
> What is the comment supposed to mean (other than that such
> comments inevitably become stale :)?

It means that these items must be present some point after the
file-table in order for the checkpoint image to restart. That's
why I chose a number near 400  -- it looked like [300-400) were set 
aside for file objects.

Cheers,
	-Matt Helsley
