From: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: memrlimit controller merge to mainline
Date: Wed, 30 Jul 2008 01:16:17 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0807300113200.14699@blonde.site>
References: <6599ad830807250114h7ab0fdb1u98c0968961647642@mail.gmail.com>
	<Pine.LNX.4.64.0807251004570.31120@blonde.site>
	<6599ad830807250706t23e483b5j18d683c0470d1d22@mail.gmail.com>
	<Pine.LNX.4.64.0807251715070.12089@blonde.site>
	<20080729150111.f879c989.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080729150111.f879c989.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Rik van Riel <riel-ebMLmSuQjDVBDgjK7y7TUQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org" <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 29 Jul 2008, KAMEZAWA Hiroyuki wrote:
> On Fri, 25 Jul 2008 17:46:45 +0100 (BST)
> Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org> wrote:
> 
> > IIRC Rik expressed the same by pointing out that a cgroup at its
> > swap limit would then be forced to grow in mem (until it hits its
> > mem limit): so controlling the less precious resource would increase
> > pressure on the more precious resource.  (Actually, that probably
> > bears little relation to what he said - sorry, Rik!)  I don't recall
> > what answer he got, perhaps I'd be persuaded if I heard it again.
> > 
> Added Nishimura to CC.
> 
> IMHO, from user point of view, both of
>  - having 2 controls as mem controller + swap controller
>  - mem + swap controller
> doesn't have much difference. The users will use as they like.

I'm not suggesting either one of those alternatives.

I'm suggesting we have a mem controller (the thing we already have)
and a mem+swap controller (which we don't yet have: a controller
for the total mem+swap of a cgroup); the mem+swap controller likely
making use of much that is in the mem controller, as Paul has said.

(Unfortunately I don't have a good name for this "mem+swap".)

I happen to believe that the mem+swap controller would actually be
a lot more useful than the current mem controller, and would expect
many to run with mem+swap controller enabled but mem controller
disabled or unlimited.  How much is mem and how much is swap being
left to global reclaim to decide, not imposed by any cgroup policy.

What I don't like the sound of at all is a swap controller.  Do you
think that a mem controller (limit 1G) and a mem+swap controller
(limit 2G) is equivalent to a mem controller (limit 1G) and a
swap controller (limit 1G)?  No: imagine memory pressure from
outside the cgroup - with the mem+swap controller it can push as
much as suits of the 2G out to swap; whereas with the swap controller,
once 1G is out, it has to stop pushing any more of that cgroup out.
I think that's absurd - but perhaps I just haven't looked, and
I've totally misinterpreted the talk of a swap controller.

> 
> >From memory controller's point of view, treating mem+swap by the same
> controller makes sense. Because memory controller can check wheter we can use
> more swap or not, we can avoid hopeless-scanning of Anon at swap-shortage.
> (By split-lru, I think we can do this avoidance.)

That's a detail I'm not concerned with on this level.

>  
> Another-Topic?
> 
> In recent servers, memory is big, swap is (relatively) small.

You'll know much more about those common proportions than I do.
I'd wonder why such big memory servers have any swap at all:
to cope with VM management defects we should be fixing?

> And under memory resource controller, the whole swap is easily occupied
> by a group. I want to avoid it.

Why?  I presume because you're thinking it a precious resource.
I don't think its relative smallness makes it more precious.

> 
> For users, swap is not precious because it's not fast. 

Yes, and that's my view.

> But for memory reclaiming, swap is precious resource to page out
> anonymous/shmem/tmpfs memory.

I see that makes swap a useful resource, I don't see that it makes
it a precious resource.  We page out to it precisely because it's
less precious than the memory; both users and kernel would much
prefer to keep all the data in memory, but sometimes there isn't
enough memory so we go to swap.

There is just one way in which I see swap as precious, and that
is to get around some VM management stupidity.  If, for example,
on i386 there's a shortage of lowmem and lots of anonymous in lowmem
that we should shift to highmem, then I think it's still the case
that we have to do that balancing via writing out to and reading
in from swap, because nobody has actually hooked up page migration
to do that when appropriate?  But that's an argument for extending
page migration, not for needing a swap controller.

> I think usual system-admin considers swap as some emergency spare of memory.

Yes, I do too.

> I'd like to allow this "emergency spare" to each cgroup.

We do allow that emergency spare to each cgroup.  Perhaps you're
saying you want to divide it up in advance between the cgroups?
But why?  Sounds like a nice idea (reminds me of what Paul said
about using temporary files), but a solution to what problem?

> (For example, swap is used even if vm.swappiness==0. This is for avoiding
> OOM-Killer under some situation, this behavior is added by Rik.)

Sorry, I don't know what you're referring to there, but again,
suspect it's a detail we don't need to be concerned with here.

> 
> == following is another use case I explained to Rik at 23/May/08 ==
> 
> IIRC, a man shown his motivation to controll swap in OLS2007/BOF as following.
> Consider following system. (and there is no swap controller.) 
> Memory 4G. Swap 1G. with 2 cgroups A, B.
> 
> state 1) swap is not used.
>   A....memory limit to be 1G  no swap usage memory_usage=0M
>   B....memory limit to be 1G  no swap usage memory_usage=0M
> 
> state 2) Run a big program on A.
>   A....memory limit to be 1G and try to use 1.7G. uses 700MBytes of swap.
>        memory_usage=1G swap_usage=700M
>   B....memory_usage=0M
> 
> state 3) A some of programs ends in 'A'
>   A....memory_usage=500M swap_usage=700M
>   B....memory_usage=0M.
> 
> state 4) Run a big program on B.
>   A...memory_usage=500M swap_usage=700M.
>   B...memory_usage=1G   swap_usage=300M

Right, thanks a lot for looking that out again, it's a good example
which helped to focus my mind.  But I don't think I'm learning from
it what you intended.

If you believe a swap controller would make that better, what limits
do you suggest?  If you assign A a swap limit of 700M or above, it
changes nothing; if you assign A a swap limit below 700M, it cannot
do all the work that it could do in the example.

The example tells me two things: one, that artificial limits can
indeed push you into awkward corners; two, that a mem+swap controller
makes more sense than a mem controller - give both A and B a mem+swap
limit of 2.5G, or 1.7G even, they'll run much better that way.

(Three: we should have a way of migrating pages back from swap,
other than use or swapoff?  Certainly there are arguments for
swap prefetch, but I don't see this as one of them: let A's
pages stay on swap until A needs them in memory, why not?)

> 
> Group B can only use 1.3G because of unfair swap use of group A.

"unfair swap use"!  A is _disadvantaged_ by having its pages out
on swap, or will be disadvantaged if it ever needs them again.
The anomaly comes from imposing a low mem limit on B instead of
a more liberal mem+swap limit.

> But users think why A uses 700M of swap with 500M of free memory....

Because at this time A isn't actively using any of that 700M.

Hugh
