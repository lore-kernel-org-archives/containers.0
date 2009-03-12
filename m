From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 00/11] track files for checkpointability
Date: Thu, 12 Mar 2009 10:30:48 -0500
Message-ID: <20090312153048.GA11147@hallyn.com>
References: <20090305174037.GA2274@x200.localdomain>
	<1236280567.22399.99.camel@nimitz>
	<20090305210840.GA2499@x200.localdomain>
	<1236288427.22399.122.camel@nimitz>
	<20090305220044.GA2819@x200.localdomain>
	<1236352121.5732.80.camel@bahia>
	<20090306153549.GA898@us.ibm.com> <49B15F35.2010909@free.fr>
	<20090306183055.GA6729@us.ibm.com> <49B76D91.1020807@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49B76D91.1020807-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (legoater-GANU6spQydw@public.gmane.org):
> >> And if Ingo's requirement is fulfilled, would any C/R patchset be acceptable ?
> > 
> > Yup, no matter how hideous  :)  Ok not really.
> > 
> > But the point was that it wasn't Dave not understanding Alexey's
> > suggestion, but Greg not understanding Ingo's.  If you think Ingo's
> > goal isn't worthwhile or achievable, then argue that (as I am), don't
> > keep elaborating on something we all agree will be needed (Alexey's
> > suggestion or some other way of doing a true may-be-checkpointed test).
> 
> I rather spend my time on enabling things rather than forbid them. 

That sure sounds productive.  How could I argue with that.

But wait, haven't several teams been doing that for years?  So why is
c/r not in the upstream kernel?  Could it be that ignoring the
upstream maintainers' concerns about (a) treating the feature as a
toy, (b) long-term maintainability, and (c) c/r becoming an impediment
to future features, and instead hacking away at our toy feature, is
*not* always the best course?

Now I actually don't think you believe it's politically possible for
c/r to get upstream.  But I do.

Getting back on track.  Ingo's concern is that this turn into a toy feature
rather than something which serious apps can rely on.  To address that
he wants an application to be able to tell whether or not it is
checkpointable, and, if not, then why not.

Now Alexey also has a suggestion for addressing this.  It has (at least)
two shortcomings relative to Dave's:

	1. it is more prone to race conditions.  If an app opens an
uncheckpointable file briefly and then closes it, and later reopens
it, then it may think it is checkpointable even though it could have
already known it is not always.  If you want to argue that returning
-EAGAIN is better in that case, that seems reasonable.

	2. For repeatedly checking the checkpointability of large
applications it could be much more costly.  For instance, if we have
to check the flags on each vma, and an application has 10s or 100s of
gigs of memory, each check for checkpointability would require walking
all those vmas each time.  Dave's approach has the advantage of only
checking those when the resource is opened.

Hmm, plus

	3. One of the things Ingo likes about Dave's approach, which
you may think is bogus, is that users of an uncheckpointable application
will scream more loudly if the app becomes permanently uncheckpointable
(and they know why), than if it sometimes works and sometimes doesn't
(-EAGAIN).

The funny thing is, for simplicity I actually prefer Alexey's approach.
It's easier (and therefore seems more robust) to tell if a task has a
particular sort of file at a definite point in time, than to try and
catch all the ways such an open file can be opened or received.  Which
is where Ingo's LSM suggestion is seductive, but I'm convinced that
approach would be politically impossible.

-serge
