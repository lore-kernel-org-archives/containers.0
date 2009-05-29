From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: s390: define CKPT_ARCH_ID for s390
Date: Fri, 29 May 2009 06:16:52 -0400
Message-ID: <4A1FB614.6070506@cs.columbia.edu>
References: <20090528174503.GA22373@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090528174503.GA22373-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


applied, thanks.

Serge E. Hallyn wrote:
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  arch/s390/include/asm/checkpoint_hdr.h |    5 +++++
>  include/linux/checkpoint_hdr.h         |    1 +
>  2 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
> index 185194b..fc0ace8 100644
> --- a/arch/s390/include/asm/checkpoint_hdr.h
> +++ b/arch/s390/include/asm/checkpoint_hdr.h
> @@ -20,6 +20,11 @@
>  #include <sys/user.h>
>  #endif
>  
> +#ifdef CONFIG_64BIT
> +#define CKPT_ARCH_ID	CKPT_ARCH_S390X
> +/* else - if we ever support 32bit - CKPT_ARCH_S390 */
> +#endif
> +
>  /*
>   * Notes
>   * NUM_GPRS defined in <asm/ptrace.h> to be 16
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 46f38f3..7f4972b 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -89,6 +89,7 @@ enum {
>  /* architecture */
>  enum {
>  	CKPT_ARCH_X86_32 = 1,
> +	CKPT_ARCH_S390X,
>  };
>  
>  /* shared objrects (objref) */
