From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Thu, 31 Jul 2008 10:44:47 -0400
Message-ID: <4891CFDF.8060108@cs.columbia.edu>
References: <Pine.LNX.4.64.0807292325290.9868@takamine.ncl.cs.columbia.edu>
	<20080730161535.GB22403@hawkmoon.kerlabs.com>
	<4890B2A8.8010808@cs.columbia.edu>
	<20080731140844.GE22403@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080731140844.GE22403-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Louis Rilling wrote:
> On Wed, Jul 30, 2008 at 02:27:52PM -0400, Oren Laadan wrote:
>>
>> Louis Rilling wrote:
>>>> +/**
>>>> + * cr_vma_fill_pgarr - fill a page-array with addr/page tuples for a vma
>>>> + * @ctx - checkpoint context
>>>> + * @pgarr - page-array to fill
>>>> + * @vma - vma to scan
>>>> + * @start - start address (updated)
>>>> + */
>>>> +static int cr_vma_fill_pgarr(struct cr_ctx *ctx, struct cr_pgarr *pgarr,
>>>> +			     struct vm_area_struct *vma, unsigned long *start)
>>>> +{
>>>> +	unsigned long end = vma->vm_end;
>>>> +	unsigned long addr = *start;
>>>> +	struct page **pagep;
>>>> +	unsigned long *addrp;
>>>> +	int cow, nr, ret = 0;
>>>> +
>>>> +	nr = pgarr->nleft;
>>>> +	pagep = &pgarr->pages[pgarr->nused];
>>>> +	addrp = &pgarr->addrs[pgarr->nused];
>>>> +	cow = !!vma->vm_file;
>>>> +
>>>> +	while (addr < end) {
>>>> +		struct page *page;
>>>> +
>>>> +		/* simplified version of get_user_pages(): already have vma,
>>>> +		* only need FOLL_TOUCH, and (for now) ignore fault stats */
>>>> +
>>>> +		cond_resched();
>>>> +		while (!(page = follow_page(vma, addr, FOLL_TOUCH))) {
>>>> +			ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
>>>> +			if (ret & VM_FAULT_ERROR) {
>>>> +				if (ret & VM_FAULT_OOM)
>>>> +					ret = -ENOMEM;
>>>> +				else if (ret & VM_FAULT_SIGBUS)
>>>> +					ret = -EFAULT;
>>>> +				else
>>>> +					BUG();
>>>> +				break;
>>>> +			}
>>>> +			cond_resched();
>>>> +		}
>>> I guess that 'ret' should be checked somewhere after this loop.
>> yes; this is where a "break(2)" construct in C would come handy :)
> 
> Alternatively, putting the inner loop in a separate function often helps to
> handle errors in a cleaner way.

Also true. I opted to keep it that way to keep the code as similar as
possible to get_user_pages().

Note that the logic can be optimized by, instead of traversing the page
table once for each page, we could aggregate a few pages in each round.
I wanted to keep the code simple.

> 
>>>> +
>>>> +		if (IS_ERR(page)) {
>>>> +			ret = PTR_ERR(page);
>>>> +			break;
>>>> +		}
>>>> +
>>>> +		if (page == ZERO_PAGE(0))
>>>> +			page = NULL;	/* zero page: ignore */
>>>> +		else if (cow && page_mapping(page) != NULL)
>>>> +			page = NULL;	/* clean cow: ignore */
>>>> +		else {
>>>> +			get_page(page);
>>>> +			*(addrp++) = addr;
>>>> +			*(pagep++) = page;
>>>> +			if (--nr == 0) {
>>>> +				addr += PAGE_SIZE;
>>>> +				break;
>>>> +			}
>>>> +		}
>>>> +
>>>> +		addr += PAGE_SIZE;
>>>> +	}
>>>> +
>>>> +	if (unlikely(ret < 0)) {
>>>> +		nr = pgarr->nleft - nr;
>>>> +		while (nr--)
>>>> +			page_cache_release(*(--pagep));
>>>> +		return ret;
>>>> +	}
>>>> +
>>>> +	*start = addr;
>>>> +	return (pgarr->nleft - nr);
>>>> +}
>>>> +
> 
> 
>>>> +int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
>>>> +{
>>>> +	struct cr_hdr h;
>>>> +	struct cr_hdr_mm *hh = ctx->tbuf;
>>>> +	struct mm_struct *mm;
>>>> +	struct vm_area_struct *vma;
>>>> +	int ret;
>>>> +
>>>> +	h.type = CR_HDR_MM;
>>>> +	h.len = sizeof(*hh);
>>>> +	h.id = ctx->pid;
>>>> +
>>>> +	mm = get_task_mm(t);
>>>> +
>>>> +	hh->tag = 1;	/* non-zero will mean first time encounter */
>>>> +
>>>> +	hh->start_code = mm->start_code;
>>>> +	hh->end_code = mm->end_code;
>>>> +	hh->start_data = mm->start_data;
>>>> +	hh->end_data = mm->end_data;
>>>> +	hh->start_brk = mm->start_brk;
>>>> +	hh->brk = mm->brk;
>>>> +	hh->start_stack = mm->start_stack;
>>>> +	hh->arg_start = mm->arg_start;
>>>> +	hh->arg_end = mm->arg_end;
>>>> +	hh->env_start = mm->env_start;
>>>> +	hh->env_end = mm->env_end;
>>>> +
>>>> +	hh->map_count = mm->map_count;
>>> Some fields above should also be protected with mmap_sem, like ->brk,
>>> ->map_count, and possibly others (I'm not a memory expert though).
>> true; keep in mind, though, that the container will be frozen during
>> this time, so nothing should change at all. The only exception would
>> be if, for instance, someone is killing the container while we save
>> its state.
> 
> Sure. So you think that taking mm->mmap_sem below is useless? I tend to believe
> so, since no other task should share this mm_struct at this time, and we could
> state that ptrace should not interfere during restart. However, I'm never
> confident when ptrace considerations come in...

Not quite.

Probing the value of mm->brk is always safe, although it may turn out to
yield incorrect value. Traversing the vma's isn't safe, because - if for
instance the target task dies in the middle, it may alter the vma list.
So the mmap_sem protects against the latter.

Anyway, it won't hurt to be extra safe and take the semaphore earlier.

Ptrace, btw, cannot come in because the container is (supposedly) frozen.

Oren.

>>>> +
>>>> +	/* FIX: need also mm->flags */
>>>> +
>>>> +	ret = cr_write_obj(ctx, &h, hh);
>>>> +	if (ret < 0)
>>>> +		goto out;
>>>> +
>>>> +	/* write the vma's */
>>>> +	down_read(&mm->mmap_sem);
>>>> +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
>>>> +		if ((ret = cr_write_vma(ctx, vma)) < 0)
>>>> +			break;
>>>> +	}
>>>> +	up_read(&mm->mmap_sem);
>>>> +
>>>> +	if (ret < 0)
>>>> +		goto out;
>>>> +
>>>> +	ret = cr_write_mm_context(ctx, mm);
>>>> +
>>>> + out:
>>>> +	mmput(mm);
>>>> +	return ret;
>>>> +}
> 
> Thanks,
> 
> Louis
> 
