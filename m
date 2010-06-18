From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC] checkpoint: un-blacklist VM_NORESERVE
Date: Fri, 18 Jun 2010 11:33:35 -0400
Message-ID: <4C1B91CF.6070701@cs.columbia.edu>
References: <1276808838.6401.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1276808838.6401.6.camel@localhost>
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


On 06/17/2010 05:07 PM, Nathan Lynch wrote:
> While a region mapped with MAP_NORESERVE may segv on a write in
> low-memory conditions, reading it (as we do during checkpoint) is
> fine.  Remove the VM_NORESERVE flag from CKPT_VMA_NOT_SUPPORTED.
> 
> ---
> 
> Oren, what do you think about this?  I've tested this lightly with no
> apparent problems; is there some reason I'm missing to not support
> MAP_NORESERVE regions?

Sounds reasonable. I originally left it out because I wasn't sure.
In particular, my concern was whether a user may cause troubles by
specifying this flag. Now I looked deeper, and I think it's safe.

Note, however, it isn't enough to allow the flag, we also need to
modify calc_map_flags_bits() to reintroduce MAP_NORESERVE for the
flags argument to do_mmap_pgoff(). Otherwise it won't be restored
at restart...

No need to repost the patch. I'll do it.

Oren.

> 
>  include/linux/checkpoint.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 84bb7a9..f3e0d11 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -301,7 +301,7 @@ extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
>  
>  #define CKPT_VMA_NOT_SUPPORTED						\
>  	(VM_IO | VM_HUGETLB | VM_NONLINEAR | VM_PFNMAP |		\
> -	 VM_RESERVED | VM_NORESERVE | VM_HUGETLB | VM_NONLINEAR |	\
> +	 VM_RESERVED | VM_HUGETLB | VM_NONLINEAR |	\
>  	 VM_MAPPED_COPY | VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
>  
>  /* signals */
