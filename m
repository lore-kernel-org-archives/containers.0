From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/2] CR: save/restore a single, simple task
Date: Thu, 31 Jul 2008 19:15:37 +0200
Message-ID: <4891F339.6030404@fr.ibm.com>
References: <Pine.LNX.4.64.0807292306570.9868@takamine.ncl.cs.columbia.edu>
	<20080730213541.GA24192@us.ibm.com>
	<4890FD57.7050601@cs.columbia.edu> <4891A0C4.5080906@fr.ibm.com>
	<4891D962.3020407@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4891D962.3020407-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

Oren Laadan wrote:
> 
> Daniel Lezcano wrote:
>> Oren Laadan wrote:
>>> Disclaimer: long reply :)
>>>
>>> Serge E. Hallyn wrote:
>>>> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>>>> In the recent mini-summit at OLS 2008 and the following days it was
>>>>> agreed to tackle the checkpoint/restart (CR) by beginning with a very
>>>>> simple case: save and restore a single task, with simple memory
>>>>> layout, disregarding other task state such as files, signals etc.
>>>>>
>>>>> Following these discussions I coded a prototype that can do exactly
>>>>> that, as a starter. This code adds two system calls - sys_checkpoint
>>>>> and sys_restart - that a task can call to save and restore its state
>>>>> respectively. It also demonstrates how the checkpoint image file can
>>>>> be formatted, as well as show its nested nature (e.g. cr_write_mm()
>>>>> -> cr_write_vma() nesting).
>>>>>
>>>>> The state that is saved/restored is the following:
>>>>> * some of the task_struct
>>>>> * some of the thread_struct and thread_info
>>>>> * the cpu state (including FPU)
>>>>> * the memory address space
>>>>>
>>>>> [The patch is against commit fb2e405fc1fc8b20d9c78eaa1c7fd5a297efde43
>>>>> of Linus's tree (uhhh.. don't ask why), but against tonight's head 
>>>>> too].
>>>>>
>>>>> In the current code, sys_checkpoint will checkpoint the current task,
>>>>> although the logic exists to checkpoint other tasks (not in the
>>>>> checkpointee's execution context). A simple loop will extend this to
>>>>> handle multiple processes. sys_restart restarts the current tasks, and
>>>>> with multiple tasks each task will call the syscall independently.
>>>> I assume that approach worked in Zap, so there must be a simple solution
>>>> to this, but I don't see how having each process in a container
>>>> independently call sys_restart works for sharing.  Oh, or is that where
>>> The main reason to do that (and I thought openvz works similarly ?) is
>>> that I want to re-use as much as possible the existing kernel 
>>> functionality.
>>> Restart differs from checkpoint in that you have to construct new 
>>> resources
>>> as opposed to only inspect existing resources. To inspect - you only need
>>> a reference to the object and then to obtain its state by accessing 
>>> it. In
>>> contrast, to construct, you need to create a new resource.
>>>
>>> In almost all cases, creating a resource for a process is easiest if 
>>> done by
>>> the process itself. For instance - to restore the memory map, you want 
>>> the
>>> process that owns the target mm to call mmap() (in particular, the lower
>>> level and more convenient for us do_mmap_pgoff() function). If the 
>>> process
>>> that restores a given vma didn't own that mm, it would take much more 
>>> pain
>>> to build the vma into a "foreign" mm.
>>>
>>> Thus, there is a huge advantage of doing everything in-context of the 
>>> target
>>> process, that is - we can re-use the existing kernel code (and spirit) to
>>> create the resources, instead of having to hand-craft them carefully with
>>> specialized code.
>>>
>>>> a 'container restart context' comes in?  An nsproxy has a pointer to a
>>> More or less. At a first approximation, this is how I envision it:
>>>
>>> 0) in user space, a new (empty) container will be created with all the
>>> needed settings for the file system etc (mounts .. and the like)
>>>
>>> 1) the first task (container init) will call sys_restart with the 
>>> checkpoint
>>> image file.
>>>
>>> 2) the code will verify the header, then read in the global section; 
>>> it will
>>> create a restart-context which will be referenced from the 
>>> container-object
>>> (one option we considered is to have the freezer-cgroup be that object).
>>>
>>> 3) using the info from that section, it will create the task tree 
>>> (forest)
>>> to be restored. In particular, new tasks will be created and each will 
>>> end
>>> up in do_restart_task() inside the kernel.
>>>
>>> [note that in Zap, step 3 is still done in user space...]
>>>
>>> Since all tasks live in the container, they will all have access to the
>>> restart-context, through which all coordination is done.
>>>
>>> At first, the restart will be performed _one task at a time_, at the 
>>> order
>>> they were dumped. So while the init task restores itself, the remaining
>>> tasks sleep. When the init task finishes - it will wake the next in line
>>> and so on. The last one will wake the init task to finalize the work. So:
>>>
>>> 4) each task waits (sleeps) until it is prompted to restore its own 
>>> state.
>>> When it completes, it wakes up the next task in line and goes to a freeze
>>> state.
>>>
>>> 5) the init task finalized the restart, and either completes the 
>>> freeze or
>>> unfreezes the container, depending on what the user requested.
>>>
>>> This scheme makes sense because we assume that the data is streamed. 
>>> So it
>>> does not make much sense to try to restart the 5th job before the 2nd job
>>> because the data isn't there yet. Moreover, if they refer to the same 
>>> shared
>>> object, job#5 will have to wait to job#2 to create the object, since its
>>> state was saved with that job.
>>>
>>> In the future, to speed the process by concurrent restarting multiple 
>>> tasks,
>>> we'll have to read in data from the stream into a buffer (read-ahead) and
>>> then restarting tasks could skip data that doesn't belongs to them; while
>>> they may still need to wait for shared resources to be created, other 
>>> work
>>> can be done in parallel in the meanwhile.
>>>
>>>> checkpoint/restart context which the first task creates and all tasks
>>>> reference and update?  So task 5 created its mm_struct, task 6 is
>>>> supposed to use the same mm_struct, so it finds that out from the
>>>> context?  I wonder whether that would start to become complicated
>>>> when checkpointing nested containers.
>>> Yes, that's what I had in mind - the restart context holds a hash table
>>> that references all the shared objects that are created during the 
>>> restart.
>>> (Like the checkpoint context that will hold references to objects that
>>> have been inspected).
>>>
>>> Checkpointing nested containers ???   Why ?
>>> I'm not sure why would that be a problem; but sure, we need to discuss
>>> that using a concrete use-case and identify the needs and difficulties.
>> In the current proposition, we talked about creating an empty container 
>> and the first process calls sys_restart. With nested container, we have 
>> to CR the container itself no ? I don't see how we can CR nested 
>> container otherwise :/
> 
> Probably so: with nested containers it is necessary to also save the state
> of the "container-tree" (which is sort of analogous to task-tree).
> In particular, because tasks in nested containers are essentially part
> of the outermost container that is being checkpointed. Is this issue
> specific to the proposed scheme, or a general issue of any scheme ?

I meant an issue with the proposed scheme. How to sys_restart 
recursively on a pid 1 with nested container if we want to create the 
container and having the first process calling sys_restart ?

But anyway, let's checkpoint a single container before :)

> I think that to tackle this, we need to first agree and implement an
> object that represents a container (again, the freezer_cgroup ?).

Didn't we state on creating a checkpoint/restart control group 
sub-system to have the context allocated ?

>>>> So I still prefer the idea that the init process calls restart, and that
>>>> creates all the tasks in the container and rebuilds them.  But you have
>>>> code, so you win :)
>>> I agree: the init task calls restart, and that creates all the tasks in
>>> the container. And then, make each of them call do_restart_task() in
>>> some way :)
>>>
>>>> Anyway I'm still reading through patch 2.  It looks great to me - the
>>>> only comments I have written so far are:
>>>>     1. why not just store LINUX_VERSION_CODE in the header instead
>>>>     of breaking it up
>>> hmph ... good question. Avoid 32/64 bit conversion complications ?
>>>
>>>>     2. the x86-specific code should of course go into arch-specific
>>>>     directories, but 
>>> of course. I left it there for simplicity right now.
>>>
>>>> neither of which really is worth the bother right now imo :)
>>>>
>>>>> (Actually, to checkpoint outside the context of a task, it is also
>>>>> necessary to also handle restart-block logic when saving/restoring the
>>>>> thread data).
>>>>>
>>>>> It takes longer to describe what isn't implemented or supported by
>>>>> this prototype ... basically everything that isn't as simple as the
>>>>> above.
>>>>>
>>>>> As for containers - since we still don't have a representation for a
>>>>> container, this patch has no notion of a container. The tests for
>>>>> consistent namespaces (and isolation) are also omitted.
>>>>>
>>>>> Below are two example programs: one uses checkpoint (called ckpt) and
>>>>> one uses restart (called rstr). Execute like this (as a superuser):
>>>>>
>>>>> orenl:~/test$ ./ckpt > out.1
>>>>> hello, world!  (ret=1)        <-- sys_checkpoint returns positive id
>>>>>                  <-- ctrl-c
>>>>> orenl:~/test$ ./ckpt > out.2
>>>>> hello, world!  (ret=2)
>>>>>                  <-- ctrl-c
>>>>> orenl:~/test$ ./rstr < out.1
>>>>> hello, world!  (ret=0)        <-- sys_restart return 0
>>>>>
>>>>> (if you check the output of ps, you'll see that "rstr" changed its
>>>>> name to "ckpt", as expected).
>>>>>
>>>>> Hoping this will accelerate the discussion. Comments are welcome.
>>>>> Let the fun begin :)
>>>>>
>>>>> Oren.
>>>>>
>>>>>
>>>>> ============================== ckpt.c ================================
>>>>>
>>>>> #define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */
>>>>>
>>>>> #include <stdio.h>
>>>>> #include <stdlib.h>
>>>>> #include <errno.h>
>>>>> #include <fcntl.h>
>>>>> #include <unistd.h>
>>>>> #include <asm/unistd_32.h>
>>>>> #include <sys/syscall.h>
>>>>>
>>>>> int main(int argc, char *argv[])
>>>>> {
>>>>>      pid_t pid = getpid();
>>>>>      int ret;
>>>>>
>>>>>      ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, 0);
>>>>>      if (ret < 0)
>>>>>          perror("checkpoint");
>>>>>
>>>>>      fprintf(stderr, "hello, world!  (ret=%d)\n", ret);
>>>>>
>>>>>      while (1)
>>>>>          ;
>>>>>
>>>>>      return 0;
>>>>> }
>>>>>
>>>>> ============================== rstr.c ================================
>>>>>
>>>>> #define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */
>>>>>
>>>>> #include <stdio.h>
>>>>> #include <stdlib.h>
>>>>> #include <errno.h>
>>>>> #include <fcntl.h>
>>>>> #include <unistd.h>
>>>>> #include <asm/unistd_32.h>
>>>>> #include <sys/syscall.h>
>>>>>
>>>>> int main(int argc, char *argv[])
>>>>> {
>>>>>      pid_t pid = getpid();
>>>>>      int ret;
>>>>>
>>>>>      ret = syscall(__NR_restart, pid, STDIN_FILENO, 0);
>>>>>      if (ret < 0)
>>>>>          perror("restart");
>>>>>
>>>>>      printf("should not reach here !\n");
>>>>>
>>>>>      return 0;
>>>>> }
