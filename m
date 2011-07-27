From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC][PATCH 0/7 + tools] Checkpoint/restore mostly in the
	userspace
Date: Wed, 27 Jul 2011 14:01:14 +0200
Message-ID: <20110727120114.GZ2622@htj.dyndns.org>
References: <4E204466.8010204@parallels.com>
	<20110723002558.GE16940@count0.beaverton.ibm.com>
	<20110723051005.GE21089@mtj.dyndns.org>
	<20110726220215.GE14808@count0.beaverton.ibm.com>
	<20110726222109.GB28497@mtj.dyndns.org>
	<20110727000651.GA15501@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110727000651.GA15501-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Matt.

On Tue, Jul 26, 2011 at 05:06:51PM -0700, Matt Helsley wrote:
> On Wed, Jul 27, 2011 at 12:21:09AM +0200, Tejun Heo wrote:
> > On Tue, Jul 26, 2011 at 03:02:15PM -0700, Matt Helsley wrote:
> > > > Sure, that was completely embedded in the kernel and things can be
> > > > implemented and fixed with much less consideration.  I can see how
> > > > that would be easier for the specific use case, but that EXACTLY is
> > > > why it can't go upstream.  I just can't see it happening and think it
> > > 
> > > It can't go upstream because it's too easy to implement and fix?
> > > It can't go upstream because it has a specific use case?
> > > Is there something that says every interface added to the kernel *must*
> > > be useful for something besides the purpose that originally inspired it?
> > 
> > You really don't understand what I'm trying to say at all?
> 
> That's not what I said. I know you're arguing we shouldn't have an
> in-kernel implementation.
> 
> Your statement above did not seem to support your argument at all --
> you seemed to be conceding that an in-kernel implementation ("embedded
> in the kernel") would be easier to implement and fix (nit: would've
> been nice for you to include a bit more context..).

I see.  Probably I was too indirect, so let me try again.  The reason
why in-kernel implementation seems easier for CR itself is because it
has unlimited access to all the internal data structures, locking and
everything, which waivers a lot of efforts.  There's no layering to
consider and no userland visible API to worry about.

Unfortunately, those benefits don't come free.  It ends up adding a
lot of side-way accesses to different subsystems including another
locking vector, which add complexity to all the subsystems.  In short,
it makes CR easier by making everything else more complex.

Analogies are often misleading but in-kernel web server seems useful
to explain the point I'm trying to make (at least some part of it).
If the kernel lacks proper support API, hooking deeply into page
cache, network stack, scheduler and whatnot would make building high
performance web server much easier than trying to devise and implement
proper APIs to support high performance web server, and as a prototype
or probing project, in-kernel implementation sure would have a lot of
usefulness, but that's not how the end result should turn out.  It
makes maintaining and improving kernel subsystems unnecessarily
difficult for quite limited usefulness.

Again, I'm not saying CR is exactly the same and POV can vary greatly
depending on how one perceives various parameters, but I think it at
least illustrates my point clear.

> I know you think we should make use of lots of changes in a variety
> of places such as ptrace, new bits in /proc, etc. to avoid an in-kernel
> implementation. That's certainly an enticingly simple (non-complex) idea.
> However I still question whether the idea will work well for
> checkpoint/restart.

I think the difference in opinions originates from two major factors.
One being scope or completeness and the other perceived difficulties
of doing it from userland.  I think I've already said enough about the
former in another reply.

For the latter, I still can't see what would be so difficult.  We have
properly working ptrace now (and can even transparently inject worker
thread into the target process) so the core functionality is easily
(it takes effort but isn't technically difficult) achievable.  The
specific issues you've raised in this thread don't seem all that
daunting to tackle.  To me, the crux of most issues seems already
half-solved.  Maybe I'm overly optimistic but I don't really see any
missing chunk which is too big or especially difficult.  If you can
think of some, please bring them up.  Let's talk about them.

Thanks.

-- 
tejun
