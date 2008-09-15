From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v5][PATCH 5/8] Restore memory address space
Date: Mon, 15 Sep 2008 12:14:04 -0700
Message-ID: <1221506044.16561.37.camel__24038.8442333371$1221506178$gmane$org@nimitz>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>
	<1221347167-9956-6-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1221347167-9956-6-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, 2008-09-13 at 19:06 -0400, Oren Laadan wrote:
> +struct file *cr_read_open_fname(struct cr_ctx *ctx, int flags, int mode)
> +{
> +	struct file *file;
> +	char *fname;
> +	int flen, ret;
> +
> +	flen = PATH_MAX;
> +	fname = kmalloc(flen, GFP_KERNEL);
> +	if (!fname)
> +		return ERR_PTR(-ENOMEM);
> +
> +	ret = cr_read_fname(ctx, fname, flen);
> +	cr_debug("fname '%s' flags %#x mode %#x\n", fname, flags, mode);
> +	if (ret >= 0)
> +		file = filp_open(fname, flags, mode);
> +	else
> +		file = ERR_PTR(ret);
> +
> +	kfree(fname);
> +	return file;
> +}

PATH_MAX is about as short of a global macro name as you're going to
get.  It should just be used directly.  Please kill 'flen'.


> +static int cr_read_pages_vaddrs(struct cr_ctx *ctx, unsigned long nr_pages)
> +{
> +	struct cr_pgarr *pgarr;
> +	unsigned long *vaddrp;
> +	int nr, ret;
> +
> +	while (nr_pages) {
> +		pgarr = cr_pgarr_current(ctx);
> +		if (!pgarr)
> +			return -ENOMEM;
> +		nr = cr_pgarr_nr_free(pgarr);
> +		if (nr > nr_pages)
> +			nr = nr_pages;
> +		vaddrp = &pgarr->vaddrs[pgarr->nr_used];
> +		ret = cr_kread(ctx, vaddrp, nr * sizeof(unsigned long));
> +		if (ret < 0)
> +			return ret;
> +		pgarr->nr_used += nr;
> +		nr_pages -= nr;
> +	}
> +	return 0;
> +}
> +
> +static int cr_page_read(struct cr_ctx *ctx, struct page *page, char *buf)
> +{
> +	void *ptr;
> +	int ret;
> +
> +	ret = cr_kread(ctx, buf, PAGE_SIZE);
> +	if (ret < 0)
> +		return ret;
> +
> +	ptr = kmap_atomic(page, KM_USER1);
> +	memcpy(ptr, buf, PAGE_SIZE);
> +	kunmap_atomic(page, KM_USER1);
> +
> +	return 0;
> +}
> +
> +/**
> + * cr_read_pages_contents - read in data of pages in page-array chain
> + * @ctx - restart context
> + */
> +static int cr_read_pages_contents(struct cr_ctx *ctx)
> +{
> +	struct mm_struct *mm = current->mm;
> +	struct cr_pgarr *pgarr;
> +	unsigned long *vaddrs;
> +	char *buf;
> +	int i, ret = 0;
> +
> +	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	down_read(&mm->mmap_sem);
> +	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
> +		vaddrs = pgarr->vaddrs;
> +		for (i = 0; i < pgarr->nr_used; i++) {
> +			struct page *page;
> +
> +			ret = get_user_pages(current, mm, vaddrs[i],
> +					     1, 1, 1, &page, NULL);
> +			if (ret < 0)
> +				goto out;
> +
> +			ret = cr_page_read(ctx, page, buf);
> +			page_cache_release(page);
> +
> +			if (ret < 0)
> +				goto out;
> +		}
> +	}
> +
> + out:
> +	up_read(&mm->mmap_sem);
> +	kfree(buf);
> +	return 0;
> +}
> +
> +/**
> + * cr_read_private_vma_contents - restore contents of a VMA with private memory
> + * @ctx - restart context
> + *
> + * Reads a header that specifies how many pages will follow, then reads
> + * a list of virtual addresses into ctx->pgarr_list page-array chain,
> + * followed by the actual contents of the corresponding pages. Iterates
> + * these steps until reaching a header specifying "0" pages, which marks
> + * the end of the contents.
> + */
> +static int cr_read_private_vma_contents(struct cr_ctx *ctx)
> +{
> +	struct cr_hdr_pgarr *hh;
> +	unsigned long nr_pages;
> +	int parent, ret = 0;
> +
> +	while (!ret) {
> +		hh = cr_hbuf_get(ctx, sizeof(*hh));
> +		parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_PGARR);
> +		if (parent < 0)
> +			return parent;
> +		else if (parent != 0)
> +			return -EINVAL;
> +
> +		cr_debug("nr_pages %ld\n", (unsigned long) hh->nr_pages);
> +
> +		nr_pages = hh->nr_pages;
> +		cr_hbuf_put(ctx, sizeof(*hh));
> +
> +		if (!nr_pages)
> +			break;
> +
> +		ret = cr_read_pages_vaddrs(ctx, nr_pages);
> +		if (ret < 0)
> +			break;
> +		ret = cr_read_pages_contents(ctx);
> +		if (ret < 0)
> +			break;
> +		cr_pgarr_reset_all(ctx);
> +	}
> +
> +	return ret;
> +}

That's an interesting loop condition, especially since it will never
actually get triggered.  while(1) would give the same functionality,
right?


-- Dave
