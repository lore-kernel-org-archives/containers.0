From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Sun, 07 Nov 2010 16:59:44 -0500
Message-ID: <4CD72150.9070705@cs.columbia.edu>
References: <Pine.LNX.4.64.1011021530470.12128@takamine.ncl.cs.columbia.edu>
	<4CD08419.5050803@kernel.org>
	<AANLkTinOg6n3ZA+0gHzw9LouRuUmJ7DJwHtABRy5c=gM@mail.gmail.com>
	<4CD26948.7050009@kernel.org>
	<20101104164401.GC10656@sundance.ccs.neu.edu>
	<4CD3CE29.2010105@kernel.org>
	<20101106053204.GB12449@count0.beaverton.ibm.com>
	<20101106204008.GA31077@sundance.ccs.neu.edu>
	<4CD5D99A.8000402@cs.columbia.edu>
	<20101107184927.GF31077@sundance.ccs.neu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101107184927.GF31077-Rl5vdzG4YPwx/1z6v04GWfZ8FUJU4vz8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gene Cooperman <gene-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>
Cc: Kapil Arya <kapil-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ksummit-2010-discuss-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, hch-jcswGhMUV9g@public.gmane.org
List-Id: containers.vger.kernel.org

[cc'ing linux containers mailing list]

On 11/07/2010 01:49 PM, Gene Cooperman wrote:

[snip]

> Matt had asked how we would handle inotify(), but I was getting swamped
> by all the questions.  There is a virtualization approach to inotify in which
> one puts wrappers around inotify_add_watch(), inotify_rm_watch() and
> friends in the same way as we wrap open() and could wrap close().
> One would then need to wrap read() (which we don't like to do, just

This sounds like reimplementation in userspace the very same logic
done by the kernel :)

> in case it could add significant overhead).  But if we consider kernel
> and userland virtualization together, then something similar to  TIOCSTI
> for ioctl would allow us to avoid wrapping read().

We could work to add ABIs and APIs for each and every possible piece
of state that affects userspace. And for each we'll argue forever
about the design and some time later regret that it wasn't designed
correctly :p

Even if that happens (which is very unlikely and unnecessary),
it will generate all the very same code in the kernel that Tejun
has been complaining about, and _more_. And we will still suffer
from issues such as lack of atomicity and being unable to do many
simple and advanced optimizations.

Or we could use linux-cr for that: do the c/r in the kernel,
keep the know-how in the kernel, expose (and commit to) a
per-kernel-version ABI (not vow to keep countless new individual
ABIs forever after getting them wrongly...), be able to do all
sorts of useful optimization and provide atomicity and guarantees
(see under "leak detection" in the OLS linux-cr paper). Also,
once the c/r infrastructure is in the kernel, it will be easy
(and encouraged) to support new =ly introduced features.

Finally, then we would use dmtcp as well as other tools on top
of the kernel-cr - and I'm looking forward to do that !

[snip]

>> Hmm... can you really c/r from userspace a process that was, at
>> checkpoint time, in a ptrace-stopped state at an arbitrary kernel
>> ptrace-hook ?  I strongly suspect the answer is "no", definitely
>> not unless you also virtualize and replicate the entire in-kernel
>> ptrace functionality in userspace,
>
> Let's try it and see.  If you write a program, we'll try it out in
> DMTCP (unstable branch) and see.  So far, checkpointing gdb sessions
> has worked well for us.  If there is something we don't cover, it will
> be helpful to both of us to find it, and analyze that case.

Try "strace bash" :)
I suspect it won't work - and for the reasons I described.

[snip]

>> (Now looking forward to discuss more details with dmtcp team on
>> Tuesday and on :)
>
> Also a very good point above, and I agree.  The offline discussion should
> be a better forum for putting this all into perspective.
>
> Thanks again for your thoughtful response,

Same here. Talk to you soon...

Oren.
