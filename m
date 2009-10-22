From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] Checkpoint/restart epoll sets
Date: Thu, 22 Oct 2009 09:02:29 -0500
Message-ID: <20091022140228.GA29615@us.ibm.com>
References: <ce2e15faf44e254b80578c6c62e71d8685516896.1255971848.git.matthltc@us.ibm.com>
	<20091021003128.GA23721@us.ibm.com>
	<20091022062909.GF7757@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091022062909.GF7757-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
> On Tue, Oct 20, 2009 at 07:31:28PM -0500, Serge E. Hallyn wrote:
> > Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> 
> <snip>
> 
> > > +struct file* ep_file_restore(struct ckpt_ctx *ctx,
> > > +			     struct ckpt_hdr_file *h)
> > > +{
> > > +	struct file *epfile;
> > > +	int epfd, ret;
> > > +
> > > +	if (h->h.type != CKPT_HDR_FILE ||
> > > +	    h->h.len  != sizeof(*h) ||
> > > +	    h->f_type != CKPT_FILE_EPOLL)
> > > +		return ERR_PTR(-EINVAL);
> > > +
> > > +	epfd = sys_epoll_create1(h->f_flags & EPOLL_CLOEXEC);
> > > +	if (epfd < 0)
> > > +		return ERR_PTR(epfd);
> > > +	epfile = fget(epfd);
> > > +	sys_close(epfd); /* harmless even if an error occured */
> > > +	BUG_ON(!epfile);
> > 
> > Would perhaps return ERR_PTR(-ENOENT) be nicer?  (And maybe safer - I'm
> > not quite clear on under which arches BUG_ON does nothing).
> 
> OK, good idea. Mind if I post it as a separate patch to be merged with
> this series?

Haha, yeah, pls don't repost the whole patch with a two-line change :)

-serge
