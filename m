From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v2][PATCH 4/9] Memory management - dump state
Date: Fri, 22 Aug 2008 17:21:27 -0400
Message-ID: <48AF2DD7.9030902__13539.8508086384$1219440525$gmane$org@cs.columbia.edu>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0808202304490.17436@takamine.ncl.cs.columbia.edu>
	<20080821095316.GH581@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080821095316.GH581-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


Thanks Louis for all the comments. Will fix in v3.

Oren.

Louis Rilling wrote:
> On Wed, Aug 20, 2008 at 11:05:15PM -0400, Oren Laadan wrote:
>> For each VMA, there is a 'struct cr_vma'; if the VMA is file-mapped,
>> it will be followed by the file name.  The cr_vma->npages will tell
>> how many pages were dumped for this VMA.  Then it will be followed
>> by the actual data: first a dump of the addresses of all dumped
>> pages (npages entries) followed by a dump of the contents of all
>> dumped pages (npages pages). Then will come the next VMA and so on.
> 
> [...]
> 
>> diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
>> new file mode 100644
>> index 0000000..a23aa29
>> --- /dev/null
>> +++ b/checkpoint/ckpt_mem.c
> 
> [...]
> 
>> +/**
>> + * cr_vma_fill_pgarr - fill a page-array with addr/page tuples for a vma
>> + * @ctx - checkpoint context
>> + * @pgarr - page-array to fill
>> + * @vma - vma to scan
>> + * @start - start address (updated)
>> + */
>> +static int cr_vma_fill_pgarr(struct cr_ctx *ctx, struct cr_pgarr *pgarr,
>> +			     struct vm_area_struct *vma, unsigned long *start)
>> +{
>> +	unsigned long end = vma->vm_end;
>> +	unsigned long addr = *start;
>> +	struct page **pagep;
>> +	unsigned long *addrp;
>> +	int cow, nr, ret = 0;
>> +
>> +	nr = pgarr->nleft;
>> +	pagep = &pgarr->pages[pgarr->nused];
>> +	addrp = &pgarr->addrs[pgarr->nused];
>> +	cow = !!vma->vm_file;
>> +
>> +	while (addr < end) {
>> +		struct page *page;
>> +
>> +		/* simplified version of get_user_pages(): already have vma,
>> +		* only need FOLL_TOUCH, and (for now) ignore fault stats */
>> +
>> +		cond_resched();
>> +		while (!(page = follow_page(vma, addr, FOLL_TOUCH))) {
>> +			ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
>> +			if (ret & VM_FAULT_ERROR) {
>> +				if (ret & VM_FAULT_OOM)
>> +					ret = -ENOMEM;
>> +				else if (ret & VM_FAULT_SIGBUS)
>> +					ret = -EFAULT;
>> +				else
>> +					BUG();
>> +				break;
>> +			}
> 
> +			ret = 0;
> 
>> +			cond_resched();
>> +		}
>> +
>> +		if (IS_ERR(page)) {
>> +			ret = PTR_ERR(page);
>> +			break;
>> +		}
> 
> Need to check ret here:
> 
> + 		if (ret)
> 			break;
> 
>> +
>> +		if (page == ZERO_PAGE(0))
>> +			page = NULL;	/* zero page: ignore */
>> +		else if (cow && page_mapping(page) != NULL)
>> +			page = NULL;	/* clean cow: ignore */
>> +		else {
>> +			get_page(page);
>> +			*(addrp++) = addr;
>> +			*(pagep++) = page;
>> +			if (--nr == 0) {
>> +				addr += PAGE_SIZE;
>> +				break;
>> +			}
>> +		}
>> +
>> +		addr += PAGE_SIZE;
>> +	}
>> +
>> +	if (unlikely(ret < 0)) {
>> +		nr = pgarr->nleft - nr;
>> +		while (nr--)
>> +			page_cache_release(*(--pagep));
>> +		return ret;
>> +	}
>> +
>> +	*start = addr;
>> +	return (pgarr->nleft - nr);
>> +}
> 
> [...]
> 
> Thanks,
> 
> Louis
> 
