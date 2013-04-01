From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 26/28] memcg: per-memcg kmem shrinking
Date: Mon, 1 Apr 2013 12:48:43 +0400
Message-ID: <515949EB.7020400__31778.5487430685$1364806120$gmane$org@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-27-git-send-email-glommer@parallels.com>
	<515945E3.9090809@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <515945E3.9090809-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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

>> +static int memcg_try_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
>> +{
>> +	int retries = MEM_CGROUP_RECLAIM_RETRIES;
> 
> I'm not sure this retry numbers, for anon/file LRUs is suitable for kmem.
> 
Suggestions ?

>> +	struct res_counter *fail_res;
>> +	int ret;
>> +
>> +	do {
>> +		ret = res_counter_charge(&memcg->kmem, size, &fail_res);
>> +		if (!ret)
>> +			return ret;
>> +
>> +		if (!(gfp & __GFP_WAIT))
>> +			return ret;
>> +
>> +		/*
>> +		 * We will try to shrink kernel memory present in caches. We
>> +		 * are sure that we can wait, so we will. The duration of our
>> +		 * wait is determined by congestion, the same way as vmscan.c
>> +		 *
>> +		 * If we are in FS context, though, then although we can wait,
>> +		 * we cannot call the shrinkers. Most fs shrinkers (which
>> +		 * comprises most of our kmem data) will not run without
>> +		 * __GFP_FS since they can deadlock. The solution is to
>> +		 * synchronously run that in a different context.
>> +		 */
>> +		if (!(gfp & __GFP_FS)) {
>> +			/*
>> +			 * we are already short on memory, every queue
>> +			 * allocation is likely to fail
>> +			 */
>> +			memcg_stop_kmem_account();
>> +			schedule_work(&memcg->kmemcg_shrink_work);
>> +			flush_work(&memcg->kmemcg_shrink_work);
>> +			memcg_resume_kmem_account();
>> +		} else if (!try_to_free_mem_cgroup_kmem(memcg, gfp))
>> +			congestion_wait(BLK_RW_ASYNC, HZ/10);
> 
> Why congestion_wait() ? I think calling congestion_wait() in vmscan.c is
> a part of memory-reclaim logic but I don't think the caller should do
> this kind of voluteer wait without good reason..
> 
> 

Although it is not the case with dentries (or inodes, since only
non-dirty inodes goes to the lru list), some objects we are freeing may
need time to be written back to disk. This is the case for instance with
the buffer heads and bio's. They will not be actively shrunk in
shrinkers, but it is my understanding that they will be released. Inodes
as well, may have time to be written back and become non-dirty.

In practice, in my tests, this would almost-always fail after a retry if
we don't wait, and almost always succeed in a retry if we do wait.

Am I missing something in this interpretation ?
