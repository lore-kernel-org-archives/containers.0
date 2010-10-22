From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 03/11] checkpoint: reformat CKPT_VMA_NOT_SUPPORTED
Date: Thu, 21 Oct 2010 17:34:34 -0700
Message-ID: <20101022003434.GI10119@count0.beaverton.ibm.com>
References: <1287601006-13794-1-git-send-email-ntl@pobox.com>
	<1287601006-13794-4-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1287601006-13794-4-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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

On Wed, Oct 20, 2010 at 01:56:38PM -0500, Nathan Lynch wrote:
> Remove duplicate VM_HUGETLB and VM_NONLINEAR; place each flag on its
> own line and alphabetize the list.  This will make future
> modifications to CKPT_VMA_NOT_SUPPORTED easier to review.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  include/linux/checkpoint.h |   15 +++++++++++----
>  1 files changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index a11d40e..49cf01e 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -309,10 +309,17 @@ extern int checkpoint_memory_contents(struct ckpt_ctx *ctx,
>  extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
> 
> 
> -#define CKPT_VMA_NOT_SUPPORTED						\
> -	(VM_IO | VM_HUGETLB | VM_NONLINEAR | VM_PFNMAP |		\
> -	 VM_RESERVED | VM_HUGETLB | VM_NONLINEAR |	\
> -	 VM_MAPPED_COPY | VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
> +#define CKPT_VMA_NOT_SUPPORTED (			\
> +		VM_HUGETLB |				\
> +		VM_INSERTPAGE |				\
> +		VM_IO |					\
> +		VM_MAPPED_COPY |			\
> +		VM_MIXEDMAP |				\
> +		VM_NONLINEAR |				\
> +		VM_PFNMAP |				\
> +		VM_RESERVED |				\
> +		VM_SAO |				\
> +		0)
> 
>  /* signals */
>  extern int checkpoint_obj_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
> -- 
> 1.7.2.2
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
