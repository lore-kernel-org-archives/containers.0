From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/2] c/r: [x86_32] sys_restore to use ptregs prototype
Date: Sun, 06 Dec 2009 17:51:40 -0500
Message-ID: <4B1C357C.2090003@cs.columbia.edu>
References: <1260131469-2917-1-git-send-email-orenl@cs.columbia.edu>
	<1260131469-2917-2-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1260131469-2917-2-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org




Oren Laadan wrote:
> Similar to other select syscalls (fork, clone, execve), sys_restart
> needs to access the pt_regs structure, so that it can modify it to
> restore the original state from the time of the checkpoint.
> 
> (This is less of an issue for x86-32, however is required for those
> architectures that otherwise save/restore partial state (e.g. not all
> registers) during syscall entry/exit, like x86-64.
> 
> This patch prepares to support c/r on x86-64, specifically:
> 
> * Changes the syscall prototype and definition to accept the pt_regs
>   struct as an argument (into %eax register).

I forgot to mention that this of course breaks s390 and ppc: you
need to provide an arch-dependent sys_restart() similar to how it's
done here.

Oren.

> 
> * Move arch/x86/mm/checkpoint*.c to arch/x86/kernel/...
> 
> * Split 32bit-dependent part of arch/x86/kernel/checkpoint.c into a
>   new arch/x86/kernel/checkpoint_32.c
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> ---
