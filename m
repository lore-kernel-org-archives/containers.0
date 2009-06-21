From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: uts: don't pass an unsigned var as a signed int
Date: Sun, 21 Jun 2009 14:13:05 -0500
Message-ID: <20090621191305.GA2499@hallyn.com>
References: <20090619203719.GA30093@us.ibm.com> <m3prczfs2m.fsf@pobox.com>
	<20090621001837.GA32394@hallyn.com> <m34ouaf942.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m34ouaf942.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> >> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> >> 
> >> > Else my checkpoing image gets reeeaallly huge.  Just passing the
> >> > result of sizeof() however does the right thing.
> >> >
> >> > Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >> > ---
> >> >  checkpoint/namespace.c |   12 ++++++------
> >> >  1 files changed, 6 insertions(+), 6 deletions(-)
> >> 
> >> But right above the code you're changing we have:
> >> 
> >> 	h->sysname_len = sizeof(name->sysname);
> >> 	h->nodename_len = sizeof(name->nodename);
> >> 	h->release_len = sizeof(name->release);
> >> 	h->version_len = sizeof(name->version);
> >> 	h->machine_len = sizeof(name->machine);
> >> 	h->domainname_len = sizeof(name->domainname);
> >> 
> >> Your patch shouldn't change any behavior.  What gives?
> >
> > "Shouldn't", perhaps, but does.
> 
> 
> Revisiting do_checkpoint_uts_ns, I think it's a case of use after free:
> 
> 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
> 	if (!h)
> 		return -ENOMEM;
> 
> 	h->sysname_len = sizeof(name->sysname);
> 	h->nodename_len = sizeof(name->nodename);
> 	h->release_len = sizeof(name->release);
> 	h->version_len = sizeof(name->version);
> 	h->machine_len = sizeof(name->machine);
> 	h->domainname_len = sizeof(name->domainname);
> 
> 	ret = ckpt_write_obj(ctx, &h->h);
> 	ckpt_hdr_put(ctx, h);
> 	if (ret < 0)
> 		return ret;
> 
> 	down_read(&uts_sem);
> 	ret = ckpt_write_string(ctx, name->sysname, h->sysname_len);
> 
> We're continuing to use h's memory after it has been released by
> ckpt_hdr_put.  Seems plausible that the poison values written by sl*b
> debug would cause the len argument to be ridiculously large.

Oren,

would it be possible to put up a filter, either manual or
automatic, to send every patch that gets pushed on the current
ckpt git branch to the containers list, maybe with a [CKPT PUSH]
tag in the subject line?

I think it will foster much more review of every patch.  Right now
it feels like we just catch blatant bugs when they bite us too hard,
but I don't think many people are looking through 'git wc' every
day.

-serge
