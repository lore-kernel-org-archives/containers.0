From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Fix up headers so we can munge them for use by userspace.
Date: Mon, 5 Oct 2009 21:20:27 -0500
Message-ID: <20091006022027.GA31628@us.ibm.com>
References: <1254553859-481-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1254553859-481-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

I'm sorry, I'm really pretty ignorant when it comes to userspace includes.
Can you give a little more explanation as to:
	1. why we don't need sys/user.h, and why it was included originally?
	2. why we need sys/types.h first?  I don't see that mentioned in
		the linux/types.h.
	3. how much of this will be distro-dependent?

Don't read this as questioning their correctness, just as my curiosity.

thanks,
-serge

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  arch/s390/include/asm/checkpoint_hdr.h |    7 +++++--
>  arch/x86/include/asm/checkpoint_hdr.h  |    2 --
>  include/linux/checkpoint_hdr.h         |    4 ++++
>  3 files changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
> index b6ea8ce..bc9f624 100644
> --- a/arch/s390/include/asm/checkpoint_hdr.h
> +++ b/arch/s390/include/asm/checkpoint_hdr.h
> @@ -19,8 +19,6 @@
> 
>  #ifdef __KERNEL__
>  #include <asm/processor.h>
> -#else
> -#include <sys/user.h>
>  #endif
> 
>  #ifdef CONFIG_64BIT
> @@ -34,7 +32,12 @@
>   * NUM_FPRS defined in <asm/ptrace.h> to be 16
>   * NUM_APRS defined in <asm/ptrace.h> to be 16
>   * NUM_CR_WORDS defined in <asm/ptrace.h> to be 3
> + *              but is not yet in glibc headers.
>   */
> +#ifndef NUM_CR_WORDS
> +#define NUM_CR_WORDS 3
> +#endif
> +
>  struct ckpt_hdr_cpu {
>  	struct ckpt_hdr h;
>  	__u64 args[1];
> diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
> index 7a24de5..282bd31 100644
> --- a/arch/x86/include/asm/checkpoint_hdr.h
> +++ b/arch/x86/include/asm/checkpoint_hdr.h
> @@ -34,8 +34,6 @@
>  /* i387 structure seen from kernel/userspace */
>  #ifdef __KERNEL__
>  #include <asm/processor.h>
> -#else
> -#include <sys/user.h>
>  #endif
> 
>  #ifdef CONFIG_X86_32
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index f8bd4e1..b318cee 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -10,6 +10,10 @@
>   *  distribution for more details.
>   */
> 
> +#ifndef __KERNEL__
> +/* In userspace sys/types.h must be included before linux/types.h */
> +#include <sys/types.h>
> +#endif
>  #include <linux/types.h>
> 
>  #ifdef __KERNEL__
> -- 
> 1.5.6.3
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
