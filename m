From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 08/10] Introduce functions to restart a process
Date: Mon, 20 Oct 2008 11:23:24 +0200
Message-ID: <48FC4E0C.7050008@fr.ibm.com>
References: <1224285098-573-1-git-send-email-major@openvz.org>	<1224285098-573-2-git-send-email-major@openvz.org>	<1224285098-573-3-git-send-email-major@openvz.org>	<1224285098-573-4-git-send-email-major@openvz.org>	<1224285098-573-5-git-send-email-major@openvz.org>	<1224285098-573-6-git-send-email-major@openvz.org>	<1224285098-573-7-git-send-email-major@openvz.org>	<1224285098-573-8-git-send-email-major@openvz.org>
	<1224285098-573-9-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224285098-573-9-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello Andrey !


> diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
> index 109792b..a4848a3 100644
> --- a/arch/x86/kernel/entry_32.S
> +++ b/arch/x86/kernel/entry_32.S
> @@ -225,6 +225,7 @@ ENTRY(ret_from_fork)
>  	GET_THREAD_INFO(%ebp)
>  	popl %eax
>  	CFI_ADJUST_CFA_OFFSET -4
> +ret_from_fork_tail:
>  	pushl $0x0202			# Reset kernel eflags
>  	CFI_ADJUST_CFA_OFFSET 4
>  	popfl
> @@ -233,6 +234,26 @@ ENTRY(ret_from_fork)
>  	CFI_ENDPROC
>  END(ret_from_fork)
>  
> +ENTRY(i386_ret_from_resume)
> +	CFI_STARTPROC
> +	pushl %eax
> +	CFI_ADJUST_CFA_OFFSET 4
> +	call schedule_tail
> +	GET_THREAD_INFO(%ebp)
> +	popl %eax
> +	CFI_ADJUST_CFA_OFFSET -4
> +	movl (%esp), %eax
> +	testl %eax, %eax
> +	jz    1f
> +	pushl %esp
> +	call  *%eax
> +	addl  $4, %esp
> +1:
> +	addl  $256, %esp
> +	jmp   ret_from_fork_tail
> +	CFI_ENDPROC
> +END(i386_ret_from_resume)

Could you explain why you need to do this  

	call  *%eax

is it related to the freezer code ? 

C.
