From: Tejun Heo <tj@kernel.org>
Subject: Re: [EXAMPLE CODE] Parasite thread injection using PTRACE_SEIZE and
 friends
Date: Sat, 23 Jul 2011 04:10:48 +0200
Message-ID: <20110723021048.GA21089@mtj.dyndns.org>
References: <20110720140037.GM3455@htj.dyndns.org>
 <20110722231953.GC16940@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110722231953.GC16940@count0.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Glauber Costa <glommer@parallels.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Hey, Matt.

On Fri, Jul 22, 2011 at 04:19:53PM -0700, Matt Helsley wrote:
> parasitism is fine for a slow-but-sure debugger but is not suitable
> for checkpoint/restart.

Hmmm... okay, can you elaborate on that?  I can't reach the same
conclusion from what you wrote below.  You're implying parasitism
would be too slow for CR, right?  But why would it be slower or faster
in any meaningful way than in-kernel implementation?

> The difficulty of checkpoint/restart is not that the task has
> more information than the kernel.

But yes it is, if you're trying to implement it from userland in
transparent manner.  There is a lot of information which is not
available to a third party process and some of the available
information is painfully slow to get to (e.g. PTRACE_PEEK/POKEDATA is
word-by-word).

> Quite the contrary. Most of the "information" the task has that the
> kernel is not explicitly aware of is encoded in the task's
> memory. So long as the kernel faithfully restores memory and
> registers the task can know little the kernel doesn't already know.

Sure, kernel ultimately knows and can access *everything*, but we
aren't talking about in-kernel implementation here.

> One example of something the task knows that the kernel does not is
> which pids it cares about. However, a parasitic thread capable
> of checkpointing arbitrary processes won't know about these pids
> either -- it would have to be designed to checkpoint *only* the
> process it was injected into.

That's what the outer mechanism should provide regardless of how the
core CR is implemented.  Maybe it is NS based, maybe it's just some
subset of processes.  It doesn't have much to do with core
implementation.

> Furthermore, the kernel has information necessary for
> checkpoint/restart that the task does not. The composition of an
> epoll set is one example.

Again, sure, kernel knows and can access everything, but most of
necessary information is already available in userland.  If epoll
isn't available, let's export epoll information.  We have
/proc/PID/fdinfo already.  If that's not the correct interface for
whatever reason, we can add introspection to epoll itself and make
parasite query it.

It's not like problems solve themselves automatically if you put CR
inside the kernel.  It side-steps a lot of issues mostly by allowing
avoiding difficult userland visible decisions, but as you already know
well enough, I think that does more harm than good.

Last year, when we were talking about userland implementation, one of
the arguments was that ptrace / jobctl interaction was too messy and
broken to be used for CR, but it's fixed now and the interaction is
well defined and jobctl states are fully capturable.  And really,
before, ptrace or in-kernel CR, it wasn't possible to capture the
states properly, they were simply broken and not well defined enough.

Identifying and fixing individual missing pieces is both more
benefical to the kernel in general and much more likely to be merged
upstream and the ptrace change for sure took a lot more time than I
expected but it was something which has been horribly broken for a
very long time and was very complex to deal with.  I think other
pieces - most of which should be about exporting more info via some
mechanism - should be much easier.

> So ptrace is just the wrong interface to base checkpoint/restart on.
> Pavel's approach, though I believe it is subtly flawed, is better.

Again, I just don't understand how you draw the above conclusion from
the arguments you provided above.  I don't see much connection between
the arguments and the conclusion.

Thanks.

-- 
tejun
