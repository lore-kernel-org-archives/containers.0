From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v2][PATCH 4/9] Memory management - dump state
Date: Wed, 27 Aug 2008 15:34:27 -0500
Message-ID: <20080827203427.GA1158__23068.5262162753$1219869456$gmane$org@us.ibm.com>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0808202304490.17436@takamine.ncl.cs.columbia.edu>
	<1219437422.20559.146.camel@nimitz>
	<48B0F449.2000006@cs.columbia.edu>
	<1219768406.8680.17.camel@nimitz>
	<48B49C61.1040003@cs.columbia.edu>
	<1219851696.8680.67.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1219851696.8680.67.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> On Tue, 2008-08-26 at 20:14 -0400, Oren Laadan wrote:
> > >>>> +
> > >>>> +	while (addr < end) {
> > >>>> +		struct page *page;
> > >>>> +
> > >>>> +		/* simplified version of get_user_pages(): already have vma,
> > >>>> +		* only need FOLL_TOUCH, and (for now) ignore fault stats */
> > >>>> +
> > >>>> +		cond_resched();
> > >>>> +		while (!(page = follow_page(vma, addr, FOLL_TOUCH))) {
> > >>>> +			ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
> > >>>> +			if (ret & VM_FAULT_ERROR) {
> > >>>> +				if (ret & VM_FAULT_OOM)
> > >>>> +					ret = -ENOMEM;
> > >>>> +				else if (ret & VM_FAULT_SIGBUS)
> > >>>> +					ret = -EFAULT;
> > >>>> +				else
> > >>>> +					BUG();
> > >>>> +				break;
> > >>>> +			}
> > >>>> +			cond_resched();
> > >>>> +		}
> > >>> At best this needs to get folded back into its own function.  This is
> > >> This is almost identical to the original - see the preceding comment.
> > > 
> > > Exactly.  The code is copy-and-pasted.  If there's a bug in the
> > > original, who will change this one?  Better to simply consolidate the
> > > code into one copy.
> > > 
> > >>> pretty hard to read as-is.  Also, are there truly no in-kernel functions
> > >>> that can be used for this?
> > >> Can you suggest one ?
> > > 
> > > This is where the mentality has to shift.  Instead of thinking "there is
> > > no exact in-kernel match for what I want here" we need to consider that
> > > we can modify the in-kernel ones.  They can be modified to suit both
> > > existing and the new needs that we have.
> > 
> > I agree.
> > 
> > However, my main goal now is not to make this patch perfect, but to provide
> > a viable proof-of-concept that demonstrates how we want to do things. Unless
> > you feel we are near ready to send these for inclusion soon (...), I intend
> > to prioritize design and functionality.
> 
> So, you currently have buy-in on this basic approach from the OpenVZ
> guys, and probably Ingo.  If you get too far along in the "design and
> functionality" and a community member comes up with a really good
> objection to some basic part of the "design and functionality" you're
> going to have a lot of code to rewrite.
> 
> I'm trying to get minimized the quantity of "design and functionality"
> down to the bare minimum set where we can get this merged.  So, yes, I
> do think these should be sent for inclusion soon.
> 
> I believe that we're on course to create another large out-of-tree patch
> set that does in-kernel checkpoint/restart.  We have no shortage of
> those.  It's been done many times before.
> 
> This one will *HOPEFULLY* be different from all the rest when it gets
> merged.  

It's true there are out-of-tree proofs-of-concept for in-kernel c/r, but
on the other hand it is nice seeing where Oren's code is going.  Based
on the patchsets you and he have been sending, the impression I've
gotten was that Oren was fleshing out the longer-term tree, while you
were working on the upstream-acceptable minimal patchset.  That seems
like a good model to me.  (Was I wrong about either of your intents?)

It does mean that much of Oren's patchset may end up having to be
re-written based on how Dave's patches look when they get upstream, but
I'm sure Oren knows that's par for the course and doesn't mind.

(Or, is that too much effort required on your part to try and
cherrypick bits of Oren's changes back into your tree?)

In any case, if that *is* the model, then I'd really like to see a
repost of your (Dave's) simplified patchset.  I think we need to
decide precisly which features we want to try to push first (I
thought we were not going to support fds?), throw out any extraneous
infrastructure, put the source for the one-and-only program that
it can checkpoint and restart in the patch description, and see what
feedback we get from the community.  The reason it'll be good to
have Oren continue on his own path is that you know we'll get
questions like "well how are you going to handle (X)", so then
we can point them to Oren's tree.

At least, that's how I was seeing it.

-serge
