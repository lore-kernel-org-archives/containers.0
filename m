From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: How to enable SYSENTER/SYSEXIT in glibc-2.7?
Date: Mon, 13 Apr 2009 11:45:32 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904131140270.26713@localhost.localdomain>
References: <d15b2c7b0904130210j7ff25665h539546d239db5697@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <d15b2c7b0904130210j7ff25665h539546d239db5697-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Guofu Xiang <whxgf1984-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org



On Mon, 13 Apr 2009, Guofu Xiang wrote:
> 
>      (gdb) disas __kernel_vsyscall
>      Dump of assembler code for function __kernel_vsyscall:
>      0xb7f7a400 <__kernel_vsyscall+0>:       int    $0x80
>      0xb7f7a402 <__kernel_vsyscall+2>:       ret
>      End of assembler dump.

(gdb) disassemble __kernel_vsyscall
Dump of assembler code for function __kernel_vsyscall:
0xb8046414 <__kernel_vsyscall+0>:	push   %ecx
0xb8046415 <__kernel_vsyscall+1>:	push   %edx
0xb8046416 <__kernel_vsyscall+2>:	push   %ebp
0xb8046417 <__kernel_vsyscall+3>:	mov    %esp,%ebp
0xb8046419 <__kernel_vsyscall+5>:	sysenter 
0xb804641b <__kernel_vsyscall+7>:	nop    
0xb804641c <__kernel_vsyscall+8>:	nop    
0xb804641d <__kernel_vsyscall+9>:	nop    
0xb804641e <__kernel_vsyscall+10>:	nop    
0xb804641f <__kernel_vsyscall+11>:	nop    
0xb8046420 <__kernel_vsyscall+12>:	nop    
0xb8046421 <__kernel_vsyscall+13>:	nop    
0xb8046422 <__kernel_vsyscall+14>:	jmp    0xb8046417 <__kernel_vsyscall+3>
0xb8046424 <__kernel_vsyscall+16>:	pop    %ebp
0xb8046425 <__kernel_vsyscall+17>:	pop    %edx
0xb8046426 <__kernel_vsyscall+18>:	pop    %ecx
0xb8046427 <__kernel_vsyscall+19>:	ret    

>      The system call is implemented by int $80h, rather than SYSENTER. What
> is the reason? How to set SYSENTER as the default implementation of system
> call? Thank you for your response!

What CPU do you have?  We only enable sysenter on CPU's that support them 
well.

		Linus
