From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 6/7] proc: Introduce the /proc/<pid>/dump file
Date: Thu, 21 Jul 2011 08:44:08 +0200
Message-ID: <20110721064408.GR3455@htj.dyndns.org>
References: <4E204466.8010204@parallels.com> <4E204500.6040800@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E204500.6040800-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Fri, Jul 15, 2011 at 05:47:44PM +0400, Pavel Emelyanov wrote:
> An image read from file contains task's registers and information
> about its VM. Later this image can be execve-ed causing recreation
> of the previously read task state.
> 
> The file format is my own, very simple. Introduced to make the code
> as simple as possible. Better file format (if any) is to be discussed.

First of all, I don't really think we need to bake in process dumper
into the kernel.  Most of information dumped here is already available
through /proc and ptrace and we can add the missing pieces like the
suggested proc vma fds.

> +static int img_dump_regs(struct task_struct *p, char __user *buf, size_t size, int pos)
> +{
> +	struct binfmt_regs_image regi;
> +	struct pt_regs *regs;
> +	int i;
> +
> +	regs = task_pt_regs(p);
> +
> +	regi.r15 = regs->r15;
> +	regi.r14 = regs->r14;
> +	regi.r13 = regs->r13;
> +	regi.r12 = regs->r12;
> +	regi.r11 = regs->r11;
> +	regi.r10 = regs->r10;
> +	regi.r9 = regs->r9;
> +	regi.r8 = regs->r8;
> +	regi.ax = regs->ax;
> +	regi.orig_ax = regs->orig_ax;
> +	regi.bx = regs->bx;
> +	regi.cx = regs->cx;
> +	regi.dx = regs->dx;
> +	regi.si = regs->si;
> +	regi.di = regs->di;
> +	regi.ip = regs->ip;
> +	regi.flags = regs->flags;
> +	regi.bp = regs->bp;
> +	regi.sp = regs->sp;
> +
> +	/* segments */
> +	regi.gsindex = encode_segment(p->thread.gsindex);
> +	regi.fsindex = encode_segment(p->thread.fsindex);
> +	regi.cs = encode_segment(regs->cs);
> +	regi.ss = encode_segment(regs->ss);
> +	regi.ds = encode_segment(p->thread.ds);
> +	regi.es = encode_segment(p->thread.es);
> +
> +	BUILD_BUG_ON(GDT_ENTRY_TLS_ENTRIES != CKPT_TLS_ENTRIES);
> +	for (i = 0; i < GDT_ENTRY_TLS_ENTRIES; i++)
> +		regi.tls[i] = encode_tls(&p->thread.tls_array[i]);
> +
> +	if (p->thread.gsindex)
> +		regi.gs = 0;
> +	else
> +		regi.gs = p->thread.gs;
> +
> +	if (p->thread.fsindex)
> +		regi.fs = 0;
> +	else
> +		regi.fs = p->thread.fs;
> +
> +	return img_dump_buffer(buf, size, &regi, sizeof(regi), pos);
> +}

Umm... x86_64 code directly under fs/proc?  And the dump image doesn't
have arch marker?

> +static ssize_t do_produce_dump(struct task_struct *p, char __user *buf,
> +		size_t size, loff_t *ppos)
> +{
...
> +	/* registers */
> +	seek_pos(sizeof(struct binfmt_regs_image));
> +	if (pos < img_pos) {
> +		len = img_dump_regs(p, buf, size, pos - img_ppos);
> +		if (len < 0)
> +			goto err;
> +
> +		move_pos();
> +		if (size == 0)
> +			goto out;
> +	}

This is per-thread information.

> +	/* memory */
...
> +	for (vma = mm->mmap; vma != NULL; vma = vma->vm_next) {
> +		/* slow and stupid */
> +		unsigned long addr;
> +		struct page *page;
> +		void *pg_data;
> +
> +		if (!is_private_vma(vma))
> +			continue;
> +
> +		for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
> +			page = follow_page(vma, addr, FOLL_FORCE | FOLL_DUMP | FOLL_GET);
> +			if (page == NULL)
> +				continue;
> +			if (IS_ERR(page)) /* huh? */
> +				continue;
> +
> +			seek_pos(sizeof(struct binfmt_page_image) + PAGE_SIZE);
> +			if (pos < img_pos) {
> +				pg_data = kmap(page);
> +				len = img_dump_page(addr, pg_data, buf, size, pos - img_ppos);
> +				kunmap(page);
> +
> +				if (len < 0) {
> +					put_page(page);
> +					goto err_mm;
> +				}
> +
> +				move_pos();
> +				if (size == 0) {
> +					put_page(page);
> +					goto out_mm;
> +				}
> +			}
> +
> +			put_page(page);
> +		}
> +	}
...

These are per-process.  I can't see how this would work out well.

Thanks.

-- 
tejun
