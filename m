From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 08/10] Introduce functions to restart a process
Date: Wed, 22 Oct 2008 14:47:50 +0200
Message-ID: <48FF20F6.1040505__796.462680637155$1224679907$gmane$org@fr.ibm.com>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-9-git-send-email-major@openvz.org>
	<48FC4E0C.7050008@fr.ibm.com> <200810221249.55600.major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200810221249.55600.major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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

>>> +ENTRY(i386_ret_from_resume)
>>> +	CFI_STARTPROC
>>> +	pushl %eax
>>> +	CFI_ADJUST_CFA_OFFSET 4
>>> +	call schedule_tail
>>> +	GET_THREAD_INFO(%ebp)
>>> +	popl %eax
>>> +	CFI_ADJUST_CFA_OFFSET -4
>>> +	movl (%esp), %eax
>>> +	testl %eax, %eax
>>> +	jz    1f
>>> +	pushl %esp
>>> +	call  *%eax
>>> +	addl  $4, %esp
>>> +1:
>>> +	addl  $256, %esp
>>> +	jmp   ret_from_fork_tail
>>> +	CFI_ENDPROC
>>> +END(i386_ret_from_resume)
>> Could you explain why you need to do this
>>
>> 	call  *%eax
>>
>> is it related to the freezer code ?
> 
> It is not related to the freezer code actually.
> That is needed to restart syscalls. Right now I don't have a code in my 
> patchset which restarts a syscall, but later I plan to add it.
> In OpenVZ checkpointing we restart syscalls if process was caught in syscall 
> during checkpointing.

ok. I get it now. why 256 bytes of extra stack ? I'm sure it's not random. 

Thanks,

C.
