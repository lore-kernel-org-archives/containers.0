From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 05/10] Core checkpoint/restart support code
Date: Mon, 4 Apr 2011 14:55:11 -0700
Message-ID: <20110404215511.GA27628__49461.5647745833$1301957585$gmane$org@count0.beaverton.ibm.com>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
	<1298936432-29607-6-git-send-email-ntl@pobox.com>
	<20110403190324.GD15044@hallyn.com>
	<1301929228.31531.39.camel@tp-t61>
	<20110404151017.GA4857@hallyn.com>
	<1301931608.31531.49.camel@tp-t61>
	<20110404162753.GA3456@hallyn.com>
	<20110404104119.78189678.akpm@linux-foundation.org>
	<20110404185119.GB4782@peq.hallyn.com>
	<20110404124222.fd5eb85b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110404124222.fd5eb85b.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Apr 04, 2011 at 12:42:22PM -0700, Andrew Morton wrote:
> On Mon, 4 Apr 2011 13:51:20 -0500 "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> > > On Mon, 4 Apr 2011 11:27:53 -0500 "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> > > 
> > > > Andrew (Cc:d), did you see this thread go by, and it did it look
> > > > in any way more palatable to you?  Have you had any thoughts on
> > > > checkpoint/restart in the last few months?  Or did that horse quietly
> > > > die over winter?
> > > 
> > > argh, it was the victim of LIFO.
> > > 
> > > All I can say at this stage is that I'll be interested next time it
> > > comes past, sorry.
> > 
> > Thanks, that's good to know.
> > 
> > As you know, we started with a minimal patchset, then grew it over time
> > to answer the "but how will you (xyz) without uglifying the kernel".
> > Would you recommend we go back to keeping a separate minimal patchset,
> > or that we develop on the current, pretty feature-full version?  I'm not
> > convinced believe there will be bandwidth to keep two trees and do both
> > justice.
> 
> The minimal patchset is too minimal for Oren's use and the maximal
> patchset seems to have run aground on general kernel sentiment.  So I
> guess you either take the minimal patchset and make it less minimal or
> take the maximal patchset and make it less maximal, ending up with the
> same thing.  How's that for hand-waving useless obviousnesses :)
> 
> One obvious approach is to merge the minimal patchset then, over time,
> sneak more stuff into it so we end up with the maximal patchset which
> people didn't like.  Don't do that :)

Yes, merging this minimal patch set early is obviously premature.

It seems clear from your statement above that "the maximal patchset seems to
have run aground on  general kernel sentiment" -- pushing that set isn't
going to make any progress. So I think we're left with modifying the new
minimal patch set.

However I think we need some review before we continue modifying it. We
had a minimal patch set which evolved into the current maximal set. It
never really got the reviews outside our little group that it needed.
Now we're back with a new minimal patch set. You're asking us to do the same
thing and expect different results -- stack more patches on top and expect to
get it reviewed. OK, but what reason do we have to believe this time will be
any different?

Cheers,
	-Matt Helsley
