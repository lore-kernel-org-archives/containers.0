From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 06/29] Dump memory address space
Date: Mon, 6 Apr 2009 20:26:36 -0700
Message-ID: <20090407032636.GD12316@us.ibm.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-7-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238477349-11029-7-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


One comment below.

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| From eed3f074ed035c93eb49d05cc1491ee680956906 Mon Sep 17 00:00:00 2001
| From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
| Date: Mon, 30 Mar 2009 13:57:11 -0400
| Subject: [PATCH 06/29] Dump memory address space
| 
| For each VMA, there is a 'struct cr_vma'; if the VMA is file-mapped,
| it will be followed by the file name. Then comes the actual contents,
| in one or more chunk: each chunk begins with a header that specifies
| how many pages it holds, then the virtual addresses of all the dumped
| pages in that chunk, followed by the actual contents of all dumped
| pages. A header with zero number of pages marks the end of the contents.
| Then comes the next VMA and so on.
| 
| Changelog[v14]:
|   - Revert change to pr_debug(), back to cr_debug()
|   - Save new field 'vdso' in mm_context
|   - Discard field 'h->parent'
|   - Check whether calls to cr_hbuf_get() fail
| 
| Changelog[v13]:
|   - pgprot_t is an abstract type; use the proper accessor (fix for
|     64-bit powerpc (Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>)
| 
| Changelog[v12]:
|   - Hide pgarr management inside cr_private_vma_fill_pgarr()
|   - Fix management of pgarr chain reset and alloc/expand: keep empty
|     pgarr in a pool chain
|   - Replace obsolete cr_debug() with pr_debug()
| 
| Changelog[v11]:
|   - Copy contents of 'init->fs->root' instead of pointing to them.
|   - Add missing test for VM_MAYSHARE when dumping memory
| 
| Changelog[v10]:
|   - Acquire dcache_lock around call to __d_path() in cr_fill_name()
| 
| Changelog[v9]:
|   - Introduce cr_ctx_checkpoint() for checkpoint-specific ctx setup
|   - Test if __d_path() changes mnt/dentry (when crossing filesystem
|     namespace boundary). for now cr_fill_fname() fails the checkpoint.
| 
| Changelog[v7]:
|   - Fix argument given to kunmap_atomic() in memory dump/restore
| 
| Changelog[v6]:
|   - Balance all calls to cr_hbuf_get() with matching cr_hbuf_put()
|     (even though it's not really needed)
| 
| Changelog[v5]:
|   - Improve memory dump code (following Dave Hansen's comments)
|   - Change dump format (and code) to allow chunks of <vaddrs, pages>
|     instead of one long list of each
|   - Fix use of follow_page() to avoid faulting in non-present pages
| 
| Changelog[v4]:
|   - Use standard list_... for cr_pgarr
| 
| Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
| Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
| Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| ---
|  arch/x86/include/asm/checkpoint_hdr.h |    6 +
|  arch/x86/mm/checkpoint.c              |   31 ++
|  checkpoint/Makefile                   |    3 +-
|  checkpoint/checkpoint.c               |   87 +++++
|  checkpoint/checkpoint_arch.h          |    1 +
|  checkpoint/checkpoint_mem.h           |   41 +++
|  checkpoint/ckpt_mem.c                 |  558 +++++++++++++++++++++++++++++++++
|  checkpoint/sys.c                      |   11 +
|  include/linux/checkpoint.h            |   13 +
|  include/linux/checkpoint_hdr.h        |   32 ++
|  10 files changed, 782 insertions(+), 1 deletions(-)
|  create mode 100644 checkpoint/checkpoint_mem.h
|  create mode 100644 checkpoint/ckpt_mem.c
| 
| diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
| index ffdb5f5..54d3a41 100644
| --- a/arch/x86/include/asm/checkpoint_hdr.h
| +++ b/arch/x86/include/asm/checkpoint_hdr.h
| @@ -95,4 +95,10 @@ struct cr_hdr_cpu {
|  	/* thread_xstate contents follow (if used_math) */
|  } __attribute__((aligned(8)));
|  
| +struct cr_hdr_mm_context {
| +	__u64 vdso;
| +	__u32 ldt_entry_size;
| +	__u32 nldt;
| +} __attribute__((aligned(8)));
| +
|  #endif /* __ASM_X86_CKPT_HDR__H */
| diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
| index 946fac1..92926e1 100644
| --- a/arch/x86/mm/checkpoint.c
| +++ b/arch/x86/mm/checkpoint.c
| @@ -240,3 +240,34 @@ int cr_write_head_arch(struct cr_ctx *ctx)
|  
|  	return ret;
|  }
| +
| +/* dump the mm->context state */
| +int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
| +{
| +	struct cr_hdr h;
| +	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
| +	int ret;
| +
| +	h.type = CR_HDR_MM_CONTEXT;
| +	h.len = sizeof(*hh);
| +
| +	mutex_lock(&mm->context.lock);
| +
| +	hh->vdso = (unsigned long) mm->context.vdso;
| +	hh->ldt_entry_size = LDT_ENTRY_SIZE;
| +	hh->nldt = mm->context.size;
| +
| +	cr_debug("nldt %d vdso %#llx\n", hh->nldt, hh->vdso);
| +
| +	ret = cr_write_obj(ctx, &h, hh);
| +	cr_hbuf_put(ctx, sizeof(*hh));
| +	if (ret < 0)
| +		goto out;
| +
| +	ret = cr_kwrite(ctx, mm->context.ldt,
| +			mm->context.size * LDT_ENTRY_SIZE);
| +
| + out:
| +	mutex_unlock(&mm->context.lock);
| +	return ret;
| +}
| diff --git a/checkpoint/Makefile b/checkpoint/Makefile
| index 364c326..6924ef4 100644
| --- a/checkpoint/Makefile
| +++ b/checkpoint/Makefile
| @@ -2,4 +2,5 @@
|  # Makefile for linux checkpoint/restart.
|  #
|  
| -obj-$(CONFIG_CHECKPOINT) += sys.o checkpoint.o restart.o
| +obj-$(CONFIG_CHECKPOINT) += sys.o checkpoint.o restart.o \
| +	 ckpt_mem.o
| diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
| index 422ceff..422e1a3 100644
| --- a/checkpoint/checkpoint.c
| +++ b/checkpoint/checkpoint.c
| @@ -13,6 +13,7 @@
|  #include <linux/time.h>
|  #include <linux/fs.h>
|  #include <linux/file.h>
| +#include <linux/fdtable.h>
|  #include <linux/dcache.h>
|  #include <linux/mount.h>
|  #include <linux/utsname.h>
| @@ -73,6 +74,65 @@ int cr_write_string(struct cr_ctx *ctx, char *str, int len)
|  	return cr_write_obj(ctx, &h, str);
|  }
|  
| +/**
| + * cr_fill_fname - return pathname of a given file
| + * @path: path name
| + * @root: relative root
| + * @buf: buffer for pathname
| + * @n: buffer length (in) and pathname length (out)
| + */
| +static char *
| +cr_fill_fname(struct path *path, struct path *root, char *buf, int *n)
| +{
| +	struct path tmp = *root;
| +	char *fname;
| +
| +	BUG_ON(!buf);
| +	spin_lock(&dcache_lock);
| +	fname = __d_path(path, &tmp, buf, *n);
| +	spin_unlock(&dcache_lock);
| +	if (!IS_ERR(fname))
| +		*n = (buf + (*n) - fname);
| +	/*
| +	 * FIXME: if __d_path() changed these, it must have stepped out of
| +	 * init's namespace. Since currently we require a unified namespace
| +	 * within the container: simply fail.
| +	 */
| +	if (tmp.mnt != root->mnt || tmp.dentry != root->dentry)
| +		fname = ERR_PTR(-EBADF);
| 

Shouldn't this be under if (!IS_ERR(fname)) ? 'tmp' may be uninitialized
if __d_path() fails with ENAMETOOLONG. Even otherwise, it may be better
to report the error from __dpath() first ?
