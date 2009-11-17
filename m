From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH user-cr 2/2] add nsexeccwp to test clone-with-pids
Date: Mon, 16 Nov 2009 22:05:26 -0600
Message-ID: <20091117040526.GA11241@hallyn.com>
References: <1258089886-10034-1-git-send-email-serue@us.ibm.com>
	<1258089886-10034-3-git-send-email-serue@us.ibm.com>
	<1258325156.4031.3.camel@localhost.localdomain>
	<20091116111249.GA32340@us.ibm.com>
	<1258328984.4031.21.camel@localhost.localdomain>
	<20091116182655.GA3777@us.ibm.com>
	<1258413522.4031.1036.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1258413522.4031.1036.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> Okay, here's the violence I've committed against your code to get eclone
> working on powerpc (tested 32-bit userspace against 64-bit kernel).
> 
> ./nsexeccwp -z 300 /bin/bash -c 'echo $$'
> [debugging cruft elided]
> 300
> 
> This is meant not for inclusion but for discussion at this point.  I
> made some changes that will certainly break the builds for other
> architectures.
> 
> Note that I have generic code initializing clone_args with the true
> stack base and size and passing that to the architecture code.  The
> architecture code (e.g. clone_ppc.c) is responsible for calculating the
> stack pointer to pass to the kernel.  The architecture code is also
> responsible for clearing clone_args.child_stack_size and updating
> clone_args.child_stack, adjusting for alignment and arguments if
> appropriate.  In this way, we can accommodate ia64 and parisc and keep
> platform details in platform-specific code.

...

> diff --git a/clone_ppc.c b/clone_ppc.c
> index 49797fd..9e19fae 100644
> --- a/clone_ppc.c
> +++ b/clone_ppc.c
> @@ -10,14 +10,25 @@
>  
>  #define _GNU_SOURCE
>  
> +#include <stdint.h>
> +#include <stdio.h>
> +#include <string.h>
>  #include <unistd.h>
>  #include <errno.h>
>  #include <sys/types.h>
>  #include <sys/syscall.h>
>  #include <asm/unistd.h>
>  
> +#include "eclone.h"
> +
>  struct target_pid_set;
>  
> +struct pid_set {
> +	size_t nr_pids;
> +	pid_t *pids;
> +};

You shouldn't need the pid_set any more right?

...

> @@ -305,12 +294,17 @@ int main(int argc, char *argv[])
>  			return -1;
>  		}
>  
> +		memset(&clone_args, 0, sizeof(clone_args));
> +		clone_args.child_stack = (unsigned long)stack;
> +		clone_args.child_stack_size = stacksize;
> +		clone_args.nr_pids = nr_pids;
> +
>  		printf("about to clone with %lx\n", flags);
>  		if (chosen_pid)
>  			printf("Will choose pid %d\n", chosen_pid);
> +		printf("argv = %p\n", argv);
>  		flags |= SIGCHLD;
> -		pid = clone_with_pids(do_child, stack, flags, &pid_set,
> -					(void *)argv);
> +		pid = eclone(do_child, argv, flags, &clone_args, &chosen_pid);
>  		if (pid == -1) {
>  			perror("clone");
>  			return -1;

Yup, of course I agree with switching to a clean eclone passing
the clone_args and no struct pid_set, i was just trying to
minimize (to 0 :) the changes required for now in restart.c.

If you don't mind sending the patch to update restart.c as
well as this (minus some debugging) when you're ready, I'll
port clone_s390x.c to your precise api.

thanks,
-serge
