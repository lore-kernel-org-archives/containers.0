From: "MinChan Kim" <minchan.kim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v4][PATCH 4/9] Memory management (dump)
Date: Thu, 11 Sep 2008 08:49:54 +0900
Message-ID: <28c262360809101649k13080508md990d1ee98684d11__27926.9876111814$1221090735$gmane$org@mail.gmail.com>
References: <1220946154-15174-1-git-send-email-orenl@cs.columbia.edu>
	<1220946154-15174-5-git-send-email-orenl@cs.columbia.edu>
	<28c262360809100051o24e69f1cp45b73201d9c748e9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <28c262360809100051o24e69f1cp45b73201d9c748e9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

one more thing.

On Wed, Sep 10, 2008 at 4:51 PM, MinChan Kim <minchan.kim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, Sep 9, 2008 at 4:42 PM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:
>> For each VMA, there is a 'struct cr_vma'; if the VMA is file-mapped,
>> it will be followed by the file name.  The cr_vma->npages will tell
>> how many pages were dumped for this VMA.  Then it will be followed
>> by the actual data: first a dump of the addresses of all dumped
>> pages (npages entries) followed by a dump of the contents of all
>> dumped pages (npages pages). Then will come the next VMA and so on.
>>
>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
>> ---
>>  arch/x86/mm/checkpoint.c   |   30 +++
>>  arch/x86/mm/restart.c      |    1 +
>>  checkpoint/Makefile        |    3 +-
>>  checkpoint/checkpoint.c    |   53 ++++++
>>  checkpoint/ckpt_arch.h     |    1 +
>>  checkpoint/ckpt_mem.c      |  448 ++++++++++++++++++++++++++++++++++++++++++++
>>  checkpoint/ckpt_mem.h      |   35 ++++
>>  checkpoint/sys.c           |   23 ++-
>>  include/asm-x86/ckpt_hdr.h |    5 +
>>  include/linux/ckpt.h       |   12 ++
>>  include/linux/ckpt_hdr.h   |   30 +++
>>  11 files changed, 635 insertions(+), 6 deletions(-)
>>  create mode 100644 checkpoint/ckpt_mem.c
>>  create mode 100644 checkpoint/ckpt_mem.h
>>
>> diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
>> index 71d21e6..50cfd29 100644
>> --- a/arch/x86/mm/checkpoint.c
>> +++ b/arch/x86/mm/checkpoint.c
>> @@ -192,3 +192,33 @@ int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
>>        cr_hbuf_put(ctx, sizeof(*hh));
>>        return ret;
>>  }
>> +
>> +/* dump the mm->context state */
>> +int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
>> +{
>> +       struct cr_hdr h;
>> +       struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
>> +       int ret;
>> +
>> +       h.type = CR_HDR_MM_CONTEXT;
>> +       h.len = sizeof(*hh);
>> +       h.parent = parent;
>> +
>> +       mutex_lock(&mm->context.lock);
>> +
>> +       hh->ldt_entry_size = LDT_ENTRY_SIZE;
>> +       hh->nldt = mm->context.size;
>> +
>> +       cr_debug("nldt %d\n", hh->nldt);
>> +
>> +       ret = cr_write_obj(ctx, &h, hh);
>> +       cr_hbuf_put(ctx, sizeof(*hh));
>> +       if (ret < 0)
>> +               return ret;
>> +
>> +       ret = cr_kwrite(ctx, mm->context.ldt, hh->nldt * LDT_ENTRY_SIZE);
>> +
>> +       mutex_unlock(&mm->context.lock);
>> +
>> +       return ret;
>> +}
>> diff --git a/arch/x86/mm/restart.c b/arch/x86/mm/restart.c
>> index 883a163..d7fb89a 100644
>> --- a/arch/x86/mm/restart.c
>> +++ b/arch/x86/mm/restart.c
>> @@ -8,6 +8,7 @@
>>  *  distribution for more details.
>>  */
>>
>> +#include <linux/unistd.h>
>>  #include <asm/desc.h>
>>  #include <asm/i387.h>
>>
>> diff --git a/checkpoint/Makefile b/checkpoint/Makefile
>> index d2df68c..3a0df6d 100644
>> --- a/checkpoint/Makefile
>> +++ b/checkpoint/Makefile
>> @@ -2,4 +2,5 @@
>>  # Makefile for linux checkpoint/restart.
>>  #
>>
>> -obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o
>> +obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o \
>> +               ckpt_mem.o
>> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
>> index d34a691..4dae775 100644
>> --- a/checkpoint/checkpoint.c
>> +++ b/checkpoint/checkpoint.c
>> @@ -55,6 +55,55 @@ int cr_write_string(struct cr_ctx *ctx, char *str, int len)
>>        return cr_write_obj(ctx, &h, str);
>>  }
>>
>> +/**
>> + * cr_fill_fname - return pathname of a given file
>> + * @path: path name
>> + * @root: relative root
>> + * @buf: buffer for pathname
>> + * @n: buffer length (in) and pathname length (out)
>> + */
>> +static char *
>> +cr_fill_fname(struct path *path, struct path *root, char *buf, int *n)
>> +{
>> +       char *fname;
>> +
>> +       BUG_ON(!buf);
>> +       fname = __d_path(path, root, buf, *n);
>> +       if (!IS_ERR(fname))
>> +               *n = (buf + (*n) - fname);
>> +       return fname;
>> +}
>> +
>> +/**
>> + * cr_write_fname - write a file name
>> + * @ctx: checkpoint context
>> + * @path: path name
>> + * @root: relative root
>> + */
>> +int cr_write_fname(struct cr_ctx *ctx, struct path *path, struct path *root)
>> +{
>> +       struct cr_hdr h;
>> +       char *buf, *fname;
>> +       int ret, flen;
>> +
>> +       flen = PATH_MAX;
>> +       buf = kmalloc(flen, GFP_KERNEL);
>> +       if (!buf)
>> +               return -ENOMEM;
>> +
>> +       fname = cr_fill_fname(path, root, buf, &flen);
>> +       if (!IS_ERR(fname)) {
>> +               h.type = CR_HDR_FNAME;
>> +               h.len = flen;
>> +               h.parent = 0;
>> +               ret = cr_write_obj(ctx, &h, fname);
>> +       } else
>> +               ret = PTR_ERR(fname);
>> +
>> +       kfree(buf);
>> +       return ret;
>> +}
>> +
>>  /* write the checkpoint header */
>>  static int cr_write_head(struct cr_ctx *ctx)
>>  {
>> @@ -164,6 +213,10 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
>>        cr_debug("task_struct: ret %d\n", ret);
>>        if (ret < 0)
>>                goto out;
>> +       ret = cr_write_mm(ctx, t);
>> +       cr_debug("memory: ret %d\n", ret);
>> +       if (ret < 0)
>> +               goto out;
>>        ret = cr_write_thread(ctx, t);
>>        cr_debug("thread: ret %d\n", ret);
>>        if (ret < 0)
>> diff --git a/checkpoint/ckpt_arch.h b/checkpoint/ckpt_arch.h
>> index 5bd4703..9bd0ba4 100644
>> --- a/checkpoint/ckpt_arch.h
>> +++ b/checkpoint/ckpt_arch.h
>> @@ -2,6 +2,7 @@
>>
>>  int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t);
>>  int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t);
>> +int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent);
>>
>>  int cr_read_thread(struct cr_ctx *ctx);
>>  int cr_read_cpu(struct cr_ctx *ctx);
>> diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
>> new file mode 100644
>> index 0000000..2c93447
>> --- /dev/null
>> +++ b/checkpoint/ckpt_mem.c
>> @@ -0,0 +1,448 @@
>> +/*
>> + *  Checkpoint memory contents
>> + *
>> + *  Copyright (C) 2008 Oren Laadan
>> + *
>> + *  This file is subject to the terms and conditions of the GNU General Public
>> + *  License.  See the file COPYING in the main directory of the Linux
>> + *  distribution for more details.
>> + */
>> +
>> +#include <linux/kernel.h>
>> +#include <linux/sched.h>
>> +#include <linux/slab.h>
>> +#include <linux/file.h>
>> +#include <linux/pagemap.h>
>> +#include <linux/mm_types.h>
>> +#include <linux/ckpt.h>
>> +#include <linux/ckpt_hdr.h>
>> +
>> +#include "ckpt_arch.h"
>> +#include "ckpt_mem.h"
>> +
>> +/*
>> + * utilities to alloc, free, and handle 'struct cr_pgarr' (page-arrays)
>> + * (common to ckpt_mem.c and rstr_mem.c).
>> + *
>> + * The checkpoint context structure has two members for page-arrays:
>> + *   ctx->pgarr: list head of the page-array chain
>> + *   ctx->pgcur: tracks the "current" position in the chain
>> + *
>> + * During checkpoint (and restart) the chain tracks the dirty pages (page
>> + * pointer and virtual address) of each MM. For a particular MM, these are
>> + * always added to the "current" page-array (ctx->pgcur). The "current"
>> + * page-array advances as necessary, and new page-array descriptors are
>> + * allocated on-demand. Before the next MM, the chain is reset but not
>> + * freed (that is, dereference page pointers and reset ctx->pgcur).
>> + */
>> +
>> +#define CR_PGARR_ORDER  0
>> +#define CR_PGARR_TOTAL  ((PAGE_SIZE << CR_PGARR_ORDER) / sizeof(void *))
>> +
>> +/* release pages referenced by a page-array */
>> +void cr_pgarr_unref_pages(struct cr_pgarr *pgarr)
>> +{
>> +       int n;
>> +
>> +       /* only checkpoint keeps references to pages */
>> +       if (pgarr->pages) {
>> +               cr_debug("nr_used %d\n", pgarr->nr_used);
>> +               for (n = pgarr->nr_used; n--; )
>> +                       page_cache_release(pgarr->pages[n]);
>> +       }
>> +}
>> +
>> +/* free a single page-array object */
>> +static void cr_pgarr_free_one(struct cr_pgarr *pgarr)
>> +{
>> +       cr_pgarr_unref_pages(pgarr);
>> +       if (pgarr->pages)
>> +               free_pages((unsigned long) pgarr->pages, CR_PGARR_ORDER);
>> +       if (pgarr->vaddrs)
>> +               free_pages((unsigned long) pgarr->vaddrs, CR_PGARR_ORDER);
>> +       kfree(pgarr);
>> +}
>> +
>> +/* free a chain of page-arrays */
>> +void cr_pgarr_free(struct cr_ctx *ctx)
>> +{
>> +       struct cr_pgarr *pgarr, *tmp;
>> +
>> +       list_for_each_entry_safe(pgarr, tmp, &ctx->pgarr, list) {
>> +               list_del(&pgarr->list);
>> +               cr_pgarr_free_one(pgarr);
>> +       }
>> +       ctx->pgcur = NULL;
>> +}
>> +
>> +/* allocate a single page-array object */
>> +static struct cr_pgarr *cr_pgarr_alloc_one(void)
>> +{
>> +       struct cr_pgarr *pgarr;
>> +
>> +       pgarr = kzalloc(sizeof(*pgarr), GFP_KERNEL);
>> +       if (!pgarr)
>> +               return NULL;
>> +
>> +       pgarr->nr_free = CR_PGARR_TOTAL;
>> +       pgarr->nr_used = 0;
>> +
>> +       pgarr->pages = (struct page **)
>> +               __get_free_pages(GFP_KERNEL, CR_PGARR_ORDER);
>> +       pgarr->vaddrs = (unsigned long *)
>> +               __get_free_pages(GFP_KERNEL, CR_PGARR_ORDER);
>> +       if (!pgarr->pages || !pgarr->vaddrs) {
>> +               cr_pgarr_free_one(pgarr);
>> +               return NULL;
>> +       }
>> +
>> +       return pgarr;
>> +}
>> +
>> +/* cr_pgarr_alloc - return the next available pgarr in the page-array chain
>> + * @ctx: checkpoint context
>> + *
>> + * Return the page-array following ctx->pgcur, extending the chain if needed
>> + */
>> +struct cr_pgarr *cr_pgarr_alloc(struct cr_ctx *ctx)
>> +{
>> +       struct cr_pgarr *pgarr;
>> +
>> +       /* can reuse next element after ctx->pgcur ? */
>> +       pgarr = ctx->pgcur;
>> +       if (pgarr && !list_is_last(&pgarr->list, &ctx->pgarr)) {
>> +               pgarr = list_entry(pgarr->list.next, struct cr_pgarr, list);
>> +               goto out;
>> +       }
>> +
>> +       /* nope, need to extend the page-array chain */
>> +       pgarr = cr_pgarr_alloc_one();
>> +       if (!pgarr)
>> +               return NULL;
>> +
>> +       list_add_tail(&pgarr->list, &ctx->pgarr);
>> + out:
>> +       ctx->pgcur = pgarr;
>> +       return pgarr;
>> +
>> +}
>> +
>> +/* reset the page-array chain (dropping page references if necessary) */
>> +void cr_pgarr_reset(struct cr_ctx *ctx)
>> +{
>> +       struct cr_pgarr *pgarr;
>> +
>> +       list_for_each_entry(pgarr, &ctx->pgarr, list) {
>> +               cr_pgarr_unref_pages(pgarr);
>> +               pgarr->nr_free = CR_PGARR_TOTAL;
>> +               pgarr->nr_used = 0;
>> +       }
>> +       ctx->pgcur = NULL;
>> +}
>> +
>> +
>> +/* return current page-array (and allocate if needed) */
>> +struct cr_pgarr *cr_pgarr_prep(struct cr_ctx *ctx
>> +)
>
> Brace shoudl be located in above line. :)
>> +{
>> +       struct cr_pgarr *pgarr = ctx->pgcur;
>> +
>> +       if (!pgarr->nr_free)

At first trial, ctx->pgcur is null.
so, It may happen oops.

>> +               pgarr = cr_pgarr_alloc(ctx);
>> +       return pgarr;
>> +}
>> +
>> +/*
>> + * Checkpoint is outside the context of the checkpointee, so one cannot
>> + * simply read pages from user-space. Instead, we scan the address space
>> + * of the target to cherry-pick pages of interest. Selected pages are
>> + * enlisted in a page-array chain (attached to the checkpoint context).
>> + * To save their contents, each page is mapped to kernel memory and then
>> + * dumped to the file descriptor.
>> + */
>> +
>> +/**
>> + * cr_vma_fill_pgarr - fill a page-array with addr/page tuples for a vma
>> + * @ctx - checkpoint context
>> + * @pgarr - page-array to fill
>> + * @vma - vma to scan
>> + * @start - start address (updated)
>> + */
>> +static int cr_vma_fill_pgarr(struct cr_ctx *ctx, struct cr_pgarr *pgarr,
>> +                            struct vm_area_struct *vma, unsigned long *start)
>> +{
>> +       unsigned long end = vma->vm_end;
>> +       unsigned long addr = *start;
>> +       struct page **pagep;
>> +       unsigned long *addrp;
>> +       int cow, nr, ret = 0;
>> +
>> +       nr = pgarr->nr_free;
>> +       pagep = &pgarr->pages[pgarr->nr_used];
>> +       addrp = &pgarr->vaddrs[pgarr->nr_used];
>> +       cow = !!vma->vm_file;
>> +
>> +       while (addr < end) {
>> +               struct page *page;
>> +
>> +               /*
>> +                * simplified version of get_user_pages(): already have vma,
>> +                * only need FOLL_TOUCH, and (for now) ignore fault stats.
>> +                *
>> +                * FIXME: consolidate with get_user_pages()
>> +                */
>> +
>> +               cond_resched();
>> +               while (!(page = follow_page(vma, addr, FOLL_TOUCH))) {
>> +                       ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
>> +                       if (ret & VM_FAULT_ERROR) {
>> +                               if (ret & VM_FAULT_OOM)
>> +                                       ret = -ENOMEM;
>> +                               else if (ret & VM_FAULT_SIGBUS)
>> +                                       ret = -EFAULT;
>> +                               else
>> +                                       BUG();
>> +                               break;
>> +                       }
>> +                       cond_resched();
>> +                       ret = 0;
>> +               }
>> +
>> +               if (IS_ERR(page))
>> +                       ret = PTR_ERR(page);
>> +
>> +               if (ret < 0)
>> +                       break;
>> +
>> +               if (page == ZERO_PAGE(0)) {
>> +                       page = NULL;    /* zero page: ignore */
>> +               } else if (cow && page_mapping(page) != NULL) {
>> +                       page = NULL;    /* clean cow: ignore */
>> +               } else {
>> +                       get_page(page);
>> +                       *(addrp++) = addr;
>> +                       *(pagep++) = page;
>> +                       if (--nr == 0) {
>> +                               addr += PAGE_SIZE;
>> +                               break;
>> +                       }
>> +               }
>> +
>> +               addr += PAGE_SIZE;
>> +       }
>> +
>> +       if (unlikely(ret < 0)) {
>> +               nr = pgarr->nr_free - nr;
>> +               while (nr--)
>> +                       page_cache_release(*(--pagep));
>> +               return ret;
>> +       }
>> +
>> +       *start = addr;
>> +       return pgarr->nr_free - nr;
>> +}
>> +
>> +/**
>> + * cr_vma_scan_pages - scan vma for pages that will need to be dumped
>> + * @ctx - checkpoint context
>> + * @vma - vma to scan
>> + *
>> + * lists of page pointes and corresponding virtual addresses are tracked
>> + * inside ctx->pgarr page-array chain
>> + */
>> +static int cr_vma_scan_pages(struct cr_ctx *ctx, struct vm_area_struct *vma)
>> +{
>> +       unsigned long addr = vma->vm_start;
>> +       unsigned long end = vma->vm_end;
>> +       struct cr_pgarr *pgarr;
>> +       int nr, total = 0;
>> +
>> +       while (addr < end) {
>> +               pgarr = cr_pgarr_prep(ctx);
>> +               if (!pgarr)
>> +                       return -ENOMEM;
>> +               nr = cr_vma_fill_pgarr(ctx, pgarr, vma, &addr);
>> +               if (nr < 0)
>> +                       return nr;
>> +               pgarr->nr_free -= nr;
>> +               pgarr->nr_used += nr;
>> +               total += nr;
>> +       }
>> +
>> +       cr_debug("total %d\n", total);
>> +       return total;
>> +}
>> +
>> +static int cr_page_write(struct cr_ctx *ctx, struct page *page, char *buf)
>> +{
>> +       void *ptr;
>> +
>> +       ptr = kmap_atomic(page, KM_USER1);
>> +       memcpy(buf, ptr, PAGE_SIZE);
>> +       kunmap_atomic(page, KM_USER1);
>> +
>> +       return cr_kwrite(ctx, buf, PAGE_SIZE);
>> +}
>> +
>> +/**
>> + * cr_vma_dump_pages - dump pages listed in the ctx page-array chain
>> + * @ctx - checkpoint context
>> + * @total - total number of pages
>> + *
>> + * First dump all virtual addresses, followed by the contents of all pages
>> + */
>> +static int cr_vma_dump_pages(struct cr_ctx *ctx, int total)
>> +{
>> +       struct cr_pgarr *pgarr;
>> +       char *buf;
>> +       int i, ret = 0;
>> +
>> +       if (!total)
>> +               return 0;
>> +
>> +       list_for_each_entry(pgarr, &ctx->pgarr, list) {
>> +               ret = cr_kwrite(ctx, pgarr->vaddrs,
>> +                               pgarr->nr_used * sizeof(*pgarr->vaddrs));
>> +               if (ret < 0)
>> +                       return ret;
>> +       }
>> +
>> +       buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
>> +       if (!buf)
>> +               return -ENOMEM;
>> +
>> +       list_for_each_entry(pgarr, &ctx->pgarr, list) {
>> +               for (i = 0; i < pgarr->nr_used; i++) {
>> +                       ret = cr_page_write(ctx, pgarr->pages[i], buf);
>> +                       if (ret < 0)
>> +                               goto out;
>> +               }
>> +       }
>> +
>> + out:
>> +       kfree(buf);
>> +       return ret;
>> +}
>> +
>> +static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
>> +{
>> +       struct cr_hdr h;
>> +       struct cr_hdr_vma *hh = cr_hbuf_get(ctx, sizeof(*hh));
>> +       int vma_type, nr, ret;
>> +
>> +       h.type = CR_HDR_VMA;
>> +       h.len = sizeof(*hh);
>> +       h.parent = 0;
>> +
>> +       hh->vm_start = vma->vm_start;
>> +       hh->vm_end = vma->vm_end;
>> +       hh->vm_page_prot = vma->vm_page_prot.pgprot;
>> +       hh->vm_flags = vma->vm_flags;
>> +       hh->vm_pgoff = vma->vm_pgoff;
>> +
>> +       if (vma->vm_flags & (VM_SHARED | VM_IO | VM_HUGETLB | VM_NONLINEAR)) {
>> +               pr_warning("CR: unsupported VMA %#lx\n", vma->vm_flags);
>> +               return -ETXTBSY;
>> +       }
>> +
>> +       /* by default assume anon memory */
>> +       vma_type = CR_VMA_ANON;
>> +
>> +       /* if there is a backing file, assume private-mapped */
>> +       /* (FIX: check if the file is unlinked) */
>> +       if (vma->vm_file)
>> +               vma_type = CR_VMA_FILE;
>> +
>> +       hh->vma_type = vma_type;
>> +
>> +       /*
>> +        * it seems redundant now, but we do it in 3 steps for because:
>> +        * first, the logic is simpler when we how many pages before
>> +        * dumping them; second, a future optimization will defer the
>> +        * writeout (dump, and free) to a later step; in which case all
>> +        * the pages to be dumped will be aggregated on the checkpoint ctx
>> +        */
>> +
>> +       /* (1) scan: scan through the PTEs of the vma to count the pages
>> +        * to dump (and later make those pages COW), and keep the list of
>> +        * pages (and a reference to each page) on the checkpoint ctx */
>> +       nr = cr_vma_scan_pages(ctx, vma);
>> +       if (nr < 0)
>> +               return nr;
>> +
>> +       hh->nr_pages = nr;
>> +       ret = cr_write_obj(ctx, &h, hh);
>> +       cr_hbuf_put(ctx, sizeof(*hh));
>> +       if (ret < 0)
>> +               return ret;
>> +       /* save the file name, if relevant */
>> +       if (vma->vm_file)
>> +               ret = cr_write_fname(ctx, &vma->vm_file->f_path, ctx->vfsroot);
>> +
>> +       if (ret < 0)
>> +               return ret;
>> +
>> +       /* (2) dump: write out the addresses of all pages in the list (on
>> +        * the checkpoint ctx) followed by the contents of all pages */
>> +       ret = cr_vma_dump_pages(ctx, nr);
>> +
>> +       /* (3) free: release the extra references to the pages in the list */
>> +       cr_pgarr_reset(ctx);
>> +
>> +       return ret;
>> +}
>> +
>> +int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
>> +{
>> +       struct cr_hdr h;
>> +       struct cr_hdr_mm *hh = cr_hbuf_get(ctx, sizeof(*hh));
>> +       struct mm_struct *mm;
>> +       struct vm_area_struct *vma;
>> +       int objref, ret;
>> +
>> +       h.type = CR_HDR_MM;
>> +       h.len = sizeof(*hh);
>> +       h.parent = task_pid_vnr(t);
>> +
>> +       mm = get_task_mm(t);
>> +
>> +       objref = 0;     /* will be meaningful with multiple processes */
>> +       hh->objref = objref;
>> +
>> +       down_read(&mm->mmap_sem);
>> +
>> +       hh->start_code = mm->start_code;
>> +       hh->end_code = mm->end_code;
>> +       hh->start_data = mm->start_data;
>> +       hh->end_data = mm->end_data;
>> +       hh->start_brk = mm->start_brk;
>> +       hh->brk = mm->brk;
>> +       hh->start_stack = mm->start_stack;
>> +       hh->arg_start = mm->arg_start;
>> +       hh->arg_end = mm->arg_end;
>> +       hh->env_start = mm->env_start;
>> +       hh->env_end = mm->env_end;
>> +
>> +       hh->map_count = mm->map_count;
>> +
>> +       /* FIX: need also mm->flags */
>> +
>> +       ret = cr_write_obj(ctx, &h, hh);
>> +       cr_hbuf_put(ctx, sizeof(*hh));
>> +       if (ret < 0)
>> +               goto out;
>> +
>> +       /* write the vma's */
>> +       for (vma = mm->mmap; vma; vma = vma->vm_next) {
>> +               ret = cr_write_vma(ctx, vma);
>> +               if (ret < 0)
>> +                       goto out;
>> +       }
>> +
>> +       ret = cr_write_mm_context(ctx, mm, objref);
>> +
>> + out:
>> +       up_read(&mm->mmap_sem);
>> +       mmput(mm);
>> +       return ret;
>> +}
>> diff --git a/checkpoint/ckpt_mem.h b/checkpoint/ckpt_mem.h
>> new file mode 100644
>> index 0000000..8ee211d
>> --- /dev/null
>> +++ b/checkpoint/ckpt_mem.h
>> @@ -0,0 +1,35 @@
>> +#ifndef _CHECKPOINT_CKPT_MEM_H_
>> +#define _CHECKPOINT_CKPT_MEM_H_
>> +/*
>> + *  Generic container checkpoint-restart
>> + *
>> + *  Copyright (C) 2008 Oren Laadan
>> + *
>> + *  This file is subject to the terms and conditions of the GNU General Public
>> + *  License.  See the file COPYING in the main directory of the Linux
>> + *  distribution for more details.
>> + */
>> +
>> +#include <linux/mm_types.h>
>> +
>> +/*
>> + * page-array chains: each cr_pgarr describes a set of <strcut page *,vaddr>
>> + * tuples (where vaddr is the virtual address of a page in a particular mm).
>> + * Specifically, we use separate arrays so that all vaddrs can be written
>> + * and read at once.
>> + */
>> +
>> +struct cr_pgarr {
>> +       unsigned long *vaddrs;
>> +       struct page **pages;
>> +       unsigned int nr_used;   /* how many entries already used */
>> +       unsigned int nr_free;   /* how many entries still free */
>> +       struct list_head list;
>> +};
>> +
>> +void cr_pgarr_reset(struct cr_ctx *ctx);
>> +void cr_pgarr_free(struct cr_ctx *ctx);
>> +struct cr_pgarr *cr_pgarr_alloc(struct cr_ctx *ctx);
>> +struct cr_pgarr *cr_pgarr_prep(struct cr_ctx *ctx);
>> +
>> +#endif /* _CHECKPOINT_CKPT_MEM_H_ */
>> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
>> index 113e0df..8141161 100644
>> --- a/checkpoint/sys.c
>> +++ b/checkpoint/sys.c
>> @@ -16,6 +16,8 @@
>>  #include <linux/capability.h>
>>  #include <linux/ckpt.h>
>>
>> +#include "ckpt_mem.h"
>> +
>>  /*
>>  * helpers to write/read to/from the image file descriptor
>>  *
>> @@ -110,7 +112,6 @@ int cr_kread(struct cr_ctx *ctx, void *buf, int count)
>>        return ret;
>>  }
>>
>> -
>>  /*
>>  * helpers to manage CR contexts: allocated for each checkpoint and/or
>>  * restart operation, and persists until the operation is completed.
>> @@ -126,6 +127,11 @@ void cr_ctx_free(struct cr_ctx *ctx)
>>
>>        free_pages((unsigned long) ctx->hbuf, CR_HBUF_ORDER);
>>
>> +       if (ctx->vfsroot)
>> +               path_put(ctx->vfsroot);
>> +
>> +       cr_pgarr_free(ctx);
>> +
>>        kfree(ctx);
>>  }
>>
>> @@ -145,10 +151,13 @@ struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
>>        get_file(ctx->file);
>>
>>        ctx->hbuf = (void *) __get_free_pages(GFP_KERNEL, CR_HBUF_ORDER);
>> -       if (!ctx->hbuf) {
>> -               cr_ctx_free(ctx);
>> -               return ERR_PTR(-ENOMEM);
>> -       }
>> +       if (!ctx->hbuf)
>> +               goto nomem;
>> +
>> +       /* assume checkpointer is in container's root vfs */
>> +       /* FIXME: this works for now, but will change with real containers */
>> +       ctx->vfsroot = &current->fs->root;
>> +       path_get(ctx->vfsroot);
>>
>>        ctx->pid = pid;
>>        ctx->flags = flags;
>> @@ -156,6 +165,10 @@ struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
>>        ctx->crid = atomic_inc_return(&cr_ctx_count);
>>
>>        return ctx;
>> +
>> + nomem:
>> +       cr_ctx_free(ctx);
>> +       return ERR_PTR(-ENOMEM);
>>  }
>>
>>  /*
>> diff --git a/include/asm-x86/ckpt_hdr.h b/include/asm-x86/ckpt_hdr.h
>> index 44a903c..6bc61ac 100644
>> --- a/include/asm-x86/ckpt_hdr.h
>> +++ b/include/asm-x86/ckpt_hdr.h
>> @@ -69,4 +69,9 @@ struct cr_hdr_cpu {
>>
>>  } __attribute__((aligned(8)));
>>
>> +struct cr_hdr_mm_context {
>> +       __s16 ldt_entry_size;
>> +       __s16 nldt;
>> +} __attribute__((aligned(8)));
>> +
>>  #endif /* __ASM_X86_CKPT_HDR__H */
>> diff --git a/include/linux/ckpt.h b/include/linux/ckpt.h
>> index 91f4998..5c62a90 100644
>> --- a/include/linux/ckpt.h
>> +++ b/include/linux/ckpt.h
>> @@ -10,6 +10,9 @@
>>  *  distribution for more details.
>>  */
>>
>> +#include <linux/path.h>
>> +#include <linux/fs.h>
>> +
>>  #define CR_VERSION  1
>>
>>  struct cr_ctx {
>> @@ -24,6 +27,11 @@ struct cr_ctx {
>>
>>        void *hbuf;             /* temporary buffer for headers */
>>        int hpos;               /* position in headers buffer */
>> +
>> +       struct list_head pgarr; /* page array for dumping VMA contents */
>> +       struct cr_pgarr *pgcur; /* current position in page array */
>> +
>> +       struct path *vfsroot;   /* container root (FIXME) */
>>  };
>>
>>  /* cr_ctx: flags */
>> @@ -46,11 +54,15 @@ struct cr_hdr;
>>
>>  int cr_write_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf);
>>  int cr_write_string(struct cr_ctx *ctx, char *str, int len);
>> +int cr_write_fname(struct cr_ctx *ctx, struct path *path, struct path *root);
>>
>>  int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n);
>>  int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type);
>>  int cr_read_string(struct cr_ctx *ctx, void *str, int len);
>>
>> +int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
>> +int cr_read_mm(struct cr_ctx *ctx);
>> +
>>  int do_checkpoint(struct cr_ctx *ctx);
>>  int do_restart(struct cr_ctx *ctx);
>>
>> diff --git a/include/linux/ckpt_hdr.h b/include/linux/ckpt_hdr.h
>> index e66f322..ac77d7d 100644
>> --- a/include/linux/ckpt_hdr.h
>> +++ b/include/linux/ckpt_hdr.h
>> @@ -32,6 +32,7 @@ struct cr_hdr {
>>  enum {
>>        CR_HDR_HEAD = 1,
>>        CR_HDR_STRING,
>> +       CR_HDR_FNAME,
>>
>>        CR_HDR_TASK = 101,
>>        CR_HDR_THREAD,
>> @@ -82,4 +83,33 @@ struct cr_hdr_task {
>>        __s32 task_comm_len;
>>  } __attribute__((aligned(8)));
>>
>> +struct cr_hdr_mm {
>> +       __u32 objref;           /* identifier for shared objects */
>> +       __u32 map_count;
>> +
>> +       __u64 start_code, end_code, start_data, end_data;
>> +       __u64 start_brk, brk, start_stack;
>> +       __u64 arg_start, arg_end, env_start, env_end;
>> +
>> +} __attribute__((aligned(8)));
>> +
>> +/* vma subtypes */
>> +enum vm_type {
>> +       CR_VMA_ANON = 1,
>> +       CR_VMA_FILE
>> +};
>> +
>> +struct cr_hdr_vma {
>> +       __u32 vma_type;
>> +       __u32 _padding;
>> +       __s64 nr_pages;
>> +
>> +       __u64 vm_start;
>> +       __u64 vm_end;
>> +       __u64 vm_page_prot;
>> +       __u64 vm_flags;
>> +       __u64 vm_pgoff;
>> +
>> +} __attribute__((aligned(8)));
>> +
>>  #endif /* _CHECKPOINT_CKPT_HDR_H_ */
>> --
>> 1.5.4.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>
>
>
>
> --
> Kinds regards,
> MinChan Kim
>



-- 
Kinds regards,
MinChan Kim
