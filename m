From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 6/6 mm] memcgroup: revert swap_state mods
Date: Mon, 12 Nov 2007 12:26:04 +0530
Message-ID: <4737F904.8080107@linux.vnet.ibm.com>
References: <Pine.LNX.4.64.0711090700530.21638@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0711090713300.21663@blonde.wat.veritas.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0711090713300.21663-VFT1Jj/mpSzq8/QPP7pA5326JSxr+BKB@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Hugh Dickins wrote:
> If we're charging rss and we're charging cache, it seems obvious that
> we should be charging swapcache - as has been done.  But in practice
> that doesn't work out so well: both swapin readahead and swapoff leave
> the majority of pages charged to the wrong cgroup (the cgroup that
> happened to read them in, rather than the cgroup to which they belong).
> 
> (Which is why unuse_pte's GFP_KERNEL while holding pte lock never
> showed up as a problem: no allocation was ever done there, every page
> read being already charged to the cgroup which initiated the swapoff.)
> 
> It all works rather better if we leave the charging to do_swap_page and
> unuse_pte, and do nothing for swapcache itself: revert mm/swap_state.c
> to what it was before the memory-controller patches.  This also speeds
> up significantly a contained process working at its limit: because it
> no longer needs to keep waiting for swap writeback to complete.
> 

Yes, it does speed up things, but we lose control over swap cache.
It might grow very large, but having said that I am in favour of
removing the mods till someone faces a severe problem with them.
Another approach is to provide a per-container tunable as to
whether swap cache should be controlled or not and document
the side-effects of swap cache control.

> Is it unfair that swap pages become uncharged once they're unmapped,
> even though they're still clearly private to particular cgroups?  For
> a short while, yes; but PageReclaim arranges for those pages to go to
> the end of the inactive list and be reclaimed soon if necessary.
> 
> shmem/tmpfs pages are a distinct case: their charging also benefits
> from this change, but their second life on the lists as swapcache
> pages may prove more unfair - that I need to check next.
> 
> Signed-off-by: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>

Thanks for the patch

Acked-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
