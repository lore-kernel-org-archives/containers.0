From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Wed, 17 Nov 2010 14:17:13 -0800
Message-ID: <20101117221713.GA27736@count0.beaverton.ibm.com>
References: <AANLkTinOg6n3ZA+0gHzw9LouRuUmJ7DJwHtABRy5c=gM@mail.gmail.com>
 <4CD26948.7050009@kernel.org>
 <20101104164401.GC10656@sundance.ccs.neu.edu>
 <4CD3CE29.2010105@kernel.org>
 <20101106053204.GB12449@count0.beaverton.ibm.com>
 <20101106204008.GA31077@sundance.ccs.neu.edu>
 <4CD5D99A.8000402@cs.columbia.edu>
 <20101107184927.GF31077@sundance.ccs.neu.edu>
 <4CD72150.9070705@cs.columbia.edu>
 <4CE3C334.9080401@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CE3C334.9080401@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Gene Cooperman <gene@ccs.neu.edu>, Matt Helsley <matthltc@us.ibm.com>, Kapil Arya <kapil@ccs.neu.edu>, ksummit-2010-discuss@lists.linux-foundation.org, linux-kernel@vger.kernel.org, hch@lst.de, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Wed, Nov 17, 2010 at 12:57:40PM +0100, Tejun Heo wrote:
> Hello, Oren.
> 
> On 11/07/2010 10:59 PM, Oren Laadan wrote:

<snip>

> 
> > Even if that happens (which is very unlikely and unnecessary),
> > it will generate all the very same code in the kernel that Tejun
> > has been complaining about, and _more_. And we will still suffer
> > from issues such as lack of atomicity and being unable to do many
> > simple and advanced optimizations.
> 
> It may be harder but those will be localized for specific features
> which would be useful for other purposes too.  With in-kernel CR,
> you're adding a bunch of intrusive changes which can't be tested or
> used apart from CR.

You seem to be arguing "Z is only testable/useful for doing the things Z
was made for". I couldn't agree more with that. CR is useful for:

	Fault-tolerance (typical HPC)
	Load-balancing (less-typical HPC)
	Debugging (simple [e.g. instead of coredumps] or complex
		time-reversible)
	Embedded devices that need to deal with persistent low-memory
		situations.

I think Oren's Kernel Summit presentation succinctly summarized these:
	http://www.cs.columbia.edu/~orenl/talks/ksummit-2010.pdf

My personal favorite idea (that hasn't been implemented yet) is an
application startup cache. I've been wondering if caching bash startup
after all the shared libraries have been searched, loaded, and linked
couldn't save a bunch of time spent in shell scripts. Post-link actually
seems like a checkpoint in application startup which would be generally
useful too. Of course you'd want to flush [portions of] the cache when
packages get upgraded/removed or shell PATHs change and the caches
would have to be per-user.

I'm less confident but still curious about caching after running rc
scripts (less confident because it would depend highly on the content
of the rc scripts). A scripted boot, for example, might be able to save
some time if the same rc scripts are run and they don't vary over time.
That in turn might be useful for carefully-tuned boots on embedded devices.

That said we don't currently have code for application caching. Yet we
can't be expected to write tools for every possible use of our API in
order to show just how true your tautology is.

> 
> > Or we could use linux-cr for that: do the c/r in the kernel,
> > keep the know-how in the kernel, expose (and commit to) a
> > per-kernel-version ABI (not vow to keep countless new individual

Oren, that statement might be read to imply that it's based on
something as useless as kernel version numbers. Arnd has pointed out in the
past how unsuitable that is and I tend to agree. There are at least two
possible things we can relate it to: the SHA of the compiled kernel tree
(which doesn't quite work because it assumes everybody uses git trees :( ),
or perhaps the SHA/hash of the cpp-processed checkpoint_hdr.h. We could
also stuff that header into the kernel (much like kconfigs are output from
/proc) for programs that want the kernel to describe the ABI to them.

> > ABIs forever after getting them wrongly...), be able to do all
> > sorts of useful optimization and provide atomicity and guarantees
> > (see under "leak detection" in the OLS linux-cr paper). Also,
> > once the c/r infrastructure is in the kernel, it will be easy
> > (and encouraged) to support new =ly introduced features.
> 
> And the only reason it seems easier is because you're working around
> the ABI problem by declaring that these binary blobs wouldn't be kept
> compatible between different kernel versions and configurations.  That

Not true. First of all, if you look at checkpoint_hdr.h, the contents and
layout of the structs don't vary according to kernel configurations.
Secondly, we have taken measures to increase the likelihood that the
structures will remain compatible. We've designed them to layout the
same on 32-bit and 64-bit variants of an arch. We add to the end of the
structs. We use an explicit length field in a header to each section
to ensure that changes in the size of the structures don't necessarily
break compatibility.

That said, yes, these measures don't absolutely preclude incompatibility.
They will however make compatibility more likely.

Then there's the fact that structures like siginfo (for example) so rarely
change because they're already part of an ABI. That in turn means that the
corresponding checkpoint ABI rarely changes (we don't reuse the existing
struct because that would require compat-syscall-style code).

Most of the time, in fact, the fields we output are there only because
they reflect the 'model' of how things work that the kernel presents to
userspace. That model also rarely changes (we've never gotten rid of the
POSIX concept of process groups in one extreme example). Perhaps the 
closest thing we have to wholly-kernel-internal data structures are the
signal/sighand structs which echo the way these fields are split from the
task struct and shared between tasks. Though I'd argue that gets back into
the 'model' presented to userspace (via fork/clone) anyway...

I'd estimate that the biggest 'model' changes have come via various
filesystem interfaces over the years. We don't checkpoint tasks with open
sysfs, /proc, or debugfs files (for example) so that's not part of our
ABI and we don't intend to make it so.

Nor do we output wholly kernel-internal structures and fields that are
often chosen for their performance benefits (e.g. rbtrees, linked lists,
hash tables, idrs, various caches, locks, RCU heads, refcounts, etc). So
the kernel is free to change implementations without affecting our ABI.

The compatibility has natural limits. For instance we can't ever
restart an x86_64 binary on a 32-bit kernel. If you add a new syscall
interface (e.g. fanotify) then you can't use a checkpoint of a task that
makes use of it on fanotify-disabled kernels. Yet these limitations exist
no matter where or how you choose to implement checkpoint/restart.

We've made almost every effort at making this a proper ABI (I say
'almost' because we still need to export a description of it at runtime
and we need to do something better in place of the logfd output). Still,
the essentials of a proper checkpoint/restart ABI are already there.

Cheers,
	-Matt Helsley
