From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 05/11] checkpoint: allow VM_{IO,RESERVED,PFNMAP} mappings
Date: Mon, 10 Jan 2011 21:36:06 -0500
Message-ID: <4D2BC216.1080903@cs.columbia.edu>
References: <1287601006-13794-1-git-send-email-ntl@pobox.com>
	<1287601006-13794-6-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1287601006-13794-6-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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

Hi,

I'm not too familiar with all the uses of VM_{IO,RESERVED,PFNMAP}
flags. Should I be concerned about missing out cases where the
checkpoint succeeds but the restart will fail (or worse, succeed
but not work correctly thereafter) ?

If these are only "used" by devices, then no problem - they won't
checkpoint unless they have the code to support c/r.  But are
they used elsewhere ?

If so, perhaps we should find a way to encode these constraints
differently, e.g., only allow these flags if there is vma->vm_file
which has a .checkpoint operation valid ?

Oren.

On 10/20/2010 02:56 PM, Nathan Lynch wrote:
> This is necessary for checkpoint/restart of BSR device (and likely
> hpet and other timer device) mappings.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  include/linux/checkpoint.h |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index a02f27a..df0a9ed 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -313,12 +313,9 @@ extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
>  #define CKPT_VMA_NOT_SUPPORTED (			\
>  		VM_HUGETLB |				\
>  		VM_INSERTPAGE |				\
> -		VM_IO |					\
>  		VM_MAPPED_COPY |			\
>  		VM_MIXEDMAP |				\
>  		VM_NONLINEAR |				\
> -		VM_PFNMAP |				\
> -		VM_RESERVED |				\
>  		VM_SAO |				\
>  		0)
>  
