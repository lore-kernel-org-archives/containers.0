From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: define CKPT_ARCH_NSIG for s390
Date: Sat, 27 Jun 2009 06:28:54 -0400
Message-ID: <4A45F466.5020403@cs.columbia.edu>
References: <20090626190821.GA29506@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090626190821.GA29506-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Serge E. Hallyn wrote:
> Better?

Nice, added.

> 
> From 5cb3dae3611cf9cf86ff9616dac7c36de8b812d1 Mon Sep 17 00:00:00 2001
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Date: Fri, 26 Jun 2009 15:06:43 -0400
> Subject: [PATCH 1/1] cr: define CKPT_ARCH_NSIG for s390
> 
> Also add a check for x86 and s390 in the hopes of catching any
> changes to NSIG which don't update CKPT_ARCH_NSIG.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---

Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

>  arch/s390/include/asm/checkpoint_hdr.h |    8 ++++++++
>  arch/x86/include/asm/checkpoint_hdr.h  |    6 ++++++
>  2 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
> index fc0ace8..264a42c 100644
> --- a/arch/s390/include/asm/checkpoint_hdr.h
> +++ b/arch/s390/include/asm/checkpoint_hdr.h
> @@ -79,6 +79,14 @@ struct ckpt_hdr_mm_context {
>  	unsigned long asce_limit;
>  };
>  
> +#define CKPT_ARCH_NSIG  64
> +#ifdef __KERNEL__
> +#include <asm/signal.h>
> +#if CKPT_ARCH_NSIG != _SIGCONTEXT_NSIG
> +#error CKPT_ARCH_NSIG size is wrong (asm/sigcontext.h and asm/checkpoint_hdr.h)
> +#endif
> +#endif
> +
>  struct ckpt_hdr_header_arch {
>  	struct ckpt_hdr h;
>  };
> diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
> index 745038b..21fb072 100644
> --- a/arch/x86/include/asm/checkpoint_hdr.h
> +++ b/arch/x86/include/asm/checkpoint_hdr.h
> @@ -45,6 +45,12 @@ enum {
>  };
>  
>  #define CKPT_ARCH_NSIG  64
> +#ifdef __KERNEL__
> +#include <asm/signal.h>
> +#if CKPT_ARCH_NSIG != NSIG
> +#error CKPT_ARCH_NSIG size is wrong per asm/signal.h and asm/checkpoint_hdr.h
> +#endif
> +#endif
>  
>  struct ckpt_hdr_header_arch {
>  	struct ckpt_hdr h;
