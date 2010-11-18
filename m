From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Thu, 18 Nov 2010 11:06:19 +0100
Message-ID: <4CE4FA9B.1060104@kernel.org>
References: <AANLkTinOg6n3ZA+0gHzw9LouRuUmJ7DJwHtABRy5c=gM@mail.gmail.com>
	<4CD26948.7050009@kernel.org>
	<20101104164401.GC10656@sundance.ccs.neu.edu>
	<4CD3CE29.2010105@kernel.org>
	<20101106053204.GB12449@count0.beaverton.ibm.com>
	<20101106204008.GA31077@sundance.ccs.neu.edu>
	<4CD5D99A.8000402@cs.columbia.edu>
	<20101107184927.GF31077@sundance.ccs.neu.edu>
	<4CD72150.9070705@cs.columbia.edu> <4CE3C334.9080401@kernel.org>
	<20101117221713.GA27736@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101117221713.GA27736-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: Kapil Arya <kapil-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>, Gene Cooperman <gene-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ksummit-2010-discuss-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, hch-jcswGhMUV9g@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Matt.

On 11/17/2010 11:17 PM, Matt Helsley wrote:
>> It may be harder but those will be localized for specific features
>> which would be useful for other purposes too.  With in-kernel CR,
>> you're adding a bunch of intrusive changes which can't be tested or
>> used apart from CR.
> 
> You seem to be arguing "Z is only testable/useful for doing the things Z
> was made for". I couldn't agree more with that. CR is useful for:

I'm saying it's way too narrow scoped and inflexible to be a kernel
feature.  Kernel features should be like the basic tools, you know,
hammers, saws, drills and stuff.  In-kernel CR is more like an over
complicated food processor which usually sits in the top drawer after
first several runs,

> 	Fault-tolerance (typical HPC)
> 	Load-balancing (less-typical HPC)
> 	Debugging (simple [e.g. instead of coredumps] or complex
> 		time-reversible)
> 	Embedded devices that need to deal with persistent low-memory
> 		situations.

which can do all of the above, a lot of which can be achieved in
less messy way than putting the whole thing inside the kernel.

> My personal favorite idea (that hasn't been implemented yet) is an
> application startup cache. I've been wondering if caching bash startup
> after all the shared libraries have been searched, loaded, and linked
> couldn't save a bunch of time spent in shell scripts. Post-link actually
> seems like a checkpoint in application startup which would be generally
> useful too. Of course you'd want to flush [portions of] the cache when
> packages get upgraded/removed or shell PATHs change and the caches
> would have to be per-user.

What does that have anything to do with the kernel?  If you want
post-link cache, implement it in ld.so where it belongs.  That's like
using food processor to mix cement.

> I'm less confident but still curious about caching after running rc
> scripts (less confident because it would depend highly on the content
> of the rc scripts). A scripted boot, for example, might be able to save
> some time if the same rc scripts are run and they don't vary over time.
> That in turn might be useful for carefully-tuned boots on embedded devices.
> 
> That said we don't currently have code for application caching. Yet we
> can't be expected to write tools for every possible use of our API in
> order to show just how true your tautology is.

Continuing the same line of thought.  It _CAN_ be used to do that in a
convoluted way but there are better ways to solve those problems.

> Most of the time, in fact, the fields we output are there only because
> they reflect the 'model' of how things work that the kernel presents to
> userspace. That model also rarely changes (we've never gotten rid of the
> POSIX concept of process groups in one extreme example). Perhaps the 
> closest thing we have to wholly-kernel-internal data structures are the
> signal/sighand structs which echo the way these fields are split from the
> task struct and shared between tasks. Though I'd argue that gets back into
> the 'model' presented to userspace (via fork/clone) anyway...

Yeah, exactly, so just do it inside the established ABI extending
where it makes sense.  No reason to add a whole separate set.

Thanks.

-- 
tejun
