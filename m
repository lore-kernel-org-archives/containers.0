From: Tejun Heo <tj@kernel.org>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Wed, 17 Nov 2010 12:57:40 +0100
Message-ID: <4CE3C334.9080401@kernel.org>
References: <Pine.LNX.4.64.1011021530470.12128@takamine.ncl.cs.columbia.edu> <4CD08419.5050803@kernel.org> <AANLkTinOg6n3ZA+0gHzw9LouRuUmJ7DJwHtABRy5c=gM@mail.gmail.com> <4CD26948.7050009@kernel.org> <20101104164401.GC10656@sundance.ccs.neu.edu> <4CD3CE29.2010105@kernel.org> <20101106053204.GB12449@count0.beaverton.ibm.com> <20101106204008.GA31077@sundance.ccs.neu.edu> <4CD5D99A.8000402@cs.columbia.edu> <20101107184927.GF31077@sundance.ccs.neu.edu> <4CD72150.9070705@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CD72150.9070705@cs.columbia.edu>
Sender: linux-kernel-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Gene Cooperman <gene@ccs.neu.edu>, Matt Helsley <matthltc@us.ibm.com>, Kapil Arya <kapil@ccs.neu.edu>, ksummit-2010-discuss@lists.linux-foundation.org, linux-kernel@vger.kernel.org, hch@lst.de, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Hello, Oren.

On 11/07/2010 10:59 PM, Oren Laadan wrote:
> We could work to add ABIs and APIs for each and every possible piece
> of state that affects userspace. And for each we'll argue forever
> about the design and some time later regret that it wasn't designed
> correctly :p

I'm sorry but in-kernel CR already looks like a major misdesign to me.

> Even if that happens (which is very unlikely and unnecessary),
> it will generate all the very same code in the kernel that Tejun
> has been complaining about, and _more_. And we will still suffer
> from issues such as lack of atomicity and being unable to do many
> simple and advanced optimizations.

It may be harder but those will be localized for specific features
which would be useful for other purposes too.  With in-kernel CR,
you're adding a bunch of intrusive changes which can't be tested or
used apart from CR.

> Or we could use linux-cr for that: do the c/r in the kernel,
> keep the know-how in the kernel, expose (and commit to) a
> per-kernel-version ABI (not vow to keep countless new individual
> ABIs forever after getting them wrongly...), be able to do all
> sorts of useful optimization and provide atomicity and guarantees
> (see under "leak detection" in the OLS linux-cr paper). Also,
> once the c/r infrastructure is in the kernel, it will be easy
> (and encouraged) to support new =ly introduced features.

And the only reason it seems easier is because you're working around
the ABI problem by declaring that these binary blobs wouldn't be kept
compatible between different kernel versions and configurations.  That
simply is the wrong approach.  If you want to export something, build
it properly into ABI.

> Finally, then we would use dmtcp as well as other tools on top
> of the kernel-cr - and I'm looking forward to do that !

Yeah, this part I agree.  The higher level workarounds implemented in
dmtcp are quite impressive and useful no matter what happens to lower
layer.

Thanks.

-- 
tejun
