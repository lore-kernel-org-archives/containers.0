From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][cr-tests]: eclone-1: Test basic functionality
Date: Tue, 2 Feb 2010 14:07:20 -0600
Message-ID: <20100202200720.GA32305@us.ibm.com>
References: <20100202193508.GA8542@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100202193508.GA8542-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> 
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Sat, 30 Jan 2010 12:49:30 -0800
> Subject: [PATCH 1/6] eclone-1: Test basic functionality
> 
> Verify that a child process gets the expected pid and arguments on stack
> when it is created with eclone() system call.
> 
> NOTE:	The myclone() function in eclone-lib.c supports just x86 for now.
> 	Needs to be ported to other architectures.

Thanks, but

I'd prefer to see a libeclone patch for user-cr, and cr_tests programs
compiled against that.  user-cr already has done the ugliness required
to do eclone per-arch right now.

Would it be a lot of work to do so?  (I shouldn't think so)

thanks,
-serge

> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>  Makefile            |    2 +-
>  eclone/Makefile     |   16 +++++++
>  eclone/clone_args.h |   37 ++++++++++++++++
>  eclone/eclone-1.c   |  121 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  eclone/eclone-lib.c |   85 ++++++++++++++++++++++++++++++++++++
>  5 files changed, 260 insertions(+), 1 deletions(-)
>  create mode 100644 eclone/Makefile
>  create mode 100644 eclone/clone_args.h
>  create mode 100644 eclone/eclone-1.c
>  create mode 100644 eclone/eclone-lib.c
> 
> diff --git a/Makefile b/Makefile
> index 95f8b6e..1d412b9 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -1,5 +1,5 @@
>  SUBDIRS = libcrtest counterloop fileio simple userns ipc sleep \
> -	  process-tree futex epoll taskfs
> +	  process-tree futex epoll taskfs eclone
> 
>  targets = ns_exec mysu
> 
> diff --git a/eclone/Makefile b/eclone/Makefile
> new file mode 100644
> index 0000000..43cef65
> --- /dev/null
> +++ b/eclone/Makefile
> @@ -0,0 +1,16 @@
> +
> +CFLAGS = -Wall
> +
> +LDFLAGS = 
> +
> +PROGS = eclone-1
> +
> +all: $(PROGS)
> +
> +eclone-lib.o: eclone-lib.c clone_args.h
> +
> +$(PROGS): %: %.c eclone-lib.o
> +	$(CC) $(CFLAGS) -o $@ $< eclone-lib.o $(LDFLAGS)
> +
> +clean:
> +	rm -f $(PROGS) eclone-lib.o
> diff --git a/eclone/clone_args.h b/eclone/clone_args.h
> new file mode 100644
> index 0000000..393f139
> --- /dev/null
> +++ b/eclone/clone_args.h
> @@ -0,0 +1,37 @@
> +#include <errno.h>
> +
> +#define __NR_clone_with_pids 	337
> +#define __NR_clone3		337
> +#define __NR_eclone		337
> +#define __NR_clone 		120
> +#define __NR_exit 		1
> +#define __NR_getpid 		20
> +
> +#define CLONE_NEWPID            0x20000000
> +#define CLONE_CHILD_SETTID      0x01000000
> +#define CLONE_PARENT_SETTID     0x00100000
> +#define CLONE_UNUSED		0x00001000
> +
> +#define STACKSIZE	8192
> +
> +typedef unsigned long long u64;
> +typedef unsigned int u32;
> +typedef int pid_t;
> +struct clone_args {
> +        u64 clone_flags_high;
> +
> +        u64 child_stack_base;
> +        u64 child_stack_size;
> +
> +        u64 parent_tid_ptr;
> +        u64 child_tid_ptr;
> +
> +        u32 nr_pids;
> +
> +        u32 reserved0;
> +};
> +
> +void *setup_stack(int (*child_fn)(void *), void *child_arg, int stack_size);
> +int eclone(int flags_low, struct clone_args *clone_args, int args_size,
> +		int *pids);
> +int gettid();
> diff --git a/eclone/eclone-1.c b/eclone/eclone-1.c
> new file mode 100644
> index 0000000..06a10f9
> --- /dev/null
> +++ b/eclone/eclone-1.c
> @@ -0,0 +1,121 @@
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <errno.h>
> +#include <unistd.h>
> +#include <signal.h>
> +#include <string.h>
> +#include <sys/types.h>
> +#include <sys/wait.h>
> +#include <sys/syscall.h>
> +#include "clone_args.h"
> +
> +int verbose = 0;
> +int child_tid, parent_tid;
> +
> +#define CHILD_TID1	377
> +#define	CHILD_TID2	399
> +#define	CHILD_ARG	(void *)0x979797
> +
> +pid_t pids_list[] = { CHILD_TID1, CHILD_TID2 };
> +
> +int do_child(void *arg)
> +{
> +	sleep(3);
> +
> +	if (arg != CHILD_ARG) {
> +		printf("ERROR: Expected arg %p, actual %p\n", CHILD_ARG, arg);
> +		exit(1);
> +	}
> +
> +	if (gettid() != CHILD_TID1) {
> +		printf("FAIL: Child expected pid %d, actual %d\n", CHILD_TID1,
> +					getpid());
> +		exit(2);
> +	} else {
> +		printf("PASS: Child got expected pid %d\n", CHILD_TID1);
> +		exit(0);
> +	}
> +
> +}
> +
> +static int myclone(int (*child_fn)(void *), void *child_arg, 
> +		unsigned int flags_low, int nr_pids, pid_t *pids_list)
> +{
> +	int rc;
> +	void *stack;
> +	struct clone_args ca;
> +	int args_size;
> +
> +	stack = setup_stack(child_fn, child_arg, STACKSIZE);
> +	if (!stack) {
> +		printf("ERROR: setup_stack returns NULL for size %d\n",
> +				STACKSIZE);
> +		exit(1);
> +	}
> +
> +	memset(&ca, 0, sizeof(ca));
> +	ca.child_stack_base = (u64)(int)stack;
> +	ca.child_stack_size = (u64)0;
> +	ca.parent_tid_ptr = (u64)((int)&parent_tid);
> +	ca.child_tid_ptr = (u64)((int)&child_tid);
> +	ca.nr_pids = nr_pids;
> +
> +	if (verbose) {
> +		printf("[%d, %d]: Parent:\n\t child_stack 0x%p, ptidp %llx, "
> +				"ctidp %llx, pids %p\n", getpid(), gettid(),
> +				stack, ca.parent_tid_ptr, ca.child_tid_ptr,
> +				pids_list);
> +	}
> +
> +	args_size = sizeof(struct clone_args);
> +	rc = eclone(flags_low, &ca, args_size, pids_list);
> +
> +	if (verbose) {
> +		printf("[%d, %d]: eclone() returned %d, error %d\n", getpid(),
> +				gettid(), rc, errno);
> +		fflush(stdout);
> +	}
> +
> +	if (rc < 0) {
> +		printf("ERROR: ");
> +		exit(1);
> +	}
> +
> +	return rc;
> +}
> +
> +int main()
> +{
> +	int rc, pid, status;
> +	unsigned long flags; 
> +	int nr_pids = 1;
> +
> +	flags = SIGCHLD|CLONE_PARENT_SETTID|CLONE_CHILD_SETTID;
> +
> +	pid = myclone(do_child, (void *)CHILD_ARG, flags, nr_pids, pids_list);
> +
> +	if (verbose) {
> +		printf("[%d, %d]: Parent waiting for %d\n", getpid(),
> +					gettid(), pid);
> +	}
> +
> +	rc = waitpid(pid, &status, __WALL);
> +	if (rc < 0) {
> +		printf("ERROR: ");
> +		verbose = 1;
> +	}
> +
> +	if (verbose) {
> +		printf("\twaitpid(): child %d, rc %d, error %d, status 0x%x\n",
> +				getpid(), rc, errno, status);
> +		if (rc >=0) {
> +			if (WIFEXITED(status)) {
> +				printf("\t EXITED, %d\n", WEXITSTATUS(status));
> +			} else if (WIFSIGNALED(status)) {
> +				printf("\t SIGNALED, %d\n", WTERMSIG(status));
> +			} 
> +		}
> +	}
> +
> +	return 0;
> +}
> diff --git a/eclone/eclone-lib.c b/eclone/eclone-lib.c
> new file mode 100644
> index 0000000..f547945
> --- /dev/null
> +++ b/eclone/eclone-lib.c
> @@ -0,0 +1,85 @@
> +#define _GNU_SOURCE
> +#include <stdio.h>
> +#include <errno.h>
> +#include <stdlib.h>
> +#include <unistd.h>
> +#include <sys/syscall.h>
> +#include "clone_args.h"
> +
> +/* From Oren Laadan */
> +
> +#if defined(__i386__) && defined(__NR_eclone)
> +/*
> + * libc doesn't support eclone() yet...
> + * (see: http://lkml.indiana.edu/hypermail/linux/kernel/9604.3/0204.html)
> + */
> +
> +int eclone(int flags_low, struct clone_args *clone_args, int args_size,
> +		int *pids)
> +{
> +	long retval;
> +
> +	__asm__ __volatile__(
> +		 "movl %3, %%ebx\n\t"	/* flags_low -> 1st (ebx)  */
> +		 "movl %4, %%ecx\n\t"	/* clone_args -> 2nd (ecx) */
> +		 "movl %5, %%edx\n\t"	/* args_size -> 3rd (edx) */
> +		 "movl %6, %%esi\n\t"	/* pids -> 4th (esi) */
> +
> +		 "pushl %%ebp\n\t"	/* save value of ebp */
> +		 "int $0x80\n\t"	/* Linux/i386 system call */
> +		 "testl %0,%0\n\t"	/* check return value */
> +		 "jne 1f\n\t"		/* jump if parent */
> +		 "popl %%esi\n\t"	/* get subthread function */
> +		 "call *%%esi\n\t"	/* start subthread function */
> +		 "movl %2,%0\n\t"
> +		 "int $0x80\n"		/* exit system call: exit subthread */
> +		 "1:\n\t"
> +		 "popl %%ebp\t"		/* restore parent's ebp */
> +
> +		:"=a" (retval)
> +
> +		:"0" (__NR_clone3),
> +		 "i" (__NR_exit),
> +		 "b" (flags_low),
> +		 "c" (clone_args),
> +		 "d" (args_size),
> +		 "D" (pids)
> +	);
> +
> +	if (retval < 0) {
> +		errno = -retval;
> +		retval = -1;
> +	}
> +	return retval;
> +}
> +
> +void *setup_stack(int (*child_fn)(void *), void *child_arg, int size)
> +{
> +	void *stack_base;
> +	void **stack_top;
> +	
> +	stack_base = malloc(size);
> +	if (!stack_base)
> +		return NULL;
> +
> +	stack_top = (void **)((char *)stack_base + (size - 4));
> +	*--stack_top = child_arg;
> +	*--stack_top = child_fn;
> +
> +	return stack_top;
> +}
> +
> +#endif
> +
> +/* gettid() is a bit more useful than getpid() when messing with clone() */
> +int gettid()
> +{
> +	int rc;
> +
> +	rc = syscall(__NR_gettid, 0, 0, 0);
> +	if (rc < 0) {
> +		printf("rc %d, errno %d\n", rc, errno);
> +		exit(1);
> +	}
> +	return rc;
> +}
> -- 
> 1.6.6.1
