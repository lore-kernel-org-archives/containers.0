From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
Date: Thu, 26 Feb 2009 18:33:02 +0100
Message-ID: <20090226173302.GB29439__14218.0386501879$1235669832$gmane$org@elte.hu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1234285547.30155.6.camel@nimitz>
	<20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz>
	<1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz>
	<20090212141014.2cd3d54d.akpm@linux-foundation.org>
	<1234479845.30155.220.camel@nimitz>
	<20090226162755.GB1456@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090226162755.GB1456-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


* Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Regarding interactions of C/R with other code:
> 
> 1. trivia
> 1a. field in some datastructure is removed
> 
> 	technically, compilation breaks
> 
> 	Need to decide what to do -- from trivial compile fix
> 	by removing code to ignoring some fields in dump image.
> 
> 1b. field is added
> 
> 	This is likely to happen silently, so maintainers
> 	will have to keep an eye on critical data structures
> 	and general big changes in core kernel.
> 
> 	Need to decide what to do with new field --
> 	anything from 'doesn't matter' to 'yeah, needs C/R part'
> 	with dump format change.
> 
> 2. non-trivia
> 2a. standalone subsystem added (say, network protocol)
> 
>     If submitter sends C/R part -- excellent.
>     If he doesn't, well, don't forget to add tiny bit of check
> 	and abort if said subsystem is in use.
> 
> 2b. massacre inside some subsystem (say, struct cred introduction)
> 
> 	Likely, C/R non-trivially breaks both in compilation and
> 	in working, requires non-trivial changes in algorithms and in
> 	C/R dump image.
> 
> For some very core data structures dump file images should be made
> fatter than needed to more future-proof, like
> a) statistics in u64 regardless of in-kernel width.
> b) ->vm_flags in image should be at least u64 and bits made append-only
> 	so dump format would survive flags addition, removal and
> 	renumbering.
> and so on.
> 
> 
> 
> So I guess, at first C/R maintainers will take care of all of 
> these issues with default policy being 'return -E, implement 
> C/R later', but, ideally, C/R will have same rights as other 
> kernel subsystem, so people will make non-trivial changes in 
> C/R as they make their own non-trivial changes.
> 
> If last statement isn't acceptable, in-kernel C/R is likely 
> doomed from the start (especially given lack of in-kernel 
> testsuite).

Well, given the fact that OpenVZ has followed such upstream 
changes for years successfully, there's precedent that it's 
possible to do it and stay sane.

If C/R is bitrotting will it be blamed on the maintainer who 
broke it, or on C/R maintainers? Do we have a good, fast and 
thin vector along which we can quickly tag Kconfig spaces (or 
even runtime flags) that are known (or discovered) to be C/R 
unsafe?

Is there any automated test that could discover C/R breakage via 
brute force? All that matters in such cases is to get the "you 
broke stuff" information as soon as possible. If it comes at an 
early stage developers can generally just fix stuff. If it comes 
in late, close to some release, people become more argumentative 
and might attack C/R instead of fixing the code.

I think the main question is: will we ever find ourselves in the 
future saying that "C/R sucks, nobody but a small minority uses 
it, wish we had never merged it"? I think the likelyhood of that 
is very low. I think the current OpenVZ stuff already looks very 
useful, and i dont think we've realized (let alone explored) all 
the possibilities yet.

	Ingo
