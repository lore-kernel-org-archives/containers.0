From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/17] ckpt_write_err: use single format with %(T)
	style tokens
Date: Thu, 29 Oct 2009 21:18:19 -0500
Message-ID: <20091030021819.GB10379@us.ibm.com>
References: <1256849682-858-1-git-send-email-serue@us.ibm.com>
	<1256849682-858-2-git-send-email-serue@us.ibm.com>
	<4AEA1527.7090907@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AEA1527.7090907-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> 
> 
> serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > 
> > Matt Helsley originally suggested this to avoid having two
> > format strings.  This is not bisect-safe and therefore not
> > even compile-tested.  Every call to ckpt_write_err must be
> > updated to use a single format.
> > 
> > Changelog:
> > 	Oct 29: merge with the next patch, moving ckpt_generate_fmt()
> > 		into checkpoing/sys.c and making it non-static so that
> > 		we can use it in ckpt_error().
> > 	Oct 28: also fix comment above ckpt_generate_fmt()
> > 	Oct 27: ensure %(T) has a closing paren
> > 
> > Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  checkpoint/checkpoint.c    |  105 +++-----------------------------------------
> >  checkpoint/sys.c           |   95 +++++++++++++++++++++++++++++++++++++++
> >  include/linux/checkpoint.h |   13 +++--
> >  3 files changed, 110 insertions(+), 103 deletions(-)
> > 
> > diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> > index 6eb8f3b..c6be4f9 100644
> > --- a/checkpoint/checkpoint.c
> > +++ b/checkpoint/checkpoint.c
> > @@ -96,104 +96,15 @@ int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
> >  	return ckpt_write_obj_type(ctx, str, len, CKPT_HDR_STRING);
> >  }
> >  
> 
> [...]
> 
> > diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> > index 260a1ee..9b2de18 100644
> > --- a/checkpoint/sys.c
> > +++ b/checkpoint/sys.c
> > @@ -339,6 +339,101 @@ int walk_task_subtree(struct task_struct *root,
> >  	return (ret < 0 ? ret : total);
> >  }
> >  
> 
> Some pieces of the comment below are obsolete...
> 
> > +/*
> > + * ckpt_generate_fmt - generate standard checkpoint error message
> > + * @ctx: checkpoint context
> > + * @fmt: message format
> > + *
> > + * This generates a unified format of checkpoint error messages, to
> > + * ease (after the failure) inspection by userspace tools. It converts
> > + * the (printf) message @fmt into a new format: "[PREFMT]: fmt".
> > + *
> > + * PREFMT is constructed from @fmt by subtituting format snippets
> > + * according to the contents of @fmt.  The format characters in
> > + * @fmt can be %(E) (error), %(O) (objref), %(P) (pointer), %(S) (string),
> > + * %(C) (bytes read/written out of checkpoint image so far), * and %(V)
> 							      ^^^^^
> > + * (variable/symbol). For example, %(E) will generate a "err %d"
> > + * in PREFMT.
>       ^^^^^^^^^
> > + *
> > + * If @fmt begins with %(T), PREFMT will begin with "pid %d tsk %s"
> 	    ^^^^^^^^^
> > + * with the pid and the tsk->comm of the currently checkpointed task.
> > + * The latter is taken from ctx->tsk, and is it the responsbilility of
> 						typo  ^^^^^^^^^^^^^^^^^
> > + * the caller to have a valid pointer there (in particular, functions
> > + * that iterate on the processes: collect_objects, checkpoint_task,
> > + * and tree_count_tasks).
> > + *
> > + * The caller of ckpt_write_err() and _ckpt_write_err() must provide
> 		    ^^^^^^^^^^^^^^^^	 ^^^^^^^^^^^^^^^^^
> > + * the additional variabes, in order, to match the @fmt0 (except for
> 		typo ^^^^^^^^			     ^^^^^^^
> > + * the T key), e.g.:
>       ^^^^^^^^^^  (obsolete)
> > + *
> > + *   ckpt_writ_err(ctx, "TEO", "FILE flags %d", err, objref, flags)
> 			  ^^^^^^^^
> > + *
> > + * Here, T is simply passed, E expects an integer (err), O expects an
> > + * integer (objref), and the last argument matches the format string.
> 
> Rewrite example...

Ok, thanks for pointing that out - I'll rewrite the whole thing.

> > + * XXX Do we want 'T' and 'C' to simply always be prepended?
> > + */
> > +char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
> > +{
> > +	char *format;
> > +	int alloclen, len = 0;
> > +	int first = 1;
> > +
> > +	/*
> > +	 * 17 for "pid %d" (plus space)
> > +	 * 21 for "tsk %s" (tsk->comm)
> > +	 * up to 8 per varfmt entry
> 		      ^^^^^^^^
> 
> > +	 */
> > +	alloclen = 37 + 8 * strlen(fmt);
> 
> This calculation assumed that @fmt had only format string...
> At the very minimum you could take strlen(fmt)/3 (+1 to round up)

Yeah, I didn't want to think about that in detail yet :)

> I thought you were going to use a @ctx->buffer or something ?

And I am, for my string.  We need one for the expanded fmt here,
and then one to snprintf the final string into so we can write it
out.

Shall I just add a @ctx->fmtbuf?

> > +	format = kzalloc(alloclen, GFP_KERNEL);
> > +	if (!format)
> > +		return NULL;
> > +
> > +	for (; *fmt; fmt++) {
> > +		BUG_ON(len > alloclen);
> > +		if (*fmt != '%' || fmt[1] != '(' || fmt[3] != ')') {
> 
> This is still a bit risky .. how about adding
> 	|| fmt[2] == '\0'
> between the 2nd and 3rd test ?

Well I can do that, but since we provide the fmt strings and there is
no risk for an information leak I didn't think it was worth making
the line even longer.  But ok, I'll add it...

thanks,
-serge
