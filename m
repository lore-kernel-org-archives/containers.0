From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] fix ifdef to shut up gcc in mm/mmap.c
Date: Thu, 04 Feb 2010 12:38:41 -0500
Message-ID: <4B6B0621.6080102@cs.columbia.edu>
References: <20100128205333.GA5026@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100128205333.GA5026-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


Ughhh ... done.

Serge E. Hallyn wrote:
> 1. For some reason there were two lines worth of spaces at the end
> of each line
> 2. #ifdef a && b doesn't please gcc.  use #if defined() && defined()
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  mm/mmap.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 0b2319f..c2451e3 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2324,10 +2324,10 @@ int special_mapping_restore(struct ckpt_ctx *ctx,
>  	 * Even that, is very basic - call arch_setup_additional_pages
>  	 * requiring the same mapping (start address) as before.
>  	 */
> -#ifdef CONFIG_X86_64 && CONFIG_COMPAT                                                                                                                                                                            
> -	if (test_thread_flag(TIF_IA32))                                                                                                                                                                           
> -		return syscall32_setup_pages(NULL, h->vm_start, 0);                                                                                                                                               
> -#endif                                                                                                                                                                                                           
> +#if defined(CONFIG_X86_64) && defined(CONFIG_COMPAT)
> +	if (test_thread_flag(TIF_IA32))
> +		return syscall32_setup_pages(NULL, h->vm_start, 0);
> +#endif
>  	return arch_setup_additional_pages(NULL, h->vm_start, 0);
>  }
>  #else /* !CONFIG_CHECKPOINT */
