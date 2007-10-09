From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH][for -mm] Fix and Enhancements for memory cgroup [0/6]
 intro
Date: Tue, 09 Oct 2007 16:00:55 +0530
Message-ID: <470B585F.9040207@linux.vnet.ibm.com>
References: <20071009184620.8b14cbc6.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071009184620.8b14cbc6.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> Hi, Balbir-san
> This is a patch set against memory cgroup I have now.
> Reflected comments I got.
> 
> = 
> [1] charge refcnt fix patch     - avoid charging against a page which is being 
>                                   uncharged.
> [2] fix-err-handling patch      - remove unnecesary unlock_page_cgroup()
> [3] lock and page->cgroup patch - add helper function for charge/uncharge
> [4] avoid handling no LRU patch - makes mem_cgroup_isolate_pages() avoid
>                                   handling !Page_LRU pages.
> [5] migration fix patch         - a fix for page migration.
> [6] force reclaim patch         - add an interface for uncharging all pages in
>                                   empty cgroup.
> =
> 

Thank you very much for working on this.

> BTW, which way would you like to go ?
> 
>   1. You'll merge this set (and my future patch) to your set as
>      Memory Cgroup Maintainer and pass to Andrew Morton, later.
>      And we'll work against your tree.
>   2. I post this set to the (next) -mm. And we'll work agaisnt -mm.
> 

I think (2) is better. I don't maintain my own tree, so lets get
all the fixes and enhancements into -mm

> not as my usual patch, tested on x86-64 fake-NUMA.
> 

I'll also test these patches.

> Thanks,
> -Kame
> 


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
