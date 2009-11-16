From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/7] kernel/cred.c: ckpt_err at restart
Date: Mon, 16 Nov 2009 10:51:33 -0600
Message-ID: <20091116165133.GB16493@us.ibm.com>
References: <1257465619-1777-1-git-send-email-serue@us.ibm.com>
	<1257465619-1777-6-git-send-email-serue@us.ibm.com>
	<4B017AA5.60503@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B017AA5.60503-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > 
> > Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  kernel/cred.c |   46 ++++++++++++++++++++++++++++++++++++----------
> >  1 files changed, 36 insertions(+), 10 deletions(-)
> > 
> > diff --git a/kernel/cred.c b/kernel/cred.c
> > index 62d28a4..c941078 100644
> > --- a/kernel/cred.c
> > +++ b/kernel/cred.c
> > @@ -764,32 +764,46 @@ static struct cred *do_restore_cred(struct ckpt_ctx *ctx)
> >  	int i;
> >  
> >  	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CRED);
> > -	if (IS_ERR(h))
> > +	if (IS_ERR(h)) {
> > +		ckpt_err(ctx, ret, "reading cred entry\n");
> 
> This error is better reported for _all_ callers of ckpt_read_obj_type()
> from that function ?
> 
> I am thinking that moving the report to the specific place where an
> error occurs, plus data from the image file (and location there)
> should be sufficient for debugging.

Yeah, it would help reduce the code size too.  I guess I was
thinking the caller would have extra information, but it really
doesn't, or if in the rare caes it does then it can add it.  Good
idea.

thanks,
-serge
