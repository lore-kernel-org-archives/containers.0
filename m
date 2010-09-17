From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 5/8] checkpoint/restart of anonymous hugetlb mappings
Date: Thu, 16 Sep 2010 20:44:56 -0400
Message-ID: <4C92BA08.70106@cs.columbia.edu>
References: <1284494530-25946-1-git-send-email-ntl@pobox.com>
	<1284494530-25946-6-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1284494530-25946-6-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



On 09/14/2010 04:02 PM, Nathan Lynch wrote:
> Support checkpoint and restore of both private and shared
> hugepage-backed mappings established via mmap(MAP_HUGETLB).  Introduce
> APIs for checkpoint and restart of individual huge pages which are to
> be used by the sysv SHM_HUGETLB c/r code.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

The code looks clean, but I need to learn more about HUGETLB
before I can say much...

Do you also have test-suite for this ?

[...]

> +static int hugetlb_dump_contents(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
> +{
> +	struct ckpt_hdr_hpage hdr;
> +	unsigned long pageshift;
> +	unsigned long pagesize;
> +	unsigned long addr;
> +	int ret;
> +
> +	pageshift = huge_page_shift(hstate_vma(vma));
> +	pagesize = vma_kernel_pagesize(vma);
> +
> +	ckpt_hdr_hpage_init(&hdr, pageshift);
> +
> +	for (addr = vma->vm_start; addr < vma->vm_end; addr += pagesize) {
> +		struct page *page = NULL;
> +
> +		down_read(&vma->vm_mm->mmap_sem);
> +		ret = __get_user_pages(ctx->tsk, vma->vm_mm,
> +				       addr, 1, FOLL_DUMP | FOLL_GET,
> +				       &page, NULL);
> +		/* FOLL_DUMP gives -EFAULT for holes */
> +		if (ret == -EFAULT)
> +			ret = 0;

With regular pages, this didn't always work, especially after they
slightly changed the semantics of FOLL_DUMP. So I introduced the
FOLL_DIRTY flag to detect dirty (non-zero) pages.  I wonder if
something like that may be needed here too ?

[...]

Oren.
