From: Albert Cahalan <acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 11/11][v15]: Document sys_eclone
Date: Sat, 3 Jul 2010 19:41:30 -0400
Message-ID: <AANLkTinM1jqG-9Mgbzft8bALGri7ZpzU9ZcPbMTe4fvW@mail.gmail.com>
References: <1278189164-28408-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1278189164-28408-12-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1278189164-28408-12-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Jul 3, 2010 at 4:32 PM, Sukadev Bhattiprolu
<sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> +struct clone_args {
> +       u64 clone_flags_high;
> +       u64 child_stack_base;
> +       u64 child_stack_size;
> +       u64 parent_tid_ptr;
> +       u64 child_tid_ptr;
> +       u32 nr_pids;
> +       u32 reserved0;
> +};
> +
> +
> +sys_eclone(u32 flags_low, struct clone_args * __user cargs, int cargs_size,
> +               pid_t * __user pids)

I don't see why cargs_size is needed for expansion if you have flags.

> +       The order of pids in @pids is oldest in pids[0] to youngest pid
> +       namespace in pids[nr_pids-1]. If the number of pids specified in the
> +       @pids list is fewer than the nesting level of the process, the pids
> +       are applied from youngest namespace. I.e if the process is nested in
> +       a level-6 pid namespace and @pids only specifies 3 pids, the 3 pids
> +       are applied to levels 6, 5 and 4. Levels 0 through 3 are assumed to
> +       have a pid of '0' (the kernel will assign a pid in those namespaces).

That feels backwards. I'd have guessed pids[0] is how the
process sees itself. You'd truncate the array to reduce nesting
level rather than pointing into it.

> +       On failure, eclone() returns -1 and sets 'errno' to one of following
> +       values (the child process is not created).

Careful here: do you intend to document the system call itself,
or an expected glibc wrapper that doesn't exist yet?

> +       EPERM   Caller does not have the CAP_SYS_ADMIN privilege needed to
> +               specify the pids in this call (if pids are not specifed
> +               CAP_SYS_ADMIN is not required).

It seems appropriate to let PID 1 in any PID namespace be
able to assign PIDs in it's own namespace and in any
child namespaces.

> +       EINVAL  The child_stack_size field is not 0 (on architectures that
> +               pass in a stack pointer in ->child_stack field).

need to change this

> +                "int $0x80\n\t"        /* Linux/i386 system call */
> +                "testl %0,%0\n\t"      /* check return value */
> +                "jne 1f\n\t"           /* jump if parent */
> +
> +                "popl %%esi\n\t"       /* get subthread function */
> +                "call *%%esi\n\t"      /* start subthread function */
> +                "movl %2,%0\n\t"
> +                "int $0x80\n"          /* exit system call: exit subthread */
...
> +/*
> + * Allocate a stack for the clone-child and arrange to have the child
> + * execute @child_fn with @child_arg as the argument.
> + */
...
> +       *--stack = child_arg;
> +       *--stack = child_fn;
...
> +static int do_clone(int (*child_fn)(void *), void *child_arg,
> +               unsigned int flags_low, int nr_pids, pid_t *pids_list)

There needs to be a way to pass child_fn and child_arg
via the kernel. Besides being required for kernel-managed
stacks, it's normally a saner interface. Stack setup would
be much like the stack setup for signal handlers. Imagine
using this for a vfork-like interface that didn't have painful
interactions with the compiler.

Speaking of vfork....

1. can you implement it for i386 (register starved) using eclone?

2. can you restart a pair of processes between vfork and execve?
