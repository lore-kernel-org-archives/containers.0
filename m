From: "Vegard Nossum" <vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v4][PATCH 4/9] Memory management (dump)
Date: Tue, 9 Sep 2008 11:22:07 +0200
Message-ID: <19f34abd0809090222u68e90c74l514cd0b50a290d4b__35659.8849910826$1220952322$gmane$org@mail.gmail.com>
References: <1220946154-15174-1-git-send-email-orenl@cs.columbia.edu>
	<1220946154-15174-5-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1220946154-15174-5-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

On Tue, Sep 9, 2008 at 9:42 AM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:
> For each VMA, there is a 'struct cr_vma'; if the VMA is file-mapped,
> it will be followed by the file name.  The cr_vma->npages will tell
> how many pages were dumped for this VMA.  Then it will be followed
> by the actual data: first a dump of the addresses of all dumped
> pages (npages entries) followed by a dump of the contents of all
> dumped pages (npages pages). Then will come the next VMA and so on.
>
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> ---
>  arch/x86/mm/checkpoint.c   |   30 +++
>  arch/x86/mm/restart.c      |    1 +
>  checkpoint/Makefile        |    3 +-
>  checkpoint/checkpoint.c    |   53 ++++++
>  checkpoint/ckpt_arch.h     |    1 +
>  checkpoint/ckpt_mem.c      |  448 ++++++++++++++++++++++++++++++++++++++++++++
>  checkpoint/ckpt_mem.h      |   35 ++++
>  checkpoint/sys.c           |   23 ++-
>  include/asm-x86/ckpt_hdr.h |    5 +
>  include/linux/ckpt.h       |   12 ++
>  include/linux/ckpt_hdr.h   |   30 +++
>  11 files changed, 635 insertions(+), 6 deletions(-)
>  create mode 100644 checkpoint/ckpt_mem.c
>  create mode 100644 checkpoint/ckpt_mem.h
>
> diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
> index 71d21e6..50cfd29 100644
> --- a/arch/x86/mm/checkpoint.c
> +++ b/arch/x86/mm/checkpoint.c
> @@ -192,3 +192,33 @@ int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
>        cr_hbuf_put(ctx, sizeof(*hh));
>        return ret;
>  }
> +
> +/* dump the mm->context state */
> +int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
> +{
> +       struct cr_hdr h;
> +       struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +       int ret;
> +
> +       h.type = CR_HDR_MM_CONTEXT;
> +       h.len = sizeof(*hh);
> +       h.parent = parent;
> +
> +       mutex_lock(&mm->context.lock);
> +
> +       hh->ldt_entry_size = LDT_ENTRY_SIZE;
> +       hh->nldt = mm->context.size;
> +
> +       cr_debug("nldt %d\n", hh->nldt);
> +
> +       ret = cr_write_obj(ctx, &h, hh);
> +       cr_hbuf_put(ctx, sizeof(*hh));
> +       if (ret < 0)
> +               return ret;

mutex_unlock(&mm->context.lock) before return, I think?

> +
> +       ret = cr_kwrite(ctx, mm->context.ldt, hh->nldt * LDT_ENTRY_SIZE);
> +
> +       mutex_unlock(&mm->context.lock);
> +
> +       return ret;
> +}


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
