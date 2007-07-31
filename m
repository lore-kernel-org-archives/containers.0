From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Subject: Re: [-mm PATCH 6/9] Memory controller add per container LRU and
 reclaim
	(v4)
Date: Tue, 31 Jul 2007 14:14:59 +0900 (JST)
Message-ID: <20070731051459.E827E1BF77B@siro.lan>
References: <20070727201041.31565.14803.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S940897AbXGaFPU@vger.kernel.org>
In-Reply-To: Your message of "Sat, 28 Jul 2007 01:40:41 +0530"
	<20070727201041.31565.14803.sendpatchset@balbir-laptop>
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com, xemul@openvz.org
List-Id: containers.vger.kernel.org

> +unsigned long mem_container_isolate_pages(unsigned long nr_to_scan,
> +					struct list_head *dst,
> +					unsigned long *scanned, int order,
> +					int mode, struct zone *z,
> +					struct mem_container *mem_cont,
> +					int active)
> +{
> +	unsigned long nr_taken = 0;
> +	struct page *page;
> +	unsigned long scan;
> +	LIST_HEAD(mp_list);
> +	struct list_head *src;
> +	struct meta_page *mp;
> +
> +	if (active)
> +		src = &mem_cont->active_list;
> +	else
> +		src = &mem_cont->inactive_list;
> +
> +	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
> +		mp = list_entry(src->prev, struct meta_page, lru);

what prevents another thread from freeing mp here?

> +		spin_lock(&mem_cont->lru_lock);
> +		if (mp)
> +			page = mp->page;
> +		spin_unlock(&mem_cont->lru_lock);
> +		if (!mp)
> +			continue;

YAMAMOTO Takashi
