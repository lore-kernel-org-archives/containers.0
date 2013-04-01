From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 23/28] lru: add an element to a memcg list
Date: Mon, 1 Apr 2013 12:29:03 +0400
Message-ID: <5159454F.10105__35671.9229523607$1364804942$gmane$org@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-24-git-send-email-glommer@parallels.com>
	<515942D8.1070301@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <515942D8.1070301-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 04/01/2013 12:18 PM, Kamezawa Hiroyuki wrote:
> (2013/03/29 18:14), Glauber Costa wrote:
>> With the infrastructure we now have, we can add an element to a memcg
>> LRU list instead of the global list. The memcg lists are still
>> per-node.
>>
>> Technically, we will never trigger per-node shrinking in the memcg is
>> short of memory. Therefore an alternative to this would be to add the
>> element to *both* a single-node memcg array and a per-node global array.
>>
> 
> per-node shrinking by memcg pressure is not imporant, I think.
> 
No, it is not. And this is precisely what I've stated: "we will never
trigger per-node shrinking in the memcg is short of memory."

This is to clarify that this design decision does not come from the need
to do that, which we don't have, but rather to save memory. Keeping
memcg objects per-node is less memory-expensive than adding an extra LRU
to the dentries and inodes. Therefore I do that, and when global
pressure kicks in I will scan all memcgs that belong to that node.

This will break global LRU order, but will help maintain fairness among
different memcgs.

>>   
>>   struct list_lru {
>>   	struct list_lru_node	node[MAX_NUMNODES];
>> +	atomic_long_t		node_totals[MAX_NUMNODES];
> 
> some comments will be helpful. 
> 
Yes, they will!

>> +
>> +static inline struct list_lru_node *
>> +lru_node_of_index(struct list_lru *lru, int index, int nid)
>> +{
>> +	BUG_ON(index < 0); /* index != -1 with !MEMCG_KMEM. Impossible */
>> +	return &lru->node[nid];
>> +}
>>   #endif
> 
> I'm sorry ...what "lru_node_of_index" means ? What is the "index" ?

There is extensive documentation for this above the macro
for_each_memcg_lru_index, so I didn't bother rewriting it here. But I
can add pointers like "see more at for_each..."

Basically, this will be either the memcg index if we want memcg reclaim,
or -1 for the global LRU. This is not 100 % the memcg index, so I called
it just "index".

IOW, it is the index in the memcg array if index >= 0, or the global
array if index < 0.
