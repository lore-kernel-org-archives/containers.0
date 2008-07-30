From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/2] CR: save/restore a single, simple task
Date: Wed, 30 Jul 2008 16:35:41 -0500
Message-ID: <20080730213541.GA24192@us.ibm.com>
References: <Pine.LNX.4.64.0807292306570.9868@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0807292306570.9868-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> In the recent mini-summit at OLS 2008 and the following days it was
> agreed to tackle the checkpoint/restart (CR) by beginning with a very
> simple case: save and restore a single task, with simple memory
> layout, disregarding other task state such as files, signals etc.
> 
> Following these discussions I coded a prototype that can do exactly
> that, as a starter. This code adds two system calls - sys_checkpoint
> and sys_restart - that a task can call to save and restore its state
> respectively. It also demonstrates how the checkpoint image file can
> be formatted, as well as show its nested nature (e.g. cr_write_mm()
> -> cr_write_vma() nesting).
> 
> The state that is saved/restored is the following:
> * some of the task_struct
> * some of the thread_struct and thread_info
> * the cpu state (including FPU)
> * the memory address space
> 
> [The patch is against commit fb2e405fc1fc8b20d9c78eaa1c7fd5a297efde43
> of Linus's tree (uhhh.. don't ask why), but against tonight's head too].
> 
> In the current code, sys_checkpoint will checkpoint the current task,
> although the logic exists to checkpoint other tasks (not in the
> checkpointee's execution context). A simple loop will extend this to
> handle multiple processes. sys_restart restarts the current tasks, and
> with multiple tasks each task will call the syscall independently.

I assume that approach worked in Zap, so there must be a simple solution
to this, but I don't see how having each process in a container
independently call sys_restart works for sharing.  Oh, or is that where
a 'container restart context' comes in?  An nsproxy has a pointer to a
checkpoint/restart context which the first task creates and all tasks
reference and update?  So task 5 created its mm_struct, task 6 is
supposed to use the same mm_struct, so it finds that out from the
context?  I wonder whether that would start to become complicated
when checkpointing nested containers.

So I still prefer the idea that the init process calls restart, and that
creates all the tasks in the container and rebuilds them.  But you have
code, so you win :)

Anyway I'm still reading through patch 2.  It looks great to me - the
only comments I have written so far are:
	1. why not just store LINUX_VERSION_CODE in the header instead
	of breaking it up
	2. the x86-specific code should of course go into arch-specific
	directories, but 
neither of which really is worth the bother right now imo :)

> (Actually, to checkpoint outside the context of a task, it is also
> necessary to also handle restart-block logic when saving/restoring the
> thread data).
> 
> It takes longer to describe what isn't implemented or supported by
> this prototype ... basically everything that isn't as simple as the
> above.
> 
> As for containers - since we still don't have a representation for a
> container, this patch has no notion of a container. The tests for
> consistent namespaces (and isolation) are also omitted.
> 
> Below are two example programs: one uses checkpoint (called ckpt) and
> one uses restart (called rstr). Execute like this (as a superuser):
> 
> orenl:~/test$ ./ckpt > out.1
> hello, world!  (ret=1)		<-- sys_checkpoint returns positive id
>  				<-- ctrl-c
> orenl:~/test$ ./ckpt > out.2
> hello, world!  (ret=2)
>  				<-- ctrl-c
> orenl:~/test$ ./rstr < out.1
> hello, world!  (ret=0)		<-- sys_restart return 0
> 
> (if you check the output of ps, you'll see that "rstr" changed its
> name to "ckpt", as expected).
> 
> Hoping this will accelerate the discussion. Comments are welcome.
> Let the fun begin :)
> 
> Oren.
> 
> 
> ============================== ckpt.c ================================
> 
> #define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */
> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <errno.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <asm/unistd_32.h>
> #include <sys/syscall.h>
> 
> int main(int argc, char *argv[])
> {
>  	pid_t pid = getpid();
>  	int ret;
> 
>  	ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, 0);
>  	if (ret < 0)
>  		perror("checkpoint");
> 
>  	fprintf(stderr, "hello, world!  (ret=%d)\n", ret);
> 
>  	while (1)
>  		;
> 
>  	return 0;
> }
> 
> ============================== rstr.c ================================
> 
> #define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */
> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <errno.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <asm/unistd_32.h>
> #include <sys/syscall.h>
> 
> int main(int argc, char *argv[])
> {
>  	pid_t pid = getpid();
>  	int ret;
> 
>  	ret = syscall(__NR_restart, pid, STDIN_FILENO, 0);
>  	if (ret < 0)
>  		perror("restart");
> 
>  	printf("should not reach here !\n");
> 
>  	return 0;
> }
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
