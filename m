From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/5] cr: checkpoint and restore task credentials
Date: Thu, 14 May 2009 08:54:44 -0500
Message-ID: <20090514135444.GB3980@us.ibm.com>
References: <20090511160424.GA12234@us.ibm.com>
	<20090511160539.GD12286@us.ibm.com>
	<20090514081850.GA21115@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090514081850.GA21115-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> On Mon, May 11, 2009 at 11:05:39AM -0500, Serge E. Hallyn wrote:
> > --- a/checkpoint/objhash.c
> > +++ b/checkpoint/objhash.c
> > +#define CKPT_MAXGROUPS 15
> > +#define MAX_GROUPINFO_SIZE (sizeof(*h)+CKPT_MAXGROUPS*sizeof(gid_t))
> > +/* move this fn into kernel/sys.c next to group functions? */
> > +static int checkpoint_write_groupinfo(struct ckpt_ctx *ctx,
> > +					struct group_info *g)
> > +{
> > +	int ret, i, size;
> > +	struct ckpt_hdr_groupinfo *h;
> > +
> > +	if (g->ngroups > CKPT_MAXGROUPS) {
> > +		ckpt_debug("Too many groups: %d  (max is %d)\n",
> > +			g->ngroups, CKPT_MAXGROUPS);
> > +		return -E2BIG;
> > +	}
> 
> Ooh, a hack :-)

Yup - actually I originally only had this at restart, and we must
have it there to protect from malicious checkpoint images.

I copied it into the restart code during a cleanup phase, and I
probably shouldn't have.

> > +	size = sizeof(*h) + g->ngroups * sizeof(__u32);
> > +	h = ckpt_hdr_get_type(ctx, size, CKPT_HDR_GROUPINFO);
> > +	if (!h)
> > +		return -ENOMEM;
> > +
> > +	h->ngroups = g->ngroups;
> > +	for (i = 0; i < g->ngroups; i++)
> > +		h->groups[i] = GROUP_AT(g, i);
> > +
> > +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> > +	ckpt_hdr_put(ctx, h);
> > +
> > +	return ret;
> > +}
> 
> > +/*
> > + * write the user struct
> > + * TODO keyring will need to be dumped
> > + */
> > +#define UNSAVED_NS_MAX 5
> 
> Another hack :-)
> 
> This is an invitation to discuss what to do with references to future,
> especially given that object image can be variable-size _and_
> streamability on dump.
> 
> In case of user->user_ns->creator, we can avoid the issue and dump creator
> first.

In fact I do dump the creator first.  Note first that this '5' is not just
for 5 levels of (user->user_ns)->(creator->user_ns)->...,  but for 5
such levels where there are no tasks in any of the intermediate user
namespaces.  So a task did a

1.  T1: T2=clone(CLONE_NEWNS)
2.  T1: exit T2: T3=clone(CLONE_NEWNS)
3.  T2: exit T3: T4=clone(CLONE_NEWNS)
4.  T3: exit T4: t5=clone(CLONE_NEWNS)

As with groups, I think I agree with you that we don't need such a
limit at checkpoint time.  But we need some kind of sanity check at
restart time.  How about 5000?

thanks,
-serge
