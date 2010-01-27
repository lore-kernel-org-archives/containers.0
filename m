From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] fill vdso with syscall32_setup_pages if TIF_IA32 on
	x86_64
Date: Wed, 27 Jan 2010 09:59:42 -0500 (EST)
Message-ID: <Pine.LNX.4.64.1001270954120.8974@takamine.ncl.cs.columbia.edu>
References: <20100127071636.GA16624@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100127071636.GA16624-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Cool !

So what do we have working now for 64 bit kernel (for 32 bit kernel
we know it works...):

	'restart'	checkpointed
	 program	  program
	----------------------------------------
	  64bit		  64bit		-> works
	  32bit		  32bit		-> works

	  64bit		  32bit		-> ?????

Does it make sense to allow the opposite transition: 'restart' starts
as a 32bit and becomes a 64bit after it restores the state from the
image ?

And what about if you checkpoint on a 32 bit kernel and try to 
restart on a 64 bit kernel, and vice versa ?  (in both cases, the
program of course is 32bit, and we can assume same physical host
for now). 

Oren.



On Wed, 27 Jan 2010, Serge E. Hallyn wrote:

> arch_setup_additional_pages() on x86_64 fills in a 64-bit
> vdso page.
> 
> With this patch, restart of 32-bit tasks (both self- and external
> checkpoints) on x86-64 succeeds.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  mm/mmap.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 1759a7f..e3d4178 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2324,6 +2324,10 @@ int special_mapping_restore(struct ckpt_ctx *ctx,
>  	 * Even that, is very basic - call arch_setup_additional_pages
>  	 * requiring the same mapping (start address) as before.
>  	 */
> +#ifdef CONFIG_X86_64 && CONFIG_COMPAT
> +	if (test_thread_flag(TIF_IA32))
> +		return syscall32_setup_pages(NULL, h->vm_start, 0);
> +#endif
>  	return arch_setup_additional_pages(NULL, h->vm_start, 0);
>  }
>  #else /* !CONFIG_CHECKPOINT */
> 
