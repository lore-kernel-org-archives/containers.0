From: Guofu Xiang <whxgf1984-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: How to enable SYSENTER/SYSEXIT in glibc-2.7?
Date: Mon, 13 Apr 2009 17:10:20 +0800
Message-ID: <d15b2c7b0904130210j7ff25665h539546d239db5697@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: brian.haley-VXdhtT5mjnY@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

I have known that from glibc-2.3.1-25, SYSENTER is supported as the default.
Now, My OS is Fedora 8(kernel version:
linux-2.6.23), and glibc-2.7-2 is the default. When I compile C program,
this is the debug result by gdb:

     (gdb) disas __kernel_vsyscall
     Dump of assembler code for function __kernel_vsyscall:
     0xb7f7a400 <__kernel_vsyscall+0>:       int    $0x80
     0xb7f7a402 <__kernel_vsyscall+2>:       ret
     End of assembler dump.

     The system call is implemented by int $80h, rather than SYSENTER. What
is the reason? How to set SYSENTER as the default implementation of system
call? Thank you for your response!
