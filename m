From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] c/r: Add CR_COPY() macro (v2)
Date: Wed, 25 Feb 2009 16:21:10 -0600
Message-ID: <20090225222110.GB1751@hallyn.com>
References: <1235585529-806-1-git-send-email-danms@us.ibm.com>
	<1235585529-806-3-git-send-email-danms@us.ibm.com>
	<20090225160841.4d727144@thinkcentre.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090225160841.4d727144-4v5LP+xe+1byhTdZtsIeww@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> On Wed, 25 Feb 2009 13:12:08 -0500
> Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > As suggested by Dave, this provides us a way to make the copy-in and
> > copy-out processes symmetric.  I also added CR_COPY_BIT() to use with
> > the s390 bitfields, since we can't memcpy() those.
> > 
> > Changelog:
> >     Feb 25:
> >             . Changed WARN_ON() to BUILD_BUG_ON()
> > 
> > Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  include/linux/checkpoint.h |   20 ++++++++++++++++++++
> >  1 files changed, 20 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> > index 217cf6e..3add90e 100644
> > --- a/include/linux/checkpoint.h
> > +++ b/include/linux/checkpoint.h
> > @@ -149,4 +149,24 @@ static inline void process_deny_checkpointing(struct task_struct *task) {}
> >  
> >  #endif
> >  
> > +#define CR_CPT 1
> > +#define CR_RST 2
> > +
> > +#define CR_COPY(op, a, b)				\
> > +	do {						\
> > +		BUILD_BUG_ON(sizeof(a) != sizeof(b));	\
> > +		if (op == CR_CPT)			\
> > +			memcpy(&a, &b, sizeof(a));	\
> > +		else					\
> > +			memcpy(&b, &a, sizeof(a));	\
> > +	} while (0);
> > +
> > +#define CR_COPY_BIT(op, a, b)				\
> > +	do {						\
> > +		if (op == CR_CPT)			\
> > +			a = b;				\
> > +		else					\
> > +			b = a;				\
> > +	} while (0);
> > +
> >  #endif /* _CHECKPOINT_CKPT_H_ */
> 
> No typechecking.  Multiple expansion of arguments (probably harmless
> for the current use case, but still).  Generates a memcpy where,
> depending on the arguments, simple assignment would be sufficient and

well is there any case where we must do a memcpy?  Or, if the headers
in the checkpoint image also give a bounded array size, can we just
copy that array using 'a = b'?

In any case we guarantee the sizes are correct, which may be all that
we want anyway.

> preferred.  Not useful for targets where fields in the checkpoint image
> are larger than the register state they reflect (32-bit variants of x86
> and powerpc).
> 
> Anyway, checkpoint and restart should not be "symmetric" -- the restart
> code has to validate certain values, such as privileged registers, in
> the image before committing them.

The argument in favor is that using the CR_COPY() macros in a single fn
for the common code allows us to

	1. make sure that none of the common code is accidentally
		overlooked (which does in fact make it more
		maintainable)
	2. lets any code which must be specially done at checkpoint
		or restart stand out.  Like resetting access registers
		in Dan's version.

> And while these macros may reduce initial development effort, the
> reading effort incurred is non-trivial.  It doesn't seem worth it.

-serge
