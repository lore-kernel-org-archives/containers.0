From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/12] define a new set of functions for error and
	debug logging
Date: Mon, 2 Nov 2009 23:24:18 -0800
Message-ID: <20091103072418.GA19243@count0.beaverton.ibm.com>
References: <1257200620-15499-1-git-send-email-serue@us.ibm.com>
	<1257200620-15499-2-git-send-email-serue@us.ibm.com>
	<20091102232439.GK14023@count0.beaverton.ibm.com>
	<20091103023959.GA19697@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091103023959.GA19697-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Mon, Nov 02, 2009 at 08:39:59PM -0600, Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > On Mon, Nov 02, 2009 at 04:23:29PM -0600, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > > From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ...

<snip>

> > > +#define _ckpt_err(ctx, fmt, args...) do { \
> > > +	_do_ckpt_msg(ctx, "[ error %s:%d]" fmt, __func__, __LINE__, ##args);	\
> > > +} while (0)
> > > +
> > > +/* ckpt_logmsg() or ckpt_msg() will do do_ckpt_msg with an added
> > > + * prefix */
> > 
> > nit: This comment is about future code. It should perhaps be part of
> > 	the patch description rather than in the code as comment.
> 
> Sure - and if there are no basic objectiosn then apart from addressing
> these I'll also aim to put some meaningful ckpt_errs() on restart failure
> paths tomorrow.

No objections from me.

Acked-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Cheers,
	-Matt Helsley
