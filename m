From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] [RFC PATCH 0/4] Container Freezer: Reuse Suspend	Freezer
Date: Fri, 04 Apr 2008 17:54:03 -0700
Message-ID: <1207356843.30178.180.camel__17365.8642372631$1207356981$gmane$org@localhost.localdomain>
References: <20080403210316.397506379@us.ibm.com>
	<6599ad830804031649p6bbc60f3s59fb7c25a7260505@mail.gmail.com>
	<1207278180.30178.94.camel@localhost.localdomain>
	<47F64FBB.2080207@cs.columbia.edu>
	<1207348060.30178.166.camel@localhost.localdomain>
	<47F6C829.4010109@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47F6C829.4010109-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org


On Fri, 2008-04-04 at 20:30 -0400, Oren Laadan wrote:
> 
> Matt Helsley wrote:

<snip>

> > 	I don't have an upper limit on how many more states we will need and I
> > think that number impacts the interface significantly. Can you give us
> > an estimate?
> 
> In Zap there are (using the current terminology):
> RUNNING - running
> FREEZING - transition to FROZEN
> FROZEN - frozen
> THAWING - transition to RUNNING
> CKPTING - being checkpointed (needs special semantics* for some ops)
> RSTRTING - being restarted (may need special semantics* for some ops)
> ABORTING - transition to DEAD (mainly when aborting a failed restart)
> DEAD - dead (but not fully cleaned up yet)
> 
> There is also "SPECIAL" in which some operations are not allowed;
> this simplifies dealing with a bunch of races related to checkpoint/
> restart, but I'm not sure it's a must. If anything, it only stays
> for very short times (like an uninterruptible sleep) saying "don't
> mess with this container now, it's busy".
> 
> I have very good justifications for almost all the states, a good
> reasoning for DEAD, and a case for SPECIAL (although there may be
> a way to do without it).
> 
> Despite the "many" states, there are very few transitions: CKPTING
> can only be reached from- and changed to- FROZEN. A similar rule holds
> for RSTRTING. ABORTING is reached from RSTRTING, and leads to DEAD.
> The only one I don't cover is reaching DEAD from any other state
> (except SPECIAL) but I never saw a reason to explicitly encode that.
> Something like this (without SPECIAL):
> 
>           ->  FREEZING  ->          <-> CKPTING
> RUNNING                    FROZEN
>           <-  THAWING   <-          <-> RSTRTING -> ABORTING -> DEAD
> 
> Out of curiosity - why does the number of states impact the interface
> so much ?

	Only that, if you're trying to keep the interface human readable, then
having too many names for things (states and transitions) can make the
interface less than intuitive. Doesn't look like that's an issue for the
above state machine though so I think you're right -- a single file with
transitions encoded as states seems best.

> > 
> >> Second, my gut feeling is that a single, atomic operation to get the
> >> status is preferred over multiple (non-atomic) operations. In other
> >> words, I suggest a single state file instead of two. You can encode
> >> every possible transition in a single state. It's not that the kernel
> > 
> > 	If the transitions are to be human-readable and there are more than a
> > small number of states it may not be desirable to encode transitions as
> > states. Paul's reason for suggesting the additional file(s), as best I
> > could tell, was to keep the interface human-readable.
> 
> The scheme above has very few transitions. Whatever be the final scheme,
> I would prefer not to have many possible transition (the full matrix).
> It probably isn't necessary either.
> 
> The main idea behind limiting the transitions above, is that checkpoint
> requires to first freeze the container to be able to capture a consistent
> view of the state of its processes; that means, for example, that we also
> would like to prevent signals from being delivered to tasks in a frozen
> state (if you do want to signal - thaw it first).
> 
> There is also the issue of a pre-checkpoint (a.k.a live migration) where
> significant state (mainly memory) of the container is recorded while the
> container is still running, and when it's finally frozen little state
> remains to be saved, reducing the application downtime. I didn't see a
> need for a special state for this case; instead Zap uses a status flag
> that belongs to the container.
> 
> Oren.

Thanks for the explanation of the states.

Cheers,
	-Matt Helsley
