From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: problem with ZONE_MOVABLE.
Date: Thu, 13 Sep 2007 21:23:30 +0530
Message-ID: <46E95CFA.6090300@linux.vnet.ibm.com>
References: <20070913190719.ab6451e7.kamezawa.hiroyu@jp.fujitsu.com>
	<20070913131117.GG22778@skynet.ie>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070913131117.GG22778-wJa12IhQEiizQB+pC5nmwQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mel Gorman <mel-wJa12IhQEiizQB+pC5nmwQ@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Mel Gorman wrote:
> On (13/09/07 19:07), KAMEZAWA Hiroyuki didst pronounce:
>> Hi, 
>>
>> While I'm playing with memory controller of 2.6.23-rc4-mm1, I met following.
>>
>> ==
>> [root@drpq test-2.6.23-rc4-mm1]# echo $$ > /opt/mem_control/group_1/tasks
>> [root@drpq test-2.6.23-rc4-mm1]# cat /opt/mem_control/group_1/memory.limit
>> 32768
>> [root@drpq test-2.6.23-rc4-mm1]# cat /opt/mem_control/group_1/memory.usage
>> 286
>> // Memory is limited to 512 GiB. try "dd" 1GiB (page size is 16KB)
>>  
>> [root@drpq test-2.6.23-rc4-mm1]# dd if=/dev/zero of=/tmp/tmpfile bs=1024 count=1048576
>> Killed
>> [root@drpq test-2.6.23-rc4-mm1]# ls
>> Killed
>> //above are caused by OOM.
>> [root@drpq test-2.6.23-rc4-mm1]# cat /opt/mem_control/group_1/memory.usage
>> 32763
>> [root@drpq test-2.6.23-rc4-mm1]# cat /opt/mem_control/group_1/memory.limit
>> 32768
>> // fully filled by page cache. no reclaim run.
>> ==
>>
>> The reason  this happens is  because I used kernelcore= boot option, i.e
>> ZONE_MOVABLE. Seems try_to_free_mem_container_pages() ignores ZONE_MOVABLE.
>>
>> Quick fix is attached, but Mel's one-zonelist-pernode patch may change this.
>> I'll continue to watch.
>>
> 
> You are right on both counts. This is a valid fix but
> one-zonelist-pernode overwrites it. Specifically the code in question
> with one-zonelist will look like;
> 
> 	for_each_online_node(node) {
> 		zonelist = &NODE_DATA(node)->node_zonelist;
> 		if (do_try_to_free_pages(zonelist, sc.gfp_mask, &sc))
> 			return 1;
> 	}
> 
> We should be careful that this problem does not get forgotten about if
> one-zonelist gets delayed for a long period of time. Have the fix at the
> end of the container patchset where it can be easily dropped if
> one-zonelist is merged.
> 
> Thanks

Yes, I second that. So, we should get KAMEZAWA's fix in.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
