From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Wed, 30 Jul 2008 11:52:49 -0500
Message-ID: <20080730165249.GA23802@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
List-Id: containers.vger.kernel.org

This list is getting on my nerves.  Louis, I'm sorry the threading
is going to get messed up.

----- Forwarded message from mailman-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org -----

Subject: Content filtered message notification
From: mailman-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-owner-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Date: Wed, 30 Jul 2008 09:16:12 -0700

The attached message matched the containers mailing list's content
filtering rules and was prevented from being forwarded on to the list
membership.  You are receiving the only remaining copy of the
discarded message.


Date: Wed, 30 Jul 2008 18:15:35 +0200
From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory
	maps
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org

Hi Oren,

On Tue, Jul 29, 2008 at 11:27:17PM -0400, Oren Laadan wrote:
> 
> Expand the template sys_checkpoint and sys_restart to be able to dump
> and restore a single task. The task's address space may consist of only
> private, simple vma's - anonymous or file-mapped.
> 
> This big patch adds a mechanism to transfer data between kernel or user
> space to and from the file given by the caller (sys.c), alloc/setup/free
> of the checkpoint/restart context (sys.c), output wrappers and basic
> checkpoint handling (checkpoint.c), memory dump (ckpt_mem.c), input
> wrappers and basic restart handling (restart.c), and finally the memory
> restore (rstr_mem.c).

This looks globally clean to me, but I'm sure that others will have stronger
arguments against or in favor of it.

Just a few comments inline, in case it helps.

[...]

> diff --git a/ckpt/checkpoint.c b/ckpt/checkpoint.c
> new file mode 100644
> index 0000000..1698a35
> --- /dev/null
> +++ b/ckpt/checkpoint.c

[...]

> +/* dump the task_struct of a given task */
> +static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_task *hh = ctx->tbuf;
> +
> +	h.type = CR_HDR_TASK;
> +	h.len = sizeof(*hh);
> +	h.id = ctx->pid;
> +
> +	hh->state = t->state;
> +	hh->exit_state = t->exit_state;
> +	hh->exit_code = t->exit_code;
> +	hh->exit_signal = t->exit_signal;
> +
> +	hh->pid = t->pid;
> +	hh->tgid = t->tgid;

IIRC, it is assumed that pid and tgid will be restored before actually calling
sys_restart(), eg by giving the proper pid and clone flags to a variant of
do_fork(). So, maybe these ids are useless here and should be put earlier in the
checkpoint header (see also the matching comment below in cr_read_task_struct()).

[...]

> diff --git a/ckpt/ckpt_mem.c b/ckpt/ckpt_mem.c
> new file mode 100644
> index 0000000..12caad0
> --- /dev/null
> +++ b/ckpt/ckpt_mem.c

[...]

> +/**
> + * cr_vma_fill_pgarr - fill a page-array with addr/page tuples for a vma
> + * @ctx - checkpoint context
> + * @pgarr - page-array to fill
> + * @vma - vma to scan
> + * @start - start address (updated)
> + */
> +static int cr_vma_fill_pgarr(struct cr_ctx *ctx, struct cr_pgarr *pgarr,
> +			     struct vm_area_struct *vma, unsigned long *start)
> +{
> +	unsigned long end = vma->vm_end;
> +	unsigned long addr = *start;
> +	struct page **pagep;
> +	unsigned long *addrp;
> +	int cow, nr, ret = 0;
> +
> +	nr = pgarr->nleft;
> +	pagep = &pgarr->pages[pgarr->nused];
> +	addrp = &pgarr->addrs[pgarr->nused];
> +	cow = !!vma->vm_file;
> +
> +	while (addr < end) {
> +		struct page *page;
> +
> +		/* simplified version of get_user_pages(): already have vma,
> +		* only need FOLL_TOUCH, and (for now) ignore fault stats */
> +
> +		cond_resched();
> +		while (!(page = follow_page(vma, addr, FOLL_TOUCH))) {
> +			ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
> +			if (ret & VM_FAULT_ERROR) {
> +				if (ret & VM_FAULT_OOM)
> +					ret = -ENOMEM;
> +				else if (ret & VM_FAULT_SIGBUS)
> +					ret = -EFAULT;
> +				else
> +					BUG();
> +				break;
> +			}
> +			cond_resched();
> +		}

I guess that 'ret' should be checked somewhere after this loop.

> +
> +		if (IS_ERR(page)) {
> +			ret = PTR_ERR(page);
> +			break;
> +		}
> +
> +		if (page == ZERO_PAGE(0))
> +			page = NULL;	/* zero page: ignore */
> +		else if (cow && page_mapping(page) != NULL)
> +			page = NULL;	/* clean cow: ignore */
> +		else {
> +			get_page(page);
> +			*(addrp++) = addr;
> +			*(pagep++) = page;
> +			if (--nr == 0) {
> +				addr += PAGE_SIZE;
> +				break;
> +			}
> +		}
> +
> +		addr += PAGE_SIZE;
> +	}
> +
> +	if (unlikely(ret < 0)) {
> +		nr = pgarr->nleft - nr;
> +		while (nr--)
> +			page_cache_release(*(--pagep));
> +		return ret;
> +	}
> +
> +	*start = addr;
> +	return (pgarr->nleft - nr);
> +}
> +

[...]

> +int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_mm *hh = ctx->tbuf;
> +	struct mm_struct *mm;
> +	struct vm_area_struct *vma;
> +	int ret;
> +
> +	h.type = CR_HDR_MM;
> +	h.len = sizeof(*hh);
> +	h.id = ctx->pid;
> +
> +	mm = get_task_mm(t);
> +
> +	hh->tag = 1;	/* non-zero will mean first time encounter */
> +
> +	hh->start_code = mm->start_code;
> +	hh->end_code = mm->end_code;
> +	hh->start_data = mm->start_data;
> +	hh->end_data = mm->end_data;
> +	hh->start_brk = mm->start_brk;
> +	hh->brk = mm->brk;
> +	hh->start_stack = mm->start_stack;
> +	hh->arg_start = mm->arg_start;
> +	hh->arg_end = mm->arg_end;
> +	hh->env_start = mm->env_start;
> +	hh->env_end = mm->env_end;
> +
> +	hh->map_count = mm->map_count;

Some fields above should also be protected with mmap_sem, like ->brk,
->map_count, and possibly others (I'm not a memory expert though).

> +
> +	/* FIX: need also mm->flags */
> +
> +	ret = cr_write_obj(ctx, &h, hh);
> +	if (ret < 0)
> +		goto out;
> +
> +	/* write the vma's */
> +	down_read(&mm->mmap_sem);
> +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +		if ((ret = cr_write_vma(ctx, vma)) < 0)
> +			break;
> +	}
> +	up_read(&mm->mmap_sem);
> +
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = cr_write_mm_context(ctx, mm);
> +
> + out:
> +	mmput(mm);
> +	return ret;
> +}

[...]

> diff --git a/ckpt/restart.c b/ckpt/restart.c
> new file mode 100644
> index 0000000..9f52851
> --- /dev/null
> +++ b/ckpt/restart.c

[...]

> +/* read the task_struct into the current task */
> +static int cr_read_task_struct(struct cr_ctx *ctx)
> +{
> +	struct cr_hdr_task *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	struct task_struct *t = current;
> +	int ret;
> +
> +	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_TASK);
> +	if (ret < 0)
> +		return ret;
> +
> +	/* for now, only restore t->comm */

+	/* current should already have correct pid and tgid */

> +	if (hh->task_comm_len < 0 || hh->task_comm_len > TASK_COMM_LEN)
> +		return -EINVAL;
> +
> +	memset(t->comm, 0, TASK_COMM_LEN);
> +	memcpy(t->comm, hh->comm, hh->task_comm_len);
> +
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +	return 0;
> +}
> +

Louis

-- 
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes




----- End forwarded message -----
