From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] use more compatible code in special_mapping_restore
Date: Sun, 31 Jan 2010 22:42:36 -0600
Message-ID: <20100201044236.GA2746@us.ibm.com>
References: <20100129033041.GA21071@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100129033041.GA21071-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> (Also remove some unused vars in my do_unmap helper)
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Please don't apply this.  It wasn't supposed to change behavior,
but it does, for the worse.

> ---
>  mm/mmap.c |   12 +++++-------
>  1 files changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 15afae6..468c8e2 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -30,6 +30,7 @@
>  #include <linux/mmu_notifier.h>
>  #include <linux/perf_event.h>
>  #include <linux/checkpoint.h>
> +#include <linux/compat.h>
> 
>  #include <asm/uaccess.h>
>  #include <asm/cacheflush.h>
> @@ -1960,9 +1961,6 @@ int do_munmap_nocheck(struct mm_struct *mm, unsigned long start, size_t len)
> 
>  int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
>  {
> -	unsigned long end;
> -	struct vm_area_struct *vma, *prev, *last;
> -
>  	if ((start & ~PAGE_MASK) || start > TASK_SIZE || len > TASK_SIZE-start)
>  		return -EINVAL;
> 
> @@ -2354,10 +2352,10 @@ int special_mapping_restore(struct ckpt_ctx *ctx,
>  	 * Even that, is very basic - call arch_setup_additional_pages
>  	 * requiring the same mapping (start address) as before.
>  	 */
> -#ifdef CONFIG_X86_64 && CONFIG_COMPAT                                                                                                                                                                            
> -	if (test_thread_flag(TIF_IA32))                                                                                                                                                                           
> -		return syscall32_setup_pages(NULL, h->vm_start, 0);                                                                                                                                               
> -#endif                                                                                                                                                                                                           
> +#ifdef CONFIG_COMPAT
> +	if (is_compat_task())
> +		return compat_arch_setup_additional_pages(NULL, h->vm_start, 0);
> +#endif
>  	return arch_setup_additional_pages(NULL, h->vm_start, 0);
>  }
>  #else /* !CONFIG_CHECKPOINT */
> -- 
> 1.6.0.6
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
