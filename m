From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [9/10]
 per-zone-lru for memory cgroup
Date: Mon, 19 Nov 2007 15:35:49 +0900
Message-ID: <20071119153549.d6f6f1de.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071116191107.46dd523a.kamezawa.hiroyu@jp.fujitsu.com>
	<20071116192642.8c7f07c9.kamezawa.hiroyu@jp.fujitsu.com>
	<473F2A1A.8000703@linux.vnet.ibm.com>
	<20071119104826.e4ba02ca.kamezawa.hiroyu@jp.fujitsu.com>
	<47412B5B.80409@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47412B5B.80409-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 19 Nov 2007 11:51:15 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > =
> > /cgroup/group_A/group_A_1
> >             .  /group_A_2
> >                /group_A_3
> > (LRU(s) will be used for maintaining parent/child groups.)
> > 
> 
> The LRU's will be shared, my vision is
> 
> 		LRU
> 		^ ^
> 		| |
> 	Mem-----+ +----Mem
> 
> 
> That two or more mem_cgroup's can refer to the same LRU list and have
> their own resource counters. This setup will be used in the case
> of a hierarchy, so that a child can share memory with its parent
> and have it's own limit.
> 
> The mem_cgroup will basically then only contain a reference
> to the LRU list.
> 
Hmm, interesting. 

Then, 
   group_A_1's usage + group_A_2's usage + group_A_3's usgae < group_A's limit.
   group_A_1, group_A_2, group_A_3 has its own limit.
In plan.

I wonder if we want rich control functions, we need "share" or "priority" among
childs. (but maybe this will be complicated one.)

Thank you for explanation.

Regards,
-Kame
