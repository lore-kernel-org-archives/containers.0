From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] [-mm PATCH] Memory controller fix swap charging context
 in unuse_pte()
Date: Fri, 26 Oct 2007 11:44:44 +0530
Message-ID: <472185D4.6090801@linux.vnet.ibm.com>
References: <20071005041406.21236.88707.sendpatchset@balbir-laptop>
	<Pine.LNX.4.64.0710071735530.13138@blonde.wat.veritas.com>
	<4713A2F2.1010408@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0710221933570.21262@blonde.wat.veritas.com>
	<471F3732.5050407@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0710252002540.25735@blonde.wat.veritas.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0710252002540.25735-VFT1Jj/mpSzq8/QPP7pA5326JSxr+BKB@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linux MM Mailing List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hugh Dickins wrote:
> Gosh, it's nothing special.  Appended below, but please don't shame
> me by taking it too seriously.  Defaults to working on a 600M mmap
> because I'm in the habit of booting mem=512M.  You probably have
> something better yourself that you'd rather use.
> 

Thanks for sending it. I do have something more generic that I got
from my colleague.

>> In the use case you've mentioned/tested, having these mods to
>> control swapcache is actually useful, right?
> 
> No idea what you mean by "these mods to control swapcache"?
> 

Yes

> With your mem_cgroup mods in mm/swap_state.c, swapoff assigns
> the pages read in from swap to whoever's running swapoff and your
> unuse_pte mem_cgroup_charge never does anything useful: swap pages
> should get assigned to the appropriate cgroups at that point.
> 
> Without your mem_cgroup mods in mm/swap_state.c, unuse_pte makes
> the right assignments (I believe).  But I find that swapout (using
> 600M in a 512M machine) from a 200M cgroup quickly OOMs, whereas
> it behaves correctly with your mm/swap_state.c.
> 

I'll try this test and play with your test

> Thought little yet about what happens to shmem swapped pages,
> and swap readahead pages; but still suspect that they and the
> above issue will need a "limbo" cgroup, for pages which are
> expected to belong to a not-yet-identified mem cgroup.
> 

This is something I am yet to experiment with. I suspect this
should be easy to do if we decide to go this route.


>> Could you share your major objections at this point with the memory
>> controller at this point. I hope to be able to look into/resolve them
>> as my first priority in my list of items to work on.
> 
> The things I've noticed so far, as mentioned before and above.
> 
> But it does worry me that I only came here through finding swapoff
> broken by that unuse_mm return value, and then found one issue
> after another.  It feels like the mem cgroup people haven't really
> thought through or tested swap at all, and that if I looked further
> I'd uncover more.
> 

I thought so far that you've found a couple of bugs and one issue
with the way we account for swapcache. Other users, KAMEZAWA,
YAMAMOTO have been using and enhancing the memory controller.
I can point you to a set of links where I posted all the test
results. Swap was tested mostly through swapout/swapin when the
cgroup goes over limit. Please do help uncover as many bugs
as possible, please look more closely as you find more time.


> That's simply FUD, and I apologize if I'm being unfair: but that
> is how it feels, and I expect we all know that phase in a project
> when solving one problem uncovers three - suggests it's not ready.
> 

I disagree, all projects/code do have bugs, which we are trying to
resolve, but I don't think there are any major design drawbacks
that *cannot* be fixed. We discussed the design at VM-Summit and
everyone agreed it was the way to go forward (even though Double
LRU has its complexity).

> Hugh

[snip]

Thanks for the review and your valuable feedback!

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
