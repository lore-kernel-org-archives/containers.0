From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: move CKPT_ARCH_NSIG to asm/signal.h
Date: Fri, 26 Jun 2009 12:02:35 -0400
Message-ID: <4A44F11B.20803@cs.columbia.edu>
References: <20090626153012.GA23103@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090626153012.GA23103-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> I dunno...  does this seem worth a shot?  Or should I just go ahead
> and #define CKPT_ARCH_NSIG in arch/s390/include/asm/checkpoint_hdr.h
> after all?

How about leaving definition in checkpoint_hdr.h, and adding
somewhere a compile bug (under __KERNEL__) if there is a
mismatch, i.e. if CKPT_ARCH_NSIG != _NSIG ?

Oren.

> 
> From c128ce9ebc0bea5801f90ba99a58fcc18b7df84f Mon Sep 17 00:00:00 2001
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Date: Fri, 26 Jun 2009 10:59:17 -0400
> Subject: [PATCH 1/1] cr: move CKPT_ARCH_NSIG to asm/signal.h
> 
> Just a thought...  if the signal code changes we don't want
> the checkpoint code getting out of sync.  But putting it where
> it really belongs - asm/sigcontext.h - doesn't work bc that's
> under ifdef __KERNEL__.  So does this seem like a reasonable thing
> to do?
> 
> Also define the value for s390.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  arch/s390/include/asm/signal.h        |    2 ++
>  arch/x86/include/asm/checkpoint_hdr.h |    2 --
>  arch/x86/include/asm/signal.h         |    1 +
>  include/linux/checkpoint_hdr.h        |    1 +
>  4 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/s390/include/asm/signal.h b/arch/s390/include/asm/signal.h
> index f6cfddb..bcd7afa 100644
> --- a/arch/s390/include/asm/signal.h
> +++ b/arch/s390/include/asm/signal.h
> @@ -38,6 +38,8 @@ typedef unsigned long sigset_t;
>  
>  #endif /* __KERNEL__ */
>  
> +#define CKPT_ARCH_NSIG	64
> +
>  #define SIGHUP           1
>  #define SIGINT           2
>  #define SIGQUIT          3
> diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
> index 745038b..16485ca 100644
> --- a/arch/x86/include/asm/checkpoint_hdr.h
> +++ b/arch/x86/include/asm/checkpoint_hdr.h
> @@ -44,8 +44,6 @@ enum {
>  	CKPT_HDR_MM_CONTEXT_LDT,
>  };
>  
> -#define CKPT_ARCH_NSIG  64
> -
>  struct ckpt_hdr_header_arch {
>  	struct ckpt_hdr h;
>  	/* FIXME: add HAVE_HWFP */
> diff --git a/arch/x86/include/asm/signal.h b/arch/x86/include/asm/signal.h
> index 7761a5d..de9147d 100644
> --- a/arch/x86/include/asm/signal.h
> +++ b/arch/x86/include/asm/signal.h
> @@ -40,6 +40,7 @@ typedef unsigned long sigset_t;
>  #endif /* __KERNEL__ */
>  #endif /* __ASSEMBLY__ */
>  
> +#define CKPT_ARCH_NSIG  64
>  #define SIGHUP		 1
>  #define SIGINT		 2
>  #define SIGQUIT		 3
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 37bae3d..7d16664 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -12,6 +12,7 @@
>  
>  #include <linux/types.h>
>  #include <linux/utsname.h>
> +#include <asm/signal.h> /* for CKPT_ARCH_NSIG */
>  
>  /*
>   * To maintain compatibility between 32-bit and 64-bit architecture flavors,
