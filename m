From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH linux-cr] send uses_interp=1 to arch_setup_additional_pages
Date: Mon, 01 Mar 2010 14:31:03 -0500
Message-ID: <4B8C15F7.8000006@cs.columbia.edu>
References: <20100224213322.GA3502@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100224213322.GA3502-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Applied.

I added the commit comment to the code, because when (and if) we
fold this to v20, the commit message will be gone.

Oren.

Serge E. Hallyn wrote:
> Because the s390 version won't set up vdso if it is 0.  It
> is safe to assume that if we are calling special_mapping_restore()
> then there is a vdso in the checkpoint image, and if that is
> the case then the checkpointed program was dynamically linked.
> 
> Other architectures ignore uses_interp so this shouldn't
> matter to them.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  mm/mmap.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 6aa606a..9cded98 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2404,7 +2404,7 @@ int special_mapping_restore(struct ckpt_ctx *ctx,
>  	if (test_thread_flag(TIF_IA32))
>  		return syscall32_setup_pages(NULL, h->vm_start, 0);
>  #endif
> -	return arch_setup_additional_pages(NULL, h->vm_start, 0);
> +	return arch_setup_additional_pages(NULL, h->vm_start, 1);
>  }
>  #else /* !CONFIG_CHECKPOINT */
>  #define special_mapping_checkpoint NULL
