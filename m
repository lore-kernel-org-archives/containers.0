From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 04/22] Change to the new enhanced error string format
Date: Mon, 2 Nov 2009 10:52:20 -0600
Message-ID: <20091102165220.GA32067@us.ibm.com>
References: <1256943629-4531-1-git-send-email-serue@us.ibm.com>
	<1256943629-4531-5-git-send-email-serue@us.ibm.com>
	<20091102163327.GH14023@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091102163327.GH14023-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
> On Fri, Oct 30, 2009 at 06:00:26PM -0500, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > 
> > Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> 
> <snip>
> 
> > - * This generates a unified format of checkpoint error messages, to
> > - * ease (after the failure) inspection by userspace tools. It converts
> > - * the (printf) message @fmt into a new format: "[PREFMT]: fmt".
> > + * The special flags are surrounded by %() to help them visually stand
> > + * out.  For instance, %(O) means an objref.  The following special
> > + * flags are recognized:
> > + *	E: error
> > + *	O: objref
> > + *	P: pointer
> > + *	T: task
> > + *	S: string
> > + *	V: variable
> >   *
> 
> Something for the future: It might be good to have "F: File" as well. It
> may sometimes be useful to print out a file name instead of just the struct
> file pointer. It'd be useful for epoll, file checkpoint ops in general, and
> file-backed VMAs.

Sure...  As callers want it, we can add it - I also expect %A for
ctx->active_pid (which won't take an argument) to be added.

...

> > +	for (; *fmt && len < CKPT_MSG_BUFSZ; fmt++) {
> > +		if (*fmt != '%' || fmt[1] != '(' || fmt[2] == '\0' ||
> > +							fmt[3] != ')') {
> > +			s[len++] = *fmt;
> > +			continue;
> > +		}
> > +		if (!first)
> > +			s[len++] = ' ';
> > +		else
> > +			first = 0;
> > +		switch (fmt[2]) {
> > +		case 'E':
> > +			len += sprintf(s+len, "[%s]", "err %d");
> 
> Why not use snprintf ?

Yup, thanks for keeping me honest - just switched my new patchset
to do that.

...

> > +		default:
> > +			printk(KERN_ERR "c/r: bad format specifier %c\n",
> > +					fmt[2]);
> > +			BUG();
> 
> Perhaps BUG() isn't such a good idea since this will be used in

I disagree - this fmt is passed in by the kernel, so if we get a flag
we don't understand, then it is a bug in our c/r code.

-serge
