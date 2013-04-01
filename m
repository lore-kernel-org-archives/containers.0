From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 22/28] memcg,
	list_lru: duplicate LRUs upon kmemcg creation
Date: Mon, 1 Apr 2013 12:22:38 +0400
Message-ID: <515943CE.9070709__12682.874283246$1364804558$gmane$org@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-23-git-send-email-glommer@parallels.com>
	<51593FD0.9080502@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51593FD0.9080502-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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

Hi Kame,

>>   
>> +/*
>> + * This is supposed to be M x N matrix, where M is kmem-limited memcg,
>> + * and N is the number of nodes.
>> + */
> 
> Could you add a comment that M can be changed and the array can be resized.
Yes, I can.

> 
>> +struct list_lru_array {
>> +	struct list_lru_node node[1];
>> +};
>> +
>>   struct list_lru {
>>   	struct list_lru_node	node[MAX_NUMNODES];
>>   	nodemask_t		active_nodes;
>> +#ifdef CONFIG_MEMCG_KMEM
>> +	struct list_head	lrus;
>> +	struct list_lru_array	**memcg_lrus;
>> +#endif
> 
> please add comments, for what ....
> 
ok.

>> +struct list_lru_array *lru_alloc_array(void)
>> +{
>> +	struct list_lru_array *lru_array;
>>   	int i;
>>   
>> -	nodes_clear(lru->active_nodes);
>> -	for (i = 0; i < MAX_NUMNODES; i++) {
>> -		spin_lock_init(&lru->node[i].lock);
>> -		INIT_LIST_HEAD(&lru->node[i].list);
>> -		lru->node[i].nr_items = 0;
>> +	lru_array = kzalloc(nr_node_ids * sizeof(struct list_lru_node),
>> +				GFP_KERNEL);
> 
> A nitpick...you can use kmalloc() here. All field will be overwritten.
It is, however, not future-proof if anyone wants to add more fields, and
forget to zero out the structure. If you really feel strongly for
kmalloc I can change. But I don't see this as a big issue, specially
this not being a fast path.

>> +#ifdef CONFIG_MEMCG_KMEM
>> +int __memcg_init_lru(struct list_lru *lru)
>> +{
>> +	int ret;
>> +
>> +	INIT_LIST_HEAD(&lru->lrus);
>> +	mutex_lock(&all_memcg_lrus_mutex);
>> +	list_add(&lru->lrus, &all_memcg_lrus);
>> +	ret = memcg_new_lru(lru);
>> +	mutex_unlock(&all_memcg_lrus_mutex);
>> +	return ret;
>> +}
> 
> returns 0 at success ? what kind of error can be shown here ?
> 

memcg_new_lru will allocate memory, and therefore can fail with ENOMEM.
It will already return 0 itself on success, so just forwarding its
return value is around.

>> -EXPORT_SYMBOL_GPL(list_lru_init);
>> +EXPORT_SYMBOL_GPL(__list_lru_init);
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index ecdae39..c6c90d8 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2988,16 +2988,30 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
>>   	memcg_kmem_set_activated(memcg);
>>   
>>   	ret = memcg_update_all_caches(num+1);
>> -	if (ret) {
>> -		ida_simple_remove(&kmem_limited_groups, num);
>> -		memcg_kmem_clear_activated(memcg);
>> -		return ret;
>> -	}
>> +	if (ret)
>> +		goto out;
>> +
>> +	/*
>> +	 * We should make sure that the array size is not updated until we are
>> +	 * done; otherwise we have no easy way to know whether or not we should
>> +	 * grow the array.
>> +	 */
>> +	ret = memcg_update_all_lrus(num + 1);
>> +	if (ret)
>> +		goto out;
>>   
>>   	memcg->kmemcg_id = num;
>> +
>> +	memcg_update_array_size(num + 1);
>> +
>>   	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
>>   	mutex_init(&memcg->slab_caches_mutex);
>> +
>>   	return 0;
>> +out:
>> +	ida_simple_remove(&kmem_limited_groups, num);
>> +	memcg_kmem_clear_activated(memcg);
>> +	return ret;
> 
> When this failure can happens ? This happens only when the user
> tries to set kmem_limit and doesn't affect kernel internal logic ?
> 

There are 2 points of failure for this:
1) setting kmem limit from a previously unset scenario,
2) creating a new child memcg, as a child of a kmem limited memcg

Those are the same as the slab, and indeed they are attempted right
after it.

LRU initialization failures can still exist in a 3rd way, when a new LRU
is created and we have no memory available to hold its structures. But
this will not be called from here.
