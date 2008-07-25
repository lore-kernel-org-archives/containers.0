From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: memrlimit controller merge to mainline
Date: Fri, 25 Jul 2008 15:28:11 -0400
Message-ID: <488A294B.4090609@linux.vnet.ibm.com>
References: <6599ad830807250114h7ab0fdb1u98c0968961647642@mail.gmail.com>
	<Pine.LNX.4.64.0807251004570.31120@blonde.site>
	<6599ad830807250706t23e483b5j18d683c0470d1d22@mail.gmail.com>
	<Pine.LNX.4.64.0807251715070.12089@blonde.site>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0807251715070.12089-popGQ1T0qN76K7/ahGyk6A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Rik van Riel <riel-ebMLmSuQjDVBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Hugh Dickins wrote:
> On Fri, 25 Jul 2008, Paul Menage wrote:
>> On Fri, Jul 25, 2008 at 5:06 AM, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org> wrote:
>>> (Different topic, but one day I ought to get around to saying again
>>> how absurd I think a swap controller; whereas a mem+swap controller
>>> makes plenty of sense.  I think Rik and others said the same.)
>> Agreed that a swap controller without a memory controller doesn't make
>> much sense, but a memory controller without a swap controller can make
>> sense on machines that don't intend to use swap.
> 
> I agree that a memory controller without a swap controller can
> make sense: I hope so, anyway, since that's what's in mainline.
> Even if swap is used, memory is a more precious resource than swap,
> and you were right to go about controlling memory first.
> 

Yes, I agree.

>> So if they were separate controllers, we'd use the proposed cgroup
>> dependency features to make the swap controller depend on the memory
>> controller - in which case you'd only be able to mount the swap
>> controller on a hierarchy that also had the memory controller, and the
>> swap controller would be able to make use of the page ownership
>> information.
>>
>> It's more of a modularity issue than a functionality issue, I think -
>> the swap controller and memory controller are tracking fundamentally
>> different things (space on disk versus pages in memory), and the only
>> dependency between them is the "memory controller" tracking the
>> ownership of a page and providing it to the "swap controller".
> 
> It sounds as if you're interpreting my "mem+swap controller" as a
> mem controller and a swap controller and the swap controller makes
> use of some of the mem controller infrastructure.
> 
> No, I'm trying to say something stronger than that.  I'm saying,
> as I've said before, that I cannot imagine why anyone would want
> to control swap itself - what they want to control is the total
> of mem+swap.  Swap is a second-class citizen, nobody wants swap
> if they can have mem, so why control it separately?
> 
> IIRC Rik expressed the same by pointing out that a cgroup at its
> swap limit would then be forced to grow in mem (until it hits its
> mem limit): so controlling the less precious resource would increase
> pressure on the more precious resource.  (Actually, that probably
> bears little relation to what he said - sorry, Rik!)  I don't recall
> what answer he got, perhaps I'd be persuaded if I heard it again.
> 

I see what your saying. When you look at Linux right now, we control swap
independent of memory, so I am not totally opposed to setting swap, instead of
swap+mem. I might not want to swap from a particular cgroup, in which case, I
set swap to 0 and risk OOMing, which might be an acceptable trade-off depending
on my setup. I could easily change this policy on demand and add swap if OOMing
was no longer OK.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
