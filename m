From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 0/7] cgroup: io-throttle controller (v14)
Date: Fri, 24 Apr 2009 09:10:15 +0800
Message-ID: <49F11177.6000709__46295.6731477336$1240535617$gmane$org@cn.fujitsu.com>
References: <1240090636-898-1-git-send-email-righi.andrea@gmail.com>
	<49EC34C1.6010709@cn.fujitsu.com> <20090420144816.GA13307@linux>
	<49ED1E66.6030604@cn.fujitsu.com> <20090421095848.GB13699@linux>
	<49EE6E3C.8050409@cn.fujitsu.com> <20090422124328.GA32007@linux>
	<49EFD948.7050803@cn.fujitsu.com> <20090423101400.GA16768@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090423101400.GA16768@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Andrea Righi wrote:
> page_cgroup_*_onwer are defined in mm/page_cgroup.c, that is built if
> CONFIG_PAGE_TRACKING=y. But from init/Kconfig:

  page_cgroup_*_onwer also depend on CONFIG_SPARSEMEM, if !defined(CONFIG_SPARSEMEM), 
  they won't be built. So just move them out of CONFIG_SPARSEMEM block.

> 
>   config CGROUP_IO_THROTTLE
>   	bool "Enable cgroup I/O throttling"
>   	depends on CGROUPS && RESOURCE_COUNTERS && EXPERIMENTAL
>   	select MM_OWNER
>   	select PAGE_TRACKING
> 	       ^^^^^^^^^^^^^
> mmmh??? it should be correct.
> 
> And I don't understand how the following patch can fix this problem...
> 
> Could you post your .config?
> 
> Thanks,
> -Andrea
> 
>> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> ---
>>  mm/page_cgroup.c |   65 ++++++++++++++++++++++++++---------------------------
>>  1 files changed, 32 insertions(+), 33 deletions(-)
>>
>> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
>> index b3b394c..9c392f1 100644
>> --- a/mm/page_cgroup.c
>> +++ b/mm/page_cgroup.c
>> @@ -244,6 +244,38 @@ static int __meminit page_cgroup_callback(struct notifier_block *self,
>>  
>>  #endif
>>  
>> +void __init page_cgroup_init(void)
>> +{
>> +	unsigned long pfn;
>> +	int fail = 0;
>> +
>> +	if (mem_cgroup_disabled() && iothrottle_disabled())
>> +		return;
>> +
>> +	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
>> +		if (!pfn_present(pfn))
>> +			continue;
>> +		fail = init_section_page_cgroup(pfn);
>> +	}
>> +	if (fail) {
>> +		printk(KERN_CRIT
>> +			"try cgroup_disable=memory,blockio boot option\n");
>> +		panic("Out of memory");
>> +	} else {
>> +		hotplug_memory_notifier(page_cgroup_callback, 0);
>> +	}
>> +	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
>> +	printk(KERN_INFO
>> +		"try cgroup_disable=memory,blockio option if you don't want\n");
>> +}
>> +
>> +void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
>> +{
>> +	return;
>> +}
>> +
>> +#endif
>> +
>>  /**
>>   * page_cgroup_get_owner() - get the owner ID of a page
>>   * @page:	the page we want to find the owner
>> @@ -317,39 +349,6 @@ int page_cgroup_copy_owner(struct page *npage, struct page *opage)
>>  	return 0;
>>  }
>>  
>> -void __init page_cgroup_init(void)
>> -{
>> -	unsigned long pfn;
>> -	int fail = 0;
>> -
>> -	if (mem_cgroup_disabled() && iothrottle_disabled())
>> -		return;
>> -
>> -	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
>> -		if (!pfn_present(pfn))
>> -			continue;
>> -		fail = init_section_page_cgroup(pfn);
>> -	}
>> -	if (fail) {
>> -		printk(KERN_CRIT
>> -			"try cgroup_disable=memory,blockio boot option\n");
>> -		panic("Out of memory");
>> -	} else {
>> -		hotplug_memory_notifier(page_cgroup_callback, 0);
>> -	}
>> -	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
>> -	printk(KERN_INFO
>> -		"try cgroup_disable=memory,blockio option if you don't want\n");
>> -}
>> -
>> -void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
>> -{
>> -	return;
>> -}
>> -
>> -#endif
>> -
>> -
>>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>>  
>>  static DEFINE_MUTEX(swap_cgroup_mutex);
>> -- 
>> 1.5.4.rc3
> 
> 
> 

-- 
Regards
Gui Jianfeng
