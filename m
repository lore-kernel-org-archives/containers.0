From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [RFC][v7][PATCH 8/9]: Define clone2() syscall
Date: Thu, 24 Sep 2009 23:43:59 +0200
Message-ID: <200909242343.59903.arnd__10543.5894839049$1253828946$gmane$org@arndb.de>
References: <20090924165548.GA16586@us.ibm.com>
	<20090924170308.GH16989@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090924170308.GH16989-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thursday 24 September 2009, Sukadev Bhattiprolu wrote:
> +asmlinkage long
> +sys_clone2(struct clone_struct __user *ucs, pid_t __user *pids)
> +{
> +       int rc;
> +       struct clone_struct kcs;
> +       unsigned long clone_flags;
> +       int __user *parent_tid_ptr;
> +       int __user *child_tid_ptr;
> +       unsigned long __user child_stack_base;
> +       struct pt_regs *regs;
> +
> +       rc = copy_from_user(&ucs, &kcs, sizeof(kcs));
> +       if (rc)
> +               return -EFAULT;
> +
> +       /*
> +        * TODO: Convert clone_flags to 64-bit
> +        */
> +       clone_flags = (unsigned long)kcs.flags;
> +       child_stack_base = (unsigned long)kcs.child_stack;
> +       parent_tid_ptr = &ucs.parent_tid;
> +       child_tid_ptr =  &ucs.child_tid;
> +       regs = task_pt_regs(current);
> +
> +       if (!child_stack_base)
> +               child_stack_base = user_stack_pointer(regs);
> +
> +       return do_fork_with_pids(clone_flags, child_stack_base, regs, 0,
> +                       parent_tid_ptr, child_tid_ptr, kcs.nr_pids, pids);
> +}
> +

The function looks ok, but you have put it into arch/x86/kernel/process_32.c,
which is specific to x86-32. Since the code in this form is generic, why
not just put it into kernel/fork.c? You should probably enclose it within
#ifdef CONFIG_HAVE_ARCH_TRACEHOOK to make sure that user_stack_pointer()
is implemented, but then it would be immediately usable by the nine architectures
implementing that. The other architectures can then decide between adding
their private version of sys_clone2 with an open-coded user_stack_pointer
implementation or alternatively implement the tracehooks.

	Arnd <><
