From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: uts: don't pass an unsigned var as a signed int
Date: Sat, 20 Jun 2009 19:18:37 -0500
Message-ID: <20090621001837.GA32394@hallyn.com>
References: <20090619203719.GA30093@us.ibm.com> <m3prczfs2m.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m3prczfs2m.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Else my checkpoing image gets reeeaallly huge.  Just passing the
> > result of sizeof() however does the right thing.
> >
> > Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  checkpoint/namespace.c |   12 ++++++------
> >  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> But right above the code you're changing we have:
> 
> 	h->sysname_len = sizeof(name->sysname);
> 	h->nodename_len = sizeof(name->nodename);
> 	h->release_len = sizeof(name->release);
> 	h->version_len = sizeof(name->version);
> 	h->machine_len = sizeof(name->machine);
> 	h->domainname_len = sizeof(name->domainname);
> 
> Your patch shouldn't change any behavior.  What gives?

"Shouldn't", perhaps, but does.

I assumed the compiler guessed that i wanted an int in the
second case and gave me a different result for that sizeof.

> (PS: ckpt_write_string and friends should take a size_t or some other
> unsigned type for len.)

There I agree, but then we need to check that no callers are
passing in potentially negative signed ints coming from userspace,
so I thought this patch would spur discussion about best path
forward (plus make checkpoint work for me again :)

-serge
