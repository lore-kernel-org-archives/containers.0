From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: Re: [-mm PATCH 6/9] Memory controller add per container LRU and reclaim
 (v4)
Date: Tue, 31 Jul 2007 18:25:40 +0530
Message-ID: <46AF314C.7030404@linux.vnet.ibm.com>
References: <20070727201041.31565.14803.sendpatchset@balbir-laptop> <20070731051459.E827E1BF77B@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760753AbXGaM41@vger.kernel.org>
In-Reply-To: <20070731051459.E827E1BF77B@siro.lan>
Sender: linux-kernel-owner@vger.kernel.org
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org, menage@google.com, dhaval@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org



YAMAMOTO Takashi wrote:
>> +unsigned long mem_container_isolate_pages(unsigned long nr_to_scan,
>> +					struct list_head *dst,
>> +					unsigned long *scanned, int order,
>> +					int mode, struct zone *z,
>> +					struct mem_container *mem_cont,
>> +					int active)
>> +{
>> +	unsigned long nr_taken = 0;
>> +	struct page *page;
>> +	unsigned long scan;
>> +	LIST_HEAD(mp_list);
>> +	struct list_head *src;
>> +	struct meta_page *mp;
>> +
>> +	if (active)
>> +		src = &mem_cont->active_list;
>> +	else
>> +		src = &mem_cont->inactive_list;
>> +
>> +	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
>> +		mp = list_entry(src->prev, struct meta_page, lru);
> 
> what prevents another thread from freeing mp here?

mem_cont->lru_lock protects the list and validity of mp.  If we hold
mem_cont->lru_lock for this entire loop, then we preserve the validity
of mp.  However that will be holding up container charge and uncharge.

This entire routing is called with zone->lru_lock held by the caller.
 So within a zone, this routine is serialized.

However page uncharge may race with isolate page.  But will that lead
to any corruption of the list?  We may be holding the lock for too
much time just to be on the safe side.

Please allow us some time to verify whether this is indeed inadequate
locking that will lead to corruption of the list.

Thanks for pointing out this situation.
--Vaidy

>> +		spin_lock(&mem_cont->lru_lock);
>> +		if (mp)
>> +			page = mp->page;
>> +		spin_unlock(&mem_cont->lru_lock);
>> +		if (!mp)
>> +			continue;
> 
> YAMAMOTO Takashi
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
