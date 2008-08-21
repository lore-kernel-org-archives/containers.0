From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v2][PATCH 1/9] kernel based checkpoint-restart
Date: Wed, 20 Aug 2008 22:58:21 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0808202251500.17436__42206.4050021165$1219287734$gmane$org@takamine.ncl.cs.columbia.edu>
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
To: dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
List-Id: containers.vger.kernel.org


These patches implement checkpoint-restart [CR v2]. This version adds
save and restore of open files state (regular files and directories)
which makes it more usable. Other changes address the feedback given
for the previous version. It is also refactored (along Dave's posting)
for easier reviewing.

Todo:
- Add support for x86-64 and improve ABI
- Refine or change syscall interface
- Extend to handle (multiple) tasks in a container
- Security (without CAPS_SYS_ADMIN files restore may fail)

Changelog:

[2008-Aug-20] v2:
   - Added dump and restore of open files (regular and directories);
     see the changes in the test program (ckpt.c)
   - Added basic handling of shared objects, and use 'parent tag'
   - Added documentation
   - Improved ABI, add 64bit padding for image data
   - Improved locking when saving/restoring memory
   - Added UTS information to header (release, version, machine)
   - Cleanup extraction of filename from a file pointer
   - Refactor to allow easier reviewing
   - Remove requirement for CAPS_SYS_ADMIN until we come up with a
     security policy (this means that file restore may fail)
   - Other cleanup in response to comments for v1

[2008-Jul-29] v1:
   - Initial version: support a single task with address space of only
     private anonymous or file-mapped VMAs; syscalls ignore pid/crid
     argument and act on current process.

--
(Dave Hansen's announcement)

At the containers mini-conference before OLS, the consensus among
all the stakeholders was that doing checkpoint/restart in the kernel
as much as possible was the best approach.  With this approach, the
kernel will export a relatively opaque 'blob' of data to userspace
which can then be handed to the new kernel at restore time.

This is different than what had been proposed before, which was
that a userspace application would be responsible for collecting
all of this data.  We were also planning on adding lots of new,
little kernel interfaces for all of the things that needed
checkpointing.  This unites those into a single, grand interface.

The 'blob' will contain copies of select portions of kernel
structures such as vmas and mm_structs.  It will also contain
copies of the actual memory that the process uses.  Any changes
in this blob's format between kernel revisions can be handled by
an in-userspace conversion program.

This is a similar approach to virtually all of the commercial
checkpoint/restart products out there, as well as the research
project Zap.

These patches basically serialize internel kernel state and write
it out to a file descriptor.  The checkpoint and restore are done
with two new system calls: sys_checkpoint and sys_restart.

In this incarnation, they can only work checkpoint and restore a
single task. The task's address space may consist of only private,
simple vma's - anonymous or file-mapped. The open files may consist
of only simple files and directories.

--
(Original announcement)

In the recent mini-summit at OLS 2008 and the following days it was
agreed to tackle the checkpoint/restart (CR) by beginning with a very
simple case: save and restore a single task, with simple memory
layout, disregarding other task state such as files, signals etc.

Following these discussions I coded a prototype that can do exactly
that, as a starter. This code adds two system calls - sys_checkpoint
and sys_restart - that a task can call to save and restore its state
respectively. It also demonstrates how the checkpoint image file can
be formatted, as well as show its nested nature (e.g. cr_write_mm()
-> cr_write_vma() nesting).

The state that is saved/restored is the following:
* some of the task_struct
* some of the thread_struct and thread_info
* the cpu state (including FPU)
* the memory address space

In the current code, sys_checkpoint will checkpoint the current task,
although the logic exists to checkpoint other tasks (not in the
checkpointee's execution context). A simple loop will extend this to
handle multiple processes. sys_restart restarts the current tasks, and
with multiple tasks each task will call the syscall independently.
(Actually, to checkpoint outside the context of a task, it is also
necessary to also handle restart-block logic when saving/restoring the
thread data).

It takes longer to describe what isn't implemented or supported by
this prototype ... basically everything that isn't as simple as the
above.

As for containers - since we still don't have a representation for a
container, this patch has no notion of a container. The tests for
consistent namespaces (and isolation) are also omitted.

Below are two example programs: one uses checkpoint (called ckpt) and
one uses restart (called rstr). Execute like this (as a superuser):

orenl:~/test$ ./ckpt > out.1
 				<-- ctrl-c
orenl:~/test$ cat /tmp/cr-rest.out
hello, world!
world, hello!
(ret = 1)

orenl:~/test$ ./ckpt > out.1
 				<-- ctrl-c
orenl:~/test$ cat /tmp/cr-rest.out
hello, world!
world, hello!
(ret = 2)

 				<-- now change the contents of the file
orenl:~/test$ sed -i 's/world, hello!/xxxx/' /tmp/cr-rest.out
orenl:~/test$ cat /tmp/cr-rest.out
hello, world!
xxxx
(ret = 2)

 				<-- and do the restart
orenl:~/test$ ./rstr < out.1
 				<-- ctrl-c
orenl:~/test$ cat /tmp/cr-rest.out
hello, world!
world, hello!
(ret = 0)

(if you check the output of ps, you'll see that "rstr" changed its
name to "ckpt", as expected).

Oren.


============================== ckpt.c ================================

#define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <asm/unistd.h>
#include <sys/syscall.h>

#define OUTFILE "/tmp/cr-test.out"

int main(int argc, char *argv[])
{
 	pid_t pid = getpid();
 	FILE *file;
 	int ret;

 	close(0);
 	close(2);

 	unlink(OUTFILE);
 	file = fopen(OUTFILE, "w+");
 	if (!file) {
 		perror("open");
 		exit(1);
 	}

 	fprintf(file, "hello, world!\n");
 	fflush(file);

 	ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, 0);
 	if (ret < 0) {
 		perror("checkpoint");
 		exit(2);
 	}

 	fprintf(file, "world, hello!\n");
 	fprintf(file, "(ret = %d)\n", ret);
 	fflush(file);

 	while (1)
 		;

 	return 0;
}

============================== rstr.c ================================

#define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <asm/unistd.h>
#include <sys/syscall.h>

int main(int argc, char *argv[])
{
 	pid_t pid = getpid();
 	int ret;

 	ret = syscall(__NR_restart, pid, STDIN_FILENO, 0);
 	if (ret < 0)
 		perror("restart");

 	printf("should not reach here !\n");

 	return 0;
}
