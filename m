From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] checkpoint: conditionally schedule; check for fatal
	signals
Date: Thu, 18 Nov 2010 15:03:35 -0800
Message-ID: <20101118230335.GD27736@count0.beaverton.ibm.com>
References: <1290115265-19038-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1290115265-19038-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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

On Thu, Nov 18, 2010 at 03:21:05PM -0600, Nathan Lynch wrote:
> Long-running operations in the kernel should:
> 
> o  not monopolize the CPU
> o  abort when asked
> 
> Put voluntary preemption points in ckpt_kread, ckpt_kwrite, and the
> VMA-walking checkpoint code.  At the same points, return an error if a
> fatal signal is pending; callers of these functions are supposed to be
> checking return values.

We do alot more than read/write the image -- e.g. collecting references at
the beginning prior to checkpoint. Perhaps should add some to the objhash
code too.

Cheers,
	-Matt Helsley

> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  kernel/checkpoint/sys.c |   10 ++++++++++
>  mm/checkpoint.c         |    7 +++++++
>  2 files changed, 17 insertions(+), 0 deletions(-)
> 
> diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
> index b761ec0..04e6277 100644
> --- a/kernel/checkpoint/sys.c
> +++ b/kernel/checkpoint/sys.c
> @@ -72,6 +72,11 @@ int ckpt_kwrite(struct ckpt_ctx *ctx, void *addr, size_t count)
>  	if (ckpt_test_error(ctx))
>  		return ckpt_get_error(ctx);
> 
> +	if (fatal_signal_pending(current))
> +		return -EINTR;
> +
> +	cond_resched();
> +
>  	ret = _ckpt_kwrite(ctx->file, addr, count);
>  	if (ret < 0)
>  		return ret;
> @@ -103,6 +108,11 @@ int ckpt_kread(struct ckpt_ctx *ctx, void *addr, size_t count)
>  	if (ckpt_test_error(ctx))
>  		return ckpt_get_error(ctx);
> 
> +	if (fatal_signal_pending(current))
> +		return -EINTR;
> +
> +	cond_resched();
> +
>  	ret = _ckpt_kread(ctx->file, addr, count);
>  	if (ret < 0)
>  		return ret;
> diff --git a/mm/checkpoint.c b/mm/checkpoint.c
> index 70300e8..6732a2e 100644
> --- a/mm/checkpoint.c
> +++ b/mm/checkpoint.c
> @@ -310,6 +310,13 @@ static int vma_fill_pgarr(struct ckpt_ctx *ctx,
>  		while (addr < end) {
>  			struct page *page;
> 
> +			if (fatal_signal_pending(current)) {
> +				cnt = -EINTR;
> +				goto out;
> +			}
> +
> +			cond_resched();
> +
>  			if (vma)
>  				page = consider_private_page(vma, addr);
>  			else
> -- 
> 1.7.3.2
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
