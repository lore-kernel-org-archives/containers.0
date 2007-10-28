From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] [-mm PATCH] Memory controller fix swap charging context
	in unuse_pte()
Date: Mon, 29 Oct 2007 02:02:19 +0530
Message-ID: <20071028203219.GA7145@linux.vnet.ibm.com>
References: <20071005041406.21236.88707.sendpatchset@balbir-laptop>
	<Pine.LNX.4.64.0710071735530.13138@blonde.wat.veritas.com>
	<4713A2F2.1010408@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0710221933570.21262@blonde.wat.veritas.com>
	<471F3732.5050407@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0710252002540.25735@blonde.wat.veritas.com>
	<4724F0BC.1020209@linux.vnet.ibm.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4724F0BC.1020209-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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

On Mon, Oct 29, 2007 at 01:57:40AM +0530, Balbir Singh wrote:
Hugh Dickins wrote:

[snip]
 
> Without your mem_cgroup mods in mm/swap_state.c, unuse_pte makes
> the right assignments (I believe).  But I find that swapout (using
> 600M in a 512M machine) from a 200M cgroup quickly OOMs, whereas
> it behaves correctly with your mm/swap_state.c.
> 

On my UML setup, I booted the UML instance with 512M of memory and
used the swapout program that you shared. I tried two things


1. Ran swapout without any changes. The program ran well without
   any OOM condition occuring, lot of reclaim occured.
2. Ran swapout with the changes to mm/swap_state.c removed (diff below)
   and I still did not see any OOM. The reclaim count was much lesser
   since swap cache did not get accounted back to the cgroup from
   which pages were being evicted.

I am not sure why I don't see the OOM that you see, still trying. May be
I missing something obvious at this late hour in the night :-)

Output of the tests
-------------------

balbir@ubuntu:/container/swapout$ cat memory.limit_in_bytes
209715200
balbir@ubuntu:/container/swapout$ cat memory.usage_in_bytes
65536
balbir@ubuntu:/container/swapout$ cat tasks
1815
1847
balbir@ubuntu:/container/swapout$ ps
  PID TTY          TIME CMD
 1815 pts/0    00:00:00 bash
 1848 pts/0    00:00:00 ps
balbir@ubuntu:/container/swapout$ ~/swapout
balbir@ubuntu:/container/swapout$ echo $?
0
balbir@ubuntu:/container/swapout$ cat memory.failcnt
18

Diff to remove mods from swap_state.c (for testing only)
--------------------------------------------------------

--- mm/swap_state.c.org	2007-10-29 01:42:14.000000000 +0530
+++ mm/swap_state.c	2007-10-29 01:52:48.000000000 +0530
@@ -79,10 +79,6 @@ static int __add_to_swap_cache(struct pa
 	BUG_ON(PageSwapCache(page));
 	BUG_ON(PagePrivate(page));
 
-	error = mem_cgroup_cache_charge(page, current->mm, gfp_mask);
-	if (error)
-		goto out;
-
 	error = radix_tree_preload(gfp_mask);
 	if (!error) {
 		write_lock_irq(&swapper_space.tree_lock);
@@ -94,14 +90,11 @@ static int __add_to_swap_cache(struct pa
 			set_page_private(page, entry.val);
 			total_swapcache_pages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
-		} else
-			mem_cgroup_uncharge_page(page);
+		}
 
 		write_unlock_irq(&swapper_space.tree_lock);
 		radix_tree_preload_end();
-	} else
-		mem_cgroup_uncharge_page(page);
-out:
+	}
 	return error;
 }
 
@@ -141,7 +134,6 @@ void __delete_from_swap_cache(struct pag
 	BUG_ON(PageWriteback(page));
 	BUG_ON(PagePrivate(page));
 
-	mem_cgroup_uncharge_page(page);
 	radix_tree_delete(&swapper_space.page_tree, page_private(page));
 	set_page_private(page, 0);
 	ClearPageSwapCache(page);
-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
