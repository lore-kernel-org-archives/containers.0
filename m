From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/6][cr-tests]: eclone-3: Fail if reserved fields are not 0
Date: Tue, 2 Feb 2010 15:09:39 -0600
Message-ID: <20100202210939.GE32305@us.ibm.com>
References: <20100202193508.GA8542@us.ibm.com>
	<20100202193822.GB8793@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100202193822.GB8793-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Date: Sat, 30 Jan 2010 12:53:04 -0800
> Subject: [PATCH 3/6][cr-tests]: eclone-3: Fail if reserved fields are not 0.
> 
> To ensure future extendability, we want the unused fields to be 0.
> Ensure eclone() fails if ->reserved0 field is non-0.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  eclone/Makefile   |    2 +-
>  eclone/eclone-3.c |  117 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 118 insertions(+), 1 deletions(-)
>  create mode 100644 eclone/eclone-3.c
> 
> diff --git a/eclone/Makefile b/eclone/Makefile
> index 95633d1..ebe508d 100644
> --- a/eclone/Makefile
> +++ b/eclone/Makefile
> @@ -3,7 +3,7 @@ CFLAGS = -Wall
> 
>  LDFLAGS = 
> 
> -PROGS = eclone-1 eclone-2
> +PROGS = eclone-1 eclone-2 eclone-3
> 
>  all: $(PROGS)
> 
> diff --git a/eclone/eclone-3.c b/eclone/eclone-3.c
> new file mode 100644
> index 0000000..5a972ce
> --- /dev/null
> +++ b/eclone/eclone-3.c
> @@ -0,0 +1,117 @@
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
> +/*
> + * Verify that eclone() fails if ->reserved0 field is non-zero.
> + */
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
> +	printf("FAIL: Child created with [%d, %d]. We expected eclone() to "
> +			"fail with EINVAL since ->reserved0 is non-zero\n",
> +			 gettid(), getpid());
> +	exit(2);
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
> +	ca.reserved0 = 0xdeadbeef;
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
> +	if (rc < 0 && errno == EINVAL) {
> +		printf("PASS: eclone() failed (->reserved0 is not 0)\n");
> +		exit(0);
> +	} else {
> +		printf("FAIL: Expected eclone() to fail with EINVAL");
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
> +	flags = SIGCHLD;
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
> -- 
> 1.6.6.1
