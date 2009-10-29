From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: factor out objref handling from {_,}ckpt_read_obj()
Date: Thu, 29 Oct 2009 14:21:30 -0700
Message-ID: <20091029212130.GC14023@count0.beaverton.ibm.com>
References: <1256710435-3266-1-git-send-email-matthltc@us.ibm.com>
	<1256838612-17372-1-git-send-email-orenl@librato.com>
	<20091029195213.GA29874@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091029195213.GA29874-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Thu, Oct 29, 2009 at 02:52:13PM -0500, Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> > As noted by Matt Helsley, a portion of one of these functions was
> > missing the block "dispatching" errors. Otherwise the handling of
> > shard objects is pretty much the same, so this patch factors out the
> > common code.
> > 
> > Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> 
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Although you could go one step further and pass in len and max
> and check those in ckpt_read_obj_dispatch() as well.

Actually I think it should only "do the dispatch" and nothing else. Otherwise
it becomes "ckpt_alloc_and_read_and_dispatch_and_check_obj()" (ok, I'm
exaagerating a bit..).

There's alot of variation in these ckpt_read* functions based on issues
like:
	1. When to alloc the header (and how much to alloc)
	2. When/what to compare the header len to
	3. If/When to alloc the payload
	4. If/When to read the payload

So merging the length/max parameter check with
ckpt_read_obj_dispatch() may limit its usefulness or cause its parameter
list to explode.

That said, the looping, reading, and minimal length checking
performed here looks pretty nice.

Cheers,
	-Matt Helsley

> 
> -serge
> 
> > ---
> >  checkpoint/restart.c |   58 ++++++++++++++++++++++++++-----------------------
> >  1 files changed, 31 insertions(+), 27 deletions(-)
> > 
> > diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> > index 9b75de8..130b4b2 100644
> > --- a/checkpoint/restart.c
> > +++ b/checkpoint/restart.c
> > @@ -238,6 +238,35 @@ static int _ckpt_read_objref(struct ckpt_ctx *ctx, struct ckpt_hdr *hh)
> >  	return ret;
> >  }
> > 
> > +/**
> > + * ckpt_read_obj_dispatch - dispatch ERRORs and OBJREFs; don't return them
> > + * @ctx: checkpoint context
> > + * @h: desired ckpt_hdr
> > + */
> > +static int ckpt_read_obj_dispatch(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
> > +{
> > +	int ret;
> > +
> > +	while (1) {
> > +		ret = ckpt_kread(ctx, h, sizeof(*h));
> > +		if (ret < 0)
> > +			return ret;
> > +		_ckpt_debug(CKPT_DRW, "type %d len %d\n", h->type, h->len);
> > +		if (h->len < sizeof(*h))
> > +			return -EINVAL;
> > +
> > +		if (h->type == CKPT_HDR_ERROR) {
> > +			ret = _ckpt_read_err(ctx, h);
> > +			if (ret < 0)
> > +				return ret;
> > +		} else if (h->type == CKPT_HDR_OBJREF) {
> > +			ret = _ckpt_read_objref(ctx, h);
> > +			if (ret < 0)
> > +				return ret;
> > +		} else
> > +			return 0;
> > +	}
> > +}
> > 
> >  /**
> >   * _ckpt_read_obj - read an object (ckpt_hdr followed by payload)
> > @@ -254,26 +283,11 @@ static int _ckpt_read_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h,
> >  {
> >  	int ret;
> > 
> > - again:
> > -	ret = ckpt_kread(ctx, h, sizeof(*h));
> > +	ret = ckpt_read_obj_dispatch(ctx, h);
> >  	if (ret < 0)
> >  		return ret;
> >  	_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
> >  		    h->type, h->len, len, max);
> > -	if (h->len < sizeof(*h))
> > -		return -EINVAL;
> > -
> > -	if (h->type == CKPT_HDR_ERROR) {
> > -		ret = _ckpt_read_err(ctx, h);
> > -		if (ret < 0)
> > -			return ret;
> > -		goto again;
> > -	} else if (h->type == CKPT_HDR_OBJREF) {
> > -		ret = _ckpt_read_objref(ctx, h);
> > -		if (ret < 0)
> > -			return ret;
> > -		goto again;
> > -	}
> > 
> >  	/* if len specified, enforce, else if maximum specified, enforce */
> >  	if ((len && h->len != len) || (!len && max && h->len > max))
> > @@ -362,21 +376,11 @@ static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
> >  	struct ckpt_hdr *h;
> >  	int ret;
> > 
> > - again:
> > -	ret = ckpt_kread(ctx, &hh, sizeof(hh));
> > +	ret = ckpt_read_obj_dispatch(ctx, &hh);
> >  	if (ret < 0)
> >  		return ERR_PTR(ret);
> >  	_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
> >  		    hh.type, hh.len, len, max);
> > -	if (hh.len < sizeof(*h))
> > -		return ERR_PTR(-EINVAL);
> > -
> > -	if (hh.type == CKPT_HDR_OBJREF) {
> > -		ret = _ckpt_read_objref(ctx, &hh);
> > -		if (ret < 0)
> > -			return ERR_PTR(ret);
> > -		goto again;
> > -	}
> > 
> >  	/* if len specified, enforce, else if maximum specified, enforce */
> >  	if ((len && hh.len != len) || (!len && max && hh.len > max))
> > -- 
> > 1.6.0.4
> > 
> > _______________________________________________
> > Containers mailing list
> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > https://lists.linux-foundation.org/mailman/listinfo/containers
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
