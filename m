From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 6/9] Make AT_VECTOR_SIZE_ARCH 2 for x86-32
Date: Mon, 08 Feb 2010 22:42:07 -0500
Message-ID: <4B70D98F.20303@cs.columbia.edu>
References: <1265680806-13295-1-git-send-email-serue@us.ibm.com>
	<1265680806-13295-7-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1265680806-13295-7-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


Are you going to send this to mainline ?

serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Both x86-32 and x86-64 with 32-bit compat use ARCH_DLINFO_IA32,
> which defines two saved_auxv entries.  But system.h only defines
> AT_VECTOR_SIZE_ARCH as 2 for CONFIG_IA32_EMULATION, not for
> CONFIG_X86_32.  Fix that.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  arch/x86/include/asm/system.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/include/asm/system.h b/arch/x86/include/asm/system.h
> index ecb544e..e04740f 100644
> --- a/arch/x86/include/asm/system.h
> +++ b/arch/x86/include/asm/system.h
> @@ -11,9 +11,9 @@
>  #include <linux/irqflags.h>
>  
>  /* entries in ARCH_DLINFO: */
> -#ifdef CONFIG_IA32_EMULATION
> +#if defined(CONFIG_IA32_EMULATION) || !defined(CONFIG_X86_64)
>  # define AT_VECTOR_SIZE_ARCH 2
> -#else
> +#else /* else it's non-compat x86-64 */
>  # define AT_VECTOR_SIZE_ARCH 1
>  #endif
>  
