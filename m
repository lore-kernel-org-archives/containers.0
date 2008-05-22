From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [PATCH 4/4] swapcgroup: modify vm_swap_full for cgroup
Date: Thu, 22 May 2008 21:34:50 +0900
Message-ID: <4835686A.9000106@mxp.nes.nec.co.jp>
References: <48351120.6000800@mxp.nes.nec.co.jp>
	<20080522064507.AB6A35A0A@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080522064507.AB6A35A0A-Pcsii4f/SVk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: Lee.Schermerhorn-VXdhtT5mjnY@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

On 2008/05/22 15:45 +0900, YAMAMOTO Takashi wrote:
>> @@ -1892,3 +1892,36 @@ int valid_swaphandles(swp_entry_t entry, unsigned long *offset)
>>  	*offset = ++toff;
>>  	return nr_pages? ++nr_pages: 0;
>>  }
>> +
>> +#ifdef CONFIG_CGROUP_SWAP_RES_CTLR
>> +int swap_cgroup_vm_swap_full(struct page *page)
>> +{
>> +	int ret;
>> +	struct swap_info_struct *p;
>> +	struct mem_cgroup *mem;
>> +	u64 usage;
>> +	u64 limit;
>> +	swp_entry_t entry;
>> +
>> +	VM_BUG_ON(!PageLocked(page));
>> +	VM_BUG_ON(!PageSwapCache(page));
>> +
>> +	ret = 0;
>> +	entry.val = page_private(page);
>> +	p = swap_info_get(entry);
>> +	if (!p)
>> +		goto out;
>> +
>> +	mem = p->memcg[swp_offset(entry)];
>> +	usage = swap_cgroup_read_usage(mem) / PAGE_SIZE;
>> +	limit = swap_cgroup_read_limit(mem) / PAGE_SIZE;
>> +	limit = (limit < total_swap_pages) ? limit : total_swap_pages;
>> +
>> +	ret = usage * 2 > limit;
>> +
>> +	spin_unlock(&swap_lock);
>> +
>> +out:
>> +	return ret;
>> +}
>> +#endif
> 
> shouldn't it check the global usage (nr_swap_pages) as well?
> 
> YAMAMOTO Takashi
> 

I didn't check global usage because I didn't want 
some group to be influenced by other groups.

But in above code, there would be some cases that
vm_swap_full() returns false even when more than
half of swap is used in global.

Thanks you for pointing it out.

How about something like this?

  :
usage = swap_cgroup_read_usage(mem);	//no need to align to number of page
limit = swap_cgroup_read_limit(mem);	//no need to align to number of page
ret = (usage * 2 > limit) || (nr_swap_pages * 2 < total_swap_pages)
  :


Thanks,
Daisuke Nishimura.
