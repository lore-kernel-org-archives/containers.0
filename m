From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] memory controller : backgorund reclaim and avoid
	excessive locking [5/5] lazy page_cgroup freeing
Date: Mon, 18 Feb 2008 13:55:21 +0900
Message-ID: <20080218135521.2cee9df5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080214172148.bfd564d5.kamezawa.hiroyu@jp.fujitsu.com>
	<20080214173624.d29b26d9.kamezawa.hiroyu@jp.fujitsu.com>
	<47B90B04.3090001@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47B90B04.3090001-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 18 Feb 2008 10:05:16 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> Hi, KAMEZAWA-San,
> 
> For this and the next patch, do you know if there is a performance improvement?
> Have we measured it. The complexity of the code seems to be high, want to make
> sure it is worth it.

I'd like to make codes simpler (by removing knobs and...)
I confirmed lock-contention/cache bouncing was much reduced.
(you can see it by /proc/lock_stat)
But I have no number now. I'm now searching an apps which can show performance
improvement clearly and wait for avilable machine ;)
So, please wait. I'm not hurrying.

> Could we re-use the pagevec mechansim for LRU handling?
Hmm, it's also complicated.

>That was my long term plan and I also wanted to move the kmalloc's to their
>own cache and use kmem_cache_alloc and try some other experiments.
maybe good idea.

> May be batching the alloc's for
> page_container can be done in the same way that you've proposed LRU and
> accounting changes.
> 
Maybe.

Thanks,
-Kame
